FROM ubuntu:16.04

MAINTAINER Rutger Vos <rutger.vos@naturalis.nl>

ENV TERM linux
ENV DEBIAN_FRONTEND noninteractive
ENV LD_LIBRARY_PATH /usr/lib64

ADD ./treePL /usr/local/src/treePL

RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    g++ \
    libnlopt-dev \
    libnlopt0 \
    libcolpack-dev \
    make \
    libomp-dev \
    build-essential \
    autoconf \
    autotools-dev \
    automake \
    libtool \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    cd /usr/local/src/treePL/deps/ && \
    tar xvzf adol-c_git_saved.tar.gz && \
    cd /usr/local/src/treePL/deps/adol-c/ && \
    ./update_versions.sh && \
    ./configure --with-openmp-flag=-fopenmp --prefix=/usr && \
    make && \
    make install && \
    cd /usr/local/src/treePL/src && \
    ./configure && \
    make && \
    mkdir /input

CMD ["/usr/local/src/treePL/src/treePL"]