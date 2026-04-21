import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../models/vaccine_model.dart';
import '../services/chat_service.dart';
import '../services/specialized_chat_service.dart';
import '../services/polio_campaign_kb.dart';
import '../services/sia_kb.dart';
import '../widgets/chat_widgets.dart';
import 'analytics_screen.dart';

// ══════════════════════════════════════════════════════════════════
//  مركز الاستشارات الموحد — صفحة واحدة مع تبويبات داخلية
// ══════════════════════════════════════════════════════════════════

class ConsultationCenterScreen extends StatefulWidget {
  const ConsultationCenterScreen({super.key});

  @override
  State<ConsultationCenterScreen> createState() => _ConsultationCenterScreenState();
}

class _ConsultationCenterScreenState extends State<ConsultationCenterScreen>
    with TickerProviderStateMixin {
  int _selectedTab = 0;
  late final List<GlobalKey<NavigatorState>> _navigatorKeys;
  late final TabController _tabController;

  // خدمات البوتات المتخصصة
  late final SpecializedChatService _polioBot;
  late final SpecializedChatService _siaBot;

  // ═══ تعريف التبويبات ═══
  static const _tabs = [
    _TabDef(emoji: '🤖', label: 'الاستشارة العامة', color: AppTheme.primaryColor),
    _TabDef(emoji: '🦠', label: 'حملات الشلل', color: Color(0xFF27AE60)),
    _TabDef(emoji: '🚐', label: 'النشاط الإيصالي', color: Color(0xFFE67E22)),
    _TabDef(emoji: '📊', label: 'تحليل البيانات', color: Color(0xFF2E86AB)),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _selectedTab = _tabController.index);
      }
    });
    _navigatorKeys = List.generate(_tabs.length, (_) => GlobalKey<NavigatorState>());

    _polioBot = SpecializedChatService(
      botName: 'خبير حملات الشلل',
      botEmoji: '🦠',
      welcomeMessage:
          '🦠 مرحباً! أنا خبير حملات شلل الأطفال في اليمن 🇾🇪\n\n'
          '📋 أقدر أساعدك في:\n'
          '• أنواع الحملات (NIDs, SNIDs)\n'
          '• تفاصيل فريق الحملة\n'
          '• تقييم أداء الحملات\n'
          '• السجلات والتقارير\n'
          '• تاريخ شلل الأطفال في اليمن\n'
          '• الاستجابة للأوبئة\n'
          '• التثقيف الصحي\n\n'
          '💡 اسألني عن أي شيء!',
      knowledgeBase: polioCampaignKnowledgeBase,
      keywordMap: polioCampaignKeywordMap,
      defaultReplies: const [
        QuickReply(text: 'وش أنواع الحملات؟', emoji: '🚐'),
        QuickReply(text: 'وش الفرق بين NIDs و SNIDs؟', emoji: '📊'),
        QuickReply(text: 'تاريخ شلل الأطفال', emoji: '📜'),
        QuickReply(text: 'فريق الحملة', emoji: '👥'),
        QuickReply(text: 'تقييم الحملة', emoji: '📊'),
        QuickReply(text: 'السجلات والتقارير', emoji: '📋'),
      ],
      contextReplies: {
        'الحملات الوطنية': [
          const QuickReply(text: 'الحملات الإقليمية', emoji: '📍'),
          const QuickReply(text: 'فريق الحملة', emoji: '👥'),
          const QuickReply(text: 'تقييم الحملة', emoji: '📊'),
        ],
        'فريق الحملة': [
          const QuickReply(text: 'تقييم الحملة', emoji: '📊'),
          const QuickReply(text: 'التثقيف الصحي', emoji: '📢'),
          const QuickReply(text: 'السجلات', emoji: '📋'),
        ],
      },
    );

    _siaBot = SpecializedChatService(
      botName: 'خبير النشاط الايصالي',
      botEmoji: '🚐',
      welcomeMessage:
          '🚐 مرحباً! أنا خبير النشاط الايصالي التكاملي (SIA) 🇾🇪\n\n'
          '📋 أقدر أساعدك في:\n'
          '• أنواع النشاط الايصالي\n'
          '• تكميم فيتامين أ\n'
          '• حملات الحصبة\n'
          '• أسبوع صحة الطفل\n'
          '• حملات الكزاز للحوامل\n'
          '• التخطيط والتقييم\n'
          '• التحديات والحلول\n\n'
          '💡 اسألني عن أي شيء!',
      knowledgeBase: siaKnowledgeBase,
      keywordMap: siaKeywordMap,
      defaultReplies: const [
        QuickReply(text: 'وش أنواع النشاط؟', emoji: '📋'),
        QuickReply(text: 'تكميم فيتامين أ', emoji: '🌟'),
        QuickReply(text: 'حملات الحصبة', emoji: '🔴'),
        QuickReply(text: 'أسبوع صحة الطفل', emoji: '👶'),
        QuickReply(text: 'تقييم SIA', emoji: '📊'),
        QuickReply(text: 'التحديات', emoji: '⚠️'),
      ],
      contextReplies: {
        'تكميم فيتامين أ': [
          const QuickReply(text: 'وش الجدول؟', emoji: '📅'),
          const QuickReply(text: 'وش الفائدة؟', emoji: '💪'),
          const QuickReply(text: 'كم جرعة؟', emoji: '🔢'),
        ],
        'حملات الحصبة': [
          const QuickReply(text: 'وش الفئة المستهدفة؟', emoji: '🎯'),
          const QuickReply(text: 'تقييم الحملة', emoji: '📊'),
        ],
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          _buildTabChips(),
          Expanded(child: _buildTabContent()),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  Header
  // ═══════════════════════════════════════════════════════════════

  Widget _buildHeader() {
    final tab = _tabs[_selectedTab];
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [tab.color, tab.color.withOpacity(0.85)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              // Avatar
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.85, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutBack,
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Center(
                        child: Text(tab.emoji, style: const TextStyle(fontSize: 24)),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              // Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مركز الاستشارات',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: Colors.greenAccent,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.greenAccent.withOpacity(0.5), blurRadius: 4),
                            ],
                          ),
                        ).animate(onPlay: (c) => c.repeat()).fadeIn(duration: 800.ms).then().fadeOut(duration: 800.ms),
                        const SizedBox(width: 6),
                        Text(
                          'متصل • بدون إنترنت • ${_tabs[_selectedTab].label}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.8),
                            fontFamily: 'Tajawal',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  Tab Chips (Horizontal scroll)
  // ═══════════════════════════════════════════════════════════════

  Widget _buildTabChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _tabs.asMap().entries.map((entry) {
            final i = entry.key;
            final tab = entry.value;
            final isSelected = _selectedTab == i;
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: GestureDetector(
                onTap: () {
                  _tabController.animateTo(i);
                  setState(() => _selectedTab = i);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(colors: [tab.color, tab.color.withOpacity(0.85)])
                        : null,
                    color: isSelected ? null : AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? tab.color : Colors.grey.shade300,
                      width: isSelected ? 1.5 : 1,
                    ),
                    boxShadow: isSelected
                        ? [BoxShadow(color: tab.color.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 3))]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(tab.emoji, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Text(
                        tab.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : Colors.black54,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  Tab Content
  // ═══════════════════════════════════════════════════════════════

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return const _GeneralChatView();
      case 1:
        return _SpecializedChatView(chatService: _polioBot, title: 'حملات شلل الأطفال', emoji: '🦠', accentColor: const Color(0xFF27AE60));
      case 2:
        return _SpecializedChatView(chatService: _siaBot, title: 'النشاط الايصالي التكاملي', emoji: '🚐', accentColor: const Color(0xFFE67E22));
      case 3:
        return const _AnalyticsWrapper();
      default:
        return const _GeneralChatView();
    }
  }
}

// ══════════════════════════════════════════════════════════════════
//  General Chat View (inside center)
// ══════════════════════════════════════════════════════════════════

class _GeneralChatView extends StatefulWidget {
  const _GeneralChatView();

  @override
  State<_GeneralChatView> createState() => _GeneralChatViewState();
}

class _GeneralChatViewState extends State<_GeneralChatView> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
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
    return Column(
      children: [
        _buildInfoBanner(),
        Expanded(child: _buildChatArea()),
        _buildInputArea(),
      ],
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.accentColor.withOpacity(0.08), AppTheme.accentColor.withOpacity(0.03)],
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
              style: TextStyle(fontSize: 12, color: AppTheme.accentColor.withOpacity(0.8), fontFamily: 'Tajawal'),
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
                style: TextStyle(fontSize: 11, color: AppTheme.accentColor, fontWeight: FontWeight.w600, fontFamily: 'Tajawal'),
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
            return _buildMessageBubble(msg, index, chatService.messages);
          },
        );
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, int index, List<ChatMessage> messages) {
    final isBot = msg.isBot;
    final isLastBot = isBot && index == (messages.length - 1);

    return Padding(
      padding: EdgeInsets.only(bottom: 10, left: isBot ? 0 : 40, right: isBot ? 40 : 0),
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
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
            ),
            child: SelectableText(
              msg.text,
              style: TextStyle(fontSize: 15, height: 1.7, color: isBot ? Colors.black87 : Colors.white, fontFamily: 'Tajawal'),
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
          final i = entry.key;
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
                  Text(reply.text, style: const TextStyle(fontSize: 13, color: AppTheme.primaryColor, fontFamily: 'Tajawal', fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ).animate().fadeIn(delay: Duration(milliseconds: 100 + i * 80)).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), curve: Curves.easeOutBack);
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
                    const SnackBar(content: Text('ميزة الصوت قريباً! 🎤', style: TextStyle(fontFamily: 'Tajawal')), duration: Duration(seconds: 2)),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
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
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: _controller.text.trim().isNotEmpty ? AppTheme.primaryGradient : LinearGradient(colors: [Colors.grey.shade300, Colors.grey.shade300]),
                shape: BoxShape.circle,
                boxShadow: _controller.text.trim().isNotEmpty ? [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.3), blurRadius: 10)] : null,
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
    context.read<ChatService>().sendMessage(text);
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

  void _showQuickTopics() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Text('📚 المواضيع الشائعة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Tajawal')),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _topicChip(ctx, '💉', 'التطعيمات'),
                _topicChip(ctx, '⚠️', 'الآثار الجانبية'),
                _topicChip(ctx, '🦠', 'الأمراض'),
                _topicChip(ctx, '❄️', 'سلسلة التبريد'),
                _topicChip(ctx, '🌟', 'فيتامين أ'),
                _topicChip(ctx, '👶', 'حالات خاصة'),
                _topicChip(ctx, '🚫', 'الأساطير'),
                _topicChip(ctx, '🚐', 'الحملات'),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _topicChip(BuildContext ctx, String emoji, String label) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(ctx);
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
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Tajawal', color: AppTheme.primaryColor)),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

