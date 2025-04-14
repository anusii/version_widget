/// Version widget for the app.
///
// Time-stamp: <Sunday 2025-03-09 11:50:04 +1100 Graham Williams>
///
/// Copyright (C) 2024-2025, Software Innovation Institute, ANU.
///
/// Licensed under the GNU General Public License, Version 3 (the "License").
///
/// License: https://www.gnu.org/licenses/gpl-3.0.en.html.
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
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
  /// If not provided, will be extracted from the changelog.
  /// The version should follow semantic versioning (e.g., '0.0.9').

  final String? version;

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

  /// Creates a new [VersionWidget].
  /// All parameters are optional, but at least one of [version] or [changelogUrl]
  /// should be provided for meaningful display.

  const VersionWidget({
    super.key,
    this.version,
    this.changelogUrl,
    this.showDate = true,
    this.defaultDate = '20250101',
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

  /// Controls the visibility of the tooltip.
  /// Set to true when the user taps on the version text.
  bool _showTooltip = false;

  @override
  void initState() {
    super.initState();
    // Fetch changelog if we need the date or if no version was provided.
    if (widget.showDate || widget.version == null) {
      _fetchChangelog();
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
        _currentVersion = widget.version ?? '0.0.0';
        _latestVersion = _currentVersion;
        _isLatest = true;
      });
      return;
    }

    try {
      final response = await http.get(Uri.parse(widget.changelogUrl!));
      final content = response.body;

      // Extract version and date from CHANGELOG.md - first entry in [x.x.x YYYYMMDD] format.
      // Example: [0.0.9 20250218].
      final match = RegExp(r'\[([\d.]+) (\d{8})').firstMatch(content);
      if (match != null) {
        _latestVersion = match.group(1)!;
        setState(() {
          _currentVersion = widget.version ?? match.group(1)!;
          _currentDate = match.group(2)!;
          _isLatest = _currentVersion == _latestVersion;
        });
      } else {
        setState(() {
          _currentVersion = widget.version ?? '0.0.0';
          _currentDate = widget.defaultDate ?? '20250101';
          _latestVersion = _currentVersion;
          _isLatest = true;
        });
      }
    } catch (e) {
      debugPrint('Error fetching changelog: $e');
      setState(() {
        _currentVersion = widget.version ?? '0.0.0';
        _currentDate = widget.defaultDate ?? '20250101';
        _latestVersion = _currentVersion;
        _isLatest = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Construct the display text based on whether date should be shown.
    final displayText = widget.showDate
        ? 'Version $_currentVersion - $_currentDate'
        : 'Version $_currentVersion';

    // Add available version information if current version is not latest
    final tooltipText = _isLatest
        ? 'This app is regularly updated to bring you the best experience. The latest version is always available from the website. Tap on the Version text here to visit the CHANGELOG in your browser and see a list of all changes.'
        : 'A newer version ($_latestVersion) is available! Visit the website for update instructions.';

    return Stack(
      children: [
        // Main version text with click handling.
        GestureDetector(
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
          // Show tooltip on tap down.
          onTapDown: (_) => setState(() => _showTooltip = true),
          // Hide tooltip on tap up.
          onTapUp: (_) => setState(() => _showTooltip = false),
          // Hide tooltip if tap is cancelled.
          onTapCancel: () => setState(() => _showTooltip = false),
          child: MouseRegion(
            // Show pointer cursor if changelog URL is available.
            cursor: widget.changelogUrl == null
                ? SystemMouseCursors.basic
                : SystemMouseCursors.click,
            child: Text(
              displayText,
              style: TextStyle(
                color: _isLatest ? Colors.blue : Colors.red,
                fontSize: 16,
                fontWeight: _isLatest ? FontWeight.normal : FontWeight.bold,
              ),
            ),
          ),
        ),
        // Custom tooltip that appears above the version text.
        if (_showTooltip)
          Positioned(
            top: -60,
            left: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(4),
              ),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  children: [
                    const TextSpan(
                      text: 'Version: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: tooltipText,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
