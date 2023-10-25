# Role: `user_management`

Manage users and their SSH public key enrollment via Ansible.

## Requirements

- Ansible >=2.10

## Role Variables

### `defaults/main.yml`

| Name                                       | Type  | Default | Description                                                                                                                                             |
| ------------------------------------------ | ----- | ------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `user_management_default_sudo_mode`        | `str` |         | Installs `sudo` if set to `sudo`.                                                                                                                       |
| `user_management_default_shell`            | `str` |         | Default Shell to set per user to create. May be referenced in user's variables.                                                                         |
| `user_management_default_home_root`        | `str` |         | Custom `$HOME` root path. May be referenced in user's variables.                                                                                        |
| `user_management_default_primary_group`    | `str` |         | Custom primary user group. May be referenced in user's variables.                                                                                       |
| `user_management_default_secondary_groups` | `str` |         | Custom secondary user groups (comma-seperated). May be referenced in user's variables.                                                                  |
| `user_management_default_ssh_from`         | `str` | `"*"`   | Default, global `from=""` value added to `authorized_keys` for each user which has a `{{user_management_users.name}}.pubkey` file in [files](./files/). |

### `vars/main.yml`

| Name                                       | Type   | Default                         | Description                                                                                                                                                                                                                                              |
| ------------------------------------------ | ------ | ------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `user_management_users`                    | `list` |                                 | List of users to be modiefied.                                                                                                                                                                                                                           |
| `user_management_users.name`               | `str`  |                                 | User's Linux login name.                                                                                                                                                                                                                                 |
| `user_management_users.state`              | `str`  |                                 | User's state (`present` or `absent`).                                                                                                                                                                                                                    |
| `user_management_users.userdel_remove`     | `bool` | `false`                         | This only affects 'state=absent', it attempts to remove directories associated with the user.                                                                                                                                                            |
| `user_management_users.userdel_force`      | `bool` | `false`                         | This only affects 'state=absent', it forces removal of the user and associated directories on supported platforms.                                                                                                                                       |
| `user_management_users.home_create`        | `bool` | `true`                          | Unless set to false, a home directory will be made for the user when the account is created or if the home directory does not exist.                                                                                                                     |
| `user_management_users.absolute_home_path` | `str`  |                                 | Optionally set the user's home directory.                                                                                                                                                                                                                |
| `user_management_users.home_move`          | `bool` | `false`                         | If set to `true` when used with `home:` , attempt to move the user's old home directory to the specified directory if it isn't there already and the old home exists.                                                                                    |
| `user_management_users.primary_group`      | `str`  | `user_management_users.name`    | Optionally sets the user's primary group (takes a group name).                                                                                                                                                                                           |
| `user_management_users.secondary_groups`   | `str`  | `user_management_users.name`    | List of groups user will be added to. By default, the user is removed from all other groups. Configure `groups_append` to modify this. When set to an empty string `''`, the user is removed from all groups except the primary group.                   |
| `user_management_users.groups_append`      | `bool` | `true`                          | If `true`, add the user to the groups specified in groups. If `false`, user will only be added to the groups specified in `secondary_groups`, removing them from all other groups.                                                                       |
| `user_management_users.shell`              | `str`  | `user_management_default_shell` | Optionally set the user's shell.                                                                                                                                                                                                                         |
| `user_management_users.custom_ssh_from`    | `str`  |                                 | `from=""` value added to `authorized_keys` if user has a `{{user_management_users.name}}.pubkey` file in [files](./files/). If `user_management_default_ssh_from` or `custom_ssh_from` is defined and not set to `'*'`, all values will be concatenated. |

### `../inventory/host_vars/*`

| Name              | Type  | Default | Description                                                                                                                                                                                                                                                                        |
| ----------------- | ----- | ------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `custom_ssh_from` | `str` |         | `from=""` value added to `authorized_keys` for each user which has a `*.pubkey` file in [files](./files/) on the specific host. If `user_management_default_ssh_from` or `user_management_users.custom_ssh_from` is defined and not set to `'*'`, all values will be concatenated. |

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
