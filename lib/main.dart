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
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Version Widget Examples:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // Example 1: Up-to-date version (blue)
            Card(
              margin: EdgeInsets.all(8),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('Up-to-date Version (Blue)'),
                    SizedBox(height: 8),
                    VersionWidget(
                      version: '0.0.7',
                      changelogUrl:
                          'https://github.com/anusii/healthpod/blob/dev/CHANGELOG.md',
                      showDate: true,
                      defaultDate: '20250429',
                    ),
                  ],
                ),
              ),
            ),
            // Example 2: Outdated version (red)
            Card(
              margin: EdgeInsets.all(8),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('Outdated Version (Red)'),
                    SizedBox(height: 8),
                    VersionWidget(
                      version: '0.0.5',
                      changelogUrl:
                          'https://github.com/gjwgit/rattleng/blob/dev/CHANGELOG.md',
                      showDate: true,
                      defaultDate: '20250417',
                    ),
                  ],
                ),
              ),
            ),
            // Example 3: Checking state (grey)
            Card(
              margin: EdgeInsets.all(8),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('Checking State (Grey)'),
                    SizedBox(height: 8),
                    VersionWidget(
                      version: '0.0.7',
                      changelogUrl:
                          'https://raw.githubusercontent.com/togaware/version_widget/main/CHANGELOG.md',
                      showDate: true,
                      defaultDate: '20250429',
                    ),
                  ],
                ),
              ),
            ),
            // Example 4: No internet connection
            Card(
              margin: EdgeInsets.all(8),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('No Internet Connection'),
                    SizedBox(height: 8),
                    VersionWidget(
                      version: '0.0.7',
                      changelogUrl:
                          'https://raw.githubusercontent.com/nonexistent/repo/main/CHANGELOG.md',
                      showDate: true,
                      defaultDate: '20250429',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
