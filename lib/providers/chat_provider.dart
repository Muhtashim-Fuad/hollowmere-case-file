import 'package:assistant/services/chat_service.dart';
import 'package:flutter/material.dart';

class ChatProvider extends ChangeNotifier {
  final List<String> _messages = [];
  
  List<String> get messages => _messages;
  bool isGeneratingAnswer = false;

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }


  void onSubmit(String message) async {
    if (message.trim().isEmpty) return;
    String userMessage = message.trim();
    isGeneratingAnswer = true;
    _messages.add(userMessage);
    notifyListeners();

    String response = await ChatService.ask(_messages);
    //await Future.delayed(const Duration(seconds: 1)); // Simulate a delay for the response
    //String response = "This is a simulated response from the chat assistant. You can replace this with the actual response from the Generator.generate method.";

    _messages.add(response);
    isGeneratingAnswer = false;
    notifyListeners();
  }
 }