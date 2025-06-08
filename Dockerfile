FROM nvidia/cuda:12.1.1-cudnn8-devel-ubuntu20.04
LABEL description="Full-featured FFmpeg with NVIDIA NVENC/NVDEC support"

ARG DEBIAN_FRONTEND=noninteractive
ARG FFMPEG_VERSION=6.1

# Set environment variables for CUDA
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility,video
ENV PATH="/usr/local/cuda/bin:${PATH}"
ENV LD_LIBRARY_PATH="/usr/local/cuda/lib64:${LD_LIBRARY_PATH}"
ENV PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:/usr/lib/x86_64-linux-gnu/pkgconfig"

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    pkg-config \
    wget \
    curl \
    git \
    yasm \
    nasm \
    cmake \
    libtool \
    automake \
    autoconf \
    libssl-dev \
    zlib1g-dev \
    libxml2-dev \
    && rm -rf /var/lib/apt/lists/*

# Install media libraries
RUN apt-get update && apt-get install -y --no-install-recommends \
    libfreetype6-dev \
    libfribidi-dev \
    libfontconfig1-dev \
    libass-dev \
    libaom-dev \
    libx264-dev \
    libx265-dev \
    libvpx-dev \
    libmp3lame-dev \
    libfdk-aac-dev \
    libopus-dev \
    libtwolame-dev \
    libvorbis-dev \
    libspeex-dev \
    libsoxr-dev \
    librubberband-dev \
    libwebp-dev \
    librsvg2-dev \
    libzmq3-dev \
    libzvbi-dev \
    frei0r-plugins-dev \
    ladspa-sdk \
    libcaca-dev \
    libpulse-dev \
    && rm -rf /var/lib/apt/lists/*

# Install hardware acceleration libraries
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgl1-mesa-dev \
    libegl1-mesa-dev \
    libglu1-mesa-dev \
    libsdl2-dev \
    libvdpau-dev \
    libva-dev \
    libxv-dev \
    libx11-dev \
    libxext-dev \
    && rm -rf /var/lib/apt/lists/*

# Install NVIDIA codec headers - CRITICAL for NVENC support
RUN git clone https://git.videolan.org/git/ffmpeg/nv-codec-headers.git && \
    cd nv-codec-headers && \
    git checkout sdk/12.1 && \
    make install PREFIX=/usr/local && \
    cd .. && \
    rm -rf nv-codec-headers && \
    # Create additional symlinks for better detection
    ln -sf /usr/local/include/ffnvcodec /usr/include/ffnvcodec && \
    ldconfig

# Create user and setup workspace
RUN useradd -ms /bin/bash ffmpeguser
WORKDIR /tmp

# Download and extract FFmpeg (using newer version for better NVIDIA support)
RUN wget https://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.gz && \
    tar xzf ffmpeg-${FFMPEG_VERSION}.tar.gz && \
    rm ffmpeg-${FFMPEG_VERSION}.tar.gz

WORKDIR /tmp/ffmpeg-${FFMPEG_VERSION}

# Configure FFmpeg with NVENC support - single attempt with better paths
RUN ./configure \
    --prefix=/usr/local \
    --enable-gpl \
    --enable-nonfree \
    --enable-shared \
    --disable-static \
    --enable-libx264 \
    --enable-libx265 \
    --enable-libvpx \
    --enable-libfdk-aac \
    --enable-libmp3lame \
    --enable-libopus \
    --enable-libtwolame \
    --enable-libvorbis \
    --enable-libspeex \
    --enable-libsoxr \
    --enable-librubberband \
    --enable-libfreetype \
    --enable-libfribidi \
    --enable-libfontconfig \
    --enable-libass \
    --enable-libwebp \
    --enable-librsvg \
    --enable-libzmq \
    --enable-libzvbi \
    --enable-frei0r \
    --enable-ladspa \
    --enable-libcaca \
    --enable-libpulse \
    --enable-cuda-nvcc \
    --enable-nvenc \
    --enable-nvdec \
    --enable-cuvid \
    --enable-vdpau \
    --enable-vaapi \
    --extra-cflags="-I/usr/local/cuda/include -I/usr/local/include/ffnvcodec -I/usr/include/ffnvcodec" \
    --extra-ldflags="-L/usr/local/cuda/lib64 -L/usr/local/lib" \
    --extra-libs="-lpthread -lm -lz"

# Compile FFmpeg
RUN make -j$(nproc)

# Install FFmpeg
RUN make install && \
    ldconfig

# Clean up build files
RUN rm -rf /tmp/ffmpeg-${FFMPEG_VERSION}

# Update library cache
RUN echo "/usr/local/lib" > /etc/ld.so.conf.d/ffmpeg.conf && \
    echo "/usr/local/cuda/lib64" > /etc/ld.so.conf.d/cuda.conf && \
    ldconfig

# Set final environment variables
ENV PATH="/usr/local/bin:/usr/local/cuda/bin:${PATH}"
ENV LD_LIBRARY_PATH="/usr/local/lib:/usr/local/cuda/lib64:${LD_LIBRARY_PATH}"

# Switch to non-root user for runtime
USER ffmpeguser
WORKDIR /home/ffmpeguser

# Verify installation and show capabilities
RUN ffmpeg -version && \
    echo "=== Hardware Accelerators ===" && \
    ffmpeg -hwaccels && \
    echo "=== NVENC Encoders ===" && \
    ffmpeg -encoders | grep -i nvenc && \
    echo "=== NVDEC Decoders ===" && \
    ffmpeg -decoders | grep -E "(cuvid|h264|h265)" | head -5

# Default command
CMD ["/bin/bash"]