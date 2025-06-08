#!/bin/bash

# 100% Working FFmpeg CUDA Build Script
# Optimized for RTX 4090 + Windows 11 + Docker Desktop + WSL2

set -e

echo "🚀 Building 100% Working FFmpeg CUDA Docker Image"
echo "Optimized for RTX 4090 + Windows 11 + Docker Desktop + WSL2"
echo "=================================================="
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker Desktop first:"
    echo "   https://docs.docker.com/desktop/install/windows-install/"
    exit 1
fi

# Check if we're in WSL2
if ! grep -q microsoft /proc/version; then
    echo "⚠️  Warning: This script is optimized for WSL2 environment"
    echo "   Make sure you're running this in WSL2 (Ubuntu)"
fi

# Check if NVIDIA GPU is accessible
if ! command -v nvidia-smi &> /dev/null; then
    echo "❌ nvidia-smi not found. Please ensure:"
    echo "   1. NVIDIA drivers are installed on Windows"
    echo "   2. Docker Desktop has GPU support enabled"
    echo "   3. You're running in WSL2"
    exit 1
fi

echo "🔍 Checking GPU status..."
nvidia-smi --query-gpu=name,driver_version,cuda_version --format=csv,noheader,nounits

echo ""
echo "🔨 Starting Docker build (this will take 30-60 minutes)..."
echo "Key optimizations for your setup:"
echo "  ✅ VAAPI disabled (not needed for NVIDIA RTX 4090)"
echo "  ✅ NVENC/NVDEC enabled for hardware acceleration"
echo "  ✅ CUDA 12.3.1 + FFmpeg 6.1.1 (stable combination)"
echo "  ✅ WSL2 optimized configuration"
echo ""

# Build the image
docker build -t ffmpeg-cuda:latest . --no-cache

echo ""
echo "✅ Build completed successfully!"
echo ""
echo "🧪 Testing the image..."

# Test basic functionality
echo "Testing FFmpeg version..."
docker run --rm ffmpeg-cuda:latest ffmpeg -version | head -1

echo ""
echo "Testing hardware accelerators..."
docker run --rm --gpus all ffmpeg-cuda:latest ffmpeg -hwaccels

echo ""
echo "Testing NVENC encoders..."
docker run --rm --gpus all ffmpeg-cuda:latest ffmpeg -encoders | grep nvenc

echo ""
echo "🎉 SUCCESS! Your FFmpeg CUDA Docker image is ready!"
echo ""
echo "📋 Quick Usage Examples:"
echo ""
echo "# Basic hardware accelerated encoding:"
echo "docker run --rm --gpus all -v \$(pwd):/workspace -w /workspace ffmpeg-cuda:latest \\"
echo "  ffmpeg -i input.mp4 -c:v h264_nvenc -preset fast output.mp4"
echo ""
echo "# Add text overlay:"
echo "docker run --rm --gpus all -v \$(pwd):/workspace -w /workspace ffmpeg-cuda:latest \\"
echo "  ffmpeg -i input.mp4 -vf \"drawtext=text='Hello World':fontsize=48:fontcolor=white:x=10:y=10\" \\"
echo "  -c:v h264_nvenc output_with_text.mp4"
echo ""
echo "# Interactive shell:"
echo "docker run --rm -it --gpus all -v \$(pwd):/workspace -w /workspace ffmpeg-cuda:latest bash"
echo ""
echo "🎯 This image is specifically optimized for your RTX 4090 + WSL2 setup!"

