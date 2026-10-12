@echo off
echo ==== Setting up backend ====
where python >nul 2>nul || (echo Python is not installed or not on PATH & exit /b 1)
where npm >nul 2>nul || (echo Node.js/npm is not installed or not on PATH & exit /b 1)

python -m venv env || exit /b 1
call env\Scripts\activate
pip install -r requirements.txt || exit /b 1
alembic upgrade head || exit /b 1

echo ==== Setting up frontend ====
cd frontend
call npm install || (cd .. & exit /b 1)
cd ..

echo.
echo Setup complete. Run runapplication.bat to start the app.
echo (Optional) load sample data:  python seed.py
