# Troubleshooting Guide

## Backend Issues

### ❌ "Failed to load Llama/Gemma model"

**Cause**: Model files not found or corrupt

**Solutions**:
```bash
# 1. Check if models exist
ls -la backend/models/

# 2. If empty, download them
cd backend
python setup-models.py

# 3. Verify files are not corrupted
# Check file sizes match expected:
# - llama-3.1-8b-q8_0.gguf should be ~7.2 GB
# - gemma-4-E2B-it-Q8_0.gguf should be ~1.8 GB

# 4. If download fails, manual download from:
# https://huggingface.co/QuantFactory/Meta-Llama-3.1-8B-Instruct-GGUF
# https://huggingface.co/unsloth/gemma-4-E2B-it-GGUF
```

### ❌ "Address already in use" (Port 8000)

**Cause**: Another process using port 8000

**Solutions**:
```bash
# Find process using port 8000
lsof -i :8000          # Mac/Linux
netstat -ano | findstr :8000  # Windows

# Kill the process
kill -9 <PID>          # Mac/Linux
taskkill /PID <PID> /F # Windows

# Or use different port
# Edit main.py and change port 8000 to something else
```

### ❌ "Out of memory (OOM)"

**Cause**: GPU/system doesn't have enough memory

**Solutions**:
```python
# Option 1: Use Gemma instead (1.8 GB vs 7.2 GB)
# Select "gemma-4" instead of "llama-3.1-8b"

# Option 2: Reduce GPU layers (in main.py)
# Change: n_gpu_layers=-1
# To:     n_gpu_layers=20  (or lower)

# Option 3: Close other GPU apps
nvidia-smi  # Check GPU memory usage

# Option 4: Reduce max_tokens in API requests
max_tokens: 250  # instead of 500
```

### ❌ "CUDA error" or GPU not detected

**Cause**: NVIDIA GPU drivers not installed or torch not compiled for CUDA

**Solutions**:
```bash
# 1. Check GPU
nvidia-smi

# 2. Update drivers from nvidia.com

# 3. Reinstall torch with CUDA support
pip uninstall torch -y
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

# 4. Verify installation
python -c "import torch; print(torch.cuda.is_available())"
```

### ❌ "Connection timeout" when calling API

**Cause**: Backend not fully loaded or crashed

**Solutions**:
```bash
# 1. Check backend is running
curl http://localhost:8000/health

# 2. Wait longer - first request takes time to load model
# Gemma: 5-10 seconds to load
# Llama: 10-20 seconds to load

# 3. Check backend logs for errors
# Look at terminal where you ran 'python main.py'

# 4. Restart backend
# Stop: Ctrl+C in backend terminal
# Start: python main.py
```

### ❌ "502 Bad Gateway" from frontend

**Cause**: Backend crashed or not responding

**Solutions**:
```bash
# 1. Check backend health
curl http://localhost:8000/health

# 2. Check backend logs
# Terminal with backend should show errors

# 3. Restart backend
# Kill: Ctrl+C
# Start: python main.py

# 4. Check if port 8000 is accessible
# telnet localhost 8000
# or: curl http://127.0.0.1:8000/health
```

### ❌ "ImportError: No module named 'fastapi'"

**Cause**: Dependencies not installed

**Solutions**:
```bash
cd backend
pip install -r requirements.txt
# or reinstall in fresh venv
```

---

## Frontend Issues

### ❌ Port 3000 already in use

**Cause**: Another process using port 3000

**Solutions**:
```bash
# Find process using port 3000
lsof -i :3000          # Mac/Linux
netstat -ano | findstr :3000  # Windows

# Kill the process
kill -9 <PID>          # Mac/Linux
taskkill /PID <PID> /F # Windows

# Or use different port
npm run dev -- --port 3001
```

### ❌ "Cannot find module" errors

**Cause**: Dependencies not installed

**Solutions**:
```bash
cd frontend
npm install
# If still fails, try clean install
rm -rf node_modules
npm install
```

### ❌ "API is undefined" or blank responses

**Cause**: Backend not responding or CORS issue

**Solutions**:
```bash
# 1. Verify backend is running
curl http://localhost:8000/health

# 2. Check browser console (F12) for CORS error

# 3. Verify CORS is enabled in backend/main.py
# Should include: CORSMiddleware

# 4. Check API URL in frontend .env
# Should be: VITE_API_URL=http://localhost:8000
```

### ❌ "Model list empty"

**Cause**: Backend models failed to load

**Solutions**:
```bash
# 1. Check backend health endpoint
curl http://localhost:8000/models

# 2. Look at backend logs for error messages

# 3. Download models
cd backend
python setup-models.py

# 4. Restart backend
```

### ❌ Chat messages not appearing

