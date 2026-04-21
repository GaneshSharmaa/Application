import React, { useRef, useEffect, useState } from 'react';

interface SearchBoxProps {
  value: string;
  onChange: (value: string) => void;
  onSubmit: () => void;
  isLoading?: boolean;
  placeholder?: string;
}

export const SearchBox: React.FC<SearchBoxProps> = ({
  value,
  onChange,
  onSubmit,
  isLoading = false,
  placeholder = 'Ask anything',
}) => {
  const textareaRef = useRef<HTMLTextAreaElement>(null);
  const [isRecording, setIsRecording] = useState(false);

  useEffect(() => {
    if (textareaRef.current) {
      textareaRef.current.style.height = 'auto';
      textareaRef.current.style.height = Math.min(textareaRef.current.scrollHeight, 100) + 'px';
    }
  }, [value]);

  const handleKeyDown = (e: React.KeyboardEvent<HTMLTextAreaElement>) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      onSubmit();
    }
  };

  const handleMicrophone = () => {
    setIsRecording(!isRecording);
  };

  return (
    <div className="bg-gray-900 border border-purple-500/30 rounded-3xl px-4 py-3 flex gap-3 items-end mx-4 mb-6">
      <textarea
        ref={textareaRef}
        value={value}
        onChange={(e) => onChange(e.target.value)}
        onKeyDown={handleKeyDown}
        disabled={isLoading}
        placeholder={placeholder}
        className="flex-1 bg-transparent text-white placeholder-gray-400 outline-none resize-none max-h-24 text-base"
        rows={1}
      />
      <div className="flex gap-2">
        <button
          onClick={handleMicrophone}
          disabled={isLoading}
          className={`p-2 rounded-full transition-all flex items-center justify-center ${
            isRecording ? 'bg-red-500' : 'hover:bg-gray-700'
          }`}
          title="Voice input"
        >
          <svg className="w-5 h-5 text-white" fill="currentColor" viewBox="0 0 24 24">
            <path d="M12 14c1.66 0 3-1.34 3-3V5c0-1.66-1.34-3-3-3S9 3.34 9 5v6c0 1.66 1.34 3 3 3z" />
            <path d="M17 16.91c-1.48 1.46-3.51 2.36-5.77 2.36-2.26 0-4.29-.9-5.77-2.36M9 18.9v3.04h6V18.9" />
          </svg>
        </button>
        <button
          onClick={onSubmit}
          disabled={isLoading || !value.trim()}
          className="p-2 rounded-full hover:bg-gray-700 disabled:opacity-50 disabled:cursor-not-allowed transition-all flex items-center justify-center"
          title="Send"
        >
          {isLoading ? (
            <svg className="w-5 h-5 text-white animate-spin" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
            </svg>
          ) : (
            <svg className="w-5 h-5 text-white" fill="currentColor" viewBox="0 0 24 24">
              <path d="M16.6915026,12.4744748 L3.50612381,13.2599618 C3.19218622,13.2599618 3.03521743,13.4170592 3.03521743,13.5741566 L1.15159189,20.0151496 C0.8376543,20.8006365 0.99,21.89 1.77946707,22.52 C2.41,22.99 3.50612381,23.1 4.13399899,22.8429026 L21.714504,14.0454487 C22.6563168,13.5741566 23.1272231,12.6315722 22.9702544,11.6889879 L4.13399899,1.16865389 C3.34915502,0.9115565 2.40734225,1.02411974 1.77946707,1.4954118 C0.994623095,2.13399899 0.837654326,3.22628631 1.15159189,3.9914922 L3.03521743,10.4324851 C3.03521743,10.5895825 3.19218622,10.7466799 3.50612381,10.7466799 L16.6915026,11.5321668 C16.6915026,11.5321668 17.1624089,11.5321668 17.1624089,12.0034589 C17.1624089,12.4744748 16.6915026,12.4744748 16.6915026,12.4744748 Z" />
            </svg>
          )}
        </button>
      </div>
    </div>
  );
};
