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
        '🧠 أفهمك بعمق — اسألني أي سؤال وأجاوبك!\n\n'
        'أقدر أساعدك في:\n'
        '💉 تطعيمات طفلك (حسب عمره وحالته)\n'
        '⚠️ الآثار الجانبية (حرارة، تورم، تشنجات...)\n'
        '🦠 الأمراض التي تحمي منها التطعيمات\n'
        '👶 حالات خاصة (مبتسرين، سكري، قلب...)\n'
        '🍼 التغذية وتأثيرها على المناعة\n'
        '🚫 الرد على الأساطير (التوحد، العقم...)\n'
        '❄️ سلسلة التبريد و VVM\n'
        '📜 تاريخ التحصين في اليمن\n\n'
        '💡 نصيحة: قولي عمر طفلك وأقدر أعطيك تطعيماته المطلوبة!',
        quickReplies: _welcomeReplies(),
      );
    }
  }

  void sendMessage(String text) {
    _messages.add(ChatMessage(id: _gid(), text: text, isBot: false, timestamp: DateTime.now()));
    notifyListeners();

    final ms = 300 + min(text.length * 6, 1000);
    Future.delayed(Duration(milliseconds: ms), () {
      final resp = _process(text);
      _addBotMessage(resp.text, quickReplies: resp.quickReplies);
    });
  }

  // ══════════════════════════════════════════════════════════════
  //  المعالجة الرئيسية مع السياق العميق
  // ══════════════════════════════════════════════════════════════

  _BotResponse _process(String raw) {
    final norm = SmartNLP.normalize(raw);
    final intent = SmartNLP.detectIntent(norm, previousIntent: _ctx.lastTopic, lastTopic: _ctx.lastTopic);

    // ═══ استخراج الكيانات ═══
    _ctx.extractEntities(norm);
    _ctx.updatePhase(intent);

    // ═══ هل يحتاج توضيح؟ ═══
    final clar = _ctx.needsClarification(norm, intent);
    if (clar.needs) {
      _ctx.awaitingClarification = true;
      _ctx.clarificationContext = intent;
      return _BotResponse(clar.question, clar.options.map((o) => QuickReply(o, '❓')).toList());
    }

    // ═══ إذا كان ينتظر توضيح ═══
    if (_ctx.awaitingClarification) {
      _ctx.awaitingClarification = false;
      return _handleClarificationResponse(norm, _ctx.clarificationContext);
    }

    // ═══ هل هو سؤال متابعة؟ ═══
    if (SmartNLP.hasNegation(norm) && _ctx.lastTopic.isNotEmpty) {
      return _handleNegation(norm);
    }

    if (intent == 'follow_up') {
      return _handleFollowUp(norm);
    }

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
      default: break;
    }

    // ═══ بحث في القاموس الموسع ═══
    final ext = _searchExt(norm);
    if (ext != null) { _ctx.lastTopic = ext; _record('general', norm); return _Resp(_kb[ext]!, _ctxReplies(ext)); }

    // ═══ بحث في قاعدة المعرفة ═══
    final kb = _searchKB(norm);
    if (kb != null) { _ctx.lastTopic = kb; _record('general', norm); return _Resp(_kb[kb]!, _ctxReplies(kb)); }

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

      // تخصيص الرد حسب السياق
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

      // نصيحة حسب العمر
      if (m <= 3) buf.writeln('\n💡 نصيحة: لا تأخر عن مواعيد 6 و10 و14 أسبوع!');
      if (m >= 8 && m <= 10) buf.writeln('\n⏰ تطعيم الحصبة قرب! لا تفوته في عمر 9 أشهر.');

      buf.writeln('\n📋 ${_ctx.buildConsultationContext()}');
      _record('age_query', n);
      return _Resp(buf.toString(), [
        const QuickReply('وش الآثار الجانبية؟', '⚠️'),
        const QuickReply('هل أطعم وهو مريض؟', '🤒'),
        const QuickReply('وين أطعمه؟', '📍'),
        const QuickReply('هل مجاني؟', '💰'),
      ]);
    }

    _ctx.awaitingClarification = true;
    _ctx.clarificationContext = 'age_query';
    return _Resp('📅 كم عمر طفلك؟', [
      const QuickReply('عمره شهر', '📅'), const QuickReply('عمره 3 شهور', '📅'),
      const QuickReply('عمره 6 شهور', '📅'), const QuickReply('عمره 9 شهور', '📅'),
      const QuickReply('عمره سنة', '📅'),
    ]);
  }

  _Resp _handleClarificationResponse(String n, String context) {
    if (context == 'age_query') return _handleAge(n);
    if (context == 'side_effects') return _handleSideEffects(n);
    return _handleDefault(n);
  }

  _Resp _handleNegation(String n) {
    // المستخدم نفى شيء — افهم وش يبي
    if (_ctx.lastTopic.contains('تطعيم') || _ctx.lastTopic.contains('لقاح')) {
      return _Resp(
        '👍 ما يبي يطعمه الحين — مافي مشكلة!\n\n'
        '📌 بس تذكر:\n'
        '• التطعيم المتأخر أفضل من عدم التطعيم\n'
        '• لا تحتاج تبدأ من جديد\n'
        '• استأنف الجدول لما يتحسن\n\n'
        '💡 متى يرجع يتحسن؟ ارجع لي وأقولك وش التطعيمات اللي فاتته.',
        [const QuickReply('متى أرجع أطعمه؟', '⏰'), const QuickReply('وش الآثار؟', '⚠️')],
      );
    }
    return _Resp('تمام! 👍 إذا احتجت شيء ثاني أنا هنا.', _welcomeReplies());
  }

  _Resp _handleFollowUp(String n) {
    // نعم/اشرح/تفاصيل
    if (RegExp(r'^(نعم|ايوه|ايه|اي|يب|ايه نعم)').hasMatch(n)) {
      if (_ctx.lastTopic.isNotEmpty && _kb.containsKey(_ctx.lastTopic)) {
        return _Resp(_kb[_ctx.lastTopic]!, _ctxReplies(_ctx.lastTopic));
      }
      return _Resp('تمام! ✅ اسألني أي تفاصيل إضافية.', _welcomeReplies());
    }
    // لا
    if (RegExp(r'^(لا|ما ابي|مو|ما يبي)').hasMatch(n)) {
      return _Resp('👍 تمام! إذا احتجت شيء ثاني أنا هنا.', _welcomeReplies());
    }
    // اشرح/وضح
    if (RegExp(r'اشرح|وضح|بالتفصيل|تفاصيل|شرح لي').hasMatch(n)) {
      if (_ctx.lastTopic.isNotEmpty && _kb.containsKey(_ctx.lastTopic)) {
        return _Resp(_kb[_ctx.lastTopic]!, _ctxReplies(_ctx.lastTopic));
      }
    }
    return _Resp('🤔 ممكن توضح أكثر وش تقصد بالضبط؟', _welcomeReplies());
  }

  _Resp _handleChildSick(String n) {
    final severity = SmartNLP.detectSeverity(n);
    final symptoms = _ctx.child.mentionedSymptoms;

    if (symptoms.contains('تشنجات') || symptoms.contains(' серьезн')) {
      return _Resp(
        '🚨 اطلب طبيب فوراً!\n\n'
        '⚠️ التشنجات حالة طوارئ:\n'
        '1. اطلب الإسعاف\n'
        '2. ضع الطفل على جانبه\n'
        '3. لا تضع شيء في فمه\n'
        '4. دوّن مدة التشنج\n\n'
        '⏰ لا تنتظر — اذهب للمستشفى الآن!',
        [const QuickReply('وش أسوي؟', '🚨'), const QuickReply('متى أخاف؟', '⚠️')],
      );
    }

    final symptomsText = symptoms.isNotEmpty ? '\n\n📋 الأعراض: ${symptoms.join(', ')}' : '';

    if (severity == 'شديد') {
      return _Resp(
        '⚠️ إذا كان طفلك تعبان بشكل شديد:$symptomsText\n\n'
        '🏥 استشر الطبيب قبل التطعيم\n'
        '⏳ يؤجل التطعيم حتى يتحسن\n\n'
        '📌 لكن إذا كان مرض بسيط (زكام، إسهال خفيف) ← يُطعم عادي!',
        [const QuickReply('متى أرجع أطعمه؟', '⏰'), const QuickReply('وش أعراض الخطر؟', '🚨')],
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
      [const QuickReply('حرارته عالية', '🌡️'), const QuickReply('عنده إسهال', '💧'), const QuickReply('يسعل', '😷')],
    );
  }

  _Resp _handleSideEffects(String n) {
    // حرارة
    if (n.contains('حراره') || n.contains('سخون')) {
      _ctx.lastTopic = 'حرارة بعد التطعيم';
      return _Resp(_kb['حرارة بعد التطعيم']!, _ctxReplies('side_effects'));
    }
    // تشنجات
    if (n.contains('تشنج') || n.contains('نوبه') || n.contains('يرتعش')) {
      _ctx.lastTopic = 'تشنجات بعد التطعيم';
      return _Resp(_kb['تشنجات بعد التطعيم']!, _ctxReplies('side_effects'));
    }
    // تورم
    if (n.contains('تورم') || n.contains('انتفاخ') || n.contains('ورم')) {
      _ctx.lastTopic = 'تتورم مكان الحقن';
      return _Resp(_kb['تتورم مكان الحقن']!, _ctxReplies('side_effects'));
    }
    // بكاء
    if (n.contains('يبكي') || n.contains('بكاء') || n.contains('ما يسكت')) {
      _ctx.lastTopic = 'بكاء مستمر بعد التطعيم';
      return _Resp(_kb['بكاء مستمر بعد التطعيم']!, _ctxReplies('side_effects'));
    }

    // آثار تطعيم محدد
    final v = SmartNLP.detectVaccineMention(n);
    if (v != null) {
      _ctx.lastVaccine = v;
      _ctx.lastTopic = 'آثار جانبية';
      return _Resp(_getSpecificEffects(v), _ctxReplies('side_effects'));
    }

    _ctx.lastTopic = 'آثار جانبية';
    return _Resp(_kb['آثار جانبية']!, _ctxReplies('side_effects'));
  }

  String _getSpecificEffects(String vid) {
    final e = {
      'bcg': '🔴 آثار BCG:\n✅ طبيعي بعد 2-8 أسابيع: احمرار، قُرحة، تندب\n📌 التندب يبقى مدى الحياة — طبيعي!\n🚫 لا تضع مرهم أو تغطي المكان',
      'opv': '🟢 آثار OPV: نادرة جداً\n✅ لا توجد آثار شائعة\n⚠️ شلل مرتبط باللقاح: 1 لكل 2.4 مليون جرعة',
      'penta': '🟡 آثار الخماسي:\n✅ ألم مكان الحقن (شائعة)\n✅ حرارة 38-39° (30% من الأطفال)\n⚠️ حرارة أكثر من 39.5° ← اطلب طبيب\n⏰ تزول خلال 1-3 أيام',
      'mr': '🔴 آثار MR:\n✅ تظهر بعد 5-12 يوم (ليست فورية!)\n• حرارة خفيفة\n• طفح جلدي خفيف\n📌 هذا طبيعي!',
      'pcv': '🟣 آثار PCV: نادرة وخفيفة\n✅ ألم مكان الحقن، حرارة خفيفة',
      'rota': '🔵 آثار الروتا: نادرة جداً\n✅ من أكثر التطعيمات أماناً!',
    };
    return e[vid] ?? _kb['آثار جانبية']!;
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
      [const QuickReply('حرارة بعد التطعيم', '🌡️'), const QuickReply('تشنجات', '🚨')],
    );
  }

  _Resp _handleMyths(String n) {
    if (n.contains('اوتيزم') || n.contains('توحد')) {
      _ctx.lastTopic = 'التطعيم والتوحد';
      return _Resp(_kb['التطعيم والتوحد']!, _ctxReplies('myths'));
    }
    if (n.contains('عقم') || n.contains('خصوبه')) {
      _ctx.lastTopic = 'التطعيم والعقم';
      return _Resp(_kb['التطعيم والعقم']!, _ctxReplies('myths'));
    }
    if (n.contains('يضر') || n.contains('مضره')) {
      _ctx.lastTopic = 'أساطير';
      return _Resp(_kb['أساطير']!, _ctxReplies('myths'));
    }
    _ctx.lastTopic = 'أساطير';
    return _Resp(_kb['أساطير']!, [
      const QuickReply('هل يسبب أوتيزم؟', '🚫'),
      const QuickReply('هل يسبب عقم؟', '🚫'),
      const QuickReply('هل مضرة؟', '🚫'),
    ]);
  }

  _Resp _handleSpecialCases(String n) {
    if (n.contains('مبتسر') || n.contains('خديج')) { _ctx.lastTopic = 'للأطفال المبتسرين'; return _Resp(_kb['للأطفال المبتسرين']!, _ctxReplies('special')); }
    if (n.contains('مرض') || n.contains('مريض')) { _ctx.lastTopic = 'للأطفال المرضى'; return _Resp(_kb['للأطفال المرضى']!, _ctxReplies('special')); }
    if (n.contains('مرضع')) { _ctx.lastTopic = 'الأم المرضعة'; return _Resp(_kb['الأم المرضعة']!, _ctxReplies('special')); }
    if (n.contains('حامل')) { _ctx.lastTopic = 'الحوامل'; return _Resp(_kb['الحوامل']!, _ctxReplies('special')); }
    if (n.contains('hiv') || n.contains('ايدز')) { _ctx.lastTopic = 'HIV'; return _Resp(_kb['تطعيم الأطفال المصابين بـ HIV']!, _ctxReplies('special')); }
    if (n.contains('سرطان')) { _ctx.lastTopic = 'سرطان'; return _Resp(_kb['الأطفال المصابين بالسرطان']!, _ctxReplies('special')); }
    if (n.contains('سكر')) { _ctx.lastTopic = 'سكري'; return _Resp(_kb['الأطفال المصابين بالسكري']!, _ctxReplies('special')); }
    if (n.contains('قلب')) { _ctx.lastTopic = 'قلب'; return _Resp(_kb['الأطفال المصابين بالقلب'] ?? '🟡 عيوب القلب: جميع التطعيمات آمنة ومهمة!', _ctxReplies('special')); }
    if (n.contains('ربو')) { _ctx.lastTopic = 'ربو'; return _Resp('🟡 الأطفال المصابون بالربو:\n\n✅ جميع التطعيمات آمنة ومهمة!\n• الربو لا يمنع أي تطعيم\n• بل التطعيم يحميهم من عدوى تزيد الربو\n\n💡 استشر طبيب الربو', _ctxReplies('special')); }
    return _Resp('👶 حالات خاصة:', [
      const QuickReply('مبتسرين', '👶'), const QuickReply('مرضى', '🤒'),
      const QuickReply('حوامل', '🤰'), const QuickReply('HIV', '🔴'),
      const QuickReply('سكر', '🟡'), const QuickReply('قلب', '❤️'),
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
    return _Resp(buf.toString(), [const QuickReply('عمره 6 أشهر', '📅'), const QuickReply('وش الآثار؟', '⚠️')]);
  }

  _Resp _handleDose(String n) {
    final v = SmartNLP.detectVaccineMention(n);
    if (v != null) {
      final d = {'bcg':'🔴 BCG: جرعة واحدة عند الولادة','opv':'🟢 OPV: 4 جرعات','ipv':'🟢 IPV: جرعة واحدة','penta':'🟡 الخماسي: 3 جرعات','pcv':'🟣 PCV: 3 جرعات','rota':'🔵 الروتا: 2 جرعتين','mr':'🔴 MR: 2 جرعة','td':'👩 Td: 5 جرعات'};
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
    return _Resp(_kb['ما هي اللقاحات']!, [const QuickReply('كيف تعمل؟', '🔬'), const QuickReply('هل آمنة؟', '✅')]);
  }

  _Resp _handleDiseases(String n) {
    final d = SmartNLP.detectDiseaseMention(n);
    if (d != null) {
      final dm = {'measles':'مرض السل','polio':'شلل الأطفال المرض','tetanus':'الكزاز','diphtheria':'الخناق','pertussis':'السعال الديبي','hepatitis':'التهاب الكبد ب','pneumonia':'المكورات الرئوية','rotavirus':'الروتا المرض','meningitis':'التهاب الأغشية المخية'};
      final t = dm[d];
      if (t != null && _kb.containsKey(t)) { _ctx.lastTopic = t; return _Resp(_kb[t]!, _ctxReplies('disease')); }
    }
    return _Resp('🦠 الأمراض التي تحمي منها التطعيمات:\n\n1. السل\n2. شلل الأطفال\n3. الخناق\n4. الكزاز\n5. السعال الديبي\n6. التهاب الكبد B\n7. المستدمية النزلية\n8. الحصبة\n9. الحصبة الألمانية\n10. المكورات الرئوية\n11. الروتا فيروس\n\n💡 اسألني عن أي مرض!', [const QuickReply('الحصبة', '🦠'), const QuickReply('الشلل', '🦠')]);
  }

  _Resp _handleNutrition(String n) {
    if (n.contains('رضاع')) { _ctx.lastTopic = 'الرضاعة والتطعيم'; return _Resp(_kb['الرضاعة والتطعيم']!, _ctxReplies('nutrition')); }
    _ctx.lastTopic = 'تغذية الطفل والتطعيم'; return _Resp(_kb['تغذية الطفل والتطعيم']!, _ctxReplies('nutrition'));
  }

  _Resp _handleColdChain(String n) {
    if (n.contains('vvm')) { _ctx.lastTopic = 'VVM'; return _Resp(_kb['VVM']!, _ctxReplies('cold_chain')); }
    _ctx.lastTopic = 'سلسلة التبريد'; return _Resp(_kb['سلسلة التبريد']!, _ctxReplies('cold_chain'));
  }

  _Resp _handleLocation() => _Resp(_kb['أين التطعيم']!, [const QuickReply('هل مجاني؟', '💰'), const QuickReply('متى التطعيم؟', '📅')]);
  _Resp _handleCost() => _Resp(_kb['مجاناً']!, [const QuickReply('وين أطعم؟', '📍'), const QuickReply('متى التطعيم؟', '📅')]);
  _Resp _handleCampaigns() => _Resp(_kb['حملات التطعيم']!, [const QuickReply('وين أطعم؟', '📍'), const QuickReply('هل مجاني؟', '💰')]);
  _Resp _handleTravel() => _Resp(_kb['السفر والتطعيم']!, [const QuickReply('هل مجاني؟', '💰'), const QuickReply('وش التطعيمات؟', '💉')]);
  _Resp _handleHistory() => _Resp(_kb['تاريخ التحصين في اليمن']!, _welcomeReplies());
  _Resp _handleBenefits() => _Resp(_kb['فوائد اقتصادية']!, _welcomeReplies());

  _Resp _handleDefault(String n) {
    // هل فيه أعراض مذكورة؟
    if (_ctx.child.mentionedSymptoms.isNotEmpty) {
      return _handleChildSick(n);
    }

    String g = _ctx.turnCount <= 1 ? '🤖 أهلاً! ' : '🤖 ';
    return _Resp('${g}أقدر أساعدك في كل شيء متعلق بالتحصين!\n\n💡 جرب:\n• "عمر طفلي 6 أشهر وش تطعيماته؟"\n• "وش الآثار للخماسي؟"\n• "هل يسبب أوتيزم؟"\n• "ولدي حرارته 39 وش أسوي؟"\n\nأو اختر من الاقتراحات 👇', _welcomeReplies());
  }

  // ══════════════════════════════════════════════════════════════
  //  أدوات مساعدة
  // ══════════════════════════════════════════════════════════════

  Map<String, String> get _kb => mainKnowledgeBase;

  String? _searchExt(String n) {
    for (final e in extendedKeywordMap.entries) {
      for (final kw in e.value) { if (n.contains(kw.toLowerCase()) && _kb.containsKey(e.key)) return e.key; }
    }
    return null;
  }

  String? _searchKB(String n) {
    double best = 0; String? bestKey;
    for (final key in _kb.keys) {
      final kn = SmartNLP.normalize(key);
      if (n.contains(kn) || kn.contains(n)) return key;
      final score = SmartNLP.calculateRelevance(n, SmartNLP.extractKeywords(kn));
      if (score > best) { best = score; bestKey = key; }
    }
    return best > 0.35 ? bestKey : null;
  }

  void _record(String intent, String msg) {
    _ctx.recordTurn(msg, '', intent);
  }

  List<QuickReply> _welcomeReplies() => const [
    QuickReply('وش تطعيمات طفلي؟', '💉'), QuickReply('وش الآثار الجانبية؟', '⚠️'),
    QuickReply('هل مجاني؟', '💰'), QuickReply('الفرق OPV و IPV؟', '🔵'),
    QuickReply('هل يسبب أوتيزم؟', '🚫'), QuickReply('ولدي مريض', '🤒'),
    QuickReply('وش السلسلة الباردة؟', '❄️'), QuickReply('وش هو VVM؟', '🔍'),
    QuickReply('الأمراض', '🦠'), QuickReply('التغذية', '🍼'),
  ];

  List<QuickReply> _ctxReplies(String topic) {
    final m = {
      'bcg': [const QuickReply('وش الآثار؟', '⚠️'), const QuickReply('وش التندب؟', '🔴')],
      'opv': [const QuickReply('الفرق OPV و IPV؟', '🔵'), const QuickReply('هل اليمن خالية؟', '🎉')],
      'penta': [const QuickReply('وش الآثار؟', '⚠️'), const QuickReply('كم جرعة؟', '🔢')],
      'mr': [const QuickReply('متى يُعطى؟', '📅'), const QuickReply('وش الآثار؟', '⚠️')],
      'side_effects': [const QuickReply('حرارة بعد التطعيم', '🌡️'), const QuickReply('تشنجات', '🚨'), const QuickReply('متى أخاف؟', '⚠️')],
      'special': [const QuickReply('مبتسرين', '👶'), const QuickReply('مرضى', '🤒'), const QuickReply('سكر', '🟡')],
      'myths': [const QuickReply('هل يسبب أوتيزم؟', '🚫'), const QuickReply('هل يسبب عقم؟', '🚫')],
      'nutrition': [const QuickReply('الرضاعة والتطعيم', '🍼'), const QuickReply('فيتامين أ', '🌟')],
      'cold_chain': [const QuickReply('وش هو VVM؟', '🔍'), const QuickReply('المحاقن', '💉')],
      'disease': [const QuickReply('وش التطعيم؟', '💉'), const QuickReply('وش الآثار؟', '⚠️')],
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

class QuickReply {
  final String text;
  final String emoji;
  const QuickReply(this.text, this.emoji);
}
