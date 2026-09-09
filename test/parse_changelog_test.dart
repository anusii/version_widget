/// Tests for CHANGELOG parsing.

library;

import 'package:flutter_test/flutter_test.dart';

import 'package:version_widget/src/utils/parse_changelog.dart';

import 'fixtures/changelogs.dart';

void main() {
  group('parseChangelogEntries', () {
    test('reads the documented `[version date author]` order', () {
      final entries = parseChangelogEntries(canonicalChangelog);

      expect(entries.length, 3);
      expect(entries.first.version, '1.0.10');
      expect(entries.first.date, '20260512');
      expect(entries.last.version, '1.0.8');
    });

    test('reads the `[version author date]` order podmail writes', () {
      // The regression. Before 1.1.0 this yielded zero entries, so podmail
      // reported itself up to date on every launch for 13 releases.

      final entries = parseChangelogEntries(authorFirstChangelog);

      expect(entries.length, 3);
      expect(entries.first.version, '0.1.13');
      expect(entries.first.date, '20260908');
      expect(entries[1].version, '0.1.12');
      expect(entries[1].date, '20260907');
    });

    test('reads both orders from the one file', () {
      final entries = parseChangelogEntries(mixedChangelog);

      expect(
        entries.map((e) => e.version).toList(),
        ['2.0.1', '2.0.0', '1.9.9'],
      );
      expect(
        entries.map((e) => e.date).toList(),
        ['20260601', '20260530', '20260501'],
      );
    });

    test('skips entries it cannot read rather than guessing', () {
      expect(parseChangelogEntries(unparsableChangelog), isEmpty);
    });

    test('skips each malformed form individually', () {
      expect(parseChangelogEntries('[1.0.0]'), isEmpty);
      expect(parseChangelogEntries('[1.0.0 jess]'), isEmpty);
      expect(parseChangelogEntries('[abc 20250101]'), isEmpty);
      expect(parseChangelogEntries('[1.0.0 2026051]'), isEmpty);

      // A nine digit run is rejected outright rather than silently
      // truncated to a plausible looking eight digit date.

      expect(parseChangelogEntries('[1.0.0 202605123]'), isEmpty);
    });

    test('accepts an unterminated entry, as earlier releases did', () {
      final entries = parseChangelogEntries('+ Something [1.0.0 20250101');

      expect(entries.length, 1);
      expect(entries.first.version, '1.0.0');
    });

    test('does not run past a closing bracket into the next entry', () {
      final entries = parseChangelogEntries('[1.0.0 nodate]\n[2.0.0 20260101]');

      expect(entries.length, 1);
      expect(entries.first.version, '2.0.0');
    });

    test('finds entries embedded in rendered HTML', () {
      final entries = parseChangelogEntries(htmlChangelog);

      expect(entries.length, 2);
      expect(entries.first.version, '0.1.11');
    });

    test('returns nothing for empty or blank content', () {
      expect(parseChangelogEntries(''), isEmpty);
      expect(parseChangelogEntries('   \n\n  '), isEmpty);
      expect(parseChangelogEntries('# A changelog with no entries'), isEmpty);
    });
  });

  group('latestVersionOf', () {
    test('returns null when there are no entries', () {
      expect(latestVersionOf([]), isNull);
    });

    test('returns the highest version, not the first listed', () {
      // A changelog written out of order, or with an entry appended at the
      // bottom, still reports the right answer.

      final entries = parseChangelogEntries(
        '[1.0.2 20260101 gjw]\n[1.0.9 20260301 gjw]\n[1.0.5 20260201 gjw]',
      );

      expect(latestVersionOf(entries), '1.0.9');
    });

    test('compares numerically rather than lexically', () {
      final entries = parseChangelogEntries(
        '[1.0.9 20260101 gjw]\n[1.0.10 20260301 gjw]',
      );

      expect(latestVersionOf(entries), '1.0.10');
    });

    test('resolves a tie to the first occurrence', () {
      final entries = parseChangelogEntries(
        '[1.0.0 20260101 gjw]\n[1.0.0 20250101 gjw]',
      );

      expect(latestVersionOf(entries), '1.0.0');
    });

    test('returns the newest entry of a newest first changelog', () {
      expect(
        latestVersionOf(parseChangelogEntries(canonicalChangelog)),
        '1.0.10',
      );
      expect(
        latestVersionOf(parseChangelogEntries(authorFirstChangelog)),
        '0.1.13',
      );
    });
  });

  group('isComparableVersion', () {
    test('accepts anything carrying a digit', () {
      expect(isComparableVersion('0.1.14'), isTrue);
      expect(isComparableVersion('1'), isTrue);
      expect(isComparableVersion('2.0.0-beta'), isTrue);
    });

    test('rejects a version the app could not supply', () {
      // An empty string is what package_info_plus returns when the build
      // carries no CFBundleShortVersionString. Comparing it would rank the
      // app below every release.

      expect(isComparableVersion(''), isFalse);
      expect(isComparableVersion('   '), isFalse);
      expect(isComparableVersion('unknown'), isFalse);
    });
  });

  group('dateForVersion', () {
    final entries = parseChangelogEntries(canonicalChangelog);

    test('finds the date recorded against a listed version', () {
      expect(dateForVersion(entries, '1.0.9'), '20260510');
    });

    test('returns null for a version the changelog does not list', () {
      // A development build ahead of the changelog, or one older than it.

      expect(dateForVersion(entries, '9.9.9'), isNull);
      expect(dateForVersion(entries, '1.0.0'), isNull);
    });

    test('takes the first date when a version appears twice', () {
      final duplicated = parseChangelogEntries(
        '[1.0.0 20260101 gjw]\n[1.0.0 20250101 gjw]',
      );

      expect(dateForVersion(duplicated, '1.0.0'), '20260101');
    });
  });
}
