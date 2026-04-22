// ══════════════════════════════════════════════════════════════════════════
//  محرك الذكاء الاصطناعي المتقدم — EPI-Bot AI Engine
//  يدعم: كشف النية بالتسجيل المرجح، ذاكرة المحادثة العميقة،
//  توليد الردود الذكية، الاستشارات الاستباقية، تحليل المشاعر العربي
//  يعمل بالكامل بدون إنترنت — لا يعتمد على أي مكتبات خارجية
// ══════════════════════════════════════════════════════════════════════════

import 'dart:math';

// ╔═════════════════════════════════════════════════════════════════════════╗
// ║  القسم ١: تحليل المشاعر العربي (SentimentAnalyzer)                     ║
// ╚═════════════════════════════════════════════════════════════════════════╝

/// أنواع المشاعر المكتشفة
enum SentimentType {
  worry,       // قلق
  confusion,   // حيرة
  urgency,     // استعجال
  gratitude,   // شكر
  frustration, // إحباط
  neutral,     // محايد
  relief,      // ارتياح
  sadness,     // حزن
}

/// نتيجة تحليل المشاعر
class SentimentResult {
  final SentimentType type;
  final double confidence;
  final String arabicLabel;
  final String? detectedPhrase;

  const SentimentResult({
    required this.type,
    required this.confidence,
    required this.arabicLabel,
    this.detectedPhrase,
  });

  @override
  String toString() => 'SentimentResult($arabicLabel, ${(confidence * 100).toStringAsFixed(1)}%)';
}

/// محلل المشاعر للنصوص العربية — يكتشف القلق والحيرة والاستعجال والشكر والإحباط
class SentimentAnalyzer {
  // ──── كلمات القلق والخوف ────
  static const Map<String, double> _worryPatterns = {
    'قلقان': 1.0, 'قلقانه': 1.0, 'قلق': 0.9, 'خايف': 1.0, 'خايفه': 1.0,
    'خوف': 0.9, 'متوتر': 0.85, 'متوترة': 0.85, 'خايف عليه': 1.0,
    'خايفه عليه': 1.0, 'قلقان عليه': 1.0, 'يمتى': 0.5, 'يخوف': 0.85,
    'مرعوب': 0.9, 'مرعوبه': 0.9, 'فزع': 0.85, 'خايفة': 1.0,
    'قلقانة': 1.0, 'رعب': 0.9, 'ما نام': 0.6, 'ما نامت': 0.6,
    'قلقان موت': 1.0, 'خايف موت': 1.0,
  };

  // ──── كلمات الحيرة والارتباك ────
  static const Map<String, double> _confusionPatterns = {
    'محتار': 1.0, 'محتاره': 1.0, 'ما ادري': 0.95, 'ما اعرف': 0.85,
    'مش فاهم': 0.9, 'مش فاهمه': 0.9, 'تائه': 0.85, 'حيران': 0.9,
    'حيرانه': 0.9, 'مشوش': 0.85, 'مشوشه': 0.85, 'ملخبط': 0.8,
    'ملخبطه': 0.8, 'ما فاهم': 0.9, 'ما فاهمه': 0.9, 'مو فاهم': 0.9,
    'مو فاهمه': 0.9, 'ابي اعرف': 0.6, 'ابغى اعرف': 0.6,
    'ليش كذا': 0.7, 'كيف يعني': 0.75, 'وش يعني': 0.7,
    'ما عارف': 0.85, 'ما عارفه': 0.85, 'مو عارف': 0.85,
  };

  // ──── كلمات الاستعجال ────
  static const Map<String, double> _urgencyPatterns = {
    'عاجل': 1.0, 'ضروري': 0.9, 'الحين': 0.85, 'بسرعة': 0.9,
    'فورا': 1.0, 'الآن': 0.85, 'سريع': 0.8, 'مستعجل': 0.95,
    'لازم الحين': 1.0, 'ضروري الحين': 1.0, 'ما اقدر انتظر': 0.9,
    'طفلي حاله حرجه': 1.0, 'حاله طوارئ': 1.0, 'بسررررعه': 1.0,
    'ابغاه الحين': 0.9, 'لازم اسوي شي': 0.85, 'ساعدني': 0.7,
    'ارجوكم': 0.8, 'الله يخليكم': 0.7,
  };

  // ──── كلمات الشكر والامتنان ────
  static const Map<String, double> _gratitudePatterns = {
    'شكرا': 1.0, 'شكراً': 1.0, 'مشكور': 0.95, 'مشكوره': 0.95,
    'يعطيك العافية': 1.0, 'يعطيكي العافية': 1.0, 'الله يعافيك': 0.9,
    'جزاك الله خير': 1.0, 'جزاكي الله خير': 1.0, 'تسلم': 0.85,
    'تسلمي': 0.85, 'مشكوور': 0.95, 'شكرا جزيلا': 1.0,
    'الله يجزاك خير': 1.0, 'ماقصرت': 0.85, 'ماقصرتي': 0.85,
    'يعطيك الف عافيه': 1.0, 'مشكووور': 0.95,
  };

  // ──── كلمات الإحباط والغضب ────
  static const Map<String, double> _frustrationPatterns = {
    'زعلان': 0.9, 'زعلانه': 0.9, 'معصب': 0.9, 'معصبه': 0.9,
    'مو عاجبني': 0.85, 'مو عاجبني شي': 0.9, 'مقهور': 0.85,
    'مقهوره': 0.85, 'مستاء': 0.85, 'مستاءه': 0.85,
    'ظالم': 0.8, 'ما شي فايده': 0.85, 'حرااام': 0.75,
    'ليش ما أحد يرد': 0.9, 'ما ابي اتكلم': 0.7,
    'كذا مو زين': 0.75, 'مو عاجبني الموضوع': 0.85,
  };

  // ──── كلمات الارتياح ────
  static const Map<String, double> _reliefPatterns = {
    'مرتاح': 0.85, 'مرتاحه': 0.85, 'مبسوط': 0.8, 'مبسوطه': 0.8,
    'فرحان': 0.8, 'فرحانه': 0.8, 'الحمد لله': 0.75,
    'الحمدالله': 0.75, 'اطمأننت': 0.9, 'اطمأننتي': 0.9,
    'الحمد لله طمني': 0.85,
  };

  // ──── كلمات الحزن ────
  static const Map<String, double> _sadnessPatterns = {
    'حزين': 0.9, 'حزينه': 0.9, 'مكسور': 0.85, 'مكسوره': 0.85,
    'ميت من القهر': 0.9, 'قلبي انكسر': 0.85, 'يا حسرة': 0.8,
  };

  /// تحليل المشاعر في النص العربي
  /// يعيد نوع المشاعر الأقوى مع نسبة الثقة
  static SentimentResult analyze(String text) {
    final normalized = _normalizeForSentiment(text);
    final scores = <SentimentType, double>{};

    // حساب نقاط كل فئة مشاعر
    scores[SentimentType.worry] = _calculateScore(normalized, _worryPatterns);
    scores[SentimentType.confusion] = _calculateScore(normalized, _confusionPatterns);
    scores[SentimentType.urgency] = _calculateScore(normalized, _urgencyPatterns);
    scores[SentimentType.gratitude] = _calculateScore(normalized, _gratitudePatterns);
    scores[SentimentType.frustration] = _calculateScore(normalized, _frustrationPatterns);
    scores[SentimentType.relief] = _calculateScore(normalized, _reliefPatterns);
    scores[SentimentType.sadness] = _calculateScore(normalized, _sadnessPatterns);

    // إيجاد الفئة الأقوى
    SentimentType bestType = SentimentType.neutral;
    double bestScore = 0.0;
    String? bestPhrase;

    for (final entry in scores.entries) {
      if (entry.value > bestScore) {
        bestScore = entry.value;
        bestType = entry.key;
        bestPhrase = _findDetectedPhrase(normalized, _getPatternsForType(bestType));
      }
    }

    // إذا لم تصل أي مشاعر لعتبة المعنوية
    if (bestScore < 0.3) {
      return const SentimentResult(
        type: SentimentType.neutral,
        confidence: 0.8,
        arabicLabel: 'محايد',
      );
    }

    return SentimentResult(
      type: bestType,
      confidence: bestScore.clamp(0.0, 1.0),
      arabicLabel: _typeToArabic(bestType),
      detectedPhrase: bestPhrase,
    );
  }

  /// تحليل متعدد — يعيد جميع المشاعر المكتشفة مرتبة
  static List<SentimentResult> analyzeAll(String text) {
    final normalized = _normalizeForSentiment(text);
    final results = <SentimentResult>[];

    final allPatterns = {
      SentimentType.worry: _worryPatterns,
      SentimentType.confusion: _confusionPatterns,
      SentimentType.urgency: _urgencyPatterns,
      SentimentType.gratitude: _gratitudePatterns,
      SentimentType.frustration: _frustrationPatterns,
      SentimentType.relief: _reliefPatterns,
      SentimentType.sadness: _sadnessPatterns,
    };

    for (final entry in allPatterns.entries) {
      final score = _calculateScore(normalized, entry.value);
      if (score >= 0.3) {
        results.add(SentimentResult(
          type: entry.key,
          confidence: score.clamp(0.0, 1.0),
          arabicLabel: _typeToArabic(entry.key),
          detectedPhrase: _findDetectedPhrase(normalized, entry.value),
        ));
      }
    }

    results.sort((a, b) => b.confidence.compareTo(a.confidence));
    return results;
  }

  /// هل المستخدم قلق؟
  static bool isWorried(String text) {
    final result = analyze(text);
    return result.type == SentimentType.worry && result.confidence >= 0.5;
  }

  /// هل المستخدم محتاج دعم عاطفي؟
  static bool needsEmotionalSupport(String text) {
    final result = analyze(text);
    return (result.type == SentimentType.worry ||
            result.type == SentimentType.frustration ||
            result.type == SentimentType.sadness) &&
           result.confidence >= 0.5;
  }

  // ──── وظائف مساعدة خاصة ────

