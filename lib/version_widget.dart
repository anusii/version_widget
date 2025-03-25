import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

/// A widget that displays version information with optional changelog date and link.
///
/// This widget can be used to show the current version of an app, optionally
/// including the release date from a CHANGELOG file and providing a link to
/// view the full changelog.
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
  final String? version;

  /// The URL to the CHANGELOG.md file.
  /// If provided, the widget will attempt to extract the release date and version from it.
  final String? changelogUrl;

  /// Whether to show the release date alongside the version.
  /// Defaults to true.
  final bool showDate;

  /// The default date to show if the changelog cannot be fetched.
  /// Format should be 'YYYYMMDD'.
  /// Defaults to '20250101'.
  final String? defaultDate;

  /// Creates a new [VersionWidget].
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

class _VersionWidgetState extends State<VersionWidget> {
  bool _isLatest = true;
  String _currentDate = '';
  String _currentVersion = '';
  bool _showTooltip = false;

  @override
  void initState() {
    super.initState();
    if (widget.showDate || widget.version == null) {
      _fetchChangelog();
    }
  }

  Future<void> _fetchChangelog() async {
    if (widget.changelogUrl == null) {
      setState(() {
        _currentDate = widget.defaultDate ?? '20250101';
        _currentVersion = widget.version ?? '0.0.0';
      });
      return;
    }

    try {
      final response = await http.get(Uri.parse(widget.changelogUrl!));
      final content = response.body;

      // Extract version and date from CHANGELOG.md - first entry in [x.x.x YYYYMMDD] format
      final match = RegExp(r'\[([\d.]+) (\d{8})').firstMatch(content);
      if (match != null) {
        setState(() {
          _currentVersion = match.group(1)!;
          _currentDate = match.group(2)!;
        });
      } else {
        setState(() {
          _currentVersion = widget.version ?? '0.0.0';
          _currentDate = widget.defaultDate ?? '20250101';
        });
      }
    } catch (e) {
      debugPrint('Error fetching changelog: $e');
      setState(() {
        _currentVersion = widget.version ?? '0.0.0';
        _currentDate = widget.defaultDate ?? '20250101';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayText = widget.showDate
        ? 'Version $_currentVersion - $_currentDate'
        : 'Version $_currentVersion';

    return Stack(
      children: [
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
          onTapDown: (_) => setState(() => _showTooltip = true),
          onTapUp: (_) => setState(() => _showTooltip = false),
          onTapCancel: () => setState(() => _showTooltip = false),
          child: MouseRegion(
            cursor: widget.changelogUrl == null
                ? SystemMouseCursors.basic
                : SystemMouseCursors.click,
            child: Text(
              displayText,
              style: TextStyle(
                color: _isLatest ? Colors.blue : Colors.red,
                fontSize: 16,
              ),
            ),
          ),
        ),
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
                      text: _isLatest
                          ? 'This app is regularly updated to bring you the best experience. The latest version is always available from the website. Tap on the Version text here to visit the CHANGELOG in your browser and see a list of all changes.'
                          : 'A newer version is available! Visit the website for update instructions.',
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
