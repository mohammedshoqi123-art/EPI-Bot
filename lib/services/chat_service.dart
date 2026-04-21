import 'dart:math';
import 'package:flutter/material.dart';
import '../models/vaccine_model.dart';
import 'vaccination_service.dart';
import 'knowledge_base.dart';
import 'smart_nlp.dart';
import 'context_manager.dart';

class ChatService extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  final ContextManager _ctx = ContextManager();

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
        '📜 تاريخ التحصين في اليمن\n\n'
        '💡 قولي عمر طفلك وأعطيك تطعيماته!',
        quickReplies: _welcomeReplies(),
      );
    }
  }

  void sendMessage(String text) {
    _messages.add(ChatMessage(id: _gid(), text: text, isBot: false, timestamp: DateTime.now()));
    notifyListeners();

    final ms = (200 + (text.length * 5)).clamp(200, 1200);
    Future.delayed(Duration(milliseconds: ms.toInt()), () {
      final resp = _process(text);
      _addBotMessage(resp.text, quickReplies: resp.quickReplies);
    });
  }

  // ══════════════════════════════════════════════════════════════
  //  المعالجة الرئيسية مع السياق العميق
  // ══════════════════════════════════════════════════════════════

  _Resp _process(String raw) {
    final norm = SmartNLP.normalize(raw);

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
      default: break;
    }

    // ═══ بحث ذكي شامل ═══
    final found = _smartSearch(norm);
    if (found != null) {
      _ctx.lastTopic = found;
      _record('general', norm);
      return _Resp(_kb[found] ?? 'عذراً، لا تتوفر معلومات حالياً', _ctxReplies(found));
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

    // --- الأشراف الداعم ---
    if (norm.contains('الاشراف الداعم') || norm.contains('الأشراف الداعم')) {
      return _handleSupervision(norm);
    }

    // --- إدارة المستوى الوسيط ---
    if (norm.contains('المستوى الوسيط') || norm.contains('اداره المستوى') || norm.contains('ادارة المستوى')) {
      return _handleManagement(norm);
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
  //  المعالجات المتقدمة
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

      // التطعيمات المتأخرة أولاً (أهم)
      if (overdue.isNotEmpty) {
        buf.writeln('\n⚠️ تطعيمات متأخرة (أعطها فوراً!):');
        for (final v in overdue) {
          buf.writeln('  ⚠️ ${v.iconEmoji} ${v.nameAr} — ${v.doseNumber}');
        }
      }

      // التطعيمات التي يجب أن تكون معطاة
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

      // نصائح ذكية
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
    // إجابات إيجابية
    if (RegExp(r'^(نعم|ايوه|ايه|اي|يب|ايه نعم|اوك|اوكي|ياب|أي نعم|أيوه|ايه اي)').hasMatch(n)) {
      if (_ctx.lastTopic.isNotEmpty && _kb.containsKey(_ctx.lastTopic)) {
        return _Resp(_kb[_ctx.lastTopic] ?? 'عذراً، لا تتوفر معلومات حالياً', _ctxReplies(_ctx.lastTopic));
      }
      return _Resp('تمام! ✅ اسألني أي تفاصيل إضافية.', _welcomeReplies());
    }

    // إجابات سلبية
    if (RegExp(r'^(لا|ما ابي|مو|ما يبي|ما ابغي|ما ابي اعطيه|لالا|لا شكرا)').hasMatch(n)) {
      return _Resp('👍 تمام! إذا احتجت شيء ثاني أنا هنا.', _welcomeReplies());
    }

    // طلب شرح أو تفصيل
    if (RegExp(r'اشرح|وضح|بالتفصيل|تفاصيل|شرح لي|زود|فهمني اكثر|فهمني|زيدني|عطيني تفاصيل|اكثر').hasMatch(n)) {
      if (_ctx.lastTopic.isNotEmpty && _kb.containsKey(_ctx.lastTopic)) {
        return _Resp(_kb[_ctx.lastTopic] ?? 'عذراً، لا تتوفر معلومات حالياً', _ctxReplies(_ctx.lastTopic));
      }
      // إذا مافي سياق، عرض المواضيع
      return _Resp('📚 وش تبي أشرح لك بالتفصيل؟ اختر من المواضيع:', _welcomeReplies());
    }

    // موافقة
    if (RegExp(r'^(طيب|تمام|زين|اوكي|اوك|تمام شكرا|كذا خلاص|شكرا|thanks|فاهمت|فهمت|واضح)').hasMatch(n)) {
      if (_ctx.lastTopic.isNotEmpty) {
        return _Resp('💡 تمام! تبي تعرف أكثر عن "${_ctx.lastTopic}"؟ أو عندك سؤال ثاني؟', _welcomeReplies());
      }
      return _Resp('🌟 تمام! أي سؤال ثاني أنا موجود!', _welcomeReplies());
    }

    // أسئلة "كم"
    if (n.startsWith('كم')) {
      return _Resp('📊 تحب تعرف كم جرعة؟ ولا كم عمر يبدأ فيه التطعيم؟', [
        const QuickReply(text: 'كم جرعة؟', emoji: '🔢'),
        const QuickReply(text: 'متى يبدأ؟', emoji: '📅'),
        const QuickReply(text: 'كم تطعيم بالمجموع؟', emoji: '💉'),
      ]);
    }

    // "ليش" / "ليه" / "لماذا"
    if (RegExp(r'^ليه|^ليش|^لماذا|^ليهذا|^لي ذا').hasMatch(n)) {
      if (_ctx.lastTopic.isNotEmpty && _kb.containsKey(_ctx.lastTopic)) {
        return _Resp(_kb[_ctx.lastTopic] ?? 'عذراً', _ctxReplies(_ctx.lastTopic));
      }
      return _Resp('🤔 ليش إيش بالضبط؟ اشرح لي أكثر وأجاوبك!', _welcomeReplies());
    }

    // "وش" / "ايش" في سياق
    if (RegExp(r'^وش|^ايش|^ماذا|^ايش').hasMatch(n)) {
      if (_ctx.lastTopic.isNotEmpty) {
        final topicReplies = _ctxReplies(_ctx.lastTopic);
        return _Resp('💡 وش بالضبط تبي تعرف عن "${_ctx.lastTopic}"؟', topicReplies);
      }
    }

    // سؤال عن "متى"
    if (RegExp(r'^متى').hasMatch(n)) {
      if (_ctx.lastTopic.contains('تطعيم') || _ctx.lastTopic.contains('لقاح') || _ctx.lastTopic.contains('عمر')) {
        return _Resp(_kb['متى أطعم'] ?? '', _ctxReplies('vaccine_list'));
      }
      return _Resp('🤔 متى إيش بالضبط؟ متى التطعيم؟ ولا متى أخاف؟', _welcomeReplies());
    }

    // سؤال عن "وين" / "اين"
    if (RegExp(r'^وين|^اين|^فين|^أين').hasMatch(n)) {
      return _handleLocation();
    }

    // وش / ايش standalone
    if (RegExp(r'^وش |^ايش |^ما هو|^ما هي').hasMatch(n)) {
      return _handleVaccineTypes(n);
    }

    return _Resp('🤔 ممكن توضح أكثر وش تقصد بالضبط؟\n\n💡 أنا أقدر أساعدك في:\n• تطعيمات طفلك حسب عمره\n• الآثار الجانبية\n• أمراض ووقاية\n• حالات خاصة\n• الأشراف الداعم', _welcomeReplies());
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

    // حرارة بدون رقم
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

    // أعراض عامة بدون تطعيم محدد
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
    // كشف حالة طوارئ مباشرة
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
    
    // كشف حرارة عالية
    final temp = SmartNLP.extractTemperature(n);
    if (temp != null && temp >= 39) {
      return _Resp(
        '🚨 حرارة طفلك ${temp}° عالية! ⚠️\n\n'
        '📋 افعل هذا فوراً:\n'
        '1. كمادات ماء دافئ على الجبه\n'
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
    // إذا فيه عمر محدد
    final age = SmartNLP.extractAge(n);
    if (age != null) return _handleAge(n);

    // جدول كامل
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

  /// خريطة تطابق IDs العامة مع IDs التطعيمات
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
    return _Resp(
      _kb['الأشراف الداعم للتحصين'] ?? _kb['الأشراف الداعم'] ?? 'عذراً',
      [const QuickReply(text: 'إدارة المستوى الوسيط', emoji: '🏢'), const QuickReply(text: 'مؤشرات الأداء', emoji: '📊'), const QuickReply(text: 'سلسلة التبريد', emoji: '❄️')],
    );
  }

  _Resp _handleManagement(String n) {
    _ctx.lastTopic = 'إدارة المستوى الوسيط';
    return _Resp(
      _kb['إدارة المستوى الوسيط'] ?? 'عذراً',
      [const QuickReply(text: 'الأشراف الداعم', emoji: '🔍'), const QuickReply(text: 'تغطية التطعيم', emoji: '📊'), const QuickReply(text: 'حملات التحصين', emoji: '🚐')],
    );
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
      '$g$contextHint\n\n💡 اسألني عن أي شيء:\n• تطعيمات طفلك\n• الآثار الجانبية\n• أمراض ووقاية\n• حالات خاصة\n• الأشراف الداعم',
      _welcomeReplies(),
    );
  }

  _Resp _handleDefault(String n) {
    // محاولة استخراج حرارة
    final temp = SmartNLP.extractTemperature(n);
    if (temp != null && temp > 38.5) {
      _ctx.child.mentionedSymptoms.add('حرارة');
      _ctx.lastTopic = 'حرارة بعد التطعيم';
      return _Resp(
        '🌡️ حرارة طفلك ${temp}° — ${temp >= 39.5 ? '⚠️ عالية!' : 'راقب الوضع'}\n\n${_kb['حرارة بعد التطعيم'] ?? ''}',
        [const QuickReply(text: 'متى أخاف؟', emoji: '🚨'), const QuickReply(text: 'متى أروح للطبيب؟', emoji: '🏥')],
      );
    }

    // محاولة استخراج عمر
    final age = SmartNLP.extractAge(n);
    if (age != null) return _handleAge(n);

    // محاولة أخيرة — بحث بالكلمات الجزئية
    final words = n.split(' ').where((w) => w.length > 2).toList();
    for (final word in words) {
      for (final key in _kb.keys) {
        final kn = SmartNLP.normalize(key);
        if (kn.contains(word) && word.length > 3) {
          _ctx.lastTopic = key;
          return _Resp(_kb[key] ?? '', _ctxReplies(key));
        }
      }
    }

    // رد ذكي حسب سياق المحادثة
    if (_ctx.turnCount <= 1) {
      return _Resp(
        '🤖 أهلاً! أنا مستشار التحصين الذكي 🇾🇪\n\n'
        'أقدر أساعدك في كل شيء متعلق بالتحصين الصحي الموسع!\n\n'
        '💡 جرب تقولي:\n'
        '• "عمر طفلي 6 أشهر وش تطعيماته؟"\n'
        '• "وش الآثار الجانبية للخماسي؟"\n'
        '• "هل التطعيم يسبب أوتيزم؟"\n'
        '• "ولدي حرارته 39 وش أسوي؟"\n'
        '• "وش الأشراف الداعم؟"\n\n'
        'أو اختر من الاقتراحات 👇',
        _welcomeReplies(),
      );
    }

    // إذا عندنا اسم الطفل، نذكره في الرد
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
        '📌 ممكن أجاوب على:\n• تطعيمات طفلك حسب عمره\n• الآثار الجانبية\n• أمراض ووقاية\n• حالات خاصة\n• الأشراف الداعم',
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
      '• "الأشراف الداعم للتحصين"\n\n'
      'أو اختر من الاقتراحات 👇',
      _welcomeReplies(),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  أدوات مساعدة
  // ══════════════════════════════════════════════════════════════

  Map<String, String> get _kb => unifiedKnowledgeBase;

  String? _searchExt(String n) {
    // أولاً: بحث مباشر في خريطة الكلمات المفتاحية الموسّعة
    for (final e in extendedKeywordMap.entries) {
      for (final kw in e.value) {
        if (n.contains(kw.toLowerCase()) && _kb.containsKey(e.key)) return e.key;
      }
    }
    // ثانياً: بحث في الاقتراحات السريعة
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
      // تطابق مباشر
      if (n.contains(kn) || kn.contains(n)) return key;

      // تطابق بالكلمات المفتاحية
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

      // تطابق بالمرادفات
      final score = SmartNLP.calculateRelevance(n, keyKw);
      if (score > best) { best = score; bestKey = key; }
    }
    return best > 0.15 ? bestKey : null;
  }

  /// بحث ذكي شامل — يجمع كل الطرق
  String? _smartSearch(String n) {
    // 1. بحث في الكلمات المفتاحية الموسّعة
    final ext = _searchExt(n);
    if (ext != null) return ext;

    // 2. بحث ضبابي في قاعدة المعرفة
    final kb = _searchKB(n);
    if (kb != null) return kb;

    // 3. بحث بالكلمات الفردية
    final words = n.split(' ').where((w) => w.length > 2).toList();
    for (final word in words) {
      for (final key in _kb.keys) {
        final kn = SmartNLP.normalize(key);
        if (kn.contains(word) && word.length > 3) return key;
      }
    }

    // 4. بحث عكسي
    for (final key in _kb.keys) {
      final kn = SmartNLP.normalize(key);
      final keyWords = kn.split(' ');
      for (final kw in keyWords) {
        if (kw.length > 3 && n.contains(kw)) return key;
      }
    }

    return null;
  }

  void _record(String intent, String msg) {
    _ctx.recordTurn(msg, '', intent);
  }

  List<QuickReply> _welcomeReplies() => const [
    QuickReply(text: 'وش تطعيمات طفلي؟', emoji: '💉'), QuickReply(text: 'وش الآثار الجانبية؟', emoji: '⚠️'),
    QuickReply(text: 'هل مجاني؟', emoji: '💰'), QuickReply(text: 'الفرق OPV و IPV؟', emoji: '🔵'),
    QuickReply(text: 'هل يسبب أوتيزم؟', emoji: '🚫'), QuickReply(text: 'ولدي مريض', emoji: '🤒'),
    QuickReply(text: 'الأشراف الداعم', emoji: '🔍'), QuickReply(text: 'إدارة المستوى الوسيط', emoji: '🏢'),
    QuickReply(text: 'الأمراض', emoji: '🦠'), QuickReply(text: 'التغذية', emoji: '🍼'),
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
