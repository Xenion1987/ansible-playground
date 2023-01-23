# ansible-playground

## Installing

### Install requirements

1. [vscode](https://code.visualstudio.com/Download)
1. [docker compose](https://docs.docker.com/compose/install/)
1. vscode plugins
    1. [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

### Clone this repository

```sh
git clone https://github.com/Access-InTech/ansible-playground.git
```

## Start the playground

### Prepare ansible control node

Ansible requires to connect via SSH to the clients. That's why we need to export devcontainer's SSH public key into the client's containers.

```sh
bash ./scripts/init-ansible-playground.sh
```

This script...
- ... builds the client's images
- ... creates the SSH keypair used by ansible within this project
- ... creates the `authorized_keys` file to allow `ansible-control` to ssh to all clients
- ... creates the docker network used for this project
- ... starts the client's containers

### Start the ansible control container

Open the repository in vscode. Vscode should give you a hint, that it has detected a DevContainer config and asks you to reopen it in DevContainer. Accept to initialize the ansible-control container.

#### Add some customizations to ansible-control

1. Inside the DevContainer, open the vscode terminal
1. Run `bash scripts/customize-ansible-control.sh`
1. Source `.bashrc` to update your environment via `source ~/.bashrc`

Ansible autocompletion and ansible-lint should now work for you.

## Now you're ready to play
