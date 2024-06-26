#!/usr/bin/env bash

# shellcheck disable=SC2312 # Consider invoking this command separately to avoid masking its return value
export DEBIAN_FRONTEND=noninteractive

##############################################
# Helper functions
##############################################
function cbanner() {
  #############################################
  # DESCRIPTION:
  # Print a banner as an eye catcher or separator
  #
  # EXAMPLE USAGE:
  # cbanner Hello World
  #
  # OUTPUT:
  ########################################
  #             Hello World              #
  ########################################
  #############################################

  local STRING="${*}"
  local BANNER_SYMBOL="#"
  local BANNER_WIDTH=40
  local SPACES_LEFT_COUNT=$(((BANNER_WIDTH - ${#STRING} - 2) / 2))
  local BANNER_LINE
  BANNER_LINE=$(printf "%${BANNER_WIDTH}s" | tr ' ' "${BANNER_SYMBOL}")

  echo "${BANNER_LINE}"
  echo "#$(printf "%${SPACES_LEFT_COUNT}s")${STRING}$(printf "%$((BANNER_WIDTH - ${#STRING} - 2 - SPACES_LEFT_COUNT))s")#"
  echo "${BANNER_LINE}"
}
function helper_apt_cleanup() {
  cbanner "Proceeding ${FUNCNAME[0]}"
  apt -y autoremove
  apt -y autoclean
  apt -y clean
  rm -rf /var/lib/apt/lists/*
}
function helper_apt_install() {
  cbanner "Proceeding ${FUNCNAME[0]} ${*}"
  apt update &&
    apt -y --no-install-recommends install "${@}" &&
    helper_apt_cleanup
}
function helper_get_latest_git_release() {
  local org="${1}"
  local repo="${2}"
  curl --fail -sS "https://api.github.com/repos/${org}/${repo}/releases/latest" |
    grep '"tag_name":' |
    sed -E 's/.*"([^"]+)".*/\1/'
}
function helper_get_machine_arch() {
  local machine_arch=""
  case $(uname -m) in
  i386)
    machine_arch="386"
    ;;
  i686)
    machine_arch="386"
    ;;
  x86_64)
    machine_arch="amd64"
    ;;
  arm64)
    machine_arch="arm64"
    ;;
  aarch64)
    dpkg --print-architecture | grep -q "arm64" && machine_arch="arm64" || machine_arch="arm"
    ;;
  *)
    machine_arch="UNKNOWN"
    ;;
  esac
  echo "${machine_arch}"
}
##############################################
# Install functions
##############################################
function install_all_ansible() {
  cbanner "Proceeding ${FUNCNAME[0]} ${*}"
  install_os_requirements_ansible
  install_pip
  install_pip_requirements
  install_pre_commit
  install_ansible "${1}"
  shift
  install_ansible_lint "${1}"
  shift
  install_openstacksdk
  helper_apt_cleanup
}
function install_all_terraform() {
  cbanner "Proceeding ${FUNCNAME[0]} ${*}"
  install_os_requirements_terraform
  install_pip
  install_pip_requirements
  install_pre_commit
  install_terraform "${1}"
  shift
  install_terraformer "${1}"
  shift
  install_tf_docs "${1}"
  shift
  install_tf_lint "${1}"
  shift
  install_trivy "${1}"
  shift
  install_terragrunt "${1}"
  shift
  install_awscli "${1}"
  shift
  helper_apt_cleanup
}
function install_os_requirements_ansible() {
  cbanner "Proceeding ${FUNCNAME[0]}"
  apt -y purge imagemagick imagemagick-6-common
  apt -y dist-upgrade
  helper_apt_install \
    apt-transport-https \
    apt-utils \
    bash-completion \
    curl \
    dialog \
    git \
    gcc \
    gpg \
    gnupg \
    lsb-release \
    openssh-client \
    python3-pip \
    python3-apt \
    python3-venv \
    sshpass \
    sudo \
    unzip
}
function install_os_requirements_terraform() {
  cbanner "Proceeding ${FUNCNAME[0]}"
  apt -y purge imagemagick imagemagick-6-common
  apt -y dist-upgrade
  helper_apt_install \
    apt-transport-https \
    apt-utils \
    bash-completion \
    curl \
    dialog \
    gettext \
    git \
    gpg \
    gnupg \
    lsb-release \
    python3-minimal \
    python3-pip \
    openssh-client \
    sudo \
    unzip
}
function install_ansible() {
  cbanner "Proceeding ${FUNCNAME[0]} ${*}"
  if [[ "${1}" == "latest" ]]; then
    python3 -m pip install --upgrade \
      ansible
  else
    python3 -m pip install --upgrade \
      "ansible${1}"
  fi
}
function install_ansible_lint() {
  cbanner "Proceeding ${FUNCNAME[0]} ${*}"
  if [[ "${1}" == "latest" ]]; then
    python3 -m pip install --upgrade \
      ansible-lint
  else
    python3 -m pip install --upgrade \
      "ansible-lint${1}"
  fi
}
function install_awscli() {
  cbanner "Proceeding ${FUNCNAME[0]} ${*}"
  local machine_arch
  local install_path=/usr/local/aws-cli
  local binary_path=/usr/local/bin
  case $(uname -m) in
  aarch64)
    machine_arch="aarch64"
    ;;
  *)
    machine_arch="x86_64"
    ;;
  esac
  curl "https://awscli.amazonaws.com/awscli-exe-linux-${machine_arch}.zip" -o "/tmp/awscliv2.zip"
  cd /tmp || exit 1
  unzip /tmp/awscliv2.zip
  /tmp/aws/install --install-dir "${install_path}" --bin-dir "${binary_path}"
  if [[ -f /usr/local/bin/aws ]]; then
    rm -rf /tmp/awscliv2.zip /tmp/aws
    return 0
  else
    exit 1
  fi
}
function install_openstacksdk() {
  cbanner "Proceeding ${FUNCNAME[0]}"
  apt purge -y gcc && apt update && apt -y install gcc
  helper_apt_cleanup
  python3 -m pip install --upgrade \
    openstacksdk
}
function install_pip() {
  cbanner "Proceeding ${FUNCNAME[0]}"
  python3 -m pip install --upgrade \
    pip
}
function install_pip_requirements() {
  cbanner "Proceeding ${FUNCNAME[0]}"
  if [[ $(grep -Evc '^[[:space:]]*#' requirements.txt) -gt 0 ]]; then
    python3 -m pip install --upgrade \
      -r requirements.txt
  fi
}
function install_pre_commit() {
  cbanner "Proceeding ${FUNCNAME[0]}"
  python3 -m pip install --upgrade \
    pre-commit
}
function install_terraform() {
  cbanner "Proceeding ${FUNCNAME[0]} ${*}"
  local tf_version
  tf_version="${1:-latest}"
  if [[ ${tf_version} == "latest" ]]; then
    tf_version="terraform"
  else
    tf_version="terraform=${tf_version}-1"
  fi
  curl -sSLo - https://apt.releases.hashicorp.com/gpg |
    gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" |
    tee /etc/apt/sources.list.d/hashicorp.list
  helper_apt_install "${tf_version}"
}
function install_terraformer() {
  cbanner "Proceeding ${FUNCNAME[0]} ${*}"
  local machine_arch machine_os version
  local org=GoogleCloudPlatform
  local repo=terraformer
  local binary_path=/usr/bin
  local binary_name=terraformer
  machine_arch=$(helper_get_machine_arch)
  machine_os=$(uname)
  machine_os=${machine_os,,}
  version="${1:-latest}"

  if [[ ${version} == "latest" ]]; then
    version=$(helper_get_latest_git_release "${org}" "${repo}")
  fi
  curl -sSLo "${binary_path}/${binary_name}" \
    --url "https://github.com/${org}/${repo}/releases/download/${version}/terraformer-all-${machine_os,,}-${machine_arch,,}"
  chmod +x "${binary_path}/${binary_name}"
}
function install_terragrunt() {
  cbanner "Proceeding ${FUNCNAME[0]} ${*}"
  local machine_arch machine_os version
  local org=gruntwork-io
  local repo=terragrunt
  local binary_path=/usr/bin
  local binary_name=terragrunt
  machine_arch=$(helper_get_machine_arch)
  machine_os=$(uname)
  machine_os=${machine_os,,}
  version="${1:-latest}"

  if [[ ${version} == "latest" ]]; then
    version=$(helper_get_latest_git_release "${org}" "${repo}")
  fi
  curl -sSLo "${binary_path}/${binary_name}" \
    --url "https://github.com/${org}/${repo}/releases/download/${version}/terragrunt_${machine_os}_${machine_arch}"
  chmod +x "${binary_path}/${binary_name}"
}
function install_tf_docs() {
  cbanner "Proceeding ${FUNCNAME[0]} ${*}"
  local machine_arch machine_os version
  local org=terraform-docs
  local repo=terraform-docs
  local binary_path=/usr/bin
  local binary_name=terraform-docs
  machine_arch=$(helper_get_machine_arch)
  machine_os=$(uname)
  machine_os=${machine_os,,}
  version="${1:-latest}"

  if [[ ${version} == "latest" ]]; then
    version=$(helper_get_latest_git_release "${org}" "${repo}")
  fi
  curl -sSLo /tmp/terraform-docs.tar.gz \
    --url "https://terraform-docs.io/dl/${version}/terraform-docs-${version}-${machine_os}-${machine_arch}.tar.gz"
  tar -xzf /tmp/terraform-docs.tar.gz -C /tmp/
  chmod +x "/tmp/${binary_name}"
  mv "/tmp/${binary_name}" "${binary_path}/${binary_name}"
  rm -f /tmp/{README.md,LICENSE,*{.tar,.tgz,.gz}}
}
function install_tf_lint() {
  cbanner "Proceeding ${FUNCNAME[0]} ${*}"
  local TFLINT_VERSION
  export TFLINT_VERSION="${1:-latest}"
  curl -sSL https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
}
function install_trivy() {
  cbanner "Proceeding ${FUNCNAME[0]} ${*}"
  local version
  version="${1:-latest}"
  if [[ ${version} == "latest" ]]; then
    version="trivy"
  else
    version="trivy=${version}-1"
  fi
  curl -sSLo - https://aquasecurity.github.io/trivy-repo/deb/public.key |
    gpg --dearmor -o /usr/share/keyrings/trivy.gpg
  echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" |
    tee /etc/apt/sources.list.d/trivy.list
  helper_apt_install "${version}"
}
function install_minio_client() {
  cbanner "Proceeding ${FUNCNAME[0]}"
  local machine_arch machine_os
  local binary_path=/usr/bin/minio-binaries
  local binary_name=mc

  machine_arch=$(helper_get_machine_arch)
  machine_os=$(uname)
  machine_os=${machine_os,,}
  curl -sSL \
    --url "https://dl.min.io/client/mc/release/linux-${machine_arch}/mc" \
    --output "${binary_path}/${binary_name}" \
    --create-dirs

  chmod +x "${binary_path}/${binary_name}"
  export PATH="${PATH}:${binary_path}"
}
##############################################
# Setup functions
##############################################
function setup_python_argcomplete() {
  cbanner "Proceeding ${FUNCNAME[0]}"
  if [[ -f /usr/bin/activate-global-python-argcomplete3 ]]; then
    /usr/bin/activate-global-python-argcomplete3
  elif [[ -f /usr/bin/activate-global-python-argcomplete ]]; then
    /usr/bin/activate-global-python-argcomplete
  else
    return 0
  fi
}
function setup_user() {
  cbanner "Proceeding ${FUNCNAME[0]} ${*}"
  local usr
  # local pswd
  usr="${1}"
  useradd -m -s /bin/bash "${usr}"
  usermod -a -G sudo "${usr}"
  # pswd=$(
  #   tr </dev/urandom -dc '_A-Z-a-z-0-9' | head -c"${2:-13}"
  #   echo
  # )
  # chpasswd <<<"${usr}:${pswd}"
  # echo "${pswd}" >"/home/${usr}/sudo_password.txt"
  echo "${usr} ALL=(ALL) NOPASSWD: ALL" >"/etc/sudoers.d/50-${usr}"
  chmod 400 "/etc/sudoers.d/50-${usr}"
  sed -i -r \
    -e 's/^([[:space:]]*)#(.*)--color(.*)/\1\2--color\3/' \
    -e 's/#force_color_prompt/force_color_prompt/' \
    -e 's/^([[:space:]]*)PS1(.*)\\\$/\1PS1\2\\n\\$/' \
    "/home/${usr}/.bashrc"
}
function setup_omb() {
  cbanner "Proceeding ${FUNCNAME[0]} ${*}"
  local theme
  local user_home
  theme="${1:-powerline-multiline}"
  user_home="$(awk -F':' '{print $6}' < <(getent passwd "$(whoami)"))"

  if ! ls -1Ad "${user_home}/.oh-my-bash" &>/dev/null; then
    rm -rf "${user_home}/.oh-my-bash"
  fi
  curl -fsSL -o /tmp/install.sh https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh
  chmod +x /tmp/install.sh
  if /tmp/install.sh --unattended; then
    sed -E -i \
      -e '/composer/d' \
      -e 's/OSH_THEME="(.*)"/OSH_THEME="'"${theme}"'"/' \
      ~/.bashrc
    rm -f /tmp/install.sh
  fi
}
function setup_ssh_key() {
  cbanner "Proceeding ${FUNCNAME[0]} ${*}"
  local usr
  usr="${1}"
  su - "${usr}" -c 'ssh-keygen -q -t rsa -b 4096 -f ~/.ssh/id_rsa -N "" -C "ansible_devcontainer" <<<y >/dev/null'
}
##############################################
# Help functions
##############################################
function help() {
  cat <<_ENDOFHELP

 USAGE:
  ./${0} COMMAND SUB-COMMAND

 COMMANDS:
  install       - Install applications
  setup         - Setup applications

 SUB-COMMANDS:
  help          - Show [COMMAND] help


_ENDOFHELP
}
function help_install() {
  cat <<_ENDOFHELP

 USAGE:
  ./${0} install SUB-COMMAND

 COMMAND:
  install                   - Install applications

 SUB-COMMANDS:
  ansible [VERSION]         - Install ansible via pip
  ansible-lint [VERSION]    - Install ansible-lint via pip
  awscli [VERSION]          - Install awscli via pip
  help                      - Show [COMMAND] help
  mc                        - Install MinIO client 'mc'
  pip                       - Install pip
  pip-requirements          - Install pip packages from requirements.txt
  pre-commit                - Install PreCommit via pip
  openstacksdk              - Install OpenStackSDK via pip
  os-requirements-ansible   - Install OS requirements
  os-requirements-terraform - Install OS requirements
  terraform [VERSION]       - Install terraform VERSION (default: latest)
  terraformer [VERSION]     - Install terraformer VERSION (default: latest)
  terraform-docs [VERSION]  - Install terraform-docs VERSION (default: latest)
  terragrunt [VERSION]      - Install terragrunt VERSION (default: latest)
  tflint [VERSION]          - Install terraform-lint VERSION (default: latest)
  trivy [VERSION]           - Install trivy VERSION (default: latest)

  all
    SUB-COMMANDS:
    ansible \\
      [ANSIBLE_VERSION] \\
      [ANSIBLE_LINT_VERSION] - Install all ansible applications
    terraform \\
      [TERRAFORM_VERSION] \\
      [TERRAFORMER_VERSION] \\
      [TFDOCS_VERSION] \\
      [TFLINT_VERSION] \\
      [TFTRIVY_VERSION] \\
      [TERRAGRUNT_VERSION]   - Install all terraform applications


_ENDOFHELP
}
function help_setup() {
  cat <<_ENDOFHELP

 USAGE:
  ./${0} setup SUB-COMMAND [OPTIONS]

 COMMAND:
  setup               - Setup applications

 SUB-COMMANDS:
  help                - Show [COMMAND] help
  oh-my-bash [THEME]  - Setup Oh-My-Bash command line with theme THEME (default: 'powerline-multiline')
  python-argcomplete  - Setup Python-Argcomplete
  ssh-key USERNAME    - Add USERNAME's id_rsa ssh key pair
  user USERNAME       - Add linux user USERNAME


_ENDOFHELP
}
##############################################
# Main function
##############################################
function main() {
  case $1 in
  install)
    shift
    case $1 in
    all)
      shift
      case $1 in
      ansible)
        shift
        install_all_ansible "${1:-latest}" "${2:-latest}"
        ;;
      terraform)
        shift
        install_all_terraform "${1:-latest}" "${2:-latest}" "${3:-latest}" "${4:-latest}" "${5:-latest}"
        ;;
      *)
        echo "Missing or wrong SUB-COMMAND - Exit"
        help_install
        exit 1
        ;;
      esac
      ;;
    ansible)
      shift
      install_ansible "${1:-latest}"
      ;;
    ansible-lint)
      shift
      install_ansible_lint "${1:-latest}"
      ;;
    awscli)
      shift
      install_awscli "${1:-latest}"
      ;;
    mc)
      install_minio_client
      ;;
    pip)
      install_pip
      ;;
    pip-requirements)
      install_pip_requirements
      ;;
    pre-commit)
      install_pre_commit
      ;;
    openstacksdk)
      install_openstacksdk
      ;;
    os-requirements-ansible)
      install_os_requirements_ansible
      ;;
    os-requirements-terraform)
      install_os_requirements_terraform
      ;;
    terraform)
      shift
      install_terraform "${1}"
      ;;
    terraformer)
      shift
      install_terraformer "${1}"
      ;;
    terraform-docs)
      shift
      install_tf_docs "${1}"
      ;;
    terragrunt)
      shift
      install_terragrunt "${1}"
      ;;
    tflint)
      shift
      install_tf_lint "${1}"
      ;;
    trivy)
      shift
      install_trivy "${1}"
      ;;
    *)
      echo "Missing or wrong SUB-COMMAND - Exit"
      help_install
      exit 1
      ;;
    esac
    ;;
  setup)
    shift
    case $1 in
    oh-my-bash)
      shift
      setup_omb "${1}"
      ;;
    python-argcomplete)
      setup_python_argcomplete
      ;;
    user)
      shift
      if [[ -z "${1}" ]]; then
        echo "Missing USERNAME - Exit"
        help_setup
        exit 1
      fi
      setup_user "${1}"
      ;;
    ssh-key)
      shift
      if [[ -z "${1}" ]]; then
        echo "Missing USERNAME - Exit"
        help_setup
        exit 1
      fi
      setup_ssh_key "${1}"
      ;;
    *)
      echo "Missing or wrong SUB-COMMAND - Exit"
      help_setup
      exit 1
      ;;
    esac
    ;;
  *)
    echo "Missing or wrong SUB-COMMAND - Exit"
    help
    exit 1
    ;;
  esac
}
main "${@}"
