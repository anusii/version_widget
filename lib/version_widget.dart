/// Version widget for the app.
///
// Time-stamp: <Thursday 2025-05-01 15:20:44 +1000 Graham Williams>
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
// this program.  If not, see <https://www.gnu.org/licenses/>.
///
/// Authors: Kevin Wang.

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:version_widget/utils/compare_versions.dart';
import 'package:markdown_tooltip/markdown_tooltip.dart';

/// A widget that displays version information with optional changelog date and link.
///
/// This widget can be used to show the current version of an app, optionally
/// including the release date from a CHANGELOG file and providing a link to
/// view the full changelog.
///
/// The widget supports three modes of operation:
/// 1. Automatic mode: Fetches both version and date from a CHANGELOG.md file
/// 2. Semi-automatic mode: Uses provided version but fetches date from CHANGELOG
/// 3. Manual mode: Uses provided version and default date
///
/// Example usage:
/// ```dart
/// VersionWidget(
///   changelogUrl: 'https://github.com/yourusername/yourrepo/raw/main/CHANGELOG.md',
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
        '12': 'Dec'
      };

      return '$day ${months[month] ?? month} $year';
    } catch (e) {
      return dateStr;
    }
  }

  /// Fetches and parses the changelog file to extract version and date information.
  /// The method handles several scenarios:
  /// 1. No changelog URL provided: Uses default values
  /// 2. Changelog fetch successful: Extracts version and date
  /// 3. Changelog fetch failed: Falls back to default values

  Future<void> _fetchChangelog() async {
    if (widget.changelogUrl == null) {
      setState(() {
        _currentDate = widget.defaultDate ?? '20250101';
        _latestVersion = _currentVersion;
        _isLatest = true;
        _isChecking = false;
      });
      return;
    }

    try {
      final response = await http.get(Uri.parse(widget.changelogUrl!));
      final content = response.body;

      // Extract all version and date pairs from CHANGELOG.md
      final matches = RegExp(r'\[([\d.]+) (\d{8})').allMatches(content);

      if (matches.isNotEmpty) {
        // First match is the latest version
        final latestMatch = matches.first;
        _latestVersion = latestMatch.group(1)!;

        // Find the date for the current version
        String? currentVersionDate;
        for (final match in matches) {
          if (match.group(1) == _currentVersion) {
            currentVersionDate = match.group(2);
            break;
          }
        }

        setState(() {
          _currentDate = currentVersionDate ?? widget.defaultDate ?? '20250101';
          _isLatest = compareVersions(_currentVersion, _latestVersion) >= 0;
          _isChecking = false;
          _hasInternet = true;
        });
      } else {
        setState(() {
          _currentDate = widget.defaultDate ?? '20250101';
          _latestVersion = _currentVersion;
          _isLatest = true;
          _isChecking = false;
          _hasInternet = true;
        });
      }
    } catch (e) {
      debugPrint('Error fetching changelog: $e');
      setState(() {
        _currentDate = widget.defaultDate ?? '20250101';
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
        : widget.showDate && _hasInternet
            ? 'Version $_currentVersion - ${_formatDate(_currentDate)}'
            : 'Version $_currentVersion';

    final defaultLatestTooltip = '''

    that is the latest version available.

    ''';

    final defaultNotLatestTooltip = '''

    there is now a version **$_latestVersion** available. You should consider
    updating to the latest version.

    ''';

    final tooltipMessage = '''

    You are running app **Version $_currentVersion.**

    According to the app *CHANGELOG* ${_isLatest ? widget.isLatestTooltip ?? defaultLatestTooltip : widget.notLatestTooltip ?? defaultNotLatestTooltip}

    **Tap** on the **Version** string in the card to visit the *CHANGELOG* in
    your browser.

    ''';

    return MarkdownTooltip(
      message: tooltipMessage,
      child: GestureDetector(
        onTap: widget.changelogUrl == null
            ? null
            : () async {
                final Uri url = Uri.parse(widget.changelogUrl!);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                } else {
                  debugPrint('Could not launch ${widget.changelogUrl}');
                }
              },
        child: MouseRegion(
          cursor: widget.changelogUrl == null
              ? SystemMouseCursors.basic
              : SystemMouseCursors.click,
          child: Text(
            displayText,
            style: TextStyle(
              color: _isChecking
                  ? Colors.grey
                  : (_isLatest ? Colors.blue : Colors.red),
              fontSize: 16,
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
