import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ClaudeService {
  static const _keyApiKey = 'claude_api_key';
  static const _apiUrl = 'https://api.anthropic.com/v1/messages';
  static const _model = 'claude-sonnet-4-6';

  final _storage = const FlutterSecureStorage();

  Future<String?> getApiKey() => _storage.read(key: _keyApiKey);
  Future<void> saveApiKey(String key) => _storage.write(key: _keyApiKey, value: key);
  Future<void> clearApiKey() => _storage.delete(key: _keyApiKey);

  Future<bool> get hasApiKey async {
    final key = await getApiKey();
    return key != null && key.isNotEmpty;
  }

  Future<String> sendMessage({
    required String userMessage,
    required List<Map<String, String>> history,
    required String systemPrompt,
  }) async {
    final apiKey = await getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      return '__NO_KEY__';
    }

    final messages = [
      ...history,
      {'role': 'user', 'content': userMessage},
    ];

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': _model,
          'max_tokens': 1024,
          'system': systemPrompt,
          'messages': messages,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['content'][0]['text'] as String;
      } else if (response.statusCode == 401) {
        return '__INVALID_KEY__';
      } else {
        return 'Sorry, I encountered an error (${response.statusCode}). Please try again.';
      }
    } catch (e) {
      return 'Connection error. Please check your internet connection.';
    }
  }

  String buildSystemPrompt({
    required double totalIncome,
    required double totalExpense,
    required double balance,
    required Map<String, double> categories,
    required String spenderType,
    required int healthScore,
  }) {
    final topCats = (categories.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)))
        .take(3)
        .map((e) => '${e.key}: RM${e.value.toStringAsFixed(0)}')
        .join(', ');

    return '''You are FinGuard AI, a friendly and intelligent personal financial assistant for a Malaysian user.

User's Financial Summary:
- Monthly Income: RM${totalIncome.toStringAsFixed(2)}
- Monthly Expenses: RM${totalExpense.toStringAsFixed(2)}
- Current Balance: RM${balance.toStringAsFixed(2)}
- Spending Profile: $spenderType
- Financial Health Score: $healthScore/100
- Top Spending: $topCats

Guidelines:
- Be conversational, friendly, and encouraging
- Keep responses concise (2-4 sentences) unless detailed analysis is requested
- Use Malaysian Ringgit (RM) for all currency mentions
- Give specific, actionable advice based on the user's actual numbers
- If asked about topics unrelated to finance, politely redirect to financial topics
- Celebrate good financial habits when you see them''';
  }
}
