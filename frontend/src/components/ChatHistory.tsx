import React, { useEffect, useRef } from 'react';
import { ChatBubble } from './ChatBubble';
import type { Message } from '../types/chat';

interface ChatHistoryProps {
  messages: Message[];
  isLoading?: boolean;
}

export const ChatHistory: React.FC<ChatHistoryProps> = ({ messages, isLoading = false }) => {
  const endOfMessagesRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    endOfMessagesRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  return (
    <div className="flex-1 overflow-y-auto pb-4">
      {messages.length === 0 ? (
        <div className="h-full flex items-center justify-center">
          <div className="text-center text-gray-400">
            <svg className="w-12 h-12 mx-auto mb-4 opacity-50" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
            </svg>
            <p className="text-lg font-semibold mb-2">Start a new conversation</p>
            <p className="text-sm">Ask anything to get started</p>
          </div>
        </div>
      ) : (
        <>
          {messages.map((message) => (
            <ChatBubble
              key={message.id}
              role={message.role}
              content={message.content}
              timestamp={message.timestamp}
              model={message.model}
            />
          ))}
          {isLoading && (
            <div className="flex justify-start mb-4 px-4">
              <div className="bg-gray-800 rounded-3xl px-4 py-3 rounded-bl-sm">
                <div className="flex space-x-2">
                  <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce" />
                  <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style={{ animationDelay: '0.1s' }} />
                  <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style={{ animationDelay: '0.2s' }} />
                </div>
              </div>
            </div>
          )}
          <div ref={endOfMessagesRef} />
        </>
      )}
    </div>
  );
};
