# Chat AI Frontend

A modern React + TypeScript frontend for interacting with local LLM models.

## Tech Stack

- **React 18** - UI library
- **TypeScript** - Type safety
- **Vite** - Fast build tool
- **Tailwind CSS** - Styling
- **Axios** - HTTP client

## Project Structure

```
src/
├── components/       # React components
│   ├── ChatScreen.tsx    # Main chat interface
│   ├── ChatHistory.tsx   # Message display
│   ├── ChatBubble.tsx    # Individual message bubble
│   ├── ModelSelector.tsx # Model selection dropdown
│   └── SearchBox.tsx     # Chat input area
├── services/        # API integration
│   └── apiService.ts    # Backend API client
├── types/          # TypeScript types
│   └── chat.ts         # Chat-related type definitions
├── App.tsx         # Root component
├── main.tsx        # Entry point
└── index.css       # Global styles with Tailwind
```

## Setup

### Prerequisites
- Node.js 16+
- npm or yarn

### Installation

```bash
# Install dependencies
npm install

# Create environment file
cp .env .env.local  # Optional, for custom API URL
```

### Development

```bash
# Start development server (port 3000)
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview
```

## Configuration

### Environment Variables

Create a `.env.local` file to override defaults:

```
VITE_API_URL=http://localhost:8000
```

## Features

- **Chat Interface** - Clean, glass-morphic UI
- **Model Selection** - Switch between available models
- **Auto-scroll** - Messages automatically scroll into view
- **Loading States** - Visual feedback during API calls
- **Error Handling** - User-friendly error messages
- **Responsive Design** - Works on desktop and tablet

## Architecture

The frontend uses a component-based architecture with:

- **ChatScreen** - Container component managing state and API calls
- **ChatHistory** - Displays message history
- **SearchBox** - Input field with auto-sizing textarea
- **ModelSelector** - Dropdown for model selection
- **ChatBubble** - Individual message rendering

## API Integration

The frontend expects the backend to provide:

- `GET /health` - Health check
- `GET /models` - List available models
- `POST /chat/completions` - Send message and get response
- `POST /chat/completions/stream` - Stream responses (future)

See `src/services/apiService.ts` for API client implementation.

## Next Steps

- Backend integration (ensure FastAPI backend is running on localhost:8000)
- Add chat history persistence
- Implement streaming responses
- Add markdown rendering for code blocks
- Add settings/configuration panel
