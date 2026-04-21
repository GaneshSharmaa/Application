# Mitra AI - Complete Setup Guide

This is a full-stack chat application with a React frontend and FastAPI backend running quantized LLM models locally.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                     Frontend (React)                         │
│                  localhost:3000                              │
│  - Chat UI with glassmorphism design                        │
│  - Model selection dropdown                                  │
│  - Message history with actions                              │
│  - Responsive design (mobile & desktop)                      │
└────────────────────────┬────────────────────────────────────┘
                         │ HTTP/CORS
┌────────────────────────▼────────────────────────────────────┐
│                    Backend (FastAPI)                         │
│                  localhost:8000                              │
│  - Chat completions endpoint                                │
│  - Model management                                          │
│  - GPU acceleration (CUDA)                                   │
└────────────────────────┬────────────────────────────────────┘
                         │ llama-cpp-python
┌────────────────────────▼────────────────────────────────────┐
│                  LLM Inference Engine                        │
│  - Llama 3.1 8B (4096 context)                             │
│  - Gemma 4 (2048 context)                                  │
│  - Q8_0 Quantization (8-bit)                               │
└────────────────────────┬────────────────────────────────────┘
                         │ CUDA
                    GPU (RTX 4060+)
```

## Project Structure

```
Application/
├── frontend/                      # React + TypeScript UI
│   ├── src/
│   │   ├── components/           # React components
│   │   │   ├── ChatScreen.tsx    # Main container
│   │   │   ├── ChatHistory.tsx   # Message display
│   │   │   ├── ChatBubble.tsx    # Message bubble
│   │   │   ├── SearchBox.tsx     # Chat input
│   │   │   ├── ModelSelector.tsx # Model dropdown
│   │   │   └── Sidebar.tsx       # Navigation sidebar
│   │   ├── services/
│   │   │   └── apiService.ts     # API client
│   │   ├── types/
│   │   │   └── chat.ts           # TypeScript types
│   │   ├── App.tsx               # Root component
│   │   ├── main.tsx              # Entry point
│   │   └── index.css             # Global styles
│   ├── package.json
│   ├── vite.config.ts
│   ├── tsconfig.json
│   ├── tailwind.config.js
│   ├── index.html
│   └── README.md
│
├── backend/                       # FastAPI LLM Server
│   ├── main.py                   # FastAPI app (main entry point)
│   ├── setup-models.py           # Model downloader
│   ├── test-client.py            # API test client
│   ├── requirements.txt          # Python dependencies
│   ├── .env.example              # Environment template
│   ├── models/                   # Model storage
│   │   ├── llama-3.1-8b-q8_0.gguf
│   │   └── gemma-4-E2B-it-Q8_0.gguf
│   └── README.md
│
└── [other project files]
```

## Quick Start

### Prerequisites

- **Node.js 18+** (for frontend)
- **Python 3.9+** (for backend)
- **GPU with CUDA** (for acceleration)
- **16+ GB RAM**
- **10+ GB disk space** (for models)

### Step 1: Setup Backend

```bash
# Navigate to backend
cd backend

# Create Python virtual environment
python -m venv venv

# Activate virtual environment
# On Windows:
venv\Scripts\activate
# On macOS/Linux:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Download models (one-time)
python setup-models.py

# Start the server
python main.py
```

The backend will start at `http://localhost:8000`

Check it works: `curl http://localhost:8000/health`

### Step 2: Setup Frontend

```bash
# In a new terminal, navigate to frontend
cd frontend

# Install dependencies
npm install

# Start development server
npm run dev
```

The frontend will start at `http://localhost:3000`

### Step 3: Start Chatting!

1. Open `http://localhost:3000` in your browser
2. Select a model from the dropdown
3. Type a message and press Enter
4. Watch the response stream in!

## API Documentation

### Available Endpoints

#### Health Check
```bash
curl http://localhost:8000/health
```

#### List Models
```bash
curl http://localhost:8000/models
```

