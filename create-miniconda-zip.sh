#!/usr/bin/env bash
# The purpose of this script is to create a fresh install of miniconda and zipping it.
# This is useful when we want to add a new zip version to the DataSenseAnalytics/AtlasPython
# repository

set -euo pipefail

# https://stackoverflow.com/a/246128
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
MINICONDA_VERSION="miniconda2-4.3.30"

pyenv uninstall -f "${MINICONDA_VERSION}"
pyenv install "${MINICONDA_VERSION}"

pushd ~/.pyenv/versions/"${MINICONDA_VERSION}"

MINICONDA_DIR="$(pwd)"
PATH="${MINICONDA_DIR}/bin:${PATH}"
echo "MINICONDA_DIR=${MINICONDA_DIR}"

function conda_pip() {
    python -m pip "$@"
}

conda_pip install --upgrade pip

OS_VERSION_ARCH="$(uname)_$(uname -p)"
OUTPUT_ZIP_NAME="${ROOT_DIR}/${MINICONDA_VERSION}_${OS_VERSION_ARCH}.tgz"
tar -C "${MINICONDA_DIR}/.." -czf  "${OUTPUT_ZIP_NAME}" "${MINICONDA_VERSION}"

echo "Miniconda installation for platform ${OS_VERSION_ARCH} complete"
echo "Artifact is available at: ${OUTPUT_ZIP_NAME}"