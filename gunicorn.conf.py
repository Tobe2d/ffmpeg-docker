# Gunicorn configuration file for FFmpeg CUDA API
# Production settings optimized for video processing

import multiprocessing
import os

# Server socket
bind = "0.0.0.0:5000"
backlog = 2048

# Worker processes
workers = 2
worker_class = "sync"
worker_connections = 1000
timeout = 3600  # 1 hour for long video processing
keepalive = 2
max_requests = 1000
max_requests_jitter = 100

# Restart workers after this many requests, to help prevent memory leaks
preload_app = True

# Logging
accesslog = "-"
errorlog = "-"
loglevel = "info"
access_log_format = '%(h)s %(l)s %(u)s %(t)s "%(r)s" %(s)s %(b)s "%(f)s" "%(a)s" %(D)s'

# Process naming
proc_name = "ffmpeg-cuda-api"

# Server mechanics
daemon = False
pidfile = None
user = None
group = None
tmp_upload_dir = None

# SSL (disabled for internal use)
keyfile = None
certfile = None

# Performance
worker_tmp_dir = "/dev/shm"  # Use shared memory for better performance

# Security
limit_request_line = 4094
limit_request_fields = 100
limit_request_field_size = 8190

def when_ready(server):
    server.log.info("🚀 FFmpeg CUDA API server is ready. Listening on %s", server.address)

def worker_int(worker):
    worker.log.info("🔄 Worker received INT or QUIT signal")

def pre_fork(server, worker):
    server.log.info("👷 Worker spawned (pid: %s)", worker.pid)

def post_fork(server, worker):
    server.log.info("✅ Worker spawned (pid: %s)", worker.pid)

def worker_abort(worker):
    worker.log.info("💥 Worker received SIGABRT signal")