  static String _normalizeForSentiment(String text) {
    var t = text.trim();
    // إزالة التشكيل
    t = t.replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '');
    // توحيد الحروف المتشابهة
    t = t.replaceAll('أ', 'ا').replaceAll('إ', 'ا').replaceAll('آ', 'ا');
    t = t.replaceAll('ة', 'ه').replaceAll('ى', 'ي').replaceAll('ؤ', 'و').replaceAll('ئ', 'ي');
    t = t.replaceAll('ء', '');
    // توحيد المسافات
    t = t.replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
    return t;
  }

  static double _calculateScore(String normalized, Map<String, double> patterns) {
    double maxScore = 0.0;
    double totalScore = 0.0;
    int matchCount = 0;

    for (final pattern in patterns.entries) {
      if (normalized.contains(pattern.key)) {
        totalScore += pattern.value;
        matchCount++;
        if (pattern.value > maxScore) maxScore = pattern.value;
      }
    }

    if (matchCount == 0) return 0.0;

    // الجمع بين أقوى تطابق ومتوسط التطابقات
    final avgScore = totalScore / matchCount;
    final combined = (maxScore * 0.6) + (avgScore * 0.4);

    // تعزيز إذا تطابقات متعددة
    final multiMatchBoost = matchCount > 1 ? 1.0 + (matchCount - 1) * 0.1 : 1.0;

    return (combined * multiMatchBoost).clamp(0.0, 1.0);
  }

  static String? _findDetectedPhrase(String normalized, Map<String, double> patterns) {
    for (final pattern in patterns.entries) {
      if (normalized.contains(pattern.key)) return pattern.key;
    }
    return null;
  }

  static Map<String, double> _getPatternsForType(SentimentType type) {
    switch (type) {
      case SentimentType.worry: return _worryPatterns;
      case SentimentType.confusion: return _confusionPatterns;
      case SentimentType.urgency: return _urgencyPatterns;
      case SentimentType.gratitude: return _gratitudePatterns;
      case SentimentType.frustration: return _frustrationPatterns;
      case SentimentType.relief: return _reliefPatterns;
      case SentimentType.sadness: return _sadnessPatterns;
      case SentimentType.neutral: return {};
    }
  }

  static String _typeToArabic(SentimentType type) {
    switch (type) {
      case SentimentType.worry: return 'قلق';
      case SentimentType.confusion: return 'حيرة';
      case SentimentType.urgency: return 'استعجال';
      case SentimentType.gratitude: return 'شكر';
      case SentimentType.frustration: return 'إحباط';
      case SentimentType.relief: return 'ارتياح';
      case SentimentType.sadness: return 'حزن';
      case SentimentType.neutral: return 'محايد';
    }
  }
}


// ╔═════════════════════════════════════════════════════════════════════════╗
// ║  القسم ٢: كاشف النية الذكي بالتسجيل المرجح (IntelligentIntentDetector)   ║
// ╚═════════════════════════════════════════════════════════════════════════╝

/// نتيجة كشف النية المتقدمة
class AdvancedIntentResult {
  final String intent;
  final double confidence;
  final Map<String, double> allScores;
  final List<String> matchedKeywords;
  final String? contextBoost;

  const AdvancedIntentResult({
    required this.intent,
    required this.confidence,
    this.allScores = const {},
    this.matchedKeywords = const [],
    this.contextBoost,
  });

  bool get isHighConfidence => confidence >= 0.75;
  bool get isMediumConfidence => confidence >= 0.40 && confidence < 0.75;
  bool get isLowConfidence => confidence < 0.40;

  @override
  String toString() =>
      'AdvancedIntentResult($intent, ${(confidence * 100).toStringAsFixed(1)}%, matched: ${matchedKeywords.length})';
}

/// كاشف النية المتقدم — يستخدم التسجيل المرجح مع السياق والتشابه الدلالي
class IntelligentIntentDetector {
  // ──── خريطة النوايا مع الكلمات المفتاحية والأوزان ────
  // كل نية تحتوي على: كلمات مفتاحية → وزنها
  // الأوزان: 1.0 = كلمة حاسمة، 0.7 = كلمة قوية، 0.5 = كلمة متوسطة، 0.3 = كلمة ضعيفة

