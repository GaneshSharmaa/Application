@echo off
REM Setup script for Mitra AI (Windows)

echo ================================
echo Mitra AI - Setup Script
echo ================================
echo.

REM Check Python
echo Checking Python...
python --version >nul 2>&1 || (echo Python not found & exit /b 1)

REM Check Node
echo Checking Node.js...
node --version >nul 2>&1 || (echo Node.js not found & exit /b 1)

REM Backend setup
echo.
echo ================================
echo Setting up Backend...
echo ================================

cd backend

REM Create virtual environment
if not exist "venv" (
    echo Creating virtual environment...
    python -m venv venv
)

REM Activate virtual environment
call venv\Scripts\activate.bat

REM Install dependencies
echo Installing Python dependencies...
python -m pip install --upgrade pip
pip install -r requirements.txt

echo Backend setup complete!
echo.

REM Check for models directory
if not exist "models" mkdir models

REM Check for models
if not exist "models\gemma-4-E2B-it-Q8_0.gguf" (
    echo.
    echo ================================
    echo Downloading Models...
    echo ================================
    echo This will download ~9 GB of models.
    set /p download="Continue? (y/n): "
    if /i "%download%"=="y" (
        python setup-models.py
    ) else (
        echo Models not downloaded. You can run 'python setup-models.py' later.
    )
)

REM Frontend setup
echo.
echo ================================
echo Setting up Frontend...
echo ================================

cd ..\frontend

echo Installing Node dependencies...
call npm install

echo Frontend setup complete!

echo.
echo ================================
echo Setup Complete! 
echo ================================
echo.
echo To start the application:
echo.
echo Terminal 1 (Backend):
echo   cd backend
echo   venv\Scripts\activate.bat
echo   python main.py
echo.
echo Terminal 2 (Frontend):
echo   cd frontend
echo   npm run dev
echo.
echo Then open: http://localhost:3000
echo.
pause
