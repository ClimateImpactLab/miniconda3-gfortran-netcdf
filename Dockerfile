FROM continuumio/miniconda3:4.6.14

# Dumb init
RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64
RUN chmod +x /usr/local/bin/dumb-init

USER root

RUN apt-get update
RUN apt-get install -yq --no-install-recommends apt-utils
RUN apt-get install -yq --no-install-recommends \
  build-essential \
  curl \
  fuse \
  gfortran \
  g++ \
  git \
  gnupg \
  gnupg2 \
  keychain \
  libcurl4-openssl-dev \
  libfuse-dev \
  liblapack-dev \
  libssl-dev \
  locate \
  lsb-release \
  make \
  m4 \
  nano \
  rsync \
  tzdata \
  unzip \
  vim \
  zip

ENV CC=gcc
ENV FC=gfortran

RUN apt-get install -yq --no-install-recommends \
  libnetcdf-dev libnetcdff-dev

ENTRYPOINT [ "/usr/bin/tini", "--" ]
CMD [ "/bin/bash" ]
