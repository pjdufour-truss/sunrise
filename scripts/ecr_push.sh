#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
readonly DIR

set -eu -o pipefail

usage() {
  echo "Usage: ecr_push.sh IMAGE REPO TAG"
  echo "Requires environment variables: AWS_ACCESS_KEY_ID"
  exit 1
}

[[ $# -ne 3 ]] && usage

image=$1
readonly image

repo=$2
readonly repo

tag=$3
readonly tag

[[ -z "${AWS_ACCESS_KEY_ID:-}" ]] && usage

aws_account_id=$(aws sts get-caller-identity --output "text" --query "Account")
readonly aws_account_id

if [[ "${aws_account_id}" != "" ]]; then
  # shellcheck disable=SC2086
  bash -c "$(aws ecr get-login --no-include-email --region ${AWS_DEFAULT_REGION})"
  docker tag "${image}" "${aws_account_id}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${repo}:${tag}"
  docker push "${aws_account_id}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${repo}:${tag}"
fi
