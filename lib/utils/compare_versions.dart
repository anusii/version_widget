/// Compare two version strings.
///
/// Returns:
/// - A negative number if version1 is older than version2
/// - Zero if version1 is equal to version2
/// - A positive number if version1 is newer than version2
///
/// Example:
/// ```dart
/// compareVersions('1.2.3', '1.2.4') // returns -1
/// compareVersions('1.2.3', '1.2.3') // returns 0
/// compareVersions('1.2.4', '1.2.3') // returns 1
/// ```
int compareVersions(String version1, String version2) {
  final parts1 = version1.split('.');
  final parts2 = version2.split('.');

  for (var i = 0; i < parts1.length || i < parts2.length; i++) {
    final part1 = i < parts1.length ? int.tryParse(parts1[i]) ?? 0 : 0;
    final part2 = i < parts2.length ? int.tryParse(parts2[i]) ?? 0 : 0;

    if (part1 != part2) {
      return part1 - part2;
    }
  }

  return 0;
}
