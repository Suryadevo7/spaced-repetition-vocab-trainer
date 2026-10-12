"""Load seed_data.sql into the SQLite DB (Windows-friendly: no sqlite3 CLI needed).
Run after `alembic upgrade head`:   python seed.py"""
import sqlite3
from app.database import DATABASE_URL

path = DATABASE_URL.replace("sqlite:///", "")
with sqlite3.connect(path) as conn, open("seed_data.sql", encoding="utf-8") as f:
    conn.executescript(f.read())
print(f"Seed data loaded into {path}")
