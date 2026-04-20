import torch
from llama_cpp import Llama
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import logging
from typing import Optional

# Logging setup
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

print("=" * 60)
print("Imported all necessary libraries!")
print("=" * 60)

# ============================================================================
# MODEL PATHS - Update these to your local paths
# ============================================================================
LLAMA_PATH = "./models/llama-3.1-8b-q8_0.gguf"     # Download from HF
GEMMA_PATH = "./models/gemma-4-E2B-it-Q8_0.gguf"   # Download from HF

print(f"Llama path: {LLAMA_PATH}")
print(f"Gemma path: {GEMMA_PATH}")

# ============================================================================
# GLOBAL CONFIGURATION
# ============================================================================
GLOBAL_STOP_TOKENS = [
    "<|eot_id|>", "<|end_of_text|>", "[INST]", "</s>",
    "\n\n\n", "\nQuestion:", "\nUser:", "\n###", "```", "# "
]

print("Defined stop tokens!")

# ============================================================================
# MODEL LOADING
# ============================================================================
print("\n" + "=" * 60)
print("Loading Llama 3.1 (8-bit)...")
print("=" * 60)
try:
    llama_model = Llama(
        model_path=LLAMA_PATH,
        n_gpu_layers=-1,  # Offload all layers to GPU
        n_ctx=4096,
        chat_format="llama-3",
        verbose=False
    )
    print("✓ Llama 3.1 loaded successfully!")
except FileNotFoundError:
    print(f"✗ Llama model not found at {LLAMA_PATH}")
    print("  Download from: https://huggingface.co/QuantFactory/Meta-Llama-3.1-8B-Instruct-GGUF")
    llama_model = None
except Exception as e:
    print(f"✗ Error loading Llama: {e}")
    llama_model = None

print("\n" + "=" * 60)
print("Loading Gemma 2B (8-bit)...")
print("=" * 60)
try:
    gemma_model = Llama(
        model_path=GEMMA_PATH,
        n_gpu_layers=-1,  # Offload all layers to GPU
        n_ctx=2048,
        chat_format="gemma",
        verbose=False
    )
    print("✓ Gemma 2B loaded successfully!")
except FileNotFoundError:
    print(f"✗ Gemma model not found at {GEMMA_PATH}")
    print("  Download from: https://huggingface.co/QuantFactory/Gemma-2-2b-Instruct-GGUF")
    gemma_model = None
except Exception as e:
    print(f"✗ Error loading Gemma: {e}")
    gemma_model = None

# ============================================================================
# FASTAPI APP
# ============================================================================
app = FastAPI(title="MITRA - Dual Model Backend", version="2.0")
print("\n✓ FastAPI app initialized!")

# ============================================================================
# PYDANTIC MODELS (Request/Response)
# ============================================================================
class GenerateRequest(BaseModel):
    prompt: str
    model: str = "llama"  # "llama" or "gemma"
    max_tokens: int = 500
    temperature: float = 0.3
    top_p: float = 0.9
    repeat_penalty: float = 1.25

class GenerateResponse(BaseModel):
    status: str
    response: Optional[str] = None
    model_used: str
    error: Optional[str] = None

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================
def post_process_response(response_text: str) -> str:
    """Clean up response by removing stop tokens."""
    for pattern in GLOBAL_STOP_TOKENS:
        if pattern in response_text:
            response_text = response_text.split(pattern)[0].strip()
            break
    return response_text

# ============================================================================
# API ENDPOINTS
# ============================================================================

@app.get("/health")
def health_check():
    """Health check endpoint."""
    return {
        "status": "ok",
        "llama_loaded": llama_model is not None,
        "gemma_loaded": gemma_model is not None
    }

@app.post("/generate", response_model=GenerateResponse)
def generate_text(req: GenerateRequest):
    """
    Generate text using either Llama 3.1 or Gemma 2B.
    
    Parameters:
    - prompt: Input text prompt
    - model: "llama" (default) or "gemma"
    - max_tokens: Maximum tokens to generate (default 500)
    - temperature: Sampling temperature (default 0.3)
    - top_p: Nucleus sampling parameter (default 0.9)
    - repeat_penalty: Penalty for repeated tokens (default 1.25)
    """
    
    # Validate prompt
    if not req.prompt or not req.prompt.strip():
        raise HTTPException(status_code=400, detail="No prompt provided")
    
    # Select model
    if req.model.lower() == "gemma":
        if gemma_model is None:
            raise HTTPException(status_code=503, detail="Gemma model not loaded")
        model = gemma_model
        chat_format = "gemma"
    else:  # default to llama
        if llama_model is None:
            raise HTTPException(status_code=503, detail="Llama model not loaded")
        model = llama_model
        chat_format = "llama-3"
    
    logger.info(f"Received request for {req.model} model. Prompt: {req.prompt[:80]}...")
    
    messages = [
        {"role": "user", "content": req.prompt}
    ]
    
    try:
        # Call the model
        output = model.create_chat_completion(
            messages=messages,
            max_tokens=req.max_tokens,
            temperature=req.temperature,
            top_p=req.top_p,
            repeat_penalty=req.repeat_penalty,
            stop=GLOBAL_STOP_TOKENS
        )
        
        response_text = output["choices"][0]["message"]["content"].strip()
        response_text = post_process_response(response_text)
        
        logger.info(f"Successfully generated response ({len(response_text)} chars)")
        
        return GenerateResponse(
            status="success",
            response=response_text,
            model_used=req.model
        )
    
    except Exception as e:
        logger.error(f"Error during generation: {e}")
        return GenerateResponse(
            status="error",
            model_used=req.model,
            error=str(e)
        )

@app.post("/generate/llama", response_model=GenerateResponse)
def generate_llama(req: GenerateRequest):
    """Shortcut endpoint for Llama 3.1 only."""
    req.model = "llama"
    return generate_text(req)

@app.post("/generate/gemma", response_model=GenerateResponse)
def generate_gemma(req: GenerateRequest):
    """Shortcut endpoint for Gemma 2B only."""
    req.model = "gemma"
    return generate_text(req)

@app.get("/models")
def list_models():
    """List available models and their status."""
    return {
        "available_models": {
            "llama": {
                "name": "Meta-Llama-3.1-8B-Instruct",
                "loaded": llama_model is not None,
                "quantization": "Q8_0",
                "context_window": 4096
            },
            "gemma": {
                "name": "Gemma-2-2b-Instruct",
                "loaded": gemma_model is not None,
                "quantization": "Q8_0",
                "context_window": 2048
            }
        }
    }

# ============================================================================
# RUN SERVER
# ============================================================================
if __name__ == "__main__":
    import uvicorn
    
    print("\n" + "=" * 60)
    print("Starting FastAPI server...")
    print("=" * 60)
    print("API available at: http://127.0.0.1:8000")
    print("Docs at: http://127.0.0.1:8000/docs")
    print("=" * 60 + "\n")
    
    uvicorn.run(
        app,
        host="0.0.0.0",
        port=8000,
        log_level="info"
    )
