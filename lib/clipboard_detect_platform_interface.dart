import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'clipboard_detect_method_channel.dart';

abstract class ClipboardDetectPlatform extends PlatformInterface {
  /// Constructs a ClipboardDetectPlatform.
  ClipboardDetectPlatform() : super(token: _token);

  static final Object _token = Object();

  static ClipboardDetectPlatform _instance = MethodChannelClipboardDetect();

  /// The default instance of [ClipboardDetectPlatform] to use.
  ///
  /// Defaults to [MethodChannelClipboardDetect].
  static ClipboardDetectPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ClipboardDetectPlatform] when
  /// they register themselves.
  static set instance(ClipboardDetectPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<List<String>> detectClipboardPatterns({List<String>? patterns}) {
    throw UnimplementedError(
      'detectClipboardPatterns() has not been implemented.',
    );
  }
}
