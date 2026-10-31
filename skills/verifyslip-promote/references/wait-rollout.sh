#!/usr/bin/env bash
# wait-rollout.sh CLUSTER "svc=tag [svc=tag ...]" [TIMEOUT_SEC]
#
# Waits until, for every service, the PRIMARY ECS deployment runs a task
# definition with an image tagged exactly TAG and its rolloutState is COMPLETED.
#   exit 0  every service COMPLETED on its tag        (prints COMPLETED ...)
#   exit 1  a deployment on TAG reached FAILED, or the timeout passed
#           (prints FAILED ... / TIMEOUT ...). FAILED is checked on every
#           deployment, not only PRIMARY: after a circuit-breaker rollback the
#           old revision becomes PRIMARY again.
#   exit 2  usage error, unknown service, or an AWS call failed
#
# Read-only: calls only ecs describe-services / describe-task-definition.
# Takes the account from AWS_PROFILE / AWS_REGION (VerifySlip: vestearth,
# ap-southeast-1). Poll interval: WAIT_ROLLOUT_INTERVAL seconds (default 20).
# Runs under macOS /bin/bash 3.2.
set -euo pipefail

usage() {
  echo "usage: $0 CLUSTER \"svc=tag [svc=tag ...]\" [TIMEOUT_SEC]" >&2
  exit 2
}

[ "$#" -ge 2 ] || usage
cluster=$1
pairs=$2
timeout=${3:-1500}
interval=${WAIT_ROLLOUT_INTERVAL:-20}
case $timeout in '' | *[!0-9]*) usage ;; esac
case $interval in '' | *[!0-9]*) usage ;; esac
[ -n "$pairs" ] || usage
for p in $pairs; do
  case $p in ?*=?*) ;; *) usage ;; esac
done
deadline=$(($(date +%s) + timeout))

# has_tag TASK_DEF TAG: 0 when any container image in TASK_DEF ends in :TAG,
# 1 when none does, 2 when the AWS call fails.
has_tag() {
  local images image
  images=$(aws ecs describe-task-definition --task-definition "$1" \
    --query 'taskDefinition.containerDefinitions[].image' --output text) || return 2
  for image in $images; do
    case $image in *":$2") return 0 ;; esac
  done
  return 1
}

while :; do
  all_done=1
  summary=""
  for p in $pairs; do
    svc=${p%%=*}
    tag=${p#*=}
    if ! deployments=$(aws ecs describe-services --cluster "$cluster" --services "$svc" \
      --query 'services[0].deployments[].[status,rolloutState,taskDefinition,runningCount,desiredCount]' \
      --output text); then
      echo "ERROR describe-services failed for $svc on $cluster" >&2
      exit 2
    fi
    if [ -z "$deployments" ] || [ "$deployments" = "None" ]; then
      echo "ERROR service $svc not found on $cluster" >&2
      exit 2
    fi

    primary="none"
    svc_done=0
    while IFS=$'\t' read -r status rollout td running desired; do
      [ -n "${td:-}" ] || continue
      rc=0
      has_tag "$td" "$tag" || rc=$?
      if [ "$rc" -eq 2 ]; then
        echo "ERROR describe-task-definition failed for $td" >&2
        exit 2
      fi
      if [ "$rc" -eq 0 ] && [ "$rollout" = "FAILED" ]; then
        echo "FAILED $svc ${td##*/} $tag status=$status running/desired=$running/$desired"
        exit 1
      fi
      if [ "$status" = "PRIMARY" ]; then
        primary="${td##*/}:$rollout:$running/$desired"
        if [ "$rc" -eq 0 ] && [ "$rollout" = "COMPLETED" ]; then
          svc_done=1
          primary="${td##*/}:$tag:$rollout:$running/$desired"
        fi
      fi
    done <<EOF
$deployments
EOF

    [ "$svc_done" -eq 1 ] || all_done=0
    summary="$summary $svc=$primary"
  done

  if [ "$all_done" -eq 1 ]; then
    echo "COMPLETED$summary"
    exit 0
  fi
  if [ "$(date +%s)" -ge "$deadline" ]; then
    echo "TIMEOUT$summary"
    exit 1
  fi
  sleep "$interval"
done