**Cause**: API error or frontend bug

**Solutions**:
```bash
# 1. Open DevTools (F12) → Console tab

# 2. Check for JavaScript errors

# 3. Check Network tab
# - Should see POST request to /chat/completions
# - Should see 200 response

# 4. Verify response format
# Response should include: id, content, model, usage

# 5. Try test message with backend
python backend/test-client.py
```

### ❌ Slow response or "Loading..." never finishes

**Cause**: Model taking time or crashed request

**Solutions**:
```bash
# 1. First response always slower (model loading)
# Wait up to 30 seconds

# 2. Check GPU usage
nvidia-smi  # Should show GPU utilization

# 3. If GPU usage is 0%, model is on CPU (very slow)
# See "CUDA error" section above

# 4. Check backend logs for errors

# 5. Try simpler request
# Use Gemma instead of Llama
# Reduce max_tokens
```

---

## Docker Issues

### ❌ "Cannot connect to Docker daemon"

**Cause**: Docker not running

**Solutions**:
```bash
# Start Docker Desktop (if on Mac/Windows)
# Or on Linux: sudo systemctl start docker
```

### ❌ "NVIDIA runtime not found"

**Cause**: nvidia-docker not installed

**Solutions**:
```bash
# Install nvidia-docker
# Ubuntu/Debian:
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
sudo apt-get update && sudo apt-get install -y nvidia-docker2
sudo systemctl restart docker
```

### ❌ "Image build failed"

**Cause**: Missing files or dependency issues

**Solutions**:
```bash
# 1. Check all required files exist
ls backend/requirements.txt
ls frontend/package.json

# 2. Try rebuilding without cache
docker-compose build --no-cache

# 3. Check Dockerfile syntax
# Review backend/Dockerfile and frontend/Dockerfile
```

---

## General Troubleshooting

### 🔍 Enable Debug Logging

**Backend**:
```python
# Edit main.py, change logging level
logging.basicConfig(level=logging.DEBUG)  # was INFO
```

**Frontend**:
```typescript
// Add to src/services/apiService.ts
this.api.interceptors.response.use(
  (response) => {
    console.log('API Response:', response);
    return response;
  }
);
```

### 📊 Monitor System Resources

```bash
# GPU usage
nvidia-smi
watch -n 1 nvidia-smi  # Update every 1 second

# CPU/RAM usage
top                    # Mac/Linux
tasklist              # Windows
htop                  # Mac/Linux (if installed)
```

### 🔗 Test Connectivity

```bash
# Backend health
curl http://localhost:8000/health
curl http://127.0.0.1:8000/health

# List models
curl http://localhost:8000/models

# Test chat
curl -X POST http://localhost:8000/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [{"role": "user", "content": "test"}],
    "model": "gemma-4"
  }'

# Frontend (if running)
curl http://localhost:3000
```

### 🔄 Clean Restart

```bash
# Kill both services
pkill -f "python main.py"
pkill -f "npm run dev"

# Wait 5 seconds
sleep 5

# Start fresh
cd backend && python main.py &
cd frontend && npm run dev &
```

### 📝 Collect Debug Info

When asking for help, provide:
```bash
# 1. OS and Python version
python --version
uname -a  # or: systeminfo on Windows

# 2. GPU info
nvidia-smi

# 3. Error messages
# (Copy from backend/frontend terminal or browser console)

# 4. What you tried
# (Include steps to reproduce)
```

---

## Still Having Issues?

1. **Check README files**:
   - `README.md` - Project overview
   - `SETUP_GUIDE.md` - Detailed setup
   - `backend/README.md` - Backend docs
   - `frontend/README.md` - Frontend docs

2. **Check API documentation**:
   - Start backend: `python backend/main.py`
   - Visit: `http://localhost:8000/docs`

3. **Try the test client**:
   ```bash
   python backend/test-client.py
   ```

4. **Review code comments**:
   - `backend/main.py` - Well commented
   - `frontend/src/components/ChatScreen.tsx` - Component logic

5. **Check dependencies**:
   ```bash
   # Backend
   pip list | grep -E "fastapi|torch|llama"
   
   # Frontend
   npm list react typescript vite
   ```

---

## Performance Optimization

### If backend is slow:

1. **Use Gemma** (faster) instead of Llama
2. **Reduce max_tokens** from 500 to 250
3. **Check temperature** - lower (0.3) is deterministic, faster
4. **Monitor GPU** - ensure it's being used (`nvidia-smi`)

### If frontend is slow:

1. **Check Network** tab in DevTools (F12)
2. **Check API response time** - should be 3-12 seconds depending on model
3. **Reduce number of messages** in history (too many slows rendering)

---

**Need more help? Review the SETUP_GUIDE.md or check the docs at /docs**
