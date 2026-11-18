#!/usr/bin/env bash
set -euo pipefail

if [[ $# != 1 ]]; then
    printf '用法：%s baseline|quota\n' "$0" >&2
    exit 2
fi

cd "$(dirname "$0")/.."
if [[ ! -x bin/textstats ]]; then
    printf '请先运行 make build\n' >&2
    exit 1
fi

case "$1" in
    baseline) quota_args=() ;;
    quota) quota_args=(--property=CPUQuota=50%) ;;
    *)
        printf '用法：%s baseline|quota\n' "$0" >&2
        exit 2
        ;;
esac

exec systemd-run --unit="lab3-o7-textstats-$1" --collect \
    --property="WorkingDirectory=$PWD" --property=AllowedCPUs=1 \
    --setenv=GOMAXPROCS=1 "${quota_args[@]}" \
    "$PWD/bin/textstats" -addr 127.0.0.1:18080
