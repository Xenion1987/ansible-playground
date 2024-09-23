# ansible-playground

[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit)](https://github.com/pre-commit/pre-commit) ![pre-commit](https://github.com/Xenion1987/ansible-playground/actions/workflows/pre-commit.yml/badge.svg) ![ansible-tests](https://github.com/Xenion1987/ansible-playground/actions/workflows/ansible-tests.yml/badge.svg)

## Installing

### Install requirements

1. [vscode](https://code.visualstudio.com/Download)
1. [docker compose](https://docs.docker.com/compose/install/)
1. vscode plugins
   1. [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

### Clone this repository

```sh
git clone https://github.com/Xenion1987/ansible-playground.git
```

## Start the playground

### Start the ansible control container

Open the repository in vscode. Vscode should give you a hint, that it has detected a DevContainer config and asks you to reopen it in DevContainer. Accept to initialize and start the environment.

By default, this playground builds and starts 2 out of 4 clients (`debian-12` and `almalinux-8`). If you want to build and start all 4 clients, you have to uncomment the `ubuntu` and `suse` client in both [docker-compose.yml](.devcontainer/docker-compose.yml) and [inventory.yml](inventory/inventory.yml) files.

## Contributing

This repository is [`pre-commit`](https://pre-commit.com/) enabled. Before commiting, all changes will be checked by pre-commit-hooks defined in [.pre-commit-config.yaml](./.pre-commit-config.yaml). [`pre-commit`](https://pre-commit.com/) will be installed inside the devcontainer.

Before doing a `git commit`, you should run `pre-commit run --all-files` to run checks and fix mentioned warnings/errors.
