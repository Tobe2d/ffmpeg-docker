# FFmpeg + NVIDIA/CUDA GPU-Enabled Docker Container

A powerful, GPU-accelerated Docker container for [FFmpeg](https://ffmpeg.org/) built with full codec, subtitle, and filter support using the official [NVIDIA CUDA](https://hub.docker.com/r/nvidia/cuda) runtime base image. Supports H.264/H.265 NVENC encoding, AV1, text rendering, filters, and much more.

## Docker Image Overview

- Based on: `nvidia/cuda:12.1.0-cudnn8-runtime-ubuntu20.04`
- Includes: FFmpeg 6.0.1 built from source
- GPU Features: NVENC, CUVID, CUDA acceleration
- Extras: Subtitle rendering, audio/video filters, effects, overlay, format conversion, AV1 support

---

## How to Get the Image

Clone the repository:

```bash
git clone https://github.com/Tobe2d/ffmpeg-docker.git
cd ffmpeg-docker
```

Build the image locally:

```bash
docker build -t tobe2d/ffmpeg-nvidia:full .
```

---

## How to Run

Run the container with full GPU access:

```bash
docker run --rm --gpus all -it tobe2d/ffmpeg-nvidia:full
```

You can now use `ffmpeg` with all hardware-accelerated features enabled.

---

## Test NVIDIA Support

After entering the container, check:

```bash
nvidia-smi
which ffmpeg
ffmpeg -codecs | grep -E 'nvenc|cuvid'
```

You should see support for encoders like `h264_nvenc`, `hevc_nvenc`, and decoders like `h264_cuvid`.

---

## Example Command: Transcode with NVENC

```bash
ffmpeg \
  -hwaccel cuvid \
  -c:v h264_cuvid \
  -i input.mp4 \
  -c:v hevc_nvenc \
  -cq:v 19 \
  -preset p4 \
  output.mp4
```

---

## Key Build Configuration

FFmpeg is built with the following flags for full multimedia capability:

- `--enable-gpl`, `--enable-nonfree`
- `--enable-nvenc`, `--enable-cuvid`, `--enable-cuda`
- Subtitle/Text rendering: `--enable-libass`, `--enable-libfreetype`, `--enable-libfribidi`
- Audio codecs: `libfdk-aac`, `libmp3lame`, `libopus`, `libtwolame`, `libvorbis`, `libspeex`
- Video codecs: `libx264`, `libx265`, `libvpx`, `libaom`, `libsvtav1`
- Filters and effects: `frei0r`, `ladspa`, `libvmaf`, `libzmq`, `libsoxr`, `libcaca`, `libsdl2`

---

## Supported Use Cases

- Convert videos between formats
- Add subtitles and overlay text
- Transcode with NVIDIA GPU acceleration (NVENC, CUVID)
- Apply filters and effects (color, crop, fade, drawtext, etc.)
- Extract or merge audio/video streams
- Support for AV1, H.265, AAC, MP3, Opus, and more

---

## References

- [FFmpeg Documentation](https://ffmpeg.org/documentation.html)
- [NVIDIA Video Codec SDK](https://developer.nvidia.com/nvidia-video-codec-sdk)
- [NVIDIA Docker Hub](https://hub.docker.com/r/nvidia/cuda)