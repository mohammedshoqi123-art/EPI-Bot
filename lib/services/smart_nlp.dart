// ══════════════════════════════════════════════════════════════
//  محرك الفهم العميق — NLP عربي متقدم (v2)
//  يدعم: أرقام عربية مكتوبة، سياق المحادثة، بحث ضبابي
// ══════════════════════════════════════════════════════════════

class SmartNLP {
  // ──── تطبيع شامل ────
  static String normalize(String text) {
    var t = text.trim();
    t = t.replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '');
    t = t.replaceAll('أ', 'ا').replaceAll('إ', 'ا').replaceAll('آ', 'ا');
    t = t.replaceAll('ة', 'ه').replaceAll('ى', 'ي').replaceAll('ؤ', 'و').replaceAll('ئ', 'ي');
    t = t.replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
    const ar = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const en = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    for (int i = 0; i < ar.length; i++) {
      t = t.replaceAll(ar[i], en[i]);
    }
    return t;
  }

  // ──── تطبيع خفيف (يحافظ على المعنى) ────
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
    return RegExp(r'^(مرحب|سلام|هلا|صباح|مساء|السلام|يا هلا|هلا وغلا|شخبارك|اخبارك|كيفك|كيف الحال|ايش الاخبار|وش الاخبار|يسعد|෴)')
        .hasMatch(n);
  }

  // ──── كشف المقارنة ────
  static bool hasComparison(String text) {
    return RegExp(r'افضل|احسن|اقوى|اوفر|اكثر|اقل|اكبر|اصغر|ولّا|او لا|او|ام |بين')
        .hasMatch(normalize(text));
  }

  // ──── خريطة الأرقام العربية المكتوبة ────
  static final Map<String, int> _arabicNumbers = {
    'صفر': 0,
    'واحد': 1,
    'واحده': 1,
    'اثنين': 2,
    'اثنان': 2,
    'اثنتين': 2,
    'ثلاث': 3,
    'ثلاثه': 3,
    'اربع': 4,
    'اربعه': 4,
    'خمس': 5,
    'خمسه': 5,
    'ست': 6,
    'سته': 6,
    'سبع': 7,
    'سبعه': 7,
    'ثماني': 8,
    'ثمانيه': 8,
    'تسع': 9,
    'تسعه': 9,
    'عشر': 10,
    'عشره': 10,
    'حدعش': 11,
    'اتناشر': 12,
    'اثنا عشر': 12,
    'ثلاثطعش': 13,
    'اربعتاشر': 14,
    'خمطعش': 15,
    'ستطعش': 16,
    'عشرين': 20,
    'واحد وعشرين': 21,
    'واحد و عشرين': 21,
    'عشرون': 20,
    'ثلاثين': 30,
    'ثلاثون': 30,
    'اربعين': 40,
    'خمسين': 50,
    'ستين': 60,
    'سبعين': 70,
  };

  // ──── تحويل أرقام عربية مكتوبة إلى رقم ────
  static int? parseArabicNumber(String text) {
    final n = normalize(text).trim();
    // جرّب مباشر
    if (_arabicNumbers.containsKey(n)) return _arabicNumbers[n];
    // جرّب جزئي
    for (final entry in _arabicNumbers.entries) {
      if (n.contains(normalize(entry.key))) return entry.value;
    }
    return null;
  }

  // ──── استخراج العمر المتقدم (يدعم أرقام عربية مكتوبة) ────
  static ({int weeks, int months, int days})? extractAge(String text) {
    final n = normalize(text);
    final original = softNormalize(text);

    // ── أنماط خاصة: شهر واحد / شهرين / أسبوع واحد ──
    // "شهرين" أو "اسبوعين"
    if (n.contains('شهرين')) return (weeks: 0, months: 2, days: 0);
    if (n.contains('اسبوعين')) return (weeks: 2, months: 0, days: 0);
    if (n.contains('يومين')) return (weeks: 0, months: 0, days: 2);
    if (n.contains('سنتين')) return (weeks: 0, months: 24, days: 0);
    if (n.contains('سنين')) return (weeks: 0, months: 36, days: 0);

    // "شهر واحد" / "اسبوع واحد"
    if (n.contains('شهر واحد') || n.contains('شهر واحد')) {
      return (weeks: 0, months: 1, days: 0);
    }
    if (n.contains('اسبوع واحد') || n.contains('اسبوع واحد')) {
      return (weeks: 1, months: 0, days: 0);
    }
    if (n.contains('يوم واحد')) return (weeks: 0, months: 0, days: 1);

    // ── أرقام مكتوبة عربي: "ثلاث شهور"، "خمس اسابيع" ──
    final writtenMonthPattern = RegExp(r'(\S+)\s*(شهر|شهور|اشهر)');
    final wm = writtenMonthPattern.firstMatch(n);
    if (wm != null) {
      final numText = wm.group(1)!;
      final num = parseArabicNumber(numText);
      if (num != null) return (weeks: 0, months: num, days: 0);
    }

    final writtenWeekPattern = RegExp(r'(\S+)\s*(اسبوع|اسابيع)');
    final ww = writtenWeekPattern.firstMatch(n);
    if (ww != null) {
      final numText = ww.group(1)!;
      final num = parseArabicNumber(numText);
      if (num != null) return (weeks: num, months: 0, days: 0);
    }

    final writtenDayPattern = RegExp(r'(\S+)\s*(يوم|ايام)');
    final wd = writtenDayPattern.firstMatch(n);
    if (wd != null) {
      final numText = wd.group(1)!;
      final num = parseArabicNumber(numText);
      if (num != null) return (weeks: 0, months: 0, days: num);
    }

    // ── أرقام إنجليزية: "3 شهور" ──
    var m = RegExp(r'(\d+)\s*(شهر|شهور|اشهر)').firstMatch(n);
    if (m != null) return (weeks: 0, months: int.parse(m.group(1)!), days: 0);

    var w = RegExp(r'(\d+)\s*(اسبوع|اسابيع)').firstMatch(n);
    if (w != null) return (weeks: int.parse(w.group(1)!), months: 0, days: 0);

    var d = RegExp(r'(\d+)\s*(يوم|ايام)').firstMatch(n);
    if (d != null) return (weeks: 0, months: 0, days: int.parse(d.group(1)!));

    // ── أنماط "عمره X" / "عنده X" ──
    var a = RegExp(r'عمره?\s*(\d+)').firstMatch(n);
    if (a != null) {
      final v = int.tryParse(a.group(1)!);
      if (v != null && v <= 72) return (weeks: 0, months: v, days: 0);
    }

    // "عمره ثلاث" (بدون "شهور")
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

    // ── كلمات عمر معروفة ──
    if (n.contains('سنه') && !n.contains('سنتين') && !n.contains('سنين')) {
      return (weeks: 0, months: 12, days: 0);
    }

    // ── "حديث الولادة" / "مولود جديد" ──
    if (n.contains('حديث الولاده') || n.contains('مولود جديد') || n.contains('مولوده') || n.contains('توه مولود')) {
      return (weeks: 0, months: 0, days: 0);
    }

    return null;
  }

  static String normalizeNumbers(String t) {
    const ar = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const en = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    for (int i = 0; i < ar.length; i++) {
      t = t.replaceAll(ar[i], en[i]);
    }
    return t;
  }

  // ──── استخراج كلمات مفتاحية مع مرادفات ────
  static List<String> extractKeywords(String normalized) {
    final stopWords = {
      'هل', 'ما', 'ماذا', 'كيف', 'متى', 'اين', 'وين', 'كم', 'لماذا', 'ليه', 'ليش',
      'عند', 'في', 'من', 'الى', 'الي', 'على', 'عن', 'مع', 'او', 'ام', 'ثم', 'لكن',
      'بعد', 'قبل', 'بين', 'هذا', 'هذه', 'ذلك', 'انا', 'انت', 'هو', 'هي', 'نحن',
      'كان', 'يكون', 'اذا', 'لو', 'اريد', 'ابي', 'نبي', 'ودي',
      'طفلي', 'طفله', 'ولدي', 'بنتي', 'يعني', 'صح', 'طيب', 'تمام', 'زين', 'ايش', 'وش',
      'الي', 'اللي', 'لدي', 'عندما', 'حاب', 'بدي', 'عند',
    };
    return normalized
        .split(' ')
        .where((w) => w.length > 1 && !stopWords.contains(w))
        .toList();
  }

  // ──── مرادفات عربية شاملة ────
  static final Map<String, List<String>> _synonyms = {
    'حراره': ['سخونه', 'حمى', 'يرتفع', 'سخن', 'حمم', 'حرار', 'يسخن', 'سخنت'],
    'الم': ['يالم', 'يتالم', 'يتألم', 'وجع', 'يوجع', 'يعور', 'الام'],
    'احمرار': ['احمر', 'يحمر', 'حمره', 'احمرت'],
    'تورم': ['انتفاخ', 'ينتفخ', 'ورم', 'يتورم', 'انتفخ', 'تنفخ'],
    'اطعم': ['اعطي', 'اخذ', 'اسوي', 'احط', 'احطه', 'يسوي', 'ياخذ'],
    'تطعيم': ['لقاح', 'حقنه', 'تطعيمه', 'تطعيمات', 'لقاحات'],
    'طفل': ['رضيع', 'وليد', 'صغير', 'بيبي', 'ولد', 'بنت', 'عيل'],
    'مريض': ['مريضه', 'تعبان', 'تعبانه', 'مريض', 'مصاب', 'مريضه', 'تعب'],
    'مجاني': ['مجانا', 'بلاش', 'بدون فلوس', 'ما يكلف', 'مجان', 'بلا رسوم'],
    'خطر': ['خطير', 'يخوف', 'مضر', 'ضار', 'مو امان'],
    'عمر': ['سن', 'عمر', 'كبر', 'صغير'],
    'آثار': ['اعراض', 'جانبيه', 'تأثير', 'يصير', 'يسوي', 'يحصل'],
    ' безопас': ['امان', 'مو ضار', 'ما يضر', 'مو خطر'],
    ' مكان': ['وين', 'اين', 'مركز', 'مستشفى', 'عياده'],
    ' مجاني': ['بلاش', 'مجاني', 'مجانا', 'بلا فلوس'],
  };

  // ──── تشابه مع مرادفات (مُحسّن) ────
  static double calculateRelevance(String input, List<String> topicKeywords) {
    final inputKw = extractKeywords(input);
    if (inputKw.isEmpty || topicKeywords.isEmpty) return 0;

    int matches = 0;
    for (final kw in topicKeywords) {
      for (final iw in inputKw) {
        // تطابق مباشر
        if (iw.contains(kw) || kw.contains(iw)) {
          matches++;
          break;
        }
        // تطابق بالمرادفات
        final syns = _synonyms[kw] ?? [];
        for (final syn in syns) {
          if (iw.contains(syn) || syn.contains(iw)) {
            matches++;
            break;
          }
        }
        // تطابق عكسي
        for (final entry in _synonyms.entries) {
          if (entry.key == iw && entry.value.contains(kw)) {
            matches++;
            break;
          }
        }
      }
    }
    return matches / topicKeywords.length;
  }

  // ──── تشابه نصي بسيط (Jaro-Winkler مبسط) ────
  static double simpleSimilarity(String a, String b) {
    if (a == b) return 1.0;
    if (a.isEmpty || b.isEmpty) return 0.0;

    // Longest common subsequence ratio
    final longer = a.length > b.length ? a : b;
    final shorter = a.length > b.length ? b : a;

    if (longer.length == 0) return 1.0;

    // Check if shorter is substring of longer
    if (longer.contains(shorter)) {
      return shorter.length / longer.length;
    }

    // Count common characters
    int common = 0;
    for (int i = 0; i < shorter.length; i++) {
      if (i < longer.length && shorter[i] == longer[i]) common++;
    }
    return common / longer.length;
  }

  // ──── اكتشاف النية المتقدم مع فهم السياق ────
  static String detectIntent(String normalized, {String? previousIntent, String? lastTopic}) {
    final n = normalized;

    // ── تحية ──
    if (isGreeting(n)) return 'greeting';

    // ── أسئلة طوارئ (أولوية عالية) ──
    if (RegExp(r'طوارئ|خطير|خطر|يسكر|يعور|ما يتنفس|يتلوى|يتشنج|فقد وعي|ما يرد|اختنق')
        .hasMatch(n)) {
      return 'emergency';
    }

    // ── متى أخاف/أروح (طوارئ أيضاً) ──
    if (RegExp(r'متى اروح|متى اخاف|متى اقلق|متى اوديه|متى اطلب|متى استشير')
        .hasMatch(n)) {
      return 'emergency';
    }

    // ── آثار جانبية ──
    if (RegExp(r'اثار|جانبيه|اعراض|وش يصير|ايش يصير|وش يسوي|ايش يسوي')
        .hasMatch(n)) return 'side_effects';
    if (RegExp(r'حراره|سخون|حمى|يحر|يسخن')
        .hasMatch(n) &&
        RegExp(r'تطعيم|لقاح|حقنه|بعد')
            .hasMatch(n)) return 'side_effects';
    if (RegExp(r'يبكي|بكاء|صار يبكي|ما يسكت|يبكي كثير')
        .hasMatch(n)) return 'side_effects';
    if (RegExp(r'تورم|انتفاخ|ورم|انتفخ')
        .hasMatch(n)) return 'side_effects';
    if (RegExp(r'تشنج|نوبه|يرتعش|يرتجف|رعشه')
        .hasMatch(n)) return 'side_effects';

    // ── أسئلة عمر (يحتاج سياق طفل) ──
    if (RegExp(r'عمر|سن|شهر|اسبوع|يوم|كم باقي|باقي')
        .hasMatch(n)) {
      if (RegExp(r'طفل|طفله|ولد|بنت|رضيع|عمره|عمرها|عنده|عندها|ولدي|بنتي|ابني|بنتي')
          .hasMatch(n)) {
        return 'age_query';
      }
      return 'schedule_query';
    }

    // ── "وش تطعيماته" بدون عمر — لكن فيه سياق طفل ──
    if (RegExp(r'تطعيم|لقاح|ياخذ|لازم|مطلوب|وش ياخذ|ايش ياخذ')
        .hasMatch(n)) {
      if (previousIntent == 'age_query' || lastTopic?.contains('عمر') == true) {
        return 'age_query'; // متابعة لسؤال العمر
      }
      return 'vaccine_list';
    }

    // ── جرعات ──
    if (RegExp(r'كم جرعه|كم مره|عدد|جرعات|كم حقه|كم مره ياخذ')
        .hasMatch(n)) return 'dose_count';

    // ── موقع ──
    if (RegExp(r'وين|اين|مكان|مركز|مستشفى|عياده|وين اطعم|اين اطعم')
        .hasMatch(n)) return 'location';

    // ── تكلفة ──
    if (RegExp(r'مجاني|مجانا|سعر|تكلفه|رسوم|فلوس|ثمن|بكم|كم يكلف|بلاش')
        .hasMatch(n)) return 'cost';

    // ── حملات ──
    if (RegExp(r'حمله|حملات|تطعيم وطني|NIDs')
        .hasMatch(n)) return 'campaigns';

    // ── أنواع ──
    if (RegExp(r'نوع|انواع|وش الفرق|ايش الفرق|كيف يشتغل|كيف يعمل')
        .hasMatch(n)) return 'vaccine_types';

    // ── أساطير ──
    if (RegExp(r'اسطوره|خرافه|اكاذيب|مضره|يضر|يسبب|autism|اوتيزم|يشل|عقم|خصوبه')
        .hasMatch(n)) return 'myths';

    // ── حالات خاصة ──
    if (RegExp(r'مبتسر|خديج|مريض|مرضعه|حامل|سكر|قلب|سرطان|hiv|ايدز|ربو|صرع')
        .hasMatch(n)) return 'special_cases';

    // ── تغذية ──
    if (RegExp(r'تغذيه|اكل|غذاء|ياكل|رضاعه|يرضع|حليب')
        .hasMatch(n)) return 'nutrition';

    // ── سلسلة تبريد ──
    if (RegExp(r'تبريد|سلسله بارده|ثلاجه|تخزين|vvm|درجه حراره')
        .hasMatch(n)) return 'cold_chain';

    // ── متابعة (نعم/لا/اشرح) ──
    if (RegExp(r'^(نعم|ايوه|ايه|اي|يب|لا|كم|ليه|ليش|اشرح|وضح|بالتفصيل|تفاصيل|طيب|تمام|واضح|فهمت|اوكي|زين|اوك)')
        .hasMatch(n)) {
      return 'follow_up';
    }

    // ── سفر ──
    if (RegExp(r'سفر|مسافر|سياحه|مطار')
        .hasMatch(n)) return 'travel';

    // ── تاريخ ──
    if (RegExp(r'تاريخ|متى بدأ|متى بدا|متى انشئ')
        .hasMatch(n)) return 'history';

    // ── فوائد ──
    if (RegExp(r'فوائد|ليش نطعم|ليش مهم|فايده')
        .hasMatch(n)) return 'benefits';

    // ── ليش (سؤال عن السبب — قد يكون فوائد أو أساطير) ──
    if (n.startsWith('ليش') || n.startsWith('لماذا')) {
      if (previousIntent == 'myths' || previousIntent == 'benefits') {
        return previousIntent!;
      }
      return 'benefits';
    }

    // ── أمراض ──
    if (RegExp(r'مرض|امراض|عدوى|инфекци')
        .hasMatch(n)) return 'diseases';

    // ── تشخيص حالة الطفل ──
    if (RegExp(r'مريض|تعبان|مريضه|مريض|ما ياكل|يرفض|ما يبي|مريض')
        .hasMatch(n)) return 'child_sick';

    // ── سياق محادثة: إذا كنا نتحدث عن موضوع محدد ──
    if (previousIntent != null && previousIntent != 'general' && previousIntent != 'greeting') {
      // إذا السؤال قصير وغامض، تابع نفس النية
      if (n.length < 15 && !_isNewTopic(n)) {
        return previousIntent;
      }
    }

    // ── سؤال عام ──
    return 'general';
  }

  // ──── هل يشير لנושא جديد؟ ────
  static bool _isNewTopic(String n) {
    return RegExp(r'طيب|بس|تمام|غير|اوكي|زين|اوك').hasMatch(n);
  }

  // ──── اكتشاف التطعيم ────
  static String? detectVaccineMention(String n) {
    final p = {
      'bcg': ['bcg', 'بي سي جي', 'سل', 'درن'],
      'opv': ['opv', 'شلل فموي', 'بوليو', 'قطرات شلل', 'شلل اطفال'],
      'ipv': ['ipv', 'شلل حقن'],
      'penta': ['خماسي', 'pentavalent', 'penta', 'dtp'],
      'pcv': ['رئوي', 'pneumococcal', 'pcv', 'مكورات رئوي'],
      'rota': ['روتا', 'rotavirus', 'روتا فيروس'],
      'mr': ['حصبه', 'measles', 'mr', 'mmr', 'نكاف', 'حصبه المانيه'],
      'td': ['نسائي', 'حوامل', 'حامل', 'td', 'tt'],
      'vitA': ['فيتامين', 'vitamin'],
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
      'measles': ['الحصبه', 'حصبه'],
      'polio': ['شلل اطفال', 'شلل'],
      'tetanus': ['كزاز'],
      'diphtheria': ['خناق'],
      'pertussis': ['سعال ديبي', 'سعال'],
      'hepatitis': ['كبد', 'التهاب كبد'],
      'pneumonia': ['رئوي', 'التهاب رئه'],
      'rotavirus': ['روتا', 'اسهال'],
      'meningitis': ['اغشيه مخيه', 'سحايا'],
      'rubella': ['المانيه'],
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
    if (RegExp(r'كثير|شديد|قوي|مو طبيعي|يخوف|مستمر|ما يوقف|صار ساعه|خطير|قوي جدا')
        .hasMatch(n)) return 'شديد';
    if (RegExp(r'بسيط|خفيف|شوي|مو كثير|مو قوي|بسيطه')
        .hasMatch(normalize(n))) return 'خفيف';
    return 'متوسط';
  }

  // ──── هل السؤال يتطلب مقارنة؟ ────
  static bool isCompareQuestion(String n) {
    return RegExp(r'افضل|احسن|اقوى|اوفر|ولّا|او لا|بين|فرق|قارن|قارني')
        .hasMatch(normalize(n));
  }

  // ──── استخراج درجة الحرارة المذكورة ────
  static double? extractTemperature(String text) {
    final n = normalize(text);
    // "حرارته 39" / "39 درجة" / "حرارة 38.5"
    final patterns = [
      RegExp(r'حرارته?\s*(\d+\.?\d*)'),
      RegExp(r'حرارتها?\s*(\d+\.?\d*)'),
      RegExp(r'(\d+\.?\d*)\s*درجه'),
      RegExp(r'(\d+\.?\d*)\s*°'),
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
}
