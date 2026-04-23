---
description: Security baseline — OWASP Top 10 prevention, input validation, secrets, auth, dependencies. Applies to all source files.
applyTo: "**/*"
---

# Security Baseline

## Input validation (boundary rule)

- Validate every external input at the boundary (HTTP handler, CLI, queue consumer, file reader).
- Reject unknown fields by default (strict schemas).
- Size limits on payloads, arrays, file uploads.
- Canonicalize paths before filesystem access; block `..` traversal.

## Authentication & authorization

- Never trust client-side authz.
- Check authorization at the use-case entry, not only in the controller.
- Keep session tokens in HttpOnly, Secure, SameSite cookies unless an explicit rationale documents otherwise.
- Rotate and expire tokens; support revocation.

## Injection (SQLi / NoSQLi / command / LDAP / XPath)

- Parameterized queries only. No string concatenation into queries.
- No `shell=True` / unquoted shell interpolation.
- Sanitize inputs used in filesystem, process, or query paths.

## XSS

- Escape by default in templates.
- No `dangerouslySetInnerHTML` / `v-html` / raw HTML insertion without sanitization (DOMPurify or equivalent) and a justification comment.
- Set `Content-Security-Policy` with a nonce or hash strategy.

## CSRF

- State-changing endpoints require a CSRF token (or double-submit cookie / same-site cookie + Origin check).
- GETs must be idempotent and side-effect-free.

## Secrets

- No secrets in source, tests, logs, error messages.
- Use env vars / secret manager; reference via config abstraction.
- Rotate on exposure. Never commit a lockfile or artifact containing a secret.

## Crypto

- Use vetted libraries; never roll your own.
- Passwords: bcrypt/argon2 with appropriate cost.
- Avoid MD5/SHA1 for anything security-relevant.
- Use a CSPRNG for tokens (`crypto.randomBytes`, `random_bytes`, `secrets`).

## Dependencies

- Pin versions; review `npm audit` / `composer audit` / `pip-audit` output before merge.
- Prefer minimal, maintained dependencies. Remove unused ones.
- No dev-only libs in production bundles.

## Logging

- Never log secrets, tokens, passwords, PII.
- Log actionable events with correlation IDs.
- No tight-loop / per-request debug logging in production paths.

## HTTP hardening

- `Strict-Transport-Security`, `X-Content-Type-Options: nosniff`, `Referrer-Policy`, `Permissions-Policy`.
- CORS: explicit allowlist; no `*` for credentialed endpoints.
- Rate limiting / throttling on authenticated endpoints.

## File upload

- Validate MIME + magic bytes, not just extension.
- Store outside the web root or use signed URLs.
- Scan for malware when user-facing distribution is involved.

## Concurrency / idempotency

- State-changing POSTs should support idempotency keys where applicable.
- Return `409 Conflict` on concurrent mutation; do not silently overwrite.

## Prohibited without explicit justification

- Disabling TLS verification.
- Using `eval`, `new Function`, dynamic `require`, `unserialize`, `pickle.load` on user data.
- Wildcard SQL / ORM `update` / `delete` without `WHERE`.
- Logging / printing stack traces to the client.
