########################################################################
#
# Makefile template for Flutter
#
# Copyright 2021 (c) Graham.Williams@togaware.com
#
# License: Creative Commons Attribution-ShareAlike 4.0 International.
#
########################################################################

# App version numbers
#   Major release
#   Minor update
#   Trivial update or bug fix

ifeq ($(VER),)
  VER = $(shell egrep '^version:' pubspec.yaml | cut -d' ' -f2)
endif

define FLUTTER_HELP
flutter:

  android   Run with an attached Android device;
  chrome    Run with the chrome device;
  emu	    Run with the android emulator;
  linux     Run with the linux device;
  qlinux    Run with the linux device and debugPrint() turned off;

  prep      Prep for PR by running tests, checks, docs.
  push      Do a git push and bump the build number if there is one.

  docs	    Run `dart doc` to create documentation.

  import_order      Run import order checking.
  import_order_fix  Run import order fixing.

  pubspec         Choose actual/local pubspec using meld.

  fix             Run `dart fix --apply`.
  format          Run `dart format`.
  analyze         Run `flutter analyze`.
  depend	  Run `dart run dependency_validator`.
  ignore          Look for usage of ignore directives.
  license	  Look for missing top license in source code.

  test	    Run `flutter test` for testing.
  itest	    Run `flutter test integration_test` for interation testing.
  qtest	    Run above test with PAUSE=0.
  coverage  Run with `--coverage`.
    coview  View the generated html coverage in browser.

  riverpod  Setup `pubspec.yaml` to support riverpod.
  runner    Build the auto generated code as *.g.dart files.

  desktops  Set up for all desktop platforms (linux, windows, macos)

  distributions
    apk	    Builds installers/$(APP).apk
    tgz     Builds installers/$(APP).tar.gz

  publish   Publish a package to pub.dev

Also supported:

  *.itest
  *.qtest

endef
export FLUTTER_HELP

help::
	@echo "$$FLUTTER_HELP"

.PHONY: chrome
chrome:
	flutter run -d chrome

# 20220503 gjw The following fails if the target files already exist -
# just needs to be run once.
#
# dart run build_runner build --delete-conflicting-outputs
#
# List the files that are automatically generated. Then they will get
# built as required.

# BUILD_RUNNER = \
# 	lib/models/synchronise_time.g.dart

# $(BUILD_RUNNER):
# 	dart run build_runner build --delete-conflicting-outputs

pubspec.lock:
	flutter pub get

.PHONY: linux
linux: pubspec.lock $(BUILD_RUNNER)
	flutter run --device-id linux

# Turn off debugPrint() output.

.PHONY: qlinux
qlinux: pubspec.lock $(BUILD_RUNNER)
	flutter run --dart-define DEBUG_PRINT="FALSE" --device-id linux

.PHONY: macos
macos: $(BUILD_RUNNER)
	flutter run --device-id macos

.PHONY: android
android: $(BUILD_RUNNER)
	flutter run --device-id $(shell flutter devices | grep android | tr '•' '|' | tr -s '|' | tr -s ' ' | cut -d'|' -f2 | tr -d ' ')

.PHONY: emu
emu:
	@if [ -n "$(shell flutter devices | grep emulator | cut -d" " -f 6)" ]; then \
	  flutter run --device-id $(shell flutter devices | grep emulator | cut -d" " -f 6); \
	else \
	  flutter emulators --launch Pixel_3a_API_30; \
	  echo "Emulator has been started. Rerun `make emu` to build the app."; \
	fi

.PHONY: linux_config
linux_config:
	flutter config --enable-linux-desktop

.PHONY: prep
prep: analyze fix import_order_fix format ignore license todo depend
	@echo "ADVISORY: make tests docs"
	@echo $(SEPARATOR)

.PHONY: docs
docs::
	dart doc
	chmod -R go+rX doc

SEPARATOR="------------------------------------------------------------------------"

.PHONY: pubspec
pubspec:
	meld pubspec.yaml.actual pubspec.yaml pubspec.yaml.local

.PHONY: fix
fix:
	@echo "Dart: FIX"
	dart fix --apply lib
	@echo $(SEPARATOR)

.PHONY: format
format:
	@echo "Dart: FORMAT"
	dart format lib/
	@echo $(SEPARATOR)

# My emacs IDE is starting to add imports of backups automagically!

.PHONY: bakfix
bakfix:
	@echo "Find and fix imports of backups."
	find lib -type f -name '*.dart*' -exec sed -i 's/\.dart\.~\([0-9]\)~/\.dart/g' {} +
	@echo $(SEPARATOR)

.PHONY: tests
tests:: test qtest

