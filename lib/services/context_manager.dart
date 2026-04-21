// ══════════════════════════════════════════════════════════════
//  مدير السياق العميق — يحفظ ويحلل تفاصيل المحادثة
// ══════════════════════════════════════════════════════════════

/// كيان الطفل المستخرج من المحادثة
class ChildProfile {
  String? name;
  int? ageMonths;
  int? ageWeeks;
  String? gender; // ذكر / أنثى
  bool isPremature = false;
  bool hasChronicDisease = false;
  String? chronicDiseaseType;
  List<String> givenVaccines = [];
  List<String> mentionedSymptoms = [];
  DateTime? lastUpdated;

  ChildProfile();

  bool get hasBasicInfo => ageMonths != null || ageWeeks != null;
  String get ageDisplay {
    if (ageMonths != null && ageMonths! > 0) return '$ageMonths أشهر';
    if (ageWeeks != null && ageWeeks! > 0) return '$ageWeeks أسابيع';
    return 'غير محدد';
  }

  Map<String, dynamic> toJson() => {
    'name': name, 'ageMonths': ageMonths, 'ageWeeks': ageWeeks,
    'gender': gender, 'isPremature': isPremature,
    'hasChronicDisease': hasChronicDisease, 'chronicDiseaseType': chronicDiseaseType,
    'givenVaccines': givenVaccines, 'mentionedSymptoms': mentionedSymptoms,
  };
}

/// حالة المحادثة
enum ConversationPhase {
  greeting,        // بداية المحادثة
  collecting,      // جمع معلومات
  consulting,      // تقديم استشارة
  followUp,        // متابعة
  clarification,   // طلب توضيح
  emergency,       // حالة طوارئ
}

/// مدير السياق الرئيسي
class ContextManager {
  // ──── كيانات المحادثة ────
  final ChildProfile child = ChildProfile();
  
  // ──── حالة المحادثة ────
  ConversationPhase phase = ConversationPhase.greeting;
  String lastTopic = '';
  String lastVaccine = '';
  String lastDisease = '';
  String pendingClarification = '';
  
  // ──── ذاكرة المحادثة ────
  final List<ConversationTurn> history = [];
  final Map<String, dynamic> extractedEntities = {};
  final List<String> discussedTopics = [];
  int turnCount = 0;
  
  // ──── حالة الأسئلة التوضيحية ────
  bool awaitingClarification = false;
  String clarificationContext = '';
  List<String> clarificationOptions = [];

  /// تسجيل دورة محادثة جديدة
  void recordTurn(String userMessage, String botResponse, String intent) {
    history.add(ConversationTurn(
      userMessage: userMessage,
      botResponse: botResponse,
      intent: intent,
      timestamp: DateTime.now(),
      topic: lastTopic,
    ));
    turnCount++;
    
    // الاحتفاظ بآخر 20 دورة فقط
    if (history.length > 20) history.removeAt(0);
  }

  /// استخراج كيانات من رسالة المستخدم
  void extractEntities(String normalized) {
    _extractChildAge(normalized);
    _extractChildGender(normalized);
    _extractChildName(normalized);
    _extractSymptoms(normalized);
    _extractChronicConditions(normalized);
    _extractPrematurity(normalized);
    _extractVaccineHistory(normalized);
  }

  void _extractChildAge(String n) {
    final ageMatch = RegExp(r'عمره?\s*(\d+)\s*(شهر|شهور|شه)').firstMatch(n);
    if (ageMatch != null) {
      child.ageMonths = int.tryParse(ageMatch.group(1)!);
      child.lastUpdated = DateTime.now();
    }
    final weekMatch = RegExp(r'(\d+)\s*(اسبوع|اسابيع)').firstMatch(n);
    if (weekMatch != null) {
      child.ageWeeks = int.tryParse(weekMatch.group(1)!);
      child.ageMonths = (child.ageWeeks! * 7) ~/ 30;
      child.lastUpdated = DateTime.now();
    }
    final hasMatch = RegExp(r'عنده[ا]?\s*(\d+)\s*(شه|شهر)?').firstMatch(n);
    if (hasMatch != null) {
      final v = int.tryParse(hasMatch.group(1)!);
      if (v != null && v <= 72) { child.ageMonths = v; child.lastUpdated = DateTime.now(); }
    }
  }

