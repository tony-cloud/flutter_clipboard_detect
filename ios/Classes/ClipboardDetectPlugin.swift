import Flutter
import UIKit

public class ClipboardDetectPlugin: NSObject, FlutterPlugin {
  private enum Method: String {
    case getPlatformVersion
    case detectClipboardPatterns
    case detectClipboardPatternsInItems
    case detectClipboardValues
    case detectClipboardValuesInItems
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
      detectClipboardPatterns(arguments: call.arguments, flutterResult: result)
    case .detectClipboardPatternsInItems:
      detectClipboardPatternsInItems(arguments: call.arguments, flutterResult: result)
    case .detectClipboardValues:
      detectClipboardValues(arguments: call.arguments, flutterResult: result)
    case .detectClipboardValuesInItems:
      detectClipboardValuesInItems(arguments: call.arguments, flutterResult: result)
    }
  }

  private func detectClipboardPatterns(arguments: Any?, flutterResult: @escaping FlutterResult) {
    guard #available(iOS 14.0, *) else {
      flutterResult(FlutterError(code: "unsupported", message: "UIPasteboard.detectPatterns requires iOS 14 or newer.", details: nil))
      return
    }

    let patternNames = (arguments as? [String: Any])?["patterns"] as? [String]
    let resolvedPatterns = resolveDetectionPatterns(from: patternNames)

    if resolvedPatterns.isEmpty {
      flutterResult([String]())
      return
    }

    UIPasteboard.general.detectPatterns(for: resolvedPatterns) { outcome in
      switch outcome {
      case .failure(let error):
        DispatchQueue.main.async {
          flutterResult(FlutterError(code: "pattern_detection_failed", message: error.localizedDescription, details: nil))
        }
      case .success(let detectedPatterns):
        let matches = detectedPatterns.map { $0.rawValue }.sorted()
        DispatchQueue.main.async {
          flutterResult(matches)
        }
      }
    }
  }

  private func detectClipboardPatternsInItems(arguments: Any?, flutterResult: @escaping FlutterResult) {
    guard #available(iOS 14.0, *) else {
      flutterResult(FlutterError(code: "unsupported", message: "UIPasteboard.detectPatterns requires iOS 14 or newer.", details: nil))
      return
    }

    let args = arguments as? [String: Any]
    let patternNames = args?["patterns"] as? [String]
    let resolvedPatterns = resolveDetectionPatterns(from: patternNames)

    if resolvedPatterns.isEmpty {
      flutterResult([[String]]())
      return
    }

    let rawIndexes = parseItemIndexes(from: args?["itemIndexes"])
    if let rawIndexes, rawIndexes.isEmpty {
      flutterResult([[String]]())
      return
    }

    let indexSet = resolveIndexSet(from: rawIndexes)

    UIPasteboard.general.detectPatterns(for: resolvedPatterns, inItemSet: indexSet) { outcome in
      switch outcome {
      case .failure(let error):
        DispatchQueue.main.async {
          flutterResult(FlutterError(code: "pattern_detection_failed", message: error.localizedDescription, details: nil))
        }
      case .success(let patternResults):
        let matches = patternResults.map { patterns -> [String] in
          patterns.map { $0.rawValue }.sorted()
        }
        DispatchQueue.main.async {
          flutterResult(matches)
        }
      }
    }
  }

  private func detectClipboardValues(arguments: Any?, flutterResult: @escaping FlutterResult) {
    guard #available(iOS 14.0, *) else {
      flutterResult(FlutterError(code: "unsupported", message: "UIPasteboard.detectValues requires iOS 14 or newer.", details: nil))
      return
    }

    let args = arguments as? [String: Any]
    let patternNames = args?["patterns"] as? [String]
    let resolvedPatterns = resolveDetectionPatterns(from: patternNames)

    if resolvedPatterns.isEmpty {
      flutterResult([String: Any]())
      return
    }

    UIPasteboard.general.detectValues(for: resolvedPatterns) { outcome in
      switch outcome {
      case .failure(let error):
        DispatchQueue.main.async {
          flutterResult(FlutterError(code: "value_detection_failed", message: error.localizedDescription, details: nil))
        }
      case .success(let values):
        guard !values.isEmpty else {
          DispatchQueue.main.async {
            flutterResult([String: Any]())
          }
          return
        }

        let serialized = values.reduce(into: [String: Any]()) { partialResult, element in
          let (pattern, value) = element
          partialResult[pattern.rawValue] = self.serializeDetectedValue(value)
        }
        DispatchQueue.main.async {
          flutterResult(serialized)
        }
      }
    }
  }

  private func detectClipboardValuesInItems(arguments: Any?, flutterResult: @escaping FlutterResult) {
    guard #available(iOS 14.0, *) else {
      flutterResult(FlutterError(code: "unsupported", message: "UIPasteboard.detectValues requires iOS 14 or newer.", details: nil))
      return
    }

    let args = arguments as? [String: Any]
    let patternNames = args?["patterns"] as? [String]
    let resolvedPatterns = resolveDetectionPatterns(from: patternNames)

    if resolvedPatterns.isEmpty {
      flutterResult([[String: Any]]())
      return
    }

    let rawIndexes = parseItemIndexes(from: args?["itemIndexes"])
    if let rawIndexes, rawIndexes.isEmpty {
      flutterResult([[String: Any]]())
      return
    }

    let indexSet = resolveIndexSet(from: rawIndexes)

    UIPasteboard.general.detectValues(for: resolvedPatterns, inItemSet: indexSet) { outcome in
      switch outcome {
      case .failure(let error):
        DispatchQueue.main.async {
          flutterResult(FlutterError(code: "value_detection_failed", message: error.localizedDescription, details: nil))
        }
      case .success(let valueResults):
        let serialized = valueResults.map { dictionary -> [String: Any] in
          dictionary.reduce(into: [String: Any]()) { partialResult, element in
            let (pattern, value) = element
            partialResult[pattern.rawValue] = self.serializeDetectedValue(value)
          }
        }
        DispatchQueue.main.async {
          flutterResult(serialized)
        }
      }
    }
  }

  @available(iOS 14.0, *)
  private func resolveDetectionPatterns(from rawNames: [String]?) -> Set<UIPasteboard.DetectionPattern> {
    let defaultPatternNames = [
      UIPasteboard.DetectionPattern.probableWebURL.rawValue,
      UIPasteboard.DetectionPattern.number.rawValue,
      UIPasteboard.DetectionPattern.probableWebSearch.rawValue,
    ]

    let names = rawNames?.filter { !$0.isEmpty } ?? defaultPatternNames
    let patterns = names.compactMap { UIPasteboard.DetectionPattern(rawValue: $0) }
    return Set(patterns)
  }

  @available(iOS 14.0, *)
  private func parseItemIndexes(from rawValue: Any?) -> [Int]? {
    guard let rawArray = rawValue as? [Any] else {
      return nil
    }

    var indexes: [Int] = []
    indexes.reserveCapacity(rawArray.count)
    for element in rawArray {
      if let intValue = element as? Int {
        indexes.append(intValue)
      } else if let number = element as? NSNumber {
        indexes.append(number.intValue)
      }
    }
    return indexes
  }

  @available(iOS 14.0, *)
  private func resolveIndexSet(from indexes: [Int]?) -> IndexSet? {
    guard let indexes else {
      return nil
    }

    var indexSet = IndexSet()
    for index in indexes where index >= 0 {
      indexSet.insert(index)
    }
    return indexSet
  }

  @available(iOS 14.0, *)
  private func serializeDetectedValue(_ value: Any) -> Any {
    if value is NSNull {
      return NSNull()
    }

    if let boolValue = value as? Bool {
      return boolValue
    }

    if let string = value as? String {
      return string
    }

    if let number = value as? NSNumber {
      return number
    }

    if let url = value as? URL {
      return url.absoluteString
    }

    if let date = value as? Date {
      return iso8601DateFormatter.string(from: date)
    }

    if let data = value as? Data {
      return data.base64EncodedString()
    }

    if let attributed = value as? NSAttributedString {
      return attributed.string
    }

    if let array = value as? [Any] {
      return array.map { serializeDetectedValue($0) }
    }

    if let set = value as? Set<AnyHashable> {
      return set.map { serializeDetectedValue($0) }
    }

    if let nsSet = value as? NSSet {
      return nsSet.allObjects.map { serializeDetectedValue($0) }
    }

    if let dictionary = value as? [AnyHashable: Any] {
      var serialized: [String: Any] = [:]
      serialized.reserveCapacity(dictionary.count)
      for (key, entryValue) in dictionary {
        serialized[String(describing: key)] = serializeDetectedValue(entryValue)
      }
      return serialized
    }

    if let nsObject = value as? NSObject {
      return nsObject.description
    }

    return String(describing: value)
  }

  @available(iOS 14.0, *)
  private var iso8601DateFormatter: ISO8601DateFormatter {
    if let existing = _iso8601Formatter {
      return existing
    }
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    _iso8601Formatter = formatter
    return formatter
  }

  private var _iso8601Formatter: ISO8601DateFormatter?
}
