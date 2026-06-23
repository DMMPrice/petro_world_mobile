# Petro World — Flutter E‑Commerce App

This repository contains the Petro World Flutter app — an e-commerce template
and production-ready mobile/web app built with Flutter.

This README consolidates the project overview, development setup, production
configuration, and deployment checklist.

## Project Overview

- Multi-platform Flutter application (Android, iOS, Web)
- Uses Supabase for optional backend features (Auth, Storage, Edge Functions)
- Adaptive product image rendering and cached network images
- Riverpod/Provider for state management
- Environment-driven configuration via `.env`

## Quick Start (Development)

1. Install Flutter (stable) and required SDKs
2. Copy `.env.example` → `.env` and fill values
3. Get packages:

```bash
flutter pub get
```

4. Run locally:

```bash
flutter run
```

5. Run web locally:

```bash
flutter run -d chrome
```

## Environment Variables

Create a `.env` file (do not commit). Example variables are in `.env.example`.

- `API_URL` — backend API base (production:
  https://petro-world-backend.onrender.com/api/v1)
- `SUPABASE_URL` — optional Supabase project URL
- `SUPABASE_ANON_KEY` — optional Supabase anon key

`.env` is ignored by git via `.gitignore`.

## Production Configuration & Build

### Logging

This project uses a production-safe `LoggerService` located at
`lib/services/logger_service.dart`.

- Logs only appear in debug/profile builds (`kDebugMode`).
- Release builds are silent (no debug output and minimal overhead).

### Build commands

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

### Platform notes

- Android: ensure `minSdkVersion >= 21` and signing is configured
- iOS: set deployment target (recommended 12.0+) and configure provisioning
- Web: serve over HTTPS in production

## Production Readiness Checklist (summary)

- Run `flutter analyze` and `flutter test`
- Ensure `.env` is configured with production values
- Replace any debug prints (project uses `LoggerService` already)
- Confirm Supabase RLS & minimal ANON_KEY permissions
- Configure Crashlytics/Sentry for error reporting
- Asset optimization and image compression
- Verify lazy loading and pagination for large product lists

## Deployment & Monitoring Recommendations

- Configure CI to run analyzer, tests, and builds
- Set up monitoring: Firebase Crashlytics or Sentry
- Add analytics (Firebase Analytics, Mixpanel) for usage tracking
- Use staging environment for verification before production

## Production Changes (summary)

Recent production-hardening changes (2026-06-24):

- Added `lib/services/logger_service.dart` — production-safe logging
- Replaced `debugPrint()` uses with `LoggerService`
- Removed marketing links and template references
- Consolidated production documentation into repository README
- Created `.env.example` template

## Full Production Checklist (in-repo)

The project was updated with a comprehensive checklist covering:

- Code quality & testing
- Configuration & secrets
- Performance optimization
- Error handling & logging
- Security audit
- Platform-specific requirements
- Build & deployment steps
- Monitoring & analytics

Follow the checklist before tagging a release.

## Contribution & Notes

- Keep `.env` out of version control
- Use feature branches and run tests locally before creating PRs
- If you add logging for debugging, use `LoggerService` so it's gated by
  `kDebugMode`.

## Acknowledgements

This project is based on the FlutterShop template and has been adapted and
production-hardened for Petro World.

---

If you'd like, I can also:

- Add a short Developer Setup section for common IDEs
- Create CI pipeline examples (GitHub Actions) for builds/tests
- Configure a basic Sentry/Firebase integration skeleton
