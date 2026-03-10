# Neram - World Clock

A beautiful world clock app with glassmorphic dark UI, mechanical flip clock animations, and PWA support. Built with Flutter.

## Features

- **Mechanical Flip Clock** — Smooth animated digit transitions for a premium feel
- **Multi-Timezone Support** — Track up to 11 timezones simultaneously
- **Smart Search** — Find timezones by city name (Miami, Delhi), country, abbreviation (EST, IST), UTC offset, or current time (3pm)
- **Drag to Reorder** — Rearrange clocks with drag handles, first position becomes master
- **Time Preview** — Horizontal slider to see what time it will be in other zones at any offset
- **Bookmarks** — Save and restore clock layouts with time offsets
- **Share** — Share times as formatted text or screenshots
- **PWA** — Install on your device, works offline
- **Dark Glassmorphic Design** — Apple-inspired blur and glass effects

## Live Demo

Visit the live app (after GitHub Pages deployment):
> `https://<username>.github.io/neram_app/`

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.x (Web + Mobile) |
| State Management | Riverpod |
| Timezone Data | IANA via `timezone` package |
| Search | `fuzzywuzzy` + custom scoring pipeline |
| Persistence | `shared_preferences` |
| Sharing | `share_plus` + clipboard fallback for web |
| Fonts | Google Fonts |

## Getting Started

### Prerequisites

- Flutter SDK 3.x (stable channel)
- Chrome browser (for web development)

### Run Locally

```bash
git clone https://github.com/<username>/neram_app.git
cd neram_app
flutter pub get
flutter run -d chrome
```

### Build for Production

```bash
flutter build web --release --base-href /neram_app/
```

### Deploy to GitHub Pages

Push to `main` branch — GitHub Actions automatically builds and deploys to Pages.

## Project Structure

```
lib/
  core/           # Constants, colors, extensions, utilities
  data/           # Models, services, repositories
  features/
    clock/        # Main clock display, providers, widgets
    search/       # Timezone search screen
    bookmarks/    # Bookmark save/restore
    messaging/    # Share times screen
    settings/     # App settings
  shared/         # Reusable widgets (glassmorphic cards, buttons)
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

MIT License. See [LICENSE](LICENSE) for details.
