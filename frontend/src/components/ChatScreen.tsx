import React, { useState, useEffect } from 'react';
import { ChatHistory } from './ChatHistory';
import { SearchBox } from './SearchBox';
import { ModelSelector } from './ModelSelector';
import { Sidebar } from './Sidebar';
import apiService from '../services/apiService';
import type { Message, Model } from '../types/chat';

export const ChatScreen: React.FC = () => {
  const [messages, setMessages] = useState<Message[]>([]);
  const [inputValue, setInputValue] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [models, setModels] = useState<Model[]>([]);
  const [selectedModel, setSelectedModel] = useState<string>('');
  const [isLoadingModels, setIsLoadingModels] = useState(true);
  const [sidebarOpen, setSidebarOpen] = useState(false);

  // Load available models on mount
  useEffect(() => {
    const loadModels = async () => {
      try {
        const availableModels = await apiService.getModels();
        setModels(availableModels);
        if (availableModels.length > 0) {
          setSelectedModel(availableModels[0].id);
        }
      } catch (error) {
        console.error('Failed to load models:', error);
        // Set default models for demo
        const defaultModels: Model[] = [
          {
            id: 'gemma-4',
            name: 'Gemma 4',
            description: 'Quantized model',
            available: true,
          },
          {
            id: 'llama-3.1-8b',
            name: 'Llama 3.1 8B',
            description: 'Large language model',
            available: true,
          },
        ];
        setModels(defaultModels);
        setSelectedModel(defaultModels[0].id);
      } finally {
        setIsLoadingModels(false);
      }
    };

    loadModels();
  }, []);

  const handleSendMessage = async () => {
    if (!inputValue.trim() || isLoading) return;

    // Add user message
    const userMessage: Message = {
      id: Date.now().toString(),
      role: 'user',
      content: inputValue,
      timestamp: new Date(),
    };

    setMessages((prev) => [...prev, userMessage]);
    setInputValue('');
    setIsLoading(true);

    try {
      // Call API
      const response = await apiService.chatCompletion({
        messages: messages.map((m) => ({
          role: m.role,
          content: m.content,
        })),
        model: selectedModel,
      });

      // Add assistant message
      const assistantMessage: Message = {
        id: (Date.now() + 1).toString(),
        role: 'assistant',
        content: response.content,
        timestamp: new Date(),
        model: response.model,
      };

      setMessages((prev) => [...prev, assistantMessage]);
    } catch (error) {
      console.error('Failed to get response:', error);
      // Add error message
      const errorMessage: Message = {
        id: (Date.now() + 1).toString(),
        role: 'assistant',
        content: 'Something went wrong with OpenAI 😓',
        timestamp: new Date(),
      };
      setMessages((prev) => [...prev, errorMessage]);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="h-screen flex flex-col bg-black">
      {/* Header */}
      <div className="bg-black py-4 px-4 flex justify-between items-center">
        <button
          onClick={() => setSidebarOpen(!sidebarOpen)}
          className="p-2 hover:bg-gray-800 rounded-lg transition-colors"
        >
          <svg className="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
          </svg>
        </button>

        <h1 className="text-xl font-semibold text-white flex-1 text-center">Mitra AI</h1>

        <button className="p-2 hover:bg-gray-800 rounded-full transition-colors">
          <svg className="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
          </svg>
        </button>
      </div>

      <div className="flex flex-1 overflow-hidden">
        {/* Sidebar */}
        <Sidebar isOpen={sidebarOpen} onClose={() => setSidebarOpen(false)} />

        {/* Main Chat Area */}
        <div className="flex-1 flex flex-col">
          {/* Chat History */}
          <ChatHistory messages={messages} isLoading={isLoading} />

          {/* Input Area */}
          <SearchBox
            value={inputValue}
            onChange={setInputValue}
            onSubmit={handleSendMessage}
            isLoading={isLoading}
          />
        </div>
      </div>
    </div>
  );
};
