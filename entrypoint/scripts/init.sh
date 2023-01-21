#! /usr/bin/env bash

function install_basics() {
    apt update
    export DEBIAN_FRONTEND=noninteractive
    apt install -y --no-install-recommends \
        dialog \
        apt-utils \
        sudo \
        vim \
        curl \
        wget \
        iputils-ping \
        procps \
        psutils \
        git \
        direnv \
        python3-pip \
        ansible
    python3 -m pip install argcomplete
}
function create_initial_ssh_keypair() {
    [[ ! -f /root/.ssh/id_rsa ]] && ssh-keygen -t rsa -b 4096 -f /root/.ssh/id_rsa -N '' -C "ansible-playground_$(date +%F)"
    tee /root/.ssh/authorized_keys </root/.ssh/id_rsa.pub
}
function generate_config_files() {
    cat <<_EOF >"${HOME}/.bashrc"
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
    if [[ ! -f ${HOME}/ansible/inventory.yml ]]; then
        cp -a "${HOME}/ansible/inventory.yml.example" "${HOME}/ansible/inventory.yml"
    fi
    if [[ ! -f ${HOME}/ansible/ansible.cfg ]]; then
        cp -a "${HOME}/ansible/ansible.cfg.example" "${HOME}/ansible/ansible.cfg"
    fi
    mkdir -p "${HOME}/ansible/log/"
    touch "${HOME}/ansible/log/ansible.log"
    activate-global-python-argcomplete --user
}
function test_initial_client_connection() {
    cd "${HOME}/ansible" || exit
    ansible all -o -m ping
}
function main() {
    install_basics
    create_initial_ssh_keypair
    generate_config_files
    create_vim_config
    prepare_ansible_defaults
    test_initial_client_connection
}
main
