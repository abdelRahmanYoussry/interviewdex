# InterviewDex

Real interview questions for Flutter developers. Built with Flutter.

The app supports English and Arabic (RTL), system/light/dark appearance, and
saves both preferences locally. Fonts are bundled for offline use, and their
OFL license texts are registered in the app's license registry.

Interview practice opens the Flutter track directly when it is the only
available track, and shows a picker when there are multiple tracks. Card
progress is stored on-device in a versioned per-track record. Ratings schedule
the next review using spaced repetition; a card is mastered after two
consecutive “Nailed it” ratings. Sessions can be resumed at the same card and
reveal state, behavioural answer templates save drafts locally, and an
optional 90-second timer helps practice answers out loud.

The app follows a feature-first Clean Architecture structure:

- `lib/core/` contains shared app services and configuration.
- `lib/features/<feature>/` keeps feature code in `data`, `domain`, and
  `presentation` layers as needed.
- `assets/tracks/` contains track metadata and content; see
  [the content format guide](assets/tracks/README.md).
- `lib/l10n/` contains the English and Arabic ARB translations.
- `lib/core/analytics/` defines analytics events and a no-op implementation
  until the Firebase analytics phase.

## Run

```shell
flutter pub get
flutter run -d chrome
```

## Validate

```shell
flutter analyze
flutter test
```

## GitHub Pages

The GitHub Actions workflow analyzes and tests pull requests to `main`. Every
push to `main` also builds the web app with the `/interviewdex/` base path and
deploys it to GitHub Pages. Set the repository's Pages source to **GitHub
Actions** in its settings.
