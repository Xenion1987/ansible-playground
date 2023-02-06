#! /usr/bin/env bash

# shellcheck disable=SC2046

docker compose down
docker container rm -f $(docker container ls -qa -f name="ansible-control")
docker image rm $(docker image ls -q "ansible-client-*")
docker image rm $(docker image ls -q "vcs-ansible-playground*")
docker builder prune -f

find ./ssh-keys -not \( -name "ssh-keys" -or -name "server" -or -name "clients" -or -name ".keep" \)
echo "This script will delete all files listed above."
echo "Do you want to continue? [y/N] "
read -r -n1 yn
case ${yn} in
y | Y | j | J)
  find ./ssh-keys -not \( -name "ssh-keys" -or -name "server" -or -name "clients" -or -name ".keep" \) -delete
  echo
  echo "done"
  ;;
*)
  echo "Wrong input - Cancelled by user"
  echo
  ;;
esac
