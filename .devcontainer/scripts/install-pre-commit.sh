#!/usr/bin/env bash

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Function to install pre-commit on Linux
install_pre_commit_linux() {
  echo "Installing pre-commit on Linux..."
  $PIP_CMD install pre-commit
}

# Function to install pre-commit on macOS
install_pre_commit_macos() {
  echo "Installing pre-commit on macOS..."
  $PIP_CMD install pre-commit
}

# Check if pip is installed
check_pip_command() {
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

main() {
  check_pip_command
  install_pre_commit
  activate_pre_commit
}

main
