#!/usr/bin/env bash

USER_NAME="vscode"
USER_HOME="/home/${USER_NAME}"
USER_HIST_PATH="${USER_HOME}/.history_export"
USER_HIST_FILE="${USER_HIST_PATH}/.bash_history"
USER_HIST_FORMAT="%F %T %Z: "

SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=${USER_HIST_FILE} && export HISTTIMEFORMAT='${USER_HIST_FORMAT}'"

sudo install -o "${USER_NAME}" -g "${USER_NAME}" -m 750 -d "${USER_HIST_PATH}"
sudo touch "${USER_HIST_FILE}"
sudo chown -R "${USER_NAME}" "${USER_HIST_PATH}"

if ! grep -q "${SNIPPET}" "${USER_HOME}/.bashrc"; then
  echo "$SNIPPET" >>"${USER_HOME}/.bashrc"
fi
