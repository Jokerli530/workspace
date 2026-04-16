---
name: LLM Auth Retry on 401
type: Gene
schema_version: 1.5.0
id: gene_llm_auth_retry
category: repair
signals_match:
  - "authentication_error"
  - "401"
  - "invalid api key"
  - "LLM ERROR"
summary: Handle LLM 401 authentication errors with credential refresh and exponential backoff retry
strategy:
  - "Detect 401 authentication_error from LLM response"
  - "Log the error with full context (model, endpoint, error type)"
  - "Check if refresh token or alternative credentials are available"
  - "If refresh available: refresh credentials, retry once"
  - "If no refresh: fallback to cached result or return graceful error"
  - "Record auth_failure signal for future prevention"
constraints:
  max_files: 3
  forbidden_paths:
    - ".git"
    - "node_modules"
    - "/tmp"
postconditions:
  - "401 errors are caught and handled gracefully"
  - "No credential leakage in logs"
  - "Error context is preserved for debugging"
validation:
  - "401 errors do not crash the agent"
  - "Retry happens at most once per request"
  - "Logs contain no raw API keys"
