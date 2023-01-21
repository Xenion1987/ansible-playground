#! /usr/bin/env bash

# shellcheck disable=SC2046

docker compose down
docker builder prune -f
DOCKER_IMAGE_OUTPUT=$(docker image ls -q "ansible_client_*")
if [[ -n ${DOCKER_IMAGE_OUTPUT} ]]; then
    docker image rm $(docker image ls -q "ansible_client_*")
fi

sudo find ./ansible-files -not \( -name "*.example" -or -name "log" -or -name "ansible-files" \)
sudo find ./ssh-keys -not \( -name "ssh-keys" -or -name "server" -or -name "clients" -or -name ".keep" \)
echo "This script will delete all files listed above."
echo "Do you want to continue? [y/N] "
read -r -n1 yn
case ${yn} in
y | Y | j | J)
    sudo find ./ansible-files -not \( -name "*.example" -or -name "log" -or -name "ansible-files" \) -delete
    sudo find ./ssh-keys -not \( -name "ssh-keys" -or -name "server" -or -name "clients" -or -name ".keep" \) -delete
    touch ./ssh-keys/server/authorized_keys
    sudo chown 0:0 ./ssh-keys/server/authorized_keys
    echo
    echo "done"
    ;;
*)
    echo "Wrong input - Cancelled by user"
    echo
    ;;
esac
