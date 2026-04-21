import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../services/specialized_chat_service.dart';
import '../services/polio_campaign_kb.dart';
import '../services/sia_kb.dart';
import '../services/analytics_kb.dart';
import 'chat_screen.dart';
import 'schedule_screen.dart';
import 'vaccine_card_screen.dart';
import 'specialized_chat_screen.dart';
import 'analytics_screen.dart';
import 'info_screen.dart';
import '../models/vaccine_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // خدمات البوتات المتخصصة
  late final SpecializedChatService _polioBot;
  late final SpecializedChatService _siaBot;

  @override
  void initState() {
    super.initState();
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

  List<Widget> get _screens => [
    const ChatScreen(),                                          // 0: الاستشارة
    const ScheduleScreen(),                                      // 1: الجدول
    const VaccineCardScreen(),                                   // 2: البطاقة
    SpecializedChatScreen(                                       // 3: حملات الشلل
      chatService: _polioBot,
      title: 'حملات شلل الأطفال',
      emoji: '🦠',
      accentColor: const Color(0xFF27AE60),
    ),
    SpecializedChatScreen(                                       // 4: النشاط الايصالي
      chatService: _siaBot,
      title: 'النشاط الايصالي التكاملي',
      emoji: '🚐',
      accentColor: const Color(0xFFE67E22),
    ),
    const AnalyticsScreen(),                                     // 5: تحليل البيانات
    // Info screen as last tab
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: Colors.grey.shade400,
          selectedLabelStyle: const TextStyle(
            fontFamily: 'Tajawal',
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 9,
          ),
          iconSize: 22,
          items: [
            _navItem('🤖', 'الاستشارة', 0),
            _navItem('📅', 'الجدول', 1),
            _navItem('📋', 'البطاقة', 2),
            _navItem('🦠', 'حملات الشلل', 3),
            _navItem('🚐', 'النشاط الايصالي', 4),
            _navItem('📊', 'تحليل البيانات', 5),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _navItem(String emoji, String label, int index) {
    final isSelected = _currentIndex == index;
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 10 : 4,
          vertical: isSelected ? 4 : 0,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(emoji, style: TextStyle(fontSize: isSelected ? 20 : 18)),
      ),
      label: label,
    );
  }
}
