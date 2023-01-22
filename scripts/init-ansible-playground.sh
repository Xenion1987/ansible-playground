#! /usr/bin/env bash

if docker compose build; then
    echo "Generate initial SSH keypair"
    docker run -it --rm \
        -v ${PWD}/ssh-keys/clients/:/root/.ssh/clients \
        -v ${PWD}/ssh-keys/server/:/root/.ssh/server \
        ansible_client_ubuntu \
            ssh-keygen -t rsa -b 4096 -f /root/.ssh/server/id_rsa -N '' -C "ansible-playground_$(date +%Y%m%d_%H%M%S)"
    
    echo "Add 'authorized_keys' with root's puböic key for all clients"
    docker run -it --rm \
        -v ${PWD}/ssh-keys/clients/:/root/.ssh/clients \
        -v ${PWD}/ssh-keys/server/:/root/.ssh/server \
        ansible_client_ubuntu \
            cp /root/.ssh/server/id_rsa.pub /root/.ssh/clients/authorized_keys
    
    echo "Fix permissions for ansible-control node"
    docker run -it --rm \
        -v ${PWD}/ssh-keys/clients/:/root/.ssh/clients \
        -v ${PWD}/ssh-keys/server/:/root/.ssh/server \
        ansible_client_ubuntu \
            chown -R 1000:1000 /root/.ssh/

    echo "Creating docker network"    
    docker network create ansible-playground

    echo "Copy 'authorized_keys' into client's root ssh dir"
    if docker compose up -d; then
        for s in $(docker compose ps --services --status running); do
            echo "$s"
            docker compose exec ${s} mkdir -p /root/.ssh
            docker compose exec ${s} cp /root/authorized_keys /root/.ssh/authorized_keys
        done
    fi
fi