  static final Map<String, Map<String, double>> _intentKeywords = {
    // ═══════════════════════════════════════════════════
    //  نوايا المستخدم الأساسية
    // ═══════════════════════════════════════════════════

    'age_query': {
      'عمر': 0.9, 'شهر': 0.7, 'اسبوع': 0.7, 'سن': 0.7, 'كبر': 0.5,
      'صغير': 0.4, 'عمره': 0.8, 'عمرها': 0.8, 'عنده': 0.5,
      'عمر الطفل': 1.0, 'كم عمر': 0.9, 'سن الطفل': 0.8,
      'مواليد': 0.6, 'حديثي الولاده': 0.7, 'وليد': 0.5,
    },

    'vaccine_list': {
      'تطعيمات': 0.9, 'لقاحات': 0.9, 'تطعيم': 0.7, 'لقاح': 0.7,
      'وش التطعيمات': 1.0, 'ايش التطعيمات': 1.0, 'كل التطعيمات': 1.0,
      'تطعيمات الطفل': 1.0, 'تطعيمات ولدي': 1.0, 'تطعيمات بنتي': 1.0,
      'تحصينات': 0.8, 'برنامج التحصين': 0.9, 'زبارات': 0.6,
      'حقن': 0.4, 'جرعات': 0.5,
    },

    'schedule_query': {
      'متى': 0.6, 'جدول': 0.9, 'مواعيد': 0.8, 'موعد': 0.7,
      'جدول التحصين': 1.0, 'جدول التطعيمات': 1.0, 'الجدول': 0.8,
      'الجدول الكامل': 1.0, 'الجدول الوطني': 1.0, 'متى اطعم': 0.9,
      'متى اعطيه': 0.8, 'متى ياخذ': 0.8, 'فاصل': 0.6,
      'مواعيد التطعيم': 0.9,
    },

    'dose_count': {
      'كم جرعه': 1.0, 'كم جرعة': 1.0, 'كم حقه': 1.0, 'كم حقنة': 1.0,
      'عدد الجرعات': 1.0, 'كم مره': 0.8, 'كم عدد': 0.6,
      'جرعه': 0.5, 'جرعات': 0.5,
    },

    'side_effects': {
      'اثار جانبيه': 1.0, 'اعراض جانبيه': 1.0, 'آثار جانبية': 1.0,
      'وش يصير بعد': 0.9, 'وش يسوي بعد': 0.9, 'يحصل بعد': 0.7,
      'مضاعفات': 0.8, 'تأثيرات': 0.7, 'رد فعل': 0.7,
      'حراره بعد': 0.8, 'تورم': 0.6, 'احمرار': 0.6,
      'الم مكان': 0.7, 'بكاء': 0.5,
    },

    'emergency': {
      'طوارئ': 1.0, 'عاجل': 0.9, 'مستعجل': 0.9, 'حاله حرجه': 1.0,
      'خطر': 0.8, 'اسعاف': 0.9, 'تشنج': 0.85, 'تشنجات': 0.9,
      'صعوبة تنفس': 1.0, 'يغيب عن الوعي': 1.0, 'حساسيه شديده': 0.9,
      'تورم الوجه': 1.0, 'متى اخاف': 0.8, 'اروح المستشفى': 0.8,
      'متى اروح الطبيب': 0.8,
    },

    'location': {
      'وين': 0.7, 'اين': 0.7, 'مركز': 0.7, 'مستشفى': 0.5,
      'مركز صحي': 1.0, 'وحده صحيه': 0.9, 'نقطه تطعيم': 0.9,
      'وين اطعم': 1.0, 'اين اطعم': 1.0, 'وين اوديه': 0.9,
      'اقرب مركز': 1.0, 'عياده': 0.6, 'مكان تطعيم': 0.9,
    },

    'cost': {
      'مجاني': 1.0, 'مجانا': 1.0, 'بلاش': 0.9, 'فلوس': 0.7,
      'يكلف': 0.8, 'رسوم': 0.7, 'بدون فلوس': 0.9, 'بلا رسوم': 0.9,
      'هل مجاني': 1.0, 'كم يكلف': 0.8, 'مو بفلوس': 0.8,
    },

    'campaigns': {
      'حمله': 0.9, 'حملات': 0.9, 'تطعيم وطني': 1.0, 'ايام التحصين': 1.0,
      'يوم التحصين': 0.9, 'nids': 0.9, 'sia': 0.8, 'حملة تطعيم': 1.0,
      'حملة تحصين': 1.0, 'تكميليه': 0.7, 'حملات وطنيه': 0.9,
    },

    'vaccine_types': {
      'انواع': 0.8, 'نوع': 0.7, 'وش انواع': 0.9, 'ايش انواع': 0.9,
      'حي مضعف': 0.8, 'ميت': 0.6, 'سكريات مقترنه': 0.7,
      'هندسه وراثيه': 0.7, 'سموم معالجه': 0.7,
    },

    'myths': {
      'اسطوره': 1.0, 'اساطير': 1.0, 'خرافه': 0.9, 'خرافات': 0.9,
      'توحد': 0.9, 'اوتيزم': 0.9, 'عقم': 0.9, 'خصوبه': 0.7,
      'يسبب مرض': 0.8, 'مو امن': 0.7, 'ضار': 0.7, 'مو زين': 0.5,
      'هل يسبب': 0.8, 'مواد ضاره': 0.8,
    },

    'special_cases': {
      'حاله خاصه': 1.0, 'مبتسر': 0.9, 'خديج': 0.9, 'مريض': 0.6,
      'سكر': 0.7, 'سكري': 0.8, 'قلب': 0.6, 'سرطان': 0.7,
      'hiv': 0.8, 'ايدز': 0.8, 'ربو': 0.7, 'صرع': 0.7,
      'نقص مناعه': 0.9, 'مولود مبكر': 0.9,
    },

    'nutrition': {
      'تغذيه': 0.9, 'تغذية': 0.9, 'اكل': 0.5, 'غذاء': 0.6,
      'فيتامين': 0.8, 'حليب': 0.6, 'رضاعه': 0.7, 'رضاعة': 0.7,
      'نحافه': 0.6, 'سمنه': 0.5, 'تغذيه الطفل': 0.9,
    },

    'cold_chain': {
      'تبريد': 0.9, 'سلسله بارده': 1.0, 'سلسلة التبريد': 1.0,
      'ثلاجه': 0.7, 'تخزين': 0.7, 'vvm': 0.9, 'درجه حراره': 0.6,
      'فريزر': 0.7, 'صندوق تبريد': 0.8, 'حافظه باردة': 0.8,
      'تجميد': 0.6, 'صلاحيه اللقاح': 0.8,
    },

    'travel': {
      'سفر': 0.8, 'مسافر': 0.8, 'سياحه': 0.5, 'مطار': 0.4,
      'سافر': 0.6, 'رحله': 0.5, 'تطعيمات السفر': 1.0,
    },

    'history': {
      'تاريخ': 0.7, 'بدايه': 0.6, 'من اول': 0.5, 'متى بدأ': 0.7,
      'تاريخ التحصين': 1.0, 'منو أسس': 0.6, 'اصل': 0.5,
    },

    'benefits': {
      'فوائد': 0.9, 'فايده': 0.9, 'منفعه': 0.7, 'ليش مهم': 0.9,
      'وش الفايده': 1.0, 'اهميه': 0.8, 'فائده': 0.8,
      'ليش اطعم': 0.8, 'ليش التطعيم مهم': 1.0,
    },

    'diseases': {
      'امراض': 0.8, 'مرض': 0.6, 'عدوى': 0.7, 'وباء': 0.6,
      'وش الامراض': 0.9, 'ايش الامراض': 0.9, 'امراض التطعيمات': 0.9,
      'سل': 0.5, 'شلل': 0.5, 'حصبه': 0.5, 'خناق': 0.5,
      'كزاز': 0.5, 'سعال ديكي': 0.6, 'كبد': 0.4,
    },

    'child_sick': {
      'مريض': 0.7, 'تعبان': 0.7, 'حراره': 0.5, 'اسهال': 0.5,
      'سعال': 0.4, 'زكام': 0.4, 'قى': 0.5, 'قىء': 0.5,
      'ولدي مريض': 1.0, 'طفلي مريض': 1.0, 'هل اطعم وهو مريض': 1.0,
      'حرارته عاليه': 0.8, 'ما ياكل': 0.5,
    },

    'supervision': {
      'اشراف': 0.9, 'اشرافي': 0.8, 'زياره اشرافيه': 1.0,
      'متابعه': 0.6, 'تقييم': 0.5, 'رقابه': 0.6,
      'supervision': 0.7, 'توجيه': 0.5,
    },

    'management': {
      'اداره': 0.8, 'مدير': 0.7, 'تخطيط': 0.6, 'تنظيم': 0.5,
      'قياده': 0.6, 'اداري': 0.7, 'مديريه': 0.6,
    },

    'reminder': {
      'تذكير': 1.0, 'موعد': 0.7, 'لازم اطعم': 0.8, 'نسييت': 0.7,
      'نسيت': 0.7, 'فاتني': 0.7, 'فاتني الموعد': 0.9,
      'ما طعمته': 0.8, 'متأخر': 0.7,
    },

    'feedback': {
      'تغذيه راجعه': 1.0, 'ملاحظات': 0.8, 'اقتراح': 0.8,
      'راي': 0.7, 'رأي': 0.7, 'شكوى': 0.7, 'شكاوه': 0.7,
    },

    // ═══════════════════════════════════════════════════
    //  نوايا إدارية وتقنية متقدمة
    // ═══════════════════════════════════════════════════

    'intermediate_management': {
      'اداره وسيطه': 1.0, 'ادارة وسيطة': 1.0, 'المستوى الوسيط': 1.0,
      'مدير مكتب': 0.9, 'مدير محافظه': 0.9, 'مستوى وسيط': 0.9,
      'intermediate management': 0.8, 'الاداره الوسيطه': 0.9,
    },

    'supportive_supervision': {
      'اشراف داعم': 1.0, 'supportive supervision': 1.0,
      'اشرافي داعم': 0.9, 'زياره اشرافيه داعمه': 0.9,
      'الاشراف الداعم': 1.0,
    },

    'hmis_reporting': {
      'hmis': 1.0, 'dhis2': 0.9, 'نظام المعلومات': 0.9,
      'نظام معلومات صحيه': 1.0, 'تقارير': 0.6, 'ابلاغ': 0.5,
      'ديس تو': 0.8, 'دحيس': 0.7,
    },

    'microplanning': {
      'تخطيط دقيق': 1.0, 'ميكروبلان': 1.0, 'microplanning': 1.0,
      'مايكروبلانينج': 0.9, 'تخطيط محلي': 0.9, 'خطة تشغيليه': 0.9,
      'خطه تنفيذيه': 0.9,
    },

    'outbreak_response': {
      'استجابه للاوبئه': 1.0, 'استجابه وبائيه': 1.0,
      'outbreak response': 1.0, 'استجابه سريعه': 0.9,
      'مكافحة الاوبئة': 0.9, 'وبائيات': 0.7, 'فاشيه': 0.8,
      'فاشية': 0.8,
    },

    'vaccine_management': {
      'اداره اللقاحات': 1.0, 'vaccine management': 1.0,
      'اداره التطعيمات': 0.9, 'اداره المخزون': 0.7,
      'ادارة اللقاح': 0.9,
    },

    'aefi_reporting': {
      'aefi': 1.0, 'الاعراض الضاره بعد التطعيم': 1.0,
      'adverse events': 0.9, 'احداث ضاره': 0.9, 'تاثيرات ضاره': 0.9,
      'بلاغ aefi': 1.0, 'ابلاغ عن اثار': 0.9,
    },

    'coverage_monitoring': {
      'تغطيه': 0.9, 'رصد التغطيات': 1.0, 'coverage monitoring': 1.0,
      'نسب التغطيه': 1.0, 'مؤشرات تغطيه': 0.9, 'تغطية تحصين': 0.9,
      'تغطيه وطنيه': 0.8,
    },

    'school_immunization': {
      'تحصين المدارس': 1.0, 'school immunization': 1.0,
      'تطعيم المدارس': 1.0, 'تطعيم طلاب': 0.9, 'تطعيم طالبات': 0.9,
      'تحصين مدرسي': 0.9, 'فحص مدرسي': 0.8, 'مدرسه': 0.5,
      'مدرسة': 0.5, 'طلاب': 0.6, 'تلاميذ': 0.6,
    },

    'cold_chain_management': {
      'اداره سلسله التبريد': 1.0, 'cold chain management': 1.0,
      'تبريد اللقاحات': 0.9, 'حفظ اللقاح': 0.9,
      'سلسله بارده': 0.8, 'ادارة سلسلة التبريد': 1.0,
    },

    'waste_management': {
      'نفايات': 0.9, 'التخلص من النفايات': 1.0, 'waste management': 1.0,
      'نفايات طبيه': 1.0, 'نفايات حاده': 0.9, 'تخلص من ابر': 0.9,
      'تخلص من محاقن': 0.9, 'سلامه الحقن': 0.7, 'حناديق': 0.7,
      'صناديق امان': 0.8,
    },

    'session_planning': {
      'تخطيط الجلسات': 1.0, 'session planning': 1.0,
      'جلسه تطعيم': 0.9, 'جلسات تطعيم': 0.9, 'تنظيم الجلسه': 0.9,
      'تخطيط جلسه': 0.9, 'اعداد الجلسه': 0.9,
    },

    'demand_generation': {
      'تعزيز الطلب': 1.0, 'demand generation': 1.0,
      'توعيه مجتمعيه': 0.8, 'تسويق اجتماعي': 0.9,
      'تشجيع التحصين': 0.9, 'تعزيز الطلب المجتمعي': 1.0,
    },

    'community_engagement': {
      'مشاركه مجتمعيه': 1.0, 'community engagement': 1.0,
      'مشاركة المجتمع': 1.0, 'انخراط مجتمعي': 0.9,
      'تعبئه مجتمعيه': 0.9, 'قاده مجتمعيين': 0.8,
    },

    'data_quality': {
      'جوده البيانات': 1.0, 'data quality': 1.0, 'دقه البيانات': 0.9,
      'موثوقيه البيانات': 0.9, 'سلامه البيانات': 0.8,
      'تحقق البيانات': 0.9, 'تحقق من البيانات': 0.9,
    },

    'stock_management': {
      'مخزون': 0.9, 'اداره المخزون': 1.0, 'stock management': 1.0,
      'حصر اللقاحات': 0.9, 'جرد': 0.8, 'مخزون لقاحات': 0.9,
      'رصيد': 0.7, 'نواقص': 0.7, 'احتياج': 0.7,
    },

    'drop_out_analysis': {
      'تسرب': 0.9, 'تحليل التسرب': 1.0, 'drop out analysis': 1.0,
      'dropout': 0.9, 'تسرب التحصين': 0.9, 'متسربين': 0.8,
      'نسبه التسرب': 0.9, 'فجوه التسرب': 0.9,
    },

    'defaulter_tracing': {
      'تتبع المتخلفين': 1.0, 'defaulter tracing': 1.0,
      'متخلفين': 0.8, 'متاخرين': 0.7, 'تتبع الحالات': 0.8,
      'استرجاع المتخلفين': 0.9, 'بحث عن المتخلفين': 0.9,
    },

    'open_vial_policy': {
      'سياسه القاروره المفتوحه': 1.0, 'open vial policy': 1.0,
      'ovp': 0.9, 'قاروره مفتوحه': 0.9, 'قارورة مفتوحة': 0.9,
      'سياسة القارورة المفتوحة': 1.0,
    },

    'surveillance': {
      'رصد وبائي': 1.0, 'surveillance': 0.9, 'ترصد': 0.9,
      'نظام رصد': 0.9, 'رصد الامراض': 0.9, 'مراقبه وبائيه': 0.9,
      'applied epidemiology': 0.7, 'رصد': 0.6,
    },

    'training': {
      'تدريب': 0.9, 'capacity building': 0.9, 'بناء قدرات': 0.9,
      'ورشه عمل': 0.8, 'ورشه تدريبيه': 0.9, 'محاضره': 0.7,
      'تعليم مستمر': 0.8,
    },

    'injection_safety': {
      'سلامه الحقن': 1.0, 'injection safety': 1.0,
      'حقن آمن': 0.9, 'حقن امن': 0.9, 'سلامه ابر': 0.9,
      'محاقن ذاتيه التلف': 0.8, 'ads': 0.7,
    },

    'greeting': {
      'مرحبا': 1.0, 'مرحبًا': 1.0, 'سلام': 0.9, 'هلا': 0.9,
      'صباح الخير': 0.8, 'مساء الخير': 0.8, 'اهلا': 0.9,
      'هاي': 0.7, 'الو': 0.5, 'شلونك': 0.6, 'كيفك': 0.6,
      'كيف حالك': 0.5, 'اهلين': 0.8,
    },

    'follow_up': {
      'نعم': 0.5, 'ايوه': 0.5, 'طيب': 0.5, 'تمام': 0.4,
      'اشرح': 0.7, 'وضح': 0.7, 'بالتفصيل': 0.7, 'تفاصيل': 0.6,
      'ليه': 0.5, 'ليش': 0.5, 'فهمت': 0.3, 'اوكي': 0.3,
    },

    'vaccine_comparison': {
      'فرق': 0.8, 'مقارنه': 0.9, 'قارن': 0.9, 'افضل': 0.6,
      'ايش الفرق': 1.0, 'وش الفرق': 1.0, 'ولّا': 0.5,
    },

    'contraindications': {
      'موانع': 1.0, 'يمنع': 0.8, 'ما يقدر ياخذ': 0.9,
      'موانع التطعيم': 1.0, 'حساسيه': 0.7, 'استبعاد': 0.7,
    },

    'breastfeeding': {
      'رضاعه': 0.9, 'رضاعة': 0.9, 'حليب': 0.7, 'يرضع': 0.8,
      'حليب الام': 0.9, 'ارضاع': 0.8, 'ثدي': 0.5,
      'الرضاعة الطبيعيه': 1.0,
    },

    'pregnancy': {
      'حوامل': 0.9, 'حامل': 0.9, 'حامله': 0.9, 'ام': 0.4,
      'الام الحامل': 0.9, 'نساء حوامل': 0.9, 'td': 0.6, 'tt': 0.6,
      'كزاز الحوامل': 1.0,
    },

    'premature': {
      'مبتسر': 1.0, 'خديج': 1.0, 'مولود مبكر': 1.0,
      'قبل الاوان': 0.9, 'premature': 0.9, 'preterm': 0.9,
      'حضانه': 0.7,
    },

    'chronic_disease': {
      'سكر': 0.7, 'سكري': 0.8, 'قلب': 0.7, 'سرطان': 0.8,
      'hiv': 0.9, 'ايدز': 0.9, 'ربو': 0.7, 'صرع': 0.7,
      'مرض مزمن': 1.0, 'انسولين': 0.7, 'كيماوي': 0.7,
    },

    'immunology': {
      'مناعه': 0.9, 'مناعة': 0.9, 'جهاز المناع': 1.0,
      'اجسام مضاده': 0.9, 'خلايا ب': 0.7, 'immunity': 0.8,
      'حصانه': 0.8, 'حمايه': 0.6, 'مناعه مجتمعيه': 1.0,
    },

    'vitamin_a': {
      'فيتامين': 0.8, 'فيتامين ا': 1.0, 'فيتامين أ': 1.0,
      'كبسوله': 0.7, 'كبسولات': 0.7, 'كبسولة حمراء': 1.0,
      'كبسولة زرقاء': 0.9, 'vitamin a': 0.9,
    },

    'polio_status': {
      'شلل اطفال': 0.9, 'خاليه من شلل': 1.0, 'polio': 0.8,
      'بوليو': 0.8, 'هل اليمن خاليه': 1.0, 'polio free': 1.0,
    },

    'vaccine_safety': {
      'امان': 0.8, 'آمن': 0.9, 'امنه': 0.9, 'مضمون': 0.7,
      'مو ضار': 0.8, 'ما يضر': 0.8, 'مو خطر': 0.8,
      'هل التطعيم امن': 1.0, 'سلامه اللقاح': 1.0,
    },

    'adverse_events': {
      'حادث ضار': 1.0, 'احداث ضاره': 1.0, 'تاثيرات خطيره': 0.9,
      'رد فعل تحسسي': 1.0, 'anaphylaxis': 0.9, 'صدمه تحسسيه': 1.0,
    },

    'social_mobilization': {
      'تعبئه اجتماعيه': 1.0, 'social mobilization': 1.0,
      'مجتمع': 0.4, 'توعيه': 0.7, 'رسائل صحيه': 0.8,
    },

    'coordination': {
      'تنسيق': 0.9, 'coordination': 0.9, 'شراكه': 0.8,
      'تعاون': 0.7, 'تكامل': 0.7, 'تنسيق بين القطاعات': 1.0,
    },

    'quality_improvement': {
      'تحسين الجوده': 1.0, 'quality improvement': 1.0,
      'تطوير': 0.6, 'تحسين': 0.7, 'معايير': 0.6,
      'جوده الخدمه': 0.9, 'اعتماد': 0.6,
    },
  };

