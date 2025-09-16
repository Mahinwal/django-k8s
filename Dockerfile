# Use Python slim image
FROM python:3.13-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Download and install uv
ADD https://astral.sh/uv/install.sh /uv-installer.sh
RUN sh /uv-installer.sh && rm /uv-installer.sh

# Ensure uv is in PATH
ENV PATH="/root/.local/bin:$PATH" \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    UV_SYSTEM_PYTHON=1 \
    UV_LINK_MODE=copy

# Copy dependency files
COPY pyproject.toml uv.lock* ./

# Install dependencies (system install, editable mode for local dev)
RUN uv pip install --system --editable .[dev]

# Copy project files
COPY . .

# Expose Django default port
EXPOSE 8000

# Default command (Django dev server)
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]