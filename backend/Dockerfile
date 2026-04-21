FROM nvidia/cuda:12.1.1-runtime-ubuntu22.04

WORKDIR /app

# Install Python and dependencies
RUN apt-get update && apt-get install -y \
    python3.11 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY main.py .
COPY setup-models.py .

# Create models directory
RUN mkdir -p models

# Expose port
EXPOSE 8000

# Run the application
CMD ["python3", "main.py"]
