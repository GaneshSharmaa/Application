#!/usr/bin/env python3
"""
Test client for MITRA FastAPI backend.
Easily test both Llama and Gemma models.
"""

import httpx
import asyncio
import json
from typing import Optional

API_URL = "http://127.0.0.1:8000"

async def test_health():
    """Check if server is running and models are loaded."""
    print("\n" + "=" * 70)
    print("Health Check")
    print("=" * 70)
    
    try:
        async with httpx.AsyncClient(timeout=10.0) as client:
            response = await client.get(f"{API_URL}/health")
            response.raise_for_status()
            health = response.json()
            
            print(f"✓ Server is running")
            print(f"  Llama loaded: {health['llama_loaded']}")
            print(f"  Gemma loaded: {health['gemma_loaded']}")
            
            return True
    except Exception as e:
        print(f"✗ Server not running: {e}")
        return False

async def test_models():
    """List available models."""
    print("\n" + "=" * 70)
    print("Available Models")
    print("=" * 70)
    
    try:
        async with httpx.AsyncClient(timeout=10.0) as client:
            response = await client.get(f"{API_URL}/models")
            response.raise_for_status()
            models = response.json()
            
            for model_name, model_info in models["available_models"].items():
                status = "✓" if model_info["loaded"] else "✗"
                print(f"\n{status} {model_name.upper()}")
                print(f"  Name: {model_info['name']}")
                print(f"  Loaded: {model_info['loaded']}")
                print(f"  Quantization: {model_info['quantization']}")
                print(f"  Context: {model_info['context_window']} tokens")
    except Exception as e:
        print(f"✗ Error: {e}")

async def generate(
    prompt: str,
    model: str = "gemma",
    max_tokens: int = 300,
    temperature: float = 0.7,
    top_p: float = 0.9
):
    """Generate text from a prompt."""
    
    print("\n" + "=" * 70)
    print(f"Generating with {model.upper()}")
    print("=" * 70)
    print(f"Prompt: {prompt}\n")
    
    payload = {
        "prompt": prompt,
        "model": model,
        "max_tokens": max_tokens,
        "temperature": temperature,
        "top_p": top_p,
        "repeat_penalty": 1.1
    }
    
    try:
        async with httpx.AsyncClient(timeout=120.0) as client:
            response = await client.post(
                f"{API_URL}/generate",
                json=payload
            )
            response.raise_for_status()
            result = response.json()
            
            if result["status"] == "success":
                print(f"Response:\n{result['response']}\n")
                return result["response"]
            else:
                print(f"✗ Error: {result.get('error', 'Unknown error')}")
                return None
    
    except Exception as e:
        print(f"✗ Request failed: {e}")
        return None

async def interactive_mode():
    """Interactive chat mode."""
    print("\n" + "=" * 70)
    print("Interactive Mode (type 'quit' to exit)")
    print("=" * 70)
    print("Commands:")
    print("  model llama  - Switch to Llama 3.1")
    print("  model gemma  - Switch to Gemma 2B")
    print("  temp 0.5     - Set temperature")
    print("  quit         - Exit")
    print("=" * 70)
    
    current_model = "gemma"
    temperature = 0.7
    
    while True:
        try:
            user_input = input(f"\n[{current_model}] > ").strip()
            
            if not user_input:
                continue
            
            if user_input.lower() == "quit":
                print("Exiting...")
                break
            
            if user_input.startswith("model "):
                current_model = user_input.split()[1].lower()
                print(f"✓ Switched to {current_model}")
                continue
            
            if user_input.startswith("temp "):
                try:
                    temperature = float(user_input.split()[1])
                    print(f"✓ Temperature set to {temperature}")
                    continue
                except ValueError:
                    print("✗ Invalid temperature value")
                    continue
            
            # Generate response
            await generate(
                prompt=user_input,
                model=current_model,
                max_tokens=500,
                temperature=temperature
            )
        
        except KeyboardInterrupt:
            print("\n\nExiting...")
            break
        except Exception as e:
            print(f"✗ Error: {e}")

async def main():
    print("\n" + "=" * 70)
    print("MITRA FastAPI Test Client")
    print("=" * 70)
    
    # Check health
    if not await test_health():
        print("\n✗ Could not connect to server.")
        print("Make sure the server is running:")
        print("  python mitra_fastapi_main.py")
        return
    
    # List models
    await test_models()
    
    # Choose mode
    print("\n" + "=" * 70)
    print("Test Mode")
    print("=" * 70)
    print("1. Quick test (Gemma)")
    print("2. Quick test (Llama)")
    print("3. Interactive mode")
    print("4. Exit")
    
    choice = input("\nChoose: ").strip()
    
    if choice == "1":
        await generate(
            "Explain quantum computing in 2 sentences.",
            model="gemma",
            max_tokens=200
        )
    elif choice == "2":
        await generate(
            "Explain quantum computing in 2 sentences.",
            model="llama",
            max_tokens=200
        )
    elif choice == "3":
        await interactive_mode()
    else:
        print("Exiting.")

if __name__ == "__main__":
    asyncio.run(main())
