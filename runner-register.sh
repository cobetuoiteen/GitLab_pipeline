#!/bin/sh
set -eu

if [ -s /etc/gitlab-runner/config.toml ]; then
  echo "[register] config.toml exists -> skip"
  exit 0
fi

: "${RUNNER_TOKEN:?RUNNER_TOKEN missing (glrt-...)}"
: "${CI_SERVER_URL:=http://gitlab}"
: "${RUNNER_NAME:=runner-laptop-01}"
: "${DOCKER_IMAGE:=alpine:3.20}"

: "${RUNNER_TAG_LIST:=docker,linux,lab}"
: "${RUN_UNTAGGED:=true}"
: "${DOCKER_NETWORK_MODE:=lab_default}"

echo "[register] registering (glrt token workflow)"
gitlab-runner register --non-interactive \
  --url "${CI_SERVER_URL}" \
  --token "${RUNNER_TOKEN}" \
  --name "${RUNNER_NAME}" \
  --executor "docker" \
  --tag-list "${RUNNER_TAG_LIST}" \
  --run-untagged="${RUN_UNTAGGED}" \
  --docker-image "${DOCKER_IMAGE}" \
  --docker-network-mode "${DOCKER_NETWORK_MODE}" \
  --docker-volumes "/var/run/docker.sock:/var/run/docker.sock" \
  --docker-volumes "/cache" \
  --docker-pull-policy "if-not-present"

echo "[register] done"
test -s /etc/gitlab-runner/config.toml
