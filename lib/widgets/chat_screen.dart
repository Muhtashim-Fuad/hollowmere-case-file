import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:assistant/providers/chat_provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children:
          [
            Flexible(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                itemCount: Provider.of<ChatProvider>(context).messages.length,
                itemBuilder: (context, index) {
                  return MessageChip(
                    alignment: index % 2 == 0 ? Alignment.centerLeft : Alignment.centerRight,
                    message: Provider.of<ChatProvider>(context).messages[index],
                  );
                },
              ),
            ),
            if (Provider.of<ChatProvider>(context).isGeneratingAnswer)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Text('AI is typing...'),
                ),
              ),
            ChatTextField(),
            SizedBox(height: 8.0),
          ],
        ),
      ),
    );
  }
}

class ChatTextField extends StatelessWidget {
  ChatTextField({
    super.key,
  });

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 20.0, right: 4.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(32.0),
        border: Border.all(
          width: 1.2,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Flexible(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                visualDensity: VisualDensity.compact,
                hintText: 'Enter your query',
                border: InputBorder.none,
              ),
              style: const TextStyle(
                fontSize: 14.0,
              ),
              onSubmitted: (value) {
                Provider.of<ChatProvider>(context, listen: false).onSubmit(value);
                _controller.clear();
              },
            ),
          ),
          SizedBox(width: 8.0),
          IconButton(
            style: IconButton.styleFrom(
              maximumSize: const Size(48.0, 48.0),
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              backgroundColor: Theme.of(context).colorScheme.primary,
              
            ),
            onPressed: 
            Provider.of<ChatProvider>(context).isGeneratingAnswer ? 
            null :
            () {
              Provider.of<ChatProvider>(context, listen: false).onSubmit(_controller.text);
              _controller.clear();
            },
            icon: Padding(
              padding: const EdgeInsets.only(left: 6.0, right: 24.0),
              child: const Icon(Icons.send),
            ),
          ),
        ],
      ),
    );
  }
}

class MessageChip extends StatelessWidget {
  const MessageChip({
    super.key,
    required this.alignment,
    required this.message,
  });

  final Alignment alignment;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            child: MarkdownBody(
              data: message,
              selectable: true,
            ),
          ),
        ),
      ),
    );
  }
}