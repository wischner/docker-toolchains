#!/bin/sh

set -eu

die() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

need_command() {
  command -v "$1" >/dev/null 2>&1 || die "Required command not found: $1"
}

repository="${1:-}"
readme_path="${2:-}"

[ -n "$repository" ] || die "Usage: $0 NAMESPACE/REPOSITORY README"
[ -n "$readme_path" ] || die "Usage: $0 NAMESPACE/REPOSITORY README"
[ -f "$readme_path" ] || die "README not found: $readme_path"

case "$repository" in
  */*) ;;
  *) die "Repository must use NAMESPACE/REPOSITORY format: $repository" ;;
esac

case "$repository" in
  *[!a-z0-9._/-]*) die "Repository contains unsupported characters: $repository" ;;
esac

description_size="$(wc -c < "$readme_path" | tr -d '[:space:]')"
[ "$description_size" -le 25000 ] ||
  die "Docker Hub overview exceeds 25,000 bytes: $readme_path"

if [ "${DOCKERHUB_DESCRIPTION_DRY_RUN:-0}" = "1" ]; then
  printf 'Would update Docker Hub overview for %s from %s (%s bytes)\n' \
    "$repository" "$readme_path" "$description_size"
  exit 0
fi

need_command curl
need_command jq

dockerhub_username="${DOCKERHUB_USERNAME:-}"
dockerhub_secret="${DOCKERHUB_TOKEN:-${DOCKERHUB_PASSWORD:-}}"

if [ -n "$dockerhub_username" ] || [ -n "$dockerhub_secret" ]; then
  [ -n "$dockerhub_username" ] ||
    die "DOCKERHUB_USERNAME is required when a Docker Hub token or password is set"
  [ -n "$dockerhub_secret" ] ||
    die "Set DOCKERHUB_TOKEN or DOCKERHUB_PASSWORD with DOCKERHUB_USERNAME"
else
  docker_config_dir="${DOCKER_CONFIG:-${HOME:?HOME is not set}/.docker}"
  docker_config_file="${docker_config_dir}/config.json"
  [ -r "$docker_config_file" ] ||
    die "Docker credentials not found; run docker login or set DOCKERHUB_USERNAME and DOCKERHUB_TOKEN"

  registry_key=""
  for candidate in \
    'https://index.docker.io/v1/' \
    'index.docker.io' \
    'docker.io' \
    'registry-1.docker.io'; do
    if jq -e --arg key "$candidate" \
      '(.auths[$key] != null) or (.credHelpers[$key] != null)' \
      "$docker_config_file" >/dev/null 2>&1; then
      registry_key="$candidate"
      break
    fi
  done
  [ -n "$registry_key" ] || registry_key='https://index.docker.io/v1/'

  credential_helper="$(jq -r --arg key "$registry_key" \
    '.credHelpers[$key] // .credsStore // empty' "$docker_config_file")"

  if [ -n "$credential_helper" ]; then
    helper_command="docker-credential-${credential_helper}"
    need_command "$helper_command"
    credential_json="$(printf '%s\n' "$registry_key" | "$helper_command" get)" ||
      die "Could not read Docker Hub credentials from $helper_command"
    dockerhub_username="$(printf '%s' "$credential_json" | jq -er '.Username')" ||
      die "Docker credential helper did not return a username"
    dockerhub_secret="$(printf '%s' "$credential_json" | jq -er '.Secret')" ||
      die "Docker credential helper did not return a secret"
    unset credential_json
  else
    encoded_credential="$(jq -er --arg key "$registry_key" \
      '.auths[$key].auth | select(type == "string" and length > 0)' \
      "$docker_config_file")" ||
      die "Docker Hub login not found; run docker login or set Docker Hub environment credentials"
    decoded_credential="$(printf '%s' "$encoded_credential" | jq -Rr '@base64d')"
    dockerhub_username="${decoded_credential%%:*}"
    dockerhub_secret="${decoded_credential#*:}"
    unset encoded_credential decoded_credential
  fi
fi

access_token="$(
  jq -n \
    --arg identifier "$dockerhub_username" \
    --arg secret "$dockerhub_secret" \
    '{identifier: $identifier, secret: $secret}' |
    curl -fsS 'https://hub.docker.com/v2/auth/token' \
      -H 'Content-Type: application/json' \
      --data-binary @- |
    jq -er '.access_token | select(type == "string" and length > 0)'
)" || die "Docker Hub authentication failed"
unset dockerhub_secret

http_status="$(
  jq -Rs '{full_description: .}' "$readme_path" |
    curl -sS -o /dev/null -w '%{http_code}' \
      -X PATCH "https://hub.docker.com/v2/repositories/${repository}" \
      -H 'Content-Type: application/json' \
      -H "Authorization: Bearer ${access_token}" \
      --data-binary @-
)" || die "Docker Hub overview request failed for $repository"
unset access_token

case "$http_status" in
  2??) ;;
  *) die "Docker Hub rejected the overview for $repository (HTTP $http_status)" ;;
esac

printf 'Updated Docker Hub overview for %s from %s\n' "$repository" "$readme_path"