.PHONY: analyze
analyze:
	@echo "Futter ANALYZE"
	-flutter analyze lib
#	dart run custom_lint
	@echo $(SEPARATOR)

# dart pub global activate dependency_validator

.PHONY: depend
depend:
	@echo "Review pubspec.yaml dependencies."
	-dependency_validator
	@echo $(SEPARATOR)

.PHONY: ignore
ignore:
	@echo "Files that override lint checks with IGNORE:\n"
	@-if grep -r -n ignore: lib; then exit 1; else exit 0; fi
	@echo $(SEPARATOR)

.PHONY: todo
todo:
	@echo "Files that include TODO items to be resolved:\n"
	@-if grep -r -n ' TODO ' lib; then exit 1; else exit 0; fi
	@echo $(SEPARATOR)

.PHONY: license
license:
	@echo "Files without a LICENSE:\n"
	@-find lib -type f -not -name '*~' ! -exec grep -qE '^(/// .*|/// Copyright|/// Licensed)' {} \; -print | xargs printf "\t%s\n"
	@echo $(SEPARATOR)

.PHONY: riverpod
riverpod:
	flutter pub add flutter_riverpod
	flutter pub add riverpod_annotation
	flutter pub add dev:riverpod_generator
	flutter pub add dev:build_runner
	flutter pub add dev:custom_lint
	flutter pub add dev:riverpod_lint

.PHONY: runner
runner:
	dart run build_runner build

# Support desktop platforms: Linux, MacOS and Windows. Using the
# project name as in the already existant pubspec.yaml ensures the
# project name is a valid name. Otherwise it is obtained from the
# folder name and may not necessarily be a valid flutter project name.

.PHONY: desktops
desktops:
	flutter create --platforms=windows,macos,linux --project-name $(shell grep 'name: ' pubspec.yaml | awk '{print $$2}') .

########################################################################
# INTEGRATION TESTING
#
# Run the integration tests for the desktop device (linux, windows,
# macos). Without this explictly specified, if I have my android
# device connected to the computer then the testing defaults to trying
# to install on android. 20230713 gjw

.PHONY: test
test:
	@echo "Unit TEST:"
	-flutter test test
	@echo $(SEPARATOR)

# For a specific interactive test we think of it as providing a
# demonstration of the app functionality that we may actually use to
# create a narrated video. A INTERACT of 5 or more is then useful.

%.itest:
	@device_id=$(shell flutter devices | grep -E 'linux|macos|windows' | perl -pe 's|^[^•]*• ([^ ]*) .*|\1|'); \
	if [ -z "$$device_id" ]; then \
		echo "No desktop device found. Please ensure you have the correct desktop platform enabled."; \
		exit 1; \
	fi; \
	flutter test --dart-define=INTERACT=5 --device-id $$device_id integration_test/$*.dart

# For a run over all tests interactively we INTERACT a little but not as
# much as when running the individual tests.

