/// Compare version strings
///
// Time-stamp: <Saturday 2025-09-27 15:42:40 +1000 Graham Williams>
///
/// Copyright (C) 2025, Software Innovation Institute ANU
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
/// Authors: AUTHORS

// Add the library directive as we have doc entries above. We publish the above
// meta doc lines in the docs.

library;

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
