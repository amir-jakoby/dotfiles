---
name: s3-config-editor
description: Edit encrypted S3 collector configs. Use when "edit collector config", "fix s3 config", "update encrypted config", or need to modify customer collector configuration.
---

# S3 Config Editor

Download, decrypt, edit, re-encrypt, and upload S3 collector configurations.

## Prerequisites

- AWS authentication for the target environment
- Go runtime for encrypt tool
- S3 provider directory: `${CODE_ROOT:-$HOME/Code}/sawmills-collector-reviews/confmap/provider/s3provider`

## Configuration

```bash
export S3_PROVIDER_DIR="${CODE_ROOT:-$HOME/Code}/sawmills-collector-reviews/confmap/provider/s3provider"
```

## Workflow

### Step 1: Authenticate to AWS

```bash
# Example: use your preferred AWS auth flow for the target account
assume <target-account-profile>
```

Verify:

```bash
aws sts get-caller-identity
```

### Step 2: Get S3 Path

From deployment description or use **customer-config** skill.

S3 path format:

```
s3://<config-bucket>/<org_id>-<hash>/collector-config/collectorId=<id>/<version>@<encryption_key>
```

### Step 3: Decrypt Config

```bash
cd $S3_PROVIDER_DIR
go run ./cmd/encrypt -decrypt -s3 "<full_s3_path_with_key>" > /tmp/customer-config.yaml
```

### Step 4: Edit Config

Open in editor and make changes:

```bash
$EDITOR /tmp/customer-config.yaml
```

Common fixes:

- Replace `staging` with `prod` in endpoints
- Fix bucket names
- Update API keys

### Step 5: Validate YAML

```bash
yq eval '.' /tmp/customer-config.yaml > /dev/null && echo "Valid YAML"
```

### Step 6: Upload Fixed Config

```bash
cd $S3_PROVIDER_DIR
go run ./cmd/encrypt -upload -input /tmp/customer-config.yaml -s3 "<full_s3_path_with_key>"
```

### Step 7: Trigger Reload

Either:

- Redeploy from UI (creates new config version)
- Restart collector pods:

```bash
remote-operator -a <ro_address> -o <org_id> manage run \
  -d <deployment> --instance-name <instance> \
  -- kubectl rollout restart deployment/sawmills-collector -n sawmills
```

## Commands Reference

| Action           | Command                                                   |
| ---------------- | --------------------------------------------------------- |
| Decrypt          | `go run ./cmd/encrypt -decrypt -s3 "<path>"`              |
| Encrypt + Upload | `go run ./cmd/encrypt -upload -input <file> -s3 "<path>"` |
| View only        | `go run ./cmd/encrypt -s3 "<path>"` (prints to stdout)    |

## S3 Path Structure

```
s3://<config-bucket>/
  └── <org_id>-<config_hash>/
      └── collector-config/
          └── collectorId=<collector_id>/
              └── <version>@<encryption_key>
```

- `env`: prod, staging
- `config_hash`: SHA256 of config (changes on UI deploy)
- `version`: Timestamp
- `encryption_key`: Base64 key for decryption

## Safety

- Always backup before editing: `cp /tmp/customer-config.yaml /tmp/customer-config.yaml.bak`
- Validate YAML before upload
- Test changes in staging first when possible
- UI deploy creates NEW config folder; manual S3 edit only affects current version
- If UI redeploy happens after manual fix, check if new config has same issue

## Common Edits

### Fix Staging → Prod Endpoints

```bash
sed -i '' 's/staging/prod/g' /tmp/customer-config.yaml
sed -i '' 's/<staging_bucket>/<prod_bucket>/g' /tmp/customer-config.yaml
```

### Verify Endpoints

```bash
grep -E "(endpoint|bucket|livetail)" /tmp/customer-config.yaml
```

## Notes

- Encryption key is part of S3 path after `@`
- Config changes require pod restart to take effect
- UI deploy creates new folder hash; old manual fixes won't persist
