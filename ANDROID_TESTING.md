# Test CRM Pro with Android Studio and an Android phone

The Flutter project is:

`C:\Users\Asus\Documents\ChatGPT\Yutomax\crm_mobile_app`

The installed Flutter SDK is `C:\Users\Asus\flutter`.
At the last setup check, Flutter could not locate an Android SDK and no Android
emulator or physical Android device was connected. Android compilation and
device behavior have not yet been verified.

## 1. One-time Android Studio setup

1. Install Android Studio from https://developer.android.com/studio and complete
   its setup wizard, including the Android SDK.
2. For IDE Run/Debug support, open Settings > Plugins > Marketplace, install
   Flutter (and its Dart dependency), and restart Android Studio.
3. Open the project root above, which contains `pubspec.yaml`.
4. Open Tools > SDK Manager. Install an Android SDK Platform and the SDK tools:
   Android SDK Build-Tools, Android SDK Platform-Tools, Android SDK Command-line
   Tools (latest), and Android Emulator. Gradle/Flutter can request additional
   compatible SDK/NDK components during the first Android build.
5. In PowerShell, set a convenient variable pointing to Flutter:

```powershell
$flutter = 'C:\Users\Asus\flutter\bin\flutter.bat'
cd C:\Users\Asus\Documents\ChatGPT\Yutomax\crm_mobile_app
& $flutter doctor --android-licenses
& $flutter doctor -v
& $flutter pub get
```

Read and accept the Android SDK licenses you agree to. Resolve Android toolchain
errors shown by doctor. A Visual Studio warning concerns Windows desktop builds
and does not prevent Android builds.

If SDK discovery fails, copy the Android SDK Location from SDK Manager and use
that actual directory:

```powershell
& $flutter config --android-sdk 'C:\Users\Asus\AppData\Local\Android\Sdk'
& $flutter doctor -v
```

Alternatively, add `C:\Users\Asus\flutter\bin` to your user PATH and restart
your terminal; you can then use `flutter` directly instead of `& $flutter`.

## 2. Run on the Android Studio emulator

1. Open Tools > Device Manager. From the welcome screen, use More Actions >
   Virtual Device Manager.
2. Create a phone virtual device, such as a Pixel, and download a compatible
   Android system image. On this x64 laptop, choose an x86_64 image.
3. Finish creation and click the play button to start it. Wait for Android to
   finish booting.
4. Run:

```powershell
& $flutter devices
```

5. Copy the emulator ID from that output and substitute it below:

```powershell
& $flutter run -d DEVICE_ID --dart-define=APP_ROUTE=/screen-index
```

For example, only if `flutter devices` lists that ID:

```powershell
& $flutter run -d emulator-5554 --dart-define=APP_ROUTE=/screen-index
```

The Screen Index lets you open individual screens and empty/error states. For
the normal introduction flow, omit the define:

```powershell
& $flutter run -d DEVICE_ID
```

In Android Studio you can also open `lib/main.dart`, select the emulator in the
device selector, and click Run. Add
`--dart-define=APP_ROUTE=/screen-index` to the Flutter run configuration's
additional run arguments to start with the screen browser.

The first run can take several minutes while Gradle and SDK components download.
In a terminal run, press `r` for hot reload, `R` for hot restart, and `q` to stop.
Hot restart recreates application state and reloads locally stored data.

## 3. Run on your Android phone using USB

1. On the phone, open Settings > About phone and tap Build number seven times.
   The exact location depends on the phone brand.
2. Open Developer options and enable USB debugging.
3. Connect the phone using a USB cable that supports data. Unlock the phone and
   accept the Allow USB debugging prompt for your laptop.
4. If Windows does not recognize the device, install the phone manufacturer's
   appropriate ADB/USB driver.
5. Run `& $flutter devices` and copy the phone's Android device ID.
6. Launch the app:

```powershell
& $flutter run -d PHONE_DEVICE_ID --dart-define=APP_ROUTE=/screen-index
```

Use the exact ID reported by Flutter, not the phone's marketing/model name.
If the device is unauthorized, check the phone for the debugging authorization
prompt and reconnect it. Android 11+ can also use wireless debugging through
Android Studio's Pair Devices Using Wi-Fi workflow.

## 4. Optional APK installation without a debugging connection

After the Android toolchain is working:

```powershell
& $flutter build apk --debug --dart-define=APP_ROUTE=/screen-index
```

The generated APK is `build\app\outputs\flutter-apk\app-debug.apk`. Transfer it
to your own Android phone and open it. Android may ask you to allow installation
from the application used to open that APK. This is a local debug build, not a
Play Store release.

## 5. What to test

- Create/edit a lead, add notes, convert a lead, create a deal and complete a task.
- Schedule/reschedule a visit, enter check-in states, capture a signature and
  complete checkout. Confirm the selected account/visit remains correct.
- Close and reopen the app and confirm saved records and preferences remain.
- Exercise custom report ranges, empty datasets and PDF/XLSX/CSV export. Open the
  exported files and check their actual contents.
- Check keyboard appearance, scrolling, Android back navigation, smaller screens,
  rotation and larger text settings.
- Test phone, email, WhatsApp and directions actions only when ready for the
  corresponding external application to open. A missing handler should produce
  an honest fallback.
- Compare rendered screens with the original PDF, especially composite pages 11
  and 77. Passing tests do not establish exact visual parity.

Camera/audio capture, live GPS/maps, OCR/transcription, authentication-provider
integration, push delivery and cloud sync still include demo/external-service
boundaries. Declared Android permissions alone do not implement those services.

## References

- Flutter Android setup: https://docs.flutter.dev/platform-integration/android/setup
- Android physical device setup: https://developer.android.com/studio/run/device

An iPhone cannot run an Android APK or Android emulator build. Native iPhone
testing requires an iOS build using macOS and Xcode.
