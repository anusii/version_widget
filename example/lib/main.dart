/// A demonstration of the VersionWidget app.
///
// Time-stamp: <Saturday 2026-05-09 18:20:00 +1000 Tony Chen>
///
/// Copyright (C) 2025-2026, Software Innovation Institute ANU
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
/// Authors: Kevin Wang, Graham Williams, Tony Chen

// Add the library directive as we have doc entries above. We publish the above
// meta doc lines in the docs.

library;

import 'package:flutter/material.dart';

import 'package:version_widget/version_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Version Widget Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Version Widget Demo'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: const SingleChildScrollView(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: <Widget>[
                  // Example 1: Up-to-date version (blue).
                  Card(
                    margin: EdgeInsets.all(8),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            'github.com/anusii/version_widget.git\n'
                            'Specify the current version.\n'
                            'The date is from the CHANGELOG.\n'
                            'Expect blue version and correct date.\n'
                            'Font size is default\n'
                            'Tap the string to see the CHANGELOG.',
                          ),
                          SizedBox(height: 8),
                          VersionWidget(
                            version: '1.0.5',
                            changelogUrl:
                                'https://raw.githubusercontent.com/anusii/version_widget/refs/heads/main/CHANGELOG.md',
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Example 2: Outdated version with the discover-and-download
                  // button enabled. The default Update label is used so all
                  // demo buttons read the same.
                  Card(
                    margin: EdgeInsets.all(8),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            'github.com/anusii/version_widget.git\n'
                            'Specify an old version.\n'
                            'The date is from the CHANGELOG.\n'
                            'Expect red version, correct date and an\n'
                            'inline Update button to the right.\n'
                            'Font size is 18.0\n'
                            'Tap the string to see the CHANGELOG.\n'
                            'Tap the Update button to launch the URL.',
                          ),
                          SizedBox(height: 8),
                          VersionWidget(
                            version: '1.0.2',
                            changelogUrl:
                                'https://raw.githubusercontent.com/anusii/version_widget/refs/heads/main/CHANGELOG.md',
                            fontSize: 18.0,
                            showUpdateButton: true,
                            downloadUrl:
                                'https://github.com/anusii/version_widget/releases/latest',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: <Widget>[
                  // Example 3: Outdated Rattle version with the
                  // discover-and-download button enabled. Uses the default
                  // Update label for consistency with Example 2.
                  Card(
                    margin: EdgeInsets.all(8),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            'github.com/gjwgit/rattle\n'
                            'Specifying an old version.\n'
                            'The date here is from the CHANGELOG.\n'
                            'Expect bold red version, correct date and\n'
                            'the Update button targeting the Rattle\n'
                            'releases page.\n'
                            'Font size is 14.0\n'
                            'Tap the string to see the CHANGELOG.',
                          ),
                          SizedBox(height: 8),
                          VersionWidget(
                            version: '6.5.15',
                            changelogUrl:
                                'https://raw.githubusercontent.com/gjwgit/rattle/refs/heads/dev/CHANGELOG.md',
                            showDate: true,
                            fontSize: 14.0,
                            showUpdateButton: true,
                            downloadUrl:
                                'https://github.com/gjwgit/rattle/releases/latest',
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Example 4: An out of date version number is tested with
                  // no date but with a username in the CHANGELOG.
                  Card(
                    margin: EdgeInsets.all(8),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            'github.com/gjwgit/rattle\n'
                            'Old version in CHANGELOG without date.\n'
                            'We should thus not see a date here.\n'
                            'Expect bold red version and no date.\n'
                            'Font size is 12.0\n'
                            'Tap the string to see the CHANGELOG.',
                          ),
                          SizedBox(height: 8),
                          VersionWidget(
                            version: '6.1.14',
                            changelogUrl:
                                'https://raw.githubusercontent.com/gjwgit/rattle/refs/heads/dev/CHANGELOG.md',
                            showDate: true,
                            fontSize: 12.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: <Widget>[
                  Card(
                    margin: EdgeInsets.all(8),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            'github.com/gjwgit/rattle\n'
                            'Future version not in the CHANGELOG.\n'
                            'We should thus not see a date here.\n'
                            'Expect blue version and no date.\n'
                            'Font size is 10.0\n'
                            'Tap the string to see the CHANGELOG.',
                          ),
                          SizedBox(height: 8),
                          VersionWidget(
                            version: '7.0.0',
                            changelogUrl:
                                'https://raw.githubusercontent.com/gjwgit/rattle/refs/heads/dev/CHANGELOG.md',
                            showDate: true,
                            fontSize: 10.0,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Example 5: An out of date version number is tested with
                  // no date but with a username in the CHANGELOG.
                  Card(
                    margin: EdgeInsets.all(8),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            'github.com/gjwgit/rattle\n'
                            'Old version not in the CHANGELOG.\n'
                            'We should thus not see a date here.\n'
                            'Expect bold red version and no date.\n'
                            'Font size is 8.0\n'
                            'Tap the string to see the CHANGELOG.',
                          ),
                          SizedBox(height: 8),
                          VersionWidget(
                            version: '5.0.0',
                            changelogUrl:
                                'https://raw.githubusercontent.com/gjwgit/rattle/refs/heads/dev/CHANGELOG.md',
                            showDate: true,
                            fontSize: 8.0,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Example 6: Demonstrates hiding the version label entirely
                  // while still surfacing the discover-and-download button
                  // when an outdated version is detected. Only the Update
                  // button should appear.
                  Card(
                    margin: EdgeInsets.all(8),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            'github.com/anusii/version_widget.git\n'
                            'showVersion=false, showUpdateButton=true.\n'
                            'Version label is hidden but the Update\n'
                            'button is still rendered when a newer\n'
                            'release is detected in the CHANGELOG.',
                          ),
                          SizedBox(height: 8),
                          VersionWidget(
                            version: '1.0.0',
                            changelogUrl:
                                'https://raw.githubusercontent.com/anusii/version_widget/refs/heads/main/CHANGELOG.md',
                            showVersion: false,
                            showUpdateButton: true,
                            downloadUrl:
                                'https://github.com/anusii/version_widget/releases/latest',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
