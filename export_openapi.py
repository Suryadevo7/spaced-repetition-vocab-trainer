"""Write openapi.json WITHOUT starting the server (handy for SDK generation / CI):
    python export_openapi.py
    openapi-generator-cli generate -i openapi.json -g python -o srs_sdk --package-name srs_sdk"""
import json
from app.main import app

with open("openapi.json", "w", encoding="utf-8") as f:
    json.dump(app.openapi(), f, indent=2)
print("openapi.json written")
