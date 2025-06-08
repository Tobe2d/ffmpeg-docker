FROM nvidia/cuda:12.1.0-cudnn8-devel-ubuntu20.04
LABEL description="Full-featured FFmpeg with NVIDIA, codecs, filters, and CUDA/NVENC support"

ARG DEBIAN_FRONTEND=noninteractive
ARG FFMPEG_VERSION=6.0.1

# Install all required packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential pkg-config wget curl git yasm nasm cmake \
    libtool libssl-dev zlib1g-dev libxml2-dev \
    libfreetype6-dev libfribidi-dev libfontconfig1-dev libass-dev \
    libaom-dev libx264-dev libx265-dev libvpx-dev \
    libmp3lame-dev libfdk-aac-dev libopus-dev libtwolame-dev libvorbis-dev libspeex-dev \
    libsoxr-dev librubberband-dev \
    libwebp-dev librsvg2-dev \
    libzmq3-dev libzvbi-dev frei0r-plugins-dev ladspa-sdk libcaca-dev \
    libpulse-dev \
    libgl1-mesa-dev libegl1-mesa-dev libglu1-mesa-dev libsdl2-dev \
    libvdpau-dev libva-dev libxv-dev libx11-dev libxext-dev \
    nvidia-cuda-toolkit \
    nvidia-cuda-dev \
    && rm -rf /var/lib/apt/lists/*

# Install ffnvcodec headers for NVENC
RUN git clone https://git.videolan.org/git/ffmpeg/nv-codec-headers.git && \
    cd nv-codec-headers && \
    make install && \
    cd .. && \
    rm -rf nv-codec-headers

# Add user
RUN useradd -ms /bin/bash ffmpeguser
USER ffmpeguser
WORKDIR /home/ffmpeguser

# Download and extract FFmpeg
RUN wget https://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.gz && \
    tar xzf ffmpeg-${FFMPEG_VERSION}.tar.gz

# Change to source directory
WORKDIR /home/ffmpeguser/ffmpeg-${FFMPEG_VERSION}

# Configure build
RUN ./configure \
    --prefix=/home/ffmpeguser/ffmpeg-build \
    --enable-gpl \
    --enable-nonfree \
    --enable-libx264 --enable-libx265 --enable-libvpx --enable-libfdk-aac \
    --enable-libmp3lame --enable-libopus --enable-libtwolame --enable-libvorbis \
    --enable-libspeex --enable-libsoxr --enable-librubberband \
    --enable-libfreetype --enable-libfribidi --enable-libfontconfig --enable-libass \
    --enable-libwebp --enable-librsvg --enable-libzmq \
    --enable-libzvbi --enable-frei0r --enable-ladspa --enable-libcaca \
    --enable-libpulse \
    --enable-nvenc --enable-cuda-nvcc --enable-cuvid \
    --enable-vdpau \
    --enable-vaapi \
    --extra-cflags=-I/usr/local/cuda/include \
    --extra-ldflags=-L/usr/local/cuda/lib64

# Compile
RUN make -j$(nproc)

# Install
USER root
RUN cd /home/ffmpeguser/ffmpeg-${FFMPEG_VERSION} && \
    make install && \
    rm -rf /home/ffmpeguser/ffmpeg-${FFMPEG_VERSION}* && \
    ldconfig

# Add to PATH
ENV PATH="/home/ffmpeguser/ffmpeg-build/bin:/usr/local/cuda/bin:$PATH" \
    LD_LIBRARY_PATH="/home/ffmpeguser/ffmpeg-build/lib:/usr/local/cuda/lib64:$LD_LIBRARY_PATH"