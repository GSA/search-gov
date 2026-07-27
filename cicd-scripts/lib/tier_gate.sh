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
# Fail-safe: if instance tags cannot be resolved after retries, this ABORTS
# the deployment on that instance (hard exit 1) rather than guessing either
# direction. An earlier version of this fail-safe treated unresolved tags as
# "not a legacy tier" (i.e. let hook logic proceed), reasoning that silently
# skipping on a healthy green host was the bigger risk. On reflection that
# is backwards: proceeding on an actual legacy Capistrano host risks two
# independent release-management systems racing over the same releases/
# current state -- creating releases, flipping symlinks, restarting
# services -- which is exactly the corruption scenario this gate exists to
# prevent (see Issue 3 in the crawler-cutover appendix). Skipping on a
# healthy green host, by contrast, is a self-contained, visible failure:
# CodeDeploy reports it and the next deploy attempt starts clean. Aborting
# outright is safer than either silent guess, and turns an ambiguous tag
# resolution into a loud, troubleshootable failure instead of a silent
# wrong answer in either direction. get_instance_tags() retries transient
# IMDS/DescribeTags hiccups before giving up, so this should only trigger
# on a persistent problem (e.g. a missing ec2:DescribeTags permission, or
# an actual AWS API outage) worth paging on, not routine flakiness.
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
  echo "[CODEDEPLOY][TIER_GATE][WARN] $*" >&2
}

_tier_gate_error() {
  echo "[CODEDEPLOY][TIER_GATE][ERROR] $*" >&2
}


# Single attempt: resolve IMDSv2 token, instance-id, then describe-tags for
# terraform_module, Fleet, and environment. Deliberately omits --region on
# the describe-tags call: AWS CLI v2 resolves the region via IMDS
# automatically when no region is set via env var/profile/flag. Returns
# empty output (not an error) on any failure -- retries live in the caller.
_get_instance_tags_once() {
  local imds_token instance_id

  imds_token=$(curl -sS --fail --max-time 2 -X PUT \
    "http://169.254.169.254/latest/api/token" \
    -H "X-aws-ec2-metadata-token-ttl-seconds: 300" 2>/dev/null || true)
  if [ -z "$imds_token" ]; then
    return
  fi

  instance_id=$(curl -sS --fail --max-time 2 \
    -H "X-aws-ec2-metadata-token: $imds_token" \
    "http://169.254.169.254/latest/meta-data/instance-id" 2>/dev/null || true)

  if [ -z "$instance_id" ]; then
    return
  fi

  aws ec2 describe-tags \
    --filters "Name=resource-id,Values=$instance_id" \
      "Name=key,Values=terraform_module,Fleet,environment" \
    --output json 2>/dev/null || true
}

# Retries _get_instance_tags_once up to TIER_GATE_TAG_RETRIES times (default
# 3), with TIER_GATE_TAG_RETRY_DELAY seconds (default 2) between attempts,
# to absorb a transient IMDS/DescribeTags hiccup rather than treating a
# single failed call as a persistent problem. Returns empty output if every
# attempt fails.
get_instance_tags() {
  local retries="${TIER_GATE_TAG_RETRIES:-3}"
  local delay="${TIER_GATE_TAG_RETRY_DELAY:-2}"
  local attempt=1
  local tags_json=""

  while [ "$attempt" -le "$retries" ]; do
    tags_json="$(_get_instance_tags_once)"
    if [ -n "$tags_json" ]; then
      echo "$tags_json"
      return
    fi
    _tier_gate_warn "Could not resolve instance tags (attempt ${attempt}/${retries})"
    if [ "$attempt" -lt "$retries" ]; then
      sleep "$delay"
    fi
    attempt=$((attempt + 1))
  done
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
#
# Hard-fails (exit 1) if terraform_module or environment cannot be resolved
# after get_instance_tags()'s retries. This is deliberate: proceeding with
# "unknown" tags means guessing whether this hook logic is safe to run, and
# neither possible guess is safe -- see the fail-safe rationale at the top
# of this file. Callers must have `set -e` (all current hook scripts do)
# for this exit to actually stop the script; this function does not rely on
# that alone and exits explicitly regardless.
resolve_deployment_tags() {
  local tags_json
  tags_json="$(get_instance_tags)"

  TERRAFORM_MODULE="$(lookup_tag "$tags_json" terraform_module)"
  FLEET="$(lookup_tag "$tags_json" Fleet)"
  ENVIRONMENT="$(lookup_tag "$tags_json" environment)"

  [ -z "$TERRAFORM_MODULE" ] && TERRAFORM_MODULE="unknown"
  [ -z "$ENVIRONMENT" ] && ENVIRONMENT="unknown"

  if [ "$TERRAFORM_MODULE" = "unknown" ] || [ "$ENVIRONMENT" = "unknown" ]; then
    _tier_gate_error "Could not resolve terraform_module/environment tags after retries (terraform_module=$TERRAFORM_MODULE, environment=$ENVIRONMENT)."
    _tier_gate_error "Aborting: cannot safely determine whether this instance is a legacy Capistrano-managed tier."
    _tier_gate_error "Check IMDSv2 connectivity and the instance profile's ec2:DescribeTags permission, then retry the deployment."
    exit 1
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
