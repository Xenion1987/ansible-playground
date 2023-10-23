# Role: `user_management`

Manage users and their SSH public key enrollment via Ansible.

## Requirements

- Ansible >=2.10

## Role Variables

### `defaults/main.yml`

| Name                                       | Type  | Default | Description |
| ------------------------------------------ | ----- | ------- | ----------- |
| `user_management_default_sudo_mode`        | `str` |         |             |
| `user_management_default_shell`            | `str` |         |             |
| `user_management_default_home_root`        | `str` |         |             |
| `user_management_default_primary_group`    | `str` |         |             |
| `user_management_default_secondary_groups` | `str` |         |             |
| `user_management_default_ssh_from`         | `str` |         |             |

### `vars/main.yml`

| Name                                       | Type   | Default                         | Description |
| ------------------------------------------ | ------ | ------------------------------- | ----------- |
| `user_management_users`                    | `list` |                                 |             |
| `user_management_users.name`               | `str`  |                                 |             |
| `user_management_users.state`              | `str`  |                                 |             |
| `user_management_users.userdel_remove`     | `bool` | `false`                         |             |
| `user_management_users.userdel_force`      | `bool` | `false`                         |             |
| `user_management_users.home_create`        | `bool` | `true`                          |             |
| `user_management_users.absolute_home_path` | `str`  |                                 |             |
| `user_management_users.home_move`          | `bool` | `false`                         |             |
| `user_management_users.primary_group`      | `str`  | `user_management_users.name`    |             |
| `user_management_users.secondary_groups`   | `str`  | `user_management_users.name`    |             |
| `user_management_users.groups_append`      | `bool` | `true`                          |             |
| `user_management_users.shell`              | `str`  | `user_management_default_shell` |             |
| `user_management_users.custom_ssh_from`    | `str`  |                                 |             |

## Dependencies

- ansible.posix

## Example Playbook

```yaml
---
- name: Manage SSH user via Ansible
  hosts: all
  tasks:
    - name: Include role 'user_management'
      include_role:
        name: user_management
```

## Author Information

[Xenion1987](https://github.com/Xenion1987)
