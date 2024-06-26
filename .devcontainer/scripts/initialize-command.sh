#!/usr/bin/env bash

DOCKER_VOLUME_NAME="devcontainer-history"

if ! docker volume inspect "${DOCKER_VOLUME_NAME}" &>/dev/null 2>&1; then
  echo -n "INITIALIZE COMMAND :: Creating Docker volume '${DOCKER_VOLUME_NAME}'... "
  if docker volume create "${DOCKER_VOLUME_NAME}" &>/dev/null; then
    echo "done"
  fi
else
  echo "INITIALIZE COMMAND :: Docker volume '${DOCKER_VOLUME_NAME}' already exists - no need to create."
fi

### Build debian base image
echo "INITIALIZE COMMAND :: Building Debian 12 base image..."
docker compose -f .devcontainer/docker-compose.base.yml build

# if [[ ! $(docker network ls -qf name=ansible-playground) =~ [0-9a-z]{12} ]]; then
#   docker network create ansible-playground
# fi
# build_images=()
# while read -r image; do
#   if ! docker image ls "${image}" | grep -q "${image}"; then
#     build_images+=("${image}")
#   fi
# done < <(awk '/image:/ {print $NF}' .devcontainer/docker-compose.yml)
# if [[ ${#build_images[@]} -gt 0 ]]; then
#   echo "-------------- BUILDING DOCKER IMAGES --------------"
#   docker compose -f .devcontainer/docker-compose.yml build "${build_images[@]}"
# fi
# echo "---------------- DOCKER IMAGES BUILT ---------------"

# if [[ ! -f "${PWD}/ssh-keys/clients/authorized_keys" ]]; then
#   touch "${PWD}/.devcontainer/ssh-keys/clients/authorized_keys"
# fi

# docker compose -f .devcontainer/docker-compose.yml up -d

if ! find .devcontainer/ssh-keys -type f -name id_rsa | grep -q .; then
  echo "---------------- DEPLOY SSH KEYFILES ---------------"
  echo "Generate initial SSH keypair"
  docker run --rm --name tmp_ansible_init -it \
    -v "${PWD}"/.devcontainer/ssh-keys/clients/:/root/.ssh/clients \
    -v "${PWD}"/.devcontainer/ssh-keys/server/:/root/.ssh/server \
    ansible-client-debian \
    bash -c 'ssh-keygen -q -t rsa -b 4096 -f /root/.ssh/server/id_rsa -N "" -C "ansible-playground_$(date +%Y%m%d_%H%M%S)"<<<y >/dev/null'

  echo "Add 'authorized_keys' with root's public key for all clients"
  docker run --rm --name tmp_ansible_init -it \
    -v "${PWD}"/.devcontainer/ssh-keys/clients/:/root/.ssh/clients \
    -v "${PWD}"/.devcontainer/ssh-keys/server/:/root/.ssh/server \
    ansible-client-debian \
    bash -c 'cp /root/.ssh/server/id_rsa.pub /root/.ssh/clients/authorized_keys'

  echo "Fix permissions for ansible-control node"
  docker run --rm --name tmp_ansible_init -it \
    -v "${PWD}"/.devcontainer/ssh-keys/clients/:/root/.ssh/clients \
    -v "${PWD}"/.devcontainer/ssh-keys/server/:/root/.ssh/server \
    ansible-client-debian \
    bash -c 'chown -R 1000:1000 /root/.ssh/'
fi

# echo "Copy 'authorized_keys' into client's root ssh dir"
# for s in $(docker compose -f .devcontainer/docker-compose.yml ps --services --status running); do
#   echo "${s}"
#   docker compose -f .devcontainer/docker-compose.yml exec "${s}" install --directory --mode=0700 --owner=1000 --group=1000 /root/.ssh
#   docker compose -f .devcontainer/docker-compose.yml exec "${s}" cp -v /root/authorized_keys /root/.ssh/authorized_keys
# done
# echo "--------------- SSH KEYFILES DEPLOYED --------------"
