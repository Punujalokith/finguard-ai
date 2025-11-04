import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../providers/ai_assistant_provider.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../../core/theme/app_theme.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _speechAvailable = false;

  static const _suggestions = [
    'How can I save more money?',
    'Analyze my spending habits',
    'Investment tips for beginners',
    'How to create a budget?',
    "What's my financial health?",
  ];

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize();
    if (mounted) setState(() {});
  }

  void _startListening() async {
    if (!_speechAvailable) return;
    await _speech.listen(
      onResult: (r) {
        setState(() => _controller.text = r.recognizedWords);
        if (r.finalResult) _stopListening();
      },
      listenOptions: stt.SpeechListenOptions(partialResults: true),
    );
    setState(() => _isListening = true);
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
  }

  void _send(BuildContext context) {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    setState(() {});
    _doSend(context, text);
  }

  void _doSend(BuildContext context, String text) {
    final tp = context.read<TransactionProvider>();
    context.read<AiAssistantProvider>().sendMessage(
      message: text,
      totalIncome: tp.totalIncome,
      totalExpense: tp.totalExpense,
      balance: tp.balance,
      categories: tp.expenseByCategory,
      spenderType: tp.spenderType,
      healthScore: tp.healthScore,
    );
    Future.delayed(const Duration(milliseconds: 150), _scrollToBottom);
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _showApiKeyDialog(BuildContext context) {
    final ai = context.read<AiAssistantProvider>();
    final keyCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Claude API Key'),
        // SingleChildScrollView ensures the field stays visible when keyboard opens
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Enter your Anthropic API key to enable AI chat.',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
              const SizedBox(height: 12),
              TextField(
                controller: keyCtrl,
                obscureText: true,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'sk-ant-api03-...',
                  prefixIcon: const Icon(Icons.key_rounded, size: 20),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 8),
              Text('Get your key at console.anthropic.com',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (keyCtrl.text.trim().isNotEmpty) {
                await ai.saveApiKey(keyCtrl.text.trim());
              }
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(80, 40),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _speech.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Consumer<AiAssistantProvider>(
              builder: (_, ai, __) {
                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                return Column(
                  children: [
                    // API Key missing banner
                    FutureBuilder<bool>(
                      future: ai.hasKey,
                      builder: (_, snap) {
                        if (snap.data == true) return const SizedBox.shrink();
                        return _buildNoKeyBanner(context);
                      },
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        itemCount: ai.messages.length + (ai.isTyping ? 1 : 0),
                        itemBuilder: (_, i) {
                          if (i == ai.messages.length) return const _TypingBubble();
                          return _MessageBubble(msg: ai.messages[i]);
                        },
                      ),
                    ),
                    if (ai.messages.length <= 1) _buildSuggestions(context),
                    _buildInput(context, ai),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6C5CE7), Color(0xFF8B7FF5)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 12, 20, 20),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Financial Assistant',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                Text('Powered by Claude AI',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.key_rounded, color: Colors.white70, size: 20),
            onPressed: () => _showApiKeyDialog(context),
            tooltip: 'API Key',
          ),
          Consumer<AiAssistantProvider>(
            builder: (_, ai, __) => IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.white70, size: 20),
              onPressed: ai.clearChat,
              tooltip: 'Clear chat',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoKeyBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => _showApiKeyDialog(context),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.warning.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.warning.withAlpha(80)),
        ),
        child: Row(
          children: [
            const Icon(Icons.key_rounded, color: AppColors.warning, size: 20),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'No API key set. Tap here to add your Claude API key to enable AI chat.',
                style: TextStyle(fontSize: 13, color: AppColors.warning),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.warning, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestions(BuildContext context) {
    return Container(
      height: 46,
      margin: const EdgeInsets.only(top: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _suggestions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => _doSend(context, _suggestions[i]),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withAlpha(60)),
            ),
            child: Text(_suggestions[i],
                style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500)),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(BuildContext context, AiAssistantProvider ai) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 10, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onChanged: (_) => setState(() {}),
                      onSubmitted: (_) => _send(context),
                      maxLines: 3,
                      minLines: 1,
                      decoration: const InputDecoration(
                        hintText: 'Ask about your finances...',
                        // Explicitly remove ALL borders so the theme's
                        // enabledBorder/focusedBorder don't create a second box
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        filled: false,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  if (_speechAvailable)
                    GestureDetector(
                      onTap: _isListening ? _stopListening : _startListening,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                          color: _isListening ? AppColors.error : Colors.grey,
                          size: 22,
                        ),
                      ),
                    ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: (ai.isTyping || _controller.text.trim().isEmpty) ? null : () => _send(context),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 46, height: 46,
              decoration: BoxDecoration(
                gradient: (!ai.isTyping && _controller.text.trim().isNotEmpty)
                    ? const LinearGradient(
                        colors: [Color(0xFF6C5CE7), Color(0xFF8B7FF5)],
                        begin: Alignment.topLeft, end: Alignment.bottomRight)
                    : null,
                color: (ai.isTyping || _controller.text.trim().isEmpty)
                    ? Colors.grey.withAlpha(80)
                    : null,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final dynamic msg;
  const _MessageBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    final isUser = msg.isUser as bool;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32, height: 32,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6C5CE7), Color(0xFF8B7FF5)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: isUser
                    ? const LinearGradient(
                        colors: [Color(0xFF6C5CE7), Color(0xFF8B7FF5)],
                        begin: Alignment.topLeft, end: Alignment.bottomRight)
                    : null,
                color: isUser ? null : Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                border: isUser ? null : Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Text(
                msg.text as String,
                style: TextStyle(
                  fontSize: 14,
                  color: isUser ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                  height: 1.45,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 18),
            ),
          ],
        ],
      ),
    );
  }
}

class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6C5CE7), Color(0xFF8B7FF5)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18), topRight: Radius.circular(18),
                bottomLeft: Radius.circular(4), bottomRight: Radius.circular(18),
              ),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) => Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  final t = (_ctrl.value - i * 0.2).clamp(0.0, 1.0);
                  final scale = 0.6 + 0.4 * (t < 0.5 ? 2 * t : 2 * (1 - t));
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2.5),
                    width: 7 * scale,
                    height: 7 * scale,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(180),
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
