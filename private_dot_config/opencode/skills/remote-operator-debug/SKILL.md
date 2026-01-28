---
name: remote-operator-debug
description: Debug customer collectors via remote-operator CLI. Use when "collector logs", "customer kubectl", "remote operator", or need to run commands on customer Kubernetes clusters.
---

# Remote Operator Debug

Run kubectl and other commands on customer collectors via remote-operator.

## Prerequisites

- **aws-sso-login** skill: AWS authentication
- remote-operator binary in PATH

## Environment URLs

| Environment | Remote Operator Address |
|-------------|------------------------|
| prod | `https://REDACTED_INTERNAL_URL` |
| staging | `https://REDACTED_INTERNAL_URL` |

## Workflow

### Step 1: Get Org ID and Environment

Ask user for:
- Clerk org ID (e.g., `REDACTED_ORG_ID`)
- Environment (prod/staging)

### Step 2: List Deployments

```bash
remote-operator -a <ro_address> -o <org_id> manage ls
```

Output shows:
- Deployment names
- Instance names (needed for commands)
- Pod status

### Step 3: Run Commands

Basic pattern:
```bash
remote-operator -a <ro_address> -o <org_id> manage run \
  -d <deployment> --instance-name <instance> \
  -- <command>
```

## Common Commands

### Get Logs

```bash
# Main collector
remote-operator -a <ro_address> -o <org_id> manage run \
  -d <deployment> --instance-name <instance> \
  -- kubectl logs -n sawmills deployment/sawmills-collector -c main-collector --tail 200

# HAProxy
remote-operator -a <ro_address> -o <org_id> manage run \
  -d <deployment> --instance-name <instance> \
  -- kubectl logs -n sawmills deployment/sawmills-collector -c haproxy --tail 100

# Telemetry collector
remote-operator -a <ro_address> -o <org_id> manage run \
  -d <deployment> --instance-name <instance> \
  -- kubectl logs -n sawmills deployment/sawmills-collector -c telemetry-collector --tail 100
```

### Check Pod Status

```bash
remote-operator -a <ro_address> -o <org_id> manage run \
  -d <deployment> --instance-name <instance> \
  -- kubectl get pods -n sawmills
```

### Describe Deployment

```bash
remote-operator -a <ro_address> -o <org_id> manage run \
  -d <deployment> --instance-name <instance> \
  -- kubectl describe deployment sawmills-collector -n sawmills
```

### Get Helm Values

```bash
remote-operator -a <ro_address> -o <org_id> manage run \
  -d <deployment> --instance-name <instance> \
  -- helm get values sawmills-collector -n sawmills
```

### Restart Pods

```bash
remote-operator -a <ro_address> -o <org_id> manage run \
  -d <deployment> --instance-name <instance> \
  -- kubectl rollout restart deployment/sawmills-collector -n sawmills
```

### Check Events

```bash
remote-operator -a <ro_address> -o <org_id> manage run \
  -d <deployment> --instance-name <instance> \
  -- kubectl get events -n sawmills --sort-by='.lastTimestamp'
```

## Filtering Logs

```bash
# Grep for errors
remote-operator ... -- kubectl logs ... | grep -i error

# Filter by time (last 5 minutes)
remote-operator ... -- kubectl logs ... --since=5m

# Follow logs (streaming)
remote-operator ... -- kubectl logs ... -f
```

## Namespace

Default namespace is `sawmills`. Service account has limited permissions:
- Can access `sawmills` namespace
- Cannot list pods across all namespaces (`-A` flag fails)

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `executable file not found` | Command not available in container |
| `Forbidden` | Service account lacks permission |
| `No resources found` | Wrong namespace or no matching pods |
| `timeout` | Network issues or large output |

## Example Session

```bash
# 1. Set variables
ORG=REDACTED_ORG_ID
RO=https://REDACTED_INTERNAL_URL

# 2. List deployments
remote-operator -a $RO -o $ORG manage ls

# 3. Get logs from specific instance
remote-operator -a $RO -o $ORG manage run \
  -d SawmillsPoc --instance-name 7fc25w8 \
  -- kubectl logs -n sawmills deployment/sawmills-collector -c main-collector --tail 100
```

## Notes

- Instance name changes on redeployment; re-run `manage ls` to get current
- Large log output may be truncated; use `--tail` to limit
- Some commands like `logs` may default to wrong container; specify `-c`
