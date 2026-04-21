# MITRA Backend - FastAPI LLM Server

A high-performance FastAPI backend for running quantized LLM models locally (Llama 3.1 and Gemma 4).

## Features

- **Dual LLM Support**: Llama 3.1 8B and Gemma 4 models
- **GPU Acceleration**: Full GPU offloading with llama-cpp-python
- **Quantized Models**: Q8_0 GGUF format for reduced memory usage
- **OpenAI-like API**: Chat completions endpoint compatible with standard clients
- **CORS Enabled**: Ready for frontend integration
- **Auto-startup**: Models load automatically on server start

## Tech Stack

- **FastAPI** - Modern Python web framework
- **llama-cpp-python** - Fast LLM inference
- **Pydantic** - Data validation
- **Uvicorn** - ASGI server

## Prerequisites

- Python 3.9+
- CUDA-capable GPU (for GPU acceleration)
- 16+ GB RAM
- 10+ GB disk space (for models)

## Installation

### 1. Install Dependencies

```bash
cd backend
pip install -r requirements.txt
```

### 2. Download Models

#### Option A: Automatic Download (Recommended)

```bash
python setup-models.py
```

This will download:
- **Llama 3.1 8B** (~7.2 GB) - Better for complex tasks
- **Gemma 4** (~1.8 GB) - Faster, lightweight

#### Option B: Manual Download

1. **Llama 3.1 8B-Instruct (Q8_0)**
   - Download: https://huggingface.co/QuantFactory/Meta-Llama-3.1-8B-Instruct-GGUF
   - File: `Meta-Llama-3.1-8B-Instruct.Q8_0.gguf`
   - Save to: `./models/llama-3.1-8b-q8_0.gguf`

2. **Gemma 4 (Q8_0)**
   - Download: https://huggingface.co/unsloth/gemma-4-E2B-it-GGUF
   - File: `gemma-4-E2B-it.Q8_0.gguf`
   - Save to: `./models/gemma-4-E2B-it-Q8_0.gguf`

### 3. Configure Environment (Optional)

Copy `.env.example` to `.env` and adjust paths if needed:

```bash
cp .env.example .env
```

## Running the Server

```bash
python main.py
```

The server will start at `http://localhost:8000`

Access the interactive API docs at: `http://localhost:8000/docs`

## API Endpoints

### Health Check
```
GET /health
```
Returns server status and loaded models.

### List Models
```
GET /models
```
Returns available models with metadata.

**Response:**
```json
[
  {
    "id": "gemma-4",
    "name": "Gemma 4",
    "description": "Quantized model",
    "available": true
  },
  {
    "id": "llama-3.1-8b",
    "name": "Llama 3.1 8B",
    "description": "Large language model",
    "available": true
  }
]
```

### Chat Completions
```
POST /chat/completions
```

**Request:**
```json
{
  "messages": [
    {
      "role": "user",
      "content": "What is machine learning?"
    }
  ],
  "model": "gemma-4",
  "temperature": 0.7,
  "max_tokens": 500,
  "top_p": 0.9
}
```

**Response:**
```json
{
  "id": "chatcmpl-1234567890.0",
  "content": "Machine learning is a subset of artificial intelligence...",
  "model": "gemma-4",
  "usage": {
    "promptTokens": 10,
    "completionTokens": 50,
    "totalTokens": 60
  }
}
```

## Testing

Use the provided test client:

```bash
python test-client.py
```

Or use curl:

```bash
# Health check
curl http://localhost:8000/health

# Chat completion
curl -X POST http://localhost:8000/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [{"role": "user", "content": "Hello!"}],
    "model": "gemma-4"
  }'
```

## Model Information

### Llama 3.1 8B
- **Context Window**: 4096 tokens
- **Quantization**: Q8_0 (8-bit)
- **Size**: ~7.2 GB VRAM
- **Best For**: Complex reasoning, long-form content
- **Speed**: Slower but more accurate

### Gemma 4
- **Context Window**: 2048 tokens
- **Quantization**: Q8_0 (8-bit)
- **Size**: ~1.8 GB VRAM
- **Best For**: Quick responses, lightweight tasks
- **Speed**: Fast and efficient

## Performance Tips

1. **GPU Offloading**: Set `n_gpu_layers=-1` to offload all layers (faster)
2. **Temperature**: Lower (0.3-0.5) for deterministic responses, higher (0.7-1.0) for creative
3. **Max Tokens**: Balance between response length and speed
4. **Batch Processing**: Support for multiple concurrent requests

## Troubleshooting

### Model Loading Fails
- Check file paths in `main.py`
- Ensure models are in `./models/` directory
- Verify GGUF files aren't corrupted: `ls -lh models/`

### Out of Memory (OOM)
- Reduce `n_gpu_layers` (try 20-30 instead of -1)
- Use smaller model (Gemma instead of Llama)
- Reduce `max_tokens` in requests

### Slow Generation
- Ensure GPU is being used: Monitor with `nvidia-smi`
- Check if models are loading on GPU in startup logs
- Try reducing `context_window` size

### CUDA Errors
- Reinstall `torch` with proper CUDA support:
  ```bash
  pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
  ```

## Architecture

```
Frontend (React)
     ↓ HTTP/WebSocket
  [Proxy: localhost:3000 → localhost:8000]
     ↓
FastAPI Backend
     ├─ /health
     ├─ /models
     └─ /chat/completions
          ↓
    llama-cpp-python
          ↓
    Llama 3.1 8B / Gemma 4
          ↓
       GPU (CUDA)
```

## File Structure

```
backend/
├── main.py              # FastAPI server (main entry point)
├── setup-models.py      # Model download script
├── test-client.py       # Test client for debugging
├── requirements.txt     # Python dependencies
├── .env.example         # Environment template
├── models/              # Model storage directory
│   ├── llama-3.1-8b-q8_0.gguf
│   └── gemma-4-E2B-it-Q8_0.gguf
└── README.md            # This file
```

## Next Steps

1. Download models using `setup-models.py`
2. Start the server: `python main.py`
3. Test with curl or the provided test client
4. Connect frontend and start chatting!

## Contributing

- Add support for more models
- Implement streaming responses
- Add rate limiting
- Implement authentication
- Add conversation history/database

## License

MIT
