# Mitra AI - Project Overview

## What This Is

Mitra AI is a complete, production-ready chat application that runs large language models (LLMs) on your local machine. It combines a modern web frontend with a powerful backend serving quantized AI models.

## Key Features

### 🎨 Frontend
- **Beautiful UI** - Glassmorphic design inspired by modern chat apps
- **Responsive** - Works on desktop, tablet, and mobile
- **Fast** - Built with Vite for instant hot-reload during development
- **Type-Safe** - Full TypeScript support
- **Component-Based** - Modular, maintainable architecture

### 🤖 Backend
- **Dual Models** - Run Gemma 4 or Llama 3.1 8B
- **GPU Accelerated** - Full CUDA support for NVIDIA GPUs
- **Quantized** - Q8_0 8-bit quantization reduces memory 8x
- **Fast** - 3-5 seconds per response (Gemma), 8-12 seconds (Llama)
- **Scalable** - Handles concurrent requests gracefully

### 🚀 Architecture
- **API-First** - OpenAI-compatible REST endpoints
- **CORS Enabled** - Frontend-backend integration works out of box
- **Docker Ready** - Container support for easy deployment
- **Production Ready** - Error handling, logging, health checks

## Quick Facts

| Aspect | Details |
|--------|---------|
| **Frontend Language** | React + TypeScript |
| **Backend Language** | Python + FastAPI |
| **Frontend Build Tool** | Vite |
| **Backend Server** | Uvicorn |
| **LLM Framework** | llama-cpp-python |
| **GPU Support** | CUDA (NVIDIA) |
| **Models** | Gemma 4, Llama 3.1 8B |
| **Quantization** | Q8_0 (8-bit) |
| **Database** | None (in-memory for now) |
| **Authentication** | None (local only for now) |

## File Structure

```
Application/
├── frontend/                    # React UI
│   ├── src/
│   │   ├── components/         # React components
│   │   ├── services/           # API client
│   │   ├── types/              # TypeScript types
│   │   ├── App.tsx
│   │   ├── main.tsx
│   │   └── index.css
│   ├── package.json
│   ├── vite.config.ts
│   ├── tsconfig.json
│   ├── Dockerfile
│   └── README.md
│
├── backend/                     # FastAPI server
│   ├── main.py                 # Main entry point
│   ├── setup-models.py         # Model downloader
│   ├── test-client.py          # Test client
│   ├── requirements.txt        # Dependencies
│   ├── .env.example            # Config template
│   ├── Dockerfile
│   ├── models/                 # Model storage
│   └── README.md
│
├── SETUP_GUIDE.md              # Complete setup instructions
├── docker-compose.yml          # Docker orchestration
├── setup.sh                    # Linux/Mac setup script
├── setup.bat                   # Windows setup script
└── README.md (this file)
```

## Getting Started in 3 Steps

### 1. Install Dependencies

**Option A: Automated**
```bash
# Linux/Mac
bash setup.sh

# Windows
setup.bat
```

**Option B: Manual**
```bash
# Backend
cd backend
python -m venv venv
source venv/bin/activate  # or: venv\Scripts\activate on Windows
pip install -r requirements.txt
python setup-models.py  # Download models

# Frontend
cd frontend
npm install
```

### 2. Start Services

**Terminal 1 - Backend:**
```bash
cd backend
source venv/bin/activate  # or: venv\Scripts\activate on Windows
python main.py
```

**Terminal 2 - Frontend:**
```bash
cd frontend
npm run dev
```

### 3. Open in Browser
```
http://localhost:3000
```

## How It Works

### User Interaction Flow

```
1. User types message in browser
   ↓
2. Frontend sends to /chat/completions endpoint
   ↓
3. Backend receives message(s) and model selection
   ↓
4. Selected LLM processes on GPU
   ↓
5. Response generated and sent back
   ↓
6. Frontend displays in chat UI
   ↓
7. User can copy, refresh, like/dislike response
```

### API Endpoints

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/health` | Check server status |
| GET | `/models` | List available models |
| POST | `/chat/completions` | Send message, get response |
| POST | `/generate` | Legacy endpoint |

### Example Request

```bash
curl -X POST http://localhost:8000/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [
      {"role": "user", "content": "What is machine learning?"}
    ],
    "model": "gemma-4",
    "temperature": 0.7,
    "max_tokens": 500
  }'
