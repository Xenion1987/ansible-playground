#!/usr/bin/env bash

USER_NAME="$(whoami)"
USER_HOME="$(awk -F':' '{print $6}' < <(getent passwd "$(whoami)"))"
USER_HIST_PATH="${USER_HOME}/.history_export"
USER_HIST_FILE="${USER_HIST_PATH}/.history"
USER_RC_FILE="${USER_HOME}/.${SHELL##*/}rc"
USER_HIST_FORMAT="%F %T %Z: "

if ! ls -1Ad "${USER_HOME}/.oh-my-${SHELL##*/}" &>/dev/null; then
  SNIPPET+="export PROMPT_COMMAND='history -a'"$'\n'
fi
SNIPPET+="export HISTFILE=${USER_HIST_FILE}"$'\n'
SNIPPET+="export HISTTIMEFORMAT='${USER_HIST_FORMAT}'"

sudo install -o "${USER_NAME}" -g "${USER_NAME}" -m 750 -d "${USER_HIST_PATH}"
sudo touch "${USER_HIST_FILE}"
sudo chown -R "${USER_NAME}":"${USER_NAME}" "${USER_HIST_PATH}"

if ! grep -q "${SNIPPET}" "${USER_RC_FILE}"; then
  echo "$SNIPPET" >>"${USER_RC_FILE}"
fi
