#! /bin/bash
#! /usr/bin/env bash

set -eu -o pipefail

prereqs_found=true

function check() {
    local tool=$1
    local tool_install_direction=$2
    if [[ -n $(type -p "${tool}") ]]; then
        echo "${tool} installed."
    else
        echo "WARNING: ${tool} not found, install via: ${tool_install_direction}"
        prereqs_found=false
    fi
}

if [[ $(uname -s) = aDarwin ]]; then
  check aws-vault "brew cask install aws-vault"
  check direnv "brew install direnv"
  check shellcheck "brew install shellcheck"
  check pre-commit "brew install pre-commit"
else
  check aws-vault "See https://github.com/99designs/aws-vault/releases"
  if [[ -n $(type -p "apt-get") ]]; then
    check direnv "apt-get install direnv"
    check shellcheck "apt-get install shellcheck"
  else
    check direnv "See https://direnv.net/"
    check shellcheck "See https://github.com/koalaman/shellcheck"
  fi
  if [[ -n $(type -p "pip") ]]; then
    check pre-commit "pip install pre-commit"
  else
    check pre-commit "See https://pre-commit.com/"
  fi
fi


if [[ $prereqs_found == "true" ]]; then
    echo "OK: all prereqs found"
else
    echo "ERROR: some prereqs missing, please install them"
    exit 1
fi