#### Chat Completion
```bash
curl -X POST http://localhost:8000/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [
      {"role": "user", "content": "What is AI?"}
    ],
    "model": "gemma-4",
    "temperature": 0.7,
    "max_tokens": 500
  }'
```

Interactive API docs: http://localhost:8000/docs

## Model Information

### Gemma 4 (Recommended for Most Users)
- **Size**: ~1.8 GB VRAM
- **Context**: 2048 tokens
- **Speed**: Fast (3-5 sec/response)
- **Use Case**: Quick responses, general questions
- **Quantization**: Q8_0 (8-bit)

### Llama 3.1 8B
- **Size**: ~7.2 GB VRAM
- **Context**: 4096 tokens
- **Speed**: Slower (8-12 sec/response)
- **Use Case**: Complex reasoning, long-form content
- **Quantization**: Q8_0 (8-bit)

## Performance Tips

1. **GPU Usage**: Both models fully offload to GPU (n_gpu_layers=-1)
2. **Temperature**: 0.3-0.5 for factual, 0.7-1.0 for creative
3. **Context**: Don't exceed 2048 for Gemma, 4096 for Llama
4. **Concurrent Requests**: Backend handles multiple requests in queue

## Troubleshooting

### Frontend Won't Connect to Backend
- Check backend is running: `curl http://localhost:8000/health`
- Check CORS is enabled in backend
- Verify VITE_API_URL in frontend .env

### Models Not Loading
- Check models are in `backend/models/` directory
- Run `python setup-models.py` to download
- Check HuggingFace links in README

### Out of Memory (OOM)
- Try Gemma instead of Llama
- Reduce max_tokens to 250-300
- Close other GPU-intensive apps
- Check GPU memory: `nvidia-smi`

### Slow Generation
- Monitor GPU usage: `nvidia-smi` (should show ~90%+)
- Try different temperature/top_p values
- Ensure no other processes using GPU

## Development

### Frontend Development
```bash
cd frontend
npm run dev      # Start dev server with HMR
npm run build    # Build for production
npm run preview  # Preview production build
```

### Backend Development
```bash
cd backend
source venv/bin/activate
python main.py  # Auto-reloads on code changes
```

### Testing
```bash
# Frontend
cd frontend
npm run lint

# Backend
cd backend
python test-client.py
```

## Deployment

### Frontend
```bash
cd frontend
npm run build
# Output in dist/
# Deploy to Vercel, Netlify, GitHub Pages, etc.
```

### Backend
```bash
# For production, use a process manager like supervisord or systemd
# Or deploy to cloud: AWS, GCP, Azure, DigitalOcean, etc.
```

## Features Implemented

✅ Dual LLM model support (Llama 3.1 + Gemma 4)
✅ Chat interface with message history
✅ Model selection dropdown
✅ GPU acceleration (CUDA)
✅ Quantized models (Q8_0 GGUF)
✅ Responsive design
✅ Action buttons (copy, refresh, like, dislike)
✅ Loading states
✅ Error handling
✅ Health checks
✅ CORS enabled for frontend

## Future Enhancements

- [ ] Streaming responses (WebSocket)
- [ ] Chat history persistence (database)
- [ ] User authentication
- [ ] Conversation export (PDF, JSON)
- [ ] Custom prompt templates
- [ ] Markdown rendering
- [ ] Code syntax highlighting
- [ ] Voice input/output
- [ ] Rate limiting
- [ ] Analytics

## Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## License

MIT License

## Support

For issues or questions:
1. Check the README files in `frontend/` and `backend/`
2. Review API documentation at `http://localhost:8000/docs`
3. Check GitHub issues
4. Open a new issue with details

## Acknowledgments

- FastAPI for the excellent web framework
- llama-cpp-python for efficient LLM inference
- HuggingFace for model hosting
- Meta (Llama) and Google (Gemma) for models
- React and TypeScript communities

---

**Happy Chatting! 🚀**
