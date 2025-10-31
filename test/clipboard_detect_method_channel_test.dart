import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clipboard_detect/clipboard_detect_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelClipboardDetect platform = MethodChannelClipboardDetect();
  const MethodChannel channel = MethodChannel('clipboard_detect');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'getPlatformVersion':
            return '42';
          case 'detectClipboardPatterns':
            return <String>['probableWebURL'];
          case 'detectClipboardPatternsInItems':
            return <List<String>>[
              <String>['probableWebURL'],
            ];
          case 'detectClipboardValues':
            return <String, dynamic>{'probableWebURL': 'https://example.com'};
          case 'detectClipboardValuesInItems':
            return <Map<String, dynamic>>[
              <String, dynamic>{'probableWebURL': 'https://example.com'},
            ];
          default:
            return null;
        }
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      null,
    );
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });

  test('detectClipboardPatterns', () async {
    expect(await platform.detectClipboardPatterns(), <String>['probableWebURL']);
  });

  test('detectClipboardPatternsInItems', () async {
    expect(await platform.detectClipboardPatternsInItems(), <List<String>>[
      <String>['probableWebURL'],
    ]);
  });

  test('detectClipboardValues', () async {
    expect(await platform.detectClipboardValues(), <String, dynamic>{
      'probableWebURL': 'https://example.com',
    });
  });

  test('detectClipboardValuesInItems', () async {
    expect(await platform.detectClipboardValuesInItems(), <Map<String, dynamic>>[
      <String, dynamic>{'probableWebURL': 'https://example.com'},
    ]);
  });
}
