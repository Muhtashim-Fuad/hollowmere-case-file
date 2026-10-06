import 'dart:convert';
import 'package:assistant/constants.dart';
import 'package:assistant/repository.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class ChatService {
  static Future<String> ask(List<String> messages) async {
    try {
      final context = await Repository.search(messages.last, topK: 5);

      final chatMessages = [
        {'role': 'system', 'content': buildSystemPrompt(context)},
        for (int i = 0; i < messages.length; i++)
          {
            'role': (messages.length - 1 - i) % 2 == 0 ? 'user' : 'assistant',
            'content': messages[i],
          },
      ];

      final response = await http
          .post(
            Uri.parse('${Constants.baseURL}chat'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'model': Constants.textLLM,
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
      return 'Failed to connect to the assistant. Please ensure that Ollama is running!';
    }
  }

  static String buildSystemPrompt(List<String> context) {
    return 'Answer from the context in full sentences. Reply normally to greetings and pleasantries (hi, bye, thanks). Otherwise say there is no relevant context.\n\nContext:\n${context.join('\n\n')}';
  }
}