// ══════════════════════════════════════════════════════════════════
//  Specialized Chat View (Polio / SIA) — embedded
// ══════════════════════════════════════════════════════════════════

class _SpecializedChatView extends StatefulWidget {
  final SpecializedChatService chatService;
  final String title;
  final String emoji;
  final Color accentColor;

  const _SpecializedChatView({
    required this.chatService,
    required this.title,
    required this.emoji,
    required this.accentColor,
  });

  @override
  State<_SpecializedChatView> createState() => _SpecializedChatViewState();
}

class _SpecializedChatViewState extends State<_SpecializedChatView> {
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
    return Column(
      children: [
        Expanded(child: _buildChatArea()),
        _buildInputArea(),
      ],
    );
  }

  Widget _buildChatArea() {
    return AnimatedBuilder(
      animation: widget.chatService,
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
      padding: EdgeInsets.only(bottom: 10, left: isBot ? 0 : 40, right: isBot ? 40 : 0),
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
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
            ),
            child: SelectableText(
              msg.text,
              style: TextStyle(fontSize: 15, height: 1.7, color: isBot ? Colors.black87 : Colors.white, fontFamily: 'Tajawal'),
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
          final i = entry.key;
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
                  Text(reply.text, style: TextStyle(fontSize: 13, color: widget.accentColor, fontFamily: 'Tajawal', fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ).animate().fadeIn(delay: Duration(milliseconds: 100 + i * 80)).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), curve: Curves.easeOutBack);
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
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

// ══════════════════════════════════════════════════════════════════
//  Analytics Wrapper — embedded
// ══════════════════════════════════════════════════════════════════

class _AnalyticsWrapper extends StatelessWidget {
  const _AnalyticsWrapper();

  @override
  Widget build(BuildContext context) {
    return const AnalyticsScreen();
  }
}

// ══════════════════════════════════════════════════════════════════
//  Helper: Tab Definition
// ══════════════════════════════════════════════════════════════════

class _TabDef {
  final String emoji;
  final String label;
  final Color color;
  const _TabDef({required this.emoji, required this.label, required this.color});
}
