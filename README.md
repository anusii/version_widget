# Version Widget

A Flutter widget that displays version information with optional changelog date and link. This widget is designed to be used across multiple apps to maintain consistent version display and changelog access.

## Features

- Display version information
- Optional release date display
- Automatic date extraction from CHANGELOG.md files
- Clickable link to view the full changelog
- Customizable styling
- Fallback date support

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  version_widget:
    git:
      url: https://github.com/yourusername/version_widget.git
```

## Usage

Basic usage:

```dart
import 'package:version_widget/version_widget.dart';

// In your widget tree:
VersionWidget(
  version: '1.0.0',
)
```

With changelog support:

```dart
VersionWidget(
  version: '1.0.0',
  changelogUrl: 'https://github.com/yourusername/yourrepo/raw/main/CHANGELOG.md',
  showDate: true,
  defaultDate: '20240101',
)
```

## CHANGELOG.md Format

The widget expects the CHANGELOG.md file to have dates in the following format:
```markdown
## [1.0.0 20240101]
- Initial release
```

## Properties

- `version` (required): The version string to display
- `changelogUrl` (optional): URL to the CHANGELOG.md file
- `showDate` (optional): Whether to show the release date (defaults to true)
- `defaultDate` (optional): Default date to show if changelog cannot be fetched (format: YYYYMMDD)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.