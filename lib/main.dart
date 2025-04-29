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
                    Text('HeadthPod Up-to-date Version (Blue)'),
                    SizedBox(height: 8),
                    VersionWidget(
                      version: '0.1.9',
                      changelogUrl:
                          'https://github.com/anusii/healthpod/blob/dev/CHANGELOG.md',
                      showDate: true,
                      defaultDate: '20250101',
                    ),
                  ],
                ),
              ),
            ),

            Card(
              margin: EdgeInsets.all(8),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('HeadthPod Outdated Version (Red)'),
                    SizedBox(height: 8),
                    VersionWidget(
                      version: '0.1.8',
                      changelogUrl:
                          'https://github.com/anusii/healthpod/blob/dev/CHANGELOG.md',
                      showDate: true,
                      defaultDate: '20250101',
                    ),
                  ],
                ),
              ),
            ),

            // RattleNG.

            Card(
              margin: EdgeInsets.all(8),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('RattleNG Outdated Version (Red)'),
                    SizedBox(height: 8),
                    VersionWidget(
                      version: '6.4.70',
                      changelogUrl:
                          'https://github.com/gjwgit/rattleng/blob/dev/CHANGELOG.md',
                      showDate: true,
                      defaultDate: '20250417',
                    ),
                  ],
                ),
              ),
            ),

            Card(
              margin: EdgeInsets.all(8),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('RattleNG Up-to-date Version (Blue)'),
                    SizedBox(height: 8),
                    VersionWidget(
                      version: '6.4.72',
                      changelogUrl:
                          'https://github.com/gjwgit/rattleng/blob/dev/CHANGELOG.md',
                      showDate: true,
                      defaultDate: '20250417',
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
