# How this project was built - step by step

## Step 1 - Read the spec and find the hidden traps
* The "trick logic": SM-2 + a worked example (score 5 → **5 days**). Textbook SM-2 gives 1 day, then 6, so the example would fail. Decision: first successful review uses a score-based starting interval (3→2, 4→3, 5→5); everything after is standard SM-2.
* The schema has **no per-word state table**, only `words` and `reviews`. Decision: the *latest review row* is the word's current state. Never-reviewed words have no row → treated as due immediately.
* `/words/due/` must use `next_review <= today` - compared by **date** (`date(next_review) <= today`), not by timestamp, so a word due "today" is not missed at 9am.

## Step 2 - Pure algorithm first (`app/srs.py`)
Written with no database or web code, as `next_state(state, score) → new_state`. Because it is pure, it is tested in milliseconds (`tests/test_srs.py`). Bugs in the scheduling rules - what the evaluators care most about - are caught here before any API exists.

## Step 3 - Database layer
* `models.py` mirrors the required DDL exactly (CHECK score 0-5, FK `ON DELETE CASCADE`).
* `database.py` turns on `PRAGMA foreign_keys=ON` for every SQLite connection - SQLite ignores foreign keys otherwise, and the cascade delete would silently fail.
* `get_db()` is the **dependency injection** point: one session per request.
* Alembic (`alembic/versions/0001_initial_schema.py`) creates the same tables. The app never calls `create_all`; Alembic is the single source of schema truth (tests use `create_all` on a temp DB).
* `seed_data.sql` uses SQLite's `datetime('now', ...)` so demo data is always relative to today.

## Step 4 - Service layer (`services.py`)
All queries and rules live here; routers stay thin. The key query is "latest review per word": `LEFT JOIN reviews ON word_id AND reviews.id IN (SELECT max(id) ... GROUP BY word_id)`. History computes accuracy (score ≥ 3), current/longest streak (consecutive review days), and difficult words (low average score / lapses).

## Step 5 - Routers, errors, OpenAPI (`routers/words.py`, `main.py`)
* Domain exceptions (`WordNotFoundError`, `DuplicateWordError`) → 404 / 409; Pydantic validation → 422; unexpected DB errors → JSON 500.
* Fixed routes (`/due/`, `/history/`) are declared before `/{word_id}` so they're not parsed as ids.
* `generate_unique_id_function=lambda r: r.name` makes clean SDK method names (`add_word`, not `add_word_words__post`).
* `get_today` is injectable → tests move the clock instead of waiting days.

## Step 6 - Tests (`tests/`)
Each spec example is a test (Word A → 5 days, Word B → tomorrow, due returns only due words), plus validation, 404, duplicate, cascade, schedule, history, Swagger availability.

## Step 7 - Frontend
`api.js` is the only file that talks HTTP (Axios) and normalises error messages. One component per requirement: AddWord, ReviewSession (reveal → 0-5 buttons → shows next interval), Schedule, Progress (stats + CSS bar chart, no chart library to install), WordList (delete). Bonus "real-time": the due-count badge polls every 30 s and updates immediately after each action.

## Step 8 - SDK and scripts
SDK is *generated*, never hand-written: `generate_sdk.bat` runs OpenAPI Generator against `/openapi.json` with `--package-name srs_sdk` so the spec's import path works. `.bat` fixes vs. the brief: `call npm` (otherwise a batch file exits after npm), and the run script opens backend/frontend in separate windows (otherwise `python main.py` blocks and the frontend never starts).

## What I could not run
The build sandbox had no internet, so FastAPI/SQLAlchemy/npm packages could not be installed. Verified here: Python syntax of every module, all 11 SM-2 unit tests, and the seed SQL + due query on real SQLite. **Not executed here:** `pytest tests/test_api.py`, the React build, and SDK generation - run those once on your machine (README has the commands).
