import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:assistant/providers/chat_provider.dart';

class ClearButton extends StatelessWidget {
  const new({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          Provider.of<ChatProvider>(context, listen: false).clearMessages();
        },
      ),
    );
  }
}

