---
name: collector-troubleshooting
description: Systematic debugging of collector issues. Use when collector errors, "collector not working", "debug collector", or customer reports telemetry problems.
---

# Collector Troubleshooting

Systematic approach to debugging Sawmills collector issues.

## Prerequisites

- AWS authentication for the target environment
- **customer-config** skill: View configs
- **remote-operator-debug** skill: Run commands on customer collectors

## Workflow

### Step 1: Gather Context

Ask for:

- Org ID (clerk org)
- Environment (prod/staging)
- Error description or symptoms
- Collector/deployment name if known

### Step 2: Check Collector Status

```bash
remote-operator -a <ro_address> -o <org_id> manage ls
```

Look for:

- Pod count (expected vs actual)
- Container status (3/3 Running)
- Recent restarts

### Step 3: Check Logs for Errors

```bash
# Main collector logs
remote-operator -a <ro_address> -o <org_id> manage run \
  -d <deployment> --instance-name <instance> \
  -- kubectl logs -n sawmills deployment/sawmills-collector -c main-collector --tail 200

# HAProxy logs (connection issues)
remote-operator -a <ro_address> -o <org_id> manage run \
  -d <deployment> --instance-name <instance> \
  -- kubectl logs -n sawmills deployment/sawmills-collector -c haproxy --tail 100
```

### Step 4: Identify Error Category

| Error Pattern        | Likely Cause                     | Next Step                  |
| -------------------- | -------------------------------- | -------------------------- |
| `Unauthenticated`    | Wrong endpoint (staging vs prod) | Check config endpoints     |
| `route not defined`  | Missing routereceiver config     | Check pipeline config      |
| `ResourceExhausted`  | gRPC message too large           | Server-side limit increase |
| `connection refused` | Service down or wrong port       | Check endpoint URLs        |
| `deadline exceeded`  | Network/timeout issues           | Check connectivity         |

### Step 5: Check Config Endpoints

Use **s3-config-editor** skill to decrypt and inspect config.

Key endpoint shapes to verify (prod):

```yaml
# Example prod-style targets
livetail: <prod_livetail_endpoint>:443
telemetry_bucket: <prod_telemetry_bucket>
gateway: https://<prod_gateway_host>:443
prometheus: https://<prod_prometheus_host>/api/v1/push
```

Common mistake: staging endpoints in prod config.

### Step 6: Compare with Working Customer

Use **config-diff** skill to compare with a known-good reference config from the same environment.

```bash
# Decrypt both configs and diff
diff <(go run ./cmd/encrypt -decrypt -s3 "<customer_s3>") \
     <(go run ./cmd/encrypt -decrypt -s3 "<reference_s3>")
```

### Step 7: Check Helm Values

```bash
remote-operator -a <ro_address> -o <org_id> manage run \
  -d <deployment> --instance-name <instance> \
  -- helm get values sawmills-collector -n sawmills
```

Verify:

- `collector_gateway.endpoint`
- `prometheusremotewrite.endpoint`
- API keys present

### Step 8: Fix or Escalate

| Issue Type            | Action                          |
| --------------------- | ------------------------------- |
| Config endpoint wrong | Use **s3-config-editor** to fix |
| Helm values wrong     | Use remote-operator to update   |
| Server-side issue     | Create Linear ticket            |
| Unknown               | Consult team, attach logs       |

## Common Issues Reference

### Staging vs Prod Mixup

Symptoms: `Unauthenticated` errors
Fix: Replace all `staging` with `prod` in config endpoints

### Route Not Defined

Symptoms: `logstometricsprocessor` errors
Cause: Pipeline config missing metrics route
Fix: Pipeline config regeneration (pipelines-service)

### gRPC Message Too Large

Symptoms: `ResourceExhausted: message larger than max`
Cause: Batch size exceeds 4MB gRPC limit
Fix: Server-side limit increase or reduce batch size

## Notes

- Always check if Linear issue exists before creating new one
- Save decrypted configs to `/tmp/` for comparison
- Collector pods should be 3/3 Running with recent start time after deploy
