FROM nvidia/cuda:12.1.0-cudnn8-runtime-ubuntu20.04
LABEL description="Full-featured FFmpeg with NVIDIA, text rendering, audio filters, and codecs"

ARG DEBIAN_FRONTEND=noninteractive
ARG FFMPEG_VERSION="6.0.1"

# Install FFmpeg build dependencies and popular libraries
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential pkg-config wget curl git yasm nasm cmake \
    libtool libssl-dev zlib1g-dev libxml2-dev \
    libfreetype6-dev libfribidi-dev libfontconfig1-dev libass-dev \
    libaom-dev libx264-dev libx265-dev libvpx-dev \
    libmp3lame-dev libfdk-aac-dev libopus-dev libtwolame-dev libvorbis-dev libspeex-dev \
    libsoxr-dev librubberband-dev \
    libopenjp2-7-dev libwebp-dev librsvg2-dev \
    libzmq3-dev libzvbi-dev \
    frei0r-plugins-dev ladspa-sdk libcaca-dev \
    libgnutls28-dev libpulse-dev libsdl2-dev \
    && rm -rf /var/lib/apt/lists/*

# Build FFmpeg from source
RUN wget https://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.gz && \
    tar xzf ffmpeg-${FFMPEG_VERSION}.tar.gz && \
    cd ffmpeg-${FFMPEG_VERSION} && \
    ./configure \
        --prefix=/usr/local/ffmpeg \
        --pkg-config-flags="--static" \
        --extra-cflags="-I/usr/local/cuda/include" \
        --extra-ldflags="-L/usr/local/cuda/lib64" \
        --extra-libs="-lpthread -lm" \
        --bindir=/usr/local/bin \
        --enable-gpl \
        --enable-version3 \
        --enable-nonfree \
        --enable-libx264 \
        --enable-libx265 \
        --enable-libvpx \
        --enable-libmp3lame \
        --enable-libfdk-aac \
        --enable-libopus \
        --enable-libass \
        --enable-libaom \
        --enable-libsvtav1 \
        --enable-libsoxr \
        --enable-libfreetype \
        --enable-libfontconfig \
        --enable-libfribidi \
        --enable-librubberband \
        --enable-libtwolame \
        --enable-libvorbis \
        --enable-libspeex \
        --enable-libopenjpeg \
        --enable-libwebp \
        --enable-librsvg \
        --enable-libzvbi \
        --enable-libzmq \
        --enable-libvmaf \
        --enable-frei0r \
        --enable-ladspa \
        --enable-libcaca \
        --enable-sdl2 \
        --enable-gnutls \
        --enable-nvenc \
        --enable-cuda \
        --enable-cuvid \
        --enable-opengl \
        --enable-pic \
    && make -j$(nproc) && \
    make install && \
    cd .. && rm -rf ffmpeg-${FFMPEG_VERSION}*

CMD ["bash"]
