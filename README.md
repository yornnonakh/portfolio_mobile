# Yorn Nona · Flutter Developer Portfolio

A complete Flutter portfolio using the supplied 2026 CV, with ten screens,
iOS/Android layouts, tablet and desktop layouts, light/dark/system appearance,
local preferences, and no backend.

## Run

Developed with **Flutter 3.44.8 / Dart 3.12.2**. Dependency versions compatible
with that SDK are pinned in `pubspec.lock`.

```sh
flutter pub get
flutter run
# Browser preview
flutter run -d chrome
```

The portfolio follows the device theme on first launch. Settings provides explicit
light/dark and Follow system switches, plus a persistent animation preference.
Tap **English** or **ភាសាខ្មែរ** in Settings to switch immediately, or tap the
language text beside the flag in the app bar. The Settings switch is also
available (off: English, on: Khmer). The choice updates navigation,
portfolio descriptions, forms, feedback, and native controls immediately and is
saved on this device. English is the default. Noto Sans Khmer is bundled for
offline text rendering; names, contact details, technology names, user input,
original license text, and the supplied CV PDF retain their original content.

## App flow and screens

[App flow and design system](docs/APP_FLOW.md) describes navigation and visual tokens.

| Screen | Route | Behavior / CV source |
| --- | --- | --- |
| Splash | `/` | YN monogram, gradient entrance, timed redirect to Home |
| Home | `/home` | Name, title, location, exact professional summary, six-month experience, both featured projects, deployment experience, CV/contact actions |
| Projects | `/projects` | Local project gallery with All / Productivity / E-commerce filters |
| Project details | `/projects/notes`, `/projects/products` | Features, stack, contributions, conceptual architecture, integration notes, screenshot gallery and verified optional links |
| About | `/about` | Exact summary, CV-based journey, ISTAD education, languages, qualifications, experience preview |
| Skills | `/skills` | All six CV-based skill categories; no invented proficiency scores |
| Experience | `/experience` | Both roles, responsibilities, vertical timeline, education and App Store deployment experience |
| Resume | `/resume` | Exact summary and work history; asset-backed PDF preview, save/download and sharing once the original PDF is supplied |
| Contact | `/contact` | Validated Contact Us form, email composer, copy email, phone call, real GitHub profile; LinkedIn/Telegram links stay unavailable until verified URLs are supplied |
| Settings | `/settings` | Persistent theme and animation settings, version, dependency licenses |

Floating navigation retains each of the four tab stacks and their scroll positions.
The bottom bar stays fixed while scrolling, with 30 px corners, safe-area spacing,
and a centered width on larger screens.
Detail screens support back navigation and direct links. Invalid routes and project
IDs show recoverable empty states. Theme settings load before the first screen.

The Contact Us form collects user name, email, phone, and message. Send opens the
visitor's email app with every detail filled into a draft addressed to the
portfolio email (`Yornnonaistad@gmail.com`). If no mail app is available (including
on iOS Simulator), Gmail opens in the browser instead. Web uses Gmail directly
in the same tab to avoid popup blocking. The visitor signs in if necessary and
finishes sending there. Open in Gmail is also available explicitly; if both
launches fail, Copy message copies the recipient and complete message. Inputs
remain in the form. Direct delivery inside the portfolio requires a configured
email service/backend.

## Structure

```text
lib/
  main.dart                         # bootstrap, preferences, bundled font license
  app/
    app.dart                        # Riverpod-aware MaterialApp, motion policy
    router/app_router.dart          # go_router tab stacks and detail routes
    theme/app_theme.dart            # semantic palettes and Inter type scale
  core/
    constants/                      # app metadata and layout constraints
    design_system/                  # reusable cards, badges, grid, glass, headings
    services/                       # settings, URL actions, CV loading/save/share
    utils/                          # motion policy and recoverable action feedback
    widgets/                        # app frame, navigation and portrait fallback
  features/
    splash/, home/, about/, skills/, experience/, resume/, contact/
    projects/                       # filtering view model, gallery and case study
    settings/                       # persistence view model and settings screen
  shared/
    models/portfolio.dart           # immutable typed domain data
    data/portfolio_repository.dart  # repository interface + CV-backed local data
    providers/                      # repository injection and shared data providers
assets/
  images/, icons/, projects/, documents/, fonts/
test/
  widget_test.dart                  # routes, filters, layouts, themes, empty states
  domain_test.dart                  # data, URL intents, filters, PDF, storage errors
```

The implementation uses feature-first Clean Architecture with MVVM principles.
Views consume Riverpod providers. View models own filtering and preference writes.
External actions and platform dependencies are behind services; the repository is
replaceable through a provider override. No code generation or backend is needed.

## Update your CV data and assets

All professional facts live in
[`lib/shared/data/portfolio_repository.dart`](lib/shared/data/portfolio_repository.dart).
Update the typed objects there without changing screen widgets.

- **CV PDF:** add the actual PDF at `assets/documents/yorn_nona_cv.pdf`. It is
  already configured in the profile. Rebuild the app. The Resume screen loads it
  once, checks its PDF signature, previews it with `PdfPreview`, saves through the
  native file picker/download, and shares via the native share sheet. An iPad
  share anchor is supplied. Canceling a save/share is handled silently. A missing
  or corrupt document has a clear empty/error state; no fabricated CV is generated.
