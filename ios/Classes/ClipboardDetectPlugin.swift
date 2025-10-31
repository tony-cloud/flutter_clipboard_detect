import Flutter
import UIKit

public class ClipboardDetectPlugin: NSObject, FlutterPlugin {
  private enum Method: String {
    case getPlatformVersion
    case detectClipboardPatterns
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "clipboard_detect", binaryMessenger: registrar.messenger())
    let instance = ClipboardDetectPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let method = Method(rawValue: call.method) else {
      result(FlutterMethodNotImplemented)
      return
    }

    switch method {
    case .getPlatformVersion:
      result("iOS " + UIDevice.current.systemVersion)
    case .detectClipboardPatterns:
      detectClipboardPatterns(arguments: call.arguments, result: result)
    }
  }

  private func detectClipboardPatterns(arguments: Any?, result: @escaping FlutterResult) {
    guard #available(iOS 14.0, *) else {
      result(FlutterError(code: "unsupported", message: "UIPasteboard.detectPatterns requires iOS 14 or newer.", details: nil))
      return
    }

    let patternNames = (arguments as? [String: Any])?["patterns"] as? [String]
    let resolvedPatterns = resolveDetectionPatterns(from: patternNames)

    if resolvedPatterns.isEmpty {
      result([String]())
      return
    }

    UIPasteboard.general.detectPatterns(for: resolvedPatterns) { detectedPatterns, error in
      if let error = error {
        DispatchQueue.main.async {
          result(FlutterError(code: "pattern_detection_failed", message: error.localizedDescription, details: nil))
        }
        return
      }

      guard let detectedPatterns = detectedPatterns, !detectedPatterns.isEmpty else {
        DispatchQueue.main.async { result([String]()) }
        return
      }

      let matches = detectedPatterns.map { $0.rawValue }.sorted()
      DispatchQueue.main.async { result(matches) }
    }
  }

  @available(iOS 14.0, *)
  private func resolveDetectionPatterns(from rawNames: [String]?) -> Set<UIPasteboard.DetectionPattern> {
    let defaultPatternNames = [
      UIPasteboard.DetectionPattern.probableWebURL.rawValue,
      UIPasteboard.DetectionPattern.probablePhoneNumber.rawValue,
      UIPasteboard.DetectionPattern.probableEmailAddress.rawValue,
      UIPasteboard.DetectionPattern.probableAddress.rawValue,
      UIPasteboard.DetectionPattern.number.rawValue,
      UIPasteboard.DetectionPattern.probableWebSearch.rawValue,
    ]

    let names = rawNames?.filter { !$0.isEmpty } ?? defaultPatternNames
    let patterns = names.compactMap { UIPasteboard.DetectionPattern(rawValue: $0) }
    return Set(patterns)
  }
}
