# FFmpeg + NVIDIA/CUDA GPU-Enabled Docker Container

A powerful, GPU-accelerated Docker container for [FFmpeg](https://ffmpeg.org/) built with full codec, subtitle, and filter support using the official [NVIDIA CUDA](https://hub.docker.com/r/nvidia/cuda) runtime base image. Supports H.264/H.265 NVENC encoding, AV1, text rendering, filters, and much more.

## Docker Image Overview

- Based on: `nvidia/cuda:12.1.0-cudnn8-runtime-ubuntu20.04`
- Includes: FFmpeg 6.0.1 built from source
- GPU Features: NVENC, CUVID, CUDA acceleration
- Extras: Subtitle rendering, audio/video filters, effects, overlay, format conversion, AV1 support

---

# Full-Featured FFmpeg with NVIDIA GPU Support

This Docker image builds a **full-featured FFmpeg** environment with **NVIDIA GPU acceleration**, supporting text rendering, audio/video filters, subtitle styling, transitions, encoding formats, and advanced effects.

## Features

-  Hardware acceleration via CUDA/NVENC
-  Text rendering with `drawtext`, `libass`, `freetype`, and Unicode/Arabic support
-  Burn-in subtitles from `.ass`, `.srt`, and `.ssa` files
-  Visual effects, fades, transitions (`xfade`, `fade`)
-  Concatenation filters for merging multiple videos
-  Support for multiple codecs: H.264, H.265, AV1 (via `libaom`), MP3, AAC, Opus, Vorbis
-  Audio processing with `rubberband`, `soxr`, `ladspa`
-  Overlaying images and filters (logos, watermarks, etc.)
-  Compiles FFmpeg 6.0.1 from source for maximum compatibility

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
---

## Example Use Cases

### Add Styled Text
```bash
ffmpeg -i video.mp4 -vf "drawtext=text='Hello World':fontsize=40:fontcolor=white:x=100:y=100" output.mp4
```

### Burn Subtitles
```bash
ffmpeg -i video.mp4 -vf "subtitles=subs.ass" output.mp4
```
Concatenate Videos
```bash
ffmpeg -i part1.mp4 -i part2.mp4 -filter_complex "[0:v:0][0:a:0][1:v:0][1:a:0] concat=n=2:v=1:a=1 [v][a]" -map "[v]" -map "[a]" merged.mp4
```

### Add Fade to Black
```bash
ffmpeg -i input.mp4 -vf "fade=t=out:st=5:d=2" output.mp4
```

---

## File Structure

Only one Dockerfile is included (no Jupyter version):

- `Dockerfile`: Main build file for full-featured FFmpeg + CUDA

---

## Notes

- Make sure your host has the **NVIDIA Container Toolkit** installed.
- Compatible with **Ubuntu 20.04** base and FFmpeg 6.0.1
- You can customize FFmpeg versions by changing the `ARG FFMPEG_VERSION`

---

## License

MIT License – use freely, modify, and contribute back if helpful!

---
Maintained by [Tobe2d](https://github.com/Tobe2d)

---

## References

- [FFmpeg Documentation](https://ffmpeg.org/documentation.html)
- [NVIDIA Video Codec SDK](https://developer.nvidia.com/nvidia-video-codec-sdk)
- [NVIDIA Docker Hub](https://hub.docker.com/r/nvidia/cuda)