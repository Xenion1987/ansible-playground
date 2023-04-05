# ansible-playground

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

### Prepare ansible control node

> **This step will be executed automatically by starting the DevContainer**

Ansible requires to connect via SSH to the clients. That's why we need to export devcontainer's SSH public key into the client's containers.

```sh
bash ./.devcontainer/scripts/init-ansible-playground.sh
```

This script...
- ... builds the client's images
- ... creates the SSH keypair used by ansible within this project
- ... creates the `authorized_keys` file to allow `ansible-control` to ssh to all clients
- ... creates the docker network used for this project
- ... starts the client's containers

### Start the ansible control container

Open the repository in vscode. Vscode should give you a hint, that it has detected a DevContainer config and asks you to reopen it in DevContainer. Accept to initialize the ansible-control container.

### Customize `ansible-control` container

> **This step will be executed automatically by starting the DevContainer**

Starting the DevContainer for the first time will execute the script [customize-ansible-control.sh](./.devcontainer/scripts/customize-ansible-control.sh). Feel free to modify to fit to your favorite tools and configs.

## Now you're ready to play

### Example

![image](https://user-images.githubusercontent.com/39803750/214030375-86c6b518-a169-443d-9b91-8543a71da9df.png)
