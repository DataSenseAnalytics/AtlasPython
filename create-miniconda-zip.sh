#!/usr/bin/env bash
# The purpose of this script is to create a fresh install of miniconda and zipping it.
# This is useful when we want to add a new zip version to the DataSenseAnalytics/AtlasPython
# repository

MINICONDA_VERSION="miniconda2-4.3.30"

function conda_pip() {
    python -m pip "$@"
}

function create_miniconda_tarball_generic() {
    # https://stackoverflow.com/a/246128
    ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

    pyenv uninstall -f "${MINICONDA_VERSION}"
    pyenv install "${MINICONDA_VERSION}"

    pushd ~/.pyenv/versions/"${MINICONDA_VERSION}"

    MINICONDA_DIR="$(pwd)"
    PATH="${MINICONDA_DIR}/bin:${PATH}"
    echo "MINICONDA_DIR=${MINICONDA_DIR}"



    conda_pip install --upgrade pip

    OS_VERSION_ARCH="$(uname)_$(uname -p)"
    OUTPUT_ZIP_NAME="${ROOT_DIR}/${MINICONDA_VERSION}_${OS_VERSION_ARCH}.tgz"
    tar -C "${MINICONDA_DIR}/.." -czf  "${OUTPUT_ZIP_NAME}" "${MINICONDA_VERSION}"

    echo "Miniconda installation for platform ${OS_VERSION_ARCH} complete"
    echo "Artifact is available at: ${OUTPUT_ZIP_NAME}"
}

function create_miniconda_tarball_osx() {
    create_miniconda_tarball_generic
}

function create_miniconda_tarball_linux() {
    local docker_image_name="atlas-python:${MINICONDA_VERSION}"
    docker build -t  "${docker_image_name}" .
    # In order to use the docker cp command need to supply a container name.
    # We create a random one
    docker run -it "${docker_image_name}" bash -c "exit 0"
    local random_container_name
    random_container_name="$(echo ${RANDOM})"
    local conda_location_inside_image="/conda"
    docker cp "${random_container_name}:/${conda_location_inside_image}/." .
}

function main() {
    set -euo pipefail
    create_miniconda_tarball_linux
    create_miniconda_tarball_osx
}

# https://stackoverflow.com/questions/2683279/how-to-detect-if-a-script-is-being-sourced
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    echo "script is being sourced ..."
else
    main
fi

