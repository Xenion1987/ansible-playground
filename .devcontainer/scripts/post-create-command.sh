#!/usr/bin/env bash

WORKDIR="/workspaces/ansible-playground"

function install_basics() {
  export DEBIAN_FRONTEND=noninteractive
  sudo apt update && sudo apt -y dist-upgrade
  sudo apt install -y --no-install-recommends \
    bash-completion \
    iputils-ping \
    direnv \
    python3-pip \
    python3-venv \
    python3-argcomplete
  sudo rm -rf /var/lib/apt/lists/*
  sudo apt -y clean
  sudo apt -y autoclean
  sudo apt -y autoremove

  if [[ ! -f /usr/bin/python ]]; then
    sudo ln -s /usr/bin/python3 /usr/bin/python
  fi
}
function setup_python_argcomplete() {
  if type -p activate-global-python-argcomplete &>/dev/null; then
    sudo activate-global-python-argcomplete --dest /etc/bash_completion.d/
  elif type -p activate-global-python-argcomplete3 &>/dev/null; then
    sudo activate-global-python-argcomplete3 --dest /etc/bash_completion.d/
  fi
}
function generate_config_files() {
  if find "${HOME}" -type f -name '.functions' | grep -q .; then
    return 0
  fi
  cat <<_EOF >>"${HOME}/.bashrc"
# export LS_OPTIONS='--color=auto'
# eval "\$(dircolors -b)"



files=(.bash_aliases .functions .paths)
for file in "\${files[@]}"; do
    if [[ ! -f "\${HOME}/\${file}" ]]; then
        touch "\${HOME}/\${file}"
    else
        source "\${HOME}/\${file}"
    fi
done
COMPLETION_DIRS=(/etc/bash_completion.d/ \${HOME}/.bash_completion.d/)
for COMPLETION_DIR in "\${COMPLETION_DIRS[@]}"; do
  if [[ -f "\${COMPLETION_DIR}" ]]; then
    for f in \$(ls -1qA "\${COMPLETION_DIR}"); do
      source "\${COMPLETION_DIR}/\${f}"
    done
  fi
done
eval "\$(direnv hook bash)"
_EOF
  cat <<_EOF >"${HOME}/.bash_aliases"
alias ls='ls \$LS_OPTIONS'
alias ll='ls -l'
alias la='ls -lAh'
alias lt='ls -ltrh'
alias l1='ls -1'
alias src='. \${HOME}/.bashrc'
_EOF
  files=(.bash_aliases .functions .paths)
  for file in "${files[@]}"; do
    touch "${HOME}/${file}"
  done

  EXPAND_PATHS=("${HOME}/.local/bin")
  for EXPAND_PATH in "${EXPAND_PATHS[@]}"; do
    if ! grep -q "{EXPAND_PATH}" "${HOME}/.paths"; then
      echo "PATH=\${PATH}:${EXPAND_PATH}" >>"${HOME}/.paths"
    fi
  done
}
function create_vim_config() {
  mkdir -p "${HOME}/.vim/pack/vendor/start"
  git clone --depth 1 https://github.com/pearofducks/ansible-vim.git "${HOME}/.vim/pack/vendor/start/ansible-vim"

  cat <<_EOF >"${HOME}/.vimrc"
syntax on
filetype plugin indent on
au BufRead,BufNewFile */playbooks/*.yml set filetype=yaml.ansible
autocmd FileType yaml setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab autoindent
_EOF
}
create_ansible_venv() {
  cd "${WORKDIR}" || exit 1
  python3 -m venv "${WORKDIR}/.devcontainer/.venv-ansible"
  s="source ${WORKDIR}/.devcontainer/.venv-ansible/bin/activate"
  if ! grep -q "${s}" "${HOME}/.bashrc"; then
    echo "${s}" | tee -a "${HOME}/.bashrc"
  fi
}
activate_ansible_venv() {
  cd $WORKDIR || exit 1
  # shellcheck source=/dev/null
  source .devcontainer/.venv-ansible/bin/activate
}
function install_ansible() {
  python -m pip install --upgrade pip
  python -m pip install --upgrade ansible ansible-lint
}
function prepare_ansible_defaults() {
  if [[ ! -f ${WORKDIR}/inventory.yml ]]; then
    cp -a "${WORKDIR}/inventory.yml.example" "${WORKDIR}/inventory.yml"
  fi
  if [[ ! -f ${WORKDIR}/ansible.cfg ]]; then
    cp -a "${WORKDIR}/ansible.cfg.example" "${WORKDIR}/ansible.cfg"
  fi
  mkdir -p "${HOME}/.ansible/log/"
  touch "${HOME}/.ansible/log/ansible.log"
}
function test_initial_client_connection() {
  # ansible all -o -m ping
  ansible-playbook playbooks/ping_clients.yml
}
# function install_pre_commit() {
#   .devcontainer/scripts/install-pre-commit.sh
# }
command_exists() {
  # Function to check if a command exists
  command -v "$1" >/dev/null 2>&1
}
install_pre_commit_linux() {
  # Function to install pre-commit on Linux
  echo "Installing pre-commit on Linux..."
  $PIP_CMD install pre-commit
}

install_pre_commit_macos() {
  # Function to install pre-commit on macOS
  echo "Installing pre-commit on macOS..."
  $PIP_CMD install pre-commit
}
check_pip_command() {
  # Check if pip is installed
  if command_exists pip; then
    PIP_CMD="pip"
  elif command_exists pip3; then
    PIP_CMD="pip3"
  else
    echo "pip is not installed. Please install pip (https://pip.pypa.io/en/stable/installing/) and run the script again."
    exit 1
  fi
}
install_pre_commit() {
  # Check if pre-commit is already installed
  if command_exists pre-commit; then
    echo "pre-commit is already installed."
    return 0
  else
    case "$(uname)" in
    Linux)
      install_pre_commit_linux
      ;;
    Darwin)
      # Check if Homebrew is installed
      if command_exists brew; then
        install_pre_commit_macos
      else
        echo "Homebrew is not installed. Please install Homebrew (https://brew.sh/) and run the script again."
        exit 1
      fi
      ;;
    *)
      echo "Unsupported OS. This script only supports Linux and macOS."
      exit 1
      ;;
    esac
  fi
}
activate_pre_commit() {
  pre-commit install
  pre-commit autoupdate
}
function main() {
  install_basics
  setup_python_argcomplete
  generate_config_files
  # create_vim_config
  create_ansible_venv
  activate_ansible_venv
  install_ansible
  prepare_ansible_defaults
  test_initial_client_connection
  check_pip_command
  install_pre_commit
  activate_pre_commit
}
main