  /// علاقات التشابه الدلالي بين النوايا — تستخدم لتعزيز النوايا ذات الصلة
  static final Map<String, List<String>> _intentSimilarity = {
    'side_effects': ['emergency', 'aefi_reporting', 'adverse_events', 'vaccine_safety'],
    'special_cases': ['premature', 'chronic_disease', 'breastfeeding', 'pregnancy', 'contraindications'],
    'cold_chain': ['cold_chain_management', 'vaccine_management', 'stock_management'],
    'campaigns': ['demand_generation', 'social_mobilization', 'community_engagement'],
    'schedule_query': ['age_query', 'vaccine_list', 'dose_count'],
    'supervision': ['supportive_supervision', 'management', 'intermediate_management'],
    'management': ['intermediate_management', 'supervision', 'training'],
    'child_sick': ['emergency', 'side_effects', 'contraindications'],
    'diseases': ['vaccine_types', 'immunology', 'benefits'],
    'coverage_monitoring': ['hmis_reporting', 'data_quality', 'drop_out_analysis'],
    'drop_out_analysis': ['defaulter_tracing', 'coverage_monitoring'],
    'vaccine_safety': ['side_effects', 'aefi_reporting', 'myths'],
    'breastfeeding': ['nutrition', 'pregnancy', 'special_cases'],
    'immunology': ['vaccine_types', 'benefits', 'vaccine_safety'],
  };

  /// كشف النية الرئيسي — يعيد أفضل نية مع نقاط جميع النوايا
  static AdvancedIntentResult detect(
    String normalizedText, {
    String? previousIntent,
    String? lastTopic,
    int? childAgeMonths,
  }) {
    final keywords = _extractWeightedKeywords(normalizedText);
    final scores = <String, double>{};
    final matchedKeywordsMap = <String, List<String>>{};

    // ═══ الخطوة ١: حساب النقاط الأساسية لكل نية ═══
    for (final intentEntry in _intentKeywords.entries) {
      final intentName = intentEntry.key;
      final keywordWeights = intentEntry.value;
      double score = 0.0;
      final matched = <String>[];

      for (final kw in keywords) {
        // تطابق مباشر
        if (keywordWeights.containsKey(kw.word)) {
          score += kw.weight * keywordWeights[kw.word]!;
          matched.add(kw.word);
        }

        // تطابق جزئي — كلمة المستخدم تحتوي على كلمة مفتاحية أو العكس
        for (final entry in keywordWeights.entries) {
          if (kw.word.length > 3 && entry.key.length > 3) {
            if (kw.word.contains(entry.key) || entry.key.contains(kw.word)) {
              final partialScore = kw.weight * entry.value * 0.6;
              if (partialScore > 0.2 && !matched.contains(entry.key)) {
                score += partialScore;
                matched.add(entry.key);
              }
            }
          }
        }
      }

      // حساب التشابه الدلالي (تداخل الكلمات)
      final semanticScore = _calculateSemanticSimilarity(normalizedText, keywordWeights);
      score += semanticScore * 0.3;

      if (score > 0) {
        scores[intentName] = score;
        matchedKeywordsMap[intentName] = matched;
      }
    }

    // ═══ الخطوة ٢: تعزيز السياق — إذا كان هناك نية سابقة ═══
    if (previousIntent != null && previousIntent.isNotEmpty) {
      _applyContextBoost(scores, previousIntent, 0.15);
    }
    if (lastTopic != null && lastTopic.isNotEmpty) {
      _applyContextBoost(scores, lastTopic, 0.1);
    }

    // ═══ الخطوة ٣: تعزيز حسب العمر ═══
    if (childAgeMonths != null) {
      _applyAgeBoost(scores, childAgeMonths);
    }

    // ═══ الخطوة ٤: تطبيع النقاط ═══
    if (scores.isEmpty) {
      return const AdvancedIntentResult(
        intent: 'unknown',
        confidence: 0.0,
        allScores: {},
        matchedKeywords: [],
      );
    }

    // تطبيع بـ sigmoid لتقليل التباين
    final maxScore = scores.values.reduce(max);
    final normalizedScores = <String, double>{};
    for (final e in scores.entries) {
      normalizedScores[e.key] = maxScore > 0 ? e.value / maxScore : 0.0;
    }

    // ═══ الخطوة ٥: اختيار أفضل نية ═══
    String bestIntent = 'unknown';
    double bestScore = 0.0;
    for (final e in normalizedScores.entries) {
      if (e.value > bestScore) {
        bestScore = e.value;
        bestIntent = e.key;
      }
    }

    return AdvancedIntentResult(
      intent: bestIntent,
      confidence: bestScore.clamp(0.0, 1.0),
      allScores: normalizedScores,
      matchedKeywords: matchedKeywordsMap[bestIntent] ?? [],
      contextBoost: previousIntent,
    );
  }

  /// كشف متعدد النوايا — يعيد أفضل ٣ نوايا
  static List<AdvancedIntentResult> detectTopN(
    String normalizedText, {
    int n = 3,
    String? previousIntent,
    String? lastTopic,
    int? childAgeMonths,
  }) {
    final result = detect(
      normalizedText,
      previousIntent: previousIntent,
      lastTopic: lastTopic,
      childAgeMonths: childAgeMonths,
    );

    final results = <AdvancedIntentResult>[];
    final sorted = result.allScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (int i = 0; i < n && i < sorted.length; i++) {
      results.add(AdvancedIntentResult(
        intent: sorted[i].key,
        confidence: sorted[i].value.clamp(0.0, 1.0),
        allScores: result.allScores,
        matchedKeywords: [],
      ));
    }

    return results;
  }

  // ──── وظائف مساعدة خاصة ────

  /// استخراج الكلمات المفتاحية مع أوزانها من النص
  static List<_WeightedWord> _extractWeightedKeywords(String text) {
    final words = text.split(' ').where((w) => w.length > 1).toList();
    final result = <_WeightedWord>[];

    for (final word in words) {
      // كلمات الاستفهام لها وزن أعلى
      double weight = 1.0;
      if (['وش', 'ايش', 'ليش', 'ليه', 'كيف', 'متى', 'اين', 'وين', 'كم', 'هل'].contains(word)) {
        weight = 1.3;
      }
      // الكلمات الطويلة أكثر دلالة
      if (word.length >= 5) weight *= 1.1;
      result.add(_WeightedWord(word, weight));
    }

    // أزواج الكلمات (bigrams) لها وزن أعلى
    for (int i = 0; i < words.length - 1; i++) {
      final bigram = '${words[i]} ${words[i + 1]}';
      result.add(_WeightedWord(bigram, 1.5));
    }

    return result;
  }

