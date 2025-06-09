#!/bin/bash

# Production startup script for FFmpeg CUDA API
# Optimized for RTX 4090 + WSL2 + Docker

set -e

export PATH=/home/ffmpeguser/.local/bin:$PATH
cd /home/ffmpeguser

echo "🚀 FFmpeg CUDA API - Production Startup"
echo "======================================="
echo ""

# System information
echo "📊 System Information:"
echo "   User: $(whoami)"
echo "   Working Directory: $(pwd)"
echo "   Python: $(python3 --version)"
echo "   Date: $(date)"
echo ""

# Check FFmpeg
echo "🎬 FFmpeg Status:"
if command -v ffmpeg &> /dev/null; then
    echo "   ✅ FFmpeg found: $(ffmpeg -version | head -1)"
else
    echo "   ❌ FFmpeg not found"
    exit 1
fi

# Check GPU
echo "🎮 GPU Status:"
if command -v nvidia-smi &> /dev/null; then
    GPU_NAME=$(nvidia-smi --query-gpu=name --format=csv,noheader,nounits 2>/dev/null || echo "Not detected")
    echo "   ✅ GPU: $GPU_NAME"
else
    echo "   ⚠️  nvidia-smi not available (may work in container)"
fi

# Check hardware acceleration
echo "🔧 Hardware Acceleration:"
HWACCELS=$(ffmpeg -hwaccels 2>/dev/null | tail -n +2 | tr '\n' ' ')
echo "   Available: $HWACCELS"

# Check workspace
echo "📁 Workspace:"
if [ -d "/workspace" ]; then
    FILE_COUNT=$(find /workspace -maxdepth 1 -type f \( -name "*.mp4" -o -name "*.avi" -o -name "*.mov" -o -name "*.mkv" \) 2>/dev/null | wc -l)
    echo "   ✅ Workspace: /workspace ($FILE_COUNT video files)"
else
    echo "   ⚠️  Workspace not mounted: /workspace"
fi

echo ""
echo "🔥 Starting Production Server..."
echo "   Server: Gunicorn"
echo "   Workers: 2"
echo "   Port: 5000"
echo "   Timeout: 3600s (1 hour)"
echo "   Mode: Production"
echo ""

# Start Gunicorn with production settings
exec gunicorn \
    --bind 0.0.0.0:5000 \
    --workers 2 \
    --worker-class sync \
    --timeout 3600 \
    --keep-alive 2 \
    --max-requests 1000 \
    --max-requests-jitter 100 \
    --preload \
    --access-logfile - \
    --error-logfile - \
    --log-level info \
    --capture-output \
    ffmpeg_api:app