  void _extractChildGender(String n) {
    if (RegExp(r'ولد|ولدي|ابني|اخوي').hasMatch(n)) child.gender = 'ذكر';
    if (RegExp(r'بنت|بنتي|اختي').hasMatch(n)) child.gender = 'أنثى';
  }

  void _extractChildName(String n) {
    // نمط: اسمي X / اسمه X / يسمونه X
    final nameMatch = RegExp(r'(?:اسمه|اسمها|سميته|سميتها|يسمونه|يسمونها)\s+(\w+)').firstMatch(n);
    if (nameMatch != null) child.name = nameMatch.group(1);
  }

  void _extractSymptoms(String n) {
    final symptoms = {
      'حراره': 'حرارة', 'سخونه': 'حرارة', 'حمى': 'حرارة',
      'اسهال': 'إسهال', 'ماء ابيض': 'إسهال',
      'قيء': 'قيء', 'يرجع': 'قيء',
      'سعال': 'سعال', 'كحه': 'سعال', 'كحة': 'سعال',
      'زكام': 'زكام', 'رشح': 'زكام', 'انفلونزا': 'زكام',
      'طفح': 'طفح جلدي', 'حبوب': 'طفح جلدي',
      'الم': 'ألم', 'يتالم': 'ألم', 'يتألم': 'ألم',
      'تورم': 'تورم', 'انتفاخ': 'تورم',
      'يبكي': 'بكاء', 'بكاء': 'بكاء',
      'تشنج': 'تشنجات', 'نوبه': 'تشنجات',
      'ما ياكل': 'رفض الطعام', 'يرفض': 'رفض الطعام',
      'نعاس': 'نعاس', 'تعبان': 'تعب عام',
    };
    for (final e in symptoms.entries) {
      if (n.contains(e.key) && !child.mentionedSymptoms.contains(e.value)) {
        child.mentionedSymptoms.add(e.value);
      }
    }
  }

  void _extractChronicConditions(String n) {
    if (RegExp(r'sugar|سكري|انسولين').hasMatch(n)) { child.hasChronicDisease = true; child.chronicDiseaseType = 'سكري'; }
    if (RegExp(r'قلب|cardiac').hasMatch(n)) { child.hasChronicDisease = true; child.chronicDiseaseType = 'قلب'; }
    if (RegExp(r'hiv|ايدز').hasMatch(n)) { child.hasChronicDisease = true; child.chronicDiseaseType = 'HIV'; }
    if (RegExp(r'سرطان|اورام|كيماوي').hasMatch(n)) { child.hasChronicDisease = true; child.chronicDiseaseType = 'سرطان'; }
    if (RegExp(r'ربو|asma').hasMatch(n)) { child.hasChronicDisease = true; child.chronicDiseaseType = 'ربو'; }
    if (RegExp(r'صرع|epilepsy').hasMatch(n)) { child.hasChronicDisease = true; child.chronicDiseaseType = 'صرع'; }
  }

  void _extractPrematurity(String n) {
    if (RegExp(r'مبتسر|خديج|مبكر|premature|حضانه').hasMatch(n)) {
      child.isPremature = true;
    }
  }

  void _extractVaccineHistory(String n) {
    final vaccines = {'bcg':'bcg','بي سي جي':'bcg','شلل':'opv','خماسي':'penta','رئوي':'pcv','روتا':'rota','حصبه':'mr'};
    for (final e in vaccines.entries) {
      if (n.contains(e.key) && RegExp(r'اخذ|عطوه|خذ|طعموه|سوى').hasMatch(n)) {
        if (!child.givenVaccines.contains(e.value)) child.givenVaccines.add(e.value);
      }
    }
  }

