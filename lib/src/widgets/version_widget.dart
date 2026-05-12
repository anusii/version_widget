/// Version widget for the app.
///
// Time-stamp: <Tuesday 2026-05-12 14:50:00 +1000 Tony Chen>
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
/// Authors: Kevin Wang, Tony Chen.

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;
import 'package:markdown_tooltip/markdown_tooltip.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:version_widget/src/utils/compare_versions.dart';

/// A widget that displays version information with optional changelog date and link.
///
/// This widget can be used to show the current version of an app, optionally
/// including the release date from a CHANGELOG file and providing a link to
/// view the full changelog.
///
/// The widget supports three modes of operation:
///
/// 1. Automatic mode: Fetches both version and date from a CHANGELOG.md file
/// 2. Semi-automatic mode: Uses provided version but fetches date from CHANGELOG
/// 3. Manual mode: Uses provided version and default date
///
/// Styling of the version string is offered in two modes:
///
/// 1. Automatic mode: when no [userTextStyle] is supplied, the version is
///    styled with colour denoting package status (blue: up to date, red:
///    newer version available, grey: version being checked).
/// 2. Custom mode: when a [userTextStyle] is supplied the host style is
///    used verbatim while the version is up to date or still being
///    checked. As soon as a newer release is detected the host style is
///    preserved for every other field (font family, size, letter
///    spacing, decoration, etc.) but `color` and `fontWeight` are
///    escalated to red and bold so the upgrade warning remains visible.
///    This is fully backward compatible: existing hosts keep their
///    chosen styling for the up-to-date case and only see the warning
///    palette appear when an update is genuinely available.
///
/// When a newer version is detected and [showUpdateButton] is enabled, an
/// inline action button is rendered to the right of the version text. Tapping
/// the button launches [downloadUrl] in the default external handler so the
/// user can fetch the latest installer or release page.
///
/// Example usage:
/// ```dart
/// VersionWidget(
///   version: '1.0.5',
///   changelogUrl: 'https://github.com/anusii/version_widget/raw/main/CHANGELOG.md',
///   showDate: true,
///   defaultDate: '20240101',
///   showUpdateButton: true,
///   downloadUrl: 'https://example.com/downloads/myapp-latest.exe',
/// )
/// ```
class VersionWidget extends StatefulWidget {
  /// The version string to display (e.g., '1.0.0').
  /// The version should follow semantic versioning (e.g., '0.0.9').

  final String version;

  /// The URL to the CHANGELOG.md file.
  /// If provided, the widget will attempt to extract the release date and version from it.
  /// The changelog should follow the format: [x.x.x YYYYMMDD] for version entries.

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

  /// The default date to show if the changelog cannot be fetched.
  /// Format should be 'YYYYMMDD'.
  /// Defaults to '20250101'.
  /// This is used as a fallback when the changelog is unavailable or invalid.

  final String? defaultDate;

  /// Custom tooltip message to show when the version is the latest.
  /// If not provided, uses a default message.

  final String? isLatestTooltip;

  /// Custom tooltip message to show when a newer version is available.
  /// If not provided, uses a default message.

  final String? notLatestTooltip;

  /// Allow the user to override the [fontSize] to suit the app.

  final double? fontSize;

  /// Allow the host to specify a custom [userTextStyle] that the version
  /// label should adopt. The provided style is used verbatim while the
  /// installed version is up to date or the changelog check is still in
  /// flight. When the changelog reports a newer release available the
  /// supplied style is preserved for every field except `color` and
  /// `fontWeight`, which are escalated to red and bold so the upgrade
  /// warning stays visible regardless of the host's theming choices.

  final TextStyle? userTextStyle;

  /// Whether to show the discover-and-download button when a newer version is
  /// detected.
  /// Defaults to false (hidden).
  /// The button is only rendered when all of the following are true:
  /// 1. [showUpdateButton] is true
  /// 2. A newer version has been detected from the CHANGELOG
  /// 3. [downloadUrl] is non-null and non-empty
  /// Tapping the button launches [downloadUrl] using the platform's default
  /// external handler (typically the system browser) so the user can fetch
  /// the latest release.

  final bool showUpdateButton;

  /// The URL to launch when the user taps the discover-and-download button.
  /// Typically points at an installer (.exe, .apk, .dmg) or a release page.
  /// Required for the update button to be rendered.

  final String? downloadUrl;

  /// Optional label shown next to the download icon on the update button.
  /// Defaults to 'Update' when null.

  final String? updateButtonLabel;

  /// Creates a new [VersionWidget].
  /// The [version] parameter is required and should be the current version of the app.
  /// All other parameters are optional.

