/// Version widget for the app.
///
// Time-stamp: <Wednesday 2026-09-09 09:24:05 +1000 Jess Moore>
///
/// Copyright (C) 2024-2026, Software Innovation Institute, ANU.
///
/// Licensed under the MIT License (the "License").
///
/// License: https://choosealicense.com/licenses/mit/.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program.  If not, see <https://choosealicense.com/licenses/mit/>.
///
/// Authors: Kevin Wang, Tony Chen, Jess Moore

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'package:markdown_tooltip/markdown_tooltip.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:version_widget/src/models/version_status.dart';
import 'package:version_widget/src/utils/compare_versions.dart';
import 'package:version_widget/src/utils/fetch_changelog.dart';
import 'package:version_widget/src/utils/format_date.dart';
import 'package:version_widget/src/utils/parse_changelog.dart';
import 'package:version_widget/src/widgets/version_changelog_dialog.dart';

/// A widget that displays version information with optional changelog date
/// and link.
///
/// Shows the current version of an app, optionally including the release
/// date read from a CHANGELOG, and offering a link to the full changelog.
///
/// The widget reports one of five outcomes, and the distinction that matters
/// most is between being up to date and not knowing:
///
/// 1. Still checking — grey.
/// 2. No [changelogUrl] configured, so nothing was checked — as before.
/// 3. Up to date — blue.
/// 4. A newer release exists — red, bold, with an optional update button.
/// 5. The check failed — amber, and it says so rather than claiming the app
///    is current. Set [assumeLatestOnCheckFailure] to restore the older,
///    quieter behaviour.
///
/// Styling of the version string is offered in two modes:
///
/// 1. Automatic: when no [userTextStyle] is supplied, the version is styled
///    with a colour denoting status.
/// 2. Custom: when a [userTextStyle] is supplied the host style is used
///    verbatim while the version is up to date or still being checked. When
///    a newer release is detected the host style is preserved for every
///    other field (font family, size, letter spacing, decoration) but
///    `color` and `fontWeight` are escalated to red and bold so the upgrade
///    warning remains visible. A failed check likewise escalates `color`
///    alone, since a host style on a coloured background would otherwise
///    hide the fact that nothing is known.
///
/// Example usage:
/// ```dart
/// VersionWidget(
///   version: '1.0.5',
///   changelogUrl: 'https://github.com/anusii/version_widget/raw/main/CHANGELOG.md',
///   showDate: true,
///   showUpdateButton: true,
///   downloadUrl: 'https://example.com/downloads/myapp-latest.exe',
/// )
/// ```

class VersionWidget extends StatefulWidget {
  /// The version string to display (e.g., '1.0.0').
  /// The version should follow semantic versioning (e.g., '0.0.9').

  final String version;

  /// The URL to the CHANGELOG.md file.
  /// If provided, the widget will attempt to extract the release date and
  /// version from it. Entries are recognised as `[x.x.x YYYYMMDD]`, with an
  /// optional author either side of the date.

  final String? changelogUrl;

  /// Whether to show the version number text.
  /// Defaults to true.
  /// When false, the version text is hidden but version checking still occurs
  /// so that the optional update button can still appear when a newer version
  /// is detected.

  final bool showVersion;

  /// Whether to show the release date alongside the version.
  /// Defaults to true.
  /// When false, only the version number will be displayed.

  final bool showDate;

  /// Unused. The date shown is always the one read from the CHANGELOG, and
  /// no date is shown when the check does not produce one.

  @Deprecated('Never read; will be removed in 2.0.0.')
  final String? defaultDate;

  /// Custom tooltip message to show when the version is the latest.
  /// If not provided, uses a default message.

  final String? isLatestTooltip;

  /// Custom tooltip message to show when a newer version is available.
  /// If not provided, uses a default message.

  final String? notLatestTooltip;

  /// Custom tooltip message to show when the check could not be completed.
  /// If not provided, uses a default message naming the likely causes.

  final String? unknownTooltip;

  /// The colour of the version label when the check could not be completed.
  /// Defaults to a muted amber. Applied both in the built-in palette and on
  /// top of a supplied [userTextStyle], so choose a shade that stays legible
  /// against the background the version sits on.

  final Color? unknownColor;

  /// Whether a failed or unparsable check should be reported as up to date.
  /// Defaults to false, which is almost always what you want: a silent and
  /// false 'up to date' leaves users on stale builds indefinitely. Provided
  /// to restore the behaviour of releases before 1.1.0.

  final bool assumeLatestOnCheckFailure;

  /// Allow the user to override the [fontSize] to suit the app.

  final double? fontSize;

  /// Allow the host to specify a custom [userTextStyle] that the version
  /// label should adopt. See the class documentation for when the style is
  /// used verbatim and when `color` and `fontWeight` are escalated.

  final TextStyle? userTextStyle;

  /// Supplies the CHANGELOG text instead of the built-in HTTP GET.
  /// Use for a changelog the default fetch cannot reach: one behind
  /// authentication, or one bundled with the build. See [ChangelogLoader].

  final ChangelogLoader? changelogLoader;

