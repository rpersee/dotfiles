#!/usr/bin/env bash
#
# Install Ansible using pipx

set -e

if ! expr match "$PATH" "$HOME/.local/bin" &>/dev/null; then
    export PATH="$HOME/.local/bin:$PATH"
fi

if command -v ansible &>/dev/null; then
    echo "Ansible is already installed. Exiting..."
    exit 0
fi

if ! command -v python3 &>/dev/null; then
    echo "python3 is not installed. Exiting..."
    exit 1
fi

if command -v curl &>/dev/null; then
    DL_CMD="curl -fsSL"
elif command -v wget &>/dev/null; then
    DL_CMD="wget -qO-"
else
    echo "Neither curl nor wget found. Exiting..."
    exit 1
fi

export PIP_ROOT="/" # needed to prevent externally-managed-environment error
export PIP_USER=true

if ! command -v pip &>/dev/null; then
    echo "pip is not installed. Installing pip..."
    {
        echo "Trying to install pip using ensurepip..."
        python3 -m ensurepip --root / --user 2>/dev/null
    } || {
        echo "Trying to install pip using get-pip.py..."
        $DL_CMD https://bootstrap.pypa.io/get-pip.py | python3 -
    } || {
        echo "Failed to install pip. Exiting..."
        exit 1
    }
    echo "pip installed successfully."
fi

if command -v pip3 &>/dev/null && ! command -v pip &>/dev/null; then
    echo "Creating a symbolic link for pip3..."
    ln -s pip3 ~/.local/bin/pip
fi

echo "Installing pipx..."
pip install pipx

echo "Installing Ansible using pipx..."
pipx install --include-deps ansible
