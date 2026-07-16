#!/bin/bash
# Shared helper sourced by CodeDeploy lifecycle hook scripts.
#
# Determines whether the current instance is a legacy, Capistrano-managed
# tier that must NOT run the CodeDeploy-hook-driven release/service
# management introduced by the Ubuntu 24.04 upgrade (PR #1990 and everything
# built on top of it since, including SRCH-6631's db:migrate gate).
#
# Background: `production`'s "app" and "cron" terraform_module tiers have no
# Fleet tag (they have not been cut over to their "-green" counterparts) and
# are still deployed today via Capistrano's `cap $SEARCH_ENV deploy`, run as
# a separate CodeBuild stage (see buildspec_searchgov.yml). CodeDeploy's full
# lifecycle already runs end-to-end against these hosts today (confirmed
# live via `aws deploy get-deployment-instance`, 2026-07-15), but only
# BeforeInstall's fetch_env_vars.sh and AfterInstall's asset-copy step are
# currently meaningful there. If the newer release-management hooks
# (creating releases/<timestamp>, promoting `current`, running
# `bundle install`, running db:migrate) also ran unconditionally on these
# hosts, they would race with Capistrano's independent deploy on the same
# release/current state -- e.g. migrations running twice, or two competing
# release trees fighting over the `current` symlink.
#
# This helper isolates exactly that legacy-tier case so all three affected
# hook scripts (after_install.sh, application_start.sh, validate_service.sh)
# use one consistent, explicit definition rather than relying on incidental
# no-op behavior (e.g. unit-name mismatches) to stay safe on those hosts.
#
# Fail-safe: if instance tags cannot be resolved for any reason, this treats
# the host as NOT a legacy tier (i.e. hook logic proceeds). Silently skipping
# hook logic on a host we can't identify is a bigger risk than proceeding,
# since dev/staging/other green hosts must not be accidentally skipped just
# because of a transient IMDS/AWS CLI hiccup.
#
# NOTE: when production's "app"/"cron" tiers are cut over to their green
# counterparts, the case statement in is_legacy_capistrano_tier() below must
# be updated (or retired) to match the new state, the same way SRCH-6631's
# db:migrate gate documents a required post-cutover follow-up in
# app_fixes_tracking.md, section 10.

_tier_gate_log() {
  echo "[CODEDEPLOY][TIER_GATE] $*"
}

_tier_gate_warn() {
  echo "[CODEDEPLOY][TIER_GATE][WARN] $*"
}

# Single describe-tags call for terraform_module, Fleet, and environment.
# Deliberately omits --region: AWS CLI v2 resolves the region via IMDS
# automatically when no region is set via env var/profile/flag.
get_instance_tags() {
  local imds_token instance_id

  imds_token=$(curl -sS --fail --max-time 2 -X PUT \
    "http://169.254.169.254/latest/api/token" \
    -H "X-aws-ec2-metadata-token-ttl-seconds: 300" 2>/dev/null || true)
  if [ -z "$imds_token" ]; then
    _tier_gate_warn "Could not retrieve IMDSv2 token; instance tags unknown"
    return
  fi

  instance_id=$(curl -sS --fail --max-time 2 \
    -H "X-aws-ec2-metadata-token: $imds_token" \
    "http://169.254.169.254/latest/meta-data/instance-id" 2>/dev/null || true)

  if [ -z "$instance_id" ]; then
    _tier_gate_warn "Could not determine instance-id; instance tags unknown"
    return
  fi

  aws ec2 describe-tags \
    --filters "Name=resource-id,Values=$instance_id" \
      "Name=key,Values=terraform_module,Fleet,environment" \
    --output json 2>/dev/null || true
}

lookup_tag() {
  local tags_json="$1"
  local key="$2"
  if [ -z "$tags_json" ]; then
    echo ""
    return
  fi
  echo "$tags_json" | jq -r --arg key "$key" \
    '.Tags[] | select(.Key == $key) | .Value' 2>/dev/null || true
}

# Resolves and exports TERRAFORM_MODULE, FLEET, ENVIRONMENT for the current
# instance. Callers should invoke this once near the top of their script and
# reuse the resulting variables rather than re-fetching tags later (e.g. for
# a db:migrate gate) -- one describe-tags call per deployment is sufficient.
resolve_deployment_tags() {
  local tags_json
  tags_json="$(get_instance_tags)"

  TERRAFORM_MODULE="$(lookup_tag "$tags_json" terraform_module)"
  FLEET="$(lookup_tag "$tags_json" Fleet)"
  ENVIRONMENT="$(lookup_tag "$tags_json" environment)"

  [ -z "$TERRAFORM_MODULE" ] && TERRAFORM_MODULE="unknown"
  [ -z "$ENVIRONMENT" ] && ENVIRONMENT="unknown"

  if [ "$TERRAFORM_MODULE" = "unknown" ]; then
    _tier_gate_warn "terraform_module tag not found on this instance; defaulting to unknown"
  fi
  if [ "$ENVIRONMENT" = "unknown" ]; then
    _tier_gate_warn "environment tag not found on this instance; defaulting to unknown"
  fi

  export TERRAFORM_MODULE FLEET ENVIRONMENT
}

# Returns success (0) if this instance is a legacy, Capistrano-managed tier
# that the new release-management/service hooks must not act on.
# Requires resolve_deployment_tags to have been called first.
is_legacy_capistrano_tier() {
  case "${ENVIRONMENT:-unknown}:${TERRAFORM_MODULE:-unknown}" in
    production:app|production:cron)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}
