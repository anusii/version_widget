/// Version widget for the app.
///
// Time-stamp: <Sunday 2025-09-28 05:48:17 +1000 Graham Williams>
///
/// Copyright (C) 2024-2025, Software Innovation Institute, ANU.
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
/// Authors: Kevin Wang.

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
/// 1. Automatic mode: version styled with colour denoting package statu
///    (blue: up to date, red: newer version availbale, grey: version
///     being checked).
/// 2. Manual mode: user specified TextStyle().
///
/// Example usage:
/// ```dart
/// VersionWidget(
///   changelogUrl: 'https://github.com/anusii/version_widget/raw/main/CHANGELOG.md',
///   showDate: true,
///   defaultDate: '20240101',
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

  /// Allow the user to specify the full [userTextStyle] to suit the app.

  final TextStyle? userTextStyle;

  /// Creates a new [VersionWidget].
  /// The [version] parameter is required and should be the current version of the app.
  /// All other parameters are optional.

  const VersionWidget({
    super.key,
    required this.version,
    this.changelogUrl,
    this.showDate = true,
    this.defaultDate = '20260101',
    this.isLatestTooltip,
    this.notLatestTooltip,
    this.fontSize = 16.0,
    this.userTextStyle,
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
  /// Used to determine the color of the version text (blue for latest, red for outdated).

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
    if (widget.showDate) {
      _fetchChangelog();
    } else {
      _isChecking = false;
    }
  }

  /// Converts GitHub blob URLs to raw content URLs.
  /// This is necessary for CORS compatibility in web environments.
  ///
  /// Converts:
  /// - https://github.com/user/repo/blob/branch/file.md
  /// to:
  /// - https://raw.githubusercontent.com/user/repo/branch/file.md

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
      setState(() {
        _currentDate = '';
        _latestVersion = _currentVersion;
        _isLatest = true;
        _isChecking = false;
      });
      return;
    }

    try {
      // Convert GitHub blob URLs to raw URLs for CORS compatibility.

      final url = _convertToRawUrl(widget.changelogUrl!);

      if (kIsWeb && url != widget.changelogUrl) {
        debugPrint(
            'Web platform detected: Converting URL from ${widget.changelogUrl} to $url');
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to load changelog: HTTP ${response.statusCode}');
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

        setState(() {
          // Don't use default date if version not found.

          _currentDate = currentVersionDate ?? '';
          _isLatest = compareVersions(_currentVersion, _latestVersion) >= 0;
          _isChecking = false;
          _hasInternet = true;
        });
      } else {
        setState(() {
          _currentDate = '';
          _latestVersion = _currentVersion;
          _isLatest = true;
          _isChecking = false;
          _hasInternet = true;
        });
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
      setState(() {
        _currentDate = '';
        _latestVersion = _currentVersion;
        _isLatest = true;
        _isChecking = false;
        _hasInternet = false;
      });
    }
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

    **Version:** $_currentVersion. According to the CHANGELOG from the app
    repository ${_isLatest ? widget.isLatestTooltip ?? defaultLatestTooltip : widget.notLatestTooltip ?? defaultNotLatestTooltip} **Tap** on the
    **Version** string to view the app's CHANGELOG.

    ''';

    return GestureDetector(
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
            style: (widget.userTextStyle != null)
                ? widget.userTextStyle
                : TextStyle(
                    color: _isChecking
                        ? Colors.grey
                        : (_isLatest ? Colors.blue : Colors.red),
                    fontSize: widget.fontSize,
                    fontWeight: _isChecking
                        ? FontWeight.normal
                        : (_isLatest ? FontWeight.normal : FontWeight.bold),
                  ),
          ),
        ),
      ),
    );
  }
}
