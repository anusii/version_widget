/// Parse version entries out of a CHANGELOG.
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
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
///
/// Authors: Jess Moore

library;

import 'package:version_widget/src/utils/compare_versions.dart';

/// A single version entry read from a CHANGELOG.

class ChangelogEntry {
  /// Creates an entry pairing a [version] with its release [date].

  const ChangelogEntry({required this.version, required this.date});

  /// The version string, e.g. `1.0.10`.

  final String version;

  /// The release date as it appeared in the CHANGELOG, e.g. `20260512`.

  final String date;
}

/// Matches one `[version date]` entry, tolerating an author between the two.
///
/// Group 1 is the version, group 2 is the eight digit date. Both of the
/// orderings in use across our apps are accepted:
///
/// - `[1.0.10 20260512 tonypioneer]` — the documented convention.
/// - `[0.1.13 jesscmoore 20260908]` — author first, as podmail writes it.
///
/// The negative lookahead on the optional author group is what makes this
/// work. Without it the author group would happily consume the date in the
/// first form, leaving nothing for group 2 to match.
///
/// The closing `]` is deliberately not required, matching the behaviour of
/// earlier releases. Requiring it would be worse than it looks: `[^\]]`
/// matches newlines, so an unterminated entry could otherwise scan across
/// lines and swallow the entry below it.

final RegExp _entryPattern = RegExp(
  // Group 1: a dotted version, which must start with a digit.

  r'\[(\d+(?:\.\d+)*)'
  r'\s+'

  // An optional author token, matched but discarded. The lookahead stops it
  // consuming the date itself.

  r'(?:(?!\d{8}(?!\d))[^\s\]]+\s+)?'

  // Group 2: the date, rejected if it is part of a longer run of digits.

  r'(\d{8})(?!\d)',
);

/// Every parsable version entry in [content], in the order they appear.
///
/// Never throws. Malformed entries are skipped rather than guessed at, so
/// content with no recognisable entries yields an empty list — which the
/// caller should treat as a failed check, not as an up to date app.

List<ChangelogEntry> parseChangelogEntries(String content) => [
      for (final match in _entryPattern.allMatches(content))
        ChangelogEntry(version: match.group(1)!, date: match.group(2)!),
    ];

/// The latest version among [entries], or null when there are none.
///
/// The highest version wins, not the first one listed. Our changelogs are
/// written newest first, so the two usually agree — but taking the maximum
/// means a file that is out of order, or has had an entry appended at the
/// bottom, still reports the right answer. Ties go to the first occurrence.

String? latestVersionOf(List<ChangelogEntry> entries) {
  String? latest;

  for (final entry in entries) {
    if (latest == null || compareVersions(entry.version, latest) > 0) {
      latest = entry.version;
    }
  }

  return latest;
}

/// Whether [version] can be meaningfully compared against another.
///
/// Requires at least one digit. An app that does not know its own version
/// hands us an empty string — a misconfigured Info.plist will do it — and
/// comparing that against a real release would rank it below everything,
/// reporting a confident 'outdated' from no information at all.

bool isComparableVersion(String version) => version.contains(RegExp(r'\d'));

/// The date recorded against [version], or null when it is not listed.
///
/// An app running a version that predates the CHANGELOG, or a development
/// build ahead of it, will not be found — hence the null rather than a
/// fabricated fallback.

String? dateForVersion(List<ChangelogEntry> entries, String version) {
  for (final entry in entries) {
    if (entry.version == version) return entry.date;
  }
  return null;
}
