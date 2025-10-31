import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'clipboard_detect_platform_interface.dart';

/// An implementation of [ClipboardDetectPlatform] that uses method channels.
class MethodChannelClipboardDetect extends ClipboardDetectPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('clipboard_detect');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }

  @override
  Future<List<String>> detectClipboardPatterns({List<String>? patterns}) async {
    final args = <String, dynamic>{};
    if (patterns != null) {
      args['patterns'] = patterns;
    }

    final result = await methodChannel.invokeListMethod<String>(
      'detectClipboardPatterns',
      args,
    );
    return result ?? const <String>[];
  }
}