  const VersionWidget({
    super.key,
    required this.version,
    this.changelogUrl,
    this.showVersion = true,
    this.showDate = true,
    this.defaultDate = '20260101',
    this.isLatestTooltip,
    this.notLatestTooltip,
    this.fontSize = 16.0,
    this.userTextStyle,
    this.showUpdateButton = false,
    this.downloadUrl,
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
  /// Indicates whether the current version is the latest version.
  /// Used to determine the colour of the version text (blue for latest, red for outdated).

  bool _isLatest = true;

  /// The latest version available from the changelog.
  /// Used to compare with the current version to determine if an update is available.

  String _latestVersion = '';

  /// The current release date in YYYYMMDD format.
  /// Either fetched from the changelog or using the default date.

  String _currentDate = '';

  /// The current version string (e.g., '0.0.9').
  /// Either provided through the widget or extracted from the changelog.

  String _currentVersion = '';

  bool _isChecking = true;
  bool _hasInternet = true;

  /// The full CHANGELOG content for display in the dialogue.

  String _changelogContent = '';

  @override
  void initState() {
    super.initState();
    _currentVersion = widget.version;

    // We still want to check the changelog whenever the changelog URL is
    // provided so that the update button can be surfaced even when the
    // version date is intentionally hidden by the host app.

    if (widget.showDate || widget.changelogUrl != null) {
      _fetchChangelog();
    } else {
      _isChecking = false;
    }
  }

  /// Converts GitHub blob URLs to raw content URLs.
  /// This is necessary for CORS compatibility in web environments.
  ///
  /// Converts:
  /// - https://github.com/gjwgit/geopod/blob/dev/CHANGELOG.md
  /// to:
  /// - https://raw.githubusercontent.com/gjwgit/geopod/dev/CHANGELOG.md

  String _convertToRawUrl(String url) {
    if (url.contains('github.com') && url.contains('/blob/')) {
      return url
          .replaceFirst('github.com', 'raw.githubusercontent.com')
          .replaceFirst('/blob/', '/');
    }
    return url;
  }

  String _formatDate(String dateStr) {
    try {
      final year = dateStr.substring(0, 4);
      final month = dateStr.substring(4, 6);
      String day = dateStr.substring(6, 8);

      // Remove leading zero for the day. (gjw 20250501)

      if (day.startsWith('0') && day.length > 1) day = day.substring(1);

      final months = {
        '01': 'Jan',
        '02': 'Feb',
        '03': 'Mar',
        '04': 'Apr',
        '05': 'May',
        '06': 'Jun',
        '07': 'Jul',
        '08': 'Aug',
        '09': 'Sep',
        '10': 'Oct',
        '11': 'Nov',
        '12': 'Dec',
      };

      return '$day ${months[month] ?? month} $year';
    } catch (e) {
      return dateStr;
    }
  }

  /// Displays the CHANGELOG content in a dialogue with markdown rendering.
  /// This method is called when the user taps on the version text.

  void _showChangelogDialog(BuildContext context) {
    if (_changelogContent.isEmpty) {
      // Show a message if CHANGELOG content is not available.

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Changelog'),
            content: const Text('Changelog content is not available.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 800,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Column(
              children: [
                // Title bar with close button.

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Changelog',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                        tooltip: 'Close',
                      ),
                    ],
                  ),
                ),

                // Markdown content.

                Expanded(
                  child: Markdown(
                    data: _changelogContent,
                    selectable: true,
                    onTapLink: (text, href, title) async {
                      if (href != null) {
                        final Uri url = Uri.parse(href);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        }
                      }
                    },
                  ),
                ),

                // Bottom action bar.

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (widget.changelogUrl != null)
                        TextButton.icon(
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('View on GitHub'),
                          onPressed: () async {
                            final Uri url = Uri.parse(widget.changelogUrl!);
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url);
                            }
                          },
                        ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Fetches and parses the changelog file to extract version and date information.
  /// The method handles several scenarios:
  /// 1. No changelog URL provided: Uses default values
  /// 2. Changelog fetch successful: Extracts version and date
  /// 3. Changelog fetch failed: Falls back to default values
  ///
  /// For web environments, this method automatically converts GitHub blob URLs
  /// to raw.githubusercontent.com URLs to avoid CORS issues.

  Future<void> _fetchChangelog() async {
    if (widget.changelogUrl == null) {
      if (mounted) {
        setState(() {
          _currentDate = '';
          _latestVersion = _currentVersion;
          _isLatest = true;
          _isChecking = false;
        });
      }
      return;
    }

    try {
      // Convert GitHub blob URLs to raw URLs for CORS compatibility.

      final url = _convertToRawUrl(widget.changelogUrl!);

      if (kIsWeb && url != widget.changelogUrl) {
        debugPrint(
            'Web platform detected: Converting URL from ${widget.changelogUrl} '
            'to $url');
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        throw Exception('Failed to load changelog: '
            'HTTP ${response.statusCode}');
      }

      final content = response.body;

      // Store the full CHANGELOG content for display in dialogue.

      _changelogContent = content;

      // Extract all version and date pairs from CHANGELOG.md.

      final matches = RegExp(r'\[([\d.]+) (\d{8})').allMatches(content);

      if (matches.isNotEmpty) {
        // First match is the latest version.

        final latestMatch = matches.first;
        _latestVersion = latestMatch.group(1)!;

        // Find the date for the current version.

        String? currentVersionDate;
        for (final match in matches) {
          if (match.group(1) == _currentVersion) {
            currentVersionDate = match.group(2);
            break;
          }
        }

        if (mounted) {
          setState(() {
            // Don't use default date if version not found.

            _currentDate = currentVersionDate ?? '';
            _isLatest = compareVersions(_currentVersion, _latestVersion) >= 0;
            _isChecking = false;
            _hasInternet = true;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _currentDate = '';
            _latestVersion = _currentVersion;
            _isLatest = true;
            _isChecking = false;
            _hasInternet = true;
          });
        }
      }
    } catch (e) {
      if (kIsWeb) {
        debugPrint('Error fetching changelog on web platform: $e');
        debugPrint('Make sure the CHANGELOG URL uses '
            'raw.githubusercontent.com for GitHub files');
        debugPrint('Original URL: ${widget.changelogUrl}');
        debugPrint('Converted URL: ${_convertToRawUrl(widget.changelogUrl!)}');
      } else {
        debugPrint('Error fetching changelog: $e');
      }
      if (mounted) {
        setState(() {
          _currentDate = '';
          _latestVersion = _currentVersion;
          _isLatest = true;
          _isChecking = false;
          _hasInternet = false;
        });
      }
    }
  }

