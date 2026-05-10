# Version Widget

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)

[![GitHub License](https://img.shields.io/github/license/anusii/version_widget)](https://raw.githubusercontent.com/anusii/version_widget/main/LICENSE)
[![GitHub Version](https://img.shields.io/badge/dynamic/yaml?url=https://raw.githubusercontent.com/anusii/version_widget/main/pubspec.yaml&query=$.version&label=version&logo=github)](https://github.com/anusii/version_widget/blob/main/CHANGELOG.md)
[![Pub Version](https://img.shields.io/pub/v/version_widget?label=pub.dev&labelColor=333940&logo=flutter)](https://pub.dev/packages/version_widget)
[![GitHub Last Updated](https://img.shields.io/github/last-commit/anusii/version_widget?label=last%20updated)](https://github.com/anusii/version_widget/commits/main/)
[![GitHub Commit Activity (main)](https://img.shields.io/github/commit-activity/w/anusii/version_widget/main)](https://github.com/anusii/version_widget/commits/main/)
[![GitHub Issues](https://img.shields.io/github/issues/anusii/version_widget)](https://github.com/anusii/version_widget/issues)

A Flutter widget that displays version information with optional
changelog date and link. This widget is designed to be used across
multiple apps to maintain consistent version display and changelog
access.

![screenshot](https://raw.githubusercontent.com/anusii/version_widget/refs/heads/main/assets/screenshots/example.png)

## Features

- Display version information in a simple text widget
- Optionally also display the release date
- Automatic date extraction from CHANGELOG.md files
- Clickable to view the full CHANGELOG in an in-app dialogue with markdown rendering
- Customisable styling
- Fallback date support
- Custom tooltip messages
- Visual indicator for outdated version
- Network connectivity handling
- Formatted date display (DD MMM YYYY)
- Optional inline discover-and-download button when a newer release is detected

## Installation

Add the package to you app's `pubspec.yaml` file:

```yaml
dependencies:
  version_widget: ^1.0.5
```

## Usage

Basic usage:

```dart
import 'package:version_widget/version_widget.dart';

// In your widget tree:

VersionWidget(
  version: '1.0.5',  // Required parameter
)
```

With CHANGELOG support:

```dart
VersionWidget(
  version: '1.0.5',
  changelogUrl: 'https://raw.githubusercontent.com/anusii/version_widget/main/CHANGELOG.md',
  showDate: true,
  defaultDate: '20240101',
)
```

With custom tooltip messages:

```dart
VersionWidget(
  version: '1.0.5',  // Required parameter
  changelogUrl: 'https://github.com/anusii/version_widget/raw/main/CHANGELOG.md',
  isLatestTooltip: 'Your app is up to date! Enjoy the latest features.',
  notLatestTooltip: 'Version $_latestVersion is available with new features!',
)
```

With the discover-and-download button enabled. When the widget detects
a newer release in the CHANGELOG it renders a small button to the
right of the version label. Tapping the button opens
`downloadUrl` in the default external handler (typically the system
browser or platform installer).

```dart
VersionWidget(
  version: '1.0.5',
  changelogUrl: 'https://github.com/anusii/version_widget/raw/main/CHANGELOG.md',
  showUpdateButton: true,
  downloadUrl: 'https://example.com/downloads/myapp-latest.exe',
)
```

Hide the version number text but keep the update button visible
(useful when only the upgrade affordance is desired):

```dart
VersionWidget(
  version: '1.0.5',
  changelogUrl: 'https://github.com/anusii/version_widget/raw/main/CHANGELOG.md',
  showVersion: false,
  showUpdateButton: true,
  downloadUrl: 'https://example.com/downloads/myapp-latest.exe',
)
```

## Version Status Indicators

- Grey text: Version is being checked
- Blue text: Version is up to date
- Red bold text: Newer version is available
- No date shown: Internet connection unavailable

## CHANGELOG.md Format

The widget expects the CHANGELOG.md file to have dates in the
following format. The important part is `[1.0.5 20250101` and the
first such text found is interpreted as the latest version and
timestamp. This allows, for example, the string to be `[1.0.5 20250514
fred]` as a common format to attribute changes to users.

```markdown
## [1.0.5 20250101]
- Initial release
```

The widget will automatically find the correct release date for the
current version by matching against all version entries in the
changelog.

## Properties

- `version` (required): The version string to display. Must be provided.
- `changelogUrl` (optional): URL to the CHANGELOG.md file
- `showVersion` (optional): Whether to show the version number text
  (defaults to true). When false the text is hidden but the changelog
  is still consulted so the optional update button can still appear.
- `showDate` (optional): Whether to show the release date (defaults to true)
- `defaultDate` (optional): Default date to show if changelog cannot
  be fetched (format: YYYYMMDD)
- `isLatestTooltip` (optional): Custom message to show when version is latest
- `notLatestTooltip` (optional): Custom message to show when newer version is available
- `showUpdateButton` (optional): Whether to show the discover-and-download
  button when a newer version is detected (defaults to false). The
  button is only rendered when this flag is enabled, a newer version
  is found and `downloadUrl` is provided.
- `downloadUrl` (optional): URL launched when the update button is
  tapped. Typically points at an installer (.exe, .apk, .dmg) or a
  release page. Required for the update button to be rendered.
- `updateButtonLabel` (optional): Text label shown next to the icon on
  the update button (defaults to `Update`).

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file
for details.
