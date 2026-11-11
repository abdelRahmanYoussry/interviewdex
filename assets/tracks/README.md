# Track content format

The track index is `index.json`. Each track has a folder named after its stable
ID, a `track.json` metadata file, a single-colour transparent PNG icon image in
that folder, and one JSON file for each topic. The icon field is a filename
relative to that track folder, not a Flutter icon name. Render it as an
`ImageIcon` (or equivalent alpha-mask image) with the current theme colour.

All user-facing text is a localized map with a required `en` value, for example
`{"en": "Flutter basics"}`. Add another locale by adding a key such as `ar`;
IDs, enum values, filenames, source references, code solutions, and language
codes are structural or technical values, not display text. `source` is a
plain string: it is either an HTTPS URL whose hostname appears in that track's
`sourceHosts`, or a short reason beginning with `Reason: `. `sourceHosts` is
required in each `track.json` and lists the documentation hosts used by that
track. Whether a particular card should cite documentation is a content review
checklist rule, not a loader rule. Domain text values resolve the requested
language and fall back to English.

JSON Schemas are in `schemas/`. The Dart loader applies required-field, type,
enum, localized-text, and key-point-count checks at runtime. A malformed track
or topic is logged and skipped. A malformed interview card is logged and
skipped without discarding its valid neighbors.

The Flutter topics contain sample interview cards and the initial Quick Quiz
content. The quiz bank has five reviewed items for each supported topic.

To add a new track, add its ID to `index.json`, create its folder and metadata,
then add one asset line to `pubspec.yaml`, such as
`- assets/tracks/frontend/`. Include its track icon and topic JSON files.

## Content review checklist

- Check factual technical cards against an official source when one is needed;
  source-host validation is track-configured, while deciding which cards need
  links is a content review responsibility.
- Confirm each source URL host is listed in the track's `sourceHosts`, or that
  a reason begins with `Reason: ` and explains this specific card.
- Check answer accuracy, plain-English phrasing, plausible distractors when
  applicable, and a source or specific reason for each card.

## Question fields

- `stage`: `intro`, `behavioral`, `technical`, or `liveCoding`.
- `difficulty`: `junior`, `mid`, or `senior`.
- Every item in `interviewCards` has a unique track-wide ID, a required plain
  string `source` (an official documentation URL or a short card-specific
  reason), and exactly
  three localized `keyPoints`, `question`, `answer`, `followUp`, and
  `commonMistake`.
- `fillInTemplate` is optional and contains a localized template plus localized
  labels and placeholders. Every `{placeholder}` must have a matching field
  ID. No answer for a card with a `fillInTemplate` may contain placeholders;
  keep the candidate's `answer` a complete example, not the template.
- A `liveCoding` card must include a plain-string Dart code `solution`,
  localized explanation steps, and localized time and space complexity.
Topics may add optional `quiz` and `bugHunts` arrays. Quiz IDs are unique
across the whole track, including every interview card ID.

## Quiz item fields

Every quiz item has `id`, `type`, `difficulty`, `source`, `question`, `why`,
and `tip`. `type` is `multipleChoice` or `trueFalse`; difficulty is `junior`,
`mid`, or `senior`. A source follows the same track-host URL or `Reason: `
rules as interview cards. `why` explains the correct answer and `tip` adds one
useful fact; both have one or two short sentences. Optional `code` is a plain
string rendered in JetBrains Mono.

Multiple choice items have four distinct localized `options` and a zero-based
`correctIndex`. True/false items use a localized statement in `question` and a
boolean `answer`.

```json
{
  "id": "quiz_widget_immutability",
  "type": "multipleChoice",
  "difficulty": "junior",
  "source": "https://docs.flutter.dev/ui",
  "question": {"en": "What does a Flutter widget describe?"},
  "options": [
    {"en": "A configuration for part of the interface"},
    {"en": "A mutable object holding every screen pixel"},
    {"en": "A database record for the current route"},
    {"en": "A platform view created for each state change"}
  ],
  "correctIndex": 0,
  "why": {"en": "A widget is an immutable description of part of the user interface."},
  "tip": {"en": "Flutter combines widgets into a tree to describe the screen."}
}
```

```json
{
  "id": "quiz_const_canonicalization",
  "type": "trueFalse",
  "difficulty": "mid",
  "source": "https://dart.dev/language/variables",
  "question": {"en": "Dart can canonicalize identical compile-time constant objects."},
  "answer": true,
  "why": {"en": "Identical constant expressions can refer to the same canonical instance."},
  "tip": {"en": "Use const when the value is known at compile time."}
}
```
