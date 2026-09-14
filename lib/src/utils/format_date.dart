/// Format CHANGELOG dates for display.
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
/// Authors: Kevin Wang, Graham Williams, Jess Moore

library;

const Map<String, String> _months = {
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

/// Renders a `YYYYMMDD` CHANGELOG date as `D Mmm YYYY`.
///
/// Returns [dateStr] unchanged if it is not in the expected form, so a
/// surprising date is shown as written rather than swallowed.

String formatChangelogDate(String dateStr) {
  try {
    final year = dateStr.substring(0, 4);
    final month = dateStr.substring(4, 6);
    String day = dateStr.substring(6, 8);

    // Remove leading zero for the day. (gjw 20250501)

    if (day.startsWith('0') && day.length > 1) day = day.substring(1);

    return '$day ${_months[month] ?? month} $year';
  } catch (e) {
    return dateStr;
  }
}
