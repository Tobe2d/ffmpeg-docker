FROM nvidia/cuda:12.1.0-cudnn8-runtime-ubuntu20.04
LABEL description="Full-featured FFmpeg with NVIDIA, text rendering, audio filters, and codecs"

ARG DEBIAN_FRONTEND=noninteractive
ARG FFMPEG_VERSION=6.0.1

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential pkg-config wget curl git yasm nasm cmake \
    libtool libssl-dev zlib1g-dev libxml2-dev \
    libfreetype6-dev libfribidi-dev libfontconfig1-dev libass-dev \
    libaom-dev libx264-dev libx265-dev libvpx-dev \
    libmp3lame-dev libfdk-aac-dev libopus-dev libtwolame-dev libvorbis-dev libspeex-dev \
    libsoxr-dev librubberband-dev \
    libopenjp2-7-dev libwebp-dev librsvg2-dev \
    libzmq3-dev libzvbi-dev frei0r-plugins-dev ladspa-sdk libcaca-dev \
    libgnutls28-dev libpulse-dev libsdl2-dev \
    && rm -rf /var/lib/apt/lists/*

# Add user (optional)
RUN useradd -ms /bin/bash ffmpeguser
USER ffmpeguser
WORKDIR /home/ffmpeguser

# Download and compile FFmpeg
RUN wget https://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.gz && \
    tar xzf ffmpeg-${FFMPEG_VERSION}.tar.gz && \
    cd ffmpeg-${FFMPEG_VERSION} && \
    ./configure \
        --prefix=/usr/local \
        --enable-gpl \
        --enable-nonfree \
        --enable-libx264 --enable-libx265 --enable-libvpx --enable-libfdk-aac \
        --enable-libmp3lame --enable-libopus --enable-libtwolame --enable-libvorbis \
        --enable-libspeex --enable-libsoxr --enable-librubberband \
        --enable-libfreetype --enable-libfribidi --enable-libfontconfig --enable-libass \
        --enable-libopenjp2 --enable-libwebp --enable-librsvg --enable-libzmq \
        --enable-libzvbi --enable-frei0r --enable-ladspa --enable-libcaca \
        --enable-libpulse --enable-libsdl2 \
        --enable-nvenc --enable-cuda --enable-cuvid \
        --enable-libgnutls --enable-opengl \
    && make -j$(nproc) && sudo make install && \
    cd .. && rm -rf ffmpeg-${FFMPEG_VERSION}*

# Switch back to root to finalize
USER root