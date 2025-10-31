import 'clipboard_detect_platform_interface.dart';

class ClipboardDetect {
  Future<String?> getPlatformVersion() {
    return ClipboardDetectPlatform.instance.getPlatformVersion();
  }

  Future<List<String>> detectClipboardPatterns({List<String>? patterns}) {
    return ClipboardDetectPlatform.instance.detectClipboardPatterns(patterns: patterns);
  }

  Future<List<List<String>>> detectClipboardPatternsInItems({
    List<int>? itemIndexes,
    List<String>? patterns,
  }) {
    return ClipboardDetectPlatform.instance.detectClipboardPatternsInItems(
      itemIndexes: itemIndexes,
      patterns: patterns,
    );
  }

  Future<Map<String, dynamic>> detectClipboardValues({List<String>? patterns}) {
    return ClipboardDetectPlatform.instance.detectClipboardValues(patterns: patterns);
  }

  Future<List<Map<String, dynamic>>> detectClipboardValuesInItems({
    List<int>? itemIndexes,
    List<String>? patterns,
  }) {
    return ClipboardDetectPlatform.instance.detectClipboardValuesInItems(
      itemIndexes: itemIndexes,
      patterns: patterns,
    );
  }
}
