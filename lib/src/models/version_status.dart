/// The outcome of a version check.
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

import 'package:flutter/material.dart';

/// The outcome of checking the installed version against a CHANGELOG.
///
/// The distinction that matters is between [current] and [unknown]. Before
/// version 1.1.0 a failed or unparsable check was reported as though the
/// installed version were the latest, so an app whose CHANGELOG had moved,
/// gone private, or changed format claimed to be up to date indefinitely.

enum VersionStatus {
  /// The CHANGELOG request is still in flight.

  checking,

  /// No changelog URL was configured, so no check was attempted. This is a
  /// legitimate configuration, not a failure, and renders exactly as it did
  /// before the status model was introduced.

  unchecked,

  /// The installed version matches or exceeds the newest CHANGELOG entry.

  current,

  /// The CHANGELOG advertises a release newer than the installed version.

  outdated,

  /// The check could not be completed: the transport failed, the response
  /// was not usable, or the body held no parsable version entries. Nothing
  /// is known about whether a newer release exists.

  unknown,
}

/// How each [VersionStatus] presents itself in the version label.

extension VersionStatusDisplay on VersionStatus {
  /// The colour of the version label when the host supplies no text style.
  ///
  /// [unknownColour] is passed in rather than hard-coded so the host can
  /// choose a shade that stays legible against its own background.

  Color colourWith(Color unknownColour) {
    switch (this) {
      case VersionStatus.checking:
        return Colors.grey;
      case VersionStatus.unchecked:
      case VersionStatus.current:
        return Colors.blue;
      case VersionStatus.outdated:
        return Colors.red;
      case VersionStatus.unknown:
        return unknownColour;
    }
  }

  /// The weight of the version label when the host supplies no text style.
  ///
  /// Only [VersionStatus.outdated] is bold. An unknown status is an absence
  /// of information rather than an alarm, so it is not escalated to bold.

  FontWeight get weight =>
      this == VersionStatus.outdated ? FontWeight.bold : FontWeight.normal;

  /// Whether a release date may accompany the version for this status.
  ///
  /// A date is only meaningful once the CHANGELOG has actually been read.

  bool get showsDate =>
      this == VersionStatus.current || this == VersionStatus.outdated;

  /// Whether the discover-and-download button may be rendered.
  ///
  /// Only when a newer release is known to exist. Offering the button on an
  /// [VersionStatus.unknown] check would assert an update we cannot see.

  bool get allowsUpdateButton => this == VersionStatus.outdated;
}
