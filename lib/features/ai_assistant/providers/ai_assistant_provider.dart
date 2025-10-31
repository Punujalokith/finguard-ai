import 'package:flutter/material.dart';
import '../../../core/services/claude_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  ChatMessage({required this.text, required this.isUser, DateTime? timestamp})
      : timestamp = timestamp ?? DateTime.now();
}

class AiAssistantProvider extends ChangeNotifier {
  final ClaudeService _claude = ClaudeService();
  final List<ChatMessage> _messages = [];
  final List<Map<String, String>> _history = [];
  bool _isTyping = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isTyping => _isTyping;

  AiAssistantProvider() {
    _messages.add(ChatMessage(
      text: "Hello! I'm your AI Financial Assistant. I can help you with budgeting, savings tips, financial planning, and answer any questions about your finances. How can I assist you today?",
      isUser: false,
    ));
  }

  Future<bool> get hasKey => _claude.hasApiKey;
  Future<void> saveApiKey(String key) => _claude.saveApiKey(key);
  Future<String?> getApiKey() => _claude.getApiKey();

  Future<void> sendMessage({
    required String message,
    required double totalIncome,
    required double totalExpense,
    required double balance,
    required Map<String, double> categories,
    required String spenderType,
    required int healthScore,
  }) async {
    _messages.add(ChatMessage(text: message, isUser: true));
    _isTyping = true;
    notifyListeners();

    final systemPrompt = _claude.buildSystemPrompt(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      balance: balance,
      categories: categories,
      spenderType: spenderType,
      healthScore: healthScore,
    );

    final reply = await _claude.sendMessage(
      userMessage: message,
      history: List.from(_history),
      systemPrompt: systemPrompt,
    );

    _isTyping = false;

    if (reply == '__NO_KEY__') {
      _messages.add(ChatMessage(
        text: '🔑 No API key set. Please go to Profile → AI Settings to add your Claude API key.',
        isUser: false,
      ));
    } else if (reply == '__INVALID_KEY__') {
      _messages.add(ChatMessage(
        text: '❌ Invalid API key. Please check your Claude API key in Profile → AI Settings.',
        isUser: false,
      ));
    } else {
      _history.add({'role': 'user', 'content': message});
      _history.add({'role': 'assistant', 'content': reply});
      if (_history.length > 20) {
        _history.removeRange(0, 2);
      }
      _messages.add(ChatMessage(text: reply, isUser: false));
    }
    notifyListeners();
  }

  void clearChat() {
    _messages.clear();
    _history.clear();
    _messages.add(ChatMessage(
      text: "Chat cleared. How can I help you with your finances today?",
      isUser: false,
    ));
    notifyListeners();
  }
}