  /// حساب التشابه الدلالي — تداخل الكلمات بين النص والنية
  static double _calculateSemanticSimilarity(String text, Map<String, double> intentKeywords) {
    final textWords = text.split(' ').where((w) => w.length > 2).toSet();
    final intentWords = intentKeywords.keys
        .expand((k) => k.split(' '))
        .where((w) => w.length > 2)
        .toSet();

    if (textWords.isEmpty || intentWords.isEmpty) return 0.0;

    final overlap = textWords.intersection(intentWords).length;
    final union = textWords.union(intentWords).length;

    return union > 0 ? overlap / union : 0.0;
  }

  /// تطبيق تعزيز السياق — يعزز النوايا المتشابهة مع النية السابقة
  static void _applyContextBoost(Map<String, double> scores, String previousIntent, double boostAmount) {
    // تعزيز مباشر للنية السابقة
    if (scores.containsKey(previousIntent)) {
      scores[previousIntent] = scores[previousIntent]! + boostAmount;
    }

    // تعزيز النوايا المتشابهة
    final similar = _intentSimilarity[previousIntent] ?? [];
    for (final sim in similar) {
      if (scores.containsKey(sim)) {
        scores[sim] = scores[sim]! + (boostAmount * 0.5);
      }
    }
  }

  /// تعزيز حسب عمر الطفل
  static void _applyAgeBoost(Map<String, double> scores, int ageMonths) {
    if (ageMonths <= 1) {
      _boostScores(scores, ['age_query', 'vaccine_list', 'breastfeeding'], 0.1);
    } else if (ageMonths >= 8 && ageMonths <= 10) {
      _boostScores(scores, ['age_query', 'schedule_query', 'vaccine_list'], 0.15);
    } else if (ageMonths >= 16 && ageMonths <= 19) {
      _boostScores(scores, ['age_query', 'schedule_query', 'reminder'], 0.15);
    }
  }

  static void _boostScores(Map<String, double> scores, List<String> intents, double amount) {
    for (final intent in intents) {
      if (scores.containsKey(intent)) {
        scores[intent] = scores[intent]! + amount;
      }
    }
  }
}

/// كلمة مفتاحية مع وزنها
class _WeightedWord {
  final String word;
  final double weight;
  const _WeightedWord(this.word, this.weight);
}


// ╔═════════════════════════════════════════════════════════════════════════╗
// ║  القسم ٣: ذاكرة المحادثة العميقة (ConversationMemory)                  ║
// ╚═════════════════════════════════════════════════════════════════════════╝

/// الحالة العاطفية للمستخدم
enum EmotionalState {
  worried,    // قلقان
  confident,  // واثق
  confused,   // محتار
  angry,      // معصب
  neutral,    // عادي
}

/// سجل موضوع نوقش
class DiscussedTopic {
  final String topic;
  final DateTime timestamp;
  final String intent;
  int mentionCount;

  DiscussedTopic({
    required this.topic,
    required this.timestamp,
    required this.intent,
    this.mentionCount = 1,
  });
}

/// دورة محادثة واحدة
class MemoryTurn {
  final String userMessage;
  final String botResponse;
  final String intent;
  final SentimentType sentiment;
  final DateTime timestamp;
  final String topic;

  MemoryTurn({
    required this.userMessage,
    required this.botResponse,
    required this.intent,
    required this.sentiment,
    required this.timestamp,
    required this.topic,
  });
}

/// ملف الطفل في الذاكرة
class ChildMemoryProfile {
  String? name;
  int? ageMonths;
  int? ageWeeks;
  String? gender;
  bool isPremature = false;
  bool hasChronicDisease = false;
  String? chronicDiseaseType;
  List<String> givenVaccines = [];
  List<String> mentionedSymptoms = [];
  List<String> allergies = [];
  DateTime? lastUpdated;

  bool get hasBasicInfo => ageMonths != null || ageWeeks != null;

  String get ageDisplay {
    if (ageMonths != null && ageMonths! > 0) return '$ageMonths أشهر';
    if (ageWeeks != null && ageWeeks! > 0) return '$ageWeeks أسابيع';
    return 'غير محدد';
  }

  void updateFromNormalized(String normalized) {
    // استخراج العمر
    final monthMatch = RegExp(r'(?:عمره|عمرها|عندو|عنده|عندها)\s*(\d+)\s*(شهر|شهور|شه)').firstMatch(normalized);
    if (monthMatch != null) {
      final v = int.tryParse(monthMatch.group(1)!);
      if (v != null && v <= 72) { ageMonths = v; lastUpdated = DateTime.now(); }
    }

    final weekMatch = RegExp(r'(\d+)\s*(اسبوع|اسابيع)').firstMatch(normalized);
    if (weekMatch != null) {
      final v = int.tryParse(weekMatch.group(1)!);
      if (v != null && v <= 104) { ageWeeks = v; ageMonths = (v * 7) ~/ 30; lastUpdated = DateTime.now(); }
    }

    // استخراج الجنس
    if (RegExp(r'ولد|ولدي|ابني').hasMatch(normalized)) gender = 'ذكر';
    if (RegExp(r'بنت|بنتي|ابنتي').hasMatch(normalized)) gender = 'أنثى';

    // استخراج الاسم
    final nameMatch = RegExp(r'(?:اسمه|اسمها|سميته|سميتها)\s+(\w+)').firstMatch(normalized);
    if (nameMatch != null) name = nameMatch.group(1);

    // استخراج الأعراض
    final symptomMap = {
      'حراره': 'حرارة', 'سخونه': 'حرارة', 'حمى': 'حرارة',
      'اسهال': 'إسهال', 'قىء': 'قيء', 'تشنج': 'تشنجات',
      'تورم': 'تورم', 'انتفاخ': 'تورم', 'احمرار': 'احمرار',
      'سعال': 'سعال', 'بكاء': 'بكاء مستمر',
    };
    for (final e in symptomMap.entries) {
      if (normalized.contains(e.key) && !mentionedSymptoms.contains(e.value)) {
        mentionedSymptoms.add(e.value);
      }
    }

    // استخراج الأمراض المزمنة
    if (RegExp(r'sugar|سكري|انسولين').hasMatch(normalized)) {
      hasChronicDisease = true; chronicDiseaseType = 'سكري';
    }
    if (RegExp(r'قلب|cardiac').hasMatch(normalized)) {
      hasChronicDisease = true; chronicDiseaseType = 'قلب';
    }
    if (RegExp(r'hiv|ايدز').hasMatch(normalized)) {
      hasChronicDisease = true; chronicDiseaseType = 'HIV';
    }

    // استخراج الخداجة
    if (RegExp(r'مبتسر|خديج|مبكر|premature').hasMatch(normalized)) {
      isPremature = true;
    }

    // استخراج اللقاحات المعطاة
    final vaccineMap = {'bcg': 'bcg', 'بي سي جي': 'bcg', 'شلل': 'opv', 'خماسي': 'penta', 'رئوي': 'pcv', 'روتا': 'rota', 'حصبه': 'mr'};
    for (final e in vaccineMap.entries) {
      if (normalized.contains(e.key) && RegExp(r'اخذ|عطوه|خذ|طعموه|سوى').hasMatch(normalized)) {
        if (!givenVaccines.contains(e.value)) givenVaccines.add(e.value);
      }
    }
  }

  Map<String, dynamic> toJson() => {
    'name': name, 'ageMonths': ageMonths, 'ageWeeks': ageWeeks,
    'gender': gender, 'isPremature': isPremature,
    'hasChronicDisease': hasChronicDisease, 'chronicDiseaseType': chronicDiseaseType,
    'givenVaccines': givenVaccines, 'mentionedSymptoms': mentionedSymptoms,
    'allergies': allergies,
  };
}

/// ذاكرة المحادثة العميقة — تحفظ وتحلل تفاصيل المحادثة
class ConversationMemory {
  // ──── ملف الطفل ────
  final ChildMemoryProfile child = ChildMemoryProfile();

  // ───ـ تاريخ المحادثة (آخر ٣٠ دورة) ────
  final List<MemoryTurn> _history = [];
  List<MemoryTurn> get history => List.unmodifiable(_history);

  // ──── الحالة العاطفية ────
  EmotionalState _emotionalState = EmotionalState.neutral;
  EmotionalState get emotionalState => _emotionalState;
  final List<EmotionalState> _emotionalHistory = [];

  // ──── المواضيع المناقشة ────
  final List<DiscussedTopic> _discussedTopics = [];

  // ──── نية المحادثة الحالية ────
  String _currentIntent = '';
  String _lastTopic = '';
  String _lastVaccine = '';
  String _lastDisease = '';

  // ──── عداد ────
  int _turnCount = 0;
  int get turnCount => _turnCount;

  // ══════════════════════════════════════════════════════════════
  //  تسجيل دورة محادثة
  // ══════════════════════════════════════════════════════════════

  void recordTurn({
    required String userMessage,
    required String botResponse,
    required String intent,
    required SentimentType sentiment,
    String topic = '',
  }) {
    final turn = MemoryTurn(
      userMessage: userMessage,
      botResponse: botResponse,
      intent: intent,
      sentiment: sentiment,
      timestamp: DateTime.now(),
      topic: topic,
    );

    _history.add(turn);
    _turnCount++;

    // الاحتفاظ بآخر ٣٠ دورة فقط
    while (_history.length > 30) {
      _history.removeAt(0);
    }

    // تحديث الحالة العاطفية
    _updateEmotionalState(sentiment);
    _emotionalHistory.add(_emotionalState);
    if (_emotionalHistory.length > 30) _emotionalHistory.removeAt(0);

    // تحديث المواضيع المناقشة
    if (topic.isNotEmpty) {
      _recordTopic(topic, intent);
    }

    // تحديث النية والموضوع الحالي
    _currentIntent = intent;
    if (topic.isNotEmpty) _lastTopic = topic;
  }

  // ══════════════════════════════════════════════════════════════
  //  تحديث الحالة العاطفية
  // ══════════════════════════════════════════════════════════════

