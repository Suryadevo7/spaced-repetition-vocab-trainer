@echo off
echo Starting backend (new window)...
start "SRS Backend" cmd /k "call env\Scripts\activate && python main.py"

echo Starting frontend (new window)...
start "SRS Frontend" cmd /k "cd frontend && npm start"

echo.
echo Backend : http://localhost:8000/docs
echo Frontend: http://localhost:3000