  /// Whether to show the discover-and-download button when a newer version is
  /// detected.
  /// Defaults to false (hidden).
  /// The button is only rendered when all of the following are true:
  /// 1. [showUpdateButton] is true
  /// 2. A newer version has been detected from the CHANGELOG
  /// 3. Either [downloadUrl] or [onUpdatePressed] is supplied
  /// It is deliberately not offered when the check failed, since no update is
  /// known to exist.

  final bool showUpdateButton;

  /// The URL to launch when the user taps the discover-and-download button.
  /// Typically points at an installer (.exe, .apk, .dmg) or a release page.

  final String? downloadUrl;

  /// Called instead of launching [downloadUrl] when the update button is
  /// tapped. Lets a web host reload in place rather than open an installer.

  final VoidCallback? onUpdatePressed;

  /// Optional label shown next to the download icon on the update button.
  /// Defaults to 'Update' when null.

  final String? updateButtonLabel;

  /// Creates a new [VersionWidget].
  /// The [version] parameter is required and should be the current version of
  /// the app. All other parameters are optional.

  const VersionWidget({
    super.key,
    required this.version,
    this.changelogUrl,
    this.showVersion = true,
    this.showDate = true,
    @Deprecated('Never read; will be removed in 2.0.0.')
    this.defaultDate = '20260101',
    this.isLatestTooltip,
    this.notLatestTooltip,
    this.unknownTooltip,
    this.unknownColor,
    this.assumeLatestOnCheckFailure = false,
    this.fontSize = 16.0,
    this.userTextStyle,
    this.changelogLoader,
    this.showUpdateButton = false,
    this.downloadUrl,
    this.onUpdatePressed,
    this.updateButtonLabel,
  });

  @override
  State<VersionWidget> createState() => _VersionWidgetState();
}

/// The state class for [VersionWidget].
/// Handles the fetching and display of version information, including:
/// - Fetching changelog data from the provided URL
/// - Parsing version and date information
/// - Managing tooltip display
/// - Handling user interactions

class _VersionWidgetState extends State<VersionWidget> {
  /// The outcome of the version check, driving colour, date and button.

  VersionStatus _status = VersionStatus.checking;

  /// The latest version available from the changelog. Empty until a check
  /// succeeds, so it is never quoted at the user on a guess.

  String _latestVersion = '';

  /// The release date of the current version, in YYYYMMDD format, when the
  /// changelog lists one for it.

  String _currentDate = '';

  /// The current version string (e.g., '0.0.9'), as supplied by the host.

  String _currentVersion = '';

  /// The full CHANGELOG content for display in the dialogue.

  String _changelogContent = '';

  @override
  void initState() {
    super.initState();
    _currentVersion = widget.version;

    // Check whenever a changelog URL is provided, even when the date is
    // hidden, so the update button can still be surfaced.

    if (widget.changelogUrl != null) {
      _checkVersion();
    } else {
      _status = VersionStatus.unchecked;
    }
  }

  /// Fetches and parses the changelog to determine the latest version.
  ///
  /// Every failure — transport, an unusable response, or a body with no
  /// recognisable version entries — lands in [_reportCheckFailure]. That is
  /// the point of this method: an incomplete check must not be reported as a
  /// successful one.

  Future<void> _checkVersion() async {
    final url = convertToRawUrl(widget.changelogUrl!);

    if (kIsWeb && url != widget.changelogUrl) {
      debugPrint('Web platform detected: Converting URL from '
          '${widget.changelogUrl} to $url');
    }

    try {
      // An app that does not know its own version cannot be compared
      // against one that does. Saying so beats ranking it below every
      // release and telling the user to update.

      if (!isComparableVersion(_currentVersion)) {
        throw Exception('The app reported no usable version: '
            '"$_currentVersion"');
      }

      final content = await _load(url);

      if (content.isEmpty) throw Exception('The changelog was empty');

      final entries = parseChangelogEntries(content);
      final latest = latestVersionOf(entries);

      if (latest == null) {
        throw Exception('No `[version date]` entries found in the changelog');
      }

      if (!mounted) return;

      setState(() {
        _changelogContent = content;
        _latestVersion = latest;
        _currentDate = dateForVersion(entries, _currentVersion) ?? '';
        _status = compareVersions(_currentVersion, latest) >= 0
            ? VersionStatus.current
            : VersionStatus.outdated;
      });
    } catch (e) {
      _reportCheckFailure(e);
    }
  }

  /// Loads the changelog, retrying once after a short pause.
  ///
  /// Only transport failures are retried. A response that arrives but cannot
  /// be parsed will not be helped by asking again, and is not retried.

  Future<String> _load(String url) async {
    final loader = widget.changelogLoader ?? fetchChangelogOverHttp;

    try {
      return await loader(url);
    } catch (e) {
      debugPrint('Changelog fetch failed, retrying once in 2s: $e');
      await Future<void>.delayed(const Duration(seconds: 2));

      return loader(url);
    }
  }

  /// Records that nothing is known about the latest version.