  void _updateEmotionalState(SentimentType sentiment) {
    switch (sentiment) {
      case SentimentType.worry:
      case SentimentType.sadness:
        _emotionalState = EmotionalState.worried;
        break;
      case SentimentType.confusion:
        _emotionalState = EmotionalState.confused;
        break;
      case SentimentType.frustration:
      case SentimentType.urgency:
        _emotionalState = EmotionalState.angry;
        break;
      case SentimentType.gratitude:
      case SentimentType.relief:
        _emotionalState = EmotionalState.confident;
        break;
      case SentimentType.neutral:
        // لا تتغير الحالة العاطفية من محايد
        break;
    }
  }

  // ══════════════════════════════════════════════════════════════
  //  تسجيل موضوع مناقش
  // ══════════════════════════════════════════════════════════════

  void _recordTopic(String topic, String intent) {
    final existing = _discussedTopics.where((t) => t.topic == topic);
    if (existing.isNotEmpty) {
      existing.first.mentionCount++;
    } else {
      _discussedTopics.add(DiscussedTopic(
        topic: topic,
        timestamp: DateTime.now(),
        intent: intent,
      ));
    }
  }

  // ══════════════════════════════════════════════════════════════
  //  استخراج الكيانات من رسالة المستخدم
  // ══════════════════════════════════════════════════════════════

  void extractEntities(String normalized) {
    child.updateFromNormalized(normalized);

    // تحديث اللقاح المذكور آخر مرة
    final vaccineMap = {
      'bcg': 'bcg', 'بي سي جي': 'bcg', 'سل': 'bcg',
      'شلل': 'opv', 'opv': 'opv', 'ipv': 'ipv',
      'خماسي': 'penta', 'pentavalent': 'penta',
      'رئوي': 'pcv', 'pcv': 'pcv', 'مكورات رئويه': 'pcv',
      'روتا': 'rota', 'rotavirus': 'rota',
      'حصبه': 'mr', 'mr': 'mr', 'mmr': 'mr',
    };
    for (final e in vaccineMap.entries) {
      if (normalized.contains(e.key)) _lastVaccine = e.value;
    }

    // تحديث المرض المذكور آخر مرة
    final diseaseMap = {
      'سل': 'السل', 'شلل': 'شلل الأطفال', 'حصبه': 'الحصبة',
      'خناق': 'الخناق', 'كزاز': 'الكزاز', 'سعال ديكي': 'السعال الديكي',
      'كبد': 'التهاب الكبد ب', 'رئوي': 'المكورات الرئوية',
      'روتا': 'الروتا فيروس', 'سحايا': 'التهاب السحايا',
    };
    for (final e in diseaseMap.entries) {
      if (normalized.contains(e.key)) _lastDisease = e.value;
    }
  }

  // ══════════════════════════════════════════════════════════════
  //  بناء ملخص السياق للاستجابة
  // ══════════════════════════════════════════════════════════════

  String buildContextSummary() {
    final buf = StringBuffer();

    if (child.hasBasicInfo) buf.writeln('عمر الطفل: ${child.ageDisplay}');
    if (child.gender != null) buf.writeln('الجنس: ${child.gender}');
    if (child.name != null) buf.writeln('الاسم: ${child.name}');
    if (child.isPremature) buf.writeln('مبتسر: نعم');
    if (child.hasChronicDisease) buf.writeln('مرض مزمن: ${child.chronicDiseaseType}');
    if (child.mentionedSymptoms.isNotEmpty) buf.writeln('الأعراض: ${child.mentionedSymptoms.join('، ')}');
    if (child.givenVaccines.isNotEmpty) buf.writeln('تطعيمات أخذها: ${child.givenVaccines.join('، ')}');
    if (_lastVaccine.isNotEmpty) buf.writeln('آخر لقاح ذُكر: $_lastVaccine');
    if (_lastDisease.isNotEmpty) buf.writeln('آخر مرض ذُكر: $_lastDisease');

    return buf.toString().trim();
  }

  // ══════════════════════════════════════════════════════════════
  //  كشف أنماط المحادثة
  // ══════════════════════════════════════════════════════════════

  /// هل المستخدم يسأل أسئلة متتابعة عن نفس الموضوع؟
  bool isAskingFollowUpQuestions() {
    if (_history.length < 2) return false;
    final lastTwo = _history.sublist(_history.length - 2);
    return lastTwo[0].topic == lastTwo[1].topic && lastTwo[1].topic.isNotEmpty;
  }

  /// كم مرة ناقش المستخدم نفس الموضوع؟
  int getTopicMentionCount(String topic) {
    final found = _discussedTopics.where((t) => t.topic == topic);
    return found.isNotEmpty ? found.first.mentionCount : 0;
  }

  /// هل المستخدم عالق في حلقة أسئلة؟ (أكثر من ٣ أسئلة عن نفس الموضوع)
  bool isInQuestionLoop() {
    if (_discussedTopics.isEmpty) return false;
    final maxMentions = _discussedTopics.map((t) => t.mentionCount).reduce(max);
    return maxMentions >= 4;
  }

  /// المواضيع التي نوقشت مؤخراً (آخر ٥)
  List<String> getRecentTopics({int count = 5}) {
    final recent = _history.reversed
        .where((t) => t.topic.isNotEmpty)
        .map((t) => t.topic)
        .toSet()
        .take(count)
        .toList();
    return recent;
  }

  /// المواضيع التي لم تُناقش بعد (فجوات معرفية)
  List<String> getUnDiscussedTopics() {
    const importantTopics = [
      'الآثار الجانبية', 'الجدول الكامل', 'موانع التطعيم',
      'فيتامين أ', 'الرضاعة الطبيعية', 'سلسلة التبريد',
      'المناعة المجتمعية', 'الأساطير الشائعة',
    ];
    final discussed = _discussedTopics.map((t) => t.topic).toSet();
    return importantTopics.where((t) => !discussed.contains(t)).toList();
  }

  /// اتجاه المشاعر عبر المحادثة
  EmotionalTrend getEmotionalTrend() {
    if (_emotionalHistory.length < 2) return EmotionalTrend.stable;

    final recent = _emotionalHistory.sublist(_emotionalHistory.length - 3);
    final worriedCount = recent.where((e) => e == EmotionalState.worried).length;
    final confidentCount = recent.where((e) => e == EmotionalState.confident).length;

    if (worriedCount >= 2) return EmotionalTrend.deteriorating;
    if (confidentCount >= 2) return EmotionalTrend.improving;
    return EmotionalTrend.stable;
  }

  // ══════════════════════════════════════════════════════════════
  //  Getters
  // ══════════════════════════════════════════════════════════════

  String get lastTopic => _lastTopic;
  set lastTopic(String v) => _lastTopic = v;
  String get lastVaccine => _lastVaccine;
  set lastVaccine(String v) => _lastVaccine = v;
  String get lastDisease => _lastDisease;
  set lastDisease(String v) => _lastDisease = v;
  String get currentIntent => _currentIntent;
  List<DiscussedTopic> get discussedTopics => List.unmodifiable(_discussedTopics);

  /// هل المستخدم جديد؟
  bool get isNewUser => _turnCount <= 2;

  /// هل المستخدم قلق؟
  bool get isUserWorried => _emotionalState == EmotionalState.worried;

  /// هل المستخدم محتار؟
  bool get isUserConfused => _emotionalState == EmotionalState.confused;

  // ══════════════════════════════════════════════════════════════
  //  إعادة تعيين
  // ══════════════════════════════════════════════════════════════

  void reset() {
    _history.clear();
    _emotionalHistory.clear();
    _discussedTopics.clear();
    _emotionalState = EmotionalState.neutral;
    _currentIntent = '';
    _lastTopic = '';
    _lastVaccine = '';
    _lastDisease = '';
    _turnCount = 0;
  }
}

/// اتجاه المشاعر
enum EmotionalTrend {
  improving,    // تتحسن
  deteriorating, // تزداد سلبية
  stable,       // مستقرة
}


// ╔═════════════════════════════════════════════════════════════════════════╗
// ║  القسم ٤: المولد الذكي للردود (SmartResponseGenerator)                ║
// ╚═════════════════════════════════════════════════════════════════════════╝

/// نوع الدعم العاطفي المطلوب
enum EmotionalSupportType {
  reassurance,   // طمأنة
  guidance,      // توجيه
  validation,    // تأكيد مشاعر
  encouragement, // تشجيع
}

/// مولد الردود الذكية — يجمع المعلومات ويضيف السياق الشخصي والاقتراحات
class SmartResponseGenerator {
  final ConversationMemory memory;

  SmartResponseGenerator(this.memory);

  // ──── رسائل الدعم العاطفي ────
  static const Map<EmotionalSupportType, List<String>> _emotionalSupportMessages = {
    EmotionalSupportType.reassurance: [
      'طمأنه: لا تقلق، هذا أمر طبيعي ومنتظر بعد التطعيم 💚',
      'طمأنه: أغلب الآثار الجانبية بسيطة وتزول خلال يوم أو يومين ✅',
      'طمأنه: التطعيم آمن ومجرب على ملايين الأطفال حول العالم 🌍',
      'طمأنه: أنت تسوي الشي الصح لطفلك — كمل التطعيمات 💪',
    ],
    EmotionalSupportType.guidance: [
      'توجيه: الخطوة الأولى — اذهب لأقرب مركز صحي 🏥',
      'توجيه: دوّن الأعراض ومدتها — هذا يساعد الطبيب 📝',
      'توجيه: لا تعطي الطفل أي دوش بدون استشارة الطبيب ⚠️',
    ],
    EmotionalSupportType.validation: [
      'تأكيد: من حقك تقلق على طفلك — هذا دليل حبك له ❤️',
      'تأكيد: كثير من الأهالي يسألون نفس السؤال — أنت مو لوحدك 🤝',
      'تأكيد: سؤالك مهم ويدل على متابعتك الحريصة 👍',
    ],
    EmotionalSupportType.encouragement: [
      'تشجيع: ما شاء الله عليك — متابعة ممتازة! 🌟',
      'تشجيع: طفلك محظوظ بأب/أم متابع مثلك! 🏆',
      'تشجيع: استمر في متابعة التطعيمات — هذا أحلى هدية لطفلك 🎁',
    ],
  };

