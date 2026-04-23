# Laravel Knowledge Notes

This document captures the Laravel side of the PHP learning path used by this repository.

## Why Laravel matters here

Laravel is the productivity-first framework in the curated PHP stack. It is relevant whenever the task values fast delivery, first-party developer experience, and a broad batteries-included platform.

## Primary references

- The official Laravel documentation is the canonical source for framework features, package integration, testing, queues, notifications, and deployment.
- Spatie is the preferred package ecosystem to evaluate once Laravel first-party features are not enough.

## Decision order for Laravel work

1. Prefer built-in Laravel capabilities first.
2. Prefer first-party Laravel packages next.
3. Prefer established Spatie packages before searching the wider Packagist ecosystem.
4. Only then evaluate generic third-party packages.

## Typical built-in areas to exhaust first

- Validation
- Queues and jobs
- Notifications and mail
- Cache and rate limiting
- Storage and filesystem abstractions
- Authentication, authorization, and policies
- HTTP client, events, scheduling, and testing helpers

## Spatie as the default package shortlist

Spatie is the first external vendor to evaluate for recurring Laravel concerns such as roles and permissions, media management, activity logs, data objects, and backup/reporting utilities.

That does not mean "always install Spatie". It means Spatie is the first external comparison point after Laravel-native options.

## References

- Laravel docs: https://laravel.com/docs
- Spatie open source catalog: https://spatie.be/open-source