import 'dart:math';
import 'package:flutter/material.dart';
import '../models/vaccine_model.dart';
import 'vaccination_service.dart';
import 'knowledge_base.dart';
import 'smart_nlp.dart';
import 'context_manager.dart';
import 'llm_service.dart';
import 'real_data_kb.dart';
import 'analytics_engine.dart';
import 'advanced_immunization_kb.dart';
import 'intermediate_management_kb.dart';
import 'deep_analytics_engine.dart';

class ChatService extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  final ContextManager _ctx = ContextManager();

  // ══════════════════════════════════════════════════════════════
  //  حالة الذكاء الاصطناعي
  // ══════════════════════════════════════════════════════════════
  bool _isAIEnabled = false;
  bool _isAILoading = false;
  bool get isAIEnabled => _isAIEnabled;
  bool get isAILoading => _isAILoading;
  AIIStatus get aiStatus => LLMService.currentStatus;

  /// تفعيل/تعطيل الذكاء الاصطناعي
  void setAIEnabled(bool enabled) {
    _isAIEnabled = enabled;
    notifyListeners();
  }

  /// تهيئة الذكاء الاصطناعي
  Future<void> initializeAI() async {
    await LLMService.loadConfig();
    if (LLMService.apiKey.isNotEmpty) {
      _isAIEnabled = true;
      final connected = await LLMService.testConnection();
      _isAIEnabled = connected;
    }
    notifyListeners();
  }

  /// إعداد مفتاح API
  Future<bool> configureAI(String apiKey, {String? baseUrl, String? model}) async {
    await LLMService.configure(
      apiKey: apiKey,
      baseUrl: baseUrl,
      model: model,
    );
    final connected = await LLMService.testConnection();
    _isAIEnabled = connected;
    notifyListeners();
    return connected;
  }

  void initialize() {
    if (_messages.isEmpty) {
      _addBotMessage(
        '🌟 مرحباً! أنا مستشار التحصين الصحي الموسع باليمن 🇾🇪\n\n'
        '🧠 فاهم كل شيء عن التطعيمات — اسألني براحتك!\n\n'
        '💉 تطعيمات طفلك (حسب عمره وحالته)\n'
        '⚠️ الآثار الجانبية (حرارة، تورم، تشنجات...)\n'
        '🦠 الأمراض التي تحمي منها التطعيمات\n'
        '👶 حالات خاصة (مبتسرين، سكري، قلب...)\n'
        '🍼 التغذية وتأثيرها على المناعة\n'
        '🚫 الرد على الأساطير (التوحد، العقم...)\n'
        '🏥 الأشراف الداعم وإدارة المستوى الوسيط\n'
        '❄️ سلسلة التبريد و VVM\n'
        '📜 تاريخ التحصين في اليمن\n'
        '📊 مؤشرات الأداء والتخطيط الدقيق\n'
        '🦠 الاستجابة للأوباء والرصد الوبائي\n'
        '🏫 تحصين المدارس\n\n'
        '💡 قولي عمر طفلك وأعطيك تطعيماته!',
        quickReplies: _welcomeReplies(),
      );
    }
  }

  void sendMessage(String text) {
    _messages.add(ChatMessage(id: _gid(), text: text, isBot: false, timestamp: DateTime.now()));
    notifyListeners();

    // ═══ محاولة استخدام الذكاء الاصطناعي أولاً ═══
    if (_isAIEnabled && LLMService.isOnline) {
      _sendMessageToAI(text);
    } else {
      // استخدام النظام المحلي (fallback)
      final ms = (200 + (text.length * 5)).clamp(200, 1200);
      Future.delayed(Duration(milliseconds: ms.toInt()), () {
        final resp = _process(text);
        _addBotMessage(resp.text, quickReplies: resp.quickReplies);
      });
    }
  }

  /// إرسال الرسالة للذكاء الاصطناعي مع RAG
  void _sendMessageToAI(String text) async {
    _isAILoading = true;
    notifyListeners();

    try {
      // بناء تاريخ المحادثة
      final history = <Map<String, String>>[];
      for (final msg in _messages) {
        history.add({
          'role': msg.isBot ? 'assistant' : 'user',
          'content': msg.text,
        });
      }

      // إرسال للLLM
      final response = await LLMService.sendMessage(
        userMessage: text,
        conversationHistory: history,
        childProfile: _ctx.child.toJson(),
      );

      _isAILoading = false;

      if (response.isFromLLM && response.text.isNotEmpty) {
        // نجح LLM — استخدم الرد الذكي
        _ctx.lastTopic = _extractTopicFromMessage(text);
        _record('ai_response', text);

        // إنشاء اقتراحات رد سريع ذكية
        final suggestions = LLMService.generateQuickReplySuggestions(text, response.text);
        final quickReplies = suggestions.map((s) {
          final emoji = _getEmojiForSuggestion(s);
          return QuickReply(text: s, emoji: emoji);
        }).toList();

        _addBotMessage(response.text, quickReplies: quickReplies);
      } else {
        // فشل LLM — استخدم النظام المحلي
        final resp = _process(text);
        _addBotMessage(resp.text, quickReplies: resp.quickReplies);
      }
    } catch (e) {
      _isAILoading = false;
      // خطأ — استخدم النظام المحلي
      final resp = _process(text);
      _addBotMessage(resp.text, quickReplies: resp.quickReplies);
    }
  }

  /// استخراج الموضوع من الرسالة
  String _extractTopicFromMessage(String text) {
    final norm = SmartNLP.normalize(text);
    final topicKeywords = {
      'تطعيم': 'التطعيمات', 'لقاح': 'اللقاحات', 'تحصين': 'التحصين',
      'اثار': 'الآثار الجانبية', 'جانبي': 'الآثار الجانبية',
      'حصبه': 'الحصبة', 'شلل': 'شلل الأطفال', 'خماسي': 'الخماسي',
      'رئوي': 'التطعيم الرئوي', 'روتا': 'الروتا', 'bcg': 'BCG',
      'اشراف': 'الإشراف الداعم', 'وسيط': 'إدارة المستوى الوسيط',
      'سلسله': 'سلسلة التبريد', 'تبريد': 'سلسلة التبريد',
      'حمل': 'حملات التطعيم', 'مدرس': 'تحصين المدارس',
      'مبتسر': 'الأطفال المبتسرين', 'حوامل': 'تطعيم الحوامل',
      'توحد': 'التطعيم والتوحد', 'عقم': 'التطعيم والعقم',
    };
    for (final entry in topicKeywords.entries) {
      if (norm.contains(entry.key)) return entry.value;
    }
    return 'استفسار عام';
  }

  /// اختيار إيموجي مناسب للاقتراح
  String _getEmojiForSuggestion(String suggestion) {
    final s = SmartNLP.normalize(suggestion);
    if (s.contains('اثار') || s.contains('جانبي')) return '⚠️';
    if (s.contains('مجاني') || s.contains('بلاش')) return '💰';
    if (s.contains('وين') || s.contains('اين')) return '📍';
    if (s.contains('حصبه')) return '🔴';
    if (s.contains('شلل')) return '💧';
    if (s.contains('مبتسر') || s.contains('خديج')) return '👶';
    if (s.contains('اشراف')) return '🏥';
    if (s.contains('وسيط') || s.contains('اداره')) return '📋';
    if (s.contains('طوارئ') || s.contains('خاف') || s.contains('خطر')) return '🚨';
    if (s.contains('حراره') || s.contains('سخون')) return '🌡️';
    if (s.contains('جرع')) return '🔢';
    if (s.contains('متى')) return '📅';
    if (s.contains('عادي') || s.contains('طبيعي')) return '✅';
    return '💡';
  }

  // ══════════════════════════════════════════════════════════════
  //  المعالجة الرئيسية مع السياق العميق
  // ══════════════════════════════════════════════════════════════

  _Resp _process(String raw) {
    final norm = SmartNLP.normalize(raw);

    // ═══ التحليلات العميقة أولاً — أعلى أولوية ═══
    final deepResult = DeepAnalyticsEngine.analyzeQuery(norm);
    if (deepResult != null) {
      _ctx.lastTopic = deepResult.title;
      _record('deep_analytics', norm);
      final deepReplies = <QuickReply>[
        const QuickReply(text: 'تقييم المخاطر', emoji: '🎯'),
        const QuickReply(text: 'تنبؤات متقدمة', emoji: '🔮'),
        const QuickReply(text: 'تحسين الحملات', emoji: '🚀'),
        const QuickReply(text: 'الإحاطة التنفيذية', emoji: '📋'),
      ];
      if (deepResult.actionItems.isNotEmpty) {
        return _Resp(
          '${deepResult.detailedAnalysis}\n\n━━━━ إجراءات مطلوبة ━━━━\n${deepResult.actionItems.map((a) => "  ▶️ $a").join("\n")}',
          deepReplies,
        );
      }
      return _Resp(deepResult.detailedAnalysis, deepReplies);
    }

    // ═══ الإحاطة التنفيذية ═══
    if (norm.contains('احاطه تنفيذ') || norm.contains('ملخص تنفيذ') || norm.contains('تقرير شامل') || norm.contains('وضع عاجل')) {
      _ctx.lastTopic = 'الإحاطة التنفيذية';
      _record('executive_briefing', norm);
      return _Resp(DeepAnalyticsEngine.getExecutiveBriefing(), [
        const QuickReply(text: 'تقييم المخاطر', emoji: '🎯'),
        const QuickReply(text: 'تحسين الحملات', emoji: '🚀'),
        const QuickReply(text: 'تحليل إشرافي', emoji: '🏥'),
        const QuickReply(text: 'تنبؤات متقدمة', emoji: '🔮'),
      ]);
    }

    // ═══ تحليل البيانات الحقيقية ═══
    final analyticsResult = AnalyticsEngine.analyzeQuery(norm);
    if (analyticsResult != null) {
      _ctx.lastTopic = analyticsResult.title;
      _record('analytics', norm);
      return _Resp(analyticsResult.details, [
        const QuickReply(text: 'توصيات ذكية', emoji: '💡'),
        const QuickReply(text: 'تنبؤات 2026', emoji: '🔮'),
        const QuickReply(text: 'تحليل الفجوات', emoji: '📊'),
        const QuickReply(text: 'مؤشرات الأداء', emoji: '📈'),
      ]);
    }

    // ═══ بحث في قاعدة بيانات التقارير الحقيقية ═══
    final realDataResp = _searchRealDataKB(norm);
    if (realDataResp != null) {
      _ctx.lastTopic = 'بيانات التقارير';
      _record('real_data', norm);
      return realDataResp;
    }

    // ═══ الوضع الحالي السريع ═══
    if (norm.contains('وضع حالي') || norm.contains('اخر احصائي') || norm.contains('احصائيات') || norm.contains('اخر ارقام')) {
      _ctx.lastTopic = 'الوضع الحالي';
      _record('status', norm);
      return _Resp(AnalyticsEngine.getQuickStatus(), [
        const QuickReply(text: 'تحليل الحملات', emoji: '📊'),
        const QuickReply(text: 'توصيات ذكية', emoji: '💡'),
        const QuickReply(text: 'تنبؤات 2026', emoji: '🔮'),
      ]);
    }

    // كشف الشكر
    if (SmartNLP.isThanking(norm)) {
      return _Resp('العفو! 😊 أي سؤال ثاني عن التحصين أنا موجود!', _welcomeReplies());
    }

    // ═══ معالجة مباشرة للرسائل الشائعة (Quick Replies) ═══
    final directResp = _handleDirectInput(norm, raw);
    if (directResp != null) return directResp;

    // ═══ معالجة أسئلة متعددة في رسالة واحدة ═══
    final parts = SmartNLP.splitMultipleQuestions(raw);
    if (parts.length > 1) {
      return _handleCompoundQuestions(parts, norm);
    }

    final intent = SmartNLP.detectIntent(norm, previousIntent: _ctx.lastTopic, lastTopic: _ctx.lastTopic);

    // ═══ استخراج الكيانات ═══
    _ctx.extractEntities(norm);
    _ctx.updatePhase(intent);

    // ═══ تحية ═══
    if (intent == 'greeting') return _handleGreeting(norm);

    // ═══ هل يحتاج توضيح؟ ═══
    final clar = _ctx.needsClarification(norm, intent);
    if (clar.needs) {
      _ctx.awaitingClarification = true;
      _ctx.clarificationContext = intent;
      return _Resp(clar.question, clar.options.map((o) => QuickReply(text: o, emoji: '❓')).toList());
    }

    // ═══ إذا كان ينتظر توضيح ═══
    if (_ctx.awaitingClarification) {
      _ctx.awaitingClarification = false;
      return _handleClarificationResponse(norm, _ctx.clarificationContext);
    }

    // ═══ نفي ═══
    if (SmartNLP.hasNegation(norm) && _ctx.lastTopic.isNotEmpty) {
      return _handleNegation(norm);
    }

    // ═══ مقارنة ═══
    if (SmartNLP.hasComparison(norm)) {
      return _handleComparison(norm);
    }

    // ═══ متابعة ═══
    if (intent == 'follow_up') return _handleFollowUp(norm);

    // ═══ معالجة حسب النية ═══
    switch (intent) {
      case 'age_query': return _handleAge(norm);
      case 'vaccine_list': return _handleVaccineList();
      case 'schedule_query': return _handleScheduleQuery(norm);
      case 'dose_count': return _handleDose(norm);
      case 'side_effects': return _handleSideEffects(norm);
      case 'emergency': return _handleEmergency(norm);
      case 'location': return _handleLocation();
      case 'cost': return _handleCost();
      case 'campaigns': return _handleCampaigns();
      case 'vaccine_types': return _handleVaccineTypes(norm);
      case 'myths': return _handleMyths(norm);
      case 'special_cases': return _handleSpecialCases(norm);
      case 'nutrition': return _handleNutrition(norm);
      case 'cold_chain': return _handleColdChain(norm);
      case 'travel': return _handleTravel();
      case 'history': return _handleHistory();
      case 'benefits': return _handleBenefits();
      case 'diseases': return _handleDiseases(norm);
      case 'child_sick': return _handleChildSick(norm);
      case 'supervision': return _handleSupervision(norm);
      case 'management': return _handleManagement(norm);
      case 'reminder': return _handleReminder(norm);
      case 'feedback': return _handleFeedback(norm);
      // ═══ النوايا الجديدة المضافة ═══
      case 'intermediate_management': return _handleIntermediateManagement(norm);
      case 'supportive_supervision': return _handleSupportiveSupervision(norm);
      case 'hmis_reporting': return _handleHMISReporting(norm);
      case 'microplanning': return _handleMicroplanning(norm);
      case 'outbreak_response': return _handleOutbreakResponse(norm);
      case 'vaccine_management': return _handleVaccineManagement(norm);
      case 'aefi_reporting': return _handleAEFIReporting(norm);
      case 'coverage_monitoring': return _handleCoverageMonitoring(norm);
      case 'school_immunization': return _handleSchoolImmunization(norm);
      case 'cold_chain_management': return _handleColdChainManagement(norm);
      case 'waste_management': return _handleWasteManagement(norm);
      case 'session_planning': return _handleSessionPlanning(norm);
      case 'demand_generation': return _handleDemandGeneration(norm);
      case 'community_engagement': return _handleCommunityEngagement(norm);
      case 'data_quality': return _handleDataQuality(norm);
      case 'stock_management': return _handleStockManagement(norm);
      case 'drop_out_analysis': return _handleDropOutAnalysis(norm);
      case 'defaulter_tracing': return _handleDefaulterTracing(norm);
      case 'open_vial_policy': return _handleOpenVialPolicy(norm);
      case 'surveillance': return _handleSurveillance(norm);
      case 'training': return _handleTraining(norm);
      case 'injection_safety': return _handleInjectionSafety(norm);
      default: break;
    }

    // ═══ بحث ذكي شامل ═══
    final found = _smartSearch(norm);
    if (found != null) {
      _ctx.lastTopic = found;
      _record('general', norm);
      // بحث في كل قواعد المعرفة
      final content = _kb[found]
          ?? advancedImmunizationKB[found]
          ?? intermediateManagementKB[found]
          ?? 'عذراً، لا تتوفر معلومات حالياً';
      return _Resp(content, _ctxReplies(found));
    }

    // ═══ رد افتراضي ذكي ═══
    return _handleDefault(norm);
  }

  // ══════════════════════════════════════════════════════════════
  //  معالجة مباشرة للرسائل الشائعة (Quick Replies) — تضمن عملها 100%
  // ══════════════════════════════════════════════════════════════

  _Resp? _handleDirectInput(String norm, String raw) {
    // --- تطعيمات الطفل ---
    if (norm.contains('تطعيمات طفلي') || norm.contains('تطعيمات الطفل') ||
        norm.contains('وش تطعيمات') || norm.contains('ايش تطعيمات') ||
        norm.contains('وش لقاحات') || norm.contains('ايش لقاحات') ||
        norm.contains('تطعيمات ولدي') || norm.contains('تطعيمات بنتي')) {
      if (_ctx.child.hasBasicInfo) return _handleAge(norm);
      _ctx.awaitingClarification = true;
      _ctx.clarificationContext = 'age_query';
      return _Resp('📅 عشان أقدر أعطيك تطعيمات طفلك بالضبط، كم عمره؟', [
        const QuickReply(text: 'عمره شهر', emoji: '📅'), const QuickReply(text: 'عمره 3 شهور', emoji: '📅'),
        const QuickReply(text: 'عمره 6 شهور', emoji: '📅'), const QuickReply(text: 'عمره 9 شهور', emoji: '📅'),
        const QuickReply(text: 'عمره سنة', emoji: '📅'),
      ]);
    }

    // --- الآثار الجانبية ---
    if (norm.contains('الاثار الجانبيه') || norm.contains('الآثار الجانبية') ||
        norm.contains('وش الآثار') || norm.contains('ايش الآثار') ||
        norm.contains('وش اثار') || norm.contains('وش يصير بعد') ||
        norm.contains('وش الآثار الجانبيه')) {
      _ctx.lastTopic = 'آثار جانبية';
      return _Resp(_kb['آثار جانبية'] ?? '', _ctxReplies('side_effects'));
    }

    // --- مجاني ---
    if (norm.contains('مجاني') || norm.contains('هل مجاني') || norm.contains('مجانا') || norm.contains('بلاش')) {
      _ctx.lastTopic = 'مجاناً';
      return _Resp(_kb['مجاناً'] ?? '', [const QuickReply(text: 'وين أطعم؟', emoji: '📍'), const QuickReply(text: 'متى التطعيم؟', emoji: '📅')]);
    }

    // --- الفرق بين OPV و IPV ---
    if ((norm.contains('الفرق') && norm.contains('opv') && norm.contains('ipv')) ||
        (norm.contains('الفرق') && norm.contains('شلل'))) {
      _ctx.lastTopic = 'الفرق بين OPV و IPV';
      return _Resp(_kb['الفرق بين OPV و IPV'] ?? '', _ctxReplies('cold_chain'));
    }

    // --- أوتيزم ---
    if (norm.contains('اوتيزم') || norm.contains('هل يسبب اوتيزم') || norm.contains('توحد')) {
      _ctx.lastTopic = 'التطعيم والتوحد';
      return _Resp(_kb['التطعيم والتوحد'] ?? '', _ctxReplies('myths'));
    }

    // --- عقم ---
    if (norm.contains('عقم') || norm.contains('هل يسبب عقم') || norm.contains('خصوبه')) {
      _ctx.lastTopic = 'التطعيم والعقم';
      return _Resp(_kb['التطعيم والعقم'] ?? '', _ctxReplies('myths'));
    }

    // --- هل التطعيمات مضرة ---
    if (norm.contains('هل التطعيمات مضرة') || norm.contains('هل مضرة') || norm.contains('هل التطعيم ضار') || norm.contains('هل اللقاح ضار')) {
      _ctx.lastTopic = 'هل التطعيم يضر';
      return _Resp(_kb['هل التطعيم يضر'] ?? '', _ctxReplies('myths'));
    }

    // --- هل تحتوي مواد ضارة ---
    if (norm.contains('هل تحتوي') || norm.contains('مواد ضارة') || norm.contains('مركبات ضارة')) {
      _ctx.lastTopic = 'أساطير';
      return _Resp(_kb['أساطير'] ?? '', _ctxReplies('myths'));
    }

    // --- ولدي مريض ---
    if (norm.contains('ولدي مريض') || norm.contains('طفلي مريض') || norm.contains('طفله مريض') ||
        norm.contains('ولد مريض') || norm.contains('بنت مريض')) {
      return _handleChildSick(norm);
    }

    // --- إشراف داعم / إشراف ---
    if (norm.contains('الاشراف الداعم') || norm.contains('الأشراف الداعم') ||
        norm.contains('اشراف داعم') || norm.contains('إشراف داعم') ||
        norm.contains('إشراف') || norm.contains('اشراف')) {
      return _handleSupportiveSupervision(norm);
    }

    // --- إدارة وسيطة / المستوى الوسيط / مدير مكتب / مدير محافظة ---
    if (norm.contains('المستوى الوسيط') || norm.contains('اداره المستوى') || norm.contains('ادارة المستوى') ||
        norm.contains('إداره وسيط') || norm.contains('إدارة وسيطة') || norm.contains('اداره وسيط') ||
        norm.contains('ادارة وسيطة') || norm.contains('مدير مكتب') || norm.contains('مدير محافظه') ||
        norm.contains('مدير محافظة') || norm.contains('المستوي الوسيط')) {
      return _handleIntermediateManagement(norm);
    }

    // --- مؤشرات أداء / KPI ---
    if (norm.contains('مؤشرات اداء') || norm.contains('مؤشرات الأداء') || norm.contains('مؤشرات أداء') ||
        norm.contains('kpi') || norm.contains('مؤشرات')) {
      return _handleIntermediateManagement(norm);
    }

    // --- DHIS2 / نظام المعلومات / نظام معلومات ---
    if (norm.contains('dhis2') || norm.contains('نظام المعلومات') || norm.contains('نظام معلومات') ||
        norm.contains('hmis') || norm.contains('نظام المعلومات الصحيه') || norm.contains('نظام المعلومات الصحية')) {
      return _handleHMISReporting(norm);
    }

    // --- تخطيط دقيق / تخطيط ---
    if (norm.contains('تخطيط دقيق') || norm.contains('ميكروبلان') || norm.contains('تخطيط') ||
        norm.contains('خطة تشغيليه') || norm.contains('خطة تشغيلية')) {
      return _handleMicroplanning(norm);
    }

    // --- تغطية / رصد التغطيات ---
    if (norm.contains('رصد التغطيات') || norm.contains('تغطيه') || norm.contains('تغطية') ||
        norm.contains('نسبه التغطيه') || norm.contains('نسبة التغطية')) {
      return _handleCoverageMonitoring(norm);
    }

    // --- تسرب / متخلفين / انقطاع ---
    if (norm.contains('تسرب') || norm.contains('متخلفين') || norm.contains('انقطاع') ||
        norm.contains('نسبه التسرب') || norm.contains('نسبة التسرب') || norm.contains('فجوه') ||
        norm.contains('dropout')) {
      return _handleDropOutAnalysis(norm);
    }

    // --- مخزون / احتياج / طلب لقاحات ---
    if (norm.contains('مخزون') || norm.contains('احتياج') || norm.contains('طلب لقاحات') ||
        norm.contains('جرد') || norm.contains('رصيد') || norm.contains('نواقص')) {
      return _handleStockManagement(norm);
    }

    // --- جلسات / تخطيط جلسات / جلسة ---
    if (norm.contains('تخطيط جلسات') || norm.contains('جلسات') || norm.contains('جلسه') ||
        norm.contains('جلسة تحصين') || norm.contains('جلسة')) {
      return _handleSessionPlanning(norm);
    }

    // --- نفايات / تخلص / حناديق ---
    if (norm.contains('نفايات') || norm.contains('تخلص') || norm.contains('حناديق') ||
        norm.contains('صناديق امان') || norm.contains('نفايات حاده') || norm.contains('نفايات طبيه')) {
      return _handleWasteManagement(norm);
    }

    // --- قارورة مفتوحة / سياسة القارورة ---
    if (norm.contains('قاروره مفتوحه') || norm.contains('قارورة مفتوحة') || norm.contains('سياسه القاروره') ||
        norm.contains('سياسة القارورة') || norm.contains('open vial') || norm.contains('قارورة')) {
      return _handleOpenVialPolicy(norm);
    }

    // --- حملة / حملات / تطعيم وطني / NIDs ---
    if (norm.contains('حمل') || norm.contains('nids') || norm.contains('تطعيم وطني') ||
        norm.contains('حملات') || norm.contains('ايام تحصين') || norm.contains('أيام تحصين') ||
        norm.contains('تكميليه') || norm.contains('تكميلية')) {
      return _handleCampaigns();
    }

    // --- وباء / استجابة / فاشية ---
    if (norm.contains('وباء') || norm.contains('استجابه') || norm.contains('استجابة') ||
        norm.contains('فاشيه') || norm.contains('فاشية') || norm.contains('outbreak')) {
      return _handleOutbreakResponse(norm);
    }

    // --- تحصين المدارس / مدرسة ---
    if (norm.contains('تحصين المدارس') || norm.contains('مدرسه') || norm.contains('مدرسة') ||
        norm.contains('طلاب') || norm.contains('طالبات') || norm.contains('تلاميذ') ||
        norm.contains('فحص مدرسي')) {
      return _handleSchoolImmunization(norm);
    }

    // --- ترصد / رصد وبائي ---
    if (norm.contains('ترصد') || norm.contains('رصد وبائي') || norm.contains('رصد') ||
        norm.contains('surveillance') || norm.contains('مراقبه وبائيه') || norm.contains('مراقبة وبائية')) {
      return _handleSurveillance(norm);
    }

    // --- سلامة الحقن / حقن آمن ---
    if (norm.contains('سلامه الحقن') || norm.contains('سلامة الحقن') || norm.contains('حقن آمن') ||
        norm.contains('حقن امن') || norm.contains('injection safety') || norm.contains('سلامه ابر')) {
      return _handleInjectionSafety(norm);
    }

    // --- تعزيز الطلب / طلب / توعية ---
    if (norm.contains('تعزيز الطلب') || norm.contains('توعيه') || norm.contains('توعية') ||
        norm.contains('تسويق اجتماعي') || norm.contains('رسائل صحيه') || norm.contains('رسائل صحية')) {
      return _handleDemandGeneration(norm);
    }

    // --- مشاركة مجتمعية / مجتمع ---
    if (norm.contains('مشاركه مجتمعيه') || norm.contains('مشاركة مجتمعية') || norm.contains('مجتمع') ||
        norm.contains('قاده مجتمعيين') || norm.contains('قادة مجتمعيين') || norm.contains('مجتمع محلي')) {
      return _handleCommunityEngagement(norm);
    }

    // --- الأمراض ---
    if (norm.contains('الامراض') || norm.contains('الأمراض') || norm.contains('وش الامراض') || norm.contains('ايش الامراض')) {
      return _handleDiseases(norm);
    }

    // --- التغذية ---
    if (norm.contains('التغذيه') || norm.contains('التغذية')) {
      return _handleNutrition(norm);
    }

    // --- متى أخاف ---
    if (norm.contains('متى اخاف') || norm.contains('متى اخاف عليه') || norm.contains('متى اقلق')) {
      return _handleEmergency(norm);
    }

    // --- متى أروح للطبيب ---
    if (norm.contains('متى اروح للطبيب') || norm.contains('متى اروح لدكتور') || norm.contains('متى استشير')) {
      return _handleEmergency(norm);
    }

    // --- هل مجاني ---
    if (norm.contains('هل مجاني') || norm.contains('هل بفلوس') || norm.contains('هل يكلف')) {
      _ctx.lastTopic = 'مجاناً';
      return _Resp(_kb['مجاناً'] ?? '', [const QuickReply(text: 'وين أطعم؟', emoji: '📍'), const QuickReply(text: 'متى التطعيم؟', emoji: '📅')]);
    }

    // --- وين أطعم ---
    if (norm.contains('وين اطعم') || norm.contains('اين اطعم') || norm.contains('وين اوديه') || norm.contains('فين اطعم')) {
      return _handleLocation();
    }

    // --- هل اليمن خالية ---
    if (norm.contains('هل اليمن خاليه') || norm.contains('هل اليمن خالية')) {
      _ctx.lastTopic = 'شلل الأطفال';
      return _Resp(_kb['شلل الأطفال المرض'] ?? '', _ctxReplies('opv'));
    }

    // --- متى التطعيم / متى التطعيمات ---
    if (norm.contains('متى التطعيم') || norm.contains('متى التطعيمات')) {
      _ctx.lastTopic = 'متى أطعم';
      return _Resp(_kb['متى أطعم'] ?? '', _ctxReplies('vaccine_list'));
    }

    // --- كم جرعة (generic) ---
    if (norm.contains('كم جرعة') || norm.contains('كم جرعه') || norm.contains('كم حقه') || norm.contains('كم حقنة')) {
      return _handleDose(norm);
    }

    // --- مبتسرين / خُدّج ---
    if (norm.contains('مبتسرين') || norm.contains('خديج') || norm.contains('مبتسر') || norm.contains('خُدّج')) {
      _ctx.lastTopic = 'للأطفال المبتسرين';
      return _Resp(_kb['للأطفال المبتسرين'] ?? '', _ctxReplies('special'));
    }

    // --- حوامل ---
    if (norm.contains('حوامل') || norm.contains('حامل')) {
      _ctx.lastTopic = 'الحوامل';
      return _Resp(_kb['الحوامل'] ?? '', _ctxReplies('special'));
    }

    // --- HIV ---
    if (norm.contains('hiv') || norm.contains('ايدز')) {
      _ctx.lastTopic = 'HIV';
      return _Resp(_kb['تطعيم الأطفال المصابين بـ HIV'] ?? '', _ctxReplies('special'));
    }

    // --- سكر ---
    if (norm.contains('سكر') && !norm.contains('ما ي')) {
      _ctx.lastTopic = 'سكري';
      return _Resp(_kb['الأطفال المصابين بالسكري'] ?? '', _ctxReplies('special'));
    }

    // --- قلب ---
    if (norm.contains('قلب') && norm.contains('طفل')) {
      _ctx.lastTopic = 'قلب';
      return _Resp(_kb['الأطفال المصابين بالقلب'] ?? '', _ctxReplies('special'));
    }

    // --- الرضاعة والتطعيم ---
    if (norm.contains('الرضاعه') || norm.contains('الرضاعة')) {
      _ctx.lastTopic = 'الرضاعة والتطعيم';
      return _Resp(_kb['الرضاعة والتطعيم'] ?? '', _ctxReplies('nutrition'));
    }

    // --- هل أطعم وهو مريض ---
    if (norm.contains('هل اطعم وهو مريض') || norm.contains('هل أطعم وهو مريض') || norm.contains('اطعم وهو مريض') || norm.contains('أطعم وهو مريض')) {
      return _handleChildSick(norm);
    }

    // --- جدول التحصين ---
    if (norm.contains('جدول التحصين') || norm.contains('جدول التطعيم') || norm.contains('كل التطعيمات') || norm.contains('جدول كامل')) {
      _ctx.lastTopic = 'جدول التحصين';
      return _Resp(_kb['جدول التحصين لدون العام'] ?? _kb['متى أطعم'] ?? '', _ctxReplies('vaccine_list'));
    }

    // --- الفرق بين OPV و IPV (without specifying both) ---
    if ((norm.contains('الفرق') && (norm.contains('شلل') || norm.contains('opv') || norm.contains('ipv')))) {
      _ctx.lastTopic = 'الفرق بين OPV و IPV';
      return _Resp(_kb['الفرق بين OPV و IPV'] ?? '', _ctxReplies('cold_chain'));
    }

    // --- فيتامين أ ---
    if (norm.contains('فيتامين')) {
      _ctx.lastTopic = 'فيتامين أ';
      return _Resp(_kb['فيتامين أ'] ?? '', _ctxReplies('nutrition'));
    }

    // --- VVM ---
    if (norm.contains('vvm') || norm.contains('وش هو vvm')) {
      _ctx.lastTopic = 'VVM';
      return _Resp(_kb['VVM'] ?? '', _ctxReplies('cold_chain'));
    }

    // --- السلسلة الباردة / التبريد ---
    if (norm.contains('السلسله البارده') || norm.contains('سلسلة التبريد') || norm.contains('التبريد')) {
      _ctx.lastTopic = 'سلسلة التبريد';
      return _Resp(_kb['سلسلة التبريد'] ?? '', _ctxReplies('cold_chain'));
    }

    // --- المحاقن ---
    if (norm.contains('المحاقن')) {
      _ctx.lastTopic = 'المحاقن';
      return _Resp(_kb['المحاقن'] ?? '', _ctxReplies('cold_chain'));
    }

    // --- الأزمات ---
    if (norm.contains('ازمه') || norm.contains('حرب') || norm.contains('صعوبات') || norm.contains('ازمة')) {
      _ctx.lastTopic = 'التحصين في الأزمات';
      return _Resp(_kb['التحصين في الأزمات'] ?? '', [const QuickReply(text: 'التحصين في المناطق النائية', emoji: '🏔️'), const QuickReply(text: 'التحصين للنازحين', emoji: '🏚️')]);
    }

    // --- النازحين ---
    if (norm.contains('نازح') || norm.contains('نزوح') || norm.contains('مخيم')) {
      _ctx.lastTopic = 'التحصين للنازحين';
      return _Resp(_kb['التحصين للنازحين'] ?? '', [const QuickReply(text: 'وين أطعم؟', emoji: '📍'), const QuickReply(text: 'هل مجاني؟', emoji: '💰')]);
    }

    // --- المناطق النائية ---
    if (norm.contains('نائيه') || norm.contains('ريف') || norm.contains('بعيد') || norm.contains('جبليه')) {
      _ctx.lastTopic = 'التحصين في المناطق النائية';
      return _Resp(_kb['التحصين في المناطق النائية'] ?? '', [const QuickReply(text: 'التحصين للنازحين', emoji: '🏚️'), const QuickReply(text: 'حملات التطعيم', emoji: '🚐')]);
    }

    // --- جهاز المناعة ---
    if (norm.contains('جهاز المناعه') || norm.contains('كيف يشتغل المناعه') || norm.contains('اجسام مضاده')) {
      _ctx.lastTopic = 'التفاعلات المناعية المتقدمة';
      return _Resp(_kb['التفاعلات المناعية المتقدمة'] ?? '', _welcomeReplies());
    }

    // --- الوصايا الذهبية ---
    if (norm.contains('وصايا') || norm.contains('نصائح مهمه للتطعيم') || norm.contains('ارشادات')) {
      _ctx.lastTopic = 'الوصايا الذهبية للتطعيم';
      return _Resp(_kb['الوصايا الذهبية للتطعيم'] ?? '', _welcomeReplies());
    }

    // --- تطعيمات محددة ---
    if (norm.contains('تطعيم الحصبه') || norm.contains('لقاح الحصبه') || norm.contains('تطعيم حصبه')) {
      _ctx.lastTopic = 'الحصبة';
      return _Resp(_kb['الحصبة'] ?? '', _ctxReplies('mr'));
    }
    if (norm.contains('تطعيم الخماسي') || norm.contains('لقاح الخماسي')) {
      _ctx.lastTopic = 'الخماسي';
      return _Resp(_kb['الخماسي'] ?? '', _ctxReplies('penta'));
    }
    if (norm.contains('تطعيم شلل') || norm.contains('لقاح شلل') || norm.contains('قطرات شلل')) {
      _ctx.lastTopic = 'شلل الأطفال';
      return _Resp(_kb['شلل الأطفال'] ?? '', _ctxReplies('opv'));
    }
    if (norm.contains('تطعيم الروتا') || norm.contains('لقاح الروتا') || norm.contains('روتا فيروس')) {
      _ctx.lastTopic = 'الروتا';
      return _Resp(_kb['الروتا'] ?? '', _ctxReplies('rota'));
    }
    if (norm.contains('تطعيم الرئوي') || norm.contains('لقاح الرئوي') || norm.contains('تطعيم المكورات')) {
      _ctx.lastTopic = 'التطعيم الرئوي';
      return _Resp(_kb['التطعيم الرئوي'] ?? '', _ctxReplies('pcv'));
    }
    // --- فهم الاستجابة ---
    if (norm.contains('وش معنى') || norm.contains('ايش معنى') || norm.contains('وش المقصود')) {
      return _Resp(
        '📝 معلومات عامة عن التحصين:\n\n'
        '💉 التحصين = حماية طفلك من الأمراض الخطيرة!\n\n'
        '📋 البرنامج يغطي 11 مرض:\n'
        '• الدرن (السل) • شلل الأطفال\n'
        '• الخناق • السعال الديبي • الكزاز\n'
        '• التهاب الكبد B • المستدمية النزلية\n'
        '• الحصبة • الحصبة الألمانية\n'
        '• المكورات الرئوية • الروتا فيروس\n\n'
        '📅 27 تطعيم من الولادة حتى 12 سنة\n'
        '🏥 جميعها مجانية في المراكز الصحية\n\n'
        '💡 قولي "جدول التحصين" لأعطيك الموعد الكامل!',
        _welcomeReplies(),
      );
    }

    return null; // لم يتم التعرف على الرسالة مباشرة
  }

  // ══════════════════════════════════════════════════════════════
  //  معالجة الأسئلة المركبة (عدة أسئلة في رسالة واحدة)
  // ══════════════════════════════════════════════════════════════

  _Resp _handleCompoundQuestions(List<String> parts, String norm) {
    final buf = StringBuffer();
    List<QuickReply>? allReplies;

    for (int i = 0; i < parts.length && i < 3; i++) {
      final p = SmartNLP.normalize(parts[i]);
      final resp = _process(p);
      if (i > 0) buf.writeln('\n━━━━━━━━━━━━━━━━━━━━\n');
      buf.writeln(resp.text);
      if (resp.quickReplies != null && resp.quickReplies!.isNotEmpty) {
        allReplies = resp.quickReplies;
      }
    }

    return _Resp(buf.toString(), allReplies ?? _welcomeReplies());
  }

  // ══════════════════════════════════════════════════════════════
  //  معالجة المقارنة
  // ══════════════════════════════════════════════════════════════

  _Resp _handleComparison(String n) {
    // مقارنة OPV و IPV
    if ((n.contains('opv') || n.contains('شلل فموي')) &&
        (n.contains('ipv') || n.contains('شلل حقن'))) {
      _ctx.lastTopic = 'الفرق بين OPV و IPV';
      return _Resp(_kb['الفرق بين OPV و IPV'] ?? '', _ctxReplies('cold_chain'));
    }

    // مقارنة عامّة التطعيمات
    final detected = SmartNLP.detectVaccineMention(n);
    if (detected != null) {
      _ctx.lastVaccine = detected;
      final match = VaccinationService.allVaccines.where((x) => x.id == detected).firstOrNull;
      if (match != null) {
        return _Resp('${match.iconEmoji} ${match.nameAr}\n\n${match.description}\n\n💉 ${match.doseNumber}\n📍 ${match.site}', _ctxReplies(detected));
      }
    }

    return _Resp(
      '🔄 مقارنة التطعيمات:\n\n'
      '💡 أنا أقدر أساعدك في مقارنة أي تطعيمين!\n\n'
      'جرب تسأل:\n'
      '• "الفرق بين OPV و IPV؟"\n'
      '• "وش أفضل BCG أو شي ثاني؟"\n\n'
      '📌 عموماً: كل تطعيم له دور مختلف ومكمل — لازم كلها!',
      [const QuickReply(text: 'الفرق OPV و IPV', emoji: '🔵'), const QuickReply(text: 'وش تطعيمات طفلي؟', emoji: '💉')],
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  المعالجات المتقدمة — الموجودة سابقاً
  // ══════════════════════════════════════════════════════════════

  _Resp _handleAge(String n) {
    final age = SmartNLP.extractAge(n);
    if (age != null) {
      final months = age.months > 0 ? age.months : (age.weeks * 7) ~/ 30;
      final weeks = age.weeks > 0 ? age.weeks : (age.months * 30) ~/ 7;
      _ctx.child.ageMonths = months;
      _ctx.child.ageWeeks = weeks;
      _ctx.child.lastUpdated = DateTime.now();

      final m = _ctx.child.ageMonths!;
      final w = _ctx.child.ageWeeks!;
      final due = VaccinationService().getVaccinesDueAtAge(w, m);
      final upcoming = VaccinationService().getUpcomingVaccines(w, m);
      final overdue = VaccinationService().getOverdueVaccines(w, m, _ctx.child.givenVaccines);

      final buf = StringBuffer();

      if (_ctx.child.name != null) {
        buf.writeln('📅 ${_ctx.child.name} عمره ${_ctx.child.ageDisplay}:');
      } else {
        buf.writeln('📅 عمر طفلك: ${_ctx.child.ageDisplay}');
      }

      if (_ctx.child.isPremature) buf.writeln('👶 طفل مبتسر — يُعطى حسب العمر الزمني');

      if (overdue.isNotEmpty) {
        buf.writeln('\n⚠️ تطعيمات متأخرة (أعطها فوراً!):');
        for (final v in overdue) {
          buf.writeln('  ⚠️ ${v.iconEmoji} ${v.nameAr} — ${v.doseNumber}');
        }
      }

      final completed = due.where((v) => !overdue.contains(v)).toList();
      if (completed.isNotEmpty) {
        buf.writeln('\n✅ تطعيمات يجب أن تكون مُعطاة:');
        for (final v in completed) {
          buf.writeln('  ✅ ${v.iconEmoji} ${v.nameAr} — ${v.doseNumber}');
        }
      }

      if (upcoming.isNotEmpty) {
        buf.writeln('\n⏰ التطعيمات القادمة:');
        for (final v in upcoming) buf.writeln('  📋 ${v.iconEmoji} ${v.nameAr}');
      }

      if (due.isEmpty && upcoming.isEmpty) {
        buf.writeln('\n✅ جميع التطعيمات الأساسية مكتملة لهذا العمر!');
        if (m >= 72) buf.writeln('💡 تحقق من التطعيمات المدرسية.');
      }

      if (m <= 3) buf.writeln('\n💡 لا تأخر عن مواعيد 6 و10 و14 أسبوع!');
      if (m >= 8 && m <= 10) buf.writeln('\n⏰ تطعيم الحصبة (MR) قرب! لا تفوته في عمر 9 أشهر.');
      if (m >= 16 && m <= 19) buf.writeln('\n⏰ الجرعة الثانية من MR في عمر 18 شهر — لا تفوتها!');

      if (overdue.isNotEmpty) {
        buf.writeln('\n🚨 ⚡ مهم: عندك ${overdue.length} تطعيمات متأخرة! روح المركز الصحي اليوم!');
      }

      _ctx.lastTopic = 'عمر الطفل';
      _record('age_query', n);
      return _Resp(buf.toString(), [
        const QuickReply(text: 'وش الآثار الجانبية؟', emoji: '⚠️'),
        const QuickReply(text: 'هل أطعم وهو مريض؟', emoji: '🤒'),
        const QuickReply(text: 'وين أطعمه؟', emoji: '📍'),
        const QuickReply(text: 'هل مجاني؟', emoji: '💰'),
      ]);
    }

    _ctx.awaitingClarification = true;
    _ctx.clarificationContext = 'age_query';
    return _Resp('📅 كم عمر طفلك؟ (أكتب العمر بالشهور أو الأسابيع)', [
      const QuickReply(text: 'عمره شهر', emoji: '📅'), const QuickReply(text: 'عمره 3 شهور', emoji: '📅'),
      const QuickReply(text: 'عمره 6 شهور', emoji: '📅'), const QuickReply(text: 'عمره 9 شهور', emoji: '📅'),
      const QuickReply(text: 'عمره سنة', emoji: '📅'),
    ]);
  }

  _Resp _handleClarificationResponse(String n, String context) {
    if (context == 'age_query') return _handleAge(n);
    if (context == 'side_effects') return _handleSideEffects(n);
    if (context == 'vaccine_list') return _handleAge(n);
    return _handleDefault(n);
  }

  _Resp _handleNegation(String n) {
    final topic = _ctx.lastTopic;
    if (topic.contains('تطعيم') || topic.contains('لقاح')) {
      return _Resp(
        '👍 ما يبي يطعمه الحين — مافي مشكلة!\n\n'
        '📌 بس تذكر:\n'
        '• التطعيم المتأخر أفضل من عدم التطعيم\n'
        '• لا تحتاج تبدأ من جديد\n'
        '• استأنف الجدول لما يتحسن\n\n'
        '💡 متى يرجع يتحسن؟ ارجع لي وأقولك وش التطعيمات اللي فاتته.',
        [const QuickReply(text: 'متى أرجع أطعمه؟', emoji: '⏰'), const QuickReply(text: 'وش الآثار؟', emoji: '⚠️')],
      );
    }
    return _Resp('تمام! 👍 إذا احتجت شيء ثاني أنا هنا.', _welcomeReplies());
  }

  _Resp _handleFollowUp(String n) {
    if (RegExp(r'^(نعم|ايوه|ايه|اي|يب|ايه نعم|اوك|اوكي|ياب|أي نعم|أيوه|ايه اي)').hasMatch(n)) {
      if (_ctx.lastTopic.isNotEmpty && _kb.containsKey(_ctx.lastTopic)) {
        return _Resp(_kb[_ctx.lastTopic] ?? 'عذراً، لا تتوفر معلومات حالياً', _ctxReplies(_ctx.lastTopic));
      }
      return _Resp('تمام! ✅ اسألني أي تفاصيل إضافية.', _welcomeReplies());
    }

    if (RegExp(r'^(لا|ما ابي|مو|ما يبي|ما ابغي|ما ابي اعطيه|لالا|لا شكرا)').hasMatch(n)) {
      return _Resp('👍 تمام! إذا احتجت شيء ثاني أنا هنا.', _welcomeReplies());
    }

    if (RegExp(r'اشرح|وضح|بالتفصيل|تفاصيل|شرح لي|زود|فهمني اكثر|فهمني|زيدني|عطيني تفاصيل|اكثر').hasMatch(n)) {
      if (_ctx.lastTopic.isNotEmpty && _kb.containsKey(_ctx.lastTopic)) {
        return _Resp(_kb[_ctx.lastTopic] ?? 'عذراً، لا تتوفر معلومات حالياً', _ctxReplies(_ctx.lastTopic));
      }
      return _Resp('📚 وش تبي أشرح لك بالتفصيل؟ اختر من المواضيع:', _welcomeReplies());
    }

    if (RegExp(r'^(طيب|تمام|زين|اوكي|اوك|تمام شكرا|كذا خلاص|شكرا|thanks|فاهمت|فهمت|واضح)').hasMatch(n)) {
      if (_ctx.lastTopic.isNotEmpty) {
        return _Resp('💡 تمام! تبي تعرف أكثر عن "${_ctx.lastTopic}"؟ أو عندك سؤال ثاني؟', _welcomeReplies());
      }
      return _Resp('🌟 تمام! أي سؤال ثاني أنا موجود!', _welcomeReplies());
    }

    if (n.startsWith('كم')) {
      return _Resp('📊 تحب تعرف كم جرعة؟ ولا كم عمر يبدأ فيه التطعيم؟', [
        const QuickReply(text: 'كم جرعة؟', emoji: '🔢'),
        const QuickReply(text: 'متى يبدأ؟', emoji: '📅'),
        const QuickReply(text: 'كم تطعيم بالمجموع؟', emoji: '💉'),
      ]);
    }

    if (RegExp(r'^ليه|^ليش|^لماذا|^ليهذا|^لي ذا').hasMatch(n)) {
      if (_ctx.lastTopic.isNotEmpty && _kb.containsKey(_ctx.lastTopic)) {
        return _Resp(_kb[_ctx.lastTopic] ?? 'عذراً', _ctxReplies(_ctx.lastTopic));
      }
      return _Resp('🤔 ليش إيش بالضبط؟ اشرح لي أكثر وأجاوبك!', _welcomeReplies());
    }

    if (RegExp(r'^وش|^ايش|^ماذا|^ايش').hasMatch(n)) {
      if (_ctx.lastTopic.isNotEmpty) {
        final topicReplies = _ctxReplies(_ctx.lastTopic);
        return _Resp('💡 وش بالضبط تبي تعرف عن "${_ctx.lastTopic}"؟', topicReplies);
      }
    }

    if (RegExp(r'^متى').hasMatch(n)) {
      if (_ctx.lastTopic.contains('تطعيم') || _ctx.lastTopic.contains('لقاح') || _ctx.lastTopic.contains('عمر')) {
        return _Resp(_kb['متى أطعم'] ?? '', _ctxReplies('vaccine_list'));
      }
      return _Resp('🤔 متى إيش بالضبط؟ متى التطعيم؟ ولا متى أخاف؟', _welcomeReplies());
    }

    if (RegExp(r'^وين|^اين|^فين|^أين').hasMatch(n)) {
      return _handleLocation();
    }

    if (RegExp(r'^وش |^ايش |^ما هو|^ما هي').hasMatch(n)) {
      return _handleVaccineTypes(n);
    }

    return _Resp('🤔 ممكن توضح أكثر وش تقصد بالضبط؟\n\n💡 أنا أقدر أساعدك في:\n• تطعيمات طفلك حسب عمره\n• الآثار الجانبية\n• أمراض ووقاية\n• حالات خاصة\n• الأشراف الداعم\n• الإدارة الوسيطة والتخطيط', _welcomeReplies());
  }

  _Resp _handleChildSick(String n) {
    final severity = SmartNLP.detectSeverity(n);
    final symptoms = _ctx.child.mentionedSymptoms;

    if (symptoms.contains('تشنجات') || n.contains('تشنج') || n.contains('نوبه') || n.contains('يرتعش')) {
      return _Resp(
        '🚨 اطلب طبيب فوراً!\n\n'
        '⚠️ التشنجات حالة طوارئ:\n'
        '1. اطلب الإسعاف\n'
        '2. ضع الطفل على جانبه\n'
        '3. لا تضع شيء في فمه\n'
        '4. دوّن مدة التشنج\n\n'
        '⏰ لا تنتظر — اذهب للمستشفى الآن!',
        [const QuickReply(text: 'وش أسوي؟', emoji: '🚨'), const QuickReply(text: 'متى أخاف؟', emoji: '⚠️')],
      );
    }

    final symptomsText = symptoms.isNotEmpty ? '\n\n📋 الأعراض المذكورة: ${symptoms.join(', ')}' : '';

    if (severity == 'شديد') {
      return _Resp(
        '⚠️ إذا كان طفلك تعبان بشكل شديد:$symptomsText\n\n'
        '🏥 استشر الطبيب قبل التطعيم\n'
        '⏳ يؤجل التطعيم حتى يتحسن\n\n'
        '📌 لكن إذا كان مرض بسيط (زكام، إسهال خفيف) ← يُطعم عادي!',
        [const QuickReply(text: 'متى أرجع أطعمه؟', emoji: '⏰'), const QuickReply(text: 'وش أعراض الخطر؟', emoji: '🚨')],
      );
    }

    return _Resp(
      '🤒 هل طفلك مريض؟$symptomsText\n\n'
      '📌 القاعدة الذهبية:\n'
      '• مرض بسيط (زكام، إسهال خفيف) ← يُطعم ✅\n'
      '• حرارة أقل من 38.5° ← يُطعم ✅\n'
      '• حرارة أكثر من 38.5° ← انتظر 24 ساعة ⏳\n'
      '• مرض شديد ← انتظر حتى يتحسن ⏳\n\n'
      '💡 وش أعراض طفلك بالضبط؟',
      [const QuickReply(text: 'حرارته عالية', emoji: '🌡️'), const QuickReply(text: 'عنده إسهال', emoji: '💧'), const QuickReply(text: 'يسعل', emoji: '😷')],
    );
  }

  _Resp _handleSideEffects(String n) {
    final temp = SmartNLP.extractTemperature(n);
    if (temp != null) {
      _ctx.child.mentionedSymptoms.add('حرارة');
      _ctx.lastTopic = 'حرارة بعد التطعيم';
      final urgency = temp >= 39.5
          ? '🚨 حرارة عالية! اطلب طبيب فوراً'
          : temp >= 38.5
              ? '⚠️ حرارة متوسطة — راقب الطفل عن كثب'
              : '✅ حرارة خفيفة — طبيعية بعد التطعيم';
      return _Resp(
        '🌡️ حرارة طفلك: ${temp}°\n$urgency\n\n${_kb['حرارة بعد التطعيم'] ?? '💡 حرارة خفيفة بعد التطعيم طبيعية وتزول خلال 1-3 أيام.'}',
        [const QuickReply(text: 'متى أخاف؟', emoji: '🚨'), const QuickReply(text: 'متى أروح للطبيب؟', emoji: '🏥')],
      );
    }

    if (n.contains('حراره') || n.contains('سخون') || n.contains('يسخن') || n.contains('حمى') || n.contains('سخنت')) {
      _ctx.lastTopic = 'حرارة بعد التطعيم';
      return _Resp(
        _kb['حرارة بعد التطعيم'] ?? '🌡️ الحرارة بعد التطعيم طبيعية في الغالب. كم حرارته بالضبط؟',
        [const QuickReply(text: 'حرارته 38', emoji: '🌡️'), const QuickReply(text: 'حرارته 39.5', emoji: '🌡️'), const QuickReply(text: 'متى أخاف؟', emoji: '🚨')],
      );
    }
    if (n.contains('تشنج') || n.contains('نوبه') || n.contains('يرتعش')) {
      _ctx.lastTopic = 'تشنجات بعد التطعيم';
      return _Resp(_kb['تشنجات بعد التطعيم'] ?? '🚨 التشنجات حالة طوارئ — اطلب الإسعاف فوراً!', [const QuickReply(text: 'وش أسوي الحين؟', emoji: '🚨')]);
    }
    if (n.contains('تورم') || n.contains('انتفاخ') || n.contains('ورم')) {
      _ctx.lastTopic = 'تتورم مكان الحقن';
      return _Resp(_kb['تتورم مكان الحقن'] ?? '💡 التورم البسيط مكان الحقن طبيعي ويروح خلال أيام.', _ctxReplies('side_effects'));
    }
    if (n.contains('يبكي') || n.contains('بكاء') || n.contains('ما يسكت') || n.contains('بكى')) {
      _ctx.lastTopic = 'بكاء مستمر بعد التطعيم';
      return _Resp(_kb['بكاء مستمر بعد التطعيم'] ?? '💡 البكاء بعد التطعيم طبيعي. حضنه واطمنه.', _ctxReplies('side_effects'));
    }

    if (n.contains('اعراض') || n.contains('جانبيه') || n.contains('وش يصير') || n.contains('ايش يصير')) {
      _ctx.lastTopic = 'آثار جانبية';
      return _Resp(_kb['آثار جانبية'] ?? '', _ctxReplies('side_effects'));
    }

    final v = SmartNLP.detectVaccineMention(n);
    if (v != null) {
      _ctx.lastVaccine = v;
      _ctx.lastTopic = 'آثار جانبية';
      return _Resp(_getSpecificEffects(v), _ctxReplies('side_effects'));
    }

    _ctx.lastTopic = 'آثار جانبية';
    return _Resp(_kb['آثار جانبية'] ?? 'عذراً، لا تتوفر معلومات حالياً', _ctxReplies('side_effects'));
  }

  String _getSpecificEffects(String vid) {
    final e = {
      'bcg': '🔴 آثار BCG:\n✅ طبيعي بعد 2-8 أسابيع: احمرار، قُرحة، تندب\n📌 التندب يبقى مدى الحياة — طبيعي!\n🚫 لا تضع مرهم أو تغطي المكان\n\n⏰ إذا ظهر تورم كبير بعد أسبوعين ← ارجع للمركز',
      'opv': '🟢 آثار OPV: نادرة جداً\n✅ لا توجد آثار شائعة\n⚠️ شلل مرتبط باللقاح: 1 لكل 2.4 مليون جرعة\n\n📌 لا تطعم إذا كان الطفل يقيء',
      'penta': '🟡 آثار الخماسي:\n✅ ألم مكان الحقن (شائعة)\n✅ حرارة 38-39° (30% من الأطفال)\n⚠️ حرارة أكثر من 39.5° ← اطلب طبيب\n⏰ تزول خلال 1-3 أيام\n\n📌 أعطه بارادول إذا الحرارة مؤلمة',
      'mr': '🔴 آثار MR:\n✅ تظهر بعد 5-12 يوم (ليست فورية!)\n• حرارة خفيفة\n• طفح جلدي خفيف\n📌 هذا طبيعي! يعني المناعة تشتغل\n\n⚠️ إذا الحرارة بعد MR أكثر من 39° بعد 12 يوم ← ارجع للمركز',
      'pcv': '🟣 آثار PCV: نادرة وخفيفة\n✅ ألم مكان الحقن، حرارة خفيفة\n✅ نعاس (طبيعي)',
      'rota': '🔵 آثار الروتا: نادرة جداً\n✅ من أكثر التطعيمات أماناً!\n⚠️ إسهال خفيف نادر',
      'ipv': '💉 آثار IPV: خفيفة جداً\n✅ ألم مكان الحقن\n✅ احمرار بسيط\n📌 لا يسبب الشلل أبداً (ميت)',
      'td_girls': '👧 آثار Td للبنات:\n✅ ألم مكان الحقن (بسيط)\n✅ احمرار بسيط\n📌 يحمي من الكزاز والخناق مستقبلاً',
      'vitA': '🌟 آثار فيتامين أ: نادرة جداً!\n✅ آمن جداً ولا توجد آثار جانبية شائعة\n📌 يقوي المناعة ويمنع العمى الليلي\n💡 يُعطى عن طريق الفم (كبسولة)',
      'vitA_1': '🌟 آثار فيتامين أ: نادرة جداً!\n✅ آمن جداً ولا توجد آثار جانبية شائعة',
      'vitA_2': '🌟 آثار فيتامين أ: نادرة جداً!\n✅ آمن جداً',
      'vitA_3': '🌟 آثار فيتامين أ: نادرة جداً!\n✅ آمن جداً',
      'vitA_school': '🌟 آثار فيتامين أ: نادرة جداً!\n✅ آمن جداً',
      'hepb0': '🔵 آثار HepB0: خفيفة جداً\n✅ ألم بسيط مكان الحقن\n✅ حرارة خفيفة',
      'dtp_booster': '💪 آثار DTP المعززة:\n✅ ألم مكان الحقن\n✅ حرارة خفيفة\n📌 الجرعة المعززة مهمة للحفاظ على المناعة',
      'dtp_school': '🏫 آثار DTP المدرسية:\n✅ ألم مكان الحقن\n📌 جرعة معززة عند دخول المدرسة',
      'mr_school': '🔴 آثار MR المدرسية:\n✅ حرارة بعد 5-12 يوم (طبيعية)\n📌 جرعة معززة للحصبة',
    };
    return e[vid] ?? _kb['آثار جانبية'] ?? 'عذراً، لا تتوفر معلومات حالياً';
  }

  _Resp _handleEmergency(String n) {
    if (RegExp(r'تشنج|نوبه|يرتعش|يسكر|ما يتنفس|ما يرد|اختنق|فقد وعي|شحوب شديد|يموت').hasMatch(n)) {
      return _Resp(
        '🚨 ⚡️ حالة طوارئ!\n\n'
        '1. اطلب الإسعاف فوراً (333 أو 119)\n'
        '2. ضع الطفل على جانبه في وضع التعافي\n'
        '3. لا تضع شيء في فمه أبداً\n'
        '4. لو كان يتنفس → أرجع رأسه قليلاً\n'
        '5. دوّن مدة الحالة والحرارة\n\n'
        '⏰ لا تنتظر! اذهب للمستشفى أو اطلب إسعاف الآن!',
        [const QuickReply(text: 'وش أسوي بعد كذا؟', emoji: '🚨'), const QuickReply(text: 'كيف أحميه من الحرارة؟', emoji: '🌡️')],
      );
    }

    final temp = SmartNLP.extractTemperature(n);
    if (temp != null && temp >= 39) {
      return _Resp(
        '🚨 حرارة طفلك ${temp}° عالية! ⚠️\n\n'
        '📋 افعل هذا فوراً:\n'
        '1. كمادات ماء دافئ على الجبهة\n'
        '2. أزع عنه الملابس الزائدة\n'
        '3. أعطه بارادول حسب وزنه\n'
        '4. هوّن المراوح\n'
        '5. إذا لم تنخفض خلال ساعة ← اذهب للمستشفى\n\n'
        '📏 الجرعة: 15 ملجم/كجم كل 4-6 ساعات\n'
        '⚠️ لا تعطه أسبرين أبداً للطفل!\n'
        '📞 اذهب للمستشفى أو اطلب الإسعاف!',
        [const QuickReply(text: 'كم جرعة بارادول؟', emoji: '💊'), const QuickReply(text: 'متى أروح للمستشفى؟', emoji: '🏥')],
      );
    }

    return _Resp(
      '🚨 متى تطلب طبيب فوراً؟\n\n'
      '━━ خلال دقائق (طوارئ) ━━\n'
      '🔴 صعوبة تنفس\n'
      '🔴 تورم وجه/حلق/لسان\n'
      '🔴 شحوب شديد أو فقد وعي\n'
      '🔴 تشنجات\n\n'
      '━━ خلال ساعات ━━\n'
      '🟠 حرارة أكثر من 39.5° لا تنخفض\n'
      '🟠 بكاء مستمر أكثر من 3 ساعات\n'
      '🟠 طفح جلدي شديد أو شرى\n'
      '🟠 تورم يزداد بسرعة\n\n'
      '━━ خلال يومين ━━\n'
      '🟡 حرارة مستمرة 48 ساعة\n'
      '🟡 قيء مستمر مع جفاف\n'
      '🟡 عدم القدرة على الرضاعة\n\n'
      '⏰ انتظر 15-30 دقيقة بعد التطعيم في المركز الصحي!\n'
      '📞 خط الطوارئ: 333 أو 119',
      [const QuickReply(text: 'حرارة بعد التطعيم', emoji: '🌡️'), const QuickReply(text: 'تشنجات', emoji: '🚨'), const QuickReply(text: 'تورم شديد', emoji: '⚠️')],
    );
  }

  _Resp _handleMyths(String n) {
    if (n.contains('اوتيزم') || n.contains('توحد') || n.contains('اوتيستك') || n.contains('autism')) {
      _ctx.lastTopic = 'التطعيم والتوحد';
      return _Resp(_kb['التطعيم والتوحد'] ?? '', _ctxReplies('myths'));
    }
    if (n.contains('عقم') || n.contains('خصوبه') || n.contains('خصوبة') || n.contains('يسبب عقم')) {
      _ctx.lastTopic = 'التطعيم والعقم';
      return _Resp(_kb['التطعيم والعقم'] ?? '', _ctxReplies('myths'));
    }
    if (n.contains('يضرب') || n.contains('يضير') || n.contains('ضرار') || n.contains('مضار') || n.contains('مضرة') || n.contains('يضرون')) {
      _ctx.lastTopic = 'هل التطعيم يضر';
      return _Resp(_kb['هل التطعيم يضر'] ?? '', _ctxReplies('myths'));
    }
    _ctx.lastTopic = 'أساطير';
    return _Resp(_kb['أساطير'] ?? 'عذراً', [
      const QuickReply(text: 'هل يسبب أوتيزم؟', emoji: '🚫'),
      const QuickReply(text: 'هل يسبب عقم؟', emoji: '🚫'),
      const QuickReply(text: 'هل التطعيمات مضرة؟', emoji: '🚫'),
      const QuickReply(text: 'هل تحتوي مواد ضارة؟', emoji: '🚫'),
    ]);
  }

  _Resp _handleSpecialCases(String n) {
    if (n.contains('مبتسر') || n.contains('خديج') || n.contains('مبكر') || n.contains('premature')) {
      _ctx.lastTopic = 'للأطفال المبتسرين';
      return _Resp(_kb['للأطفال المبتسرين'] ?? 'عذراً', _ctxReplies('special'));
    }
    if (n.contains('مريض') || n.contains('مريضه') || n.contains('مريضين')) {
      _ctx.lastTopic = 'للأطفال المرضى';
      return _Resp(_kb['للأطفال المرضى'] ?? 'عذراً', _ctxReplies('special'));
    }
    if (n.contains('مرضع') || n.contains('ترضع') || n.contains('يرضع')) {
      _ctx.lastTopic = 'الأم المرضعة';
      return _Resp(_kb['الأم المرضعة'] ?? 'عذراً', _ctxReplies('special'));
    }
    if (n.contains('حامل') || n.contains('حوامل') || n.contains('حمل')) {
      _ctx.lastTopic = 'الحوامل';
      return _Resp(_kb['الحوامل'] ?? 'عذراً', _ctxReplies('special'));
    }
    if (n.contains('hiv') || n.contains('ايدز') || n.contains('المناعة المكتسبة')) {
      _ctx.lastTopic = 'HIV';
      return _Resp(_kb['تطعيم الأطفال المصابين بـ HIV'] ?? 'عذراً', _ctxReplies('special'));
    }
    if (n.contains('سرطان') || n.contains('اورام') || n.contains('كيماوي')) {
      _ctx.lastTopic = 'سرطان';
      return _Resp(_kb['الأطفال المصابين بالسرطان'] ?? 'عذراً', _ctxReplies('special'));
    }
    if (n.contains('سكر') || n.contains('انسولين') || n.contains('ديابت')) {
      _ctx.lastTopic = 'سكري';
      return _Resp(_kb['الأطفال المصابين بالسكري'] ?? 'عذراً', _ctxReplies('special'));
    }
    if (n.contains('قلب') || n.contains('cardiac') || n.contains('قلب خلقي')) {
      _ctx.lastTopic = 'قلب';
      return _Resp(_kb['الأطفال المصابين بالقلب'] ?? '🟡 عيوب القلب: جميع التطعيمات آمنة ومهمة!', _ctxReplies('special'));
    }
    if (n.contains('ربو') || n.contains('asma')) {
      _ctx.lastTopic = 'ربو';
      return _Resp('🟡 الأطفال المصابون بالربو:\n\n✅ جميع التطعيمات آمنة ومهمة!\n• الربو لا يمنع أي تطعيم\n• بل التطعيم يحميهم من عدوى تزيد الربو\n\n💡 استشر طبيب الربو', _ctxReplies('special'));
    }
    if (n.contains('صرع') || n.contains('نوبات')) {
      _ctx.lastTopic = 'صرع';
      return _Resp('🟡 الأطفال المصابون بالصرع:\n\n✅ معظم التطعيمات آمنة\n⚠️ استشر طبيب الصرع قبل التطعيم\n• بعض الأدوية قد تؤثر على فعالية التطعيم\n\n💡 التطعيم مهم لحمايتهم من عدوى تزيد النوبات', _ctxReplies('special'));
    }
    if (n.contains('تغذيه سيئه') || n.contains('نحيف') || n.contains('وزن قليل') || n.contains('سوء تغذيه')) {
      _ctx.lastTopic = 'سوء التغذية والتطعيم';
      return _Resp(_kb['سوء التغذية والتطعيم'] ?? '', _ctxReplies('special'));
    }
    return _Resp('👶 حالات خاصة:', [
      const QuickReply(text: 'مبتسرين', emoji: '👶'), const QuickReply(text: 'مرضى', emoji: '🤒'),
      const QuickReply(text: 'حوامل', emoji: '🤰'), const QuickReply(text: 'HIV', emoji: '🔴'),
      const QuickReply(text: 'سكر', emoji: '🟡'), const QuickReply(text: 'قلب', emoji: '❤️'),
      const QuickReply(text: 'ربو', emoji: '🫁'),
    ]);
  }

  _Resp _handleVaccineList() {
    final schedule = VaccinationService().getFullSchedule();
    final buf = StringBuffer('💉 جدول التطعيمات الكامل:\n\n');
    for (final e in schedule.entries) {
      buf.writeln('📍 ${e.key}:');
      for (final v in e.value) buf.writeln('  ${v.iconEmoji} ${v.nameAr}');
      buf.writeln('');
    }
    buf.writeln('📊 المجموع: ${VaccinationService.allVaccines.length} تطعيم ضد 11 مرض\n💡 اكتب عمر طفلك لمعرفة تطعيماته!');
    _ctx.lastTopic = 'جدول التطعيم';
    return _Resp(buf.toString(), [const QuickReply(text: 'عمره 6 أشهر', emoji: '📅'), const QuickReply(text: 'وش الآثار؟', emoji: '⚠️')]);
  }

  _Resp _handleScheduleQuery(String n) {
    final age = SmartNLP.extractAge(n);
    if (age != null) return _handleAge(n);
    return _handleVaccineList();
  }

  _Resp _handleDose(String n) {
    final v = SmartNLP.detectVaccineMention(n);
    if (v != null) {
      final d = {
        'bcg': '🔴 BCG: جرعة واحدة عند الولادة\n📍 الذراع الأيسر',
        'opv': '🟢 OPV: 6 جرعات\n• OPV0: الولادة\n• OPV1: 6 أسابيع\n• OPV2: 10 أسابيع\n• OPV3: 14 أسبوع\n• OPV4: 9 أشهر\n• OPV5: 18 شهر',
        'ipv': '🟢 IPV: جرعة واحدة (عمر 14 أسبوع)\n📍 الفخذ الأيسر',
        'penta': '🟡 الخماسي: 3 جرعات\n• 6 أسابيع\n• 10 أسابيع\n• 14 أسبوع\n📍 الفخذ الأيسر',
        'pcv': '🟣 PCV: 3 جرعات\n• 6 أسابيع\n• 10 أسابيع\n• 14 أسبوع\n📍 الفخذ الأيسر',
        'rota': '🔵 الروتا: 2 جرعتين\n• 6 أسابيع\n• 10 أسابيع\n📍 فموي (قطرات)',
        'mr': '🔴 MR: 3 جرعات\n• 9 أشهر (MR1)\n• 18 شهر (MR2)\n• 6 سنوات (المدرسة)\n📍 الذراع الأيمن',
        'td': '👩 Td للحوامل: 5 جرعات\n• Td1-Td2: فاصل 4 أسابيع\n• Td2-Td3: فاصل 6 أشهر\n• Td3-Td4: فاصل سنة\n• Td4-Td5: فاصل سنة',
        'td_girls': '👧 Td للبنات: جرعة واحدة (عمر 12 سنة)\n📍 الذراع الأيسر',
        'vitA': '🌟 فيتامين أ: 4 جرعات\n• 6 أشهر: 100,000 و.د (زرقاء)\n• 12 شهر: 200,000 و.د (حمراء)\n• 18 شهر: 200,000 و.د (حمراء)\n• 6 سنوات: 200,000 و.د (حمراء)',
      };
      _ctx.lastVaccine = v;
      _ctx.lastTopic = 'كم جرعة';
      return _Resp(d[v] ?? '📊 عدد الجرعات يختلف حسب التطعيم.', _ctxReplies('dose'));
    }
    return _Resp(_kb['كم جرعة'] ?? '📊 كم جرعة أي تطعيم بالضبط؟', _ctxReplies('dose'));
  }

  static final Map<String, List<String>> _vaccineIdMapping = {
    'bcg': ['bcg'],
    'opv': ['opv0', 'opv1', 'opv2', 'opv3', 'opv4', 'opv5'],
    'ipv': ['ipv'],
    'penta': ['pentavalent1', 'pentavalent2', 'pentavalent3'],
    'pcv': ['pcv1', 'pcv2', 'pcv3'],
    'rota': ['rv1', 'rv2'],
    'mr': ['mr1', 'mr2', 'mr_school'],
    'td': ['td_girls'],
    'td_girls': ['td_girls'],
    'vitA': ['vitA_1', 'vitA_2', 'vitA_3', 'vitA_school'],
    'hepb0': ['hepb0'],
    'dtp': ['dtp_booster', 'dtp_school'],
  };

  List<Vaccine> _getVaccinesById(String genericId) {
    final mapping = _vaccineIdMapping[genericId];
    if (mapping != null) {
      return VaccinationService.allVaccines.where((v) => mapping.contains(v.id)).toList();
    }
    return VaccinationService.allVaccines.where((v) => v.id == genericId).toList();
  }

  _Resp _handleVaccineTypes(String n) {
    final v = SmartNLP.detectVaccineMention(n);
    if (v != null) {
      final matches = _getVaccinesById(v);
      if (matches.isNotEmpty) {
        final match = matches.first;
        _ctx.lastVaccine = v;
        _ctx.lastTopic = v;
        return _Resp('${match.iconEmoji} ${match.nameAr}\n\n📝 ${match.description}\n💉 ${match.doseNumber}\n📍 ${match.site}', _ctxReplies(v));
      }
    }
    _ctx.lastTopic = 'أنواع اللقاحات';
    return _Resp(_kb['ما هي اللقاحات'] ?? 'عذراً', [const QuickReply(text: 'كيف تعمل؟', emoji: '🔬'), const QuickReply(text: 'هل آمنة؟', emoji: '✅')]);
  }

  _Resp _handleDiseases(String n) {
    final d = SmartNLP.detectDiseaseMention(n);
    if (d != null) {
      final dm = {'measles':'الحصبة','polio':'شلل الأطفال المرض','tetanus':'الكزاز','diphtheria':'الخناق','pertussus':'السعال الديبي','hepatitis':'التهاب الكبد ب','pneumonia':'المكورات الرئوية','rotavirus':'الروتا المرض','meningitis':'التهاب الأغشية المخية','rubella':'الحصبة الألمانية','tuberculosis':'مرض السل'};
      final t = dm[d];
      if (t != null && _kb.containsKey(t)) { _ctx.lastTopic = t; return _Resp(_kb[t] ?? '', _ctxReplies('disease')); }
    }
    _ctx.lastTopic = 'الأمراض';
    return _Resp('🦠 الأمراض التي تحمي منها التطعيمات:\n\n1. السل\n2. شلل الأطفال\n3. الخناق\n4. الكزاز\n5. السعال الديبي\n6. التهاب الكبد B\n7. المستدمية النزلية\n8. الحصبة\n9. الحصبة الألمانية\n10. المكورات الرئوية\n11. الروتا فيروس\n\n💡 اسألني عن أي مرض بالتفصيل!', [const QuickReply(text: 'الحصبة', emoji: '🦠'), const QuickReply(text: 'شلل الأطفال', emoji: '🦠'), const QuickReply(text: 'الكزاز', emoji: '🦠')]);
  }

  _Resp _handleNutrition(String n) {
    if (n.contains('رضاع') || n.contains('يرضع') || n.contains('حليب') || n.contains('ثدي')) {
      _ctx.lastTopic = 'الرضاعة والتطعيم';
      return _Resp(_kb['الرضاعة والتطعيم'] ?? '', _ctxReplies('nutrition'));
    }
    if (n.contains('فيتامين')) {
      _ctx.lastTopic = 'فيتامين أ';
      return _Resp(_kb['فيتامين أ'] ?? '', _ctxReplies('nutrition'));
    }
    _ctx.lastTopic = 'تغذية الطفل والتطعيم';
    return _Resp(_kb['تغذية الطفل والتطعيم'] ?? '', _ctxReplies('nutrition'));
  }

  _Resp _handleColdChain(String n) {
    if (n.contains('vvm')) { _ctx.lastTopic = 'VVM'; return _Resp(_kb['VVM'] ?? '', _ctxReplies('cold_chain')); }
    if (n.contains('محقن') || n.contains('ابر') || n.contains('محاقن')) { _ctx.lastTopic = 'المحاقن'; return _Resp(_kb['المحاقن'] ?? '', _ctxReplies('cold_chain')); }
    _ctx.lastTopic = 'سلسلة التبريد';
    return _Resp(_kb['سلسلة التبريد'] ?? '', _ctxReplies('cold_chain'));
  }

  _Resp _handleLocation() {
    _ctx.lastTopic = 'أين التطعيم';
    return _Resp(_kb['أين التطعيم'] ?? '', [const QuickReply(text: 'هل مجاني؟', emoji: '💰'), const QuickReply(text: 'متى التطعيم؟', emoji: '📅')]);
  }

  _Resp _handleCost() {
    _ctx.lastTopic = 'مجاناً';
    return _Resp(_kb['مجاناً'] ?? '', [const QuickReply(text: 'وين أطعم؟', emoji: '📍'), const QuickReply(text: 'متى التطعيم؟', emoji: '📅')]);
  }

  _Resp _handleCampaigns() {
    _ctx.lastTopic = 'حملات التطعيم';
    return _Resp(_kb['حملات التطعيم'] ?? '', [const QuickReply(text: 'وين أطعم؟', emoji: '📍'), const QuickReply(text: 'هل مجاني؟', emoji: '💰')]);
  }

  _Resp _handleTravel() {
    _ctx.lastTopic = 'السفر والتطعيم';
    return _Resp(_kb['السفر والتطعيم'] ?? '', [const QuickReply(text: 'هل مجاني؟', emoji: '💰'), const QuickReply(text: 'وش التطعيمات؟', emoji: '💉')]);
  }

  _Resp _handleHistory() {
    _ctx.lastTopic = 'تاريخ التحصين في اليمن';
    return _Resp(_kb['تاريخ التحصين في اليمن'] ?? '', _welcomeReplies());
  }

  _Resp _handleBenefits() {
    _ctx.lastTopic = 'فوائد اقتصادية';
    return _Resp(_kb['فوائد اقتصادية'] ?? '', _welcomeReplies());
  }

  _Resp _handleSupervision(String n) {
    _ctx.lastTopic = 'الأشراف الداعم';
    return _handleSupportiveSupervision(n);
  }

  _Resp _handleManagement(String n) {
    _ctx.lastTopic = 'إدارة المستوى الوسيط';
    return _handleIntermediateManagement(n);
  }

  _Resp _handleReminder(String n) {
    if (_ctx.child.hasBasicInfo) {
      final m = _ctx.child.ageMonths!;
      final upcoming = VaccinationService().getUpcomingVaccines(_ctx.child.ageWeeks ?? 0, m);
      if (upcoming.isNotEmpty) {
        final buf = StringBuffer('⏰ تذكير بالتطعيمات القادمة لطفلك (${_ctx.child.ageDisplay}):\n\n');
        for (final v in upcoming) {
          buf.writeln('📋 ${v.iconEmoji} ${v.nameAr} — ${v.doseNumber}');
        }
        buf.writeln('\n💡 اذهب للمركز الصحي الأقرب في الموعد المحدد!');
        return _Resp(buf.toString(), [const QuickReply(text: 'وين أطعم؟', emoji: '📍'), const QuickReply(text: 'هل مجاني؟', emoji: '💰')]);
      }
      return _Resp('✅ لا توجد تطعيمات قريبة لطفلك في العمر الحالي (${_ctx.child.ageDisplay}). كل شيء مكتمل!', _welcomeReplies());
    }
    return _Resp('📅 عشان أذكّرك بالتطعيمات، قولي عمر طفلك أولاً.', [
      const QuickReply(text: 'عمره 3 شهور', emoji: '📅'), const QuickReply(text: 'عمره 6 أشهر', emoji: '📅'), const QuickReply(text: 'عمره 9 شهور', emoji: '📅'),
    ]);
  }

  _Resp _handleFeedback(String n) {
    if (RegExp(r'ممتاز|كويس|حلو|good|رائع|جميل|helpful|مفيد').hasMatch(n)) {
      return _Resp(
        '🙏 شكراً لك! سعيد إني قدرت أساعدك.\n\n'
        '💡 لا تنسَ تطعيمات طفلك في موعدها!\n'
        '🇾🇪 صحة أطفالنا أولويتنا 💉',
        _welcomeReplies(),
      );
    }
    return _Resp(
      '📝 أعتذر إذا كان في شيء ما عجبك.\n\n'
      '💡 هدفي إني أكون أفضل — تقدر تكلمني عن أي استفسار وأحاول أجاوبك بشكل أفضل.',
      _welcomeReplies(),
    );
  }

  _Resp _handleGreeting(String n) {
    final greetings = [
      '🌟 هلا وغلا! مرحباً بك في مستشار التحصين 🇾🇪💉',
      '😊 يا هلا! كيف أقدر أساعدك اليوم؟',
      '👋 أهلاً! أنا هنا للإجابة عن كل أسئلة التحصين!',
      '🕌 السلام عليكم! مرحباً بك!',
    ];
    final g = greetings[_ctx.turnCount % greetings.length];

    String contextHint = '';
    if (_ctx.child.hasBasicInfo) {
      contextHint = '\n\n📌 تذكر: عمر طفلك ${_ctx.child.ageDisplay}';
    }

    return _Resp(
      '$g$contextHint\n\n💡 اسألني عن أي شيء:\n• تطعيمات طفلك\n• الآثار الجانبية\n• أمراض ووقاية\n• حالات خاصة\n• الأشراف الداعم\n• الإدارة الوسيطة والتخطيط',
      _welcomeReplies(),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  المعالجات المتقدمة — الجديدة المضافة
  // ══════════════════════════════════════════════════════════════

  _Resp _handleIntermediateManagement(String n) {
    _ctx.lastTopic = 'إدارة المستوى الوسيط';

    // عناوين فرعية
    if (n.contains('مؤشرات') || n.contains('اداء') || n.contains('kpi')) {
      _ctx.lastTopic = 'مؤشرات الأداء';
      return _Resp(
        _kb['مؤشرات الأداء'] ?? '📊 مؤشرات الأداء الرئيسية (KPIs):\n\n'
        '📌 مؤشرات التغطية:\n'
        '• نسبة التغطية بالتطعيمات الروتينية\n'
        '• نسبة تغطية DTP3 (مؤشر عالمي)\n'
        '• نسبة تغطية MCV1 و MCV2\n\n'
        '📌 مؤشرات الجودة:\n'
        '• نسبة التسرب (Dropout rate)\n'
        '• نسبة إبلاغ AEFI\n'
        '• جودة البيانات في DHIS2\n\n'
        '📌 مؤشرات اللوجستيات:\n'
        '• نسبة نفاد المخزون\n'
        '• سلامة سلسلة التبريد\n\n'
        '💡 استخدم DHIS2 لمتابعة المؤشرات!',
        [const QuickReply(text: 'DHIS2', emoji: '📊'), const QuickReply(text: 'تغطية', emoji: '📈'), const QuickReply(text: 'تسرب', emoji: '📉')],
      );
    }

    if (n.contains('مدير مكتب') || n.contains('مدير محافظه') || n.contains('مدير محافظة')) {
      _ctx.lastTopic = 'دور مدير المكتب';
      return _Resp(
        _kb['دور مدير المكتب'] ?? '🏢 دور مدير مكتب الصحة بالمحافظة:\n\n'
        '1️⃣ التخطيط والتنسيق:\n'
        '   • إعداد الخطة التشغيلية السنوية\n'
        '   • تنسيق الأنشطة بين المديريات\n'
        '   • توزيع الموارد البشرية والمالية\n\n'
        '2️⃣ المتابعة والتقييم:\n'
        '   • مراجعة بيانات HMIS/DHIS2\n'
        '   • تحليل مؤشرات الأداء شهرياً\n'
        '   • متابعة التغطيات والتسرب\n\n'
        '3️⃣ الإشراف الداعم:\n'
        '   • توجيه الزيارات الإشرافية\n'
        '   • متابعة تنفيذ التوصيات\n'
        '   • تدريب العاملين الصحيين\n\n'
        '4️⃣ إدارة المخزون:\n'
        '   • ضمان توفر اللقاحات\n'
        '   • مراقبة سلسلة التبريد\n'
        '   • تنظيم طلبات اللقاحات\n\n'
        '5️⃣ التواصل والتنسيق:\n'
        '   • مع الشركاء الصحين\n'
        '   • مع المجتمع المحلي\n'
        '   • مع وزارة الصحة',
        [const QuickReply(text: 'مؤشرات الأداء', emoji: '📊'), const QuickReply(text: 'إشراف داعم', emoji: '🔍'), const QuickReply(text: 'تخطيط دقيق', emoji: '📋')],
      );
    }

    return _Resp(
      _kb['إدارة المستوى الوسيط'] ?? '🏢 إدارة المستوى الوسيط في التحصين:\n\n'
      '📌 التعريف:\n'
      'المستوى الوسيط هو مكتب الصحة بالمحافظة، ويلعب دور المحور بين المستوى المركزي والمديريات.\n\n'
      '📋 المهام الأساسية:\n'
      '1. التخطيط الدقيق (Microplanning)\n'
      '2. الإشراف الداعم على المديريات\n'
      '3. متابعة مؤشرات الأداء\n'
      '4. إدارة المخزون واللوجستيات\n'
      '5. رفع التقارير عبر HMIS/DHIS2\n'
      '6. التنسيق مع الشركاء\n'
      '7. تدريب وبناء قدرات العاملين\n'
      '8. تنظيم حملات التحصين التكميلية\n\n'
      '💡 مدير المكتب هو المحرك الرئيسي لبرنامج التحصين!',
      [const QuickReply(text: 'مؤشرات الأداء', emoji: '📊'), const QuickReply(text: 'إشراف داعم', emoji: '🔍'), const QuickReply(text: 'تخطيط دقيق', emoji: '📋'),
       const QuickReply(text: 'DHIS2', emoji: '💻'), const QuickReply(text: 'سلسلة التبريد', emoji: '❄️')],
    );
  }

  _Resp _handleSupportiveSupervision(String n) {
    _ctx.lastTopic = 'الأشراف الداعم';

    if (n.contains('زياره') || n.contains('زيارة') || n.contains('checklist')) {
      _ctx.lastTopic = 'الزيارة الإشرافية';
      return _Resp(
        _kb['الزيارة الإشرافية'] ?? '📋 الزيارة الإشرافية الداعمة:\n\n'
        '📌 قبل الزيارة:\n'
        '• مراجعة بيانات DHIS2 للمرفق\n'
        '• مراجعة توصيات الزيارة السابقة\n'
        '• تحديد أولويات الزيارة\n\n'
        '📌 أثناء الزيارة:\n'
        '• مراجعة سجلات التحصين\n'
        '• فحص سلسلة التبريد\n'
        '• مراقبة جلسة تحصين\n'
        '• مقابلة العاملين الصحيين\n'
        '• التحقق من جودة البيانات\n\n'
        '📌 بعد الزيارة:\n'
        '• كتابة التقرير والتوصيات\n'
        '• متابعة تنفيذ التوصيات\n'
        '• تحديد موعد الزيارة القادمة',
        [const QuickReply(text: 'إدارة المستوى الوسيط', emoji: '🏢'), const QuickReply(text: 'جودة البيانات', emoji: '📊')],
      );
    }

    return _Resp(
      _kb['الأشراف الداعم للتحصين'] ?? _kb['الأشراف الداعم'] ?? '🔍 الإشراف الداعم للتحصين:\n\n'
      '📌 التعريف:\n'
      'عملية منظمة لتقييم وتحسين أداء خدمات التحصين من خلال الزيارات الميدانية والتغذية الراجعة.\n\n'
      '📋 المكونات الأساسية:\n'
      '1️⃣ التقييم: مراجعة الأداء والعمليات\n'
      '2️⃣ التغذية الراجعة: نقاط القوة والضعف\n'
      '3️⃣ حل المشكلات: العمل مع الفريق لإيجاد حلول\n'
      '4️⃣ التدريب أثناء العمل (OJT)\n'
      '5️⃣ المتابعة: التأكد من تنفيذ التوصيات\n\n'
      '📌 مجالات الإشراف:\n'
      '• سجلات التحصين والتغطيات\n'
      '• سلسلة التبريد وتخزين اللقاحات\n'
      '• سلامة الحقن والتخلص من النفايات\n'
      '• جودة البيانات والإبلاغ\n'
      '• جلسات التحصين وتخطيطها\n'
      '• التواصل المجتمعي\n\n'
      '💡 الإشراف الداعم = إشراف + تدريب + دعم!',
      [const QuickReply(text: 'إدارة المستوى الوسيط', emoji: '🏢'), const QuickReply(text: 'مؤشرات الأداء', emoji: '📊'), const QuickReply(text: 'سلسلة التبريد', emoji: '❄️'),
       const QuickReply(text: 'جودة البيانات', emoji: '📈'), const QuickReply(text: 'تدريب', emoji: '🎓')],
    );
  }

  _Resp _handleHMISReporting(String n) {
    _ctx.lastTopic = 'HMIS/DHIS2';
    return _Resp(
      _kb['HMIS/DHIS2'] ?? '📊 نظام المعلومات الصحية (HMIS/DHIS2):\n\n'
      '📌 التعريف:\n'
      'DHIS2 هو نظام معلومات صحي رقمي يستخدم لجمع وتحليل بيانات التحصين.\n\n'
      '📋 البيانات المسجلة:\n'
      '• أعداد المطعمين حسب اللقاح والعمر\n'
      '• أعداد المستهدفين\n'
      '• بيانات المخزون\n'
      '• بيانات سلسلة التبريد\n'
      '• حالات AEFI\n\n'
      '📌 التقارير الأساسية:\n'
      '• التغطيات الشهرية\n'
      '• نسب التسرب\n'
      '• مؤشرات الأداء\n'
      '• خريطة التغطيات الجغرافية\n\n'
      '💡 DHIS2 يساعد في اتخاذ القرارات المبنية على الأدلة!',
      [const QuickReply(text: 'مؤشرات الأداء', emoji: '📊'), const QuickReply(text: 'تغطية', emoji: '📈'), const QuickReply(text: 'جودة البيانات', emoji: '✅')],
    );
  }

  _Resp _handleMicroplanning(String n) {
    _ctx.lastTopic = 'التخطيط الدقيق';
    return _Resp(
      _kb['التخطيط الدقيق'] ?? '📋 التخطيط الدقيق (Microplanning):\n\n'
      '📌 التعريف:\n'
      'عملية تخطيط مفصلة على مستوى المديرية لضمان وصول خدمات التحصين لكل المجتمعات.\n\n'
      '📋 المكونات:\n'
      '1️⃣ حصر المجتمعات المستهدفة\n'
      '2️⃣ تحديد مواقع الجلسات\n'
      '3️⃣ جدولة الجلسات (زمانياً ومكانياً)\n'
      '4️⃣ تقدير الاحتياج من اللقاحات\n'
      '5️⃣ تخصيص الموارد البشرية\n'
      '6️⃣ خطة النقل واللوجستيات\n\n'
      '📌 أنواع الجلسات:\n'
      '• ثابتة: في المرفق الصحي\n'
      '• متنقلة: في المجتمعات البعيدة\n'
      '• خارج المرفق: في الأسواق والمدارس\n\n'
      '💡 التخطيط الدقيق يضمن عدم إهمال أي مجتمع!',
      [const QuickReply(text: 'تخطيط جلسات', emoji: '📅'), const QuickReply(text: 'مخزون', emoji: '📦'), const QuickReply(text: 'إدارة المستوى الوسيط', emoji: '🏢')],
    );
  }

  _Resp _handleOutbreakResponse(String n) {
    _ctx.lastTopic = 'الاستجابة للأوبئة';
    return _Resp(
      _kb['الاستجابة للأوبئة'] ?? '🦠 الاستجابة للأوبئة والفاشيات:\n\n'
      '📌 خطوات الاستجابة:\n'
      '1️⃣ التأكد من التشخيص والإبلاغ\n'
      '2️⃣ تحديد حجم الفاشية ونطاقها\n'
      '3️⃣ تفعيل فريق الاستجابة السريعة\n'
      '4️⃣ حملة تحصين استجابية\n'
      '5️⃣ تعزيز الرصد الوبائي\n'
      '6️⃣ التوعية المجتمعية\n\n'
      '📌 الأمراض المستهدفة:\n'
      '• الحصبة • شلل الأطفال\n'
      '• الكزاز الوليدي • الدفتيريا\n'
      '• السعال الديكي\n\n'
      '⚠️ الفاشية تتطلب استجابة سريعة خلال 72 ساعة!',
      [const QuickReply(text: 'ترصد وبائي', emoji: '🔬'), const QuickReply(text: 'حملات', emoji: '🚐'), const QuickReply(text: 'توعية', emoji: '📢')],
    );
  }

  _Resp _handleVaccineManagement(String n) {
    _ctx.lastTopic = 'إدارة اللقاحات';
    return _Resp(
      _kb['إدارة اللقاحات'] ?? '💉 إدارة اللقاحات:\n\n'
      '📌 المحاور الأساسية:\n'
      '1️⃣ الطلب والتوريد\n'
      '2️⃣ الاستلام والتخزين\n'
      '3️⃣ التوزيع على المديريات\n'
      '4️⃣ مراقبة المخزون\n'
      '5️⃣ إدارة النفايات والهدر\n\n'
      '💡 قاعدة: تطلب حسب الاستهلاك + احتياطي أمان',
      [const QuickReply(text: 'مخزون', emoji: '📦'), const QuickReply(text: 'سلسلة التبريد', emoji: '❄️'), const QuickReply(text: 'سياسة القارورة المفتوحة', emoji: '💊')],
    );
  }

  _Resp _handleAEFIReporting(String n) {
    _ctx.lastTopic = 'إبلاغ AEFI';
    return _Resp(
      _kb['إبلاغ AEFI'] ?? _kb['AEFI'] ?? '📊 الإبلاغ عن الآثار الجانبية (AEFI):\n\n'
      '📌 متى تُبلغ؟\n'
      '• أي حدث خطير بعد التطعيم\n'
      '• وفيات بعد التطعيم\n'
      '• حالات الحساسية الشديدة\n'
      '• التشنجات\n'
      '• أحداث تجميعية (أكثر من حالة)\n\n'
      '📋 كيف تُبلغ؟\n'
      '1. املأ استمارة AEFI\n'
      '2. أبلغ المركز الصحي فوراً\n'
      '3. أبلغ مديرية الصحة خلال 24 ساعة\n'
      '4. أرفع للتقصي الوطني\n\n'
      '⏰ الإبلاغ السريع ينقذ الأرواح!',
      [const QuickReply(text: 'آثار جانبية', emoji: '⚠️'), const QuickReply(text: 'طوارئ', emoji: '🚨'), const QuickReply(text: 'سلامة الحقن', emoji: '💉')],
    );
  }

  _Resp _handleCoverageMonitoring(String n) {
    _ctx.lastTopic = 'رصد التغطيات';
    return _Resp(
      _kb['رصد التغطيات'] ?? '📈 رصد تغطيات التحصين:\n\n'
      '📌 المؤشرات الأساسية:\n'
      '• تغطية BCG (الهدف ≥ 90%)\n'
      '• تغطية DTP3 (مؤشر عالمي، الهدف ≥ 90%)\n'
      '• تغطية MCV1 و MCV2 (الهدف ≥ 95%)\n'
      '• تغطية OPV3 + IPV\n'
      '• تغطية الروتا 2\n'
      '• تغطية PCV3\n\n'
      '📋 مصادر البيانات:\n'
      '• تقارير HMIS/DHIS2 الشهرية\n'
      '• مسوحات التغطيات\n'
      '• مراجعة السجلات\n\n'
      '💡 رصد التغطيات أسبوعياً يكشف الفجوات مبكراً!',
      [const QuickReply(text: 'تسرب', emoji: '📉'), const QuickReply(text: 'DHIS2', emoji: '💻'), const QuickReply(text: 'مؤشرات الأداء', emoji: '📊')],
    );
  }

  _Resp _handleSchoolImmunization(String n) {
    _ctx.lastTopic = 'تحصين المدارس';
    return _Resp(
      _kb['تحصين المدارس'] ?? '🏫 تحصين المدارس:\n\n'
      '📌 التطعيمات المدرسية:\n'
      '• DTP جرعة معززة (عمر 6 سنوات)\n'
      '• MR جرعة معززة (عمر 6 سنوات)\n'
      '• فيتامين أ (200,000 وحدة دولية)\n'
      '• Td للبنات (عمر 12 سنة)\n\n'
      '📋 خطوات التنفيذ:\n'
      '1. تنسيق مع إدارة التربية والتعليم\n'
      '2. إعلام أولياء الأمور\n'
      '3. تسجيل بيانات الطلاب\n'
      '4. إعطاء التطعيمات\n'
      '5. إبلاغ عن أي AEFI\n'
      '6. إدخال البيانات في DHIS2\n\n'
      '💡 التحصين المدرسي يكمل المناعة ويحمي المجتمع!',
      [const QuickReply(text: 'فيتامين أ', emoji: '🌟'), const QuickReply(text: 'آثار جانبية', emoji: '⚠️'), const QuickReply(text: 'تغطية', emoji: '📈')],
    );
  }

  _Resp _handleColdChainManagement(String n) {
    _ctx.lastTopic = 'إدارة سلسلة التبريد';
    return _Resp(
      _kb['إدارة سلسلة التبريد'] ?? '❄️ إدارة سلسلة التبريد:\n\n'
      '📌 العناصر الأساسية:\n'
      '1️⃣ ثلاجات التحصين (TZA/HZA/CZA)\n'
      '2️⃣ صناديق النقل المبردة\n'
      '3️⃣ حافظات اللقاح (Vaccine carriers)\n'
      '4️⃣ أكياس الثلج المبردة\n'
      '5️⃣ أجهزة مراقبة الحرارة\n'
      '6️⃣ مؤشرات VVM\n\n'
      '📋 درجات الحرارة:\n'
      '• اللقاحات: +2° إلى +8° مئوية\n'
      '• لا تجمد! التجميد يفسد اللقاح\n\n'
      '⚠️ مراقبة الحرارة مرتين يومياً!',
      [const QuickReply(text: 'VVM', emoji: '🔍'), const QuickReply(text: 'مخزون', emoji: '📦'), const QuickReply(text: 'إشراف داعم', emoji: '🔍')],
    );
  }

  _Resp _handleWasteManagement(String n) {
    _ctx.lastTopic = 'إدارة النفايات';
    return _Resp(
      _kb['إدارة النفايات'] ?? '🗑️ إدارة النفايات الحيوية:\n\n'
      '📌 أنواع النفايات:\n'
      '• محاقن مستعملة\n'
      '• إبر مستعملة\n'
      '• قوارير لقاح فارغة\n'
      '• قطن وصوف ملوث\n\n'
      '📋 التخلص الآمن:\n'
      '1. التخلص الفوري في حناديق الأمان\n'
      '2. لا تملأ حناديق الأمان أكثر من 3/4\n'
      '3. لا تعيد تغطية الإبر يدوياً\n'
      '4. الحرق أو الدفن في مواقع مخصصة\n\n'
      '⚠️ النفايات الحيوية خطر على الصحة العامة!',
      [const QuickReply(text: 'سلامة الحقن', emoji: '💉'), const QuickReply(text: 'المحاقن', emoji: '💉'), const QuickReply(text: 'إشراف داعم', emoji: '🔍')],
    );
  }

  _Resp _handleSessionPlanning(String n) {
    _ctx.lastTopic = 'تخطيط الجلسات';
    return _Resp(
      _kb['تخطيط الجلسات'] ?? '📅 تخطيط جلسات التحصين:\n\n'
      '📌 أنواع الجلسات:\n'
      '• ثابتة: في المرفق الصحي (يومية)\n'
      '• متنقلة: في المجتمعات البعيدة (أسبوعية/شهرية)\n'
      '• خارج المرفق: أسواق، مدارس، مساجد\n\n'
      '📋 عناصر التخطيط:\n'
      '1. تحديد المستهدفين\n'
      '2. تقدير الاحتياج من اللقاحات\n'
      '3. توفير المستلزمات\n'
      '4. جدولة الموعد والوقت\n'
      '5. إعلام المجتمع مسبقاً\n'
      '6. تسجيل البيانات\n\n'
      '💡 جلسة مخططة جيداً = تغطية أعلى!',
      [const QuickReply(text: 'تخطيط دقيق', emoji: '📋'), const QuickReply(text: 'مخزون', emoji: '📦'), const QuickReply(text: 'تعزيز الطلب', emoji: '📢')],
    );
  }

  _Resp _handleDemandGeneration(String n) {
    _ctx.lastTopic = 'تعزيز الطلب';
    return _Resp(
      _kb['تعزيز الطلب'] ?? '📢 تعزيز الطلب على التحصين:\n\n'
      '📌 الاستراتيجيات:\n'
      '1️⃣ التسويق الاجتماعي\n'
      '2️⃣ المشاركة المجتمعية\n'
      '3️⃣ رسائل صحية عبر وسائل الإعلام\n'
      '4️⃣ قادة المجتمع كسفراء\n'
      '5️⃣ زيارات منزلية\n'
      '6️⃣ رسائل نصية تذكيرية\n\n'
      '📋 الرسائل الأساسية:\n'
      '• التحصين آمن ومجاني\n'
      '• يحمي طفلك من أمراض خطيرة\n'
      '• لا تؤخر تطعيمات طفلك\n'
      '• أكمل جميع الجرعات\n\n'
      '💡 التوعية المستمرة تزيد التغطيات!',
      [const QuickReply(text: 'مشاركة مجتمعية', emoji: '👥'), const QuickReply(text: 'تسرب', emoji: '📉'), const QuickReply(text: 'تغطية', emoji: '📈')],
    );
  }

  _Resp _handleCommunityEngagement(String n) {
    _ctx.lastTopic = 'المشاركة المجتمعية';
    return _Resp(
      _kb['المشاركة المجتمعية'] ?? '👥 المشاركة المجتمعية في التحصين:\n\n'
      '📌 المبادئ:\n'
      '• إشراك المجتمع في التخطيط\n'
      '• الاستماع لاحتياجاتهم\n'
      '• بناء الثقة\n'
      '• العمل مع القادة المحليين\n\n'
      '📋 الأدوار:\n'
      '• القادة الدينيون: نشر الوعي\n'
      '• المعلمات: متابعة الأطفال\n'
      '• المتطوعون: زيارات منزلية\n'
      '• الأئمة: ذكر أهمية التحصين\n\n'
      '💡 المجتمع المشارك = تغطيات أعلى!',
      [const QuickReply(text: 'تعزيز الطلب', emoji: '📢'), const QuickReply(text: 'توعية', emoji: '📣'), const QuickReply(text: 'تخطيط دقيق', emoji: '📋')],
    );
  }

  _Resp _handleDataQuality(String n) {
    _ctx.lastTopic = 'جودة البيانات';
    return _Resp(
      _kb['جودة البيانات'] ?? '✅ جودة البيانات في التحصين:\n\n'
      '📌 أبعاد الجودة:\n'
      '1️⃣ الدقة: البيانات صحيحة\n'
      '2️⃣ الاكتمال: لا بيانات ناقصة\n'
      '3️⃣ التوقيت: إبلاغ في الوقت\n'
      '4️⃣ الاتساق: بيانات متوافقة\n\n'
      '📋 أدوات التحسين:\n'
      '• مراجعة البيانات قبل الإرسال\n'
      '• التحقق من التناسق\n'
      '• تدريب العاملين على التسجيل\n'
      '• الاستخدام المنتظم لـ DHIS2\n\n'
      '💡 بيانات جيدة = قرارات صحيحة!',
      [const QuickReply(text: 'DHIS2', emoji: '💻'), const QuickReply(text: 'مؤشرات الأداء', emoji: '📊'), const QuickReply(text: 'إشراف داعم', emoji: '🔍')],
    );
  }

  _Resp _handleStockManagement(String n) {
    _ctx.lastTopic = 'إدارة المخزون';
    return _Resp(
      _kb['إدارة المخزون'] ?? '📦 إدارة مخزون اللقاحات:\n\n'
      '📌 المبادئ:\n'
      '• الطلب حسب الاستهلاك الفعلي\n'
      '• احتياطي أمان: شهر واحد\n'
      '• جرد دوري شهري\n'
      '• FIFO: الأول وارد أول صادر\n\n'
      '📋 نقاط المراقبة:\n'
      '• أرصدة اللقاحات\n'
      '• تواريخ الصلاحية\n'
      '• نسبة الهدر\n'
      '• حالات النفاد\n\n'
      '⚠️ النفاد = أطفال بدون تطعيم!',
      [const QuickReply(text: 'سلسلة التبريد', emoji: '❄️'), const QuickReply(text: 'سياسة القارورة المفتوحة', emoji: '💊'), const QuickReply(text: 'تخطيط جلسات', emoji: '📅')],
    );
  }

  _Resp _handleDropOutAnalysis(String n) {
    _ctx.lastTopic = 'تحليل التسرب';
    return _Resp(
      _kb['تحليل التسرب'] ?? '📉 تحليل التسرب في التحصين:\n\n'
      '📌 التعريف:\n'
      'التسرب = الفرق بين من بدأ التطعيم ومن أتمه.\n\n'
      '📋 مؤشرات التسرب:\n'
      '• DTP1-DTP3: مؤشر تسرب عالمي\n'
      '• BCG-Measles: مؤشر شامل\n'
      '• MCV1-MCV2: تسرب جرعة الحصبة\n\n'
      '📌 أسباب التسرب:\n'
      '• بعد المسافة\n'
      '• نقص الوعي\n'
      '• الآثار الجانبية\n'
      '• نقص اللقاحات\n'
      '• التواريخ المفقودة\n\n'
      '💡 تتبع المتخلفين يقلل التسرب!',
      [const QuickReply(text: 'تتبع المتخلفين', emoji: '🔍'), const QuickReply(text: 'تغطية', emoji: '📈'), const QuickReply(text: 'تعزيز الطلب', emoji: '📢')],
    );
  }

  _Resp _handleDefaulterTracing(String n) {
    _ctx.lastTopic = 'تتبع المتخلفين';
    return _Resp(
      _kb['تتبع المتخلفين'] ?? '🔍 تتبع المتخلفين عن التحصين:\n\n'
      '📌 الخطوات:\n'
      '1️⃣ تحديد المتخلفين من السجلات\n'
      '2️⃣ إعداد قائمة بالأسماء\n'
      '3️⃣ زيارات منزلية أو اتصال هاتفي\n'
      '4️⃣ توعية أولياء الأمور\n'
      '5️⃣ إعطاء التطعيمات المتأخرة\n'
      '6️⃣ تحديث السجلات\n\n'
      '💡 المتخلفون = فجوة في المناعة المجتمعية!',
      [const QuickReply(text: 'تسرب', emoji: '📉'), const QuickReply(text: 'تغطية', emoji: '📈'), const QuickReply(text: 'تعزيز الطلب', emoji: '📢')],
    );
  }

  _Resp _handleOpenVialPolicy(String n) {
    _ctx.lastTopic = 'سياسة القارورة المفتوحة';
    return _Resp(
      _kb['سياسة القارورة المفتوحة'] ?? '💊 سياسة القارورة المفتوحة (Open Vial Policy):\n\n'
      '📌 اللقاحات التي يجوز إعادة استخدام القارورة المفتوحة:\n'
      '• OPV • IPV • PCV\n'
      '• Pentavalent • HepB • Rota\n\n'
      '📋 الشروط:\n'
      '1. القارورة لها VVM في المرحلة 1 أو 2\n'
      '2. لم يتجاوز الوقت المحدد (28 يوماً)\n'
      '3. محفوظة في درجة الحرارة الصحيحة\n'
      '4. لم يتلوث المحتوى\n\n'
      '🚫 لا يجوز إعادة استخدام:\n'
      '• BCG (لا VVM)\n'
      '• MR (لا VVM)\n'
      '• أي قارورة مشكوك في سلامتها\n\n'
      '💡 السياسة تقلل الهدر وتوفر اللقاحات!',
      [const QuickReply(text: 'VVM', emoji: '🔍'), const QuickReply(text: 'مخزون', emoji: '📦'), const QuickReply(text: 'سلسلة التبريد', emoji: '❄️')],
    );
  }

  _Resp _handleSurveillance(String n) {
    _ctx.lastTopic = 'الرصد الوبائي';
    return _Resp(
      _kb['الرصد الوبائي'] ?? '🔬 الرصد الوبائي في التحصين:\n\n'
      '📌 الأهداف:\n'
      '• كشف الأمراض المستهدفة مبكراً\n'
      '• مراقبة أنماط الأمراض\n'
      '• توجيه الاستجابة للأوبئة\n\n'
      '📋 الأمراض المرصودة:\n'
      '• شلل الأطفال (AFP)\n'
      '• الحصبة والحصبة الألمانية\n'
      '• الكزاز الوليدي\n'
      '• الدفتيريا\n'
      '• السعال الديكي\n\n'
      '📌 آليات الرصد:\n'
      '• رصد سلبي (المرضى يأتون للمرفق)\n'
      '• رصد نشط (زيارات ميدانية)\n'
      '• رصد مجتمعي (متطوعون)\n\n'
      '💡 الرصد المبكر يمنع الأوبئة!',
      [const QuickReply(text: 'استجابة للأوبئة', emoji: '🦠'), const QuickReply(text: 'DHIS2', emoji: '💻'), const QuickReply(text: 'إشراف داعم', emoji: '🔍')],
    );
  }

  _Resp _handleTraining(String n) {
    _ctx.lastTopic = 'التدريب';
    return _Resp(
      _kb['التدريب'] ?? '🎓 التدريب وبناء القدرات:\n\n'
      '📌 أنواع التدريب:\n'
      '1️⃣ تدريب أولي: للعاملين الجدد\n'
      '2️⃣ تدريب تنشيطي: سنوي\n'
      '3️⃣ تدريب أثناء العمل (OJT): خلال الزيارات الإشرافية\n'
      '4️⃣ تدريب متخصص: حملات، AEFI، سلسلة التبريد\n\n'
      '📋 المحاور:\n'
      '• مهارات التحصين\n'
      '• سلامة الحقن\n'
      '• إدارة سلسلة التبريد\n'
      '• التواصل المجتمعي\n'
      '• تسجيل البيانات\n\n'
      '💡 التدريب المستمر = أداء أفضل!',
      [const QuickReply(text: 'إشراف داعم', emoji: '🔍'), const QuickReply(text: 'سلامة الحقن', emoji: '💉'), const QuickReply(text: 'جودة البيانات', emoji: '📊')],
    );
  }

  _Resp _handleInjectionSafety(String n) {
    _ctx.lastTopic = 'سلامة الحقن';
    return _Resp(
      _kb['سلامة الحقن'] ?? '💉 سلامة الحقن:\n\n'
      '📌 المبادئ الأساسية:\n'
      '1️⃣ استخدام محاقن ذاتية التلف (ADS)\n'
      '2️⃣ عدم إعادة تغطية الإبر\n'
      '3️⃣ التخلص الفوري في حناديق الأمان\n'
      '4️⃣ عدم لمس الإبرة بعد الاستخدام\n\n'
      '📋 أنواع المحاقن:\n'
      '• ADS 0.05ml: BCG (داخل الأدمة)\n'
      '• ADS 0.5ml: معظم التطعيمات\n\n'
      '⚠️ المحاقن العادية ممنوعة في التحصين!\n\n'
      '💡 سلامة الحقن = حماية الطفل والعامل!',
      [const QuickReply(text: 'نفايات', emoji: '🗑️'), const QuickReply(text: 'المحاقن', emoji: '💉'), const QuickReply(text: 'إشراف داعم', emoji: '🔍')],
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  المعالجة الافتراضية
  // ══════════════════════════════════════════════════════════════

  /// بحث في قاعدة بيانات التقارير الحقيقية
  _Resp? _searchRealDataKB(String n) {
    // كلمات مفتاحية للبحث في بيانات التقارير
    final dataKeywords = [
      'حمله شلل', 'حملات شلل', 'تغطيه شلل', 'تغطية شلل',
      'ملخص حملات', 'احصائيات شلل', 'ارقام شلل',
      'افضل محافظه', 'اقوى محافظه', 'اضعف محافظه', 'محافظه تغطيه',
      'نشاط ايصال', 'ايصالي', 'جلسات', 'معدل جلسه',
      'تغطيه روتيني', 'تغطية روتين', 'خماسي تغطي', 'حصبه تغطي',
      'فجوه', 'فجوة', 'تسرب', 'drop',
      'kpi', 'مؤشرات اداء', 'مؤشرات',
      'تنب', 'توقع', '2026', '2025',
      'تعز', 'الحديده', 'المكلا', 'عدن', 'لحج', 'شبوه',
      'الضالع', 'المهره', 'مارب', 'ابين', 'حجه', 'البيضاء', 'الجوف',
      'سقطري', 'سيئون', 'حضرموت',
      'مقارنه', 'قارن', 'فرق بين',
      'محافظات متدنيه', 'محافظات ضعيفه', 'محافظات تحتاج',
      'توص', 'نصيح', 'اقتراح',
      'بيانات حقيقي', 'تقارير', 'ارقام رسمي',
    ];

    bool hasDataKeyword = false;
    for (final kw in dataKeywords) {
      if (n.contains(kw)) {
        hasDataKeyword = true;
        break;
      }
    }

    if (!hasDataKeyword) return null;

    // البحث في قاعدة المعرفة الحقيقية
    for (final entry in realDataKnowledgeBase.entries) {
      final keyNorm = SmartNLP.normalize(entry.key);
      // تطابق مباشر مع المفتاح
      for (final word in n.split(' ')) {
        if (word.length > 3 && keyNorm.contains(word)) {
          return _Resp(entry.value, [
            const QuickReply(text: 'توصيات ذكية', emoji: '💡'),
            const QuickReply(text: 'تنبؤات 2026', emoji: '🔮'),
            const QuickReply(text: 'تحليل الفجوات', emoji: '📊'),
          ]);
        }
      }
      // تطابق مع المحتوى
      final valNorm = SmartNLP.normalize(entry.value);
      int matchCount = 0;
      for (final word in n.split(' ')) {
        if (word.length > 3 && valNorm.contains(word)) matchCount++;
      }
      if (matchCount >= 2) {
        return _Resp(entry.value, [
          const QuickReply(text: 'توصيات ذكية', emoji: '💡'),
          const QuickReply(text: 'تنبؤات 2026', emoji: '🔮'),
          const QuickReply(text: 'تحليل الفجوات', emoji: '📊'),
        ]);
      }
    }

    return null;
  }

  _Resp _handleDefault(String n) {
    final temp = SmartNLP.extractTemperature(n);
    if (temp != null && temp > 38.5) {
      _ctx.child.mentionedSymptoms.add('حرارة');
      _ctx.lastTopic = 'حرارة بعد التطعيم';
      return _Resp(
        '🌡️ حرارة طفلك ${temp}° — ${temp >= 39.5 ? '⚠️ عالية!' : 'راقب الوضع'}\n\n${_kb['حرارة بعد التطعيم'] ?? ''}',
        [const QuickReply(text: 'متى أخاف؟', emoji: '🚨'), const QuickReply(text: 'متى أروح للطبيب؟', emoji: '🏥')],
      );
    }

    final age = SmartNLP.extractAge(n);
    if (age != null) return _handleAge(n);

    final words = n.split(' ').where((w) => w.length > 2).toList();
    for (final word in words) {
      for (final key in _kb.keys) {
        final kn = SmartNLP.normalize(key);
        if (kn.contains(word) && word.length > 3) {
          _ctx.lastTopic = key;
          return _Resp(_kb[key] ?? '', _ctxReplies(key));
        }
        final syns = SmartNLP.synonyms[word];
        if (syns != null) {
          for (final syn in syns) {
            for (final key in _kb.keys) {
              if (SmartNLP.normalize(key).contains(syn)) {
                _ctx.lastTopic = key;
                return _Resp(_kb[key] ?? '', _ctxReplies(key));
              }
            }
          }
        }
        for (final key in _kb.keys) {
          final val = SmartNLP.normalize(_kb[key] ?? '');
          if (val.contains(word) && word.length > 4) {
            _ctx.lastTopic = key;
            return _Resp(_kb[key] ?? '', _ctxReplies(key));
          }
        }
      }
    }

    if (_ctx.turnCount <= 1) {
      return _Resp(
        '🤖 أهلاً! أنا مستشار التحصين الذكي 🇾🇪\n\n'
        'أقدر أساعدك في كل شيء متعلق بالتحصين الصحي الموسع!\n\n'
        '💡 جرب تقولي:\n'
        '• "عمر طفلي 6 أشهر وش تطعيماته؟"\n'
        '• "وش الآثار الجانبية للخماسي؟"\n'
        '• "هل التطعيم يسبب أوتيزم؟"\n'
        '• "ولدي حرارته 39 وش أسوي؟"\n'
        '• "وش الإشراف الداعم؟"\n'
        '• "وش إدارة المستوى الوسيط؟"\n\n'
        'أو اختر من الاقتراحات 👇',
        _welcomeReplies(),
      );
    }

    if (_ctx.child.name != null && n.length < 15) {
      return _Resp(
        '💡 ${_ctx.child.name} - أنا هنا أساعدك!\n\n'
        'جرب تسألني:\n'
        '• "تطعيمات ${_ctx.child.name}？"\n'
        '• "وش آثار الخماسي？"\n'
        '• "متى أخاف عليه？"',
        _welcomeReplies(),
      );
    }

    if (_ctx.lastTopic.isNotEmpty) {
      return _Resp(
        '🤔 مش فاهم قصدك بالضبط. تبي تعرف أكثر عن "${_ctx.lastTopic}"؟\n\n'
        '💡 أو جرب تسأل بطريقة ثانية — أنا هنا أساعدك!\n\n'
        '📌 ممكن أجاوب على:\n• تطعيمات طفلك حسب عمره\n• الآثار الجانبية\n• أمراض ووقاية\n• حالات خاصة\n• الأشراف الداعم\n• الإدارة الوسيطة والتخطيط',
        _welcomeReplies(),
      );
    }

    return _Resp(
      '🤖 أقدر أساعدك في كل شيء متعلق بالتحصين!\n\n'
      '💡 جرب:\n'
      '• "عمر طفلي 6 أشهر وش تطعيماته؟"\n'
      '• "وش الآثار للخماسي؟"\n'
      '• "هل يسبب أوتيزم؟"\n'
      '• "ولدي حرارته 39 وش أسوي؟"\n'
      '• "الأشراف الداعم للتحصين"\n'
      '• "إدارة المستوى الوسيط"\n'
      '• "تخطيط دقيق"\n\n'
      'أو اختر من الاقتراحات 👇',
      _welcomeReplies(),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  أدوات مساعدة
  // ══════════════════════════════════════════════════════════════

  Map<String, String> get _kb => fullKnowledgeBase;

  String? _searchExt(String n) {
    // بحث في اختصارات قاعدة المعرفة (abbreviations)
    for (final e in abbreviations.entries) {
      if (n.contains(e.key.toLowerCase()) && _kb.containsKey(e.value)) return e.value;
    }
    for (final e in quickRepliesByTopic.entries) {
      if (e.key == 'default') continue;
      for (final reply in e.value) {
        final rn = SmartNLP.normalize(reply);
        if (n.contains(rn) || rn.contains(n)) {
          for (final k in _kb.keys) {
            if (SmartNLP.normalize(k).contains(rn) || rn.contains(SmartNLP.normalize(k))) return k;
          }
        }
      }
    }
    return null;
  }

  String? _searchKB(String n) {
    final inputKw = SmartNLP.extractKeywords(n);
    if (inputKw.isEmpty) return null;

    double best = 0; String? bestKey;
    for (final key in _kb.keys) {
      final kn = SmartNLP.normalize(key);
      if (n.contains(kn) || kn.contains(n)) return key;

      final keyKw = SmartNLP.extractKeywords(kn);
      int directHits = 0;
      for (final kw in keyKw) {
        for (final iw in inputKw) {
          if (iw == kw || iw.contains(kw) || kw.contains(iw)) { directHits++; break; }
        }
      }
      if (keyKw.isNotEmpty) {
        final directScore = directHits / keyKw.length;
        if (directScore > best) { best = directScore; bestKey = key; }
      }

      final score = SmartNLP.calculateRelevance(n, keyKw);
      if (score > best) { best = score; bestKey = key; }
    }
    return best > 0.15 ? bestKey : null;
  }

  /// بحث ذكي شامل — يستخدم fuzzyFind وتجميعات المواضيع
  String? _smartSearch(String n) {
    // 0. بحث في قواعد المعرفة المتقدمة والإدارية أولاً
    final advancedResult = _searchAdvancedKB(n);
    if (advancedResult != null) return advancedResult;

    // 1. بحث في الكلمات المفتاحية الموسّعة
    final ext = _searchExt(n);
    if (ext != null) return ext;

    // 2. بحث ضبابي في مفاتيح قاعدة المعرفة باستخدام fuzzyFind
    final kbKeys = _kb.keys.toList();
    final fuzzyKey = SmartNLP.fuzzyFind(n, kbKeys, threshold: 0.72);
    if (fuzzyKey != null) return fuzzyKey;

    // 3. بحث ضبابي جزئي بالكلمات باستخدام fuzzyFindAll
    final fuzzyAll = SmartNLP.fuzzyFindAll(n, kbKeys, threshold: 0.75);
    if (fuzzyAll.isNotEmpty) return fuzzyAll.first;

    // 4. بحث باستخدام تجميعات المواضيع (topic clusters)
    final words = n.split(' ').where((w) => w.length > 2).toList();
    for (final word in words) {
      final clusterMatch = SmartNLP.topicClusters[word];
      if (clusterMatch != null) {
        for (final related in clusterMatch) {
          final rn = SmartNLP.normalize(related);
          for (final key in _kb.keys) {
            final kn = SmartNLP.normalize(key);
            if (kn.contains(rn) || rn.contains(kn)) return key;
          }
        }
      }
      // توسيع باستخدام تجميعات المواضيع
      for (final cluster in SmartNLP.topicClusters.entries) {
        final cn = SmartNLP.normalize(cluster.key);
        if (cn == word || cluster.value.any((v) => SmartNLP.normalize(v) == word)) {
          final expanded = SmartNLP.expandWithClusters([word]);
          for (final term in expanded) {
            final tn = SmartNLP.normalize(term);
            for (final key in _kb.keys) {
              final kn = SmartNLP.normalize(key);
              if (kn.contains(tn) && tn.length > 2) return key;
            }
          }
        }
      }
    }

    // 5. بحث في قاعدة المعرفة بالكلمات الفردية
    final kbResult = _searchKB(n);
    if (kbResult != null) return kbResult;

    // 6. بحث عكسي
    for (final key in _kb.keys) {
      final kn = SmartNLP.normalize(key);
      final keyWords = kn.split(' ');
      for (final kw in keyWords) {
        if (kw.length > 3 && n.contains(kw)) return key;
      }
    }

    return null;
  }

  /// بحث في قواعد المعرفة المتقدمة والإدارية
  String? _searchAdvancedKB(String n) {
    final combinedAdvanced = <String, String>{
      ...advancedImmunizationKB,
      ...intermediateManagementKB,
    };

    double bestScore = 0.0;
    String? bestKey;

    for (final entry in combinedAdvanced.entries) {
      double score = 0.0;
      final keyNorm = SmartNLP.normalize(entry.key);
      final valueNorm = SmartNLP.normalize(entry.value);

      // تطابق مع المفتاح
      if (n.contains(keyNorm) || keyNorm.contains(n)) {
        score += 3.0;
      }

      // تطابق كلمات
      final nWords = n.split(' ').where((w) => w.length > 2).toList();
      final kWords = keyNorm.split(' ').where((w) => w.length > 2).toList();

      for (final nw in nWords) {
        for (final kw in kWords) {
          if (nw == kw) score += 2.0;
          if (nw.contains(kw) || kw.contains(nw)) score += 1.0;
        }
      }

      // تطابق ضبابي
      final fuzzy = SmartNLP.fuzzyFind(n, combinedAdvanced.keys.toList(), threshold: 0.65);
      if (fuzzy != null && fuzzy == entry.key) score += 1.5;

      if (score > bestScore) {
        bestScore = score;
        bestKey = entry.key;
      }
    }

    return bestScore >= 1.5 ? bestKey : null;
  }

  void _record(String intent, String msg) {
    _ctx.recordTurn(msg, '', intent);
  }

  List<QuickReply> _welcomeReplies() => const [
    QuickReply(text: 'وش تطعيمات طفلي؟', emoji: '💉'), QuickReply(text: 'وش الآثار الجانبية؟', emoji: '⚠️'),
    QuickReply(text: 'هل مجاني؟', emoji: '💰'), QuickReply(text: 'الفرق OPV و IPV؟', emoji: '🔵'),
    QuickReply(text: 'هل يسبب أوتيزم؟', emoji: '🚫'), QuickReply(text: 'ولدي مريض', emoji: '🤒'),
    QuickReply(text: 'الأشراف الداعم', emoji: '🔍'), QuickReply(text: 'إدارة المستوى الوسيط', emoji: '🏢'),
    QuickReply(text: 'تخطيط دقيق', emoji: '📋'), QuickReply(text: 'تحصين المدارس', emoji: '🏫'),
  ];

  List<QuickReply> _ctxReplies(String topic) {
    final m = {
      'bcg': [const QuickReply(text: 'وش الآثار؟', emoji: '⚠️'), const QuickReply(text: 'وش التندب؟', emoji: '🔴'), const QuickReply(text: 'كم جرعة؟', emoji: '🔢')],
      'opv': [const QuickReply(text: 'الفرق OPV و IPV؟', emoji: '🔵'), const QuickReply(text: 'هل اليمن خالية؟', emoji: '🎉'), const QuickReply(text: 'كم جرعة؟', emoji: '🔢')],
      'penta': [const QuickReply(text: 'وش الآثار؟', emoji: '⚠️'), const QuickReply(text: 'كم جرعة؟', emoji: '🔢'), const QuickReply(text: 'وش يحمي منه؟', emoji: '🛡️')],
      'mr': [const QuickReply(text: 'متى يُعطى؟', emoji: '📅'), const QuickReply(text: 'وش الآثار؟', emoji: '⚠️'), const QuickReply(text: 'وش الحصبة؟', emoji: '🦠')],
      'pcv': [const QuickReply(text: 'وش الآثار؟', emoji: '⚠️'), const QuickReply(text: 'وش المكورات الرئوية؟', emoji: '🦠')],
      'rota': [const QuickReply(text: 'وش الآثار؟', emoji: '⚠️'), const QuickReply(text: 'كم جرعة؟', emoji: '🔢')],
      'ipv': [const QuickReply(text: 'الفرق OPV و IPV؟', emoji: '🔵'), const QuickReply(text: 'وش الآثار؟', emoji: '⚠️')],
      'vitA': [const QuickReply(text: 'كم جرعة؟', emoji: '🔢'), const QuickReply(text: 'متى يُعطى؟', emoji: '📅')],
      'hepb0': [const QuickReply(text: 'وش الآثار؟', emoji: '⚠️'), const QuickReply(text: 'وش التهاب الكبد؟', emoji: '🦠')],
      'dtp': [const QuickReply(text: 'كم جرعة؟', emoji: '🔢'), const QuickReply(text: 'وش الآثار؟', emoji: '⚠️')],
      'pentavalent1': [const QuickReply(text: 'وش الآثار؟', emoji: '⚠️'), const QuickReply(text: 'كم جرعة؟', emoji: '🔢')],
      'pcv1': [const QuickReply(text: 'وش الآثار؟', emoji: '⚠️'), const QuickReply(text: 'وش المكورات الرئوية؟', emoji: '🦠')],
      'rv1': [const QuickReply(text: 'وش الآثار؟', emoji: '⚠️'), const QuickReply(text: 'كم جرعة؟', emoji: '🔢')],
      'mr1': [const QuickReply(text: 'متى الجرعة الثانية؟', emoji: '📅'), const QuickReply(text: 'وش الآثار؟', emoji: '⚠️')],
      'side_effects': [const QuickReply(text: 'حرارة بعد التطعيم', emoji: '🌡️'), const QuickReply(text: 'تشنجات', emoji: '🚨'), const QuickReply(text: 'متى أخاف؟', emoji: '⚠️')],
      'special': [const QuickReply(text: 'مبتسرين', emoji: '👶'), const QuickReply(text: 'مرضى', emoji: '🤒'), const QuickReply(text: 'سكر', emoji: '🟡'), const QuickReply(text: 'قلب', emoji: '❤️')],
      'myths': [const QuickReply(text: 'هل يسبب أوتيزم؟', emoji: '🚫'), const QuickReply(text: 'هل يسبب عقم؟', emoji: '🚫'), const QuickReply(text: 'هل مضرة؟', emoji: '🚫')],
      'nutrition': [const QuickReply(text: 'الرضاعة والتطعيم', emoji: '🍼'), const QuickReply(text: 'فيتامين أ', emoji: '🌟'), const QuickReply(text: 'التغذية', emoji: '🥗')],
      'cold_chain': [const QuickReply(text: 'وش هو VVM؟', emoji: '🔍'), const QuickReply(text: 'المحاقن', emoji: '💉'), const QuickReply(text: 'سلسلة التبريد', emoji: '❄️')],
      'disease': [const QuickReply(text: 'وش التطعيم؟', emoji: '💉'), const QuickReply(text: 'وش الآثار؟', emoji: '⚠️'), const QuickReply(text: 'كم جرعة؟', emoji: '🔢')],
      'supervision': [const QuickReply(text: 'إدارة المستوى الوسيط', emoji: '🏢'), const QuickReply(text: 'مؤشرات الأداء', emoji: '📊')],
      'management': [const QuickReply(text: 'الأشراف الداعم', emoji: '🔍'), const QuickReply(text: 'حملات التحصين', emoji: '🚐')],
      'dose': [const QuickReply(text: 'كم جرعة BCG؟', emoji: '🔴'), const QuickReply(text: 'كم جرعة OPV؟', emoji: '🟢'), const QuickReply(text: 'كم جرعة الخماسي؟', emoji: '🟡')],
      'vaccine_list': [const QuickReply(text: 'عمره 6 أشهر', emoji: '📅'), const QuickReply(text: 'وش الآثار؟', emoji: '⚠️'), const QuickReply(text: 'هل مجاني؟', emoji: '💰')],
    };
    return m[topic] ?? _welcomeReplies();
  }

  void _addBotMessage(String text, {List<QuickReply>? quickReplies}) {
    _messages.add(ChatMessage(id: _gid(), text: text, isBot: true, timestamp: DateTime.now(), quickReplies: quickReplies));
    notifyListeners();
  }

  String _gid() => '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(99999)}';

  void clearChat() {
    _messages.clear(); _ctx.reset();
    notifyListeners(); initialize();
  }
}

class _Resp {
  final String text;
  final List<QuickReply>? quickReplies;
  _Resp(this.text, this.quickReplies);
}