  /// Launches the configured [VersionWidget.downloadUrl] in the default
  /// external handler so the user can fetch the new release.

  Future<void> _launchDownload() async {
    final downloadUrl = widget.downloadUrl;
    if (downloadUrl == null || downloadUrl.isEmpty) return;

    final uri = Uri.parse(downloadUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Unable to launch download URL: $downloadUrl');
    }
  }

  /// Resolves the [TextStyle] applied to the version label.
  ///
  /// 1. When [VersionWidget.userTextStyle] is null, the legacy automatic
  ///    palette is used: grey while still checking, blue when the
  ///    installed version matches the CHANGELOG, and red plus bold when
  ///    a newer release has been detected.
  /// 2. When [VersionWidget.userTextStyle] is provided and the installed
  ///    version is up to date (or the check has not yet completed) the
  ///    host-supplied style is used verbatim, so the version label
  ///    integrates with the surrounding theme exactly as before.
  /// 3. When [VersionWidget.userTextStyle] is provided and a newer
  ///    release has been detected, the host-supplied style is preserved
  ///    for every field except `color` and `fontWeight`, which are
  ///    escalated to red and bold respectively. This guarantees that the
  ///    upgrade warning remains visible even when a host has supplied a
  ///    custom text style. Hosts that need to opt out of the warning
  ///    colours should not enable changelog-driven version checking.

  TextStyle _resolveDisplayStyle() {
    final autoColour = _isChecking
        ? Colors.grey
        : (_isLatest ? Colors.blue : Colors.red);
    final autoWeight = (_isChecking || _isLatest)
        ? FontWeight.normal
        : FontWeight.bold;

    final userStyle = widget.userTextStyle;
    if (userStyle == null) {
      return TextStyle(
        color: autoColour,
        fontSize: widget.fontSize,
        fontWeight: autoWeight,
      );
    }

    final isOutdated = !_isChecking && !_isLatest;
    if (isOutdated) {
      // Outdated: escalate to the warning palette while preserving every
      // other style field provided by the host (font family, size,
      // letter spacing, decoration, etc.).

      return userStyle.copyWith(
        color: Colors.red,
        fontWeight: FontWeight.bold,
      );
    }

    // Up to date or still checking: hand back the host's style verbatim
    // for full visual parity with the previous behaviour.

    return userStyle;
  }

  /// Builds the inline discover-and-download action button surfaced when a
  /// newer release is detected. Returns null when the button should not be
  /// rendered for the current state.

  Widget? _buildUpdateButton(BuildContext context) {
    final downloadUrl = widget.downloadUrl;
    if (!widget.showUpdateButton) return null;
    if (_isChecking) return null;
    if (_isLatest) return null;
    if (downloadUrl == null || downloadUrl.isEmpty) return null;

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
            onTap: _launchDownload,
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
    final displayText = _isChecking
        ? 'Version $_currentVersion'
        : widget.showDate && _hasInternet && _currentDate.isNotEmpty
            ? 'Version $_currentVersion - ${_formatDate(_currentDate)}'
            : 'Version $_currentVersion';

    const defaultLatestTooltip = 'this is the latest version available.';

    final defaultNotLatestTooltip = 'there is a new version available '
        '$_latestVersion. You should consider '
        'updating to the latest version.';

    final tooltipMessage = '''

    **Version $_currentVersion**

    According to the CHANGELOG from the app
    repository ${_isLatest ? widget.isLatestTooltip ?? defaultLatestTooltip : widget.notLatestTooltip ?? defaultNotLatestTooltip} **Tap** on the
    **Version** string to view the app's CHANGELOG.

    ''';

    final versionLabel = GestureDetector(
      onTap: widget.changelogUrl == null
          ? null
          : () => _showChangelogDialog(context),
      child: MouseRegion(
        cursor: widget.changelogUrl == null
            ? SystemMouseCursors.basic
            : SystemMouseCursors.click,
        child: MarkdownTooltip(
          message: tooltipMessage,
          child: Text(
            displayText,
            style: _resolveDisplayStyle(),
          ),
        ),
      ),
    );

    final updateButton = _buildUpdateButton(context);

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
