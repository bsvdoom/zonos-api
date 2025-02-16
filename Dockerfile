FROM pytorch/pytorch:2.6.0-cuda12.4-cudnn9-devel

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libsndfile1 \
    espeak-ng \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install uv
RUN pip install -U uv uvicorn gunicorn fastapi soundfile pydantic_settings kanjize phonemizer sudachipy sudachidict_full

# Copy application code and submodules
COPY . .

# Initialize and update submodules
RUN git submodule update --init --recursive --remote

# Install dependencies with optimizations
RUN uv pip install --system --no-build-isolation -e .[compile] && \
    # Install flash-attention and other optimizations
    pip install --no-build-isolation \
    flash-attn \
    mamba-ssm \
    causal-conv1d

# Create a non-root user and setup directories
RUN useradd -m -u 1000 appuser && \
    mkdir -p /home/appuser/.cache/huggingface && \
    chown -R appuser:appuser /home/appuser/.cache && \
    mkdir -p /app/uploads && \
    chown -R appuser:appuser /app

USER appuser

# Set environment variables
ENV PORT=8000
ENV WORKERS=4
ENV MODEL_TYPE="Transformer"
ENV MODEL_CACHE_DIR="/home/appuser/.cache/huggingface"
ENV PYTHONUNBUFFERED=1
# CUDA optimization settings
ENV CUDA_LAUNCH_BLOCKING=0
ENV TORCH_CUDA_ARCH_LIST="7.0;7.5;8.0;8.6+PTX"
ENV CUDA_HOME="/usr/local/cuda"
ENV MAX_JOBS=4

# Expose the port
EXPOSE $PORT

# Add healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:$PORT/health || exit 1

# Run the application with Gunicorn
#CMD ["sh", "-c", "gunicorn main:app --workers $WORKERS --worker-class uvicorn.workers.UvicornWorker --bind 0.0.0.0:$PORT --timeout 300 --worker-tmp-dir /dev/shm"]
CMD ["sh", "-c", "gunicorn app.main:app --workers $WORKERS --worker-class uvicorn.workers.UvicornWorker --bind 0.0.0.0:$PORT --timeout 300 --worker-tmp-dir /dev/shm"]
