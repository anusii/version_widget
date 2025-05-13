[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)

[![Last Updated](https://img.shields.io/github/last-commit/anusii/version_widget?label=last%20updated)](https://github.com/anusii/version_widget/commits/dev/)
[![Git Version](https://img.shields.io/badge/dynamic/yaml?url=https://raw.githubusercontent.com/anusii/version_widget/master/pubspec.yaml&query=$.version&label=version)](https://github.com/anusii/version_widget/blob/dev/CHANGELOG.md)
[![Pub Version](https://img.shields.io/pub/v/version_widget?label=pub.dev&labelColor=333940&logo=flutter)](https://pub.dev/packages/version_widget)
[![GitHub Issues](https://img.shields.io/github/issues/anusii/version_widget)](https://github.com/anusii/version_widget/issues)
[![GitHub License](https://img.shields.io/github/license/anusii/version_widget)](https://raw.githubusercontent.com/anusii/version_widget/main/LICENSE)
[![GitHub commit activity (dev)](https://img.shields.io/github/commit-activity/w/anusii/version_widget/dev)](https://github.com/anusii/version_widget/commits/dev/)

# Version Widget

A Flutter widget that displays version information with optional
changelog date and link. This widget is designed to be used across
multiple apps to maintain consistent version display and changelog
access.

![image](https://github.com/anusii/version_widget/blob/main/assets/screenshots/example.png)

## Features

- Display version information in a simple text widget
- Optionally also display the release date
- Automatic date extraction from CHANGELOG.md files
- Clickable link to view the full CHANGELOG
- Customizable styling
- Fallback date support
- Custom tooltip messages
- Visual indicator for outdated version
- Network connectivity handling
- Formatted date display (DD MMM YYYY)

## Installation

Add the package to you app's `pubspec.yaml` file:

```yaml
dependencies:
  version_widget: ^1.0.0
```

## Usage

Basic usage:

```dart
import 'package:version_widget/version_widget.dart';

// In your widget tree:

VersionWidget(
  version: '1.0.0',  // Required parameter
)
```

With CHANGELOG support:

```dart
VersionWidget(
  version: '1.0.0',
  changelogUrl: 'https://github.com/yourusername/yourrepo/raw/main/CHANGELOG.md',
  showDate: true,
  defaultDate: '20240101',
)
```

With custom tooltip messages:

```dart
VersionWidget(
  version: '1.0.0',  // Required parameter
  changelogUrl: 'https://github.com/yourusername/yourrepo/raw/main/CHANGELOG.md',
  isLatestTooltip: 'Your app is up to date! Enjoy the latest features.',
  notLatestTooltip: 'Version $_latestVersion is available with new features!',
)
```

## Version Status Indicators

- Grey text: Version is being checked
- Blue text: Version is up to date
- Red bold text: Newer version is available
- No date shown: Internet connection unavailable

## CHANGELOG.md Format

The widget expects the CHANGELOG.md file to have dates in the
following format. The important part is `[1.0.0 20250101` and the
first such text found is interpreted as the latest version and
timestamp. This allows, for example, the string to be `[1.0.0 20250514
fred]` as a common format to attribute changes to users.

```markdown
## [1.0.0 20250101]
- Initial release
```

The widget will automatically find the correct release date for the
current version by matching against all version entries in the
changelog.

## Properties

- `version` (required): The version string to display. Must be provided.
- `changelogUrl` (optional): URL to the CHANGELOG.md file
- `showDate` (optional): Whether to show the release date (defaults to true)
- `defaultDate` (optional): Default date to show if changelog cannot be fetched (format: YYYYMMDD)
- `isLatestTooltip` (optional): Custom message to show when version is latest
- `notLatestTooltip` (optional): Custom message to show when newer version is available

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file
for details.
