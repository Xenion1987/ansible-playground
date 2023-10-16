#!/usr/bin/env bash

#########################################################
# Call this script from the repository's root dir.
#########################################################

# shellcheck disable=SC2046

docker compose -f .devcontainer/docker-compose.yml down

o=$(docker container ls -qa -f name="ansible-playground-control")
if [[ -n $o ]]; then
  docker container rm -f "${o}"
fi
o=$(docker image ls -q "ansible-client-*")
if [[ -n $o ]]; then
  docker image rm $(docker image ls -q "ansible-client-*")
fi
o=$(docker image ls -q "vcs-ansible-playground*")
if [[ -n $o ]]; then
  docker image rm $(docker image ls -q "vcs-ansible-playground*")
fi
docker builder prune -f

if [[ -d "./.devcontainer/.venv-ansible" ]]; then
  rm -rf "./.devcontainer/.venv-ansible"
fi

o=$(find ./.devcontainer/ssh-keys -not \( -name "ssh-keys" -or -name "server" -or -name "clients" -or -name ".keep" \))
if [[ -n $o ]]; then
  echo "${o}"
  echo "This script will delete all files listed above."
  echo "Do you want to continue? [y/N] "
  read -r -n1 yn
  case ${yn} in
  y | Y | j | J)
    find ./.devcontainer/ssh-keys -not \( -name "ssh-keys" -or -name "server" -or -name "clients" -or -name ".keep" \) -delete
    echo
    echo "done"
    ;;
  *)
    echo "Wrong input - Cancelled by user"
    echo
    ;;
  esac
fi
