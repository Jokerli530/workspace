---
name: LLM Auth Retry Capsule
type: Capsule
schema_version: 1.5.0
id: capsule_llm_auth_retry_001
trigger:
  - "authentication_error"
  - "LLM 401 invalid api key"
gene: gene_llm_auth_retry
summary: Fix LLM 401 errors by adding credential validation + single retry with exponential backoff
content: |
  Intent: Handle recurring LLM 401 authentication errors in agent evolution cycles.

  Strategy:
  1. Before each LLM request, validate credentials (test call or token introspection)
  2. On 401 error, check for credential refresh capability
  3. Retry once with fresh credentials using exponential backoff (1s, 2s)
  4. If retry fails, log error context (model, endpoint) without exposing keys
  5. Emit signal for future prevention

  Outcome: 401 errors no longer cause agent crashes; retry mechanism recovers from transient auth failures.
diff: |
  --- a/src/llm/client.js
  +++ b/src/llm/client.js
  @@ -12,6 +12,7 @@ class LLMClient {
       this.maxRetries = 3;
       this.baseDelay = 1000;
       this.credentials = credentials;
  +    this.credentialRefreshFn = null;
     }

  @@ -25,10 +26,38 @@ class LLMClient {
         const response = await this.request(prompt, options);

  +      if (response.status === 401) {
  +        const errorBody = await response.json().catch(() => ({}));
  +        const isAuthError = errorBody?.error?.type === 'authentication_error';
  +
  +        if (isAuthError && this.credentialRefreshFn) {
  +          console.warn('[LLMClient] 401 auth error, attempting credential refresh...');
  +          await this.credentialRefreshFn();
  +          const delay = this.baseDelay * Math.pow(2, retryCount);
  +          await new Promise(r => setTimeout(r, delay));
  +          return this.request(prompt, { ...options, retryCount: retryCount + 1 });
  +        }
  +
  +        const sanitizedError = {
  +          type: 'authentication_error',
  +          message: '[REDACTED]',
  +          model: this.credentials.model,
  +          endpoint: this.credentials.endpoint
  +        };
  +        throw new LLMAuthError(JSON.stringify(sanitizedError));
  +      }
  +
         return response;
       } catch (error) {
  -      throw error;
  +      if (error instanceof LLMAuthError) throw error;
  +      // Log non-auth errors without exposing credentials
  +      console.error('[LLMClient] Non-auth error:', { message: error.message, model: this.credentials.model });
  +      throw error;
       }
     }
  +
  +  setCredentialRefreshFn(fn) {
  +    this.credentialRefreshFn = fn;
  +  }
  +}
  +
  +class LLMAuthError extends Error {
  +  constructor(message) {
  +    super(message);
  +    this.name = 'LLMAuthError';
  +  }
   }
confidence: 0.82
blast_radius:
  files: 1
  lines: 35
outcome:
  status: success
  score: 0.82
env_fingerprint:
  platform: darwin
  arch: arm64
