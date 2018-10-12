FROM ubuntu:14.04
SHELL ["/bin/bash", "-c"]

RUN apt-get update && apt-get install -y curl git

RUN curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash
ADD create-miniconda-zip.sh create-miniconda-zip.sh

ENV PATH="${PATH}:~/.pyenv/bin"

RUN eval "$(pyenv init -)" && \
    source ./create-miniconda-zip.sh && \
    create_miniconda_tarball_generic

RUN mkdir -p /conda && cp miniconda*.tgz /conda
