import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../utils/rich_text_renderer.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isStreaming = false;

  // Conversation context for multi-turn
  final List<String> _contextHistory = [];

  final List<_QuickPrompt> _quickPrompts = [
    _QuickPrompt('🌱', 'Best crop for Kharif?', 'What is the best crop to grow in Kharif season in Akola, Maharashtra with black cotton soil?'),
    _QuickPrompt('💧', 'Irrigation advice', 'Give irrigation schedule for cotton crop in Akola, Maharashtra. Include water quantity and timing.'),
    _QuickPrompt('🐛', 'Pest control', 'What are the common pests in cotton and soybean in Vidarbha? Give IPM strategy with chemical and organic options.'),
    _QuickPrompt('💊', 'Fertilizer schedule', 'Give a complete fertilizer schedule for cotton crop in black cotton soil, Maharashtra. Include costs in ₹/acre.'),
    _QuickPrompt('🌦️', 'Weather impact', 'How does excess/deficit rainfall impact cotton yield in Vidarbha? What should I do?'),
    _QuickPrompt('💰', 'Government schemes', 'What are the best government schemes for small farmers in Maharashtra? Include PM-KISAN, KCC, crop insurance.'),
  ];

  @override
  void initState() {
    super.initState();
    _addGreeting();
  }

  void _addGreeting() {
    _messages.add(_ChatMessage(
      text:
          'Namaste! 🙏 I\'m **AgriIntel AI**, your precision agriculture advisor for Indian farming.\n\n'
          'I can help with:\n'
          '- Crop selection with profit calculations\n'
          '- Disease & pest identification\n'
          '- Fertilizer & irrigation scheduling\n'
          '- Market prices & sell/hold decisions\n'
          '- Government schemes & loan eligibility\n\n'
          'Ask me anything about your farm!',
      isUser: false,
    ));
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isStreaming) return;
    _controller.clear();

    final userMsg = text.trim();

    setState(() {
      _messages.add(_ChatMessage(text: userMsg, isUser: true));
      _messages.add(_ChatMessage(text: '', isUser: false, isStreaming: true));
      _isStreaming = true;
    });

    _scrollToBottom();

    // Build context from last 3 exchanges
    final context = _contextHistory.length > 6
        ? _contextHistory.sublist(_contextHistory.length - 6).join('\n')
        : _contextHistory.join('\n');

    try {
      await for (final chunk in ApiService.chatStream(
        userMsg,
        context: context.isNotEmpty ? context : null,
        district: 'Akola',
        state: 'Maharashtra',
        country: 'India',
      )) {
        if (!mounted) break;
        setState(() {
          _messages.last.text += chunk;
        });
        _scrollToBottom();
      }

      // Add to context history
      _contextHistory.add('User: $userMsg');
      _contextHistory.add('AI: ${_messages.last.text}');
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.last.text =
              'Sorry, I couldn\'t connect to the server. Please check your connection and try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isStreaming = false;
          _messages.last.isStreaming = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              itemCount: _messages.length,
              itemBuilder: (context, i) => _buildMessage(_messages[i]),
            ),
          ),
          if (_messages.length <= 1) _buildQuickPrompts(),
          _buildInput(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 16,
      title: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primary, AppTheme.primaryContainer],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.smart_toy_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AgriIntel AI',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF22c55e),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Text(
                    'Agricultural Expert',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.refresh_rounded,
              color: AppTheme.onSurfaceVariant, size: 20),
          onPressed: () {
            setState(() {
              _messages.clear();
              _contextHistory.clear();
              _addGreeting();
            });
          },
          tooltip: 'Clear chat',
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildMessage(_ChatMessage msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!msg.isUser) ...[
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primaryContainer],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.smart_toy_rounded,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 14,
                vertical: msg.isStreaming && msg.text.isEmpty ? 12 : 12,
              ),
              decoration: BoxDecoration(
                color: msg.isUser
                    ? AppTheme.primary
                    : Colors.white,
                borderRadius: BorderRadius.circular(18).copyWith(
                  bottomRight: msg.isUser
                      ? const Radius.circular(4)
                      : const Radius.circular(18),
                  bottomLeft: msg.isUser
                      ? const Radius.circular(18)
                      : const Radius.circular(4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: msg.isStreaming && msg.text.isEmpty
                  ? _buildTypingIndicator()
                  : RichTextRenderer(
                      text: msg.text,
                      isUser: msg.isUser,
                      baseFontSize: 14,
                    ),
            ),
          ),
          if (msg.isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.person_rounded,
                  color: AppTheme.primary, size: 18),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return SizedBox(
      width: 42,
      height: 18,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (i) {
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.3, end: 1.0),
            duration: Duration(milliseconds: 500 + i * 150),
            builder: (_, val, __) => Container(
              width: 7,
              height: 7,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(val),
                shape: BoxShape.circle,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildQuickPrompts() {
    return Container(
      height: 48,
      margin: const EdgeInsets.only(bottom: 4),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _quickPrompts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final p = _quickPrompts[i];
          return GestureDetector(
            onTap: () => _sendMessage(p.fullPrompt),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
                border:
                    Border.all(color: AppTheme.outlineVariant, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                '${p.emoji} ${p.label}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.onSurface,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInput() {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(12, 10, 12, 10 + bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppTheme.outlineVariant.withOpacity(0.4),
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _controller,
                maxLines: 4,
                minLines: 1,
                onSubmitted: (v) => _sendMessage(v),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'Ask about your crops, soil, market...',
                  hintStyle: GoogleFonts.inter(
                    color: AppTheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 11,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              if (!_isStreaming) _sendMessage(_controller.text);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: _isStreaming
                    ? null
                    : const LinearGradient(
                        colors: [Color(0xFF2d5a27), Color(0xFF154212)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                color: _isStreaming ? AppTheme.surfaceContainerHigh : null,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _isStreaming
                    ? Icons.hourglass_top_rounded
                    : Icons.send_rounded,
                color: _isStreaming ? AppTheme.onSurfaceVariant : Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class _ChatMessage {
  String text;
  final bool isUser;
  bool isStreaming;

  _ChatMessage({
    required this.text,
    required this.isUser,
    this.isStreaming = false,
  });
}

class _QuickPrompt {
  final String emoji;
  final String label;
  final String fullPrompt;
  const _QuickPrompt(this.emoji, this.label, this.fullPrompt);
}