// ══════════════════════════════════════════════════════════════
//  محرك الفهم العميق — NLP عربي متقدم جداً
// ══════════════════════════════════════════════════════════════

class SmartNLP {
  // ──── تطبيع شامل ────
  static String normalize(String text) {
    var t = text.trim();
    t = t.replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '');
    t = t.replaceAll('أ','ا').replaceAll('إ','ا').replaceAll('آ','ا');
    t = t.replaceAll('ة','ه').replaceAll('ى','ي').replaceAll('ؤ','و').replaceAll('ئ','ي');
    t = t.replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
    const ar = ['٠','١','٢','٣','٤','٥','٦','٧','٨','٩'];
    const en = ['0','1','2','3','4','5','6','7','8','9'];
    for (int i = 0; i < ar.length; i++) t = t.replaceAll(ar[i], en[i]);
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
    final negations = ['ما','مو','ماب','موب','لا','بدون','ما يبي','ما ابي','ما ابغي','ما ابغى','ما يبغى','ما ودي','مو حاب','مو حابه','ماني','مابي','موش','مش'];
    final n = normalize(text);
    for (final neg in negations) {
      if (n.contains(neg)) return true;
    }
    return false;
  }

  // ──── كشف المقارنة ────
  static bool hasComparison(String text) {
    return RegExp(r'افضل|احسن|اقوى|اوفر|اكثر|اقل|اكبر|اصغر|ولّا|او لا|او|ام |بين').hasMatch(normalize(text));
  }

  // ──── استخراج كلمات مفتاحية مع مرادفات ────
  static List<String> extractKeywords(String normalized) {
    final stopWords = {
      'هل','ما','ماذا','كيف','متى','اين','وين','كم','لماذا','ليه','ليش',
      'عند','في','من','الى','الي','على','عن','مع','او','ام','ثم','لكن',
      'بعد','قبل','بين','هذا','هذه','ذلك','انا','انت','هو','هي','نحن',
      'كان','يكون','اذا','لو','اريد','ابي','نبي','ودي',
      'طفلي','طفله','ولدي','بنتي','يعني','صح','طيب','تمام','زين','ايش','وش',
      'الي','اللي','لدي','عندما','حاب','بدي','عند',
    };
    return normalized.split(' ').where((w) => w.length > 1 && !stopWords.contains(w)).toList();
  }

  // ──── تشابه مع مرادفات ────
  static double calculateRelevance(String input, List<String> topicKeywords) {
    final inputKw = extractKeywords(input);
    if (inputKw.isEmpty || topicKeywords.isEmpty) return 0;
    
    // مرادفات عربية شائعة
    final synonyms = {
      'حراره': ['سخونه','حمى','يرتفع','سخن','حمم'],
      'الم': ['يالم','يتالم','يتألم','وجع','يوجع'],
      'احمرار': ['احمر','يحمر','حمره'],
      'تورم': ['انتفاخ','ينتفخ','ورم','يتورم'],
      'اطعم': ['اعطي','اخذ','اسوي','احط','احطه'],
      'تطعيم': ['لقاح','حقنه','تطعيمه'],
      'طفل': ['رضيع','وليد','صغير','بيبي'],
      'مريض': ['مريضه','تعبان','مريض','مريضه','مصاب'],
      'مجاني': ['مجانا','بلاش','بدون فلوس','ما يكلف'],
      'خطر': ['خطير','يخوف','مضر','ضار'],
    };

    int matches = 0;
    for (final kw in topicKeywords) {
      for (final iw in inputKw) {
        // تطابق مباشر
        if (iw.contains(kw) || kw.contains(iw)) { matches++; break; }
        // تطابق بالمرادفات
        for (final syn in synonyms[kw] ?? []) {
          if (iw.contains(syn) || syn.contains(iw)) { matches++; break; }
        }
        // تطابق عكسي
        for (final entry in synonyms.entries) {
          if (entry.key == iw && entry.value.contains(kw)) { matches++; break; }
        }
      }
    }
    return matches / topicKeywords.length;
  }

  // ──── اكتشاف النية المتقدم مع فهم السياق ────
  static String detectIntent(String normalized, {String? previousIntent, String? lastTopic}) {
    // أسئلة طوارئ (أولوية عالية)
    if (RegExp(r'طوارئ|خطير|خطر|يسكر|يعور|ما يتنفس|يتلوى|يتشنج|فقد وعي|ما يرد').hasMatch(normalized)) {
      return 'emergency';
    }

    // أسئلة عمر
    if (RegExp(r'عمر|سن|شهر|اسبوع|يوم|كم باقي|باقي').hasMatch(normalized)) {
      if (RegExp(r'طفل|طفله|ولد|بنت|رضيع|عمره|عمرها|عنده|عندها|ولدي|بنتي').hasMatch(normalized)) {
        return 'age_query';
      }
      return 'schedule_query';
    }

    // تطعيمات مطلوبة
    if (RegExp(r'تطعيمات مطلوبه|وش التطعيمات|ايش التطعيمات|التطعيمات الي|وش لازم|ايش لازم').hasMatch(normalized)) {
      return 'vaccine_list';
    }

    // جرعات
    if (RegExp(r'كم جرعه|كم مره|عدد|جرعات|كم حقه|كم مره ياخذ').hasMatch(normalized)) return 'dose_count';

    // آثار جانبية — مع سياق
    if (RegExp(r'اثار|جانبيه|اعراض|وش يصير|ايش يصير|وش يسوي|ايش يسوي').hasMatch(normalized)) return 'side_effects';
    if (RegExp(r'حراره|سخون|حمى|يحر').hasMatch(normalized) && RegExp(r'تطعيم|لقاح|حقنه|بعد').hasMatch(normalized)) return 'side_effects';
    if (RegExp(r'يبكي|بكاء|صار يبكي|ما يسكت|يبكي كثير').hasMatch(normalized)) return 'side_effects';
    if (RegExp(r'تورم|انتفاخ|ورم|انتفخ').hasMatch(normalized)) return 'side_effects';
    if (RegExp(r'تشنج|نوبه|يرتعش|يرتجف|رعشه').hasMatch(normalized)) return 'side_effects';

    // متى أخاف/أروح
    if (RegExp(r'متى اروح|متى اخاف|متى اقلق|متى اوديه|متى اطلب|متى استشير').hasMatch(normalized)) return 'emergency';

    // موقع
    if (RegExp(r'وين|اين|مكان|مركز|مستشفى|عيادة|وين اطعم|اين اطعم').hasMatch(normalized)) return 'location';

    // تكلفة
    if (RegExp(r'مجاني|مجانا|سعر|تكلفة|رسوم|فلوس|ثمن|بكم|كم يكلف|بلاش').hasMatch(normalized)) return 'cost';

    // حملات
    if (RegExp(r'حمله|حملات|تطعيم وطني|NIDs').hasMatch(normalized)) return 'campaigns';

    // أنواع
    if (RegExp(r'نوع|انواع|وش الفرق|ايش الفرق|كيف يشتغل|كيف يعمل').hasMatch(normalized)) return 'vaccine_types';

    // أساطير
    if (RegExp(r'اسطوره|خرافه|اكاذيب|مضره|يضر|يسبب|autism|اوتيزم|يشل|عقم|خصوبه|يضر').hasMatch(normalized)) return 'myths';

    // حالات خاصة
    if (RegExp(r'مبتسر|خديج|مريض|مرضعه|حامل|سكر|قلب|سرطان|hiv|ايدز|ربو|صرع').hasMatch(normalized)) return 'special_cases';

    // تغذية
    if (RegExp(r'تغذيه|اكل|غذاء|ياكل|رضاعه|يرضع|حليب').hasMatch(normalized)) return 'nutrition';

    // سلسلة تبريد
    if (RegExp(r'تبريد|سلسله بارده|ثلاجه|تخزين|vvm|درجة حراره').hasMatch(normalized)) return 'cold_chain';

    // متابعة (نعم/لا/اشرح)
    if (RegExp(r'^(نعم|ايوه|ايه|اي|يب|لا|كم|ليه|ليش|اشرح|وضح|بالتفصيل|تفاصيل|طيب|تمام|واضح|فهمت|اوكي|زين)').hasMatch(normalized)) {
      return 'follow_up';
    }

    // سفر
    if (RegExp(r'سفر|مسافر|سياحه|مطار').hasMatch(normalized)) return 'travel';

    // تاريخ
    if (RegExp(r'تاريخ|متى بدأ|متى بدا|متى انشئ').hasMatch(normalized)) return 'history';

    // فوائد
    if (RegExp(r'فوائد|ليش نطعم|ليش مهم|فايده|ليش').hasMatch(normalized)) return 'benefits';

    // أمراض
    if (RegExp(r'مرض|امراض|عدوى|инфекци').hasMatch(normalized)) return 'diseases';

    // تشخيص الحالة
    if (RegExp(r'مريض|تعبان|مريضه|مريض|ما ياكل|يرفض|ما يبي').hasMatch(normalized)) return 'child_sick';

    // سؤال عام
    return 'general';
  }

  // ──── استخراج العمر المتقدم ────
  static ({int weeks, int months, int days})? extractAge(String text) {
    final n = normalizeNumbers(normalize(text));
    var m = RegExp(r'(\d+)\s*(شهر|شهور|اشهر)').firstMatch(n);
    if (m != null) return (weeks: 0, months: int.parse(m.group(1)!), days: 0);
    var w = RegExp(r'(\d+)\s*(اسبوع|اسابيع)').firstMatch(n);
    if (w != null) return (weeks: int.parse(w.group(1)!), months: 0, days: 0);
    var d = RegExp(r'(\d+)\s*(يوم|ايام)').firstMatch(n);
    if (d != null) return (weeks: 0, months: 0, days: int.parse(d.group(1)!));
    var a = RegExp(r'عمره?\s*(\d+)').firstMatch(n);
    if (a != null) { final v = int.tryParse(a.group(1)!); if (v != null && v <= 72) return (weeks: 0, months: v, days: 0); }
    var h = RegExp(r'عنده[ا]?\s*(\d+)').firstMatch(n);
    if (h != null) { final v = int.tryParse(h.group(1)!); if (v != null && v <= 72) return (weeks: 0, months: v, days: 0); }
    if (n.contains('سنه') && !n.contains('سنتين')) return (weeks: 0, months: 12, days: 0);
    if (n.contains('سنتين')) return (weeks: 0, months: 24, days: 0);
    if (n.contains('3 سنين') || n.contains('ثلاث سنين')) return (weeks: 0, months: 36, days: 0);
    if (n.contains('6 سنين') || n.contains('ست سنين')) return (weeks: 0, months: 72, days: 0);
    return null;
  }

  static String normalizeNumbers(String t) {
    const ar = ['٠','١','٢','٣','٤','٥','٦','٧','٨','٩'];
    const en = ['0','1','2','3','4','5','6','7','8','9'];
    for (int i = 0; i < ar.length; i++) t = t.replaceAll(ar[i], en[i]);
    return t;
  }

  // ──── اكتشاف التطعيم ────
  static String? detectVaccineMention(String n) {
    final p = {
      'bcg': ['bcg','بي سي جي','سل','درن'],
      'opv': ['opv','شلل فموي','بوليو','قطرات شلل'],
      'ipv': ['ipv','شلل حقن'],
      'penta': ['خماسي','pentavalent','penta','dtp'],
      'pcv': ['رئوي','pneumococcal','pcv','مكورات رئوي'],
      'rota': ['روتا','rotavirus'],
      'mr': ['حصبه','measles','mr','mmr','نكاف'],
      'td': ['نسائي','حوامل','حامل','td','tt'],
      'vitA': ['فيتامين','vitamin'],
    };
    for (final e in p.entries) { for (final k in e.value) { if (n.contains(k)) return e.key; } }
    return null;
  }

  // ──── اكتشاف المرض ────
  static String? detectDiseaseMention(String n) {
    final p = {
      'measles': ['الحصبه','حصبه'],'polio': ['شلل اطفال','شلل'],
      'tetanus': ['كزاز'],'diphtheria': ['خناق'],
      'pertussis': ['سعال ديبي','سعال'],'hepatitis': ['كبد','التهاب كبد'],
      'pneumonia': ['رئوي','التهاب رئه'],'rotavirus': ['روتا','اسهال'],
      'meningitis': ['اغشيه مخيه','سحايا'],'rubella': ['المانيه'],
    };
    for (final e in p.entries) { for (final k in e.value) { if (n.contains(k)) return e.key; } }
    return null;
  }

  // ──── كشف شدة الأعراض ────
  static String detectSeverity(String n) {
    if (RegExp(r'كثير|شديد|قوي|مو طبيعي|يخوف|مستمر|ما يوقف|صار ساعه').hasMatch(n)) return 'شديد';
    if (RegExp(r'بسيط|خفيف|شوي|مو كثير|مو قوي').hasMatch(normalize(n))) return 'خفيف';
    return 'متوسط';
  }

  // ──── هل السؤال يتطلب مقارنة؟ ────
  static bool isCompareQuestion(String n) {
    return RegExp(r'افضل|احسن|اقوى|اوفر|ولّا|او لا|بين|فرق|قارن|قارني').hasMatch(normalize(n));
  }
}
