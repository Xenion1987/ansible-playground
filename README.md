# ansible-playground

## Installing

### Clone this repository
```
git clone https://github.com/Access-InTech/ansible-playground.git
```

### Enter the created repository directory

```
cd ansible-playground
```

### Start the playground

```
docker compose build && docker compose up -d
```

## Setup Ansible control node

### Execute the `init.sh` script

```
docker compose exec ansible-control /bin/bash /entrypoint/scripts/init.sh
```

> This step has to be done every time when the '`ansible`' container has been newly created (e.g. after a '`docker compose down`')

### Enter the docker container `ansible`

```
docker compose exec ansible-control /bin/bash
```

Inside the container, you have to switch to `~/ansible/`

```
cd ~/ansible
```

## Now you're ready to play
