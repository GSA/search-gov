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

log "Starting script"
log "whoami: $(whoami)"

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

if [ -z "$REGION" ]; then
  REGION="${AWS_REGION:-${SEARCH_AWS_REGION:-us-east-2}}"
  warn "Using fallback region: $REGION"
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

# Fetch LOGIN_DOT_GOV_PEM and normalize escaped newlines so OpenSSL can parse it.
log "Fetching LOGIN_DOT_GOV_PEM from SSM Parameter Store"
if ! LOGIN_DOT_GOV_PEM_VALUE=$(aws ssm get-parameter \
  --name "LOGIN_DOT_GOV_PEM" \
  --region "$REGION" \
  --with-decryption \
  --query "Parameter.Value" \
  --output text 2>&1); then
  warn "Failed to fetch LOGIN_DOT_GOV_PEM from SSM: $LOGIN_DOT_GOV_PEM_VALUE"
  warn "Login.gov authentication will be disabled"
  exit 0
fi

PEM_OUTPUT_FILE="/home/search/searchgov/shared/config/logindotgov.pem"
log "Normalizing PEM content and writing to $PEM_OUTPUT_FILE"
normalize_pem_value_to_file "$LOGIN_DOT_GOV_PEM_VALUE" "$PEM_OUTPUT_FILE"

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

# Primary validation attempt
if openssl pkey -in "$PEM_OUTPUT_FILE" -noout 2>/dev/null; then
  log "PEM validation: PASSED (primary normalization)"
else
  warn "Initial PEM normalization failed validation; attempting fallback decoding"
  
  # Fallback: try printf %b for different escape sequence handling
  printf '%b\n' "$LOGIN_DOT_GOV_PEM_VALUE" > "$PEM_OUTPUT_FILE"
  
  if openssl pkey -in "$PEM_OUTPUT_FILE" -noout 2>/dev/null; then
    log "PEM validation: PASSED (fallback normalization)"
  else
    # Capture detailed error
    PEM_ERROR=$(openssl pkey -in "$PEM_OUTPUT_FILE" -noout 2>&1 || true)
    warn "LOGIN_DOT_GOV_PEM validation FAILED after all normalization attempts"
    warn "OpenSSL error: $PEM_ERROR"
    warn "This will prevent Login.gov authentication from working"
    warn ""
    warn "To diagnose this issue:"
    warn "  1. SSH to the instance"
    warn "  2. Run: /home/search/cicd_temp/cicd-scripts/verify_pem.sh $PEM_OUTPUT_FILE"
    warn "  3. Check SSM Parameter Store value for corruption"
    warn ""
    warn "Common causes:"
    warn "  - Incorrect line endings in SSM (must be Unix LF, not Windows CRLF)"
    warn "  - Extra quotes or escape sequences in SSM value"
    warn "  - Missing or corrupted BEGIN/END markers"
    warn "  - Non-ASCII characters in the PEM content"
    warn ""
    warn "Continuing deployment - app will start but Login.gov auth will be disabled"
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
