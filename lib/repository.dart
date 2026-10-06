import 'dart:convert';
import 'dart:io';
import 'package:assistant/constants.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class Repository {
  static List<String> _chunks = [];
  static List<List<double>> _vectors = [];
  static List<String> get chunks => _chunks;

  /// Call once at app start (e.g. in main() before runApp).
  static Future<void> init() async {
    final chunks = await chunkFiles();
    final dir = await getApplicationSupportDirectory();
    final file = File('${dir.path}/vectors.json');

    // Reuse saved vectors if the chunks haven't changed.
    if (await file.exists()) {
      final data = jsonDecode(await file.readAsString());
      if (jsonEncode(data['chunks']) == jsonEncode(chunks)) {
        _vectors = (data['vectors'] as List)
            .map((v) => List<double>.from(v))
            .toList();
        return;
      }
    }

    // Otherwise embed everything (in batches) and save.
    final vectors = <List<double>>[];
    for (var i = 0; i < chunks.length; i += 16) {
      final end = (i + 16 > chunks.length) ? chunks.length : i + 16;
      vectors.addAll(await _embed(chunks.sublist(i, end)));
    }
    _vectors = vectors;
    await file.writeAsString(jsonEncode({'chunks': chunks, 'vectors': vectors}));
  }

  /// Returns the [topK] chunks most similar to [query].
  static Future<List<String>> search(String query, {int topK = 3}) async {
    final q = (await _embed([query])).first;

    final scores = <int, double>{};
    for (var i = 0; i < _vectors.length; i++) {
      scores[i] = _dot(q, _vectors[i]);
    }

    final best = scores.keys.toList()
      ..sort((a, b) => scores[b]!.compareTo(scores[a]!));
    return best.take(topK).map((i) => _chunks[i]).toList();
  }

  static Future<List<String>> chunkFiles() async {
    final chunks = <String>[];
    for (final path in Constants.contextPaths) {
      final text = await rootBundle.loadString(path);
      chunks.addAll(
        text
            .split(RegExp(r'^## ', multiLine: true))
            .map((c) => c.trim())
            .where((c) => c.isNotEmpty),
      );
    }
    _chunks = chunks;
    return chunks;
  }

  static Future<List<List<double>>> _embed(List<String> texts) async {
    final res = await http.post(
      Uri.parse('${Constants.baseURL}embed'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'model': Constants.embeddingLM, 'input': texts}),
    );
    final data = jsonDecode(res.body);
    return (data['embeddings'] as List)
        .map((e) => List<double>.from(e))
        .toList();
  }

  // Ollama returns normalized vectors, so a dot product equals cosine similarity.
  static double _dot(List<double> a, List<double> b) {
    var sum = 0.0;
    for (var i = 0; i < a.length; i++) {
      sum += a[i] * b[i];
    }
    return sum;
  }
}