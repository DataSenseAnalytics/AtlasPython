#!/usr/bin/env bash
# The purpose of this script is to create a fresh install of miniconda, and then create a
# gzipped tarball of that pure environment. This script performs this for OS X and Linux.
# If we want to upgrade the miniconda version, should update the MINICONDA_VERSION and then
# check in the new tarballs to source control

MINICONDA_VERSION="miniconda2-4.3.30"

function conda_pip() {
    python -m pip "$@"
}

function create_miniconda_tarball_generic() {
    # https://stackoverflow.com/a/246128
    ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

    if ! type -p pyenv &> /dev/null; then
        echo "Must have pyenv available on your PATH in order to use this tool"
        exit 1
    fi

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
    echo "Starting to create conda tarballs for Mac OS X"
    echo "-----------"
    create_miniconda_tarball_generic
    echo "Finished creating miniconda tarball for Mac OS X"
    echo "-----------"
}

function create_miniconda_tarball_linux() {
    echo "Starting to create miniconda tarball for Linux (inside Docker)"
    echo "-----------"
    local docker_image_name="atlas-python:${MINICONDA_VERSION}"
    docker build -t  "${docker_image_name}" .
    # In order to use the docker cp command need to supply a container name.
    # We create a random one
    local random_container_name
    random_container_name="$(echo ${RANDOM})"
    docker run -it --name "${random_container_name}" "${docker_image_name}" bash -c "exit 0"

    local conda_location_inside_image="/conda"
    docker cp "${random_container_name}:${conda_location_inside_image}/." .
    echo "-----------"
    echo "Finished creating miniconda tarball for Linux"

}

function main() {
    set -euo pipefail
    echo "Starting to create conda tarballs for all platforms"
    echo "-----------"
    create_miniconda_tarball_linux
    create_miniconda_tarball_osx
    echo "-----------"
    echo "Finished creating all miniconda versions"
}

# https://stackoverflow.com/questions/2683279/how-to-detect-if-a-script-is-being-sourced
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    echo "script is being sourced ..."
else
    main
fi

