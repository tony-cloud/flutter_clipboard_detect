# clipboard_detect

Flutter plugin that exposes iOS clipboard pattern and value detection.

## Usage

```dart
final detector = ClipboardDetect();
final matches = await detector.detectClipboardPatterns();

if (matches.contains('probableWebURL')) {
  // Handle a URL without reading clipboard contents.
}
```

Pass an explicit list of raw detection pattern identifiers to narrow the check:

```dart
await detector.detectClipboardPatterns(
	patterns: <String>['probableWebURL', 'probablePhoneNumber'],
);
```

If `patterns` is omitted the plugin evaluates a default set of common patterns (URL, phone number, email address, mailing address, number, and web search). The method resolves to an empty list when nothing matches or the clipboard is empty.

### Match a clipboard URL against an allowed domain

The pattern probe tells you when it's worthwhile to read the clipboard. Once a probable URL is detected, you can validate the host domain before acting on it:

```dart
import 'package:clipboard_detect/clipboard_detect.dart';

Future<bool> clipboardContainsAllowedUrl(Set<String> allowedHosts) async {
	final detector = ClipboardDetect();
	final matches = await detector.detectClipboardPatterns();

	if (!matches.contains('probableWebURL')) {
		return false;
	}

	final values = await detector.detectClipboardValues(
		patterns: const <String>['probableWebURL'],
	);

	final clipboardValue = values['probableWebURL'] as String?;
	if (clipboardValue == null || clipboardValue.isEmpty) {
		return false;
	}

	final uri = _resolveUrl(clipboardValue);
	if (uri == null) {
		return false;
	}

	return allowedHosts.contains(uri.host.toLowerCase());
}

Uri? _resolveUrl(String value) {
	final direct = Uri.tryParse(value);
	if (direct != null && direct.hasScheme && direct.host.isNotEmpty) {
		return direct;
	}

	final withScheme = Uri.tryParse('https://$value');
	if (withScheme != null && withScheme.host.isNotEmpty) {
		return withScheme;
	}

	return null;
}
```

Call the helper with the set of domains you trust:

```dart
final isAllowed = await clipboardContainsAllowedUrl({'example.com'});
```

### Inspect multiple pasteboard items

Use the `*InItems` variants to scope pattern and value detection to specific pasteboard entries (for example, to distinguish between primary and secondary clips):

```dart
final detector = ClipboardDetect();
final patternMatches = await detector.detectClipboardPatternsInItems(
	itemIndexes: const <int>[0, 1],
	patterns: const <String>['probableWebURL', 'probablePhoneNumber'],
);

final valueMatches = await detector.detectClipboardValuesInItems(
	itemIndexes: const <int>[0, 1],
	patterns: const <String>['probableWebURL'],
);
```

The plugin serializes any detected values into channel-safe data (strings, numbers, lists, and maps). Complex detection results (for example, data-detector structures) are stringified via `description`.

> **Note:** Pattern detection is available on iOS 14 and newer. On earlier versions the plugin throws an `PlatformException` with code `unsupported`.

## Example app

Run the sample in `example/` to try the detection path end-to-end:

```sh
cd example
flutter run
```

Copy a value on your simulator or device, then tap **Detect clipboard patterns** in the running example to see the matching pattern identifiers.


