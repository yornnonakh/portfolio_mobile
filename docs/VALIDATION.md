# Validation

## iOS UI refresh · 20 October 2026

- Dart formatting: passed across `lib` and `test`.
- Flutter static analysis: no issues.
- Full suite with preview capture: all 37 tests passed.
- Layout coverage: every content route at 320 px with 200% text, tablet, and desktop.
- Visual previews: desktop Home and every mobile content screen in both themes, including project details, Skills, Experience, Resume, and Licenses.
- Cupertino app shell, navigation bars, page routes, buttons, dialogs, selection menus, tabs, segmented controls, switch, grouped rows, and loading indicators.
- Clipboard confirmation and license-detail back navigation pass integration checks.
- Contact form checks cover required/invalid fields, full email draft contents,
  Unicode and special-character encoding, and input preservation when an email app cannot open.
- Contact form light/dark previews are saved alongside the full-page previews.
- Modern contact layout: compact profile card, responsive columns, rounded input
  fields with focus/error states, message counter, and inline action feedback.
- Khmer/English: Settings and the app-bar flag switch the full UI immediately;
  native controls are localized, and the language choice restores on startup.
  Storage failure leaves the previous choice intact. Contact input and project
  filters survive switching. Every Khmer route passes in both themes at 320 px
  with 200% text, tablet, and desktop. Bundled-font Khmer previews are saved.
- Direct language switching: localization checks cover tapping the language text
  in either direction, saving the choice, staying on the current tab, and 320 px
  with 200% text. English/Khmer button previews include the bundled SVG flags.
- Settings uses Cupertino switches for language, dark/light appearance, following
  device appearance, and motion. Checks cover manual light/dark selection, device
  brightness changes in system mode, saved preferences, and both UI languages.
- Email fallback checks cover missing/throwing mail handlers, Gmail with every form
  detail preserved, browser dispatch, an explicit Gmail button, and copying the full
  message when both launches fail. The Gmail compose URL opens successfully in Safari
  on the running iPhone 17 Pro Max simulator; no email was sent during validation.

The build results below predate the UI refresh.

## Build verification · 19 October 2026

Flutter 3.44.8 stable, Dart 3.12.2, Xcode 26.3.

| Check | Result |
| --- | --- |
| Dart formatting | Passed |
| Flutter static analysis | No issues |
| Full suite with preview capture | 14 tests passed |
| Release web compilation | Passed, including Wasm compatibility dry run |
| Android debug APK | Passed |
| Unsigned iOS release | Passed, 20.7 MB app bundle |

Tests cover every content route, unknown routes and unknown project IDs at
320 × 700 with 200% text scaling, 834 × 1194, and 1440 × 1000; they also exercise
splash redirection, tabs, filtering, case studies, preference persistence, system
reduced motion, missing assets/links, contact URI creation, error recovery, and
PDF asset validation. The opt-in capture test loads the real font/icon assets
and exports the light/dark previews under `docs/previews/`. The release web app
was also rendered in Chrome for visual review.

Build outputs (generated, excluded from source control):

- `build/app/outputs/flutter-apk/app-debug.apk`
- `build/ios/iphoneos/Runner.app`
- `build/web/`

The supplied portrait is bundled for Home and About.
The PDF, original screenshots and project/social URLs described as
missing in README were not supplied. PDF preview/save/share integrations compile;
physical-device checks with the owner's actual PDF and mail/phone applications
remain part of release acceptance. Store signing, upload and publication have
not been performed. No credentials or provisioning profiles were created.
