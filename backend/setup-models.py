#!/usr/bin/env python3
"""
Setup script: Download quantized GGUF models for MITRA.
This saves you from manual downloads and ensures consistent paths.
"""

import os
import subprocess
import requests
from pathlib import Path

# Create models directory
MODELS_DIR = Path("./models")
MODELS_DIR.mkdir(exist_ok=True)

print("=" * 70)
print("MITRA Model Setup")
print("=" * 70)

# ============================================================================
# MODEL SOURCES (Pre-quantized GGUF from HuggingFace)
# ============================================================================

MODELS = {
    "llama": {
        "name": "Meta-Llama-3.1-8B-Instruct-GGUF",
        "repo": "QuantFactory/Meta-Llama-3.1-8B-Instruct-GGUF",
        "filename": "Meta-Llama-3.1-8B-Instruct.Q8_0.gguf",
        "local_path": MODELS_DIR / "llama-3.1-8b-q8_0.gguf",
        "size_gb": 7.2
    },
    "gemma": {
        "name": "Gemma-4-E2B-it-GGUF",
        "repo": "unsloth/gemma-4-E2B-it-GGUF",
        "filename": "gemma-4-E2B-it.Q8_0.gguf",
        "local_path": MODELS_DIR / "gemma-4-E2B-it.Q8_0.gguf",
        "size_gb": 1.8
    }
}

def download_model(repo: str, filename: str, local_path: Path) -> bool:
    """Download GGUF model from HuggingFace Hub."""
    
    if local_path.exists():
        print(f"✓ {local_path.name} already exists. Skipping...")
        return True
    
    url = f"https://huggingface.co/{repo}/resolve/main/{filename}"
    
    print(f"\n📥 Downloading {filename}...")
    print(f"   From: {url}")
    print(f"   To: {local_path}")
    
    try:
        # Use subprocess with aria2c for faster, resumable downloads (if available)
        # Fallback to requests if aria2c not installed
        result = subprocess.run(
            ["aria2c", "-x", "16", "-k", "1M", "-o", str(local_path), url],
            capture_output=True
        )
        
        if result.returncode == 0 and local_path.exists():
            print(f"✓ Downloaded successfully!")
            return True
        else:
            print("⚠ aria2c not available or failed. Using requests instead...")
    except FileNotFoundError:
        print("⚠ aria2c not installed. Using requests (slower)...")
    
    # Fallback: use requests
    try:
        response = requests.get(url, stream=True)
        response.raise_for_status()
        
        total_size = int(response.headers.get('content-length', 0))
        downloaded = 0
        
        with open(local_path, 'wb') as f:
            for chunk in response.iter_content(chunk_size=8192):
                if chunk:
                    f.write(chunk)
                    downloaded += len(chunk)
                    # Progress bar
                    if total_size:
                        pct = (downloaded / total_size) * 100
                        print(f"   Progress: {pct:.1f}%", end='\r')
        
        print(f"\n✓ Downloaded successfully!")
        return True
    
    except Exception as e:
        print(f"✗ Error downloading: {e}")
        return False

def main():
    print("\nThis will download pre-quantized GGUF models to ./models/")
    print("\nTotal space needed:")
    total_size = sum(m["size_gb"] for m in MODELS.values())
    print(f"  • Llama 3.1 (8B): {MODELS['llama']['size_gb']} GB")
    print(f"  • Gemma 2B: {MODELS['gemma']['size_gb']} GB")
    print(f"  TOTAL: ~{total_size} GB")
    
    response = input("\nProceed with download? (y/n): ").strip().lower()
    if response != 'y':
        print("Cancelled.")
        return
    
    # Download models
    downloaded_count = 0
    for model_name, model_info in MODELS.items():
        success = download_model(
            repo=model_info["repo"],
            filename=model_info["filename"],
            local_path=model_info["local_path"]
        )
        if success:
            downloaded_count += 1
    
    # Summary
    print("\n" + "=" * 70)
    print("Setup Summary")
    print("=" * 70)
    print(f"✓ Models ready: {downloaded_count}/{len(MODELS)}")
    print(f"✓ Models directory: {MODELS_DIR.resolve()}")
    
    # List downloaded models
    print("\nDownloaded models:")
    for model_name, model_info in MODELS.items():
        if model_info["local_path"].exists():
            size_mb = model_info["local_path"].stat().st_size / (1024 ** 2)
            print(f"  ✓ {model_name}: {size_mb:.1f} MB")
        else:
            print(f"  ✗ {model_name}: NOT FOUND")
    
    print("\n" + "=" * 70)
    print("Next: Run the FastAPI server")
    print("=" * 70)
    print("\nCommand:")
    print("  python mitra_fastapi_main.py")
    print("\nThen test with:")
    print("  curl -X POST http://127.0.0.1:8000/generate \\")
    print("    -H 'Content-Type: application/json' \\")
    print("    -d '{\"prompt\": \"Hello\", \"model\": \"gemma\"}'")
    print("\nAPI Docs: http://127.0.0.1:8000/docs")
    print("=" * 70)

if __name__ == "__main__":
    main()