  /// هل السؤال يتطلب توضيحاً؟
  ({bool needs, String question, List<String> options}) needsClarification(String normalized, String intent) {
    // عمر الطفل غير محدد عند سؤال عن التطعيمات
    if ((intent == 'age_query' || intent == 'vaccine_list') && !child.hasBasicInfo) {
      if (!normalized.contains(RegExp(r'عمر|شهر|اسبوع|سن|عند|عنده'))) {
        return (
          needs: true,
          question: '📅 عشان أقدر أعطيك تطعيمات طفلك بالضبط، كم عمره؟',
          options: ['عمره شهر', 'عمره 3 شهور', 'عمره 6 شهور', 'عمره 9 شهور', 'عمره سنة'],
        );
      }
    }

    // سؤال عن الآثار بدون تحديد أي تطعيم
    if (intent == 'side_effects' && lastVaccine.isEmpty && lastTopic.isEmpty) {
      final v = _detectAnyVaccine(normalized);
      if (v == null) {
        return (
          needs: true,
          question: '⚠️ عن أي تطعيم تسأل عن الآثار الجانبية؟',
          options: ['الخماسي', 'BCG', 'الحصبة', 'الروتا', 'الرئوي', 'شلل الأطفال'],
        );
      }
    }

    // سؤال مبهم جداً
    if (normalized.length < 10 && !_isGreeting(normalized) && !_isYesNo(normalized)) {
      return (
        needs: true,
        question: '🤔 ممكن توضح أكثر وش تقصد؟',
        options: ['وش تطعيمات طفلي؟', 'وش الآثار الجانبية؟', 'هل التطعيم مجاني؟'],
      );
    }

    return (needs: false, question: '', options: []);
  }

  bool _isGreeting(String n) => RegExp(r'مرحب|سلام|هلا|صباح|مساء').hasMatch(n);
  bool _isYesNo(String n) => RegExp(r'^(نعم|لا|ايه|اي|يب|ايوه|مو)$').hasMatch(n);
  String? _detectAnyVaccine(String n) {
    final v = {'bcg':['bcg','بي سي جي'],'opv':['شلل'],'penta':['خماسي'],'pcv':['رئوي'],'rota':['روتا'],'mr':['حصبه']};
    for (final e in v.entries) { for (final k in e.value) { if (n.contains(k)) return e.key; } }
    return null;
  }

  /// هل السؤال يتطلب متابعة؟
  bool isFollowUpQuestion(String normalized) {
    return RegExp(r'^(نعم|ايوه|ايه|اي|يب|اشرح|وضح|بالتفصيل|تفاصيل|كم|ليه|ليش|طيب|تمام|واضح|فهمت|اوكي)').hasMatch(normalized);
  }

  /// بناء سياق للاستشارة
  String buildConsultationContext() {
    final buf = StringBuffer();
    if (child.hasBasicInfo) buf.writeln('عمر الطفل: ${child.ageDisplay}');
    if (child.gender != null) buf.writeln('الجنس: ${child.gender}');
    if (child.name != null) buf.writeln('الاسم: ${child.name}');
    if (child.isPremature) buf.writeln('مبتسر: نعم');
    if (child.hasChronicDisease) buf.writeln('مرض مزمن: ${child.chronicDiseaseType}');
    if (child.mentionedSymptoms.isNotEmpty) buf.writeln('الأعراض: ${child.mentionedSymptoms.join(', ')}');
    if (child.givenVaccines.isNotEmpty) buf.writeln('تطعيمات أخذها: ${child.givenVaccines.join(', ')}');
    return buf.toString().trim();
  }

  /// تحديث مرحلة المحادثة
  void updatePhase(String intent) {
    if (intent == 'emergency' || child.mentionedSymptoms.contains('تشنجات')) {
      phase = ConversationPhase.emergency;
    } else if (awaitingClarification) {
      phase = ConversationPhase.clarification;
    } else if (turnCount <= 2) {
      phase = ConversationPhase.greeting;
    } else if (child.hasBasicInfo) {
      phase = ConversationPhase.consulting;
    } else {
      phase = ConversationPhase.collecting;
    }
  }

  /// إعادة تعيين
  void reset() {
    lastTopic = ''; lastVaccine = ''; lastDisease = '';
    pendingClarification = ''; awaitingClarification = false;
    clarificationContext = ''; clarificationOptions = [];
    phase = ConversationPhase.greeting;
    history.clear(); extractedEntities.clear();
    discussedTopics.clear(); turnCount = 0;
  }
}

/// دورة محادثة واحدة
class ConversationTurn {
  final String userMessage;
  final String botResponse;
  final String intent;
  final DateTime timestamp;
  final String topic;

  ConversationTurn({
    required this.userMessage,
    required this.botResponse,
    required this.intent,
    required this.timestamp,
    required this.topic,
  });
}
