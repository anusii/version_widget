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
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Version Widget Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Basic Usage:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const VersionWidget(
              version: '1.0.0',
            ),
            const SizedBox(height: 40),
            const Text(
              'With Changelog:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            VersionWidget(
              version: '1.0.0',
              changelogUrl:
                  'https://raw.githubusercontent.com/yourusername/yourrepo/main/CHANGELOG.md',
              showDate: true,
              defaultDate: '20240101',
            ),
          ],
        ),
      ),
    );
  }
}
