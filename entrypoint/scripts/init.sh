#! /usr/bin/env bash

apt update &&
    export DEBIAN_FRONTEND=noninteractive &&
    apt install -y --no-install-recommends \
        dialog \
        apt-utils \
        sudo \
        vim \
        curl \
        wget \
        iputils-ping \
        procps \
        psutils \
        ansible

[[ ! -f /root/.ssh/id_rsa ]] && ssh-keygen -t rsa -b 4096 -f /root/.ssh/id_rsa -N '' -C "ansible-playground_$(date +%F)"
if [[ -f /root/.ssh/id_rsa.pub ]] && [[ ! -f /root/.ssh/authorized_keys ]]; then
    tee /root/.ssh/authorized_keys </root/.ssh/id_rsa.pub
fi
