#!/bin/bash
# Setup script for Mitra AI (macOS/Linux)

set -e

echo "================================"
echo "Mitra AI - Setup Script"
echo "================================"
echo ""

# Check Python
echo "✓ Checking Python..."
python3 --version || { echo "✗ Python 3 not found"; exit 1; }

# Check Node
echo "✓ Checking Node.js..."
node --version || { echo "✗ Node.js not found"; exit 1; }

# Backend setup
echo ""
echo "================================"
echo "Setting up Backend..."
echo "================================"
cd backend

# Create virtual environment
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
source venv/bin/activate

# Install dependencies
echo "Installing Python dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

echo "✓ Backend setup complete!"
echo ""

# Check for models
if [ ! -d "models" ]; then
    mkdir models
fi

if [ ! -f "models/gemma-4-E2B-it-Q8_0.gguf" ] || [ ! -f "models/llama-3.1-8b-q8_0.gguf" ]; then
    echo "================================"
    echo "Downloading Models..."
    echo "================================"
    echo "This will download ~9 GB of models. Continue? (y/n)"
    read -r response
    if [ "$response" = "y" ]; then
        python3 setup-models.py
    else
        echo "⚠ Models not downloaded. You can run 'python setup-models.py' later."
    fi
fi

# Frontend setup
echo ""
echo "================================"
echo "Setting up Frontend..."
echo "================================"
cd ../frontend

echo "Installing Node dependencies..."
npm install

echo "✓ Frontend setup complete!"

echo ""
echo "================================"
echo "Setup Complete! 🎉"
echo "================================"
echo ""
echo "To start the application:"
echo ""
echo "Terminal 1 (Backend):"
echo "  cd backend"
echo "  source venv/bin/activate"
echo "  python main.py"
echo ""
echo "Terminal 2 (Frontend):"
echo "  cd frontend"
echo "  npm run dev"
echo ""
echo "Then open: http://localhost:3000"
echo ""
