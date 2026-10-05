import 'dart:convert';
import 'package:assistant/repository.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class ChatService {
  static const String _baseUrl = 'http://localhost:11434';
  static const String _model = 'gemma4:e4b';

  static Future<String> ask(List<String> messages) async {
    // Treat the last message as the user's, and alternate roles going backwards.
    final chatMessages = [
      {'role': 'system', 'content': buildSystemPrompt(messages.last, Repository.chunks)},
      for (int i = 0; i < messages.length; i++)
      {
        'role': (messages.length - 1 - i) % 2 == 0 ? 'user' : 'assistant',
        'content': messages[i],
      },
    ];

    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/chat'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'model': _model,
              'messages': chatMessages,
              'stream': false,
            }),
          )
          .timeout(const Duration(minutes: 2));

      if (response.statusCode != 200) {
        return 'Error ${response.statusCode}: ${response.body}';
      }

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return (data['message']['content'] as String).trim();
    } on ClientException {
      return 'Failed to connect to the assistant. Please ensure that Ollama in running!';
    }
  }

  static String buildSystemPrompt(String question, List<String> chunks, {int topK = 5}) {
    final words = question
        .toLowerCase()
        .split(RegExp(r'\W+'))
        .where((w) => w.length > 2)
        .toSet();

    final scored = [
      for (final c in chunks)
        MapEntry(c, words.where(c.toLowerCase().contains).length),
    ]..sort((a, b) => b.value.compareTo(a.value));

    final context = scored
        .take(topK)
        .where((e) => e.value > 0)
        .map((e) => e.key)
        .join('\n\n');

    return 'Answer from the context in full sentences. Reply normally to greetings and pleasantries (hi, bye, thanks). Otherwise say there is no relevant context.\n\nContext:\n$context';
  }
}
