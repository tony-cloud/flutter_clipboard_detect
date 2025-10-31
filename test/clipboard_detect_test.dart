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
}
