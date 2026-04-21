import React, { ReactNode, useState } from 'react';

interface ChatBubbleProps {
  role: 'user' | 'assistant';
  content: ReactNode;
  timestamp?: Date;
  model?: string;
}

export const ChatBubble: React.FC<ChatBubbleProps> = ({ role, content, timestamp, model }) => {
  const isUser = role === 'user';
  const [copied, setCopied] = useState(false);

  const handleCopy = () => {
    const text = typeof content === 'string' ? content : '';
    navigator.clipboard.writeText(text);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const handleRefresh = () => {
    // Will be connected to parent component
    console.log('Refresh message');
  };

  return (
    <div className={`flex ${isUser ? 'justify-end' : 'justify-start'} mb-2 px-4`}>
      <div className={`flex flex-col ${isUser ? 'items-end' : 'items-start'}`}>
        <div
          className={`max-w-[85%] lg:max-w-md px-4 py-3 rounded-2xl ${
            isUser
              ? 'bg-purple-600 text-white rounded-br-sm'
              : 'bg-gray-800 text-white rounded-bl-sm'
          }`}
        >
          <div className="text-sm leading-relaxed">{content}</div>
        </div>

        {!isUser && (
          <div className="flex gap-3 mt-2 ml-2">
            <button
              onClick={handleCopy}
              className="p-2 hover:bg-gray-700/50 rounded-lg transition-colors"
              title="Copy"
            >
              <svg className="w-4 h-4 text-gray-400 hover:text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
              </svg>
            </button>
            <button
              onClick={handleRefresh}
              className="p-2 hover:bg-gray-700/50 rounded-lg transition-colors"
              title="Refresh"
            >
              <svg className="w-4 h-4 text-gray-400 hover:text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
              </svg>
            </button>
            <button className="p-2 hover:bg-gray-700/50 rounded-lg transition-colors" title="Like">
              <svg className="w-4 h-4 text-gray-400 hover:text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M14 10h4.764a2 2 0 011.789 2.894l-3.646 7.23a2 2 0 01-1.789 1.106H7a2 2 0 01-2-2V9a6 6 0 0112-6z" />
              </svg>
            </button>
            <button className="p-2 hover:bg-gray-700/50 rounded-lg transition-colors" title="Dislike">
              <svg className="w-4 h-4 text-gray-400 hover:text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10 14H5.236a2 2 0 01-1.789-2.894l3.646-7.23a2 2 0 011.789-1.106H17a2 2 0 012 2v8a6 6 0 01-12 0z" />
              </svg>
            </button>
          </div>
        )}
      </div>
    </div>
  );
};
