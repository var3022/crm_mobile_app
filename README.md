# CRM Pro Field Sales (Flutter + Dart)

Comprehensive mobile CRM application for field sales teams, built with Flutter and Dart.

The Flutter app now includes local account, customer, deal, visit, task, profile,
settings and reporting flows. See [IMPLEMENTATION.md](IMPLEMENTATION.md) for
screen coverage, integration boundaries, validation status and run commands.

For a browser preview with Flutter 3.38+:

```powershell
flutter pub get
flutter run -d chrome --dart-define=APP_ROUTE=/screen-index
```

The React/Vite project under `src/` remains the original preview/code viewer.
The new application screens are implemented in Flutter under `lib/`.

## Project Structure

```text
crm_pro/
├── lib/
│   ├── main.dart                       # Application entry point
│   ├── core/
│   │   ├── theme/
│   │   │   ├── app_colors.dart         # Centralized brand & semantic tokens
│   │   │   ├── app_typography.dart     # Inter typography scale
│   │   │   ├── app_spacing.dart        # 8-point spacing system
│   │   │   ├── app_dimensions.dart     # Radii and component sizing
│   │   │   └── app_theme.dart          # Master ThemeData
│   │   └── widgets/
│   │       ├── app_button.dart         # Standard 52px primary CTA
│   │       ├── app_text_field.dart     # Standard input fields
│   │       ├── app_card.dart           # Standard surface cards
│   │       ├── app_badge.dart          # Semantic status tags
│   │       ├── app_filter_pill.dart    # Filter pills with active teal fill
│   │       ├── app_back_button.dart    # 40x40 circular chevron-left
│   │       ├── app_scaffold.dart       # Responsive mobile scaffold
│   │       └── app_bottom_navigation.dart # 5-tab navigation bar
│   └── features/                       # Modular feature domains
├── pubspec.yaml                        # Flutter package configuration
└── analysis_options.yaml               # Flutter linting rules
```

## Running in Android Studio

1. Open Android Studio.
2. Select **Open** and choose this project directory.
3. Run `flutter pub get` in the terminal or click "Pub get" in Android Studio.
4. Select an Android emulator or connected device.
5. Click **Run** (or press `Shift + F10`).
