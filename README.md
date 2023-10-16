# ansible-playground

[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit)](https://github.com/pre-commit/pre-commit) ![CI](https://github.com/Xenion1987/ansible-playground/actions/workflows/pre-commit.yml/badge.svg)

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

### Customize `ansible-control` container

> **This step will be executed automatically by starting the DevContainer**

Starting the DevContainer will execute the script [post-create-command.sh](./.devcontainer/scripts/post-create-command.sh). Feel free to modify it to fit to your favorite tools and configs.

## Contributing

This repository is [`pre-commit`](https://pre-commit.com/) enabled. Before commiting, all changes will be checked by pre-commit-hooks defined in [.pre-commit-config.yaml](./.pre-commit-config.yaml). [`pre-commit`](https://pre-commit.com/) will be installed inside the devcontainer.

Before doing a `git commit`, you should run `pre-commit run --all-files` to run checks and fix mentioned warnings/errors.
