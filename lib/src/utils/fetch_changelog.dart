/// Fetch the CHANGELOG that a version check reads.
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

import 'package:http/http.dart' as http;

/// Supplies the raw CHANGELOG text for [url].
///
/// Supply one to read the CHANGELOG from somewhere the built-in
/// unauthenticated GET cannot reach — an authenticated backend, or an asset
/// bundled with the build. The [url] handed over is the configured changelog
/// URL after GitHub blob to raw normalisation, so a loader still gets that
/// rewrite for free and may ignore the argument entirely.
///
/// Throw, or return an empty string, to report failure. The widget then
/// shows that the version could not be checked rather than claiming the app
/// is up to date.
///
/// ```dart
/// // Bundled with the build. Cannot ever detect an update, since its
/// // CHANGELOG is frozen at build time, but it does populate the dialogue.
/// changelogLoader: (_) => rootBundle.loadString('assets/CHANGELOG.md'),
///
/// // Authenticated, using a token the app already holds from the signed in
/// // session. Never a token compiled into the binary: a shipped app is
/// // readable by anyone who has it, web bundles most of all.
/// changelogLoader: (url) async {
///   final response = await http.get(
///     Uri.parse(url),
///     headers: {'Authorization': 'Bearer ${session.accessToken}'},
///   );
///   return response.body;
/// },
/// ```

typedef ChangelogLoader = Future<String> Function(String url);

/// Converts GitHub blob URLs to raw content URLs.
///
/// Necessary for CORS compatibility in web environments. Converts
/// `https://github.com/gjwgit/geopod/blob/dev/CHANGELOG.md` to
/// `https://raw.githubusercontent.com/gjwgit/geopod/dev/CHANGELOG.md`.

String convertToRawUrl(String url) {
  if (url.contains('github.com') && url.contains('/blob/')) {
    return url
        .replaceFirst('github.com', 'raw.githubusercontent.com')
        .replaceFirst('/blob/', '/');
  }
  return url;
}

/// The default loader: a plain, unauthenticated GET.
///
/// Throws on any non-200 response so the caller reports the check as failed
/// rather than parsing an error page for version strings.

Future<String> fetchChangelogOverHttp(String url) async {
  final response = await http.get(Uri.parse(url));

  if (response.statusCode != 200) {
    throw Exception('Failed to load changelog: HTTP ${response.statusCode}');
  }

  return response.body;
}