  void _reportCheckFailure(Object error) {
    debugPrint('version_widget: could not check the latest version: $error');

    if (kIsWeb) {
      debugPrint('On web the changelog must be served with CORS headers that '
          'permit this origin, or from the same origin as the app. For '
          'GitHub files use raw.githubusercontent.com.');
    }

    if (!mounted) return;

    setState(() {
      _currentDate = '';
      _latestVersion = '';
      _status = widget.assumeLatestOnCheckFailure
          ? VersionStatus.current
          : VersionStatus.unknown;
    });
  }

  /// Launches [VersionWidget.downloadUrl], or defers to the host's handler.

  Future<void> _handleUpdatePressed() async {
    final onPressed = widget.onUpdatePressed;

    if (onPressed != null) {
      onPressed();

      return;
    }

    final downloadUrl = widget.downloadUrl;
    if (downloadUrl == null || downloadUrl.isEmpty) return;

    final uri = Uri.parse(downloadUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Unable to launch download URL: $downloadUrl');
    }
  }

  /// The [TextStyle] applied to the version label.

  TextStyle _versionLabelStyle() {
    final unknownColour = widget.unknownColor ?? Colors.orange.shade800;
    final userStyle = widget.userTextStyle;

    if (userStyle == null) {
      return TextStyle(
        color: _status.colourWith(unknownColour),
        fontSize: widget.fontSize,
        fontWeight: _status.weight,
      );
    }

    // Outdated escalates colour and weight; an unresolved check escalates
    // colour alone. Everything else keeps the host's style untouched.

    switch (_status) {
      case VersionStatus.outdated:
        return userStyle.copyWith(
          color: Colors.red,
          fontWeight: FontWeight.bold,
        );
      case VersionStatus.unknown:
        return userStyle.copyWith(color: unknownColour);
      case VersionStatus.checking:
      case VersionStatus.unchecked:
      case VersionStatus.current:
        return userStyle;
    }
  }

  /// The markdown tooltip describing the current status.

  String _tooltipMessage() {
    const closing = '**Tap** on the **Version** string to view the '
        "app's CHANGELOG.";

    if (_status == VersionStatus.unknown) {
      const defaultUnknown = 'The CHANGELOG could not be checked, so it is '
          'not known whether a newer version is available. Check your '
          'network connection, or the changelog location this app is '
          'configured with.';

      return '''

    **Version $_currentVersion**

    ${widget.unknownTooltip ?? defaultUnknown} $closing

    ''';
    }

    const defaultLatest = 'this is the latest version available.';

    final defaultNotLatest = 'there is a new version available '
        '$_latestVersion. You should consider '
        'updating to the latest version.';

    final body = _status == VersionStatus.outdated
        ? widget.notLatestTooltip ?? defaultNotLatest
        : widget.isLatestTooltip ?? defaultLatest;

    return '''

    **Version $_currentVersion**

    According to the CHANGELOG from the app
    repository $body $closing

    ''';
  }

  /// Builds the inline discover-and-download action button surfaced when a
  /// newer release is detected. Returns null when the button should not be
  /// rendered for the current state.

  Widget? _buildUpdateButton() {
    final downloadUrl = widget.downloadUrl;
    final hasTarget = widget.onUpdatePressed != null ||
        (downloadUrl != null && downloadUrl.isNotEmpty);

    if (!widget.showUpdateButton) return null;
    if (!_status.allowsUpdateButton) return null;
    if (!hasTarget) return null;

    final label = widget.updateButtonLabel ?? 'Update';
    final tooltipMessage = '''

    **New version $_latestVersion available**

    Tap to download and install the latest release. The download URL
    will open in the default external handler (typically your system
    browser or the relevant platform installer).

    ''';

    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: MarkdownTooltip(
        message: tooltipMessage,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _handleUpdatePressed,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.12),
                border: Border.all(color: Colors.red, width: 1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.system_update_alt,
                    size: 16,
                    color: Colors.red,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showDate =
        widget.showDate && _status.showsDate && _currentDate.isNotEmpty;

    final displayText = showDate
        ? 'Version $_currentVersion - ${formatChangelogDate(_currentDate)}'
        : 'Version $_currentVersion';

    final versionLabel = GestureDetector(
      onTap: widget.changelogUrl == null
          ? null
          : () => showChangelogDialog(
                context,
                content: _changelogContent,
                changelogUrl: widget.changelogUrl,
              ),
      child: MouseRegion(
        cursor: widget.changelogUrl == null
            ? SystemMouseCursors.basic
            : SystemMouseCursors.click,
        child: MarkdownTooltip(
          message: _tooltipMessage(),
          child: Text(
            displayText,
            style: _versionLabelStyle(),
          ),
        ),
      ),
    );

    final updateButton = _buildUpdateButton();

    // Short-circuit when neither the version label nor the update button is
    // visible to keep the widget completely transparent in the host layout.

    if (!widget.showVersion && updateButton == null) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final hasFiniteWidth = constraints.maxWidth.isFinite;
        final boundedVersionLabel = hasFiniteWidth
            ? ConstrainedBox(
                constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                child: versionLabel,
              )
            : versionLabel;

        return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 4,
          children: [
            if (widget.showVersion) boundedVersionLabel,
            if (updateButton != null) updateButton,
          ],
        );
      },
    );
  }
}
