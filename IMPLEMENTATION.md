# CRM mobile UI implementation

The supplied 105-page PDF is the visual reference. Existing authentication,
onboarding, dashboard, notifications, theme tokens, buttons, navigation, and lead
cards are retained. New Flutter screens extend those components.

## Review the app

Requires Flutter 3.38+ / Dart 3.10+.

```powershell
flutter pub get
flutter run -d chrome
```

To open the screen index directly:

```powershell
flutter run -d chrome --dart-define=APP_ROUTE=/screen-index
```

The web entry point displays a centered 390px mobile preview on larger screens.
On mobile devices the layout fills the available width.

The original repository has no Android or iOS platform projects. To generate
them on a machine with the corresponding SDKs:

```powershell
flutter create --platforms=android,ios --project-name=crm_pro .
flutter run
```

## Reference coverage

| PDF pages | Screen group | Implementation |
| --- | --- | --- |
| 1–10 | Authentication and recovery | Existing screens retained; sign-in navigation connected |
| 11 | Two-factor authentication | Security setup overview; actual setup needs authentication service |
| 12, 19 | Settings and permissions | Shared settings/preferences screens |
| 13–23 | Setup and walkthrough | Existing screens retained; intro route corrected |
| 24–26 | Dashboard and notifications | Existing screens retained; navigation/actions connected |
| 27–31 | Leads, search, empty state, filters | Shared local leads, original cards and swipe actions, live search, filters, sorting |
| 32 | Nearby leads | Distance-filtered list with the PDF's extracted map artwork; live routing pending |
| 33–40 | Lead forms, details, call log, conversion, deletion | Validation, duplicate confirmation, edit, notes, conversion and deletion |
| 41–45 | Customers, details, notes, activity | Customer list, empty state, details, scoped notes and activity |
| 46–53 | Pipeline and deals | Board/list layouts, stage drag-and-drop, forms/details, won/lost and deletion states |
| 54–60 | Visits and routes | Calendar/date filtering, list/map preview, scheduling, rescheduling, cancellation, route preview |
| 61–63 | Check-in states | Manual check-in with explicit reason and confirmation; no fabricated GPS verification |
| 64–68 | Visit in progress and checkout | Session timer, scoped notes, checklist, drawn signature, outcome and summary |
| 69–74 | Tasks | Filters, creation/editing, details, checklist, completion, snooze and deletion |
| 75–77 | Camera, voice and photos | Reference camera layout, photo gallery/detail/zoom with extracted assets, waveform and text-note fallback; real recording/capture pending |
| 78–80 | Reports, date range and export | Sample charts/metrics, date-range selector, clipboard export; PDF/XLSX export pending |
| 81–86 | Profile, settings and support | Editable local profile, preferences, password validation, help search/FAQs |
| 87–90 | Day complete, targets, history, offline data | UI screens with demo metrics/history; offline storage/sync pending |
| 91–100 | Offline, loading and error states | Named review routes, recovery navigation and support links |
| 101 | Save success | Snackbar after saving a lead |
| 102–105 | Design-system documentation | Existing brand tokens, typography and shared components reused |

The new modules live in `lib/features/workspace/`. `crm_routes.dart` lists their
named routes and a development screen index. `crm_store.dart` owns the shared
in-memory records, keeping edits visible across navigation.

## Boundaries and remaining work

- This is a **local UI implementation**, not a production CRM backend.
- Records and preference changes last for the current app session; closing or
  restarting the app restores the sample data.
- Authentication, SSO, biometrics, password updates and two-factor setup need a
  real authentication provider. The existing authentication screens are demos.
- Maps use the PDF's static map artwork, with reference lead markers.
  Live map tiles, directions, geofencing and route optimization need a provider.
- Camera, microphone, transcription, photo uploads, push notifications, device
  permissions, server sync and persistent offline storage are not connected.
- Reports display sample reference metrics. Choosing a period changes the
  selection; it does not query a reporting API. Export currently copies text.
- Some forms use the shared form layout rather than matching every individual
  field grouping in the PDF. Exact visual parity remains to be verified with the
  running app. Extracted map/photo assets and their provenance are documented in
  `assets/images/README.md`.

## Validation status

After resolving the local Windows execution restriction, the following checks
were executed on November 14, 2026:

- Dart analysis of `lib` and `test`: **zero compiler errors**. Existing warnings
  and deprecation/style notices remain; this is not a warning-free analysis.
- `flutter test --no-pub --reporter expanded`: **74 tests passed**, including
  workflow tests and mobile screen smoke tests at 390 × 844.
- `flutter build web --debug --no-pub --dart-define=APP_ROUTE=/screen-index`:
  **succeeded**.
- `dart format` applied to the new modules, main entry point, tests and repaired
  authentication/onboarding/lead files.
- `git diff --check`: passed.

Compiler repairs include incorrect spacing/typography token names, an invalid
border constructor, missing math import, inconsistent bar-width names, and
nullable note lookups. Layout tests also caught and corrected lead location text
overflow and insufficient report chart height.

Inter is bundled under `assets/fonts/` with its OFL license. Shared typography
and tests use the bundled font; the screen tests use the production app theme.

Full visual comparison with the PDF, native Android/iOS builds and real device
service integrations remain outstanding. Passing a screen-mount test does not
establish exact design parity.
