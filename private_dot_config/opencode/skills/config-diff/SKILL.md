---
name: config-diff
description: Compare collector configs between customers or environments. Use when "compare configs", "diff customer config", "why is config different", or debugging config discrepancies.
---

# Config Diff

Compare collector configurations between customers or environments to find discrepancies.

## Prerequisites

- **aws-sso-login** skill: AWS authentication
- **s3-config-editor** skill: Decrypt configs
- **customer-config** skill: Get S3 paths
- `yq` for YAML processing (optional)

## Workflow

### Step 1: Identify Configs to Compare

Common comparisons:
- Broken customer vs working customer
- Staging vs prod for same customer
- Current config vs expected template

### Step 2: Get S3 Paths

Use **customer-config** skill for each config:
```bash
# Get deployment description to find S3 path
remote-operator -a <ro_address> -o <org_id> manage run \
  -d <deployment> --instance-name <instance> \
  -- kubectl describe deployment sawmills-collector -n sawmills | grep -i s3
```

### Step 3: Decrypt Configs

```bash
cd /Users/amirjakoby/Code/sawmills-collector-reviews/confmap/provider/s3provider

# Customer A (broken)
go run ./cmd/encrypt -decrypt -s3 "<customer_a_s3_path>" > /tmp/config-a.yaml

# Customer B (working reference)
go run ./cmd/encrypt -decrypt -s3 "<customer_b_s3_path>" > /tmp/config-b.yaml
```

### Step 4: Compare Configs

#### Full Diff
```bash
diff /tmp/config-a.yaml /tmp/config-b.yaml
```

#### Side-by-Side
```bash
diff -y /tmp/config-a.yaml /tmp/config-b.yaml | head -100
```

#### Colored Diff
```bash
colordiff /tmp/config-a.yaml /tmp/config-b.yaml
```

### Step 5: Focus on Key Sections

#### Endpoints Only
```bash
echo "=== Config A ===" && grep -E "(endpoint|bucket|address)" /tmp/config-a.yaml
echo "=== Config B ===" && grep -E "(endpoint|bucket|address)" /tmp/config-b.yaml
```

#### Exporters
```bash
yq '.exporters' /tmp/config-a.yaml > /tmp/exporters-a.yaml
yq '.exporters' /tmp/config-b.yaml > /tmp/exporters-b.yaml
diff /tmp/exporters-a.yaml /tmp/exporters-b.yaml
```

#### Processors
```bash
yq '.processors' /tmp/config-a.yaml > /tmp/processors-a.yaml
yq '.processors' /tmp/config-b.yaml > /tmp/processors-b.yaml
diff /tmp/processors-a.yaml /tmp/processors-b.yaml
```

## Common Discrepancies

| What to Check | Broken Pattern | Correct Pattern |
|---------------|----------------|-----------------|
| Livetail endpoint | `staging.plat.sm-svc.com` | `prod.plat.sm-svc.com` |
| Telemetry bucket | `staging-telemetry-data` | `prod-telemetry-data` |
| Gateway | `staging.plat.sm-svc.com` | `ingest.sawmills.ai` |
| Prometheus | Wrong path | `/api/v1/push` |

## Reference Customers

Known working configs for comparison:

| Customer | Org ID | Use Case |
|----------|--------|----------|
| BigID | `REDACTED_ORG_ID` | Standard logs pipeline |
| Choice Hotel | `REDACTED_ORG_ID` | After fix |

## Quick Comparison Script

```bash
#!/bin/bash
# compare-configs.sh <org_a> <org_b>

S3_DIR="/Users/amirjakoby/Code/sawmills-collector-reviews/confmap/provider/s3provider"
RO="https://REDACTED_INTERNAL_URL"

# Get S3 paths (manual step - paste paths)
echo "Paste S3 path for config A:"
read S3_A
echo "Paste S3 path for config B:"
read S3_B

cd $S3_DIR
go run ./cmd/encrypt -decrypt -s3 "$S3_A" > /tmp/config-a.yaml
go run ./cmd/encrypt -decrypt -s3 "$S3_B" > /tmp/config-b.yaml

echo "=== Endpoint Differences ==="
diff <(grep -E "(endpoint|bucket)" /tmp/config-a.yaml | sort) \
     <(grep -E "(endpoint|bucket)" /tmp/config-b.yaml | sort)

echo "=== Full Diff ==="
diff /tmp/config-a.yaml /tmp/config-b.yaml
```

## Structured Comparison with yq

```bash
# Compare specific paths
yq '.exporters.otlp.endpoint' /tmp/config-a.yaml
yq '.exporters.otlp.endpoint' /tmp/config-b.yaml

# Extract and compare all endpoints
yq '.. | select(has("endpoint")) | .endpoint' /tmp/config-a.yaml
yq '.. | select(has("endpoint")) | .endpoint' /tmp/config-b.yaml
```

## Notes

- Save configs with descriptive names: `/tmp/choicehotel-config.yaml`, `/tmp/bigid-config.yaml`
- Config structure varies by pipeline type; focus on exporters/receivers for endpoint issues
- Use `grep -n` to get line numbers for targeted edits
- Staging vs prod issues are most common; always check environment in endpoints
