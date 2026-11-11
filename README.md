# InterviewDex

Real interview questions for Flutter developers. Built with Flutter.

The app follows a feature-first Clean Architecture structure:

- `lib/core/` contains shared app services and configuration.
- `lib/features/<feature>/` keeps feature code in `data`, `domain`, and
  `presentation` layers as needed.
- `assets/tracks/` contains track metadata and content; see
  [the content format guide](assets/tracks/README.md).

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
