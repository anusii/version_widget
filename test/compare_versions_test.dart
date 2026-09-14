/// Tests for the version comparator.

library;

import 'package:flutter_test/flutter_test.dart';

import 'package:version_widget/src/utils/compare_versions.dart';

void main() {
  group('compareVersions', () {
    test('reports equal versions as equal', () {
      expect(compareVersions('1.0.0', '1.0.0'), 0);
    });

    test('compares segments numerically, not lexically', () {
      // The trap: as strings, '1.0.10' sorts before '1.0.9'. This is
      // exactly the range podmail's versions live in.

      expect(compareVersions('1.0.10', '1.0.9'), greaterThan(0));
      expect(compareVersions('1.0.9', '1.0.10'), lessThan(0));
      expect(compareVersions('0.1.13', '0.1.9'), greaterThan(0));
    });

    test('treats a missing trailing segment as zero', () {
      expect(compareVersions('1.0', '1.0.0'), 0);
      expect(compareVersions('1.0', '1.0.1'), lessThan(0));
      expect(compareVersions('1.0.1', '1.0'), greaterThan(0));
    });

    test('orders by the most significant differing segment', () {
      expect(compareVersions('2.0.0', '1.9.9'), greaterThan(0));
      expect(compareVersions('1.2.0', '1.10.0'), lessThan(0));
    });

    test('is deliberately not semver aware', () {
      // Build metadata and pre-release suffixes parse as zero rather than
      // being interpreted. Pinned so a future change to make the
      // comparator semver aware is a deliberate one.

      expect(compareVersions('1.0.0+1', '1.0.0'), 0);
      expect(compareVersions('1.0.0-beta', '1.0.0'), 0);
    });

    test('handles empty and malformed input without throwing', () {
      expect(compareVersions('', '0'), 0);
      expect(compareVersions('1.02', '1.2'), 0);
      expect(compareVersions('abc', '0.0.0'), 0);
    });
  });
}
