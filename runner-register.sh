#!/bin/sh
set -eu

if [ -s /etc/gitlab-runner/config.toml ]; then
  echo "[register] config.toml exists -> skip"
  exit 0
fi

: "${RUNNER_TOKEN:?RUNNER_TOKEN missing}"
: "${CI_SERVER_URL:=http://192.168.1.12:8080}"
: "${RUNNER_NAME:=runner-01}"
: "${DOCKER_IMAGE:=alpine:3.20}"
: "${DOCKER_NETWORK_MODE:=lab_default}"

# Only used for legacy (non-glrt) tokens
: "${RUNNER_TAG_LIST:=docker,linux,lab}"
: "${RUN_UNTAGGED:=true}"

echo "[register] registering"

COMMON_ARGS="
  --non-interactive
  --url ${CI_SERVER_URL}
  --token ${RUNNER_TOKEN}
  --name ${RUNNER_NAME}
  --executor docker
  --docker-image ${DOCKER_IMAGE}
  --docker-network-mode ${DOCKER_NETWORK_MODE}
  --docker-volumes /var/run/docker.sock:/var/run/docker.sock
  --docker-volumes /cache
  --docker-pull-policy if-not-present
"

if echo "${RUNNER_TOKEN}" | grep -q '^glrt-'; then
  echo "[register] glrt token -> server controls tags/run-untagged (do not pass reserved flags)"

  # IMPORTANT: gitlab-runner register also reads these from ENV -> must unset for glrt workflow
  unset RUNNER_TAG_LIST RUN_UNTAGGED \
        REGISTER_LOCKED REGISTER_ACCESS_LEVEL REGISTER_MAXIMUM_TIMEOUT \
        REGISTER_PAUSED REGISTER_MAINTENANCE_NOTE || true

  gitlab-runner register ${COMMON_ARGS}
else
  echo "[register] legacy token -> allow tags/run-untagged"
  gitlab-runner register ${COMMON_ARGS} \
    --tag-list "${RUNNER_TAG_LIST}" \
    --run-untagged="${RUN_UNTAGGED}"
fi

echo "[register] done"
test -s /etc/gitlab-runner/config.toml
