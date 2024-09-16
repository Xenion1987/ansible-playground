#!/usr/bin/env bash


mkdir -p  "${HOME}/.ansible/log"
touch "${HOME}/.ansible/log/ansible.log"
mkdir -p  "${HOME}/.ansible/retry-files"

### Fix git permissions
if ! git status &>/dev/null; then
  git config --global --add safe.directory "${PWD}"
fi
