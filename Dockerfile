FROM continuumio/miniconda3:4.5.4

# Dumb init
RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64
RUN chmod +x /usr/local/bin/dumb-init

USER root
RUN apt-get update \
  && apt-get install -yq --no-install-recommends \
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
  
  # build netcdf with gcc and g-fortran

ENV CC=gcc
ENV FC=gfortran

# set library location
ENV PREFIXDIR=/usr/local

WORKDIR /

## get zlib
ENV ZLIB_VERSION=zlib-1.2.11
RUN wget https://zlib.net/${ZLIB_VERSION}.tar.gz && tar -xvzf ${ZLIB_VERSION}.tar.gz
RUN cd ${ZLIB_VERSION} \
    && ./configure --prefix=${PREFIXDIR} \
    && make check \
    && make install
WORKDIR /
RUN rm -rf ${ZLIB_VERSION}.tar.gz ${ZLIB_VERSION}

## get hdf5-1.8
ENV HDF518_VERSION=hdf5-1.8.21
RUN wget https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8/${HDF518_VERSION}/src/${HDF518_VERSION}.tar.gz && tar -xvzf ${HDF518_VERSION}.tar.gz
RUN cd ${HDF518_VERSION} \
    && ./configure --with-zlib=${PREFIXDIR} --prefix=${PREFIXDIR} --enable-hl \
    && make \
    && make check \
    && make install
WORKDIR /
RUN rm -rf ${HDF518_VERSION}.tar.gz ${HDF518_VERSION}

## get hdf5-1.10
ENV HDF5110_VERSION=hdf5-1.10.2
RUN wget https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.10/${HDF5110_VERSION}/src/${HDF5110_VERSION}.tar.gz && tar -xvzf ${HDF5110_VERSION}.tar.gz
RUN cd ${HDF5110_VERSION} \
    && ./configure --with-zlib=${PREFIXDIR} --prefix=${PREFIXDIR} --enable-hl --enable-shared \
    && make check \
    && make install
WORKDIR /
RUN rm -rf ${HDF5110_VERSION}.tar.gz ${HDF5110_VERSION}

## get netcdf-c
ENV NETCDFC_VERSION=4.6.1
RUN wget https://github.com/Unidata/netcdf-c/archive/v${NETCDFC_VERSION}.tar.gz && tar -xvzf v${NETCDFC_VERSION}.tar.gz
ENV LD_LIBRARY_PATH=${PREFIXDIR}/lib
RUN cd netcdf-c-${NETCDFC_VERSION} \
    && CPPFLAGS=-I${PREFIXDIR}/include LDFLAGS=-L${PREFIXDIR}/lib ./configure --prefix=${PREFIXDIR} --enable-netcdf-4 --enable-shared --enable-dap \
    && make check \
    && make install
WORKDIR /
RUN rm -rf v${NETCDFC_VERSION}.tar.gz netcdf-c-${NETCDFC_VERSION}

## get netcdf-fortran
ENV NETCDFFORTRAN_VERSION=4.4.4
RUN wget https://github.com/Unidata/netcdf-fortran/archive/v${NETCDFFORTRAN_VERSION}.tar.gz && tar -xvzf v${NETCDFFORTRAN_VERSION}.tar.gz
RUN cd netcdf-fortran-${NETCDFFORTRAN_VERSION} \
    && CPPFLAGS=-I${PREFIXDIR}/include LDFLAGS=-L${PREFIXDIR}/lib ./configure --prefix=${PREFIXDIR} \
    && make check \
    && make install
WORKDIR /
RUN rm -rf v${NETCDFFORTRAN_VERSION}.tar.gz netcdf-fortran-${NETCDFFORTRAN_VERSION}

ENTRYPOINT [ "/usr/bin/tini", "--" ]
CMD [ "/bin/bash" ]
