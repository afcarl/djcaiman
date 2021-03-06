FROM datajoint/datajoint:latest

MAINTAINER Edgar Fabian Sinz

WORKDIR /data

# install tools to compile
RUN \
  apt-get update && \
  apt-get install -y -q \
    build-essential && \
  apt-get update && \
  apt-get install  --fix-missing -y -q \
    autoconf \
    automake \
    libtool \
    octave \
    wget \
    bzip2 \
    git

RUN apt-get install -y build-essential cmake pkg-config libjpeg8-dev libtiff5-dev libjasper-dev \
    libpng12-dev libavcodec-dev libavformat-dev libswscale-dev libv4l-dev libxvidcore-dev libx264-dev \
    libgtk-3-dev libatlas-base-dev ffmpeg

RUN git clone https://github.com/Itseez/opencv.git && \
    cd opencv && git checkout 3.1.0 && \
    cd .. && git clone https://github.com/Itseez/opencv_contrib.git && \
    cd opencv_contrib && git checkout 3.1.0 && \
    cd ../opencv && mkdir build && cd build && \
    cmake -D CMAKE_BUILD_TYPE=RELEASE \
  	    -D WITH_CUDA=ON \
        -D CMAKE_INSTALL_PREFIX=/usr/local \
        -D OPENCV_EXTRA_MODULES_PATH=/data/opencv_contrib/modules \
        -D BUILD_EXAMPLES=ON .. && \
    make -j4 && \
    make install && \
    ldconfig && \
    rm -rf /data/opencv /data/opencv_contrib && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    apt-get clean


# --- install HDF5 reader and nose
RUN pip3 install h5py nose

# --- install CaImAn
RUN apt-get update -y -q && \
    apt-get install -y software-properties-common && \
    wget -O - http://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - && \
    apt-add-repository "deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial-3.9 main" && \
    apt-get update -y -q && \
    apt-get install -y clang-3.9 lldb-3.9 && \
    apt-get install -y libc6-i386  libsuitesparse-dev && \
    export LLVM_CONFIG=/usr/lib/llvm-3.9/bin/llvm-config && \ 
    git clone --recursive https://github.com/simonsfoundation/CaImAn.git && \
    pip3 install cython scikit-image ipyparallel psutil numba && \
    pip3 install -r CaImAn/requirements_pip.txt && \
    pip3 install git+https://github.com/j-friedrich/OASIS.git

RUN grep -vwE "install_requires=" CaImAn/setup.py > tmp && mv tmp CaImAn/setup.py &&\
    pip3 install -e CaImAn/

ENTRYPOINT ["/bin/bash"]
