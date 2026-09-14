/// Tests for how VersionWidget reports each check outcome.
///
/// Every case injects a changelogLoader, so nothing here touches the
/// network and each outcome — including the failures — is reachable.

library;

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:version_widget/version_widget.dart';

import 'fixtures/changelogs.dart';

const String _url = 'https://example.com/CHANGELOG.md';

/// A loader that always succeeds with [content].

ChangelogLoader _serving(String content) => (_) async => content;

/// A loader that always fails.

Future<String> _failing(String url) async => throw Exception('offline');

/// A minimal host for the widget under test.

Widget _host(Widget child) => MaterialApp(
      home: Scaffold(body: Center(child: child)),
    );

/// Advances past the loader's single retry pause so a failing check
/// settles. Only the transport is retried, so this matters for a throwing
/// loader rather than for unparsable content.

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(seconds: 3));
  await tester.pump();
}

/// The resolved style of the rendered version label.

TextStyle _styleOf(WidgetTester tester, String text) =>
    tester.widget<Text>(find.text(text)).style!;

/// The update button, identified by its icon.

Finder get _updateButton => find.byIcon(Icons.system_update_alt);

void main() {
  group('a successful check', () {
    testWidgets('shows blue with the release date when up to date',
        (tester) async {
      await tester.pumpWidget(
        _host(
          VersionWidget(
            version: '1.0.10',
            changelogUrl: _url,
            showUpdateButton: true,
            downloadUrl: 'https://example.com/install',
            changelogLoader: _serving(canonicalChangelog),
          ),
        ),
      );
      await _settle(tester);

      const text = 'Version 1.0.10 - 12 May 2026';
      expect(find.text(text), findsOneWidget);
      expect(_styleOf(tester, text).color, Colors.blue);
      expect(_updateButton, findsNothing);
    });

    testWidgets('shows red, bold and an update button when outdated',
        (tester) async {
      await tester.pumpWidget(
        _host(
          VersionWidget(
            version: '1.0.8',
            changelogUrl: _url,
            showUpdateButton: true,
            downloadUrl: 'https://example.com/install',
            changelogLoader: _serving(canonicalChangelog),
          ),
        ),
      );
      await _settle(tester);

      const text = 'Version 1.0.8 - 29 Apr 2026';
      expect(_styleOf(tester, text).color, Colors.red);
      expect(_styleOf(tester, text).fontWeight, FontWeight.bold);
      expect(_updateButton, findsOneWidget);
    });

    testWidgets('reads a changelog written author first', (tester) async {
      // Podmail end to end: the app is current, and says so with a date.

      await tester.pumpWidget(
        _host(
          VersionWidget(
            version: '0.1.13',
            changelogUrl: _url,
            changelogLoader: _serving(authorFirstChangelog),
          ),
        ),
      );
      await _settle(tester);

      const text = 'Version 0.1.13 - 8 Sep 2026';
      expect(find.text(text), findsOneWidget);
      expect(_styleOf(tester, text).color, Colors.blue);
    });
  });

  group('a failed check', () {
    testWidgets('reports unknown when the loader throws', (tester) async {
      await tester.pumpWidget(
        _host(
          const VersionWidget(
            version: '1.0.0',
            changelogUrl: _url,
            showUpdateButton: true,
            downloadUrl: 'https://example.com/install',
            changelogLoader: _failing,
          ),
        ),
      );
      await _settle(tester);

      expect(_styleOf(tester, 'Version 1.0.0').color, isNot(Colors.blue));
      expect(_styleOf(tester, 'Version 1.0.0').color, Colors.orange.shade800);

      // No update is known to exist, so none is offered.

      expect(_updateButton, findsNothing);
    });

    testWidgets('reports unknown when nothing in the body can be read',
        (tester) async {
      // The podmail failure exactly: the fetch succeeds, the content is
      // unreadable, and the old code called that up to date.

      await tester.pumpWidget(
        _host(
          VersionWidget(
            version: '1.0.0',
            changelogUrl: _url,
            changelogLoader: _serving(unparsableChangelog),
          ),
        ),
      );
      await _settle(tester);

      expect(_styleOf(tester, 'Version 1.0.0').color, Colors.orange.shade800);
    });

    testWidgets('reports unknown on an empty body', (tester) async {
      await tester.pumpWidget(
        _host(
          VersionWidget(
            version: '1.0.0',
            changelogUrl: _url,
            changelogLoader: _serving(''),
          ),
        ),
      );
      await _settle(tester);

      expect(_styleOf(tester, 'Version 1.0.0').color, Colors.orange.shade800);
    });

    testWidgets('reports unknown when the app has no version of its own',
        (tester) async {
      // A misconfigured Info.plist leaves package_info_plus returning ''.
      // compareVersions('', '1.0.10') is negative, so before this guard
      // the widget announced 'outdated' and offered an update button on
      // the strength of no information at all.

      await tester.pumpWidget(
        _host(
          VersionWidget(
            version: '',
            changelogUrl: _url,
            showUpdateButton: true,
            downloadUrl: 'https://example.com/install',
            changelogLoader: _serving(canonicalChangelog),
          ),
        ),
      );
      await _settle(tester);

      expect(_styleOf(tester, 'Version ').color, Colors.orange.shade800);
      expect(_styleOf(tester, 'Version ').fontWeight, isNot(FontWeight.bold));
      expect(_updateButton, findsNothing);
    });

    testWidgets('honours a supplied unknownColor', (tester) async {
      await tester.pumpWidget(
        _host(
          VersionWidget(
            version: '1.0.0',
            changelogUrl: _url,
            unknownColor: Colors.purple,
            changelogLoader: _serving(unparsableChangelog),
          ),
        ),
      );
      await _settle(tester);

      expect(_styleOf(tester, 'Version 1.0.0').color, Colors.purple);
    });

    testWidgets('restores the pre 1.1.0 behaviour when asked', (tester) async {
      // The opt out. Pinned so the old, quiet behaviour stays available.

      await tester.pumpWidget(
        _host(
          const VersionWidget(
            version: '1.0.0',
            changelogUrl: _url,
            assumeLatestOnCheckFailure: true,
            showUpdateButton: true,
            downloadUrl: 'https://example.com/install',
            changelogLoader: _failing,
          ),
        ),
      );
      await _settle(tester);

      expect(_styleOf(tester, 'Version 1.0.0').color, Colors.blue);
      expect(_updateButton, findsNothing);
    });
  });

  group('checking and unchecked', () {
    testWidgets('is grey while the check is in flight', (tester) async {
      final gate = Completer<String>();

      await tester.pumpWidget(
        _host(
          VersionWidget(
            version: '1.0.0',
            changelogUrl: _url,
            changelogLoader: (_) => gate.future,
          ),
        ),
      );
      await tester.pump();

      expect(_styleOf(tester, 'Version 1.0.0').color, Colors.grey);

      gate.complete(canonicalChangelog);
      await _settle(tester);

      expect(_styleOf(tester, 'Version 1.0.0').color, Colors.red);
    });

    testWidgets('never loads when no changelog URL is configured',
        (tester) async {
      var loaderCalls = 0;

      await tester.pumpWidget(
        _host(
          VersionWidget(
            version: '1.0.0',
            changelogLoader: (_) async {
              loaderCalls++;

              return canonicalChangelog;
            },
          ),
        ),
      );
      await _settle(tester);

      expect(loaderCalls, 0);

      // Unchanged from before the status model existed: plain blue.

      expect(_styleOf(tester, 'Version 1.0.0').color, Colors.blue);
    });
  });

  group('a host supplied text style', () {
    const hostStyle = TextStyle(
      color: Colors.white,
      fontFamily: 'Courier',
      letterSpacing: 2.0,
    );

    testWidgets('is used verbatim when up to date', (tester) async {
      await tester.pumpWidget(
        _host(
          VersionWidget(
            version: '1.0.10',
            changelogUrl: _url,
            userTextStyle: hostStyle,
            changelogLoader: _serving(canonicalChangelog),
          ),
        ),
      );
      await _settle(tester);

      expect(_styleOf(tester, 'Version 1.0.10 - 12 May 2026'), hostStyle);
    });

    testWidgets('escalates colour and weight when outdated', (tester) async {
      await tester.pumpWidget(
        _host(
          VersionWidget(
            version: '1.0.8',
            changelogUrl: _url,
            userTextStyle: hostStyle,
            changelogLoader: _serving(canonicalChangelog),
          ),
        ),
      );
      await _settle(tester);

      final style = _styleOf(tester, 'Version 1.0.8 - 29 Apr 2026');
      expect(style.color, Colors.red);
      expect(style.fontWeight, FontWeight.bold);

      // Everything else the host chose survives.

      expect(style.fontFamily, 'Courier');
      expect(style.letterSpacing, 2.0);
    });

    testWidgets('escalates colour but not weight when unknown', (tester) async {
      await tester.pumpWidget(
        _host(
          VersionWidget(
            version: '1.0.0',
            changelogUrl: _url,
            userTextStyle: hostStyle,
            changelogLoader: _serving(unparsableChangelog),
          ),
        ),
      );
      await _settle(tester);

      final style = _styleOf(tester, 'Version 1.0.0');
      expect(style.color, Colors.orange.shade800);
      expect(style.fontWeight, isNot(FontWeight.bold));
      expect(style.fontFamily, 'Courier');
    });
  });

  group('the update button', () {
    testWidgets('defers to onUpdatePressed when supplied', (tester) async {
      var pressed = 0;

      await tester.pumpWidget(
        _host(
          VersionWidget(
            version: '1.0.8',
            changelogUrl: _url,
            showUpdateButton: true,
            onUpdatePressed: () => pressed++,
            changelogLoader: _serving(canonicalChangelog),
          ),
        ),
      );
      await _settle(tester);

      // Rendered without a downloadUrl, because a handler is target enough.

      expect(_updateButton, findsOneWidget);

      await tester.tap(_updateButton);
      await tester.pump();

      expect(pressed, 1);
    });

    testWidgets('is not rendered without a target', (tester) async {
      await tester.pumpWidget(
        _host(
          VersionWidget(
            version: '1.0.8',
            changelogUrl: _url,
            showUpdateButton: true,
            changelogLoader: _serving(canonicalChangelog),
          ),
        ),
      );
      await _settle(tester);

      expect(_updateButton, findsNothing);
    });
  });

  testWidgets('collapses when the version is hidden and no button shows',
      (tester) async {
    await tester.pumpWidget(
      _host(
        VersionWidget(
          version: '1.0.10',
          changelogUrl: _url,
          showVersion: false,
          changelogLoader: _serving(canonicalChangelog),
        ),
      ),
    );
    await _settle(tester);

    expect(find.textContaining('Version'), findsNothing);
  });
}
