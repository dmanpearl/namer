# namer

A Flutter/Dart app to choose and bookmark compound names based on Flutter's tutorial

# Run on physical iOS iPhone device from command line:

1. List devices

		flutter devices
			Found 4 connected devices:
			  David’s iPhone (mobile) • 00008030-00050DC61AB9802E            • ios            • iOS 18.1.1 22B91
			  iPhone 16 Plus (mobile) • 0B387A7C-8371-40DB-8E57-1BBF7E790DDA • ios            • com.apple.CoreSimulator.SimRuntime.iOS-18-1 (simulator)
			  macOS (desktop)         • macos                                • darwin-x64     • macOS 15.1.1 24B91 darwin-x64
			  Chrome (web)            • chrome                               • web-javascript • Google Chrome 131.0.6778.205
			Found 1 wirelessly connected device:
			  David’s iPhone (mobile) • 00008030-00050DC61AB9802E • ios • iOS 18.1.1 22B91

1. Install from console:

		flutter run --release -d "David’s iPhone"
			Launching lib/main.dart on David’s iPhone in release mode...
			Automatically signing iOS for device deployment using specified development team in Xcode project: 33V4F5LWJ6
			Running Xcode build...

		flutter run --release -d "macOS"

1. Enable trust on device

	If device displays: "Untrusted Developer: Your device management settings to not allow apps from developer..."

	iPhone > Settings > General > VPN & Device Management > Developer App > you.name@domain.com > Allow Apps from... > Allow

# TESTS

## Run all tests

	flutter test test/*

or

	flutter test

## Run individual tests

	flutter test test/utils_test.dart
	flutter test test/utils_serialize_test.dart

# TODO

[✓] Use logging instead of print.
[✓] On app startup, prioritize sync from Firestore over Perstent Storage.
[✓] Unit tests.
[✓] Provide Navigate from Signout screen back to main.
[✓] Add visual indication as to login status via auth icon in sidebar.
[ ] Host on Github.
[ ] Add unit tests widget tap/scroll gestures. See widgets.dart and widget_test.dart.

# Flutter resources

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