  // ──── رسائل التوجيه خطوة بخطوة ────
  static const Map<String, List<String>> _stepByStepGuides = {
    'ماذا_تفعل_بعد_الآثار_الجانبية': [
      'الخطوة ١: لا تقلق — أغلب الآثار طبيعية ✅',
      'الخطوة ٢: ضع كمادة باردة على مكان الحقن 🧊',
      'الخطوة ٣: إذا ارتفعت الحرارة — أعطِ خافض حرارة مناسب 💊',
      'الخطوة ٤: أكثر من الرضاعة والسوائل 💧',
      'الخطوة ٥: راقب الطفل ٤٨ ساعة 👀',
      'الخطوة ٦: إذا استمرت الأعراض أكثر من ٣ أيام — راجع الطبيب 🏥',
    ],
    'ماذا_تفعل_قبل_التطعيم': [
      'الخطوة ١: تأكد من موعد التطعيم 📅',
      'الخطوة ٢: أحضر بطاقة التطعيمات 📋',
      'الخطوة ٣: البس الطفل ملابس فاتحة وسهلة اللف 🧸',
      'الخطوة ٤: لا تأتِ والمعدة فارغة — أرضع الطفل قبل 💧',
      'الخطوة ٥: أخبر الممرضة إذا كان الطفل مريض أو عنده حساسية 💬',
      'الخطوة ٦: انتظر ١٥-٣٠ دقيقة بعد التطعيم في المركز ⏰',
    ],
    'ماذا_تفعل_عند_تأخر_التطعيم': [
      'الخطوة ١: لا تقلق — التطعيم المتأخر أفضل من عدمه ✅',
      'الخطوة ٢: لا تحتاج تبدأ الجدول من جديد 🔄',
      'الخطوة ٣: استأنف من حيث توقفت 📋',
      'الخطوة ٤: اذهب لأقرب مركز صحي في أقرب فرصة 🏥',
      'الخطوة ٥: أخبر الممرضة بالتطعيمات اللي أخذها الطفل 💬',
    ],
  };

  /// توليد رد ذكي يجمع بين المعلومات والسياق الشخصي
  String generateResponse({
    required String baseContent,
    required String intent,
    String? topic,
  }) {
    final buf = StringBuffer();

    // ═══ إضافة الدعم العاطفي إذا لزم ═══
    if (memory.isUserWorried) {
      final supportMsg = _getEmotionalSupport(EmotionalSupportType.reassurance);
      buf.writeln('$supportMsg\n');
    } else if (memory.isUserConfused) {
      final supportMsg = _getEmotionalSupport(EmotionalSupportType.validation);
      buf.writeln('$supportMsg\n');
    }

    // ═══ المحتوى الأساسي ═══
    buf.writeln(baseContent);

    // ═══ إضافة سياق شخصي ═══
    final personalContext = _buildPersonalContext(intent);
    if (personalContext.isNotEmpty) {
      buf.writeln('\n$personalContext');
    }

    // ═══ إضافة اقتراحات استباقية ═══
    final suggestions = _buildProactiveSuggestions(intent);
    if (suggestions.isNotEmpty) {
      buf.writeln('\n💡 $suggestions');
    }

    return buf.toString();
  }

  /// توليد رد متعدد المواضيع (للأسئلة المركبة)
  String generateMultiTopicResponse(Map<String, String> topicContents) {
    final buf = StringBuffer();

    int i = 0;
    for (final entry in topicContents.entries) {
      if (i > 0) buf.writeln('\n━━━━━━━━━━━━━━━━━━━━\n');
      buf.writeln(entry.value);
      i++;
    }

    return buf.toString();
  }

  /// توليد توجيه خطوة بخطوة
  String generateStepByStepGuide(String guideKey) {
    final steps = _stepByStepGuides[guideKey];
    if (steps == null) return 'عذراً، لا تتوفر تعليمات خطوة بخطوة لهذا الموضوع حالياً';

    final buf = StringBuffer('📋 إرشادات خطوة بخطوة:\n\n');
    for (final step in steps) {
      buf.writeln('  $step');
    }
    return buf.toString();
  }

  /// الحصول على رسالة دعم عاطفي
  String _getEmotionalSupport(EmotionalSupportType type) {
    final messages = _emotionalSupportMessages[type]!;
    return messages[DateTime.now().millisecond % messages.length];
  }

  /// بناء سياق شخصي حسب ملف الطفل
  String _buildPersonalContext(String intent) {
    final buf = StringBuffer();
    final child = memory.child;

    switch (intent) {
      case 'age_query':
      case 'vaccine_list':
      case 'schedule_query':
        if (child.isPremature) {
          buf.writeln('👶 ملاحظة: طفلك مبتسر — التطعيمات تُعطى حسب العمر الزمني وليس عمر الحمل');
        }
        if (child.hasChronicDisease) {
          buf.writeln('⚠️ ملاحظة: عندك طفل بمرض مزمن (${child.chronicDiseaseType}) — استشيري الطبيب قبل التطعيم');
        }
        break;

      case 'side_effects':
      case 'emergency':
        if (child.mentionedSymptoms.isNotEmpty) {
          buf.writeln('📋 الأعراض المذكورة سابقاً: ${child.mentionedSymptoms.join('، ')}');
        }
        break;

      case 'special_cases':
        if (child.isPremature) {
          buf.writeln('👶 طفلك مبتسر — هذا مهم في تحديد التطعيمات المناسبة');
        }
        break;
    }

    return buf.toString().trim();
  }

  /// بناء اقتراحات استباقية
  String _buildProactiveSuggestions(String intent) {
    final suggestions = <String>[];
    final child = memory.child;

    switch (intent) {
      case 'age_query':
      case 'vaccine_list':
        suggestions.add('تقدر تسأل عن الآثار الجانبية لأي تطعيم');
        if (child.hasBasicInfo && child.ageMonths! >= 8 && child.ageMonths! <= 10) {
          suggestions.add('تطعيم الحصبة (MR) قرب! لا تفوته في عمر ٩ أشهر');
        }
        break;

      case 'side_effects':
        suggestions.add('لو الأعراض شديدة — روح الطبيب فوراً');
        suggestions.add('انتظر ١٥-٣٠ دقيقة بعد التطعيم في المركز');
        break;

      case 'myths':
        suggestions.add('التطعيمات آمنة ومجربة على ملايين الأطفال');
        break;
    }

    return suggestions.join(' | ');
  }

  /// كشف نوع الدعم العاطفي المطلوب
  EmotionalSupportType detectNeededSupport(SentimentType sentiment) {
    switch (sentiment) {
      case SentimentType.worry:
      case SentimentType.sadness:
        return EmotionalSupportType.reassurance;
      case SentimentType.confusion:
        return EmotionalSupportType.guidance;
      case SentimentType.frustration:
        return EmotionalSupportType.validation;
      case SentimentType.urgency:
        return EmotionalSupportType.guidance;
      case SentimentType.gratitude:
        return EmotionalSupportType.encouragement;
      case SentimentType.relief:
        return EmotionalSupportType.encouragement;
      case SentimentType.neutral:
        return EmotionalSupportType.encouragement;
    }
  }
}


// ╔═════════════════════════════════════════════════════════════════════════╗
// ║  القسم ٥: المستشار الاستباقي (ProactiveAdvisor)                       ║
// ╚═════════════════════════════════════════════════════════════════════════╝

/// جدول التطعيمات المبسط للاستشارات الاستباقية
class _VaccineSchedule {
  final int ageMonths;
  final int ageWeeks;
  final List<String> vaccines;

  const _VaccineSchedule({
    required this.ageMonths,
    required this.ageWeeks,
    required this.vaccines,
  });
}

/// المستشار الاستباقي — يقدم نصائح استباقية حسب عمر الطفل والموسم
class ProactiveAdvisor {
  final ConversationMemory memory;

  ProactiveAdvisor(this.memory);

  // ──── جدول التطعيمات المبسط ────
  static const List<_VaccineSchedule> _schedule = [
    _VaccineSchedule(ageMonths: 0, ageWeeks: 0, vaccines: ['بي سي جي (BCG)', 'التهاب الكبد ب - جرعة الولادة', 'شلل الأطفال الفموي - OPV0']),
    _VaccineSchedule(ageMonths: 0, ageWeeks: 6, vaccines: ['شلل الأطفال - OPV1', 'الخماسي 1', 'الرئوي 1', 'الروتا 1']),
    _VaccineSchedule(ageMonths: 0, ageWeeks: 10, vaccines: ['شلل الأطفال - OPV2', 'الخماسي 2', 'الرئوي 2', 'الروتا 2']),
    _VaccineSchedule(ageMonths: 0, ageWeeks: 14, vaccines: ['شلل الأطفال - OPV3', 'الخماسي 3', 'الرئوي 3', 'شلل الأطفال الحقني - IPV']),
    _VaccineSchedule(ageMonths: 9, ageWeeks: 0, vaccines: ['الحصبة والحصبة الألمانية - MR1', 'شلل الأطفال - OPV4']),
    _VaccineSchedule(ageMonths: 12, ageWeeks: 0, vaccines: ['فيتامين أ (٢٠٠,٠٠٠ وحدة دولية)']),
    _VaccineSchedule(ageMonths: 18, ageWeeks: 0, vaccines: ['الحصبة - MR2', 'Penta4 (خماسي تعزيزية)', 'شلل الأطفال - OPV5', 'فيتامين أ']),
    _VaccineSchedule(ageMonths: 72, ageWeeks: 0, vaccines: ['DTP جرعة المدرسة', 'MR جرعة المدرسة', 'فيتامين أ']),
    _VaccineSchedule(ageMonths: 144, ageWeeks: 0, vaccines: ['Td للبنات']),
  ];

  // ──── المواسم والأحداث الصحية ────
  static const List<_SeasonalAlert> _seasonalAlerts = [
    _SeasonalAlert(
      months: [3, 4, 5], // مارس - مايو
      title: 'موسم الحصبة',
      message: '⚠️ موسم الحصبة! تأكد من تطعيم طفلك بـ MR في عمر ٩ أشهر',
      relatedIntents: ['vaccine_list', 'schedule_query'],
    ),
    _SeasonalAlert(
      months: [6, 7, 8], // يونيو - أغسطس
      title: 'موسم حملات التطعيم الوطنية',
      message: '🚐 حملات التطعيم الوطنية! تابع أخبار الحملات في منطقتك',
      relatedIntents: ['campaigns'],
    ),
    _SeasonalAlert(
      months: [9, 10, 11], // سبتمبر - نوفمبر
      title: 'بداية العام الدراسي',
      message: '🏫 بداية المدرسة! تأكد من تطعيمات الدخول المدرسي',
      relatedIntents: ['school_immunization'],
    ),
    _SeasonalAlert(
      months: [1, 2], // يناير - فبراير
      title: 'موسم الإنفلونزا وأمراض الشتاء',
      message: '🤧 موسم أمراض الشتاء — حافظ على تطعيمات طفلك وتغذيته',
      relatedIntents: ['nutrition', 'child_sick'],
    ),
  ];

