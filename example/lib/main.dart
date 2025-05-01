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
    //

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: const Row(
        children: [
          Column(
            children: <Widget>[
              // Example 1: Up-to-date version (blue)
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
                        'Tap the string to see the CHANGELOG.',
                      ),
                      SizedBox(height: 8),
                      VersionWidget(
                        version: '0.0.8',
                        changelogUrl:
                            'https://github.com/anusii/version_widget/blob/main/CHANGELOG.md',
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
                      Text(
                        'github.com/anusii/version_widget.git\n'
                        'Specify an old version.\n'
                        'The date is from the CHANGELOG.\n'
                        'Expect red version and correct date.\n'
                        'Tap the string to see the CHANGELOG.',
                      ),
                      SizedBox(height: 8),
                      VersionWidget(
                        version: '0.0.1',
                        changelogUrl:
                            'https://github.com/anusii/version_widget/blob/main/CHANGELOG.md',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Column(
            children: <Widget>[
              Card(
                margin: EdgeInsets.all(8),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'github.com/gjwgit/rattleng\n'
                        'Specifying an old version.\n'
                        'The date here is from the CHANGELOG.\n'
                        'Expect bold red version and correct date.\n'
                        'Tap the string to see the CHANGELOG.',
                      ),
                      SizedBox(height: 8),
                      VersionWidget(
                        version: '6.2.1',
                        changelogUrl:
                            'https://github.com/gjwgit/rattleng/blob/dev/CHANGELOG.md',
                        showDate: true,
                      ),
                    ],
                  ),
                ),
              ),

              // An out of date version number is tested with no date but with a
              // username in the CHANGELOG.
              Card(
                margin: EdgeInsets.all(8),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'github.com/gjwgit/rattleng\n'
                        'Old version in CHANGELOG without date.\n'
                        'We should thus not see a date here.\n'
                        'Expect bold red version and no date.\n'
                        'Tap the string to see the CHANGELOG.',
                      ),
                      SizedBox(height: 8),
                      VersionWidget(
                        version: '6.1.14',
                        changelogUrl:
                            'https://github.com/gjwgit/rattleng/blob/dev/CHANGELOG.md',
                        showDate: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Column(
            children: <Widget>[
              Card(
                margin: EdgeInsets.all(8),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'github.com/gjwgit/rattleng\n'
                        'Future version not in the CHANGELOG.\n'
                        'We should thus not see a date here.\n'
                        'Expect blue version and no date.\n'
                        'Tap the string to see the CHANGELOG.',
                      ),
                      SizedBox(height: 8),
                      VersionWidget(
                        version: '7.0.0',
                        changelogUrl:
                            'https://github.com/gjwgit/rattleng/blob/dev/CHANGELOG.md',
                        showDate: true,
                      ),
                    ],
                  ),
                ),
              ),

              // An out of date version number is tested with no date but with a
              // username in the CHANGELOG.
              Card(
                margin: EdgeInsets.all(8),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'RattleNG @ github.com/gjwgit/rattleng\n'
                        'Old version not in the CHANGELOG.\n'
                        'We should thus not see a date here.\n'
                        'Expect bold red version and no date.\n'
                        'Tap the string to see the CHANGELOG.',
                      ),
                      SizedBox(height: 8),
                      VersionWidget(
                        version: '5.0.0',
                        changelogUrl:
                            'https://github.com/gjwgit/rattleng/blob/dev/CHANGELOG.md',
                        showDate: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
