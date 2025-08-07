# Use Python 3.11 slim image
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    curl \
    wget \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set pip configuration for better reliability
ENV PIP_DEFAULT_TIMEOUT=300
ENV PIP_RETRIES=10
ENV PIP_TIMEOUT=300

# Copy requirements first for better caching
COPY requirements.txt /app/requirements.txt

# Install Python dependencies with retry mechanism
RUN pip install --no-cache-dir --upgrade pip setuptools wheel && \
    pip install --no-cache-dir --retries 10 --timeout 300 -r requirements.txt

# Copy backend code
COPY . /app/

# Create necessary directories
RUN mkdir -p /app/scripts /app/reports /app/uploads

# Make the main script executable
RUN chmod +x /app/main.py

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Run the application
CMD ["python", "main.py"] 