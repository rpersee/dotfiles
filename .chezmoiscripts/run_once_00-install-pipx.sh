#!/usr/bin/env sh
#
# Install pipx in user site-packages

set -e

mkvenv() {
    ENV_DIR="$1"
    python3 -m venv "$ENV_DIR" || return 1
    # shellcheck source=/dev/null
    . "$ENV_DIR/bin/activate"
}

XDG_EXEC_HOME="${XDG_EXEC_HOME:-"$HOME/.local/bin"}"
if [ "${PATH#*"$XDG_EXEC_HOME"}" = "$PATH" ]; then
    echo "INFO: Ensure user-specific executables are in PATH" >&2
    export PATH="${XDG_EXEC_HOME}:${PATH}"
fi

if command -v pipx >/dev/null 2>&1; then
    echo "INFO: Skipping installation of pipx" >&2
    exit 0
fi

WORKSPACE="$(mktemp -d)"
on_exit() { rm -rf "$WORKSPACE"; }
trap on_exit EXIT

SYSTEM_PYTHON="$(command -v python3)" || {
    echo "ERROR: Python 3 is not installed" >&2
    exit 1
}
echo "INFO: Managing $(python3 --version) from $SYSTEM_PYTHON" >&2

if ! python3 -m pip --version >/dev/null 2>&1; then
    echo "INFO: Python module 'pip' is not available globally" >&2
    echo "INFO: Creating a temporary virtual environment" >&2
    mkvenv "$WORKSPACE/venv" || {
        echo "ERROR: Failed to create the virtual environment" >&2
        exit 1
    }
fi
echo "INFO: Using $(python3 -m pip --version)" >&2

echo "INFO: Installing pipx in user site-packages" >&2
PIP_PYTHON="$SYSTEM_PYTHON" python3 -m \
    pip --- install --root / --user pipx >/dev/null
echo "INFO: Installed pipx $(pipx --version) in $(command -v pipx)" >&2
