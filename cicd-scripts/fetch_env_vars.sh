#!/bin/bash
set -euo pipefail

# NOTE: This script runs during CodeDeploy BeforeInstall. Do not remove
# /home/search/cicd_temp contents, because that directory contains the staged
# deployment artifact downloaded by CodeDeploy.

log() {
  echo "[CODEDEPLOY][BEFORE_INSTALL][fetch_env_vars] $*"
}

warn() {
  echo "[CODEDEPLOY][BEFORE_INSTALL][fetch_env_vars][WARN] $*"
}

normalize_pem_value_to_file() {
  local pem_value="$1"
  local output_file="$2"

  # Trim one layer of surrounding quotes when present.
  if [[ "$pem_value" == \"*\" ]]; then
    pem_value="${pem_value#\"}"
    pem_value="${pem_value%\"}"
  fi

  # Normalize carriage returns and convert escaped newlines.
  # Some SSM values are stored with literal "\\n" sequences.
  printf '%s' "$pem_value" | sed 's/\r//g' | awk '{gsub(/\\n/,"\n")}1' > "$output_file"
}

retry() {
  local attempts="$1"
  local delay_seconds="$2"
  shift 2

  local count=1
  until "$@"; do
    if [ "$count" -ge "$attempts" ]; then
      return 1
    fi
    warn "Command failed (attempt ${count}/${attempts}): $*"
    sleep "$delay_seconds"
    count=$((count + 1))
  done
}

# Move to a writable location for generating .env
cd /home/search/cicd_temp
# Leave PARAM_PATH empty to fetch all parameters in the region
PARAM_PATH=""
# Clear the .env file if it exists
> .env

# CERT_REGION: Region where sensitive parameters (certs, keys) are stored
# Dev environment fetches from staging since dev doesn't maintain sensitive params
CERT_REGION="us-east-2"

log "Starting script"
log "whoami: $(whoami)"
log "Sensitive parameters will be fetched from region: $CERT_REGION"

# Ensure expected shared directories exist before writing files.
mkdir -p /home/search/searchgov/shared/config /home/search/searchgov/shared/tmp/pids /home/search/searchgov/shared/log

# Fetch all parameter names in the region using IMDSv2 method which new method
TOKEN=""
if ! TOKEN=$(retry 3 1 curl -sS --fail --max-time 2 -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"); then
  warn "Failed to retrieve IMDSv2 token; will fall back to AWS_REGION/SEARCH_AWS_REGION"
fi

REGION=""
if [ -n "$TOKEN" ]; then
  REGION=$(curl -sS --fail --max-time 2 \
    -H "X-aws-ec2-metadata-token: $TOKEN" \
    "http://169.254.169.254/latest/dynamic/instance-identity/document" \
    | sed -n 's/.*"region"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' || true)
fi

log "Detected AWS region: $REGION"

if [ -n "$PARAM_PATH" ]; then
    PARAM_KEYS=$(aws ssm get-parameters-by-path --path "$PARAM_PATH" --recursive --query "Parameters[*].Name" --output text --region "$REGION")
else
    PARAM_KEYS=$(aws ssm describe-parameters --query "Parameters[*].Name" --output text --region "$REGION")
fi
log "Fetched parameter keys from SSM"

# Loop through each parameter key
for PARAM in $PARAM_KEYS; do
    # Exclude parameters that start with "DEPLOY_" or match "*_EC2_PEM_KEY" or match LOGIN_DOT_GOV_PEM
    if [[ $PARAM != DEPLOY_* && ! $PARAM =~ .*_EC2_PEM_KEY$ && $PARAM != "LOGIN_DOT_GOV_PEM" ]]; then
        # Fetch the parameter value from SSM
        if ! VALUE=$(aws ssm get-parameter --name "$PARAM" --with-decryption --query "Parameter.Value" --output text --region "$REGION" 2>/dev/null); then
            warn "Skipping parameter due to access/read error: $PARAM"
            continue
        fi
        
        # Rename parameters that start with "SEARCH_AWS_" to "AWS_"
        if [[ $PARAM == SEARCH_AWS_* ]]; then
            PARAM=${PARAM/SEARCH_AWS_/AWS_}
        fi

        # Write the key=value pair to the .env file
        echo "$PARAM=$VALUE" >> .env
    fi
done

log ".env file generated successfully"
cp /home/search/cicd_temp/.env /home/search/searchgov/shared/

# Fetch LOGIN_DOT_GOV_PEM - try direct write first to preserve format
log "Fetching LOGIN_DOT_GOV_PEM from SSM Parameter Store"
log "Instance region: $REGION"
log "Fetching sensitive parameters from: $CERT_REGION (staging/prod region)"

# Verify parameter exists and check KMS key
log "Checking if LOGIN_DOT_GOV_PEM exists in region $CERT_REGION..."
PARAM_DETAILS=$(aws ssm describe-parameters \
  --region "$CERT_REGION" \
  --parameter-filters "Key=Name,Values=LOGIN_DOT_GOV_PEM" \
  --query "Parameters[0]" \
  --output json 2>&1)

if [ $? -ne 0 ] || [ -z "$PARAM_DETAILS" ] || [ "$PARAM_DETAILS" == "null" ]; then
  warn "Parameter LOGIN_DOT_GOV_PEM does NOT exist in region $CERT_REGION"
  warn "Login.gov authentication will be disabled"
  exit 0
fi

# Extract KMS key ID if encrypted with customer managed key
KMS_KEY_ID=$(echo "$PARAM_DETAILS" | grep -o '"KeyId": *"[^"]*"' | cut -d'"' -f4)

if [ -n "$KMS_KEY_ID" ] && [ "$KMS_KEY_ID" != "alias/aws/ssm" ]; then
  log "Parameter is encrypted with CUSTOMER MANAGED KMS key: $KMS_KEY_ID"
  log "CRITICAL: IAM role must have kms:Decrypt permission for this key"
  
  # Try to check if we have access to the key (best effort)
  if aws kms describe-key --key-id "$KMS_KEY_ID" --region "$CERT_REGION" >/dev/null 2>&1; then
    log "KMS key is accessible (describe-key succeeded)"
  else
    warn "Cannot describe KMS key - may lack permissions"
  fi
else
  log "Parameter uses default AWS managed key (alias/aws/ssm)"
fi

log "Parameter found in region $CERT_REGION"

PEM_OUTPUT_FILE="/home/search/searchgov/shared/config/logindotgov.pem"

# Direct write to file (preserves original formatting)
log "Fetching parameter value from $CERT_REGION..."
if ! aws ssm get-parameter \
  --name "LOGIN_DOT_GOV_PEM" \
  --region "$CERT_REGION" \
  --with-decryption \
  --query "Parameter.Value" \
  --output text > "$PEM_OUTPUT_FILE" 2>&1; then
  warn "Failed to fetch LOGIN_DOT_GOV_PEM from SSM (region: $CERT_REGION)"
  warn "Login.gov authentication will be disabled"
  exit 0
fi

log "PEM fetched and written to $PEM_OUTPUT_FILE"

# CRITICAL: Show first line to diagnose if we're getting "placeholder"
FIRST_LINE=$(head -1 "$PEM_OUTPUT_FILE" | head -c 50)
log "DIAGNOSTIC - First 50 chars of fetched PEM: $FIRST_LINE"

if echo "$FIRST_LINE" | grep -qi "placeholder"; then
  warn "!!!! CRITICAL ERROR - KMS DECRYPTION FAILURE !!!!"
  warn "Fetched PEM contains 'placeholder' - this means KMS decryption FAILED"
  warn ""
  warn "Root Cause: The IAM role attached to this EC2 instance does NOT have"
  warn "permission to decrypt the LOGIN_DOT_GOV_PEM parameter using its KMS key"
  warn ""
  warn "Fetching from region: $CERT_REGION"
  if [ -n "$KMS_KEY_ID" ]; then
    warn "KMS Key ID: $KMS_KEY_ID"
  fi
  warn ""
  warn "To fix this:"
  warn "1. Identify the IAM role attached to this EC2 instance"
  warn "2. Add kms:Decrypt permission for the KMS key in region $CERT_REGION"
  warn ""
  warn "AWS CLI commands to fix:"
  warn "  # Get instance role name"
  warn "  ROLE=\$(aws iam list-instance-profiles | jq -r '.InstanceProfiles[] | select(.InstanceProfileName | contains(\"searchgov\")) | .Roles[0].RoleName')"
  warn ""
  warn "  # Add inline policy to grant KMS access"
  warn "  aws iam put-role-policy --role-name \$ROLE --policy-name SSMKMSDecrypt --policy-document '{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":[\"kms:Decrypt\",\"kms:DescribeKey\"],\"Resource\":\"arn:aws:kms:$CERT_REGION:*:key/*\"}]}'"
  warn ""
  warn "Login.gov authentication will be disabled until KMS permissions are fixed"
fi

# Diagnostic: Check file size
PEM_SIZE=$(wc -c < "$PEM_OUTPUT_FILE" | tr -d ' ')
log "PEM file size: ${PEM_SIZE} bytes"

if [ "$PEM_SIZE" -lt 100 ]; then
  warn "PEM file is suspiciously small (${PEM_SIZE} bytes) - likely corrupt"
fi

# Check for required PEM markers
if ! grep -q "^-----BEGIN" "$PEM_OUTPUT_FILE"; then
  warn "PEM file missing BEGIN marker - showing first 3 lines:"
  head -3 "$PEM_OUTPUT_FILE" | while IFS= read -r line; do
    warn "  $line"
  done
fi

if ! grep -q "^-----END" "$PEM_OUTPUT_FILE"; then
  warn "PEM file missing END marker - showing last 3 lines:"
  tail -3 "$PEM_OUTPUT_FILE" | while IFS= read -r line; do
    warn "  $line"
  done
fi

# Test direct write first (no normalization - THIS IS KEY!)
log "Validating PEM with direct write (no normalization)..."
if openssl pkey -in "$PEM_OUTPUT_FILE" -noout 2>/dev/null; then
  log "PEM validation: PASSED (direct write, no normalization needed)"
else
  warn "Direct write failed validation; PEM may have escaped sequences in SSM"
  
  # Read the content for normalization attempts
  LOGIN_DOT_GOV_PEM_VALUE=$(cat "$PEM_OUTPUT_FILE")
  
  # Fallback 1: Try normalize_pem_value_to_file (handles \\n)
  warn "Attempting normalization for escaped newline sequences..."
  normalize_pem_value_to_file "$LOGIN_DOT_GOV_PEM_VALUE" "$PEM_OUTPUT_FILE"
  
  if openssl pkey -in "$PEM_OUTPUT_FILE" -noout 2>/dev/null; then
    log "PEM validation: PASSED (after normalizing escaped sequences)"
  else
    # Fallback 2: Try printf %b
    warn "Normalization failed; attempting printf %b fallback..."
    printf '%b\n' "$LOGIN_DOT_GOV_PEM_VALUE" > "$PEM_OUTPUT_FILE"
    
    if openssl pkey -in "$PEM_OUTPUT_FILE" -noout 2>/dev/null; then
      log "PEM validation: PASSED (after printf %b fallback)"
    else
      # Capture detailed error
      PEM_ERROR=$(openssl pkey -in "$PEM_OUTPUT_FILE" -noout 2>&1 || true)
      warn "LOGIN_DOT_GOV_PEM validation FAILED after all attempts"
      warn "OpenSSL error: $PEM_ERROR"
      warn ""
      warn "CRITICAL: Your PEM validates correctly when downloaded locally,"
      warn "but fails during deployment. Possible causes:"
      warn "  - Fetching from wrong region (current: $CERT_REGION)"
      warn "  - Different PEM version in $CERT_REGION vs local"
      warn "  - AWS CLI output formatting issue"
      warn "  - Character encoding problem during transfer"
      warn "  - KMS decryption permissions"
      warn ""
      warn "To diagnose:"
      warn "  1. SSH to instance"
      warn "  2. Run: /home/search/cicd_temp/cicd-scripts/verify_pem.sh $PEM_OUTPUT_FILE"
      warn "  3. Check parameter: aws ssm describe-parameters --region $CERT_REGION | grep LOGIN_DOT_GOV_PEM"
      warn "  4. Test decrypt: aws ssm get-parameter --name LOGIN_DOT_GOV_PEM --region $CERT_REGION --with-decryption --query Parameter.Value --output text | head -1"
      warn ""
      warn "Continuing deployment - app will start but Login.gov auth will be disabled"
    fi
  fi
fi

# Additional Ruby validation check (simulates Rails loading)
if command -v ruby >/dev/null 2>&1; then
  log "Performing Ruby OpenSSL validation check..."
  RUBY_CHECK=$(ruby -e "
    require 'openssl'
    begin
      OpenSSL::PKey::RSA.new(File.read('$PEM_OUTPUT_FILE'))
      puts 'PASS'
    rescue => e
      puts \"FAIL: #{e.class} - #{e.message}\"
    end
  " 2>&1)
  
  if echo "$RUBY_CHECK" | grep -q "PASS"; then
    log "Ruby OpenSSL validation: PASSED"
  else
    warn "Ruby OpenSSL validation: FAILED"
    warn "Ruby error: $RUBY_CHECK"
    warn "This matches the error that will occur during Rails initialization"
  fi
fi

chmod 600 "$PEM_OUTPUT_FILE" || true
log "Set PEM file permissions to 600"

# Create  directories if they do not already exist
[ ! -d /home/search/searchgov/shared/tmp/pids/ ] && mkdir -p /home/search/searchgov/shared/tmp/pids/
[ ! -d /home/search/searchgov/shared/log ] && mkdir -p /home/search/searchgov/shared/log

# Create log files if they do not already exist
[ ! -f /home/search/searchgov/shared/log/puma_access.log ] && touch /home/search/searchgov/shared/log/puma_access.log
[ ! -f /home/search/searchgov/shared/log/puma_error.log ] && touch /home/search/searchgov/shared/log/puma_error.log


# Set ownership and permissions only when running as root.
if [ "$(id -u)" -eq 0 ]; then
  chown -R search:search /home/search/searchgov/
  chmod -R 755 /home/search/searchgov/
  find /home/search/searchgov/ -type d -exec chmod 2755 {} \;
else
  warn "Skipping chown/chmod root-only operations (current user: $(whoami))"
fi

umask 022

log "Completed successfully"
