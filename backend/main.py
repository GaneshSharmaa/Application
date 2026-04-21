import torch
from llama_cpp import Llama
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import logging
from typing import Optional, List
from datetime import datetime

# Logging setup
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

print("=" * 60)
print("Imported all necessary libraries!")
print("=" * 60)

# ============================================================================
# MODEL PATHS - Update these to your local paths
# ============================================================================
LLAMA_PATH = "./backend/models/llama-3.1-8b-q8_0.gguf"
GEMMA_PATH = "./backend/models/gemma-4-E2B-it-Q8_0.gguf"

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
    print("  Download from: https://huggingface.co/unsloth/gemma-4-E2B-it-GGUF")
    gemma_model = None
except Exception as e:
    print(f"✗ Error loading Gemma: {e}")
    gemma_model = None

# ============================================================================
# FASTAPI APP
# ============================================================================
app = FastAPI(title="MITRA - Dual Model Backend", version="2.0")

# Add CORS middleware for frontend integration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

print("\n✓ FastAPI app initialized with CORS!")

# ============================================================================
# PYDANTIC MODELS (Request/Response)
# ============================================================================

class Message(BaseModel):
    role: str  # "user" or "assistant"
    content: str

class ChatCompletionRequest(BaseModel):
    messages: List[Message]
    model: str = "gemma-4"  # Model ID
    temperature: float = 0.4
    max_tokens: int = 500
    top_p: float = 0.9

class ChatCompletionResponse(BaseModel):
    id: str
    content: str
    model: str
    usage: dict

class ModelInfo(BaseModel):
    id: str
    name: str
    description: str
    available: bool

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

def get_model_by_id(model_id: str):
    """Get model instance by ID."""
    if model_id == "gemma-4":
        return gemma_model, "gemma-4"
    elif model_id == "llama-3.1-8b":
        return llama_model, "llama-3.1-8b"
    else:
        return None, None

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
        "models": {
            "gemma-4": gemma_model is not None,
            "llama-3.1-8b": llama_model is not None,
        }
    }

@app.get("/models")
def list_models() -> List[ModelInfo]:
    """List available models."""
    models = []
    
    if gemma_model is not None:
        models.append(ModelInfo(
            id="gemma-4",
            name="Gemma 4",
            description="Quantized model",
            available=True
        ))
    
    if llama_model is not None:
        models.append(ModelInfo(
            id="llama-3.1-8b",
            name="Llama 3.1 8B",
            description="Large language model",
            available=True
        ))
    
    return models

@app.post("/chat/completions")
def chat_completions(request: ChatCompletionRequest) -> ChatCompletionResponse:
    """Chat completion endpoint compatible with OpenAI-like interface."""
    
    # Validate request
    if not request.messages:
        raise HTTPException(status_code=400, detail="No messages provided")
    
    # Get model
    model, model_name = get_model_by_id(request.model)
    if model is None:
        raise HTTPException(status_code=400, detail=f"Model {request.model} not available")
    
    logger.info(f"Chat completion request with {request.model}")
    
    # Prepare messages for the model
    messages = [
        {"role": msg.role, "content": msg.content}
        for msg in request.messages
    ]
    
    try:
        # Call the model
        output = model.create_chat_completion(
            messages=messages,
            max_tokens=request.max_tokens,
            temperature=request.temperature,
            top_p=request.top_p,
            repeat_penalty=1.1,
            stop=GLOBAL_STOP_TOKENS
        )
        
        response_text = output["choices"][0]["message"]["content"].strip()
        response_text = post_process_response(response_text)
        
        # Extract usage info
        usage = output.get("usage", {})
        
        logger.info(f"Successfully generated response ({len(response_text)} chars)")
        
        return ChatCompletionResponse(
            id=f"chatcmpl-{datetime.now().timestamp()}",
            content=response_text,
            model=request.model,
            usage={
                "promptTokens": usage.get("prompt_tokens", 0),
                "completionTokens": usage.get("completion_tokens", 0),
                "totalTokens": usage.get("total_tokens", 0),
            }
        )
    
    except Exception as e:
        logger.error(f"Error during chat completion: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/generate")
def generate_text(request: ChatCompletionRequest):
    """Legacy generate endpoint for backward compatibility."""
    try:
        return chat_completions(request)
    except HTTPException:
        raise

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
