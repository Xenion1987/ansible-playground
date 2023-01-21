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
docker compose exec ansible /bin/bash /entrypoint/scripts/init.sh
```

> This step has to be done every time when the '`ansible`' container has been newly created (e.g. after a '`docker compose down`')

### Enter the docker container `ansible`

```
docker compose exec ansible /bin/bash
```

## Test if clients answer to ansible commands

### Enter the docker container `ansible`

```
docker compose exec ansible /bin/bash
```

### Send a 'ping' to all clients

```
cd $HOME/ansible
ansible all -m ping 
```
The output should look like this:
```
root@ansible:~/ansible# ansible -m ping all
client-1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
client-2 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
client-3 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
client-4 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
root@ansible:~/ansible#
```
## Now you're ready to play