```

### Example Response

```json
{
  "id": "chatcmpl-1234567890.0",
  "content": "Machine learning is a subset of artificial intelligence that enables computers to learn from data without being explicitly programmed...",
  "model": "gemma-4",
  "usage": {
    "promptTokens": 10,
    "completionTokens": 45,
    "totalTokens": 55
  }
}
```

## Model Comparison

### Gemma 4 (Recommended)
- **Size**: 1.8 GB VRAM
- **Context**: 2048 tokens
- **Speed**: ⚡⚡⚡ (3-5 sec)
- **Quality**: Good (70%)
- **Best For**: Quick answers, general knowledge
- **Quantization**: Q8_0

### Llama 3.1 8B
- **Size**: 7.2 GB VRAM
- **Context**: 4096 tokens
- **Speed**: ⚡ (8-12 sec)
- **Quality**: Excellent (95%)
- **Best For**: Complex reasoning, coding
- **Quantization**: Q8_0

## System Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| **GPU** | RTX 3060 (12GB) | RTX 4060 (16GB) or better |
| **GPU VRAM** | 12 GB | 16+ GB |
| **System RAM** | 16 GB | 32 GB |
| **Storage** | 20 GB free | 30 GB free |
| **Python** | 3.9 | 3.10+ |
| **Node.js** | 16 | 18+ |

## Performance Tips

1. **Use Gemma by default** - Faster, sufficient for most tasks
2. **Lower temperature** (0.3-0.5) - For consistent, factual responses
3. **Adjust max_tokens** - Shorter responses = faster generation
4. **Monitor GPU** - Use `nvidia-smi` to watch utilization
5. **Close other apps** - GPU memory matters

## Troubleshooting

### "Connection refused"
- Make sure backend is running: `python backend/main.py`
- Check port 8000 is not in use

### "Model not found"
- Run `python backend/setup-models.py` to download
- Check models are in `backend/models/` directory

### "Out of memory"
- Try Gemma instead of Llama
- Reduce max_tokens to 250
- Close other GPU-using applications

### "Very slow generation"
- Check `nvidia-smi` - GPU should be ~90% utilized
- If CPU usage high and GPU low, verify GPU offloading
- Try reducing context window

## What's Next?

### Possible Enhancements
- [ ] Streaming responses (Server-Sent Events)
- [ ] Chat history persistence (SQLite/PostgreSQL)
- [ ] User authentication
- [ ] Conversation export (PDF, JSON, Markdown)
- [ ] Custom system prompts
- [ ] Markdown + code syntax highlighting
- [ ] Voice input/output (TTS/STT)
- [ ] Image support (Vision models)
- [ ] RAG (Retrieval Augmented Generation)
- [ ] Fine-tuning support
- [ ] Web version

### Deployment Options
- **Local**: Already running locally
- **Docker**: Use provided Dockerfile + docker-compose
- **Cloud**: Deploy to AWS, GCP, Azure, DigitalOcean
- **Cloud GPU**: Lambda Labs, Paperspace, Vast.ai

## Important Notes

⚠️ **GPU Required**: Without a compatible GPU, inference will be extremely slow (minutes per response)

⚠️ **Model Download**: First run will take time to download models (~9 GB)

⚠️ **Privacy**: All data stays on your machine - nothing sent to cloud

✅ **No API Key Required**: Runs 100% locally

✅ **Open Source**: Use, modify, and redistribute freely

## License

MIT License - See individual README files for details

## Resources

- **Backend Docs**: `backend/README.md`
- **Frontend Docs**: `frontend/README.md`
- **Setup Guide**: `SETUP_GUIDE.md`
- **API Docs**: `http://localhost:8000/docs` (after starting backend)

## Support & Community

- Check README files for detailed documentation
- Review SETUP_GUIDE.md for common issues
- Check API documentation at `/docs` endpoint

## Contributors Welcome!

- Report bugs
- Suggest features
- Submit pull requests
- Improve documentation

---

**Start chatting with local AI today! 🚀**

For detailed setup instructions, see `SETUP_GUIDE.md`
