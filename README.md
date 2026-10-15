# AI Voice News - Flutter Frontend

The frontend for **AI Voice News**, a Flutter application that delivers personalized and location-aware news with voice-powered discovery and audio summaries.

The app connects to the AI Voice backend for news, user preferences, bookmarks, and generated voice summaries. It uses Firebase Authentication with Google Sign-In and stores lightweight user preferences locally on the device.

## Features

- Onboarding with preferred news categories and location selection
- Global news and news near the user
- Keyword search and voice search
- News article details with external article links
- AI-generated article summaries with audio playback
- Save, view, and remove bookmarked articles
- Share articles with the device share sheet
- Google Sign-In and sign-out
- Light and dark themes
- Configurable preferred categories, playback speed, and autoplay
- Local persistence for onboarding data and settings

## Technology

- Flutter and Dart
- Provider for application state management
- Firebase Core, Firebase Auth, and Google Sign-In
- HTTP REST calls to the AI Voice backend
- `speech_to_text` for voice input
- `just_audio` and `audioplayers` for audio playback
- `geolocator` and `geocoding` for location-based news
- Shared Preferences for local persistence

## Requirements

- Flutter SDK compatible with Dart `^3.10.8`
- A configured Android or iOS development environment
- A running instance of the AI Voice backend
- Firebase project configuration for authentication

Check the installed toolchain with:

```bash
flutter doctor
```

## Getting started

1. Clone the repository and open the frontend directory.
2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Configure the backend URL in [`lib/core/constants/app_constants.dart`](lib/core/constants/app_constants.dart):

   ```dart
   static const String baseUrl = "http://10.0.2.2:8000";
   ```

   `10.0.2.2` points from the Android emulator to the host machine. Use the backend machine's LAN IP for a physical device, or the appropriate host address for another platform. The backend must be reachable from the device.

4. Start the application:

   ```bash
   flutter run
   ```

## Firebase and Google Sign-In

Android Firebase configuration is expected at:

```text
android/app/google-services.json
```

The file is environment-specific configuration and should be handled securely. Do not copy its credentials into documentation or commit a replacement containing another Firebase project's values.

For iOS, add the Firebase-generated `GoogleService-Info.plist` to the Xcode Runner target and complete the Google Sign-In setup for the selected Firebase project. Firebase is initialized in [`lib/main.dart`](lib/main.dart) with the platform's native configuration.

In Firebase Console, enable the Google sign-in provider and register the application identifiers used by the Android and iOS builds.

## Runtime permissions

The Android application requests permissions for:

- Internet access
- Fine and coarse location
- Microphone access for voice search

Users must grant location and microphone permissions when using those features. iOS builds should also include the corresponding location and microphone usage descriptions in `ios/Runner/Info.plist` before distribution.

## Backend API

The API client is centralized in [`lib/services/api_service.dart`](lib/services/api_service.dart). Current frontend service calls include:

| Area | Endpoints used by the frontend |
| --- | --- |
| User setup | `/select-field`, `/user-preference/{userId}` |
| News | `/recommended-news/{userId}`, `/location-news/{userId}`, `/search-news` |
| Bookmarks | `/bookmark`, `/bookmarks/{userId}`, `/bookmark/{bookmarkId}` |
| Voice summaries | `/voice-summary` |
| Notifications | `/notifications/{userId}` |

The exact request and response shapes are defined by the backend and mapped into [`lib/models/news_model.dart`](lib/models/news_model.dart) and the related service classes.

## Project structure

```text
lib/
├── core/
│   ├── constants/       App name, API URL, categories, onboarding data
│   ├── routes/          Named application routes
│   └── theme/           Colors, typography, and light/dark themes
├── models/              API and UI data models
├── providers/           Provider/ChangeNotifier state management
├── services/            API, auth, news, voice, audio, location, and storage logic
├── screens/             Splash, onboarding, home, search, news, profile, saved, settings
└── main.dart            Firebase initialization and application routing
```

## Common commands

```bash
# Analyze Dart code
flutter analyze

# Run tests
flutter test

# Format Dart files
dart format lib test

# Build an Android APK
flutter build apk
```

## Development notes

- The default API URL is intended for local Android emulator development.
- Android currently allows cleartext traffic because the default local API URL uses HTTP. Use HTTPS and tighten the Android network policy for production.
- Avoid logging personal data, authentication details, or backend responses in production builds.
- The default widget test is still the Flutter template smoke test and should be replaced with tests for the actual application flows.

## Related project

The backend repository is maintained separately in the `ai_voice_backend` project. Start it first, verify its host and port, and then update `AppConstants.baseUrl` if necessary.
