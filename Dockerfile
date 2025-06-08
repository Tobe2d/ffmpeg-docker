# Improved FFmpeg CUDA Docker Image
# Based on proven working solution with CUDA 12.3.1 and FFmpeg 6.1.1

ARG CUDA=12.3.1
ARG OS=ubuntu22.04
ARG BUILDIMAGE=${CUDA}-devel-${OS}
ARG RUNIMAGE=${CUDA}-runtime-${OS}

FROM nvidia/cuda:${BUILDIMAGE} AS builder
ARG CUDA
ARG OS

# Set environment variables
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

# Install comprehensive media libraries for full FFmpeg functionality
RUN apt-get update && \
    apt-get -qqy install \
    flite1-dev \
    frei0r-plugins-dev \
    ladspa-sdk \
    libaom-dev \
    libass-dev \
    libaribb24-dev \
    libdavs2-dev \
    libsctp-dev \
    freeglut3-dev \
    libavc1394-dev \
    libavutil-dev \
    libavcodec-dev \
    libswscale-dev \
    libbluray-dev \
    libbs2b-dev \
    libc6 \
    libc6-dev \
    libcaca-dev \
    libcdio-dev \
    libcdio-paranoia-dev \
    libcdparanoia-dev \
    libchromaprint-dev \
    libcodec2-dev \
    libdav1d-dev \
    libdc1394-dev \
    libdrm-dev \
    libfdk-aac-dev \
    libgcrypt20-dev \
    libgles2-mesa-dev \
    libgme-dev \
    libgnutls28-dev \
    libgsm1-dev \
    libiec16022-dev \
    libiec61883-dev \
    libjack-dev \
    liblensfun-dev \
    liblilv-dev \
    libmfx-dev \
    libopencore-amrnb-dev \
    libopencore-amrwb-dev \
    libopenh264-dev \
    libopenmpt-modplug-dev \
    libplacebo-dev \
    libmp3lame-dev \
    libmysofa-dev \
    libnettle8 \
    libnuma-dev \
    libnuma1 \
    libomxil-bellagio-dev \
    libopenal-dev \
    libopengl-dev \
    libopenjp2-7-dev \
    libopenmpt-dev \
    libopus-dev \
    libpocketsphinx-dev \
    libpulse-dev \
    librabbitmq-dev \
    librsvg2-dev \
    librtmp-dev \
    librubberband-dev \
    libsdl2-gfx-dev \
    libshine-dev \
    libsmbclient-dev \
    libsnappy-dev \
    libsoxr-dev \
    libspeex-dev \
    libsrt-gnutls-dev \
    libssh-dev \
    libtesseract-dev \
    libtheora-dev \
    libtwolame-dev \
    libunistring-dev \
    libvidstab-dev \
    libvdpau-dev \
    libvo-amrwbenc-dev \
    libvpx-dev \
    libwebp-dev \
    libx264-dev \
    libx265-dev \
    libxavs2-dev \
    libxcb-shape0-dev \
    libxcb-xfixes0-dev \
    libxvidcore-dev \
    libzimg-dev \
    libzmq3-dev \
    libzvbi-dev \
    lzip \
    samba-dev \
    && rm -rf /var/lib/apt/lists/*

# Install additional libraries for text rendering and effects
RUN apt-get update && \
    apt-get -qqy install \
    libfreetype6-dev \
    libfribidi-dev \
    libfontconfig1-dev \
    && rm -rf /var/lib/apt/lists/*

# Set FFmpeg and codec versions
ARG FFMPEG_VERSION=6.1.1
ARG NVCODEC_HEADERS_VERSION=12.1.14.0
ARG VAPOURSYNTH_VERSION=63
ARG AVISYNTHPLUS_VERSION=3.7.3

# Create source directories and download sources
RUN rm -rf /opt/src/* && \
    mkdir -p /opt/src/nv-codec-headers /opt/src/ffmpeg /opt/src/vapoursynth && \
    git clone --depth 1 --branch n${NVCODEC_HEADERS_VERSION} https://git.videolan.org/git/ffmpeg/nv-codec-headers.git /opt/src/nv-codec-headers && \
    git clone --depth 1 --branch n${FFMPEG_VERSION} https://git.ffmpeg.org/ffmpeg.git /opt/src/ffmpeg && \
    git clone --depth 1 --branch R${VAPOURSYNTH_VERSION} https://github.com/vapoursynth/vapoursynth.git /opt/src/vapoursynth && \
    curl -L https://github.com/AviSynth/AviSynthPlus/archive/refs/tags/v${AVISYNTHPLUS_VERSION}.tar.gz | tar -xz -C /opt/src

# Install NVIDIA codec headers
RUN cd /opt/src/nv-codec-headers && \
    make && \
    make install

# Install VapourSynth
RUN cd /opt/src/vapoursynth && \
    pip3 install -r ./python-requirements.txt && \
    ./autogen.sh && \
    LIBGNUTLS_CFLAGS=-I/usr/include/gnutls ./configure --prefix=/usr && \
    make -j$(nproc) && \
    make install

# Install AviSynth+
RUN cd /opt/src/AviSynthPlus-${AVISYNTHPLUS_VERSION} && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_INSTALL_PREFIX=/usr .. && \
    make -j$(nproc) && \
    make install

# Configure and build FFmpeg with comprehensive features
RUN cd /opt/src/ffmpeg && \
    ./configure \
    --prefix=/usr/local \
    --enable-gpl \
    --enable-nonfree \
    --enable-shared \
    --disable-static \
    --enable-avisynth \
    --enable-chromaprint \
    --enable-cuda-nvcc \
    --enable-cuvid \
    --enable-nvenc \
    --enable-nvdec \
    --enable-vdpau \
    --enable-vaapi \
    --enable-libass \
    --enable-libaom \
    --enable-libaribb24 \
    --enable-libcodec2 \
    --enable-libdav1d \
    --enable-libdavs2 \
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
    --enable-librsvg \
    --enable-libspeex \
    --enable-libtheora \
    --enable-libtwolame \
    --enable-libvidstab \
    --enable-libvorbis \
    --enable-libvpx \
    --enable-libwebp \
    --enable-libx264 \
    --enable-libx265 \
    --enable-libxavs2 \
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

# Compile FFmpeg
RUN cd /opt/src/ffmpeg && \
    make -j$(nproc)

# Install FFmpeg
RUN cd /opt/src/ffmpeg && \
    make install && \
    ldconfig

# Create runtime image
FROM nvidia/cuda:${RUNIMAGE} AS runtime

# Set environment variables for runtime
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility,video
ENV PATH="/usr/local/bin:/usr/local/cuda/bin:${PATH}"
ENV LD_LIBRARY_PATH="/usr/local/lib:/usr/local/cuda/lib64:${LD_LIBRARY_PATH}"

# Install runtime dependencies
RUN apt-get update && \
    apt-get -qqy install \
    libass9 \
    libaom3 \
    libaribb24-0 \
    libcodec2-1.0 \
    libdav1d5 \
    libdavs2-16 \
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
    librsvg2-2 \
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
    libxavs2-13 \
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

# Copy additional libraries
COPY --from=builder /usr/lib/x86_64-linux-gnu/libavisynth* /usr/lib/x86_64-linux-gnu/
COPY --from=builder /usr/lib/libvapoursynth* /usr/lib/

# Update library cache
RUN echo "/usr/local/lib" > /etc/ld.so.conf.d/ffmpeg.conf && \
    echo "/usr/local/cuda/lib64" > /etc/ld.so.conf.d/cuda.conf && \
    ldconfig

# Create non-root user
RUN useradd -ms /bin/bash ffmpeguser
USER ffmpeguser
WORKDIR /home/ffmpeguser

# Verify installation
RUN ffmpeg -version && \
    echo "=== Hardware Accelerators ===" && \
    ffmpeg -hwaccels && \
    echo "=== NVENC Encoders ===" && \
    ffmpeg -encoders | grep -i nvenc && \
    echo "=== NVDEC Decoders ===" && \
    ffmpeg -decoders | grep -E "(cuvid|h264|h265)" | head -5 && \
    echo "=== Available Filters ===" && \
    ffmpeg -filters | grep -E "(scale_cuda|overlay_cuda|text|drawtext)" && \
    echo "=== Installation Complete ==="

# Default command
CMD ["/bin/bash"]

