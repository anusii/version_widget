/// CHANGELOG fixtures shared by the tests.

library;

/// The convention documented across our apps: `[version date author]`.

const String canonicalChangelog = '''
# Test App Changelog

Guide: The `[version timestamp user]` string is utilised by the flutter
version_widget package.

## 1.1 Review and Consolidate

+ Restore version string colours for status [1.0.10 20260512 tonypioneer]
+ Add an UPDATE button [1.0.9 20260510 tonypioneer]
+ Better tooltip formatting [1.0.8 20260429 gjw]
''';

/// Author before the date, as podmail writes it. Every entry here is
/// invisible to the pattern used before version 1.1.0.

const String authorFirstChangelog = '''
# Podmail Change Log

## 0.1 Initial concept

+ Add sent by podmail signature [0.1.13 jesscmoore 20260908]
+ Fix send and receive in web app [0.1.12 anushkavidanage 20260907]
+ Configure for podmail.me hosting [0.1.11 jesscmoore 20260907]
''';

/// Both orderings in the one file, plus an entry with no author at all.

const String mixedChangelog = '''
+ Author last [2.0.1 20260601 gjw]
+ Author first [2.0.0 jesscmoore 20260530]
+ No author [1.9.9 20260501]
''';

/// Entries that look plausible but carry no usable date. Parsing this is
/// the failure podmail hit on every launch: content arrives, nothing in it
/// can be read, and the app must not conclude it is up to date.

const String unparsableChangelog = '''
# Change Log

+ Missing the date entirely [1.0.0 jesscmoore]
+ Date too short [1.0.1 2026051]
+ Date too long [1.0.2 202605123]
+ No version at all [nightly 20260512]
''';

/// The rendered HTML a Hugo site serves, rather than raw markdown.

const String htmlChangelog = '''
<h2>Change Log</h2>
<ul>
<li>Configure for podmail.me hosting [0.1.11 jesscmoore 20260907]</li>
<li>Support email attachments [0.1.9 anushkavidanage 20260904]</li>
</ul>
''';
