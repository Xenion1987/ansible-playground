#! /usr/bin/env bash

if [[ ! $(docker network ls -qf name=ansible-playground) =~ [0-9a-z]{12} ]]; then
  docker network create ansible-playground
fi
build_images=()
while read -r image; do
  if ! docker image ls "${image}" | grep -q "${image}"; then
    build_images+=(${image})
  fi
done < <(awk '/image:/ {print $NF}' docker-compose.yml)
if [[ ${#build_images[@]} -gt 0 ]]; then
  echo "-------------- BUILDING DOCKER IMAGES --------------"
  docker compose build "${build_images[@]}"
fi
echo "---------------- DOCKER IMAGES BUILT ---------------"

docker compose up -d

if ! find ssh-keys -type f -name id_rsa | grep -q .; then
  echo "---------------- DEPLOY SSH KEYFILES ---------------"
  echo "Generate initial SSH keypair"
  docker run --rm --name tmp_ansible_init -it \
    -v ${PWD}/ssh-keys/clients/:/root/.ssh/clients \
    -v ${PWD}/ssh-keys/server/:/root/.ssh/server \
    ansible-client-debian \
    bash -c 'ssh-keygen -q -t rsa -b 4096 -f /root/.ssh/server/id_rsa -N "" -C "ansible-playground_$(date +%Y%m%d_%H%M%S)"<<<y >/dev/null'

  echo "Add 'authorized_keys' with root's public key for all clients"
  docker run --rm --name tmp_ansible_init -it \
    -v ${PWD}/ssh-keys/clients/:/root/.ssh/clients \
    -v ${PWD}/ssh-keys/server/:/root/.ssh/server \
    ansible-client-debian \
    bash -c 'cp /root/.ssh/server/id_rsa.pub /root/.ssh/clients/authorized_keys'

  echo "Fix permissions for ansible-control node"
  docker run --rm --name tmp_ansible_init -it \
    -v ${PWD}/ssh-keys/clients/:/root/.ssh/clients \
    -v ${PWD}/ssh-keys/server/:/root/.ssh/server \
    ansible-client-debian \
    bash -c 'chown -R 1000:1000 /root/.ssh/'

  echo "Copy 'authorized_keys' into client's root ssh dir"
  for s in $(docker compose ps --services --status running); do
    echo "${s}"
    docker compose exec "${s}" mkdir -p /root/.ssh
    docker compose exec "${s}" chmod 700 /root/.ssh
    docker compose exec "${s}" cp /root/authorized_keys /root/.ssh/authorized_keys
  done
fi
echo "--------------- SSH KEYFILES DEPLOYED --------------"
