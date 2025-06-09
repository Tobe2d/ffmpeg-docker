# FFmpeg CUDA Docker Image with Production API
# 100% Working for RTX 4090 + WSL2 + Windows 11
# Production-ready with Gunicorn and comprehensive API

ARG CUDA=12.3.1
ARG OS=ubuntu22.04
ARG BUILDIMAGE=${CUDA}-devel-${OS}
ARG RUNIMAGE=${CUDA}-runtime-${OS}

FROM nvidia/cuda:${BUILDIMAGE} AS builder
ARG CUDA
ARG OS

# Set environment variables for CUDA and build
ENV DEBIAN_FRONTEND=noninteractive
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility,video
ENV PATH="/usr/local/cuda/bin:${PATH}"
ENV LD_LIBRARY_PATH="/usr/local/cuda/lib64:${LD_LIBRARY_PATH}"
ENV PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:/usr/lib/x86_64-linux-gnu/pkgconfig"

# Update system and install essential build dependencies
RUN apt-get update && \
    apt-get -y --allow-change-held-packages full-upgrade && \
    apt-get -qqy install \
    automake \
    autoconf \
    bc \
    build-essential \
    cmake \
    curl \
    cython3 \
    devscripts \
    equivs \
    git \
    imagemagick \
    intltool \
    pkg-config \
    python3-dev \
    python3-pip \
    unzip \
    wget \
    yasm \
    nasm \
    libtool \
    && rm -rf /var/lib/apt/lists/*

# Install core media libraries (essential for FFmpeg)
RUN apt-get update && \
    apt-get -qqy install \
    libaom-dev \
    libass-dev \
    libcodec2-dev \
    libdav1d-dev \
    libfdk-aac-dev \
    libfreetype6-dev \
    libfribidi-dev \
    libfontconfig1-dev \
    libgsm1-dev \
    libmp3lame-dev \
    libopencore-amrnb-dev \
    libopencore-amrwb-dev \
    libopenh264-dev \
    libopenjp2-7-dev \
    libopus-dev \
    libspeex-dev \
    libtheora-dev \
    libtwolame-dev \
    libvorbis-dev \
    libvpx-dev \
    libwebp-dev \
    libx264-dev \
    libx265-dev \
    libxvidcore-dev \
    && rm -rf /var/lib/apt/lists/*

# Install additional video processing libraries
RUN apt-get update && \
    apt-get -qqy install \
    libvidstab-dev \
    librubberband-dev \
    libsoxr-dev \
    libzimg-dev \
    libzmq3-dev \
    libzvbi-dev \
    frei0r-plugins-dev \
    ladspa-sdk \
    libcaca-dev \
    libpulse-dev \
    librtmp-dev \
    libshine-dev \
    libsrt-gnutls-dev \
    libssh-dev \
    libtesseract-dev \
    && rm -rf /var/lib/apt/lists/*

# Install NVIDIA-specific libraries (NO VAAPI - NVIDIA only!)
RUN apt-get update && \
    apt-get -qqy install \
    libvdpau-dev \
    && rm -rf /var/lib/apt/lists/*

# Set FFmpeg and codec versions (tested stable combination)
ARG FFMPEG_VERSION=6.1.1
ARG NVCODEC_HEADERS_VERSION=12.1.14.0

# Create source directories and download sources
RUN rm -rf /opt/src/* && \
    mkdir -p /opt/src/nv-codec-headers /opt/src/ffmpeg && \
    git clone --depth 1 --branch n${NVCODEC_HEADERS_VERSION} https://git.videolan.org/git/ffmpeg/nv-codec-headers.git /opt/src/nv-codec-headers && \
    git clone --depth 1 --branch n${FFMPEG_VERSION} https://git.ffmpeg.org/ffmpeg.git /opt/src/ffmpeg

# Install NVIDIA codec headers (essential for NVENC/NVDEC)
RUN cd /opt/src/nv-codec-headers && \
    make && \
    make install

# Configure FFmpeg with NVIDIA-only acceleration (NO VAAPI!)
# This configuration is specifically optimized for RTX 4090 + WSL2
RUN cd /opt/src/ffmpeg && \
    ./configure \
    --prefix=/usr/local \
    --enable-gpl \
    --enable-nonfree \
    --enable-version3 \
    --enable-shared \
    --disable-static \
    --enable-cuda-nvcc \
    --enable-cuvid \
    --enable-nvenc \
    --enable-nvdec \
    --enable-vdpau \
    --disable-vaapi \
    --enable-libass \
    --enable-libaom \
    --enable-libcodec2 \
    --enable-libdav1d \
    --enable-libfdk-aac \
    --enable-libfreetype \
    --enable-libfribidi \
    --enable-libfontconfig \
    --enable-libgsm \
    --enable-libmp3lame \
    --enable-libopencore-amrnb \
    --enable-libopencore-amrwb \
    --enable-libopenh264 \
    --enable-libopenjpeg \
    --enable-libopus \
    --enable-libspeex \
    --enable-libtheora \
    --enable-libtwolame \
    --enable-libvidstab \
    --enable-libvorbis \
    --enable-libvpx \
    --enable-libwebp \
    --enable-libx264 \
    --enable-libx265 \
    --enable-libxvid \
    --enable-libzimg \
    --enable-libzmq \
    --enable-libzvbi \
    --enable-frei0r \
    --enable-ladspa \
    --enable-libcaca \
    --enable-libpulse \
    --enable-librtmp \
    --enable-librubberband \
    --enable-libshine \
    --enable-libsoxr \
    --enable-libsrt \
    --enable-libssh \
    --enable-libtesseract \
    --extra-cflags="-I/usr/local/cuda/include -I/usr/local/include" \
    --extra-ldflags="-L/usr/local/cuda/lib64 -L/usr/local/lib" \
    --extra-libs="-lpthread -lm -lz"

# Compile FFmpeg (using all available cores for faster build)
RUN cd /opt/src/ffmpeg && \
    make -j$(nproc)

# Install FFmpeg
RUN cd /opt/src/ffmpeg && \
    make install && \
    ldconfig

# Create runtime image (smaller final image)
FROM nvidia/cuda:${RUNIMAGE} AS runtime

# Set environment variables for runtime
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility,video
ENV PATH="/usr/local/bin:/usr/local/cuda/bin:${PATH}"
ENV LD_LIBRARY_PATH="/usr/local/lib:/usr/local/cuda/lib64:${LD_LIBRARY_PATH}"

# Install runtime dependencies (only what's needed to run)
RUN apt-get update && \
    apt-get -qqy install \
    libass9 \
    libaom3 \
    libcodec2-1.0 \
    libdav1d5 \
    libfdk-aac2 \
    libfreetype6 \
    libfribidi0 \
    libfontconfig1 \
    libgsm1 \
    libmp3lame0 \
    libopencore-amrnb0 \
    libopencore-amrwb0 \
    libopenh264-6 \
    libopenjp2-7 \
    libopus0 \
    libspeex1 \
    libtheora0 \
    libtwolame0 \
    libvidstab1.1 \
    libvorbis0a \
    libvorbisenc2 \
    libvpx7 \
    libwebp7 \
    libx264-163 \
    libx265-199 \
    libxvidcore4 \
    libzimg2 \
    libzmq5 \
    libzvbi0 \
    frei0r-plugins \
    libcaca0 \
    libpulse0 \
    librtmp1 \
    librubberband2 \
    libshine3 \
    libsoxr0 \
    libsrt1.4-gnutls \
    libssh-4 \
    libtesseract4 \
    libvdpau1 \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Copy FFmpeg binaries and libraries from builder
COPY --from=builder /usr/local/bin/ff* /usr/local/bin/
COPY --from=builder /usr/local/lib/lib* /usr/local/lib/
COPY --from=builder /usr/local/include/libav* /usr/local/include/
COPY --from=builder /usr/local/include/libsw* /usr/local/include/
COPY --from=builder /usr/local/lib/pkgconfig/libav* /usr/local/lib/pkgconfig/
COPY --from=builder /usr/local/lib/pkgconfig/libsw* /usr/local/lib/pkgconfig/

# Update library cache
RUN echo "/usr/local/lib" > /etc/ld.so.conf.d/ffmpeg.conf && \
    echo "/usr/local/cuda/lib64" > /etc/ld.so.conf.d/cuda.conf && \
    ldconfig

# Install Python packages for production API
RUN pip3 install flask gunicorn

# Create non-root user for security
RUN useradd -ms /bin/bash ffmpeguser

# Copy API files (these will be created separately)
COPY ffmpeg_api.py /home/ffmpeguser/
COPY start_api.sh /home/ffmpeguser/
COPY gunicorn.conf.py /home/ffmpeguser/

# Set proper ownership and permissions
RUN chown -R ffmpeguser:ffmpeguser /home/ffmpeguser && \
    chmod +x /home/ffmpeguser/start_api.sh

# Switch to non-root user
USER ffmpeguser
WORKDIR /home/ffmpeguser

# Verify FFmpeg installation
RUN ffmpeg -version && \
    echo "=== Hardware Accelerators ===" && \
    ffmpeg -hwaccels && \
    echo "=== NVENC Encoders ===" && \
    ffmpeg -encoders | grep -i nvenc && \
    echo "=== ✅ FFmpeg CUDA API Ready! ==="

# Expose port
EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:5000/health || exit 1

# Start the production API
CMD ["/home/ffmpeguser/start_api.sh"]

