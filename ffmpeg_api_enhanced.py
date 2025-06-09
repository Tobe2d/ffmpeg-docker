import flask
import subprocess
import os
import json
import time
import logging
from datetime import datetime
from werkzeug.middleware.proxy_fix import ProxyFix

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = flask.Flask(__name__)
app.wsgi_app = ProxyFix(app.wsgi_app, x_for=1, x_proto=1, x_host=1, x_prefix=1)

# Global stats
stats = {
    'total_encodings': 0,
    'successful_encodings': 0,
    'failed_encodings': 0,
    'start_time': datetime.now().isoformat()
}

@app.route('/')
def docs():
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <title>FFmpeg CUDA API - Production</title>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
            body { 
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
                margin: 0; 
                padding: 20px; 
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: #333;
            }
            .container {
                max-width: 1400px;
                margin: 0 auto;
                background: white;
                border-radius: 10px;
                padding: 30px;
                box-shadow: 0 10px 30px rgba(0,0,0,0.3);
            }
            h1 { 
                color: #2c3e50; 
                text-align: center;
                margin-bottom: 10px;
            }
            .status-bar {
                background: #27ae60;
                color: white;
                padding: 15px;
                border-radius: 5px;
                text-align: center;
                margin: 20px 0;
                font-weight: bold;
            }
            h2 { 
                color: #34495e; 
                border-bottom: 2px solid #3498db;
                padding-bottom: 10px;
                margin-top: 40px;
            }
            h3 {
                color: #2c3e50;
                margin-top: 30px;
                border-left: 4px solid #e74c3c;
                padding-left: 15px;
            }
            .endpoint {
                background: #f8f9fa;
                margin: 15px 0;
                padding: 15px;
                border-left: 4px solid #3498db;
                border-radius: 0 5px 5px 0;
            }
            .method {
                background: #e74c3c;
                color: white;
                padding: 3px 8px;
                border-radius: 3px;
                font-size: 12px;
                font-weight: bold;
                margin-right: 10px;
            }
            .method.get { background: #27ae60; }
            .method.post { background: #e74c3c; }
            pre { 
                background: #2c3e50; 
                color: #ecf0f1;
                padding: 15px; 
                border-radius: 5px; 
                overflow-x: auto;
                font-size: 13px;
                line-height: 1.4;
            }
            .grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
                gap: 20px;
                margin: 20px 0;
            }
            .card {
                background: #f8f9fa;
                padding: 20px;
                border-radius: 8px;
                border: 1px solid #dee2e6;
            }
            .btn {
                background: #3498db;
                color: white;
                padding: 10px 20px;
                border: none;
                border-radius: 5px;
                cursor: pointer;
                text-decoration: none;
                display: inline-block;
                margin: 5px;
            }
            .btn:hover { background: #2980b9; }
            .example-section {
                background: #f8f9fa;
                padding: 20px;
                margin: 20px 0;
                border-radius: 8px;
                border-left: 4px solid #e67e22;
            }
            .note {
                background: #fff3cd;
                border: 1px solid #ffeaa7;
                color: #856404;
                padding: 15px;
                border-radius: 5px;
                margin: 15px 0;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>🚀 FFmpeg CUDA API</h1>
            <div class="status-bar">
                Production Ready | RTX 4090 Accelerated | Gunicorn Powered
            </div>
            
            <div class="grid">
                <div class="card">
                    <h3>🎯 Quick Actions</h3>
                    <a href="/health" class="btn">Health Check</a>
                    <a href="/files" class="btn">List Files</a>
                    <a href="/info" class="btn">System Info</a>
                    <a href="/stats" class="btn">Statistics</a>
                </div>
                <div class="card">
                    <h3>📊 Performance</h3>
                    <p><strong>GPU:</strong> NVIDIA RTX 4090</p>
                    <p><strong>Acceleration:</strong> NVENC/NVDEC</p>
                    <p><strong>Expected Speed:</strong> 300-500+ FPS (1080p)</p>
                </div>
            </div>
            
            <h2>📋 API Endpoints</h2>
            
            <div class="endpoint">
                <span class="method get">GET</span><strong>/health</strong>
                <p>Check API health, status, and system information</p>
            </div>
            
            <div class="endpoint">
                <span class="method get">GET</span><strong>/files</strong>
                <p>List all available video files in the workspace with size information</p>
            </div>
            
            <div class="endpoint">
                <span class="method get">GET</span><strong>/info</strong>
                <p>Display FFmpeg version, capabilities, and hardware acceleration status</p>
            </div>
            
            <div class="endpoint">
                <span class="method get">GET</span><strong>/stats</strong>
                <p>Show encoding statistics and performance metrics</p>
            </div>
            
            <div class="endpoint">
                <span class="method post">POST</span><strong>/encode</strong>
                <p>Encode video with NVIDIA NVENC hardware acceleration</p>
            </div>
            
            <h2>🎬 Basic Usage Examples</h2>
            
            <h3>List Available Files:</h3>
            <pre>curl http://localhost:15959/files</pre>
            
            <h3>Basic Video Encoding:</h3>
            <pre>curl -X POST http://localhost:15959/encode \\
  -H "Content-Type: application/json" \\
  -d '{
    "input": "input_video.mp4",
    "output": "encoded_output.mp4"
  }'</pre>
            
            <h3>High Quality Encoding:</h3>
            <pre>curl -X POST http://localhost:15959/encode \\
  -H "Content-Type: application/json" \\
  -d '{
    "input": "source.mp4",
    "output": "high_quality.mp4",
    "preset": "slow",
    "crf": "18"
  }'</pre>
            
            <h3>4K Upscaling:</h3>
            <pre>curl -X POST http://localhost:15959/encode \\
  -H "Content-Type: application/json" \\
  -d '{
    "input": "1080p_video.mp4",
    "output": "4k_video.mp4",
    "scale": "3840x2160",
    "preset": "medium"
  }'</pre>

            <h2>🎭 Advanced Video Effects</h2>

            <div class="note">
                <strong>📁 Font Location:</strong> Place custom fonts in <code>/workspace/fonts/</code> (maps to <code>H:\\Downloads\\fonts\\</code>)
            </div>

            <h3>📹 Video Concatenation:</h3>
            <pre>curl -X POST http://localhost:15959/encode \\
  -H "Content-Type: application/json" \\
  -d '{
    "input": "concat:video1.mp4|video2.mp4|video3.mp4",
    "output": "concatenated.mp4",
    "custom_filter": "concat"
  }'</pre>

            <h3>🌅 Fade to Black (3 seconds):</h3>
            <pre>curl -X POST http://localhost:15959/encode \\
  -H "Content-Type: application/json" \\
  -d '{
    "input": "video.mp4",
    "output": "fade_to_black.mp4",
    "video_filter": "fade=t=out:st=27:d=3"
  }'</pre>

            <h3>🌄 Fade from Black (3 seconds):</h3>
            <pre>curl -X POST http://localhost:15959/encode \\
  -H "Content-Type: application/json" \\
  -d '{
    "input": "video.mp4",
    "output": "fade_from_black.mp4",
    "video_filter": "fade=t=in:st=0:d=3"
  }'</pre>

            <h3>📝 Add Simple Text:</h3>
            <pre>curl -X POST http://localhost:15959/encode \\
  -H "Content-Type: application/json" \\
  -d '{
    "input": "video.mp4",
    "output": "with_text.mp4",
    "video_filter": "drawtext=text='Hello World':fontsize=48:fontcolor=white:x=(w-text_w)/2:y=(h-text_h)/2"
  }'</pre>

            <h3>🎨 Add Styled Text with Custom Font:</h3>
            <pre>curl -X POST http://localhost:15959/encode \\
  -H "Content-Type: application/json" \\
  -d '{
    "input": "video.mp4",
    "output": "styled_text.mp4",
    "video_filter": "drawtext=text='My Video Title':fontfile=/workspace/fonts/arial.ttf:fontsize=64:fontcolor=white:borderw=3:bordercolor=black:x=(w-text_w)/2:y=50"
  }'</pre>

            <h3>🌫️ Blur Effect (from 10s to 15s):</h3>
            <pre>curl -X POST http://localhost:15959/encode \\
  -H "Content-Type: application/json" \\
  -d '{
    "input": "video.mp4",
    "output": "blurred_section.mp4",
    "video_filter": "gblur=sigma=10:enable='between(t,10,15)'"
  }'</pre>

            <h3>🎭 Picture-in-Picture Mix:</h3>
            <pre>curl -X POST http://localhost:15959/encode \\
  -H "Content-Type: application/json" \\
  -d '{
    "input": "background.mp4",
    "input2": "overlay.mp4",
    "output": "mixed_video.mp4",
    "complex_filter": "[1:v]scale=320:240[ovrl];[0:v][ovrl]overlay=10:10"
  }'</pre>

            <h2>🎵 Audio Processing</h2>

            <h3>🎤 Extract Audio to WAV:</h3>
            <pre>curl -X POST http://localhost:15959/encode \\
  -H "Content-Type: application/json" \\
  -d '{
    "input": "video.mp4",
    "output": "extracted_audio.wav",
    "audio_only": true,
    "audio_codec": "pcm_s16le"
  }'</pre>

            <h3>🎵 Convert WAV to MP3:</h3>
            <pre>curl -X POST http://localhost:15959/encode \\
  -H "Content-Type: application/json" \\
  -d '{
    "input": "audio.wav",
    "output": "converted.mp3",
    "audio_only": true,
    "audio_codec": "mp3",
    "audio_bitrate": "192k"
  }'</pre>

            <h3>🔊 Audio Volume Adjustment:</h3>
            <pre>curl -X POST http://localhost:15959/encode \\
  -H "Content-Type: application/json" \\
  -d '{
    "input": "video.mp4",
    "output": "louder_video.mp4",
    "audio_filter": "volume=2.0"
  }'</pre>

            <h2>🔄 Format Conversion</h2>

            <h3>📱 MP4 to MOV:</h3>
            <pre>curl -X POST http://localhost:15959/encode \\
  -H "Content-Type: application/json" \\
  -d '{
    "input": "video.mp4",
    "output": "video.mov",
    "video_codec": "h264_nvenc",
    "audio_codec": "aac"
  }'</pre>

            <h3>🎬 MOV to MP4:</h3>
            <pre>curl -X POST http://localhost:15959/encode \\
  -H "Content-Type: application/json" \\
  -d '{
    "input": "video.mov",
    "output": "video.mp4",
    "video_codec": "h264_nvenc"
  }'</pre>

            <h3>📺 MP4 to AVI:</h3>
            <pre>curl -X POST http://localhost:15959/encode \\
  -H "Content-Type: application/json" \\
  -d '{
    "input": "video.mp4",
    "output": "video.avi",
    "video_codec": "h264_nvenc",
    "audio_codec": "mp3"
  }'</pre>

            <h3>🌐 MP4 to WebM:</h3>
            <pre>curl -X POST http://localhost:15959/encode \\
  -H "Content-Type: application/json" \\
  -d '{
    "input": "video.mp4",
    "output": "video.webm",
    "video_codec": "libvpx-vp9",
    "audio_codec": "libopus"
  }'</pre>

            <h2>✨ Creative Effects</h2>

            <h3>🌈 Color Saturation Boost:</h3>
            <pre>curl -X POST http://localhost:15959/encode \\
  -H "Content-Type: application/json" \\
  -d '{
    "input": "video.mp4",
    "output": "saturated.mp4",
    "video_filter": "eq=saturation=1.5:brightness=0.1"
  }'</pre>

            <h3>📺 Old TV Effect:</h3>
            <pre>curl -X POST http://localhost:15959/encode \\
  -H "Content-Type: application/json" \\
  -d '{
    "input": "video.mp4",
    "output": "old_tv.mp4",
    "video_filter": "noise=alls=20:allf=t+u,eq=contrast=1.2:brightness=-0.1"
  }'</pre>

            <h3>🎞️ Film Grain Effect:</h3>
            <pre>curl -X POST http://localhost:15959/encode \\
  -H "Content-Type: application/json" \\
  -d '{
    "input": "video.mp4",
    "output": "film_grain.mp4",
    "video_filter": "noise=alls=10:allf=t"
  }'</pre>

            <h3>🔄 Video Stabilization:</h3>
            <pre>curl -X POST http://localhost:15959/encode \\
  -H "Content-Type: application/json" \\
  -d '{
    "input": "shaky_video.mp4",
    "output": "stabilized.mp4",
    "video_filter": "vidstabdetect=shakiness=10:accuracy=10,vidstabtransform=smoothing=10"
  }'</pre>

            <h3>⚡ Speed Up Video (2x):</h3>
            <pre>curl -X POST http://localhost:15959/encode \\
  -H "Content-Type: application/json" \\
  -d '{
    "input": "video.mp4",
    "output": "fast_video.mp4",
    "video_filter": "setpts=0.5*PTS",
    "audio_filter": "atempo=2.0"
  }'</pre>

            <h3>🐌 Slow Motion (0.5x):</h3>
            <pre>curl -X POST http://localhost:15959/encode \\
  -H "Content-Type: application/json" \\
  -d '{
    "input": "video.mp4",
    "output": "slow_motion.mp4",
    "video_filter": "setpts=2.0*PTS",
    "audio_filter": "atempo=0.5"
  }'</pre>

            <h2>⚙️ Advanced Parameters</h2>
            <div class="grid">
                <div class="card">
                    <h4>Video Parameters</h4>
                    <p><strong>video_codec:</strong> h264_nvenc, hevc_nvenc, libx264</p>
                    <p><strong>video_filter:</strong> Custom video filters</p>
                    <p><strong>scale:</strong> Resolution (1920x1080)</p>
                    <p><strong>preset:</strong> fast, medium, slow</p>
                    <p><strong>crf:</strong> Quality 18-28</p>
                </div>
                <div class="card">
                    <h4>Audio Parameters</h4>
                    <p><strong>audio_codec:</strong> aac, mp3, pcm_s16le</p>
                    <p><strong>audio_filter:</strong> Custom audio filters</p>
                    <p><strong>audio_bitrate:</strong> 128k, 192k, 320k</p>
                    <p><strong>audio_only:</strong> true/false</p>
                </div>
                <div class="card">
                    <h4>Advanced Options</h4>
                    <p><strong>complex_filter:</strong> Multi-input filters</p>
                    <p><strong>input2:</strong> Second input file</p>
                    <p><strong>custom_filter:</strong> Special operations</p>
                    <p><strong>bitrate:</strong> Overall bitrate</p>
                </div>
            </div>

            <div class="note">
                <strong>💡 Pro Tips:</strong><br>
                • Place fonts in <code>H:\\Downloads\\fonts\\</code> for custom text styling<br>
                • Use <code>preset=slow</code> for best quality, <code>preset=fast</code> for speed<br>
                • Combine multiple filters with commas: <code>"fade=t=in:d=2,eq=brightness=0.1"</code><br>
                • Check <code>/files</code> endpoint to see available videos before encoding
            </div>
            
            <div style="text-align: center; margin-top: 40px; color: #7f8c8d;">
                <p>Powered by FFmpeg + NVIDIA CUDA | Built for Production</p>
            </div>
        </div>
    </body>
    </html>
    '''

@app.route('/health')
def health():
    try:
        # Test FFmpeg
        result = subprocess.run(['ffmpeg', '-version'], capture_output=True, text=True, timeout=5)
        ffmpeg_ok = result.returncode == 0
        
        # Test GPU access
        gpu_result = subprocess.run(['nvidia-smi', '--query-gpu=name', '--format=csv,noheader'], 
                                  capture_output=True, text=True, timeout=5)
        gpu_ok = gpu_result.returncode == 0
        gpu_name = gpu_result.stdout.strip() if gpu_ok else "Not detected"
        
        return {
            'status': 'healthy' if ffmpeg_ok and gpu_ok else 'degraded',
            'timestamp': datetime.now().isoformat(),
            'ffmpeg': 'ok' if ffmpeg_ok else 'error',
            'gpu': gpu_name,
            'gpu_status': 'ok' if gpu_ok else 'error',
            'workspace': '/workspace',
            'mode': 'production',
            'server': 'gunicorn',
            'api_version': '2.0'
        }
    except Exception as e:
        logger.error(f"Health check failed: {e}")
        return {'status': 'error', 'message': str(e)}, 500

@app.route('/files')
def list_files():
    try:
        files = []
        workspace = '/workspace'
        
        if not os.path.exists(workspace):
            return {'error': 'Workspace not found', 'workspace': workspace}, 404
            
        for f in os.listdir(workspace):
            if f.lower().endswith(('.mp4', '.avi', '.mov', '.mkv', '.webm', '.flv', '.m4v', '.wmv', '.3gp', '.wav', '.mp3', '.aac', '.flac')):
                filepath = os.path.join(workspace, f)
                try:
                    stat = os.stat(filepath)
                    files.append({
                        'name': f,
                        'size_mb': round(stat.st_size / 1024 / 1024, 1),
                        'size_bytes': stat.st_size,
                        'modified': datetime.fromtimestamp(stat.st_mtime).isoformat()
                    })
                except OSError:
                    continue
        
        return {
            'files': sorted(files, key=lambda x: x['name']),
            'total': len(files),
            'workspace': workspace,
            'total_size_mb': round(sum(f['size_mb'] for f in files), 1)
        }
    except Exception as e:
        logger.error(f"File listing failed: {e}")
        return {'error': str(e), 'workspace': '/workspace'}, 500

@app.route('/info')
def ffmpeg_info():
    try:
        info = {}
        
        # FFmpeg version
        version_result = subprocess.run(['ffmpeg', '-version'], capture_output=True, text=True, timeout=10)
        if version_result.returncode == 0:
            info['ffmpeg_version'] = version_result.stdout.split('\n')[0]
        
        # Hardware accelerators
        hwaccel_result = subprocess.run(['ffmpeg', '-hwaccels'], capture_output=True, text=True, timeout=10)
        if hwaccel_result.returncode == 0:
            info['hardware_accelerators'] = [line.strip() for line in hwaccel_result.stdout.split('\n')[1:] if line.strip()]
        
        # NVENC encoders
        encoders_result = subprocess.run(['ffmpeg', '-encoders'], capture_output=True, text=True, timeout=10)
        if encoders_result.returncode == 0:
            nvenc_encoders = []
            for line in encoders_result.stdout.split('\n'):
                if 'nvenc' in line.lower() and line.strip():
                    nvenc_encoders.append(line.strip())
            info['nvenc_encoders'] = nvenc_encoders
        
        # GPU info
        gpu_result = subprocess.run(['nvidia-smi', '--query-gpu=name,memory.total,memory.used', '--format=csv,noheader,nounits'], 
                                  capture_output=True, text=True, timeout=10)
        if gpu_result.returncode == 0:
            gpu_data = gpu_result.stdout.strip().split(', ')
            if len(gpu_data) >= 3:
                info['gpu'] = {
                    'name': gpu_data[0],
                    'memory_total_mb': int(gpu_data[1]),
                    'memory_used_mb': int(gpu_data[2]),
                    'memory_free_mb': int(gpu_data[1]) - int(gpu_data[2])
                }
        
        info['cuda_available'] = 'cuda' in info.get('hardware_accelerators', [])
        
        return info
    except Exception as e:
        logger.error(f"Info gathering failed: {e}")
        return {'error': str(e)}, 500

@app.route('/stats')
def get_stats():
    uptime_seconds = (datetime.now() - datetime.fromisoformat(stats['start_time'])).total_seconds()
    return {
        **stats,
        'uptime_seconds': round(uptime_seconds, 1),
        'uptime_hours': round(uptime_seconds / 3600, 2),
        'success_rate': round((stats['successful_encodings'] / max(stats['total_encodings'], 1)) * 100, 1)
    }

@app.route('/encode', methods=['POST'])
def encode():
    start_time = time.time()
    stats['total_encodings'] += 1
    
    try:
        data = flask.request.json
        if not data:
            return {'status': 'error', 'message': 'No JSON data provided'}, 400
        
        # Validate required fields
        required_fields = ['input', 'output']
        for field in required_fields:
            if field not in data:
                return {'status': 'error', 'message': f'Missing required field: {field}'}, 400
        
        input_file = data['input']
        output_file = data['output']
        input2_file = data.get('input2')
        
        # Handle special concatenation syntax
        if input_file.startswith('concat:'):
            files = input_file.replace('concat:', '').split('|')
            input_files = [f'/workspace/{f}' if not f.startswith('/') else f for f in files]
            # Create concat file list
            concat_list = '/tmp/concat_list.txt'
            with open(concat_list, 'w') as f:
                for file in input_files:
                    f.write(f"file '{file}'\n")
            input_file = concat_list
            use_concat = True
        else:
            use_concat = False
            # Add workspace prefix if not absolute path
            if not input_file.startswith('/'):
                input_file = f'/workspace/{input_file}'
        
        if input2_file and not input2_file.startswith('/'):
            input2_file = f'/workspace/{input2_file}'
            
        if not output_file.startswith('/'):
            output_file = f'/workspace/{output_file}'
        
        # Check if input file exists (skip for concat)
        if not use_concat and not os.path.exists(input_file):
            available_files = []
            try:
                available_files = [f for f in os.listdir('/workspace') 
                                 if f.lower().endswith(('.mp4', '.avi', '.mov', '.mkv', '.webm', '.flv', '.wav', '.mp3'))]
            except:
                pass
            
            return {
                'status': 'error', 
                'message': f'Input file not found: {input_file}',
                'available_files': available_files
            }, 404
        
        # Build FFmpeg command
        cmd = ['ffmpeg', '-y']
        
        # Hardware acceleration (skip for audio-only)
        if not data.get('audio_only', False):
            cmd.extend(['-hwaccel', 'cuda'])
        
        # Input handling
        if use_concat:
            cmd.extend(['-f', 'concat', '-safe', '0', '-i', input_file])
        else:
            cmd.extend(['-i', input_file])
            
        # Second input for mixing
        if input2_file:
            cmd.extend(['-i', input2_file])
        
        # Complex filter for advanced operations
        if 'complex_filter' in data:
            cmd.extend(['-filter_complex', data['complex_filter']])
        
        # Video codec and settings
        if not data.get('audio_only', False):
            video_codec = data.get('video_codec', 'h264_nvenc')
            cmd.extend(['-c:v', video_codec])
            
            preset = data.get('preset', 'fast')
            if 'nvenc' in video_codec:
                cmd.extend(['-preset', preset])
            
            # Quality settings
            bitrate = data.get('bitrate')
            crf = str(data.get('crf', '23'))
            
            if bitrate:
                cmd.extend(['-b:v', bitrate])
            elif 'nvenc' in video_codec:
                cmd.extend(['-crf', crf])
            
            # Video filters
            video_filter = data.get('video_filter')
            scale = data.get('scale')
            
            if video_filter and scale:
                cmd.extend(['-vf', f'scale_cuda={scale},{video_filter}'])
            elif video_filter:
                cmd.extend(['-vf', video_filter])
            elif scale:
                cmd.extend(['-vf', f'scale_cuda={scale}'])
        else:
            cmd.extend(['-vn'])  # No video for audio-only
        
        # Audio codec and settings
        if not data.get('video_only', False):
            audio_codec = data.get('audio_codec', 'aac')
            cmd.extend(['-c:a', audio_codec])
            
            audio_bitrate = data.get('audio_bitrate', '128k')
            if audio_codec != 'pcm_s16le':
                cmd.extend(['-b:a', audio_bitrate])
            
            # Audio filters
            audio_filter = data.get('audio_filter')
            if audio_filter:
                cmd.extend(['-af', audio_filter])
        else:
            cmd.extend(['-an'])  # No audio for video-only
        
        # Output file
        cmd.append(output_file)
        
        logger.info(f"Starting encoding: {' '.join(cmd)}")
        
        # Execute FFmpeg with timeout
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=3600)  # 1 hour timeout
        
        processing_time = time.time() - start_time
        
        # Check if output file was created
        output_exists = os.path.exists(output_file)
        output_size = 0
        if output_exists:
            output_size = os.path.getsize(output_file)
            stats['successful_encodings'] += 1
        else:
            stats['failed_encodings'] += 1
        
        response = {
            'status': 'success' if result.returncode == 0 and output_exists else 'error',
            'returncode': result.returncode,
            'processing_time_seconds': round(processing_time, 2),
            'output_file_created': output_exists,
            'output_size_mb': round(output_size / 1024 / 1024, 1) if output_exists else 0,
            'command': ' '.join(cmd),
            'input_file': input_file,
            'output_file': output_file,
            'timestamp': datetime.now().isoformat()
        }
        
        # Include FFmpeg output for debugging if there was an error
        if result.returncode != 0 or not output_exists:
            response['ffmpeg_stdout'] = result.stdout
            response['ffmpeg_stderr'] = result.stderr
        
        logger.info(f"Encoding completed: {response['status']} in {processing_time:.2f}s")
        
        return response
        
    except subprocess.TimeoutExpired:
        stats['failed_encodings'] += 1
        logger.error("Encoding timeout")
        return {'status': 'error', 'message': 'Encoding timeout (1 hour limit)'}, 408
    except Exception as e:
        stats['failed_encodings'] += 1
        logger.error(f"Encoding failed: {e}")
        return {'status': 'error', 'message': str(e), 'timestamp': datetime.now().isoformat()}, 500

@app.errorhandler(404)
def not_found(error):
    return {'error': 'Endpoint not found', 'available_endpoints': ['/', '/health', '/files', '/info', '/stats', '/encode']}, 404

@app.errorhandler(500)
def internal_error(error):
    return {'error': 'Internal server error', 'message': str(error)}, 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)

