#!/usr/bin/env bash

USER_NAME="vscode"
USER_HOME="/home/${USER_NAME}"
USER_HIST_PATH="${USER_HOME}/.history_export"
case $SHELL in
/bin/zsh)
  USER_HIST_FILE="${USER_HIST_PATH}/.zsh_history"
  USER_RC_FILE="${USER_HOME}/.zshrc"
  ;;
*)
  USER_HIST_FILE="${USER_HIST_PATH}/.bash_history"
  USER_RC_FILE="${USER_HOME}/.bashrc"
  ;;
esac
USER_HIST_FORMAT="%F %T %Z: "

SNIPPET="export PROMPT_COMMAND='history -a'
export HISTFILE=${USER_HIST_FILE}
export HISTTIMEFORMAT='${USER_HIST_FORMAT}'"

sudo install -o "${USER_NAME}" -g "${USER_NAME}" -m 750 -d "${USER_HIST_PATH}"
sudo touch "${USER_HIST_FILE}"
sudo chown -R "${USER_NAME}":"${USER_NAME}" "${USER_HIST_PATH}"

if ! grep -q "${SNIPPET}" "${USER_RC_FILE}"; then
  echo "$SNIPPET" >>"${USER_RC_FILE}"
fi
