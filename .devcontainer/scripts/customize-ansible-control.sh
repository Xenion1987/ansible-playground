#! /usr/bin/env bash

WORKDIR="/workspaces/ansible-playground"

function install_basics() {
  sudo apt update
  export DEBIAN_FRONTEND=noninteractive
  sudo apt install -y --no-install-recommends \
    dialog \
    apt-utils \
    sudo \
    vim \
    curl \
    iputils-ping \
    git \
    direnv \
    python3-pip
  sudo rm -rf /var/lib/apt/lists/*
  python3 -m pip install --upgrade --user pip argcomplete ansible ansible-lint
  if [[ ! -f /usr/bin/python ]]; then
    sudo ln -s /usr/bin/python3 /usr/bin/python
  fi
}
function generate_config_files() {
  if find "${HOME}" -type f -name '.functions' | grep -q .; then
    return 0
  fi
  cat <<_EOF >>"${HOME}/.bashrc"
export LS_OPTIONS='--color=auto'
eval "\$(dircolors -b)"

files=(.bash_aliases .functions .paths)
for file in "\${files[@]}"; do
    if [[ ! -f "\${HOME}/\${file}" ]]; then
        touch "\${HOME}/\${file}"
    else
        source "\${HOME}/\${file}"
    fi
done
if [[ -f \${HOME}/.bash_completion.d/python-argcomplete ]]; then
    source \${HOME}/.bash_completion.d/python-argcomplete
fi
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
function prepare_ansible_defaults() {
  if [[ ! -f ${WORKDIR}/inventory.yml ]]; then
    cp -a "${WORKDIR}/inventory.yml.example" "${WORKDIR}/inventory.yml"
  fi
  if [[ ! -f ${WORKDIR}/ansible.cfg ]]; then
    cp -a "${WORKDIR}/ansible.cfg.example" "${WORKDIR}/ansible.cfg"
  fi
  mkdir -p "${HOME}/.ansible/log/"
  touch "${HOME}/.ansible/log/ansible.log"
  activate-global-python-argcomplete --user
}
function test_initial_client_connection() {
  ansible all -o -m ping
}
function main() {
  install_basics
  generate_config_files
  create_vim_config
  prepare_ansible_defaults
  test_initial_client_connection
}
main
