# Security Review Checklist

## Secrets and Credentials

Check:
- No hardcoded credentials.
- No access tokens in source code.
- No refresh tokens in logs.
- No passwords logged.
- API base URL is configurable.

Forbidden:
- hardcoded user credentials;
- logging tokens;
- logging passwords;
- committing `.env` with secrets;
- storing secrets in plain text without reason.

## Authentication

Check:
- Auth state is handled consistently.
- Logout clears in-memory session and persisted tokens.
- Unauthorized API responses move user to auth flow or clear session safely.
- Token refresh, if implemented, does not create infinite retry loops.

## User Input

Check:
- Email/password inputs are validated.
- Vehicle forms validate required fields and numeric ranges.
- Mileage cannot go backwards when flow requires validation.
- Chat input is bounded and sanitized before send.

## Error Messages

Check:
- Errors are understandable.
- Errors do not expose stack traces, tokens, raw server internals, or sensitive personal data.
- AI fallback does not hallucinate private or missing data.

## Privacy

Check:
- Vehicle VIN and user profile data are not shown in logs.
- Chat history is scoped per user and per vehicle.
- Notifications do not reveal excessive private data on lock screen unless product explicitly supports it.
