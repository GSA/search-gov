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
PARAM_PATH=""
> .env

# CERT_REGION: Region where sensitive parameters (certs, keys) are stored
CERT_REGION="us-east-2"

log "Starting script"
log "Sensitive parameters will be fetched from region: $CERT_REGION"

# Ensure expected shared directories exist before writing files.
mkdir -p /home/search/searchgov/shared/config /home/search/searchgov/shared/tmp/pids /home/search/searchgov/shared/log

# Fetch all parameter names in the region using IMDSv2 method
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

log "Instance region: $REGION"

# Fetch parameters from instance region
if [ -n "$PARAM_PATH" ]; then
    PARAM_KEYS=$(aws ssm get-parameters-by-path --path "$PARAM_PATH" --recursive --query "Parameters[*].Name" --output text --region "$REGION")
else
    PARAM_KEYS=$(aws ssm describe-parameters --query "Parameters[*].Name" --output text --region "$REGION")
fi

# Loop through each parameter key
for PARAM in $PARAM_KEYS; do
    if [[ $PARAM != DEPLOY_* && ! $PARAM =~ .*_EC2_PEM_KEY$ && $PARAM != "LOGIN_DOT_GOV_PEM" ]]; then
        if ! VALUE=$(aws ssm get-parameter --name "$PARAM" --with-decryption --query "Parameter.Value" --output text --region "$REGION" 2>/dev/null); then
            warn "Skipping parameter: $PARAM"
            continue
        fi
        
        if [[ $PARAM == SEARCH_AWS_* ]]; then
            PARAM=${PARAM/SEARCH_AWS_/AWS_}
        fi

        echo "$PARAM=$VALUE" >> .env
    fi
done

log ".env file generated successfully"
cp /home/search/cicd_temp/.env /home/search/searchgov/shared/

# Fetch LOGIN_DOT_GOV_PEM from cert region
log "Fetching LOGIN_DOT_GOV_PEM from region $CERT_REGION"
PEM_OUTPUT_FILE="/home/search/searchgov/shared/config/logindotgov.pem"

if ! aws ssm get-parameter \
  --name "LOGIN_DOT_GOV_PEM" \
  --region "$CERT_REGION" \
  --with-decryption \
  --query "Parameter.Value" \
  --output text > "$PEM_OUTPUT_FILE" 2>&1; then
  warn "Failed to fetch LOGIN_DOT_GOV_PEM from region $CERT_REGION"
  warn "Login.gov authentication will be disabled"
  exit 0
fi

# Quick PEM validation
if openssl pkey -in "$PEM_OUTPUT_FILE" -noout 2>/dev/null; then
  log "PEM validation: PASSED"
else
  warn "PEM validation failed - Login.gov auth will be disabled"
fi

chmod 600 "$PEM_OUTPUT_FILE"

# Create directories and log files if needed
mkdir -p /home/search/searchgov/shared/tmp/pids /home/search/searchgov/shared/log
touch /home/search/searchgov/shared/log/puma_access.log /home/search/searchgov/shared/log/puma_error.log

# Set ownership and permissions only when running as root
if [ "$(id -u)" -eq 0 ]; then
  chown -R search:search /home/search/searchgov/
  chmod -R 755 /home/search/searchgov/
  find /home/search/searchgov/ -type d -exec chmod 2755 {} \;
fi

umask 022
log "Completed successfully"
