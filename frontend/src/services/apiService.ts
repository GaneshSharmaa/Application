import axios, { AxiosInstance } from 'axios';
import type { ChatCompletionRequest, ChatCompletionResponse, Model } from '../types/chat';

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000';

class ApiService {
  private api: AxiosInstance;

  constructor() {
    this.api = axios.create({
      baseURL: API_BASE_URL,
      headers: {
        'Content-Type': 'application/json',
      },
    });

    // Add response interceptor for error handling
    this.api.interceptors.response.use(
      (response) => response,
      (error) => {
        console.error('API Error:', error);
        return Promise.reject(error);
      }
    );
  }

  // Chat completions
  async chatCompletion(request: { messages: Array<{ role: string; content: string }>; model: string; temperature?: number; maxTokens?: number }): Promise<ChatCompletionResponse> {
    const response = await this.api.post('/chat/completions', {
      messages: request.messages.map(m => ({
        role: m.role,
        content: m.content
      })),
      model: request.model,
      temperature: request.temperature ?? 0.7,
      max_tokens: request.maxTokens ?? 500,
      top_p: 0.9,
    });
    return response.data;
  }

  // Get available models
  async getModels(): Promise<Model[]> {
    const response = await this.api.get('/models');
    return response.data;
  }

  // Health check
  async healthCheck(): Promise<boolean> {
    try {
      await this.api.get('/health');
      return true;
    } catch {
      return false;
    }
  }

  // Stream chat completions (for future implementation)
  async streamChatCompletion(
    request: any,
    onChunk: (chunk: string) => void
  ): Promise<void> {
    const response = await this.api.post('/chat/completions/stream', request, {
      responseType: 'stream',
    });

    return new Promise((resolve, reject) => {
      response.data.on('data', (chunk: Buffer) => {
        onChunk(chunk.toString());
      });
      response.data.on('end', resolve);
      response.data.on('error', reject);
    });
  }
}

export default new ApiService();
