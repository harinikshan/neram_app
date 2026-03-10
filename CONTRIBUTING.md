# Contributing to Neram

Thanks for your interest in contributing! Here's how to get started.

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/<your-username>/neram_app.git`
3. Install Flutter (stable channel, 3.x+)
4. Run `flutter pub get`
5. Run locally: `flutter run -d chrome`

## Development Workflow

1. Create a feature branch: `git checkout -b feature/my-feature`
2. Make your changes
3. Run analysis: `flutter analyze`
4. Build web: `flutter build web`
5. Commit with a clear message
6. Push and open a Pull Request

## Code Style

- Follow [Effective Dart](https://dart.dev/effective-dart) conventions
- Use Riverpod for state management
- Keep widget files focused (one main widget per file)
- Feature-first folder structure under `lib/features/`

## Reporting Issues

- Use GitHub Issues
- Include steps to reproduce
- Include browser/device info for web issues
- Screenshots are helpful

## Pull Requests

- Keep PRs focused on a single change
- Update any affected documentation
- Ensure `flutter analyze` passes with 0 issues
- Test on Chrome (web is the primary target)