  /// الحصول على التطعيمات القادمة حسب عمر الطفل
  List<String> getUpcomingVaccinations() {
    final child = memory.child;
    if (!child.hasBasicInfo) return [];

    final ageMonths = child.ageMonths ?? 0;
    final ageWeeks = child.ageWeeks ?? 0;
    final results = <String>[];

    for (final sched in _schedule) {
      if (sched.ageMonths > ageMonths + 2 && sched.ageMonths <= ageMonths + 6) {
        results.addAll(sched.vaccines);
      } else if (sched.ageWeeks > ageWeeks + 4 && sched.ageWeeks <= ageWeeks + 12) {
        results.addAll(sched.vaccines);
      }
    }

    return results;
  }

  /// الحصول على التطعيمات المتأخرة
  List<String> getOverdueVaccinations() {
    final child = memory.child;
    if (!child.hasBasicInfo) return [];

    final ageMonths = child.ageMonths ?? 0;
    final ageWeeks = child.ageWeeks ?? 0;
    final results = <String>[];

    for (final sched in _schedule) {
      final isDue = sched.ageMonths > 0
          ? ageMonths >= sched.ageMonths
          : ageWeeks >= sched.ageWeeks;

      if (isDue) {
        for (final v in sched.vaccines) {
          // تحقق مما إذا لم يأخذ الطفل هذا اللقاح
          if (!child.givenVaccines.any((gv) => v.toLowerCase().contains(gv))) {
            results.add(v);
          }
        }
      }
    }

    return results;
  }

  /// الحصول على تنبيهات موسمية
  List<String> getSeasonalAlerts() {
    final currentMonth = DateTime.now().month;
    final alerts = <String>[];

    for (final alert in _seasonalAlerts) {
      if (alert.months.contains(currentMonth)) {
        alerts.add(alert.message);
      }
    }

    return alerts;
  }

  /// اقتراح مواضيع ذات صلة لم تُناقش بعد
  List<String> suggestRelatedTopics(String currentIntent) {
    final undiscussed = memory.getUnDiscussedTopics();
    final relatedMap = <String, List<String>>{
      'age_query': ['الآثار الجانبية', 'موانع التطعيم'],
      'vaccine_list': ['الجدول الكامل', 'الآثار الجانبية'],
      'side_effects': ['موانع التطعيم', 'الأساطير الشائعة'],
      'schedule_query': ['فيتامين أ', 'المناعة المجتمعية'],
      'myths': ['المناعة المجتمعية', 'سلسلة التبريد'],
      'special_cases': ['الرضاعة الطبيعية', 'فيتامين أ'],
    };

    final related = relatedMap[currentIntent] ?? [];
    return related.where((t) => undiscussed.contains(t)).toList();
  }

  /// كشف فجوات المعرفة لدى المستخدم
  List<String> detectKnowledgeGaps() {
    final gaps = <String>[];
    final discussed = memory.discussedTopics.map((t) => t.intent).toSet();

    // فجوات حرجة — مواضيع مهمة لم تُناقش
    const criticalGaps = {
      'side_effects': 'لا تعرف عن الآثار الجانبية بعد',
      'schedule_query': 'لم تستفسر عن جدول التطعيمات الكامل',
      'contraindications': 'لم تسأل عن موانع التطعيم',
      'myths': 'لم نتحدث عن الأساطير الشائعة',
    };

    for (final gap in criticalGaps.entries) {
      if (!discussed.contains(gap.key)) {
        gaps.add(gap.value);
      }
    }

    return gaps;
  }

  /// توليد رسالة استباقية شاملة
  String generateProactiveMessage() {
    final buf = StringBuffer();

    // ──── التطعيمات المتأخرة ────
    final overdue = getOverdueVaccinations();
    if (overdue.isNotEmpty) {
      buf.writeln('🚨 تنبيه: عندك تطعيمات متأخرة!');
      for (final v in overdue.take(3)) {
        buf.writeln('  ⚠️ $v');
      }
      if (overdue.length > 3) {
        buf.writeln('  ... و${overdue.length - 3} تطعيمات أخرى');
      }
      buf.writeln('🏥 روح المركز الصحي في أقرب فرصة!');
      buf.writeln();
    }

    // ──── التطعيمات القادمة ────
    final upcoming = getUpcomingVaccinations();
    if (upcoming.isNotEmpty) {
      buf.writeln('⏰ التطعيمات القادمة قريباً:');
      for (final v in upcoming.take(3)) {
        buf.writeln('  📋 $v');
      }
      buf.writeln();
    }

    // ──── التنبيهات الموسمية ────
    final seasonal = getSeasonalAlerts();
    for (final alert in seasonal) {
      buf.writeln(alert);
      buf.writeln();
    }

    // ──── فجوات المعرفة ────
    final gaps = detectKnowledgeGaps();
    if (gaps.isNotEmpty && memory.turnCount >= 3) {
      buf.writeln('📚 ممكن حاب تعرف:');
      for (final gap in gaps.take(2)) {
        buf.writeln('  • $gap');
      }
    }

    return buf.toString().trim();
  }
}

/// تنبيه موسمي
class _SeasonalAlert {
  final List<int> months;
  final String title;
  final String message;
  final List<String> relatedIntents;

  const _SeasonalAlert({
    required this.months,
    required this.title,
    required this.message,
    required this.relatedIntents,
  });
}


// ╔═════════════════════════════════════════════════════════════════════════╗
// ║  القسم ٦: واجهة محرك الذكاء الاصطناعي الموحدة (AIEngine)              ║
// ╚═════════════════════════════════════════════════════════════════════════╝

/// نتيجة معالجة المحرك الموحد
class AIEngineResult {
  final String response;
  final String detectedIntent;
  final double intentConfidence;
  final SentimentResult sentiment;
  final List<String> proactiveSuggestions;
  final String? stepByStepGuide;
  final bool needsEmotionalSupport;

  const AIEngineResult({
    required this.response,
    required this.detectedIntent,
    required this.intentConfidence,
    required this.sentiment,
    this.proactiveSuggestions = const [],
    this.stepByStepGuide,
    this.needsEmotionalSupport = false,
  });
}

/// المحرك الموحد — يجمع كل مكونات الذكاء الاصطناعي
class AIEngine {
  late final ConversationMemory memory;
  late final IntelligentIntentDetector intentDetector;
  late final SmartResponseGenerator responseGenerator;
  late final ProactiveAdvisor proactiveAdvisor;

  AIEngine() {
    memory = ConversationMemory();
    intentDetector = IntelligentIntentDetector();
    responseGenerator = SmartResponseGenerator(memory);
    proactiveAdvisor = ProactiveAdvisor(memory);
  }

  /// المعالجة الرئيسية — تدخل رسالة المستخدم وتُخرج نتيجة شاملة
  AIEngineResult process(String userMessage, String baseResponse) {
    // ═══ تحليل المشاعر ═══
    final sentiment = SentimentAnalyzer.analyze(userMessage);

    // ═══ كشف النية ═══
    final intentResult = IntelligentIntentDetector.detect(
      _normalize(userMessage),
      previousIntent: memory.currentIntent.isNotEmpty ? memory.currentIntent : null,
      lastTopic: memory.lastTopic.isNotEmpty ? memory.lastTopic : null,
      childAgeMonths: memory.child.ageMonths,
    );

    // ═══ استخراج الكيانات ═══
    memory.extractEntities(_normalize(userMessage));

    // ═══ تسجيل الدورة ═══
    memory.recordTurn(
      userMessage: userMessage,
      botResponse: baseResponse,
      intent: intentResult.intent,
      sentiment: sentiment.type,
      topic: memory.lastTopic,
    );

    // ═══ توليد الرد الذكي ═══
    final smartResponse = responseGenerator.generateResponse(
      baseContent: baseResponse,
      intent: intentResult.intent,
      topic: memory.lastTopic,
    );

    // ═══ الاقتراحات الاستباقية ═══
    final suggestions = proactiveAdvisor.suggestRelatedTopics(intentResult.intent);

    // ═══ الدعم العاطفي ═══
    final needsSupport = SentimentAnalyzer.needsEmotionalSupport(userMessage);

    // ═══ التوجيه خطوة بخطوة ═══
    String? stepGuide;
    if (intentResult.intent == 'side_effects' || intentResult.intent == 'emergency') {
      stepGuide = responseGenerator.generateStepByStepGuide('ماذا_تفعل_بعد_الآثار_الجانبية');
    } else if (intentResult.intent == 'schedule_query') {
      stepGuide = responseGenerator.generateStepByStepGuide('ماذا_تفعل_قبل_التطعيم');
    }

    return AIEngineResult(
      response: smartResponse,
      detectedIntent: intentResult.intent,
      intentConfidence: intentResult.confidence,
      sentiment: sentiment,
      proactiveSuggestions: suggestions,
      stepByStepGuide: stepGuide,
      needsEmotionalSupport: needsSupport,
    );
  }

  /// الحصول على رسالة استباقية
  String getProactiveMessage() {
    return proactiveAdvisor.generateProactiveMessage();
  }

  /// الحصول على ملخص السياق
  String getContextSummary() {
    return memory.buildContextSummary();
  }

  /// إعادة تعيين المحرك
  void reset() {
    memory.reset();
  }

  /// تطبيع النص
  static String _normalize(String text) {
    var t = text.trim();
    t = t.replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '');
    t = t.replaceAll('أ', 'ا').replaceAll('إ', 'ا').replaceAll('آ', 'ا');
    t = t.replaceAll('ة', 'ه').replaceAll('ى', 'ي').replaceAll('ؤ', 'و').replaceAll('ئ', 'ي');
    t = t.replaceAll('ء', '');
    t = t.replaceAll(RegExp(r'[؟?!,.\u061F;:؛]'), '');
    t = t.replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
    const ar = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const en = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    for (int i = 0; i < ar.length; i++) {
      t = t.replaceAll(ar[i], en[i]);
    }
    return t;
  }
}
