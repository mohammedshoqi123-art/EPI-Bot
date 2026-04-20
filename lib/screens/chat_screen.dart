import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../models/vaccine_model.dart';
import '../services/chat_service.dart';
import '../widgets/chat_widgets.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  late AnimationController _fabAnimController;

  @override
  void initState() {
    super.initState();
    _fabAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatService>().initialize();
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
          _buildInfoBanner(),
          Expanded(child: _buildChatArea()),
          _buildInputArea(),
        ],
      ),
      floatingActionButton: _buildScrollFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      flexibleSpace: Container(
        decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
      ),
      title: Row(
        children: [
          // Bot avatar with pulse animation
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(seconds: 2),
            builder: (context, value, child) {
              return Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.greenAccent.withOpacity(0.3 * value),
                      blurRadius: 10 * value,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('🤖', style: TextStyle(fontSize: 24)),
                ),
              );
            },
            onEnd: () {}, // continuous pulse would need setState
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'مستشار التحصين الذكي',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                      ),
                    ).animate(onPlay: (c) => c.repeat()).fadeIn(duration: 800.ms).then().fadeOut(duration: 800.ms),
                    const SizedBox(width: 6),
                    const Text(
                      'متصل • بدون إنترنت',
                      style: TextStyle(fontSize: 11, color: Colors.greenAccent),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: _showSearchSheet,
          tooltip: 'بحث سريع',
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            switch (value) {
              case 'clear':
                _showClearConfirmation();
                break;
              case 'info':
                _showBotInfo();
                break;
            }
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
            const PopupMenuItem(
              value: 'info',
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20),
                  SizedBox(width: 8),
                  Text('عن الروبوت', style: TextStyle(fontFamily: 'Tajawal')),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentColor.withOpacity(0.08),
            AppTheme.accentColor.withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.accentColor.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          const Text('💡', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'اسألني أي سؤال عن تطعيمات طفلك — أجاوبك فوراً!',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.accentColor.withOpacity(0.8),
                fontFamily: 'Tajawal',
              ),
            ),
          ),
          GestureDetector(
            onTap: _showQuickTopics,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'مواضيع',
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.accentColor,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Tajawal',
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.3, end: 0);
  }

  Widget _buildChatArea() {
    return Consumer<ChatService>(
      builder: (context, chatService, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

        final itemCount = chatService.messages.length + (_isTyping ? 1 : 0);

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          itemCount: itemCount,
          itemBuilder: (context, index) {
            if (_isTyping && index == itemCount - 1) {
              return const TypingIndicator();
            }
            final msg = chatService.messages[index];
            return _buildMessageBubble(msg, index);
          },
        );
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, int index) {
    final isBot = msg.isBot;
    final isLastBot = isBot && index == (context.watch<ChatService>().messages.length - 1);

    return Padding(
      padding: EdgeInsets.only(
        bottom: 10,
        left: isBot ? 0 : 40,
        right: isBot ? 40 : 0,
      ),
      child: Column(
        crossAxisAlignment: isBot ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          // Avatar for bot messages
          if (isBot && (index == 0 || !context.watch<ChatService>().messages[index - 1].isBot))
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: const Center(child: Text('🤖', style: TextStyle(fontSize: 14))),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'مستشار التحصين',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.primaryColor.withOpacity(0.6),
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ],
              ),
            ),

          // Message bubble
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isBot ? Colors.white : AppTheme.primaryColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isBot ? 4 : 18),
                bottomRight: Radius.circular(isBot ? 18 : 4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
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

          // Quick replies
          if (isBot && isLastBot && msg.quickReplies != null && msg.quickReplies!.isNotEmpty)
            _buildQuickReplies(msg.quickReplies!),

          // Timestamp
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _formatTime(msg.timestamp),
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade400,
                fontFamily: 'Tajawal',
              ),
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
                color: AppTheme.primaryColor.withOpacity(0.06),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.primaryColor.withOpacity(0.25)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(reply.emoji, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(
                    reply.text,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.primaryColor,
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Mic button
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: IconButton(
                icon: const Icon(Icons.mic_none, color: AppTheme.accentColor, size: 22),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('ميزة الصوت قريباً! 🎤', style: TextStyle(fontFamily: 'Tajawal')),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),

            // Text input
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
                    hintText: 'اكتب سؤالك عن التحصين...',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontFamily: 'Tajawal',
                      fontSize: 14,
                    ),
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

            // Send button
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: _controller.text.trim().isNotEmpty
                    ? AppTheme.primaryGradient
                    : LinearGradient(colors: [Colors.grey.shade300, Colors.grey.shade300]),
                shape: BoxShape.circle,
                boxShadow: _controller.text.trim().isNotEmpty
                    ? [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.3), blurRadius: 10)]
                    : null,
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

  Widget _buildScrollFab() {
    return FloatingActionButton.small(
      onPressed: () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
      },
      backgroundColor: AppTheme.primaryColor.withOpacity(0.9),
      child: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  الإجراءات
  // ══════════════════════════════════════════════════════════════

  void _sendMessage(String text) {
    setState(() => _isTyping = true);
    context.read<ChatService>().sendMessage(text);

    // إخفاء مؤشر الكتابة بعد تأخير
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

  void _showSearchSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '🔍 بحث سريع',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Tajawal',
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: QuickSearchBar(
                onSearch: (query) {
                  Navigator.pop(context);
                  _sendMessage(query);
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _buildSearchSuggestions(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    final suggestions = [
      ('💉', 'وش تطعيمات BCG؟'),
      ('⚠️', 'وش الآثار الجانبية؟'),
      ('📅', 'عمره 6 شهور'),
      ('🔵', 'الفرق بين OPV و IPV'),
      ('🚫', 'هل يسبب أوتيزم؟'),
      ('❄️', 'وش السلسلة الباردة؟'),
      ('🔍', 'وش هو VVM؟'),
      ('👶', 'ولدي مبتسر'),
      ('🤰', 'أنا حامل'),
      ('🌟', 'وش فيتامين أ؟'),
      ('🦠', 'وش مرض الحصبة؟'),
      ('🚐', 'حملات التطعيم'),
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final (emoji, text) = suggestions[index];
        return ListTile(
          leading: Text(emoji, style: const TextStyle(fontSize: 20)),
          title: Text(
            text,
            style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14),
          ),
          trailing: Icon(Icons.arrow_back_ios, size: 14, color: Colors.grey.shade400),
          onTap: () {
            Navigator.pop(context);
            _sendMessage(text);
          },
        ).animate().fadeIn(delay: Duration(milliseconds: 50 * index));
      },
    );
  }

  void _showQuickTopics() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '📚 المواضيع الشائعة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Tajawal',
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _topicChip('💉', 'التطعيمات'),
                _topicChip('⚠️', 'الآثار الجانبية'),
                _topicChip('🦠', 'الأمراض'),
                _topicChip('❄️', 'سلسلة التبريد'),
                _topicChip('🌟', 'فيتامين أ'),
                _topicChip('👶', 'حالات خاصة'),
                _topicChip('🚫', 'الأساطير'),
                _topicChip('🚐', 'الحملات'),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _topicChip(String emoji, String label) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _sendMessage(label);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Tajawal',
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('مسح المحادثة', style: TextStyle(fontFamily: 'Tajawal')),
        content: const Text(
          'هل أنت متأكد من مسح جميع الرسائل؟',
          style: TextStyle(fontFamily: 'Tajawal'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Tajawal')),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ChatService>().clearChat();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('مسح', style: TextStyle(fontFamily: 'Tajawal')),
          ),
        ],
      ),
    );
  }

  void _showBotInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Text('🤖', style: TextStyle(fontSize: 28)),
            SizedBox(width: 10),
            Text('عن الروبوت', style: TextStyle(fontFamily: 'Tajawal')),
          ],
        ),
        content: const Text(
          'مستشار التحصين الصحي الموسع باليمن 🇾🇪\n\n'
          '📋 مبني على:\n'
          '• دليل إدارة اللقاحات 2022\n'
          '• دليل التحصين الموسع أغسطس 2025\n'
          '• إرشادات منظمة الصحة العالمية\n\n'
          '🧠 يشتغل بدون إنترنت\n'
          '💉 يغطي 11 مرض و20+ تطعيم\n'
          '📚 قاعدة معرفة شاملة\n\n'
          'الإصدار 1.0.0',
          style: TextStyle(fontFamily: 'Tajawal', height: 1.6),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً', style: TextStyle(fontFamily: 'Tajawal')),
          ),
        ],
      ),
    );
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
    _fabAnimController.dispose();
    super.dispose();
  }
}