.PHONY: itest
itest:
	@device_id=$(shell flutter devices | grep -E 'linux|macos|windows' | perl -pe 's|^[^•]*• ([^ ]*) .*|\1|'); \
	if [ -z "$$device_id" ]; then \
		echo "No desktop device found. Please ensure you have the correct desktop platform enabled."; \
		exit 1; \
	fi; \
	for t in integration_test/*.dart; do flutter test --dart-define=INTERACT=2 --device-id $$device_id $$t; done
	@echo $(SEPARATOR)

# For the quick tests we do not INTERACT at all. The aim is to quickly
# test all functionality.

.PHONY: qtest
qtest:
	@device_id=$(shell flutter devices | grep -E 'linux|macos|windows' | perl -pe 's|^[^•]*• ([^ ]*) .*|\1|'); \
	if [ -z "$$device_id" ]; then \
		echo "No desktop device found. Please ensure you have the correct desktop platform enabled."; \
		exit 1; \
	fi; \
	for t in integration_test/*.dart; do \
		echo "========================================"; \
		echo $$t; /bin/echo -n $$t >&2; \
		echo "========================================"; \
		flutter test --dart-define=INTERACT=0 --device-id $$device_id --reporter failures-only  $$t 2>/dev/null; \
		if [ "$$?" -eq 0 ]; then /bin/echo ' YES' >&2; else /bin/echo -n ' ...' >&2; \
		echo '****************************************> TRY AGAIN'; \
		flutter test --dart-define=INTERACT=0 --device-id $$device_id --reporter failures-only  $$t 2>/dev/null; \
		if [ "$$?" -eq 0 ]; then /bin/echo ' YES' >&2; else /bin/echo ' NO *****' >&2; fi; fi; \
	done
	@echo $(SEPARATOR)

%.qtest:
	@device_id=$(shell flutter devices | grep -E 'linux|macos|windows' | perl -pe 's|^[^•]*• ([^ ]*) .*|\1|'); \
	if [ -z "$$device_id" ]; then \
		echo "No desktop device found. Please ensure you have the correct desktop platform enabled."; \
		exit 1; \
	fi; \
	flutter test --dart-define=INTERACT=0 --device-id $$device_id --reporter failures-only integration_test/$*.dart 2>/dev/null

.PHONY: qtest.all
qtest.all:
	@echo $(APP) `egrep '^version: ' pubspec.yaml`
	@echo "flutter version:" `flutter --version | head -1 | cut -d ' ' -f 2`
	make qtest > qtest_$(shell date +%Y%m%d%H%M%S).txt

clean::
	rm -f qtest_*.txt

.PHONY: atest
atest:
	@echo "Full integration TEST:"
	flutter test --dart-define=INTERACT=0 --verbose --device-id \
	$(shell flutter devices | grep desktop | perl -pe 's|^[^•]*• ([^ ]*) .*|\1|') \
	integration_test
	@echo $(SEPARATOR)

.PHONY: coverage
coverage:
	@echo "COVERAGE"
	@flutter test --coverage
	@echo
	@-/bin/bash support/coverage.sh
	@echo $(SEPARATOR)

.PHONY: coview
coview:
	@genhtml coverage/lcov.info -o coverage/html
	@open coverage/html/index.html

realclean::
	rm -rf coverage

# Crate an installer for Linux as a tar.gz archive.

tgz:: $(APP)-$(VER)-linux-x86_64.tar.gz

$(APP)-$(VER)-linux-x86_64.tar.gz: clean
	mkdir -p installers
	rm -rf build/linux/x64/release
	flutter build linux --release
	tar --transform 's|^build/linux/x64/release/bundle|$(APP)|' -czvf $@ build/linux/x64/release/bundle
	cp $@ installers/
	mv $@ installers/$(APP).tar.gz

apk::
	flutter build apk --release
	cp build/app/outputs/flutter-apk/app-release.apk installers/$(APP).apk
	cp build/app/outputs/flutter-apk/app-release.apk installers/$(APP)-$(VER).apk

appbundle:
	flutter build appbundle --release

realclean::
	flutter clean
	flutter pub get

# For the `dev` branch only, update the version sequence number prior
# to a push (relies on the git.mk being loaded after this
# flutter.mk). This is only undertaken through `make push` rather than
# a `git push` in any other way. If
# the pubspec.yaml is not using a build number then do not push to bump
# the build number.

VERSEQ=$(shell grep '^version: ' pubspec.yaml | cut -d'+' -f2 | awk '{print $$1+1}')

BRANCH := $(shell git branch --show-current)

ifeq ($(BRANCH),dev)
push::
	@echo $(SEPARATOR)
	perl -pi -e 's|(^version: .*)\+.*|$$1+$(VERSEQ)|' pubspec.yaml
	-egrep '^version: .*\+.*' pubspec.yaml && \
	git commit -m "Bump sequence $(VERSEQ)" pubspec.yaml
endif

.PHONY: publish
publish:
	dart pub publish

# dart pub global activate import_order_lint

.PHONY: import_order
import_order:
	@echo "Dart: CHECK IMPORT ORDER"
	dart run custom_lint
	@echo $(SEPARATOR)

.PHONY: import_order_fix
import_order_fix:
	@echo "Dart: FIX IMPORT ORDER"
	fix_imports --project-name=$(APP) -r lib
	@echo $(SEPARATOR)

### TODO THESE SHOULD BE CHECKED AND CLEANED UP


.PHONY: docs
docs::
	rsync -avzh doc/api/ root@solidcommunity.au:/var/www/html/docs/$(APP)/

.PHONY: versions
versions:
	perl -pi -e 's|applicationVersion = ".*";|applicationVersion = "$(VER)";|' \
	lib/constants/app.dart

.PHONY: wc
wc: lib/*.dart
	@cat $(shell find lib -name '*.dart') \
	| egrep -v '^ */' \
	| egrep -v '^ *$$' \
	| wc -l

#
# Manage the production install on the remote server.
#

.PHONY: solidcommunity
solidcommunity:
	rsync -avzh ./ solidcommunity.au:projects/$(APP)/ \
	--exclude .dart_tool --exclude build --exclude ios --exclude macos \
	--exclude linux --exclude windows --exclude android
	ssh solidcommunity.au '(cd projects/$(APP); flutter upgrade; make prod)'
