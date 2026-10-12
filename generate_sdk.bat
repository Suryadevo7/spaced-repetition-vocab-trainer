@echo off
REM Generates the Python SDK with OpenAPI Generator CLI.
REM Requirements: Java 11+ on PATH, Node.js, and the backend RUNNING (runapplication.bat).
call npm install -g @openapitools/openapi-generator-cli
call openapi-generator-cli generate -i http://localhost:8000/openapi.json -g python -o srs_sdk --package-name srs_sdk
call env\Scripts\activate
pip install .\srs_sdk
echo SDK generated in .\srs_sdk and installed. Try: python sdk_example.py
