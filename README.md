# Spaced Repetition Vocabulary Trainer

FastAPI + SQLite + Alembic backend, React (Axios) frontend, OpenAPI-generated Python SDK, Windows automation scripts. No Docker.

## Prerequisites
Python 3.10+, Node.js 18+, (for the SDK only) Java 11+.

## Quick start (Windows)
```bat
setupdev.bat          :: venv + pip install + alembic upgrade head + npm install
python seed.py        :: optional sample data (activate env first: env\Scripts\activate)
runapplication.bat    :: opens backend + frontend windows
```
* Frontend: http://localhost:3000
* Swagger UI: http://localhost:8000/docs  ·  ReDoc: /redoc  ·  Spec: /openapi.json

### Manual / macOS / Linux
```bash
python -m venv env && source env/bin/activate
pip install -r requirements.txt
alembic upgrade head
sqlite3 srs.db < seed_data.sql      # optional
python main.py                      # backend on :8000
cd frontend && npm install && npm start
```

## API
| Method | Path | Purpose |
|---|---|---|
| POST | `/words/` | add word (word, definition, language) → 201, 409 duplicate, 422 invalid |
| GET | `/words/` | list all words with SRS state |
| GET | `/words/due/` | words with `next_review <= today` (new words included) |
| POST | `/words/{id}/review/` | body `{"score": 0-5}` → new interval / EF / next_review; 404, 422 |
| GET | `/words/history/` | accuracy, streaks, difficult words, recent reviews, 14-day activity |
| GET | `/words/upcoming/?days=7` | upcoming schedule grouped by date |
| DELETE | `/words/{id}` | remove word (reviews cascade) → 204 / 404 |

## The SRS rules (modified SM-2, `app/srs.py`)
| Situation | Result |
|---|---|
| score 0-2 | repetition = 0, interval = **1 day**, EF unchanged |
| 1st success | score 3 → 2 d, 4 → 3 d, **5 → 5 d** |
| 2nd success | 6 days |
| later successes | `round(prev_interval × EF)` (always ≥ prev + 1) |
| EF update | `EF + 0.1 - (5-q)(0.08 + (5-q)0.02)`, minimum 1.3, start 2.5 |

Examples: Word A reviewed with 5 → due in 5 days; Word B reviewed with 1 → due tomorrow.

## Tests
```bash
pytest -v
```
`tests/test_srs.py` covers the algorithm; `tests/test_api.py` covers every endpoint, errors, cascade delete, and "time travel" through the injected `get_today` dependency.

## Generating the Python SDK
1. Start the backend. 2. Run `generate_sdk.bat` (needs Java). 3. Try `python sdk_example.py`.
No server? `python export_openapi.py` writes `openapi.json`; point the generator at that file instead.
Generated code lands in `srs_sdk/` (commit it as a deliverable).

## Project layout
```
app/            main.py (app) · routers/words.py (HTTP) · services.py (logic+queries)
                srs.py (algorithm) · models.py · schemas.py · database.py · dependencies.py
alembic/        migrations          tests/   unit + API tests
frontend/src/   api.js (Axios) · App.js · components/
seed_data.sql   sample rows         *.bat    setup / run / SDK scripts
```

## Troubleshooting
* "Cannot reach the server" in the UI → backend not running or CORS origin differs (edit `allow_origins` in `app/main.py`).
* `alembic upgrade head` creates `srs.db` in the folder you run it from - run from the project root.
* Change DB location with env var `SRS_DATABASE_URL`.
