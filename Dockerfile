# using same container as jupyter/base-notebook:python-3.7.3
FROM ubuntu:bionic-20180526@sha256:c8c275751219dadad8fa56b3ac41ca6cb22219ff117ca98fe82b42f24e1ba64e

USER root


###########
# adapted from continuumio/miniconda3:4.6.14
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PATH /opt/conda/bin:$PATH

RUN apt-get update --fix-missing && \
    apt upgrade --yes && \
    apt-get install -yq --no-install-recommends apt-utils \
    wget bzip2 ca-certificates curl git

RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-4.6.14-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda clean -tipsy && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

ENV TINI_VERSION v0.16.1
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini
###########

# Dumb init
RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64
RUN chmod +x /usr/local/bin/dumb-init

# install other apt-get packages

RUN DEBIAN_FRONTEND=noninteractive && \
  apt-get install -yq --no-install-recommends \
  build-essential \
  fuse \
  gfortran \
  g++ \
  gnupg \
  gnupg2 \
  keychain \
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

RUN apt-get clean && \
rm -rf /var/lib/apt/lists/*

ENTRYPOINT [ "/usr/bin/tini", "--" ]
CMD [ "/bin/bash" ]
