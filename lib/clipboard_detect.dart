import 'clipboard_detect_platform_interface.dart';

class ClipboardDetect {
  Future<String?> getPlatformVersion() {
    return ClipboardDetectPlatform.instance.getPlatformVersion();
  }

  Future<List<String>> detectClipboardPatterns({List<String>? patterns}) {
    return ClipboardDetectPlatform.instance.detectClipboardPatterns(
      patterns: patterns,
    );
  }
}
