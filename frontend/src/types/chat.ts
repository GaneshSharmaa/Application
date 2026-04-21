export interface Message {
  id: string;
  role: 'user' | 'assistant';
  content: string;
  timestamp: Date;
  model?: string;
}

export interface ChatSession {
  id: string;
  title: string;
  messages: Message[];
  createdAt: Date;
  updatedAt: Date;
}

export interface Model {
  id: string;
  name: string;
  description: string;
  available: boolean;
}

export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: string;
}

export interface ChatCompletionRequest {
  messages: { role: 'user' | 'assistant'; content: string }[];
  model: string;
  temperature?: number;
  maxTokens?: number;
}

export interface ChatCompletionResponse {
  id: string;
  content: string;
  model: string;
  usage: {
    promptTokens: number;
    completionTokens: number;
    totalTokens: number;
  };
}
