# Role: `user_management`

Manage firewall rules via 'Uncomplicated FireWall (UFW).  
Inspired by 'Ansible weareinteractive.ufw role'.

> **IMPORTANT** | This role won't work in docker containers!

## Requirements

- Ansible >=2.10

## Role Variables

### `defaults/main.yml`

| Name | Type | Default | Description |
| ---- | ---- | ------- | ----------- |

### `vars/main.yml`

| Name | Type | Default | Description |
| ---- | ---- | ------- | ----------- |

### `../inventory/host_vars/*`

| Name           | Type | Default | Description |
| -------------- | ---- | ------- | ----------- |
| ufw_host_rules | list |         |             |

## Dependencies

- community.general

## Example Playbook

```yaml
---
- name: Play for setting up Uncomplicated FireWall
  hosts: all
  gather_facts: true

  tasks:
    - name: Include role 'ufw'
      ansible.builtin.include_role:
        name: ufw
```

## Author Information

[Xenion1987](https://github.com/Xenion1987)
