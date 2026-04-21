import React, { useState } from 'react';
import type { Model } from '../types/chat';

interface ModelSelectorProps {
  selectedModel: string;
  onModelChange: (modelId: string) => void;
  models: Model[];
  isLoading?: boolean;
}

export const ModelSelector: React.FC<ModelSelectorProps> = ({
  selectedModel,
  onModelChange,
  models,
  isLoading = false,
}) => {
  const [isOpen, setIsOpen] = useState(false);

  const currentModel = models.find((m) => m.id === selectedModel);

  return (
    <div className="relative">
      <button
        onClick={() => setIsOpen(!isOpen)}
        disabled={isLoading}
        className="bg-gray-800 hover:bg-gray-700 disabled:opacity-50 rounded-2xl px-3 py-2 text-white text-sm font-medium transition-all"
      >
        <span className="flex items-center space-x-2">
          <span>{currentModel?.name || 'Select Model'}</span>
          <svg
            className={`w-4 h-4 transition-transform ${isOpen ? 'rotate-180' : ''}`}
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 14l-7 7m0 0l-7-7m7 7V3" />
          </svg>
        </span>
      </button>

      {isOpen && (
        <div className="absolute top-full mt-2 w-64 bg-gray-800 rounded-2xl p-3 z-50 space-y-2 border border-gray-700">
          {models.length === 0 ? (
            <div className="text-center text-gray-400 text-sm py-2">No models available</div>
          ) : (
            models.map((model) => (
              <button
                key={model.id}
                onClick={() => {
                  onModelChange(model.id);
                  setIsOpen(false);
                }}
                disabled={!model.available}
                className={`w-full text-left px-3 py-2 rounded-lg transition-all ${
                  selectedModel === model.id
                    ? 'bg-blue-600 text-white'
                    : 'text-white hover:bg-gray-700'
                } ${!model.available ? 'opacity-50 cursor-not-allowed' : ''}`}
              >
                <div className="font-medium text-sm">{model.name}</div>
                <div className="text-xs opacity-70">{model.description}</div>
              </button>
            ))
          )}
        </div>
      )}
    </div>
  );
};
