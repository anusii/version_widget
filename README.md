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
  version_widget: ^1.1.0
```

## Usage

Basic usage:

```dart
import 'package:version_widget/version_widget.dart';

// In your widget tree:

VersionWidget(
  version: '1.1.0',  // Required parameter
)
```

With CHANGELOG support:

```dart
VersionWidget(
  version: '1.1.0',
  changelogUrl: 'https://raw.githubusercontent.com/anusii/version_widget/main/CHANGELOG.md',
  showDate: true,
  defaultDate: '20240101',
)
```

With custom tooltip messages:

```dart
VersionWidget(
  version: '1.1.0',  // Required parameter
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
  version: '1.1.0',
  changelogUrl: 'https://github.com/anusii/version_widget/raw/main/CHANGELOG.md',
  showUpdateButton: true,
  downloadUrl: 'https://example.com/downloads/myapp-latest.exe',
)
```

Hide the version number text but keep the update button visible
(useful when only the upgrade affordance is desired):

```dart
VersionWidget(
  version: '1.1.0',
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
- Amber text: The version could not be checked (eg unpublished changelog, CORS
  block to changelog, app with no version)

A failed check is reported and does not offer an app update button. Pass
`assumeLatestOnCheckFailure: true` to restore the older, quieter behaviour.

Apps that do not report their own version — an empty
or non-numeric `version` are also now reported as a failed check.

## CHANGELOG.md Format

The widget expects the CHANGELOG.md file to have dates in the
following format. The important part is `[1.0.5 20250101` and the
first such text found is interpreted as the latest version and
timestamp. An author may sit on either side of the date, so both
`[1.0.5 20250514 fred]` and `[1.0.5 fred 20250514]` are read correctly.
The first form is the convention across our apps; the second is
tolerated so an app is not silently unversioned for writing it.

```markdown
## [1.0.5 20250101]
- Initial release
```

The widget will automatically find the correct release date for the
current version by matching against all version entries in the
changelog.

## Private repositories

The CHANGELOG must be published, as the widget fetches the CHANGELOG with a
plain, unauthenticated GET.

Developers with private app repositories are recommended to publish their
changelog to the same origin as the web app, to avoid CORS block issues. Ie
build your web app and then add publish CHANGELOG file.

```make
flutter build web --release
cp CHANGELOG.md build/web/CHANGELOG.md    # after the build, not in web/
```

Copy it after the build keeps the file out of anything Flutter
generates from `web/` to prevent caching issues.

When the changelog genuinely cannot be made public, supply a
`changelogLoader` and fetch it yourself:

```dart
// From an authenticated backend, using a token the app already holds
// from the signed in session.

VersionWidget(
  version: '1.1.0',
  changelogUrl: 'https://api.example.com/changelog',
  changelogLoader: (url) async {
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer ${session.accessToken}'},
    );
    return response.body;
  },
)

// Or bundled with the build. This populates the changelog dialogue but
// can never detect an update, since it is frozen at build time.

VersionWidget(
  version: '1.1.0',
  changelogUrl: 'asset',
  changelogLoader: (_) => rootBundle.loadString('assets/CHANGELOG.md'),
)
```

Never compile a long lived credential. Use a token the user's own
session already provides, or make the changelog public.

## Properties

- `version` (required): The version string to display. Must be provided.
- `changelogUrl` (optional): URL to the CHANGELOG.md file
- `showVersion` (optional): Whether to show the version number text
  (defaults to true). When false the text is hidden but the changelog
  is still consulted so the optional update button can still appear.
- `showDate` (optional): Whether to show the release date (defaults to true)
- `defaultDate` (optional): Default date to show if changelog cannot
  be fetched (format: `YYYYMMDD`)
- `isLatestTooltip` (optional): Custom message to show when version is latest
- `notLatestTooltip` (optional): Custom message to show when newer version is available
- `unknownTooltip` (optional): Custom message to show when the check could
  not be completed
- `unknownColor` (optional): Colour of the version label when the check
  could not be completed (defaults to a muted amber). Applied on top of
  `userTextStyle` too, so pick one that stays legible on your background.
- `assumeLatestOnCheckFailure` (optional): Report a failed check as up to
  date, as releases before 1.1.0 did (defaults to false)
- `changelogLoader` (optional): Supplies the CHANGELOG text instead of the
  built-in HTTP GET. See Private repositories above.
- `onUpdatePressed` (optional): Called instead of launching `downloadUrl`
  when the update button is tapped. Useful for a web app, where the update
  is a reload rather than an installer.
- `showUpdateButton` (optional): Whether to show the discover-and-download
  button when a newer version is detected (defaults to false). The
  button is only rendered when this flag is enabled, a newer version
  is found and `downloadUrl` is provided.
- `downloadUrl` (optional): URL launched when the update button is
  tapped. Typically points at an installer (.exe, .apk, .dmg) or a
  release page. Required for the update button to be rendered.
- `updateButtonLabel` (optional): Text label shown next to the icon on
  the update button (defaults to `Update`).

## Platform setup

### MacOS/iOS

MacOS and iOS builds of apps using version widget require these settings to pick
up the app version, which is used to compare against the changelog

In `Runner/Info.plist` within `macos` and `ios` folders, set:

<!-- Tabs below are verbatim from Info.plist, so keep them as tabs. -->
<!-- markdownlint-disable MD010 -->

```xml
	<key>CFBundleShortVersionString</key>
	<string>$(FLUTTER_BUILD_NAME)</string>
```

<!-- markdownlint-enable MD010 -->

If using `xcodegen` to generate XCode files, your `macos` and `ios`
`project.yml` files must contain:

```yml
MARKETING_VERSION: '$(FLUTTER_BUILD_NAME)'
CURRENT_PROJECT_VERSION: '$(FLUTTER_BUILD_NUMBER)'
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file
for details.
