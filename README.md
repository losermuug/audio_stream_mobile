# Streaming App

Flutter audio streaming client for `streaming_app_backend`.

## Architecture

The app uses a feature-based clean code structure:

- `lib/core`: shared config, networking, and utilities
- `lib/features/auth/domain`: auth entities, repository contracts, use cases
- `lib/features/auth/data`: GraphQL auth datasource, models, repository implementation
- `lib/features/auth/presentation`: login/signup controller, page, and form widgets
- `lib/features/audio_streaming/domain`: entities, repository contracts, use cases
- `lib/features/audio_streaming/data`: GraphQL datasource, models, repository implementation
- `lib/features/audio_streaming/presentation`: controller, page, and widgets

## Backend

By default the app uses:

- Android emulator: `http://10.0.2.2:8080`
- Other platforms: `http://localhost:8080`

Override it when needed:

```sh
flutter run --dart-define=API_BASE_URL=http://localhost:8080
```

For a real phone on the same network, use your computer's LAN IP instead of `localhost`:

```sh
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8080
```

If you see `Connection refused`, verify the backend is running and reachable:

```sh
cd ../streaming_app_backend
npm run dev
curl http://localhost:8080/health
```

The catalog is loaded from `POST /graphql` using the `tracks` query. Playback uses the backend REST stream endpoint returned by GraphQL, for example `/tracks/:id/stream`.
