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

    // ═══ متابعة ═══
    if (intent == 'follow_up') return _handleFollowUp(norm);

    // ═══ معالجة حسب النية ═══
    switch (intent) {
      case 'age_query': return _handleAge(norm);
      case 'vaccine_list': return _handleVaccineList();
      case 'schedule_query': return _handleVaccineList();
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
  //  المعالجات المتقدمة
  // ══════════════════════════════════════════════════════════════

  _Resp _handleAge(String n) {
    final age = SmartNLP.extractAge(n);
    if (age != null) {
      _ctx.child.ageMonths = age.months > 0 ? age.months : (age.weeks * 7) ~/ 30;
      _ctx.child.ageWeeks = age.weeks > 0 ? age.weeks : (age.months * 30) ~/ 7;
      _ctx.child.lastUpdated = DateTime.now();

      final m = _ctx.child.ageMonths!;
      final w = _ctx.child.ageWeeks!;
      final due = VaccinationService().getVaccinesDueAtAge(w, m);
      final upcoming = VaccinationService().getUpcomingVaccines(w, m);

      final buf = StringBuffer();

      if (_ctx.child.name != null) {
        buf.writeln('📅 ${_ctx.child.name} عمره ${_ctx.child.ageDisplay}:');
      } else {
        buf.writeln('📅 عمر طفلك: ${_ctx.child.ageDisplay}');
      }

      if (_ctx.child.isPremature) buf.writeln('👶 طفل مبتسر — يُعطى حسب العمر الزمني');

      if (due.isNotEmpty) {
        buf.writeln('\n✅ تطعيمات يجب أن تكون مُعطاة:');
        for (final v in due) {
          final overdue = m > 0 && v.dueMonths > 0 && (m - v.dueMonths) > 2;
          buf.writeln('  ${overdue ? '⚠️' : '✅'} ${v.iconEmoji} ${v.nameAr} — ${v.doseNumber}');
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

      buf.writeln('\n📋 ${_ctx.buildConsultationContext()}');
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
    return _Resp('📅 كم عمر طفلك؟', [
      const QuickReply(text: 'عمره شهر', emoji: '📅'), const QuickReply(text: 'عمره 3 شهور', emoji: '📅'),
      const QuickReply(text: 'عمره 6 شهور', emoji: '📅'), const QuickReply(text: 'عمره 9 شهور', emoji: '📅'),
      const QuickReply(text: 'عمره سنة', emoji: '📅'),
    ]);
  }

  _Resp _handleClarificationResponse(String n, String context) {
    if (context == 'age_query') return _handleAge(n);
    if (context == 'side_effects') return _handleSideEffects(n);
    return _handleDefault(n);
  }

  _Resp _handleNegation(String n) {
    if (_ctx.lastTopic.contains('تطعيم') || _ctx.lastTopic.contains('لقاح')) {
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
    if (RegExp(r'^(نعم|ايوه|ايه|اي|يب|ايه نعم|اوك|اوكي)').hasMatch(n)) {
      if (_ctx.lastTopic.isNotEmpty && _kb.containsKey(_ctx.lastTopic)) {
        return _Resp(_kb[_ctx.lastTopic] ?? 'عذراً، لا تتوفر معلومات حالياً', _ctxReplies(_ctx.lastTopic));
      }
      return _Resp('تمام! ✅ اسألني أي تفاصيل إضافية.', _welcomeReplies());
    }
    if (RegExp(r'^(لا|ما ابي|مو|ما يبي|ما ابغي|ما ابي اعطيه)').hasMatch(n)) {
      return _Resp('👍 تمام! إذا احتجت شيء ثاني أنا هنا.', _welcomeReplies());
    }
    if (RegExp(r'اشرح|وضح|بالتفصيل|تفاصيل|شرح لي|زود|فهمني اكثر').hasMatch(n)) {
      if (_ctx.lastTopic.isNotEmpty && _kb.containsKey(_ctx.lastTopic)) {
        return _Resp(_kb[_ctx.lastTopic] ?? 'عذراً، لا تتوفر معلومات حالياً', _ctxReplies(_ctx.lastTopic));
      }
    }
    if (RegExp(r'^(طيب|تمام|زين|اوكي|اوك|تمام شكرا|كذا خلاص)').hasMatch(n)) {
      if (_ctx.lastTopic.isNotEmpty) {
        return _Resp('💡 تمام! تبي تعرف أكثر عن "${_ctx.lastTopic}"؟ أو عندك سؤال ثاني؟', _welcomeReplies());
      }
    }
    if (n.startsWith('كم')) {
      return _Resp('📊 تحب تعرف كم جرعة؟ ولا كم عمر يبدأ فيه التطعيم؟', [
        const QuickReply(text: 'كم جرعة؟', emoji: '🔢'),
        const QuickReply(text: 'متى يبدأ؟', emoji: '📅'),
      ]);
    }
    if (RegExp(r'^ليه|^ليش|^لماذا').hasMatch(n)) {
      if (_ctx.lastTopic.isNotEmpty && _kb.containsKey(_ctx.lastTopic)) {
        return _Resp(_kb[_ctx.lastTopic] ?? 'عذراً، لا تتوفر معلومات حالياً', _ctxReplies(_ctx.lastTopic));
      }
    }
    return _Resp('🤔 ممكن توضح أكثر وش تقصد بالضبط؟', _welcomeReplies());
  }

  _Resp _handleChildSick(String n) {
    final severity = SmartNLP.detectSeverity(n);
    final symptoms = _ctx.child.mentionedSymptoms;

    if (symptoms.contains('تشنجات') || symptoms.contains(' серьي')) {
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

    final symptomsText = symptoms.isNotEmpty ? '\n\n📋 الأعراض: ${symptoms.join(', ')}' : '';

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
      '📌 القاعدة:\n'
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

    if (n.contains('حراره') || n.contains('سخون') || n.contains('يسخن')) {
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
    if (n.contains('يبكي') || n.contains('بكاء') || n.contains('ما يسكت')) {
      _ctx.lastTopic = 'بكاء مستمر بعد التطعيم';
      return _Resp(_kb['بكاء مستمر بعد التطعيم'] ?? '💡 البكاء بعد التطعيم طبيعي. حضنه واطمنه.', _ctxReplies('side_effects'));
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
      'bcg': '🔴 آثار BCG:\n✅ طبيعي بعد 2-8 أسابيع: احمرار، قُرحة، تندب\n📌 التندب يبقى مدى الحياة — طبيعي!\n🚫 لا تضع مرهم أو تغطي المكان',
      'opv': '🟢 آثار OPV: نادرة جداً\n✅ لا توجد آثار شائعة\n⚠️ شلل مرتبط باللقاح: 1 لكل 2.4 مليون جرعة',
      'penta': '🟡 آثار الخماسي:\n✅ ألم مكان الحقن (شائعة)\n✅ حرارة 38-39° (30% من الأطفال)\n⚠️ حرارة أكثر من 39.5° ← اطلب طبيب\n⏰ تزول خلال 1-3 أيام',
      'mr': '🔴 آثار MR:\n✅ تظهر بعد 5-12 يوم (ليست فورية!)\n• حرارة خفيفة\n• طفح جلدي خفيف\n📌 هذا طبيعي!',
      'pcv': '🟣 آثار PCV: نادرة وخفيفة\n✅ ألم مكان الحقن، حرارة خفيفة',
      'rota': '🔵 آثار الروتا: نادرة جداً\n✅ من أكثر التطعيمات أماناً!',
      'td_girls': '👧 آثار Td للبنات:\n✅ ألم مكان الحقن (بسيط)\n✅ احمرار بسيط\n📌 يحمي من الكزاز والخناق مستقبلاً',
      'vitA': '🌟 آثار فيتامين أ: نادرة جداً!\n✅ آمن جداً ولا توجد آثار جانبية شائعة\n📌 يقوي المناعة ويمنع العمى الليلي\n💡 يُعطى عن طريق الفم (كبسولة)',
    };
    return e[vid] ?? _kb['آثار جانبية'] ?? 'عذراً، لا تتوفر معلومات حالياً';
  }

  _Resp _handleEmergency(String n) {
    return _Resp(
      '🚨 متى تطلب طبيب فوراً؟\n\n'
      '━━ خلال دقائق (طوارئ) ━━\n'
      '🔴 صعوبة تنفس\n🔴 تورم وجه/حلق\n🔴 شحوب شديد\n🔴 فقد وعي\n\n'
      '━━ خلال ساعات ━━\n'
      '🟠 حرارة أكثر من 39.5°\n🟠 تشنجات\n🟠 طفح شديد\n🟠 بكاء أكثر من 3 ساعات\n\n'
      '━━ خلال يومين ━━\n'
      '🟡 حرارة مستمرة 48 ساعة\n🟡 تورم يزداد\n🟡 قيء مستمر\n\n'
      '⏰ انتظر 15-30 دقيقة بعد التطعيم في المركز!',
      [const QuickReply(text: 'حرارة بعد التطعيم', emoji: '🌡️'), const QuickReply(text: 'تشنجات', emoji: '🚨')],
    );
  }

  _Resp _handleMyths(String n) {
    if (n.contains('اوتيزم') || n.contains('توحد')) {
      _ctx.lastTopic = 'التطعيم والتوحد';
      return _Resp(_kb['التطعيم والتوحد'] ?? 'عذراً، لا تتوفر معلومات حالياً', _ctxReplies('myths'));
    }
    if (n.contains('عقم') || n.contains('خصوبه')) {
      _ctx.lastTopic = 'التطعيم والعقم';
      return _Resp(_kb['التطعيم والعقم'] ?? 'عذراً، لا تتوفر معلومات حالياً', _ctxReplies('myths'));
    }
    _ctx.lastTopic = 'أساطير';
    return _Resp(_kb['أساطير'] ?? 'عذراً، لا تتوفر معلومات حالياً', [
      const QuickReply(text: 'هل يسبب أوتيزم؟', emoji: '🚫'),
      const QuickReply(text: 'هل يسبب عقم؟', emoji: '🚫'),
      const QuickReply(text: 'هل مضرة؟', emoji: '🚫'),
    ]);
  }

  _Resp _handleSpecialCases(String n) {
    if (n.contains('مبتسر') || n.contains('خديج')) { _ctx.lastTopic = 'للأطفال المبتسرين'; return _Resp(_kb['للأطفال المبتسرين'] ?? 'عذراً', _ctxReplies('special')); }
    if (n.contains('مرض') || n.contains('مريض')) { _ctx.lastTopic = 'للأطفال المرضى'; return _Resp(_kb['للأطفال المرضى'] ?? 'عذراً', _ctxReplies('special')); }
    if (n.contains('مرضع')) { _ctx.lastTopic = 'الأم المرضعة'; return _Resp(_kb['الأم المرضعة'] ?? 'عذراً', _ctxReplies('special')); }
    if (n.contains('حامل')) { _ctx.lastTopic = 'الحوامل'; return _Resp(_kb['الحوامل'] ?? 'عذراً', _ctxReplies('special')); }
    if (n.contains('hiv') || n.contains('ايدز')) { _ctx.lastTopic = 'HIV'; return _Resp(_kb['تطعيم الأطفال المصابين بـ HIV'] ?? 'عذراً', _ctxReplies('special')); }
    if (n.contains('سرطان')) { _ctx.lastTopic = 'سرطان'; return _Resp(_kb['الأطفال المصابين بالسرطان'] ?? 'عذراً', _ctxReplies('special')); }
    if (n.contains('سكر')) { _ctx.lastTopic = 'سكري'; return _Resp(_kb['الأطفال المصابين بالسكري'] ?? 'عذراً', _ctxReplies('special')); }
    if (n.contains('قلب')) { _ctx.lastTopic = 'قلب'; return _Resp(_kb['الأطفال المصابين بالقلب'] ?? '🟡 عيوب القلب: جميع التطعيمات آمنة ومهمة!', _ctxReplies('special')); }
    if (n.contains('ربو')) { _ctx.lastTopic = 'ربو'; return _Resp('🟡 الأطفال المصابون بالربو:\n\n✅ جميع التطعيمات آمنة ومهمة!\n• الربو لا يمنع أي تطعيم\n• بل التطعيم يحميهم من عدوى تزيد الربو\n\n💡 استشر طبيب الربو', _ctxReplies('special')); }
    return _Resp('👶 حالات خاصة:', [
      const QuickReply(text: 'مبتسرين', emoji: '👶'), const QuickReply(text: 'مرضى', emoji: '🤒'),
      const QuickReply(text: 'حوامل', emoji: '🤰'), const QuickReply(text: 'HIV', emoji: '🔴'),
      const QuickReply(text: 'سكر', emoji: '🟡'), const QuickReply(text: 'قلب', emoji: '❤️'),
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
    return _Resp(buf.toString(), [const QuickReply(text: 'عمره 6 أشهر', emoji: '📅'), const QuickReply(text: 'وش الآثار؟', emoji: '⚠️')]);
  }

  _Resp _handleDose(String n) {
    final v = SmartNLP.detectVaccineMention(n);
    if (v != null) {
      final d = {
        'bcg': '🔴 BCG: جرعة واحدة عند الولادة',
        'opv': '🟢 OPV: 5 جرعات (الولادة + 6 أسابيع + 10 أسابيع + 14 أسبوع + 9 أشهر + 18 شهر)',
        'ipv': '🟢 IPV: جرعة واحدة (عمر 14 أسبوع)',
        'penta': '🟡 الخماسي: 3 جرعات (6 أسابيع + 10 أسابيع + 14 أسبوع)',
        'pcv': '🟣 PCV: 3 جرعات (6 أسابيع + 10 أسابيع + 14 أسبوع)',
        'rota': '🔵 الروتا: 2 جرعتين (6 أسابيع + 10 أسابيع)',
        'mr': '🔴 MR: 3 جرعات (9 أشهر + 18 شهر + 6 سنوات)',
        'td': '👩 Td للحوامل: 5 جرعات',
        'td_girls': '👧 Td للبنات: جرعة واحدة (عمر 12 سنة)',
        'vitA': '🌟 فيتامين أ: 4 جرعات (6 أشهر: 100,000 و.د + 12 شهر: 200,000 و.د + 18 شهر: 200,000 و.د + 6 سنوات: 200,000 و.د)',
      };
      return _Resp(d[v] ?? '📊 عدد الجرعات يختلف حسب التطعيم.', _ctxReplies('dose'));
    }
    return _Resp(_kb['كم جرعة'] ?? '', _ctxReplies('dose'));
  }

  _Resp _handleVaccineTypes(String n) {
    final v = SmartNLP.detectVaccineMention(n);
    if (v != null) {
      final match = VaccinationService.allVaccines.where((x) => x.id == v).firstOrNull;
      if (match != null) return _Resp('${match.iconEmoji} ${match.nameAr}\n\n📝 ${match.description}\n💉 ${match.doseNumber}\n📍 ${match.site}', _ctxReplies(v));
    }
    return _Resp(_kb['ما هي اللقاحات'] ?? 'عذراً', [const QuickReply(text: 'كيف تعمل؟', emoji: '🔬'), const QuickReply(text: 'هل آمنة؟', emoji: '✅')]);
  }

  _Resp _handleDiseases(String n) {
    final d = SmartNLP.detectDiseaseMention(n);
    if (d != null) {
      final dm = {'measles':'الحصبة','polio':'شلل الأطفال المرض','tetanus':'الكزاز','diphtheria':'الخناق','pertussus':'السعال الديبي','hepatitis':'التهاب الكبد ب','pneumonia':'المكورات الرئوية','rotavirus':'الروتا المرض','meningitis':'التهاب الأغشية المخية','tuberculosis':'السل'};
      final t = dm[d];
      if (t != null && _kb.containsKey(t)) { _ctx.lastTopic = t; return _Resp(_kb[t] ?? 'عذراً', _ctxReplies('disease')); }
    }
    return _Resp('🦠 الأمراض التي تحمي منها التطعيمات:\n\n1. السل\n2. شلل الأطفال\n3. الخناق\n4. الكزاز\n5. السعال الديبي\n6. التهاب الكبد B\n7. المستدمية النزلية\n8. الحصبة\n9. الحصبة الألمانية\n10. المكورات الرئوية\n11. الروتا فيروس\n\n💡 اسألني عن أي مرض!', [const QuickReply(text: 'الحصبة', emoji: '🦠'), const QuickReply(text: 'الشلل', emoji: '🦠')]);
  }

  _Resp _handleNutrition(String n) {
    if (n.contains('رضاع')) { _ctx.lastTopic = 'الرضاعة والتطعيم'; return _Resp(_kb['الرضاعة والتطعيم'] ?? 'عذراً', _ctxReplies('nutrition')); }
    _ctx.lastTopic = 'تغذية الطفل والتطعيم'; return _Resp(_kb['تغذية الطفل والتطعيم'] ?? 'عذراً', _ctxReplies('nutrition'));
  }

  _Resp _handleColdChain(String n) {
    if (n.contains('vvm')) { _ctx.lastTopic = 'VVM'; return _Resp(_kb['VVM'] ?? 'عذراً', _ctxReplies('cold_chain')); }
    _ctx.lastTopic = 'سلسلة التبريد'; return _Resp(_kb['سلسلة التبريد'] ?? 'عذراً', _ctxReplies('cold_chain'));
  }

  _Resp _handleLocation() => _Resp(_kb['أين التطعيم'] ?? 'عذراً', [const QuickReply(text: 'هل مجاني؟', emoji: '💰'), const QuickReply(text: 'متى التطعيم؟', emoji: '📅')]);
  _Resp _handleCost() => _Resp(_kb['مجاناً'] ?? 'عذراً', [const QuickReply(text: 'وين أطعم؟', emoji: '📍'), const QuickReply(text: 'متى التطعيم؟', emoji: '📅')]);
  _Resp _handleCampaigns() => _Resp(_kb['حملات التطعيم'] ?? 'عذراً', [const QuickReply(text: 'وين أطعم؟', emoji: '📍'), const QuickReply(text: 'هل مجاني؟', emoji: '💰')]);
  _Resp _handleTravel() => _Resp(_kb['السفر والتطعيم'] ?? 'عذراً', [const QuickReply(text: 'هل مجاني؟', emoji: '💰'), const QuickReply(text: 'وش التطعيمات؟', emoji: '💉')]);
  _Resp _handleHistory() => _Resp(_kb['تاريخ التحصين في اليمن'] ?? 'عذراً', _welcomeReplies());
  _Resp _handleBenefits() => _Resp(_kb['فوائد اقتصادية'] ?? 'عذراً', _welcomeReplies());

  _Resp _handleSupervision(String n) {
    _ctx.lastTopic = 'الأشراف الداعم للتحصين';
    return _Resp(
      _kb['الأشراف الداعم للتحصين'] ?? 'عذراً، لا تتوفر معلومات حالياً',
      [const QuickReply(text: 'إدارة المستوى الوسيط', emoji: '🏢'), const QuickReply(text: 'مؤشرات الأداء', emoji: '📊'), const QuickReply(text: 'سلسلة التبريد', emoji: '❄️')],
    );
  }

  _Resp _handleManagement(String n) {
    _ctx.lastTopic = 'إدارة المستوى الوسيط';
    return _Resp(
      _kb['إدارة المستوى الوسيط'] ?? 'عذراً، لا تتوفر معلومات حالياً',
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
    final temp = SmartNLP.extractTemperature(n);
    if (temp != null && temp > 38.5) {
      _ctx.child.mentionedSymptoms.add('حرارة');
      _ctx.lastTopic = 'حرارة بعد التطعيم';
      return _Resp(
        '🌡️ حرارة طفلك ${temp}° — ${temp >= 39.5 ? '⚠️ عالية!' : 'راقب الوضع'}\n\n${_kb['حرارة بعد التطعيم'] ?? ''}',
        [const QuickReply(text: 'متى أخاف؟', emoji: '🚨'), const QuickReply(text: 'متى أروح للطبيب؟', emoji: '🏥')],
      );
    }

    if (_ctx.child.mentionedSymptoms.isNotEmpty) return _handleChildSick(n);

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

    if (_ctx.lastTopic.isNotEmpty) {
      return _Resp(
        '🤔 مش فاهم قصدك بالضبط. تبي تعرف أكثر عن "${_ctx.lastTopic}"؟\n\n'
        '💡 أو جرب تسأل بطريقة ثانية — أنا هنا أساعدك!',
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
          // حاول إيجاد مفتاح مطابق في قاعدة المعرفة
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
    return best > 0.15 ? bestKey : null;  // خفض العتبة من 0.3 إلى 0.15
  }

  /// بحث ذكي شامل — يجمع كل الطرق
  String? _smartSearch(String n) {
    // 1. بحث في الكلمات المفتاحية الموسّعة
    final ext = _searchExt(n);
    if (ext != null) return ext;

    // 2. بحث ضبابي في قاعدة المعرفة
    final kb = _searchKB(n);
    if (kb != null) return kb;

    // 3. بحث بالكلمات الفردية — أي كلمة في السؤال تطابق مفتاح؟
    final words = n.split(' ').where((w) => w.length > 2).toList();
    for (final word in words) {
      for (final key in _kb.keys) {
        final kn = SmartNLP.normalize(key);
        if (kn.contains(word) && word.length > 3) return key;
      }
    }

    // 4. بحث عكسي — هل أي مفتاح يحتوي على كلمات السؤال؟
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
      'bcg': [const QuickReply(text: 'وش الآثار؟', emoji: '⚠️'), const QuickReply(text: 'وش التندب؟', emoji: '🔴')],
      'opv': [const QuickReply(text: 'الفرق OPV و IPV؟', emoji: '🔵'), const QuickReply(text: 'هل اليمن خالية؟', emoji: '🎉')],
      'penta': [const QuickReply(text: 'وش الآثار؟', emoji: '⚠️'), const QuickReply(text: 'كم جرعة؟', emoji: '🔢')],
      'mr': [const QuickReply(text: 'متى يُعطى؟', emoji: '📅'), const QuickReply(text: 'وش الآثار؟', emoji: '⚠️')],
      'side_effects': [const QuickReply(text: 'حرارة بعد التطعيم', emoji: '🌡️'), const QuickReply(text: 'تشنجات', emoji: '🚨'), const QuickReply(text: 'متى أخاف؟', emoji: '⚠️')],
      'special': [const QuickReply(text: 'مبتسرين', emoji: '👶'), const QuickReply(text: 'مرضى', emoji: '🤒'), const QuickReply(text: 'سكر', emoji: '🟡')],
      'myths': [const QuickReply(text: 'هل يسبب أوتيزم؟', emoji: '🚫'), const QuickReply(text: 'هل يسبب عقم؟', emoji: '🚫')],
      'nutrition': [const QuickReply(text: 'الرضاعة والتطعيم', emoji: '🍼'), const QuickReply(text: 'فيتامين أ', emoji: '🌟')],
      'cold_chain': [const QuickReply(text: 'وش هو VVM؟', emoji: '🔍'), const QuickReply(text: 'المحاقن', emoji: '💉')],
      'disease': [const QuickReply(text: 'وش التطعيم؟', emoji: '💉'), const QuickReply(text: 'وش الآثار؟', emoji: '⚠️')],
      'supervision': [const QuickReply(text: 'إدارة المستوى الوسيط', emoji: '🏢'), const QuickReply(text: 'مؤشرات الأداء', emoji: '📊')],
      'management': [const QuickReply(text: 'الأشراف الداعم', emoji: '🔍'), const QuickReply(text: 'حملات التحصين', emoji: '🚐')],
      'dose': [const QuickReply(text: 'كم جرعة BCG؟', emoji: '🔴'), const QuickReply(text: 'كم جرعة OPV؟', emoji: '🟢')],
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
