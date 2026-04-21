import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../models/vaccine_model.dart';
import '../services/specialized_chat_service.dart';
import '../widgets/chat_widgets.dart';

class SpecializedChatScreen extends StatefulWidget {
  final SpecializedChatService chatService;
  final String title;
  final String emoji;
  final Color accentColor;

  const SpecializedChatScreen({
    super.key,
    required this.chatService,
    required this.title,
    required this.emoji,
    this.accentColor = AppTheme.primaryColor,
  });

  @override
  State<SpecializedChatScreen> createState() => _SpecializedChatScreenState();
}

class _SpecializedChatScreenState extends State<SpecializedChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.chatService.initialize();
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildChatArea()),
          _buildInputArea(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [widget.accentColor, widget.accentColor.withOpacity(0.8)],
          ),
        ),
      ),
      title: Row(
        children: [
          Text(widget.emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            if (value == 'clear') widget.chatService.clearChat();
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'clear',
              child: Row(
                children: [
                  Icon(Icons.refresh, size: 20),
                  SizedBox(width: 8),
                  Text('مسح المحادثة', style: TextStyle(fontFamily: 'Tajawal')),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChatArea() {
    return ListenableBuilder(
      listenable: widget.chatService,
      builder: (context, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

        final messages = widget.chatService.messages;
        final itemCount = messages.length + (_isTyping ? 1 : 0);

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          itemCount: itemCount,
          itemBuilder: (context, index) {
            if (_isTyping && index == itemCount - 1) {
              return const TypingIndicator();
            }
            final msg = messages[index];
            return _buildMessageBubble(msg, index, messages);
          },
        );
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, int index, List<ChatMessage> messages) {
    final isBot = msg.isBot;
    final isLastBot = isBot && index == (messages.length - 1);

    return Padding(
      padding: EdgeInsets.only(
        bottom: 10,
        left: isBot ? 0 : 40,
        right: isBot ? 40 : 0,
      ),
      child: Column(
        crossAxisAlignment: isBot ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          if (isBot && (index == 0 || !messages[index - 1].isBot))
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: widget.accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Center(child: Text(widget.emoji, style: const TextStyle(fontSize: 14))),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 11,
                      color: widget.accentColor.withOpacity(0.6),
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isBot ? Colors.white : widget.accentColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isBot ? 4 : 18),
                bottomRight: Radius.circular(isBot ? 18 : 4),
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2)),
              ],
            ),
            child: SelectableText(
              msg.text,
              style: TextStyle(
                fontSize: 15,
                height: 1.7,
                color: isBot ? Colors.black87 : Colors.white,
                fontFamily: 'Tajawal',
              ),
            ),
          ).animate().fadeIn(duration: 250.ms).slideX(begin: isBot ? -0.08 : 0.08, end: 0),
          if (isBot && isLastBot && msg.quickReplies != null && msg.quickReplies!.isNotEmpty)
            _buildQuickReplies(msg.quickReplies!),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _formatTime(msg.timestamp),
              style: TextStyle(fontSize: 10, color: Colors.grey.shade400, fontFamily: 'Tajawal'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickReplies(List<QuickReply> replies) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: replies.asMap().entries.map((entry) {
          final index = entry.key;
          final reply = entry.value;
          return GestureDetector(
            onTap: () => _sendMessage(reply.text),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: widget.accentColor.withOpacity(0.06),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: widget.accentColor.withOpacity(0.25)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(reply.emoji, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(
                    reply.text,
                    style: TextStyle(
                      fontSize: 13,
                      color: widget.accentColor,
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: Duration(milliseconds: 100 + index * 80)).scale(
                begin: const Offset(0.9, 0.9),
                end: const Offset(1, 1),
                curve: Curves.easeOutBack,
              );
        }).toList(),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, -3))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: TextField(
                  controller: _controller,
                  textDirection: TextDirection.rtl,
                  maxLines: 3,
                  minLines: 1,
                  decoration: InputDecoration(
                    hintText: 'اكتب سؤالك...',
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontFamily: 'Tajawal', fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  ),
                  style: const TextStyle(fontFamily: 'Tajawal', fontSize: 15),
                  onSubmitted: (_) => _sendMessageFromInput(),
                  textInputAction: TextInputAction.send,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [widget.accentColor, widget.accentColor.withOpacity(0.8)]),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: widget.accentColor.withOpacity(0.3), blurRadius: 10)],
              ),
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
                onPressed: _sendMessageFromInput,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage(String text) {
    setState(() => _isTyping = true);
    widget.chatService.sendMessage(text);
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _isTyping = false);
    });
  }

  void _sendMessageFromInput() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    _sendMessage(text);
  }

  String _formatTime(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
