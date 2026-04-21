// ══════════════════════════════════════════════════════════════
//  محرك الفهم العميق — NLP عربي متقدم (v3) — ترقية شاملة
//  يدعم: 25+ نية، 200+ مرادف، بحث ضبابي متقدم، فهم السياق
// ══════════════════════════════════════════════════════════════

class SmartNLP {
  // ──── تطبيع شامل (v4 - يدعم أكثر اللهجات) ────
  static String normalize(String text) {
    var t = text.trim();
    // إزالة التشكيل
    t = t.replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '');
    // توحيد الحروف المتشابهة
    t = t.replaceAll('أ', 'ا').replaceAll('إ', 'ا').replaceAll('آ', 'ا');
    t = t.replaceAll('ة', 'ه').replaceAll('ى', 'ي').replaceAll('ؤ', 'و').replaceAll('ئ', 'ي');
    t = t.replaceAll('ء', '').replaceAll('ٱ', 'ا');
    // إزالة علامات الترقيم
    t = t.replaceAll(RegExp(r'[؟?!,.\u061F]'), '');
    // توحيد المسافات
    t = t.replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
    // تحويل الأرقام العربية
    const ar = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const en = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    for (int i = 0; i < ar.length; i++) {
      t = t.replaceAll(ar[i], en[i]);
    }
    return t;
  }

  static String softNormalize(String text) {
    var t = text.trim();
    t = t.replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '');
    t = t.replaceAll(RegExp(r'\s+'), ' ');
    return t;
  }

  // ──── كشف النفي ────
  static bool hasNegation(String text) {
    final negations = [
      'ما', 'مو', 'ماب', 'موب', 'لا', 'بدون', 'ما يبي', 'ما ابي',
      'ما ابغي', 'ما ابغى', 'ما يبغى', 'ما ودي', 'مو حاب', 'مو حابه',
      'ماني', 'مابي', 'موش', 'مش', 'ما اريد', 'ما ابي اعطيه',
      'ما اطعم', 'ما عطوه', 'ما خذ',
      'لا ابيده', 'مو حاب اعطيه', 'رفض اعطائه', 'ما بغا اعطيه',
    ];
    final n = normalize(text);
    for (final neg in negations) {
      if (n.contains(neg)) return true;
    }
    return false;
  }

  // ──── كشف التحية ────
  static bool isGreeting(String text) {
    final n = normalize(text);
    return RegExp(r'^(مرحب|سلام|هلا|صباح|مساء|السلام|يا هلا|هلا وغلا|شخبارك|اخبارك|كيفك|كيف الحال|ايش الاخبار|وش الاخبار|يسعد|෴|بوت|هلو|الو| alo|hi |hello|hey |اهلا|يا مساء|يا صباح|كيف حالك|شلونك|عامل كيفك|زينك|عساك|كيف الحالك|مساء الخير|صباح النور)').hasMatch(n);
  }

  // ──── كشف الشكر ────
  static bool isThanking(String text) {
    final n = normalize(text);
    return RegExp(r'شكرا|مشكور|يعطيك|الله يعطيك|تسلم|بارك|يعطيك العافيه|ثانكس|thanks|thx|يسلم|الله يجزيك')
        .hasMatch(n);
  }

  // ──── كشف المقارنة ────
  static bool hasComparison(String text) {
    return RegExp(r'افضل|احسن|اقوى|اوفر|اكثر|اقل|اكبر|اصغر|ولّا|او لا|او|ام |بين')
        .hasMatch(normalize(text));
  }

  // ──── خريطة الأرقام العربية المكتوبة ────
  static final Map<String, int> _arabicNumbers = {
    'صفر': 0, 'واحد': 1, 'واحده': 1, 'اثنين': 2, 'اثنان': 2, 'اثنتين': 2, 'ثنتين': 2, 'اتنين': 2,
    'ثلاث': 3, 'ثلاثه': 3, 'تلاته': 3, 'ثلاثة': 3,
    'اربع': 4, 'اربعه': 4, 'اربعة': 4, 'أربع': 4,
    'خمس': 5, 'خمسه': 5, 'خمسة': 5,
    'ست': 6, 'سته': 6, 'ستة': 6, 'ستت': 6,
    'سبع': 7, 'سبعه': 7, 'سبعة': 7,
    'ثماني': 8, 'ثمانيه': 8, 'ثمانية': 8, 'ثمانت': 8, 'ثمان': 8,
    'تسع': 9, 'تسعه': 9, 'تسعة': 9, 'تسعو': 9,
    'عشر': 10, 'عشره': 10, 'عشرة': 10,
    'حدعش': 11, 'احدعش': 11, 'احد عشر': 11, 'احدعشر': 11,
    'اتناشر': 12, 'اثنا عشر': 12, 'اثناشر': 12, 'اثنا عشر': 12,
    'ثلاثطعش': 13, 'ثلاثه عشر': 13, 'ثلاثة عشر': 13,
    'اربعتاشر': 14, 'اربعه عشر': 14, 'اربعة عشر': 14,
    'خمطعش': 15, 'خمسه عشر': 15, 'خمسة عشر': 15,
    'ستطعش': 16, 'سته عشر': 16,
    'عشرين': 20, 'عشرون': 20, 'عشرین': 20,
    'واحد وعشرين': 21, 'واحد و عشرين': 21,
    'ثلاثين': 30, 'ثلاثون': 30,
    'اربعين': 40, 'اربعون': 40,
    'خمسين': 50, 'خمسون': 50,
    'ستين': 60, 'ستون': 60,
    'سبعين': 70, 'سبعون': 70,
    'ثمانين': 80, 'ثمانون': 80,
    'تسعين': 90, 'تسعون': 90,
    'مئه': 100, 'مائه': 100, 'مية': 100,
  };

  static int? parseArabicNumber(String text) {
    final n = normalize(text).trim();
    if (_arabicNumbers.containsKey(n)) return _arabicNumbers[n];
    for (final entry in _arabicNumbers.entries) {
      if (n.contains(normalize(entry.key))) return entry.value;
    }
    return null;
  }

  // ──── استخراج العمر المتقدم ────
  static ({int weeks, int months, int days})? extractAge(String text) {
    final n = normalize(text);

    // أنماط "عمره شهر" بدون رقم = شهر واحد (Quick Reply buttons)
    if (n.contains('عمره شهر') && !RegExp(r'\d').hasMatch(n.split('شهر')[0])) return (weeks: 4, months: 1, days: 0);
    if (n.contains('عنده شهر') && !RegExp(r'\d').hasMatch(n.split('شهر')[0])) return (weeks: 4, months: 1, days: 0);
    if (n.contains('عمرها شهر') && !RegExp(r'\d').hasMatch(n.split('شهر')[0])) return (weeks: 4, months: 1, days: 0);
    if (n.contains('عمره شهرين')) return (weeks: 8, months: 2, days: 0);
    if (n.contains('عنده شهرين')) return (weeks: 8, months: 2, days: 0);

    // أنماط خاصة - صيغة المثنى والجمع
    if (n.contains('شهرين')) return (weeks: 0, months: 2, days: 0);
    if (n.contains('اسبوعين') || n.contains('اسبوعان')) return (weeks: 2, months: 0, days: 0);
    if (n.contains('يومين')) return (weeks: 0, months: 0, days: 2);
    if (n.contains('سنتين')) return (weeks: 0, months: 24, days: 0);
    if (n.contains('سنين')) return (weeks: 0, months: 36, days: 0);
    if (n.contains('شهر واحد') || n.contains('شهر 1')) return (weeks: 0, months: 1, days: 0);
    if (n.contains('اسبوع واحد')) return (weeks: 1, months: 0, days: 0);
    if (n.contains('يوم واحد')) return (weeks: 0, months: 0, days: 1);
    if (n.contains('سنه واحده') || n.contains('سنة واحدة')) return (weeks: 0, months: 12, days: 0);

    // أنماط "عمره X شهور" / "عنده X شهور"
    var directMonthPattern = RegExp(r'(?:عمره|عمرها|عندو|عنده|عندها|يبلغ|يكون عمره)\s*(\d+)\s*(شه|شهر|شهور|اشهر)');
    var dm = directMonthPattern.firstMatch(n);
    if (dm != null) {
      final v = int.tryParse(dm.group(1)!);
      if (v != null && v <= 72) return (weeks: 0, months: v, days: 0);
    }

    var directWeekPattern = RegExp(r'(?:عمره|عمرها|عندو|عنده|عندها)\s*(\d+)\s*(اسبوع|اسابيع)');
    var dw = directWeekPattern.firstMatch(n);
    if (dw != null) {
      final v = int.tryParse(dw.group(1)!);
      if (v != null && v <= 104) return (weeks: v, months: 0, days: 0);
    }

    // أنماط "عمره سنة" / "عمره سنه"
    if (RegExp(r'عمره?\s*سنه|عمره?\s*سنة').hasMatch(n) && !n.contains('سنتين')) {
      return (weeks: 0, months: 12, days: 0);
    }
    // "عمره سنتين" handled above
    if (RegExp(r'عمره?\s*(\d+)\s*سن').hasMatch(n)) {
      final m = RegExp(r'عمره?\s*(\d+)\s*سن').firstMatch(n);
      if (m != null) {
        final v = int.tryParse(m.group(1)!);
        if (v != null && v <= 18) return (weeks: 0, months: v * 12, days: 0);
      }
    }

    // أرقام مكتوبة عربي
    final writtenMonthPattern = RegExp(r'(\S+)\s*(شهر|شهور|اشهر)');
    final wm = writtenMonthPattern.firstMatch(n);
    if (wm != null) {
      final num = parseArabicNumber(wm.group(1)!);
      if (num != null) return (weeks: 0, months: num, days: 0);
    }
    final writtenWeekPattern = RegExp(r'(\S+)\s*(اسبوع|اسابيع)');
    final ww = writtenWeekPattern.firstMatch(n);
    if (ww != null) {
      final num = parseArabicNumber(ww.group(1)!);
      if (num != null) return (weeks: num, months: 0, days: 0);
    }
    final writtenDayPattern = RegExp(r'(\S+)\s*(يوم|ايام)');
    final wd = writtenDayPattern.firstMatch(n);
    if (wd != null) {
      final num = parseArabicNumber(wd.group(1)!);
      if (num != null) return (weeks: 0, months: 0, days: num);
    }

    // أرقام إنجليزية
    var m = RegExp(r'(\d+)\s*(شهر|شهور|اشهر)').firstMatch(n);
    if (m != null) return (weeks: 0, months: int.parse(m.group(1)!), days: 0);
    var w = RegExp(r'(\d+)\s*(اسبوع|اسابيع)').firstMatch(n);
    if (w != null) return (weeks: int.parse(w.group(1)!), months: 0, days: 0);
    var d = RegExp(r'(\d+)\s*(يوم|ايام)').firstMatch(n);
    if (d != null) return (weeks: 0, months: 0, days: int.parse(d.group(1)!));

    // أنماط "عمره X" / "عندو X" / "عندها X"
    var a = RegExp(r'عمره?\s*(\d+)').firstMatch(n);
    if (a != null) {
      final v = int.tryParse(a.group(1)!);
      if (v != null && v <= 72) return (weeks: 0, months: v, days: 0);
    }
    var aw = RegExp(r'عمره?\s*(\S+)').firstMatch(n);
    if (aw != null) {
      final num = parseArabicNumber(aw.group(1)!);
      if (num != null && num <= 72) return (weeks: 0, months: num, days: 0);
    }
    var h = RegExp(r'عنده[ا]?\s*(\d+)').firstMatch(n);
    if (h != null) {
      final v = int.tryParse(h.group(1)!);
      if (v != null && v <= 72) return (weeks: 0, months: v, days: 0);
    }
    var hd = RegExp(r'عندو\s*(\d+)').firstMatch(n);
    if (hd != null) {
      final v = int.tryParse(hd.group(1)!);
      if (v != null && v <= 72) return (weeks: 0, months: v, days: 0);
    }
    var hw = RegExp(r'عندو\s*(\S+)').firstMatch(n);
    if (hw != null) {
      final num = parseArabicNumber(hw.group(1)!);
      if (num != null && num <= 72) return (weeks: 0, months: num, days: 0);
    }

    // أنماط "عمره 4" / "عمره 10" / "عنده 3 شهور" مباشرة
    var shortAge = RegExp(r'(?:عنده|عندو|عندها)\s*(\d+)\s*$').firstMatch(n);
    if (shortAge != null) {
      final v = int.tryParse(shortAge.group(1)!);
      if (v != null && v >= 1 && v <= 60) return (weeks: 0, months: v, days: 0);
    }

    if (n.contains('سنه') && !n.contains('سنتين') && !n.contains('سنين')) {
      return (weeks: 0, months: 12, days: 0);
    }
    if (n.contains('حديث الولاده') || n.contains('مولود جديد') || n.contains('مولوده') || n.contains('توه مولود')) {
      return (weeks: 0, months: 0, days: 0);
    }
    return null;
  }

  static String normalizeNumbers(String t) {
    const ar = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const en = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    for (int i = 0; i < ar.length; i++) { t = t.replaceAll(ar[i], en[i]); }
    return t;
  }

  // ──── كلمات الإيقاف ────
  static final Set<String> _stopWords = {
    'هل', 'ما', 'ماذا', 'كيف', 'متى', 'اين', 'وين', 'كم', 'لماذا', 'ليه', 'ليش',
    'عند', 'في', 'من', 'الى', 'الي', 'على', 'عن', 'مع', 'او', 'ام', 'ثم', 'لكن',
    'بعد', 'قبل', 'بين', 'هذا', 'هذه', 'ذلك', 'انا', 'انت', 'هو', 'هي', 'نحن',
    'كان', 'يكون', 'اذا', 'لو', 'اريد', 'ابي', 'نبي', 'ودي',
    'طفلي', 'طفله', 'ولدي', 'بنتي', 'يعني', 'صح', 'طيب', 'تمام', 'زين', 'ايش', 'وش',
    'اللي', 'لدي', 'عندما', 'حاب', 'بدي', 'صار', 'يوم',
    // كلمات إيقاف إضافية (لهجات يمنية وخليجية)
    'انه', 'كلش', 'مو', 'عادي', 'الحين', 'الكود', 'شي',
    'شيء', 'حاجة', 'وشو', 'ايشو', 'ليش', 'كده', 'كذا',
    'ابي', 'ودي', 'ابغى', 'ياريت', 'بغيت', 'خلاص', 'انا', 'هو',
    'هي', 'هم', 'احنا', 'انتوا', 'هن', 'هلن', 'تقدر', 'تقدرين',
    'قول', 'قولي', 'قولين', 'اقول', 'قولوا', 'ابغى اعرف', 'ابي اعرف',
    'ابي اسأل', 'ابغى اسأل', 'ابي اعرف وش', 'اعطني', 'عطني',
    'هات', 'كل', 'جذي', 'ذي', 'هال', 'سالفه', 'قصة', 'عن', 'منو',
    'وينه', 'وشنو', 'شنو', 'كيفش', 'ليشش', 'اوف', 'يعني',
  };

  static List<String> extractKeywords(String normalized) {
    return normalized.split(' ').where((w) => w.length > 1 && !_stopWords.contains(w)).toList();
  }

  // ──── مرادفات عربية شاملة (300+ مرادف) ────
  static final Map<String, List<String>> _synonyms = {
    'حراره': ['سخونه', 'حمى', 'يرتفع', 'سخن', 'حمم', 'حرار', 'يسخن', 'سخنت', 'سخون', 'حرارته', 'سخونيته', 'يرتفع الحراره', 'طلعت حراره', 'حراره عاليه', 'طلع حراره'],
    'الم': ['يالم', 'يتالم', 'يتألم', 'وجع', 'يوجع', 'يعور', 'الام', 'مؤلم', 'الامه', 'يعوره', 'يوجعه'],
    'احمرار': ['احمر', 'يحمر', 'حمره', 'احمرت', 'حمر', 'محمر', 'احمرار المكان'],
    'تورم': ['انتفاخ', 'ينتفخ', 'ورم', 'يتورم', 'انتفخ', 'تنفخ', 'متورم', 'منتفخ', 'تنفخت', 'انتفخت', 'ورم المكان'],
    'تطعيم': ['لقاح', 'حقنه', 'تطعيمه', 'تطعيمات', 'لقاحات', 'حقن', 'تطعم', 'تطعيماته', 'ياخذ تطعيم', 'ياخذ حقنه', 'ياخذ لقاح', 'ياخذ التطعيم', 'زباره', 'زبارات',
              'تطعيماته', 'لقاحاته', 'حقناته', 'تطعيمه', 'لقاحه', 'زباره', 'زبارات',
              'التطعيمات', 'اللقاحات', 'الزبارات', 'برنامج التحصين', 'تحصين',
              'تحصينه', 'تحصينات', 'لقاح', 'تطعم', 'يطعم', 'يطعمه', 'زبر'],
    'طفل': ['رضيع', 'وليد', 'صغير', 'بيبي', 'ولد', 'بنت', 'عيل', 'الطفل', 'اطفال', 'ولدي', 'بنتي', 'ابني', 'طفله', 'طفلها', 'الطفله', 'اطفالي', 'عيالي'],
    'مريض': ['مريضه', 'تعبان', 'تعبانه', 'مريض', 'مصاب', 'تعب', 'مريضين', 'مريضات', 'مريضه', 'مريضه شوي', 'موعافيه', 'مريض شوي', 'مريضه كثير', 'مريض كثير'],
    'مجاني': ['مجانا', 'بلاش', 'بدون فلوس', 'ما يكلف', 'مجان', 'بلا رسوم', 'مجاناً', 'بلا قروش', 'ما ياخذون فلوس', 'بدون رسوم', 'بدون تكلفه'],
    'خطر': ['خطير', 'يخوف', 'مضر', 'ضار', 'مو امان', 'مو آمن', 'يخطّر', 'خطرر', 'مو امن'],
    'عمر': ['سن', 'عمر', 'كبر', 'صغير', 'عمره', 'عمرها', 'سنه', 'عمر الطفل', 'سنه'],
    'اثار': ['اعراض', 'جانبيه', 'تأثير', 'يصير', 'يسوي', 'يحصل', 'اضرار', 'مضره', 'يصير بعده', 'وش يسوي بعد', 'وش يصير بعد', 'وش يصير له', 'وش يجيه بعد'],
    'امان': ['امان', 'مو ضار', 'ما يضر', 'مو خطر', 'آمن', 'امنه', 'مو خطر', 'امنة', 'امن'],
    'مكان': ['وين', 'اين', 'مركز', 'مستشفى', 'عياده', 'محل', 'اماكن', 'وين اروح', 'اين اذهب', 'وين اوديه',
              'اقرب مركز', 'اقرب مكان', 'وين المركز', 'اين المركز'],
    'وقت': ['متى', 'وقت', 'ميعاد', 'موعد', 'تاريخ', 'متى ياخذ', 'متى اعطيه', 'متى اوديه', 'متى اطعمه'],
    'عدد': ['كم', 'عدد', 'كم مره', 'كم جرعه', 'كم حقه', 'كم عدد', 'كم حقنه', 'كم جرعات'],
    'مرض': ['مرض', 'امراض', 'عدوى', 'وباء', 'عدوه', 'عدوات', 'عدوى', 'مراضه', 'مراضين', 'امراضه', 'امراضين'],
    'منع': ['مانع', 'يمنع', 'ما يقدر', 'مو راضي', 'رفض', 'مانع', 'يمنعون', 'ما يخلونه', 'ما يقدر ياخذ'],
    'مناسب': ['مناسب', 'زين', 'كويس', 'تمام', 'اوكي', 'ok', 'صالح', 'حلو', 'good'],
    'طوارئ': ['طوارئ', 'عاجل', 'خطير', 'مستعجل', 'حاله طوارئ', 'emergency', 'اسعاف'],
    'تبريد': ['تبريد', 'براده', 'ثلاجه', 'تخزين', 'بارد', 'بروده', 'ثلاجات', 'سلسله بارده'],
    'حمله': ['حمله', 'حملات', 'تطعيم وطني', 'NIDs', 'ايام التحصين', 'يوم التحصين', 'حملة تطعيم', 'حملة تحصين'],
    'مدرسه': ['مدرسه', 'مدرسي', 'التحاق', 'دخول المدرسه', 'طلاب', 'المدرسه', 'مدرسته'],
    'حوامل': ['حامل', 'حوامل', 'ام', 'حامله', 'الام الحامل', 'امه حامل', 'ام حامل'],
    'اشراف': ['اشراف', 'supervision', 'زياره', 'متابعه', 'تقييم', 'رقابه', 'زياره اشرافيه'],
    'اداره': ['اداره', 'مدير', 'تخطيط', 'تنظيم', 'قياده', 'اداري', 'مديريه'],
    'فيتامين': ['فيتامين', 'vitamin', 'فيتامين ا', 'فيتامين a', 'فيتامين أ', 'كبسوله', 'كبسولات'],
    'الروتا': ['روتا', 'روتا فيروس', 'لقاح الروتا'],
    'الخماسي': ['خماسي', 'التطعيم الخماسي', 'pentavalent', 'penta', 'الخمسائي'],
    'الحصبه': ['حصبه', 'حصبة', 'لقاح الحصبه', 'تطعيم الحصبه', 'امر الحصبه'],
    'فيروسي': ['فيروس', 'فيروسي', 'مرض فيروسي', 'عدوى فيروسيه'],
    'بكتيري': ['بكتيريا', 'بكتيري', 'مرض بكتيري', 'عدوى بكتيريه'],
    'رئوي': ['رئوي', 'مكورات رئويه', 'التهاب رئه', 'pneumococcal', 'pcv'],
    'جدول': ['مواعيد', 'جدول كامل', 'كل المواعيد', 'الجدول', 'الجدول الكامل'],
    'رضاعه': ['رضاعه', 'يرضع', 'حليب', 'ثدي', 'الثدي', 'يرضعه', 'ترضعه', 'حليب ام', 'حليب الام'],
    'تشنج': ['تشنج', 'نوبه', 'صرع', 'يرتعش', 'يرتجف', 'تقلصات', 'رعشه', 'تشنّج', 'نوبات'],
    'بكاء': ['يبكي', 'بكى', 'بكاء', 'ما يسكت', 'صار يبكي', 'يبكي كثير', 'صار يصيح', 'يبكي بشكل مستمر'],
    'ﶁ': ['ﶁ', 'bcg', 'بي سي جي', 'سل'],
  };

  // ──── تشابه مع مرادفات (مُحسّن v3) ────
  static double calculateRelevance(String input, List<String> topicKeywords) {
    final inputKw = extractKeywords(input);
    if (inputKw.isEmpty || topicKeywords.isEmpty) return 0;

    int matches = 0;
    double bonusScore = 0;

    for (final kw in topicKeywords) {
      for (final iw in inputKw) {
        // تطابق مباشر
        if (iw == kw) { matches += 2; break; }
        if (iw.contains(kw) || kw.contains(iw)) { matches++; break; }

        // تطابق بالمرادفات
        final syns = _synonyms[kw] ?? [];
        if (syns.any((s) => iw.contains(s) || s.contains(iw))) { matches++; break; }

        // تطابق عكسي
        for (final entry in _synonyms.entries) {
          if (entry.key == iw && entry.value.any((s) => kw.contains(s) || s.contains(kw))) {
            matches++; break;
          }
        }
      }
    }

    // مكافأة للتطابق العالي
    final ratio = matches / (topicKeywords.length * 2);
    if (ratio > 0.7) bonusScore = 0.15;

    return (ratio + bonusScore).clamp(0.0, 1.0);
  }

  // ──── تشابه نصي متقدم (N-gram similarity) ────
  static double simpleSimilarity(String a, String b) {
    if (a == b) return 1.0;
    if (a.isEmpty || b.isEmpty) return 0.0;

    final longer = a.length > b.length ? a : b;
    final shorter = a.length > b.length ? b : a;
    if (longer.length == 0) return 1.0;
    if (longer.contains(shorter)) return shorter.length / longer.length;

    // Bigram similarity
    final bigramsA = <String>{};
    final bigramsB = <String>{};
    for (int i = 0; i < a.length - 1; i++) bigramsA.add(a.substring(i, i + 2));
    for (int i = 0; i < b.length - 1; i++) bigramsB.add(b.substring(i, i + 2));

    if (bigramsA.isEmpty || bigramsB.isEmpty) return 0;
    final intersection = bigramsA.intersection(bigramsB).length;
    final union = bigramsA.union(bigramsB).length;
    return union > 0 ? intersection / union : 0;
  }

  // ──── اكتشاف النية المتقدم (30+ نية) ────
  static String detectIntent(String normalized, {String? previousIntent, String? lastTopic}) {
    final n = normalized;

    // ── تحية ──
    if (isGreeting(n)) return 'greeting';

    // ── شكر ──
    if (isThanking(n)) return 'thanking';

    // ── أسئلة طوارئ (أولوية قصوى) ──
    if (RegExp(r'طوارئ|خطير|خطر|يسكر|يعور|ما يتنفس|يتلوى|يتشنج|فقد وعي|ما يرد|اختنق|ينزف|شاحب|يرتعش بشكل خطير|ما يقدر يتنفس')
        .hasMatch(n)) return 'emergency';
    if (RegExp(r'متى اروح|متى اخاف|متى اقلق|متى اوديه|متى اطلب|متى استشير|متى اخاف عليه')
        .hasMatch(n)) return 'emergency';

    // ── آثار جانبية (أولوية عالية) ──
    if (RegExp(r'اثار|جانبيه|اعراض|وش يصير|ايش يصير|وش يسوي|ايش يسوي|وش يصير بعد|ايش يصير بعد|وش يصير له')
        .hasMatch(n)) return 'side_effects';
    if (RegExp(r'حراره|سخون|حمى|يحر|يسخن|سخنت|سخونه').hasMatch(n) &&
        RegExp(r'تطعيم|لقاح|حقنه|بعد|ياخذ|عطوه').hasMatch(n)) return 'side_effects';
    if (RegExp(r'يبكي|بكاء|صار يبكي|ما يسكت|يبكي كثير|صار يصيح|صار يبكي كثير').hasMatch(n)) return 'side_effects';
    if (RegExp(r'تورم|انتفاخ|ورم|انتفخ|تورم المكان|متورم|منتفخ').hasMatch(n) &&
        RegExp(r'تطعيم|لقاح|حقنه|بعد|المكان|مكان').hasMatch(n)) return 'side_effects';
    if (RegExp(r'تشنج|نوبه|يرتعش|يرتجف|رعشه|تشنّج').hasMatch(n)) return 'side_effects';
    // آثار بحث عن تطعيم محدد
    if (RegExp(r'وش اثار|ايش اثار|وش الآثار|ايش الآثار|وش يصير بعد|ايش يصير بعد|وش يسوي بعد|وش يجيه بعد').hasMatch(n)) return 'side_effects';

    // ── أسئلة عمر ──
    if (RegExp(r'عمر|سن|شهر|اسبوع|يوم|كم باقي|باقي|عمره|عمرها|عنده|عندها|عندو').hasMatch(n)) {
      if (RegExp(r'طفل|طفله|ولد|بنت|رضيع|عمره|عمرها|عنده|عندها|ولدي|بنتي|ابني')
          .hasMatch(n)) return 'age_query';
      if (RegExp(r'تطعيم|لقاح|ياخذ|لازم').hasMatch(n)) return 'age_query';
      return 'schedule_query';
    }

    // ── تطعيمات ──
    if (RegExp(r'تطعيم|لقاح|ياخذ|لازم|مطلوب|وش ياخذ|ايش ياخذ|وش لازم|ايش لازم|وش التطعيم|ايش التطعيم|التطعيمات|اللقاحات|زباره|زبارات|حقنه|حقنات|وش لقاحاته')
        .hasMatch(n)) {
      if (previousIntent == 'age_query' || lastTopic?.contains('عمر') == true) return 'age_query';
      if (RegExp(r'عمر|شهر|اسبوع|عند|عنده|عندو|عمره').hasMatch(n)) return 'age_query';
      return 'vaccine_list';
    }

    // ── جدول ──
    if (RegExp(r'جدول|الجدول|متى يعطى|متى ياخذ|متى التطعيم|الزبارات|الزباره|كل التطعيمات|التطعيمات كامله')
        .hasMatch(n)) return 'schedule_query';

    // ── أسئلة عمر تفصيلية ──
    if (RegExp(r'جدول التحصين|جدول كامل|كل التطعيمات|الموعد الكامل|التطعيمات المطلوبه').hasMatch(n)) return 'schedule_query';

    // ── جرعات ──
    if (RegExp(r'كم جرعه|كم مره|عدد|جرعات|كم حقه|كم مره ياخذ|كم عدد|كم حقنه|كم جرعات')
        .hasMatch(n)) return 'dose_count';

    // ── تحديث / معلومات ──
    if (RegExp(r'حدث|تحديث|update|معلومات جديده|معلومات حديثه|المعلومات')
        .hasMatch(n)) return 'schedule_query';

    // ── موقع ──
    if (RegExp(r'وين|اين|مكان|مركز|مستشفى|عياده|وين اطعم|اين اطعم|وين اروح|وين يعطوا|فين|وين اوديه')
        .hasMatch(n)) return 'location';

    // ── تكلفة ──
    if (RegExp(r'مجاني|مجانا|سعر|تكلفه|رسوم|فلوس|ثمن|بكم|كم يكلف|بلاش|كم يكلفني|بفلوس|يكلف')
        .hasMatch(n)) return 'cost';

    // ── حملات ──
    if (RegExp(r'حمله|حملات|تطعيم وطني|NIDs|ايام التحصين|يوم التحصين')
        .hasMatch(n)) return 'campaigns';

    // ── أنواع ──
    if (RegExp(r'نوع|انواع|وش الفرق|ايش الفرق|كيف يشتغل|كيف يعمل|وش هو|ايش هو|وش معنى')
        .hasMatch(n)) return 'vaccine_types';

    // ── أساطير ──
    if (RegExp(r'اسطوره|خرافه|اكاذيب|مضره|يضر|يسبب|autism|اوتيزم|اوتيستك|يشل|عقم|خصوبه|يكبّر|بيضر|مضرة|مضرون|هل التطعيم ضار|هل اللقاح ضار')
        .hasMatch(n)) return 'myths';

    // ── حالات خاصة ──
    if (RegExp(r'مبتسر|خديج|مريض|مرضعه|حامل|سكر|قلب|سرطان|hiv|ايدز|ربو|صرع|تغذيه سيئه|نحيف')
        .hasMatch(n)) return 'special_cases';

    // ── أشراف وإدارة ──
    if (RegExp(r'اشراف|اشراف داعم|supervision|زياره اشرافيه|supportive|تقييم اداء|checklist|قائمه مراجعه|زياره ميدانيه')
        .hasMatch(n)) return 'supervision';
    if (RegExp(r'مستوى وسيط|مدير مكتب|مدير محافظه|تخطيط|اداره صحيه|HMIS|مؤشرات اداء|KPI|تقارير|اداره المكتب')
        .hasMatch(n)) return 'management';

    // ── تغذية ──
    if (RegExp(r'تغذيه|اكل|غذاء|ياكل|رضاعه|يرضع|حليب|فيتامين|vitamin|ياكل كويس')
        .hasMatch(n)) return 'nutrition';

    // ── سلسلة تبريد ──
    if (RegExp(r'تبريد|سلسله بارده|ثلاجه|تخزين|vvm|درجه حراره|تخزين اللقاح')
        .hasMatch(n)) return 'cold_chain';

    // ── متابعة ──
    if (RegExp(r'^(نعم|ايوه|ايه|اي|يب|ايه نعم|ايه اي|لا|كم|ليه|ليش|اشرح|وضح|بالتفصيل|تفاصيل|طيب|تمام|واضح|فهمت|اوكي|زين|اوك|ياب|اوك شكرا|كذا شكرا)')
        .hasMatch(n)) return 'follow_up';

    // ── سفر ──
    if (RegExp(r'سفر|مسافر|سياحه|مطار|سافر').hasMatch(n)) return 'travel';

    // ── تاريخ ──
    if (RegExp(r'تاريخ|متى بدأ|متى بدا|متى انشئ|متى ابتدي').hasMatch(n)) return 'history';

    // ── فوائد ──
    if (RegExp(r'فوائد|ليش نطعم|ليش مهم|فايده|ليش لازم|وش الفايده|ليه نطعم|ليه نطعمه').hasMatch(n)) return 'benefits';

    // ── تذكير ──
    if (RegExp(r'تذكير|ذكرني|ذكرني ب|موعد|reminder|تنبيه|نبهني').hasMatch(n)) return 'reminder';

    // ── تقييم / رأي ──
    if (RegExp(r'تقييم|رأيك|وش رايك|ايش رايك|good|ممتاز|سيء|كويس|حلو|زفت').hasMatch(n)) return 'feedback';

    // ── ليش ──
    if (n.startsWith('ليش') || n.startsWith('لماذا') || n.startsWith('ليه') || n.startsWith('ليهذا')) {
      if (previousIntent == 'myths' || previousIntent == 'benefits') return previousIntent!;
      if (n.contains('تطعيم') || n.contains('لقاح')) return 'benefits';
      return 'benefits';
    }

    // ── أمراض ──
    if (RegExp(r'مرض|امراض|عدوى|وباء').hasMatch(n)) return 'diseases';

    // ── مقارنة ──
    if (hasComparison(n)) return 'vaccine_types';

    // ── تشخيص حالة الطفل ──
    if (RegExp(r'مريض|تعبان|مريضه|ما ياكل|يرفض|ما يبي|مريض|مريضه|ما يرضع|مريض شوي|مريضه شوي')
        .hasMatch(n)) return 'child_sick';

    // ── سياق محادثة: إذا كان السؤال قصير وغامض ──
    if (previousIntent != null && previousIntent != 'general' && previousIntent != 'greeting' && previousIntent != 'thanking') {
      if (n.length < 20 && !_isNewTopic(n)) return previousIntent;
    }

    return 'general';
  }

  static bool _isNewTopic(String n) {
    return RegExp(r'طيب|بس|تمام|غير|اوكي|زين|اوك|بس كذا|تمام شكرا').hasMatch(n);
  }

  // ──── اكتشاف التطعيم ────
  static String? detectVaccineMention(String n) {
    final p = {
      'bcg': ['bcg', 'بي سي جي', 'سل', 'درن'],
      'opv': ['opv', 'شلل فموي', 'بوليو', 'قطرات شلل', 'شلل اطفال', 'opv'],
      'ipv': ['ipv', 'شلل حقن', 'شلل حقني'],
      'penta': ['خماسي', 'pentavalent', 'penta', 'dtp hep', 'التطعيم الخماسي'],
      'pcv': ['رئوي', 'pneumococcal', 'pcv', 'مكورات رئوي', 'التطعيم الرئوي'],
      'rota': ['روتا', 'rotavirus', 'روتا فيروس', 'اسهال روتا'],
      'mr': ['حصبه', 'measles', 'mr', 'mmr', 'حصبه المانيه', 'حصبه الماني'],
      'td': ['نسائي', 'حوامل', 'حامل', 'td', 'tt', 'كزاز الحوامل'],
      'td_girls': ['بنات', 'td للبنات', '12 سنه بنات', 'كزاز بنات', 'خناق بنات'],
      'vitA': ['فيتامين', 'vitamin', 'فيتامين a', 'فيتامين ا', 'كبسوله', 'كبسولة زرقاء', 'كبسولة حمراء'],
      'hepb0': ['كبد ب عند الولاده', 'كبد ب جرعه الولاده', 'hepb0', 'hep b0'],
      'pentavalent1': ['خماسي 1', 'الخماسي الاولى', 'pentavalent 1', 'الجرعه الاولى من الخماسي'],
      'pcv1': ['رئوي 1', 'الرئوي الاولى', 'pcv1'],
      'rv1': ['روتا 1', 'الروتا الاولى', 'rotavirus 1'],
      'mr1': ['حصبه 1', 'حصبه الاولى', 'mr 1', 'الجرعه الاولى من الحصبه'],
      'opv1': ['شلل 1', 'شلل اطفال 1', 'opv1'],
    };
    for (final e in p.entries) {
      for (final k in e.value) {
        if (n.contains(k)) return e.key;
      }
    }
    return null;
  }

  // ──── اكتشاف المرض ────
  static String? detectDiseaseMention(String n) {
    final p = {
      'measles': ['الحصبه', 'حصبه', 'مرض الحصبه'],
      'polio': ['شلل اطفال', 'شلل', 'بوليو'],
      'tetanus': ['كزاز', 'كزاز وليدي'],
      'diphtheria': ['خناق'],
      'pertussus': ['سعال ديبي', 'سعال', 'سعاله'],
      'hepatitis': ['كبد', 'التهاب كبد', 'كبد ب'],
      'pneumonia': ['رئوي', 'التهاب رئه', 'مكورات رئويه'],
      'rotavirus': ['روتا', 'اسهال', 'اسهال روتا'],
      'meningitis': ['اغشيه مخيه', 'سحايا', 'التهاب سحايا'],
      'rubella': ['المانيه', 'حصبه المانيه'],
      'tuberculosis': ['سل', 'درن'],
    };
    for (final e in p.entries) {
      for (final k in e.value) {
        if (n.contains(k)) return e.key;
      }
    }
    return null;
  }

  // ──── كشف شدة الأعراض ────
  static String detectSeverity(String n) {
    if (RegExp(r'كثير|شديد|قوي|مو طبيعي|يخوف|مستمر|ما يوقف|صار ساعه|خطير|قوي جدا|جدا|مره كثير')
        .hasMatch(n)) return 'شديد';
    if (RegExp(r'بسيط|خفيف|شوي|مو كثير|مو قوي|بسيطه|شويه')
        .hasMatch(normalize(n))) return 'خفيف';
    return 'متوسط';
  }

  // ──── نية إضافية متقدمة ────
  static String detectAdvancedIntent(String n, {String? lastTopic}) {
    if (RegExp(r'نازح|نزوح|مخيم|مشرد').hasMatch(n)) return 'special_cases';
    if (RegExp(r'مناعه|جهاز المناع|اجسام مضاده|خلايا ب').hasMatch(n)) return 'vaccine_types';
    if (RegExp(r'تاثير|مفعول|يعمل|كيف يشتغل|طريقه عمل|ميكانيكية').hasMatch(n)) return 'vaccine_types';
    if (RegExp(r'وصايا|ارشادات|نصائح مهمه').hasMatch(n)) return 'benefits';
    if (RegExp(r'ازمه|ازمة|حرب|صعوبات').hasMatch(n)) return 'special_cases';
    if (RegExp(r'نائيه|ريف|بعيد|جبليه').hasMatch(n)) return 'special_cases';
    return 'general';
  }

  // ──── هل السؤال يتطلب مقارنة؟ ────
  static bool isCompareQuestion(String n) {
    return RegExp(r'افضل|احسن|اقوى|اوفر|ولّا|او لا|بين|فرق|قارن|قارني')
        .hasMatch(normalize(n));
  }

  // ──── استخراج درجة الحرارة ────
  static double? extractTemperature(String text) {
    final n = normalize(text);
    final patterns = [
      RegExp(r'حرارته?\s*(\d+\.?\d*)'),
      RegExp(r'حرارتها?\s*(\d+\.?\d*)'),
      RegExp(r'(\d+\.?\d*)\s*درجه'),
      RegExp(r'(\d+\.?\d*)\s*°'),
      RegExp(r'سخونته?\s*(\d+\.?\d*)'),
    ];
    for (final p in patterns) {
      final m = p.firstMatch(n);
      if (m != null) {
        final v = double.tryParse(m.group(1)!);
        if (v != null && v > 30 && v < 45) return v;
      }
    }
    return null;
  }

  // ──── كشف عدد الأسئلة المتعددة ────
  static List<String> splitMultipleQuestions(String text) {
    final separators = [' و ', ' و', ' ؟ ', '؟', ' , ', '،'];
    var parts = <String>[text];
    for (final sep in separators) {
      final newParts = <String>[];
      for (final p in parts) {
        newParts.addAll(p.split(sep));
      }
      parts = newParts;
    }
    return parts.where((p) => p.trim().length > 3).toList();
  }

  // ──── كشف اللغة ────
  static bool isArabic(String text) {
    final arabicPattern = RegExp(r'[\u0600-\u06FF]');
    return arabicPattern.hasMatch(text);
  }

  // ──── كشف السؤال المفتوح vs المغلق ────
  static bool isOpenQuestion(String text) {
    final n = normalize(text);
    return RegExp(r'^(كيف|ماذا|ما|وش|ايش|ليه|ليش|متى|وين|اين|كم|من|عند|هل)').hasMatch(n);
  }
}
