# Release preparation

## Identity and assets

- Version: `1.0.0+1` in `pubspec.yaml`.
- Android application ID and namespace: `com.yornnona.portfolio`.
- iOS bundle ID: `com.yornnona.portfolio` (test targets use its `.RunnerTests` suffix).
- Android/iOS display name: Yorn Nona. Original YN launcher artwork is included.
- iOS minimum target: 13.0. Android minimum follows the installed Flutter SDK.
- Confirm that the application identifiers are available in the owner's accounts
  before creating the store records. Existing Xcode development-team selection is
  retained and must be verified by the owner.
- Add the real CV, screenshots, verified project URLs and profile URLs
  using README instructions. No store URLs or release metrics are invented.

## Android

Install the toolchain and review any pending Android SDK licenses yourself.
The current machine reports some unaccepted licenses via `flutter doctor`.

```sh
flutter doctor -v
flutter doctor --android-licenses
flutter build apk --debug
```

For a signed release, create/use your own upload keystore. Copy
`android/key.properties.example` to `android/key.properties` and fill it locally.
Both the properties file and keystore files are ignored by Git. The Gradle release
configuration uses this keystore only when present; it does **not** sign production
releases with a debug key. Without it release artifacts remain unsigned.

```sh
flutter build appbundle --release
```

Test on an Android device: four tabs, deep routes, filters, theme after force-close,
large fonts, reduced motion, email/phone/GitHub, PDF preview, native save/share,
and canceled file actions. Create actual store screenshots and review Data Safety
answers against the final distributed app and dependencies.

## iOS

```sh
flutter build ios --release --no-codesign
open ios/Runner.xcworkspace
```

In Xcode, verify bundle ID and team, configure automatic/manual signing with the
owner's credentials, test on an iPhone and iPad, then Archive and validate/upload
through Organizer and App Store Connect. A locally compiled unsigned `.app` is
not a signed App Store submission. No certificates or provisioning profiles are
created or changed by this implementation.

`UIFileSharingEnabled` and `LSSupportsOpeningDocumentsInPlace` permit Files
integration. The CV sharing action supplies bounds for the iPad share popover.
Verify portrait/landscape layouts, system appearance, dynamic type, Reduce Motion,
mail/phone handlers, PDF rendering, save picker, canceled share, and missing assets.
Prepare the actual privacy/support URLs, screenshots and listing in the owner's
App Store Connect account; no public URLs are fabricated.

## Web and optional desktop

```sh
flutter build web --release
python3 -m http.server 8080 --directory build/web
```

Hash routes work with a static host. Host over HTTPS for browser clipboard support.
The bundled fonts and local portfolio need no backend. printing may load PDF.js
from its configured CDN for web PDF previews; self-host its resources if a fully
offline web PDF preview is required. Web and desktop are supplementary previews;
iOS and Android remain the primary application targets.

macOS includes print and user-selected-file entitlements for the PDF plugins.
Desktop platform scaffolding is retained from the starter.
