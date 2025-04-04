# EcoTap

A Flutter idle game for developing a sustainable town. Made by Lucas Emanuel Silva Melo for the Digital Games course on UFCG.

## Prerequisites

Before running this project, make sure you have the following installed:

- [Flutter](https://flutter.dev/docs/get-started/install) (SDK version ^3.7.0)
- [Dart](https://dart.dev/get-dart) (latest version)
- Android Studio / Xcode (for running on Android/iOS)

## Getting Started

1. Clone the repository:
```bash
git clone [your-repository-url]
cd ecotap
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Dependencies

The project uses the following main dependencies:

- `provider: ^6.1.1` - State management
- `shared_preferences: ^2.2.2` - Local storage
- `audioplayers: ^5.2.1` - Audio playback
- `flutter_animate: ^4.5.0` - Animations
- `google_fonts: ^6.1.0` - Typography
- `flutter_svg: ^2.0.9` - SVG support

## Development

To start development:

1. Open the project in your preferred IDE
2. Make sure you have a device/emulator connected
3. Run the app in debug mode:
```bash
flutter run
```

## Building for Production

### Android
```bash
flutter build apk
```

### iOS
```bash
flutter build ios
```

### Web
```bash
flutter build web
```