#!/usr/bin/env bash

set -euo pipefail

# Ensure that ~/.local/bin is in the PATH
if [[ "$PATH" != *"${HOME}/.local/bin"* ]]; then
    export PATH="${PATH}:${HOME}/.local/bin"
fi

mktemp_venv() {
    if ! command -v python3 &>/dev/null; then
        echo "ERROR: Python 3 is not installed" >&2
        return 1
    fi

    local venv_dir="$(mktemp -d)"

    if ! python3 -m venv "$venv_dir" "$@"; then
        echo "ERROR: Failed to create virtual environment" >&2
        rm -rf "$venv_dir"
        return 1
    fi

    echo "$venv_dir"
}

addtemp_ansible() {
    local ansible_venv="$(
        mktemp_venv --prompt ansible --system-site-packages
    )" || return 1
    source "$ansible_venv/bin/activate"

    {
        pip install -qq --upgrade pip wheel
        pip install -qq ansible
    } || {
        echo "ERROR: Failed to install Ansible" >&2
        deactivate
        rm -rf "$ansible_venv"
        return 1
    }
    
    export PATH="$ansible_venv/bin:$PATH"
}

if ! command -v ansible &>/dev/null; then
    echo "INFO: Installing Ansible to a temporary environment" >&2
    addtemp_ansible || exit 1
    echo "INFO: Ansible installed successfully" >&2
    export ANSIBLE_RUN_TAGS="all,ansible"
fi

printf "INFO: Using %s from %s\n" \
    "$(ansible --version | head -n1)" "$(command -v ansible)" >&2

exec "$@"
