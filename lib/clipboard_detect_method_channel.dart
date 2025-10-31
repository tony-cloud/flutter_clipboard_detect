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
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<List<String>> detectClipboardPatterns({List<String>? patterns}) async {
    final args = <String, dynamic>{};
    if (patterns != null) {
      args['patterns'] = patterns;
    }

    final result = await methodChannel.invokeListMethod<String>('detectClipboardPatterns', args);
    return result ?? const <String>[];
  }

  @override
  Future<List<List<String>>> detectClipboardPatternsInItems({
    List<int>? itemIndexes,
    List<String>? patterns,
  }) async {
    final args = <String, dynamic>{};
    if (patterns != null) {
      args['patterns'] = patterns;
    }
    if (itemIndexes != null) {
      args['itemIndexes'] = itemIndexes;
    }

    final result = await methodChannel.invokeListMethod<dynamic>(
      'detectClipboardPatternsInItems',
      args,
    );

    if (result == null) {
      return const <List<String>>[];
    }

    return result.map((item) => (item as List<dynamic>).cast<String>()).toList(growable: false);
  }

  @override
  Future<Map<String, dynamic>> detectClipboardValues({List<String>? patterns}) async {
    final args = <String, dynamic>{};
    if (patterns != null) {
      args['patterns'] = patterns;
    }

    final result = await methodChannel.invokeMapMethod<String, dynamic>(
      'detectClipboardValues',
      args,
    );
    return result ?? const <String, dynamic>{};
  }

  @override
  Future<List<Map<String, dynamic>>> detectClipboardValuesInItems({
    List<int>? itemIndexes,
    List<String>? patterns,
  }) async {
    final args = <String, dynamic>{};
    if (patterns != null) {
      args['patterns'] = patterns;
    }
    if (itemIndexes != null) {
      args['itemIndexes'] = itemIndexes;
    }

    final result = await methodChannel.invokeListMethod<dynamic>(
      'detectClipboardValuesInItems',
      args,
    );

    if (result == null) {
      return const <Map<String, dynamic>>[];
    }

    return result
        .map((item) {
          final typed = (item as Map<dynamic, dynamic>).map(
            (key, value) => MapEntry(key as String, value),
          );
          return Map<String, dynamic>.from(typed);
        })
        .toList(growable: false);
  }
}
