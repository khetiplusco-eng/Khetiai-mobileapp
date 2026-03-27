import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isStreaming = false;

  final List<String> _quickPrompts = [
    '🌱 Best crop for this season?',
    '💧 Irrigation advice',
    '🐛 Pest control tips',
    '💊 Fertilizer schedule',
    '🌦️ Weather impact on crops',
    '💰 Government schemes for farmers',
  ];

  @override
  void initState() {
    super.initState();
    _addGreeting();
  }

  void _addGreeting() {
    _messages.add(_ChatMessage(
      text:
          'Namaste! 🙏 I\'m **AgriIntel**, your AI farming assistant for Indian agriculture.\n\nI can help you with:\n• Crop selection & planting advice\n• Disease & pest identification\n• Fertilizer & irrigation guidance\n• Market prices & government schemes\n• Loan eligibility\n\nWhat would you like to know today?',
      isUser: false,
    ));
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isStreaming) return;
    _controller.clear();

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _messages.add(_ChatMessage(text: '', isUser: false, isStreaming: true));
      _isStreaming = true;
    });

    _scrollToBottom();

    try {
      await for (final chunk in ApiService.chatStream(text)) {
        if (!mounted) break;
        setState(() {
          _messages.last.text += chunk;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.last.text =
              'Sorry, I encountered an error. Please check your connection and try again.';
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
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AgriIntel AI',
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.primary),
            onPressed: () {
              setState(() {
                _messages.clear();
                _addGreeting();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, i) => _buildMessage(_messages[i]),
            ),
          ),
          // Quick prompts
          if (_messages.length <= 1)
            _buildQuickPrompts(),
          // Input
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildMessage(_ChatMessage msg) {
    final isUser = msg.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.primaryContainer,
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(Icons.smart_toy_rounded,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? AppTheme.primary : AppTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomRight: isUser
                      ? const Radius.circular(4)
                      : const Radius.circular(20),
                  bottomLeft: isUser
                      ? const Radius.circular(20)
                      : const Radius.circular(4),
                ),
              ),
              child: msg.isStreaming && msg.text.isEmpty
                  ? _buildTypingIndicator()
                  : _buildMarkdownText(msg.text, isUser),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(Icons.person_rounded,
                  color: AppTheme.primary, size: 18),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMarkdownText(String text, bool isUser) {
    // Simple markdown-like rendering
    final lines = text.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        if (line.startsWith('## ')) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4, top: 8),
            child: Text(
              line.substring(3),
              style: GoogleFonts.manrope(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isUser ? Colors.white : AppTheme.primary,
              ),
            ),
          );
        } else if (line.startsWith('### ')) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 2, top: 6),
            child: Text(
              line.substring(4),
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isUser ? Colors.white70 : AppTheme.primaryContainer,
              ),
            ),
          );
        } else if (line.startsWith('• ') || line.startsWith('- ')) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 2, left: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: TextStyle(
                    color: isUser ? Colors.white70 : AppTheme.primary,
                    fontSize: 14,
                  ),
                ),
                Expanded(
                  child: Text(
                    line.substring(2),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: isUser ? Colors.white : AppTheme.onSurface,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        } else if (line.startsWith('**') && line.endsWith('**')) {
          return Text(
            line.replaceAll('**', ''),
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isUser ? Colors.white : AppTheme.onSurface,
              height: 1.5,
            ),
          );
        } else {
          // Handle inline bold
          final boldParts = line.split('**');
          if (boldParts.length > 1) {
            return RichText(
              text: TextSpan(
                children: boldParts.asMap().entries.map((e) {
                  return TextSpan(
                    text: e.value,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: e.key.isOdd
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: isUser ? Colors.white : AppTheme.onSurface,
                      height: 1.5,
                    ),
                  );
                }).toList(),
              ),
            );
          }
          return line.isEmpty
              ? const SizedBox(height: 4)
              : Text(
                  line,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: isUser ? Colors.white : AppTheme.onSurface,
                    height: 1.5,
                  ),
                );
        }
      }).toList(),
    );
  }

  Widget _buildTypingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 400 + i * 150),
          curve: Curves.easeInOut,
          width: 7,
          height: 7,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  Widget _buildQuickPrompts() {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _quickPrompts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          return GestureDetector(
            onTap: () => _sendMessage(_quickPrompts[i].substring(2).trim()),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: AppTheme.outlineVariant, width: 1),
              ),
              child: Text(
                _quickPrompts[i],
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
    return Container(
      padding: EdgeInsets.fromLTRB(
        16, 12, 16, 12 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppTheme.outlineVariant.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              maxLines: 4,
              minLines: 1,
              onSubmitted: _sendMessage,
              decoration: InputDecoration(
                hintText: 'Ask about your crops...',
                hintStyle: GoogleFonts.inter(
                  color: AppTheme.onSurfaceVariant,
                  fontSize: 14,
                ),
                filled: true,
                fillColor: AppTheme.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18, vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _sendMessage(_controller.text),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _isStreaming ? AppTheme.surfaceContainerHigh : AppTheme.primary,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                _isStreaming ? Icons.stop_rounded : Icons.send_rounded,
                color: _isStreaming ? AppTheme.primary : Colors.white,
                size: 22,
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
