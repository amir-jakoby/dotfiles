---
name: remote-operator-debug
description: Use when checking customer-side collector pods, logs, or deployment state through remote-operator, especially when namespace or RBAC differs from the default assumptions.
---

# Remote Operator Debug

Use this only for customer-side checks. For shared platform components, use normal prod or staging `kubectl`.

## Prerequisites

- `remote-operator` binary in `PATH`
- customer Clerk org ID, or customer name you can resolve with `clerk`
- target environment: prod or staging

## Environment URLs

| Environment | Remote Operator Address |
| --- | --- |
| prod | `<prod_remote_operator_url>` |
| staging | `<staging_remote_operator_url>` |

## Fast Path

### 1. Resolve Org

If only customer name is known:

```bash
clerk orgs list -f "<customer_name>"
```

### 2. List Deployments

```bash
remote-operator -a <ro_address> -o <org_id> manage ls
```

Pick the deployment and a live instance from this output.

### 3. Discover Namespace First

Do not assume `sawmills`.

```bash
remote-operator -a <ro_address> -o <org_id> manage run \
  -d <deployment> --instance-name <instance> \
  -- kubectl auth can-i get pods -n sawmills

remote-operator -a <ro_address> -o <org_id> manage run \
  -d <deployment> --instance-name <instance> \
  -- kubectl auth can-i get pods -n sawmills-central
```

Then confirm with a namespaced read:

```bash
remote-operator -a <ro_address> -o <org_id> manage run \
  -d <deployment> --instance-name <instance> \
  -- kubectl get deploy -n <namespace>
```

### 4. Check Runtime

```bash
remote-operator -a <ro_address> -o <org_id> manage run \
  -d <deployment> --instance-name <instance> \
  -- kubectl get deploy -n <namespace>

remote-operator -a <ro_address> -o <org_id> manage run \
  -d <deployment> --instance-name <instance> \
  -- kubectl get pods -n <namespace> -o wide
```

### 5. Sample Recent Logs

Prefer pod-level logs over deployment-level logs when isolating one bad replica.

```bash
remote-operator -a <ro_address> -o <org_id> manage run \
  -d <deployment> --instance-name <instance> \
  -- kubectl logs -n <namespace> pod/<pod> -c main-collector --since=30m --tail=200
```

Focused grep:

```bash
remote-operator -a <ro_address> -o <org_id> manage run \
  -d <deployment> --instance-name <instance> \
  -- sh -lc 'kubectl logs -n <namespace> pod/<pod> -c main-collector --since=30m --tail=400 | rg -i "error|warn|refus|drop|timeout|fail|panic"'
```

### 6. Pull Events Only if Needed

```bash
remote-operator -a <ro_address> -o <org_id> manage run \
  -d <deployment> --instance-name <instance> \
  -- kubectl get events -n <namespace> --sort-by=.lastTimestamp
```

## RBAC Rules

- Expect namespace-scoped permissions only.
- `kubectl get ns` may fail.
- `kubectl get pods -A` may fail.
- `Forbidden` on cluster-scoped verbs does not mean the customer deployment is gone.
- Start with namespaced reads, not cluster inventory.

## Common Commands

```bash
# Deployment health
remote-operator ... -- kubectl describe deployment sawmills-collector -n <namespace>

# Helm values
remote-operator ... -- helm get values sawmills-collector -n <namespace>

# Restart, only with explicit approval
remote-operator ... -- kubectl rollout restart deployment/sawmills-collector -n <namespace>
```

## Troubleshooting

| Issue | Meaning | Next step |
| --- | --- | --- |
| `Forbidden` | RBAC denied current verb or scope | switch to namespaced command |
| `No resources found` | wrong namespace or object name | re-check namespace and deployment |
| `executable file not found` | tool missing in the remote container | use a simpler command or `sh -lc` |
| `timeout` | slow network or too much output | reduce scope with `--tail`, `--since`, or a single pod |

## Common Mistakes

- Using remote-operator for platform checks.
- Assuming namespace `sawmills`.
- Reading only one pod when the alert labels already name a different pod.
- Treating one `manage ls` snapshot as permanent; instance names change on redeploy.
