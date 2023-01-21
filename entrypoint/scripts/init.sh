#! /usr/bin/env bash

apt update &&
    export DEBIAN_FRONTEND=noninteractive &&
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
        python3-pip \
        ansible

python3 -m pip install argcomplete

[[ ! -f /root/.ssh/id_rsa ]] && ssh-keygen -t rsa -b 4096 -f /root/.ssh/id_rsa -N '' -C "ansible-playground_$(date +%F)"
if [[ -f /root/.ssh/id_rsa.pub ]] && [[ ! -f /root/.ssh/authorized_keys ]]; then
    tee /root/.ssh/authorized_keys </root/.ssh/id_rsa.pub
fi
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

cat <<_EOF >"${HOME}/.bash_aliases"
alias ls='ls \$LS_OPTIONS'
alias ll='ls -l'
alias la='ls -lAh'
alias lt='ls -ltrh'
alias l1='ls -1'
alias src='. \${HOME}/.bashrc'

# Some more alias to avoid making mistakes:
# alias rm='rm -i'
# alias cp='cp -i'
# alias mv='mv -i'
_EOF
source "${HOME}/.bashrc"
activate-global-python-argcomplete --user
