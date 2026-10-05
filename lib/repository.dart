import 'package:flutter/services.dart';

class Repository {
  static List<String> get _contextPaths => [
    'assets/hollowmere_case_file.md',
  ];

  static List<String> _chunks = [];
  static List<String> get chunks => _chunks;

  static Future<List<String>> chunkFiles() async {
    final chunks = <String>[];
    for (final path in _contextPaths) {
      final text = await rootBundle.loadString(path);
      chunks.addAll(
        text.split(RegExp(r'^## ', multiLine: true)).map((c) => c.trim()).where((c) => c.isNotEmpty),
      );
    }

    Repository._chunks = chunks;
    return chunks;
  }
}