- **Portrait:** the supplied photo is bundled at `assets/images/yorn_nona_portrait.jpg`
  and configured as `portraitAsset` for Home and About. To replace it, update that
  asset or the profile path. YN initials remain the fallback if loading fails.
- **Screenshots:** add originals under `assets/projects/` and populate each
  project's `screenshots` list with full asset paths. Missing images have a fallback.
  Existing phone artwork is code-drawn and labeled **ILLUSTRATIVE PREVIEW**.
- **Project links:** set verified `repositoryUrl` / `appStoreUrl` values per project.
- **LinkedIn and Telegram:** add actual HTTPS profile URLs to `linkedIn` /
  `telegramUrl`. A Telegram number alone is shown as contact information; no link
  or username is inferred from it.
- **Case-study challenges:** replace `discussionTopics` and the honest
  not-yet-supplied explanation only when real challenge/solution narratives exist.
  Conceptual architecture is labeled as such; repository structures are not claimed.

All four asset directories are registered. If you add subdirectories, also add
those subdirectories to `pubspec.yaml`. No project screenshots,
project repository links, store links, or CV PDF were provided with this task.

## Design and accessibility

Saved design previews: [Desktop light](docs/previews/home-light.png) ·
[Desktop dark](docs/previews/home-dark.png) ·
[Mobile light](docs/previews/home-mobile-light.png) ·
[Mobile dark](docs/previews/home-mobile-dark.png) ·
[Contact form light](docs/previews/contact-form-light.png) ·
[Contact form dark](docs/previews/contact-form-dark.png).

Khmer previews: [Settings](docs/previews/settings-khmer-light.png) ·
[Home](docs/previews/home-khmer-light.png) ·
[Contact dark](docs/previews/contact-khmer-dark.png).
Language button: [English](docs/previews/language-button-en-light.png) ·
[Khmer dark](docs/previews/language-button-km-dark.png).

Contact uses a compact profile card, icon-led rounded fields with focus and error
states, a live message counter, and a full-width Send action. On desktop, profile
and social links sit beside the form; smaller screens use a single column.

The interface follows iOS conventions: grouped white surfaces on a light gray
canvas, black and charcoal surfaces in dark mode, system blue accents, and large
page titles. Apple platforms use their system text font; Inter is bundled as the
font for other platforms. Borderless cards have 22 px corners and buttons use
14 px corners. The app uses `CupertinoApp`, transparent Cupertino navigation
bars, native page transitions, a translucent tab bar, Cupertino buttons,
segmented controls, an iOS switch, and grouped action rows throughout.
Feedback uses iOS dialogs, text selection uses Cupertino menus, and the licenses
browser and license details use the same navigation and visual system.
Content adapts up to 1160 px. The supplied portrait appears on Home and About.
Project previews are clearly labeled illustrations.

Body text scaling remains enabled. Segmented selections wrap into buttons for
larger text. Decorative illustrations and Cupertino tab labels follow a fixed
scale. Primary actions have 48 px targets; Cupertino controls use native sizing.
Layout grids adapt to available width, and long content scrolls. System reduced
motion and accessibility navigation settings take priority over the app animation
preference, disabling entrances, Hero flights and route transitions. URL, clipboard,
file, preview and settings failures return useful feedback instead of crashing.

## Verify and release

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build web --release
flutter build apk --debug
flutter build ios --release --no-codesign
```

Tests exercise every content route at 320 px with 200% text scale, 834 px tablet,
and 1440 px desktop; they also cover tab navigation, project filtering/details,
missing CV/social links, persistence, contact URI construction and service errors.
CI runs formatting, analysis, tests and a release web build on pushes/PRs.
To regenerate desktop Home previews and every mobile content screen in both
themes, run:

```sh
flutter test --dart-define=CAPTURE_PREVIEWS=true
```

See [release setup](docs/RELEASE.md) for identifiers, signing, native validation,
and store preparation. Native mail, phone, PDF preview, file picker and sharing
should also be checked on physical iOS/Android devices after adding the real PDF.

## Dependencies

Riverpod, go_router, flutter_animate, google_fonts, flutter_svg, url_launcher,
shared_preferences, printing and file_saver. Package APIs were checked against the
[printing documentation](https://pub.dev/packages/printing) and
[file_saver documentation](https://pub.dev/packages/file_saver); version resolution
uses Flutter's stable package solver. The local data remains usable offline.
External links need their destination apps/network. Web PDF rasterization uses
printing's PDF.js support and can require a network connection on first preview.
Native localization uses Flutter's `flutter_localizations`. The bundled
[Noto Sans Khmer font](https://github.com/google/fonts/tree/main/ofl/notosanskhmer)
includes its SIL Open Font License in `assets/fonts/NotoSansKhmer-OFL.txt`.
US and Cambodian flag SVGs come from [flag-icons](https://github.com/lipis/flag-icons),
with the MIT license bundled in `assets/icons/flags/LICENSE.txt`. The US stars
use explicit SVG instances for compatibility with Flutter's SVG renderer.

Regenerate the code-drawn launcher icons on macOS:

```sh
swift -module-cache-path /tmp/portfolio-swift-cache tool/generate_icons.swift
```
