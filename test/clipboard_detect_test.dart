import 'package:flutter_test/flutter_test.dart';
import 'package:clipboard_detect/clipboard_detect.dart';
import 'package:clipboard_detect/clipboard_detect_platform_interface.dart';
import 'package:clipboard_detect/clipboard_detect_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockClipboardDetectPlatform
    with MockPlatformInterfaceMixin
    implements ClipboardDetectPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<List<String>> detectClipboardPatterns({List<String>? patterns}) =>
      Future.value(<String>['probableWebURL']);

  @override
  Future<List<List<String>>> detectClipboardPatternsInItems({
    List<int>? itemIndexes,
    List<String>? patterns,
  }) => Future.value(<List<String>>[
    <String>['probableWebURL'],
    <String>['probablePhoneNumber'],
  ]);

  @override
  Future<Map<String, dynamic>> detectClipboardValues({List<String>? patterns}) =>
      Future.value(<String, dynamic>{'probableWebURL': 'https://example.com'});

  @override
  Future<List<Map<String, dynamic>>> detectClipboardValuesInItems({
    List<int>? itemIndexes,
    List<String>? patterns,
  }) => Future.value(<Map<String, dynamic>>[
    <String, dynamic>{'probableWebURL': 'https://example.com'},
    <String, dynamic>{'probablePhoneNumber': '+1-555-0100'},
  ]);
}

void main() {
  final ClipboardDetectPlatform initialPlatform = ClipboardDetectPlatform.instance;

  test('$MethodChannelClipboardDetect is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelClipboardDetect>());
  });

  test('getPlatformVersion', () async {
    ClipboardDetect clipboardDetectPlugin = ClipboardDetect();
    MockClipboardDetectPlatform fakePlatform = MockClipboardDetectPlatform();
    ClipboardDetectPlatform.instance = fakePlatform;

    expect(await clipboardDetectPlugin.getPlatformVersion(), '42');
  });

  test('detectClipboardPatterns delegates to platform implementation', () async {
    ClipboardDetect clipboardDetectPlugin = ClipboardDetect();
    MockClipboardDetectPlatform fakePlatform = MockClipboardDetectPlatform();
    ClipboardDetectPlatform.instance = fakePlatform;

    expect(await clipboardDetectPlugin.detectClipboardPatterns(), <String>['probableWebURL']);
  });

  test('detectClipboardPatternsInItems delegates to platform implementation', () async {
    ClipboardDetect clipboardDetectPlugin = ClipboardDetect();
    MockClipboardDetectPlatform fakePlatform = MockClipboardDetectPlatform();
    ClipboardDetectPlatform.instance = fakePlatform;

    expect(await clipboardDetectPlugin.detectClipboardPatternsInItems(), <List<String>>[
      <String>['probableWebURL'],
      <String>['probablePhoneNumber'],
    ]);
  });

  test('detectClipboardValues delegates to platform implementation', () async {
    ClipboardDetect clipboardDetectPlugin = ClipboardDetect();
    MockClipboardDetectPlatform fakePlatform = MockClipboardDetectPlatform();
    ClipboardDetectPlatform.instance = fakePlatform;

    expect(await clipboardDetectPlugin.detectClipboardValues(), <String, dynamic>{
      'probableWebURL': 'https://example.com',
    });
  });

  test('detectClipboardValuesInItems delegates to platform implementation', () async {
    ClipboardDetect clipboardDetectPlugin = ClipboardDetect();
    MockClipboardDetectPlatform fakePlatform = MockClipboardDetectPlatform();
    ClipboardDetectPlatform.instance = fakePlatform;

    expect(await clipboardDetectPlugin.detectClipboardValuesInItems(), <Map<String, dynamic>>[
      <String, dynamic>{'probableWebURL': 'https://example.com'},
      <String, dynamic>{'probablePhoneNumber': '+1-555-0100'},
    ]);
  });
}
