# FFmpeg CUDA API - Production Setup Instructions

## 🎯 **Complete Production Solution**

This is a fully production-ready FFmpeg CUDA API with:
- ✅ Professional Flask API with beautiful web interface
- ✅ Gunicorn production WSGI server
- ✅ Comprehensive error handling and logging
- ✅ Performance monitoring and statistics
- ✅ Health checks and system monitoring
- ✅ RTX 4090 optimized NVENC acceleration
- ✅ Security features (non-root user, input validation)

## 📋 **Files Included**

1. **`Dockerfile.production`** - Complete production Dockerfile
2. **`ffmpeg_api.py`** - Advanced Flask API with web interface
3. **`start_api.sh`** - Production startup script
4. **`gunicorn.conf.py`** - Gunicorn production configuration

## 🚀 **Setup Instructions**

### **Step 1: Prepare Files**
```bash
# Navigate to your project directory
cd /mnt/c/Users/ammar/docker/ffmpeg-docker

# Copy the production files
cp Dockerfile.production Dockerfile
# Copy ffmpeg_api.py, start_api.sh, gunicorn.conf.py to the same directory
```

### **Step 2: Build Production Image**
```bash
# Build the production image (30-45 minutes)
docker build -t ffmpeg-cuda-api:production .
```

### **Step 3: Run Production Container**
```bash
# Stop any existing containers
docker stop $(docker ps -q --filter "name=ffmpeg") 2>/dev/null || true
docker rm $(docker ps -aq --filter "name=ffmpeg") 2>/dev/null || true

# Run production container
docker run -d \
  --name ffmpeg-cuda-api \
  --gpus all \
  -p 15959:5000 \
  -v /mnt/h/Downloads:/workspace \
  --restart unless-stopped \
  --health-cmd="curl -f http://localhost:5000/health || exit 1" \
  --health-interval=30s \
  --health-timeout=10s \
  --health-retries=3 \
  ffmpeg-cuda-api:production
```

### **Step 4: Verify Installation**
```bash
# Check container status
docker ps | grep ffmpeg-cuda-api

# Check logs
docker logs ffmpeg-cuda-api

# Test API
curl http://localhost:15959/health
```

## 🌐 **Access Your API**

### **Web Interface**
Open in browser: **http://localhost:15959/**

### **API Endpoints**
- **Health Check:** `GET http://localhost:15959/health`
- **List Files:** `GET http://localhost:15959/files`
- **System Info:** `GET http://localhost:15959/info`
- **Statistics:** `GET http://localhost:15959/stats`
- **Encode Video:** `POST http://localhost:15959/encode`

## 🎬 **Usage Examples**

### **Basic Encoding**
```bash
curl -X POST http://localhost:15959/encode \
  -H "Content-Type: application/json" \
  -d '{
    "input": "video.mp4",
    "output": "encoded.mp4"
  }'
```

### **High Quality Encoding**
```bash
curl -X POST http://localhost:15959/encode \
  -H "Content-Type: application/json" \
  -d '{
    "input": "source.mp4",
    "output": "high_quality.mp4",
    "preset": "slow",
    "crf": "18"
  }'
```

### **4K Upscaling**
```bash
curl -X POST http://localhost:15959/encode \
  -H "Content-Type: application/json" \
  -d '{
    "input": "1080p.mp4",
    "output": "4k.mp4",
    "scale": "3840x2160",
    "preset": "medium"
  }'
```

### **Custom Bitrate**
```bash
curl -X POST http://localhost:15959/encode \
  -H "Content-Type: application/json" \
  -d '{
    "input": "input.mp4",
    "output": "output.mp4",
    "bitrate": "10M",
    "preset": "fast"
  }'
```

## 📊 **Production Features**

### **Performance Monitoring**
- Real-time encoding statistics
- Success/failure rates
- Processing time tracking
- GPU memory monitoring

### **Error Handling**
- Comprehensive error messages
- Input validation
- File existence checks
- Timeout protection (1 hour)

### **Security**
- Non-root user execution
- Input sanitization
- Resource limits
- Health checks

### **Logging**
- Structured logging
- Access logs
- Error tracking
- Performance metrics

## 🔧 **Configuration**

### **Encoding Parameters**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `input` | string | required | Input video filename |
| `output` | string | required | Output video filename |
| `preset` | string | "fast" | NVENC preset (fast/medium/slow) |
| `crf` | number | 23 | Quality (18-28, lower=better) |
| `scale` | string | none | Resolution (e.g., "1920x1080") |
| `bitrate` | string | none | Video bitrate (e.g., "5M") |

### **Performance Tuning**
- **Workers:** 2 (optimal for video processing)
- **Timeout:** 3600s (1 hour for large files)
- **Memory:** Uses /dev/shm for better performance
- **Restart:** Auto-restart on failure

## 🎯 **Expected Performance**

With your RTX 4090:
- **1080p H.264:** 300-500+ FPS
- **4K H.264:** 100-200+ FPS
- **HEVC encoding:** 150-300+ FPS
- **Memory usage:** 2-4GB VRAM typical

## 🔍 **Monitoring**

### **Container Health**
```bash
# Check health status
docker inspect ffmpeg-cuda-api --format='{{.State.Health.Status}}'

# View health logs
docker inspect ffmpeg-cuda-api --format='{{range .State.Health.Log}}{{.Output}}{{end}}'
```

### **Performance Stats**
```bash
# API statistics
curl http://localhost:15959/stats

# System information
curl http://localhost:15959/info
```

### **Logs**
```bash
# Follow logs
docker logs -f ffmpeg-cuda-api

# Recent logs
docker logs --tail 100 ffmpeg-cuda-api
```

## 🚀 **Production Ready!**

Your FFmpeg CUDA API is now production-ready with:
- ✅ Professional web interface
- ✅ High-performance Gunicorn server
- ✅ Comprehensive monitoring
- ✅ RTX 4090 optimization
- ✅ Enterprise-grade features

**Start encoding videos with lightning-fast GPU acceleration!** 🎬

