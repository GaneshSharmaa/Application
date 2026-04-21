# Mitra AI - Quick Reference Card

## 🚀 Quick Start (5 Minutes)

```bash
# 1. Clone/navigate to project
cd Application

# 2. Run setup script
bash setup.sh              # Linux/Mac
setup.bat                  # Windows

# 3. Start backend (Terminal 1)
cd backend
python main.py

# 4. Start frontend (Terminal 2)
cd frontend
npm run dev

# 5. Open browser
http://localhost:3000
```

## 📁 Key Files

| File | Purpose |
|------|---------|
| `backend/main.py` | FastAPI server - RUN THIS |
| `frontend/src/components/ChatScreen.tsx` | Main chat UI |
| `frontend/src/services/apiService.ts` | API client |
| `backend/setup-models.py` | Download LLM models |
| `backend/requirements.txt` | Python dependencies |
| `frontend/package.json` | Node.js dependencies |

## 🌐 URLs

| Service | URL |
|---------|-----|
| Frontend | http://localhost:3000 |
| Backend | http://localhost:8000 |
| API Docs | http://localhost:8000/docs |
| Backend Health | http://localhost:8000/health |

## 📊 API Quick Reference

### Health Check
```bash
curl http://localhost:8000/health
```

### List Models
```bash
curl http://localhost:8000/models
```

### Chat
```bash
curl -X POST http://localhost:8000/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [{"role": "user", "content": "Hello!"}],
    "model": "gemma-4"
  }'
```

## 🎯 Useful Commands

### Backend Commands
```bash
# Setup
cd backend
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Download models
python setup-models.py

# Run server
python main.py

# Test
python test-client.py
```

### Frontend Commands
```bash
# Setup
cd frontend
npm install

# Development
npm run dev

# Build
npm run build

# Preview production
npm run preview

# Lint
npm run lint
```

## 🐛 Troubleshooting

| Problem | Solution |
|---------|----------|
| Port 8000 in use | Kill process or use different port |
| Port 3000 in use | Kill process or use different port |
| Models not found | Run `python backend/setup-models.py` |
| Out of memory | Use Gemma instead of Llama |
| Backend not responding | Check `http://localhost:8000/health` |
| Frontend shows errors | Open DevTools (F12) and check console |

## 📊 Model Specs

```
GEMMA 4 (Recommended)
├─ Size: 1.8 GB VRAM
├─ Context: 2048 tokens
├─ Speed: Fast ⚡⚡⚡
└─ Best for: Quick answers

LLAMA 3.1 8B
├─ Size: 7.2 GB VRAM
├─ Context: 4096 tokens
├─ Speed: Slower ⚡
└─ Best for: Complex reasoning
```

## 🔧 Configuration

### Environment Variables

Create `.env` in backend/:
```
LLAMA_MODEL_PATH=./models/llama-3.1-8b-q8_0.gguf
GEMMA_MODEL_PATH=./models/gemma-4-E2B-it-Q8_0.gguf
HOST=0.0.0.0
PORT=8000
GPU_LAYERS=-1
```

Create `.env` in frontend/ (optional):
```
VITE_API_URL=http://localhost:8000
```

## 📈 Performance

- Gemma 4: 3-5 sec per response ⚡⚡⚡
- Llama 3.1: 8-12 sec per response ⚡
- Context limit: 2048 (Gemma), 4096 (Llama)
- Batch size: 1 (single request at a time)

## 🎨 Tech Stack

```
Frontend        Backend         Infrastructure
├─ React 18     ├─ FastAPI      ├─ Docker
├─ TypeScript   ├─ Python 3.11  ├─ CUDA
├─ Tailwind     ├─ llama-cpp    ├─ GGUF
└─ Vite         └─ Uvicorn      └─ Q8_0
```

## 📝 Common Tasks

### Run locally with defaults
```bash
python backend/main.py &
npm run dev --prefix frontend
# Open http://localhost:3000
```

### Deploy with Docker
```bash
docker-compose up --build
```

### Production build
```bash
cd frontend
npm run build
# dist/ folder ready for deployment
```

### Monitor GPU
```bash
watch -n 1 nvidia-smi
```

## 🚨 Common Errors

| Error | Fix |
|-------|-----|
| `Connection refused` | Backend not running on port 8000 |
| `Model not found` | Download models with `setup-models.py` |
| `Out of memory` | Use Gemma model instead |
| `CUDA error` | Update nvidia drivers or torch |
| `Port already in use` | Kill the process using the port |

## ✅ Checklist

- [ ] Python 3.9+ installed
- [ ] Node.js 18+ installed
- [ ] GPU with CUDA support
- [ ] 16GB+ RAM
- [ ] 20GB+ disk space
- [ ] Models downloaded (`python setup-models.py`)
- [ ] Backend running (`python main.py`)
- [ ] Frontend running (`npm run dev`)
- [ ] Can open http://localhost:3000
- [ ] Can select model and chat

## 📚 Documentation

- Full guide: `SETUP_GUIDE.md`
- Backend docs: `backend/README.md`
- Frontend docs: `frontend/README.md`
- API docs: http://localhost:8000/docs

## 🆘 Help

1. Check README files
2. Check SETUP_GUIDE.md
3. Review API docs at `/docs`
4. Check console logs (F12)
5. Try test client: `python backend/test-client.py`

---

**Last Updated**: April 2026
**Version**: 1.0
