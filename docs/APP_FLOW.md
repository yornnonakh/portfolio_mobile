# Yorn Nona · Portfolio v1

## App flow

Splash (`/`) → Home (`/home`). Four persistent, independent tab stacks:
Home (`/home`), Projects (`/projects`), About (`/about`), Contact (`/contact`).
Projects → Case study (`/projects/:id`). Home/About → Skills (`/skills`),
Experience (`/experience`), Resume (`/resume`). Header → Settings (`/settings`).
Settings → Licenses (`/licenses`) → individual license details.
Detail screens have back navigation; unknown routes offer a safe return home.
Direct links to all screens work without waiting for the splash screen.

Recruiter: introduction → featured project → case study → resume → contact.
Technical reviewer: skills → experience → project implementation notes → GitHub.
Owner: settings → theme and animation preferences, persisted on this device.
Settings → Language switch (off: English / on: ភាសាខ្មែរ) updates the complete interface without
leaving the current route. The choice persists alongside theme and motion.
Project filter selections and contact form input remain intact when switching.
The language text beside Settings switches directly between English and Khmer
with one tap. The US/Cambodian flag updates with the selected language. Tapping
the language name in Settings does the same; no selection popup is shown.
The Dark mode switch selects dark when on and light when off. Follow system
tracks device appearance; changing Dark mode selects a manual preference.
Turning Follow system off keeps the currently displayed appearance.
Contact: user name, email, phone, and message → validation → prefilled email
draft to the profile email → Gmail in the browser if no mail app is available.
Web uses Gmail directly. The visitor completes sending in their email app or
Gmail; the form retains its input and offers Copy message if both launches fail.

## Design system

Dark: canvas #000000, grouped surface #1C1C1E, accent #0A84FF.
Light: canvas #F2F2F7, grouped surface #FFFFFF, accent #007AFF.
Apple system typography on Apple platforms, Inter elsewhere. Large page titles,
22 px borderless cards, 14 px buttons, round portraits, Cupertino icons, grouped
rows, native segmented controls, and an iOS switch keep the UI consistent.
The root app, navigation bars, page routes, buttons, alerts, text-selection menus,
and licenses browser use Cupertino widgets. Navigation bars are transparent;
the Cupertino tab bar is translucent, fixed at the bottom, and inset with 30 px
corners. Skills and Experience use grouped rows
and cards consistent with the rest of the app.
Project artwork is labeled illustrative. Content is constrained to 1160 px;
grids adapt to available width. Body text scales; large-text selections wrap into
buttons. Cupertino tab labels follow native sizing. System reduced motion
and user preferences disable entrance, Hero and route animations.

## Architecture

Feature-first presentation and application view models; immutable domain models
in shared/models; a repository contract with a local implementation in shared/data;
Riverpod is the dependency boundary. Settings persistence, URL actions, and CV
assets are services. Widgets never hold personal facts or project copy.

Home is implemented first on the shared components, then projects/details, followed
by About, Skills, Experience, Resume, Contact, Splash and Settings.

## Truth and missing assets

Only the supplied CV facts are represented as professional claims. No inferred
employer, expertise score, rating, availability, results, metrics or store link.
The supplied six-month experience is a fixed CV fact, not calculated from dates.
Project artwork is visibly labeled illustrative, not represented as screenshots.
Architecture sketches are conceptual; challenges/solutions are discussion prompts
until the owner supplies verified case-study details. LinkedIn, Telegram and
project URLs remain unavailable until supplied. The supplied portrait appears on
Home and About. The CV has an explicit empty state. No synthetic PDF is presented
as the original CV.
