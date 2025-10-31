import 'dart:async';

import 'package:clipboard_detect/clipboard_detect.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const Set<String> _allowedUrlHosts = {'example.com'};

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _clipboardDetectPlugin = ClipboardDetect();
  List<String> _detectedPatterns = const [];
  String? _detectionError;
  String? _lastClipboardUrl;
  bool? _clipboardUrlAllowed;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await _clipboardDetectPlugin.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Future<void> _detectClipboardPatterns() async {
    try {
      final matches = await _clipboardDetectPlugin.detectClipboardPatterns();
      final hasProbableUrl = matches.contains('probableWebURL');
      String? clipboardUrl;
      var urlAllowed = false;

      if (hasProbableUrl) {
        final data = await Clipboard.getData('text/plain');
        final value = data?.text?.trim();

        if (value != null && value.isNotEmpty) {
          clipboardUrl = value;
          final resolved = _resolveUrl(value);
          if (resolved != null) {
            urlAllowed = _allowedUrlHosts.contains(resolved.host.toLowerCase());
          }
        }
      }

      setState(() {
        _detectedPatterns = matches;
        _detectionError = null;
        _lastClipboardUrl = clipboardUrl;
        _clipboardUrlAllowed = hasProbableUrl ? urlAllowed : null;
      });
    } on PlatformException catch (error) {
      setState(() {
        _detectedPatterns = const [];
        _detectionError = error.message ?? error.code;
        _lastClipboardUrl = null;
        _clipboardUrlAllowed = null;
      });
    }
  }

  Uri? _resolveUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final direct = Uri.tryParse(trimmed);
    if (direct != null && direct.hasScheme && direct.host.isNotEmpty) {
      return direct;
    }

    final withScheme = Uri.tryParse('https://$trimmed');
    if (withScheme != null && withScheme.host.isNotEmpty) {
      return withScheme;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text('Running on: $_platformVersion'),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _detectClipboardPatterns,
                  child: const Text('Detect clipboard patterns'),
                ),
                const SizedBox(height: 16),
                if (_detectionError != null)
                  Text(
                    'Detection error: $_detectionError',
                    style: const TextStyle(color: Colors.redAccent),
                  )
                else
                  Text(
                    _detectedPatterns.isEmpty
                        ? 'No patterns detected.'
                        : 'Detected patterns: ${_detectedPatterns.join(', ')}',
                  ),
                if (_lastClipboardUrl != null) ...<Widget>[
                  const SizedBox(height: 12),
                  const Text('Clipboard URL candidate:'),
                  SelectableText(_lastClipboardUrl!),
                ],
                if (_clipboardUrlAllowed != null) ...<Widget>[
                  const SizedBox(height: 8),
                  Text(
                    _clipboardUrlAllowed!
                        ? 'URL host matches allowed domains: ${_allowedUrlHosts.join(', ')}'
                        : 'URL host outside allowed domains: ${_allowedUrlHosts.join(', ')}',
                    style: TextStyle(
                      color: _clipboardUrlAllowed!
                          ? Colors.green
                          : Colors.orangeAccent,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
