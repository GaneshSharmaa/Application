import React, { useState } from 'react';

interface SidebarProps {
  isOpen: boolean;
  onClose: () => void;
}

export const Sidebar: React.FC<SidebarProps> = ({ isOpen, onClose }) => {
  return (
    <>
      {/* Overlay */}
      {isOpen && (
        <div
          className="fixed inset-0 bg-black/50 z-40 md:hidden"
          onClick={onClose}
        />
      )}

      {/* Sidebar */}
      <div
        className={`fixed left-0 top-0 h-screen w-64 bg-gray-900 border-r border-gray-800 z-50 transform transition-transform duration-300 ease-in-out ${
          isOpen ? 'translate-x-0' : '-translate-x-full'
        } md:translate-x-0 md:static md:z-0`}
      >
        {/* Close button for mobile */}
        <button
          onClick={onClose}
          className="md:hidden absolute top-4 right-4 p-2 hover:bg-gray-800 rounded-lg"
        >
          <svg className="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>

        {/* Sidebar content */}
        <div className="p-4 pt-12 md:pt-4">
          <h2 className="text-xl font-bold text-white mb-6">Mitra AI</h2>

          <nav className="space-y-3">
            <button className="w-full text-left px-4 py-3 rounded-lg bg-blue-600 text-white hover:bg-blue-700 transition-colors">
              <div className="flex items-center space-x-3">
                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4.5v15m7.5-7.5h-15" />
                </svg>
                <span>New Chat</span>
              </div>
            </button>

            <div className="pt-4 border-t border-gray-800">
              <h3 className="px-4 py-2 text-xs font-semibold text-gray-400 uppercase">Recent</h3>
              <div className="space-y-2">
                <button className="w-full text-left px-4 py-2 rounded-lg text-gray-300 hover:bg-gray-800 transition-colors truncate">
                  What is machine learning?
                </button>
                <button className="w-full text-left px-4 py-2 rounded-lg text-gray-300 hover:bg-gray-800 transition-colors truncate">
                  How to use Python
                </button>
                <button className="w-full text-left px-4 py-2 rounded-lg text-gray-300 hover:bg-gray-800 transition-colors truncate">
                  Latest AI trends
                </button>
              </div>
            </div>
          </nav>

          {/* Settings at bottom */}
          <div className="absolute bottom-0 left-0 right-0 p-4 border-t border-gray-800">
            <button className="w-full px-4 py-3 rounded-lg text-gray-300 hover:bg-gray-800 transition-colors flex items-center space-x-3">
              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
              </svg>
              <span>Settings</span>
            </button>
          </div>
        </div>
      </div>
    </>
  );
};
