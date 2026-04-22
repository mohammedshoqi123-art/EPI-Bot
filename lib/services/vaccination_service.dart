import 'package:flutter/material.dart';
import '../models/vaccine_model.dart';

class VaccinationService extends ChangeNotifier {
  // ══════════════════════════════════════════════════════════════
  //  اليمن - برنامج التحصين الصحي الموسع (EPI)
  //  الجدول الكامل للتطعيمات حسب الدليل الرسمي أغسطس 2025
  // ══════════════════════════════════════════════════════════════

  static const List<Vaccine> allVaccines = [
    // ──────────── عند الولادة ────────────
    Vaccine(
      id: 'bcg',
      nameAr: 'بي سي جي (BCG)',
      nameEn: 'Bacillus Calmette-Guérin',
      description: 'تطعيم ضد السل (Tuberculosis) - يعطى مرة واحدة عند الولادة أو في أقرب فرصة ممكنة',
      dueWeeks: 0,
      doseNumber: 'جرعة واحدة',
      route: 'intradermal',
      site: 'الذراع الأيسر - فوق العضلة الدالية',
      color: '#E74C3C',
      iconEmoji: '🩸',
      sideEffects: ['احمرار مكان الحقن', 'تورم بسيط', 'قُرحة صغيرة تشفى تلقائياً خلال 2-3 أشهر'],
      contraindications: ['ضعف المناعة الشديد'],
      notes: 'يُعطى عند الولادة أو في أقرب فرصة. الحد الأقصى: سنة واحدة (12 شهر) — بعد السنة لا يُعطي. العلامة الطبيعية (التندب) تظهر بعد 6-8 أسابيع',
    ),
    Vaccine(
      id: 'hepb0',
      nameAr: 'التهاب الكبد ب - جرعة الولادة',
      nameEn: 'Hepatitis B - Birth Dose',
      description: 'الجرعة الأولى من تطعيم التهاب الكبد B - تُعطى خلال 24 ساعة من الولادة',
      dueWeeks: 0,
      doseNumber: 'جرعة الولادة',
      route: 'intramuscular',
      site: 'الفخذ الأيمن الأمامي',
      color: '#3498DB',
      iconEmoji: '💉',
      sideEffects: ['ألم بسيط مكان الحقن', 'حرارة خفيفة'],
      contraindications: ['حساسية شديدة لمكونات التطعيم'],
      notes: 'تُعطى خلال أول 24 ساعة من الولادة، خاصة للأمهات الحاملات للفيروس',
    ),
    Vaccine(
      id: 'opv0',
      nameAr: 'تطعيم شلل الأطفال الفموي - جرعة الولادة',
      nameEn: 'OPV0 - Oral Polio Vaccine Birth Dose',
      description: 'الجرعة الصفر من تطعيم شلل الأطفال الفموي - تُعطى عند الولادة',
      dueWeeks: 0,
      doseNumber: 'الجرعة الصفر (OPV0)',
      route: 'oral',
      site: 'عن طريق الفم',
      color: '#27AE60',
      iconEmoji: '💧',
      sideEffects: ['لا توجد آثار جانبية شائعة'],
      contraindications: ['ضعف المناعة الشديد'],
      notes: 'تُعطى قطرات في الفم عند الولادة. اليمن بلد خالي من شلل الأطفال',
    ),

    // ──────────── عمر 6 أسابيع ────────────
    Vaccine(
      id: 'opv1',
      nameAr: 'شلل الأطفال الفموي - الجرعة الأولى',
      nameEn: 'OPV1 - Oral Polio Vaccine Dose 1',
      description: 'الجرعة الأولى من تطعيم شلل الأطفال الفموي',
      dueWeeks: 6,
      doseNumber: 'الجرعة الأولى (OPV1)',
      route: 'oral',
      site: 'عن طريق الفم',
      color: '#27AE60',
      iconEmoji: '💧',
      sideEffects: ['لا توجد آثار جانبية شائعة'],
      contraindications: ['ضعف المناعة الشديد'],
      notes: 'تُعطى مع باقي تطعيمات عمر 6 أسابيع',
    ),
    Vaccine(
      id: 'pentavalent1',
      nameAr: 'التطعيم الخماسي - الجرعة الأولى',
      nameEn: 'Pentavalent (DTP-HepB-Hib) Dose 1',
      description: 'تطعيم واحد يحمي من 5 أمراض: الخناق والكزاز والسعال الديبي والتهاب الكبد B والتهاب الأغشية المخية بكتيريا HiB',
      dueWeeks: 6,
      doseNumber: 'الجرعة الأولى',
      route: 'intramuscular',
      site: 'الفخذ الأيسر الأمامي',
      color: '#E67E22',
      iconEmoji: '5️⃣',
      sideEffects: ['ألم واحمرار مكان الحقن', 'حرارة', 'بكاء غير معتاد'],
      contraindications: ['استجابة عصبية بعد جرعة سابقة', 'اعتلال دماغي بعد جرعة سابقة'],
      notes: 'تطعيم أساسي ومهم جداً. يُعطى 3 جرعات بفاصل 4 أسابيع',
    ),
    Vaccine(
      id: 'pcv1',
      nameAr: 'التطعيم الرئوي - الجرعة الأولى',
      nameEn: 'PCV1 - Pneumococcal Conjugate Vaccine',
      description: 'تطعيم ضد المكورات الرئوية التي تسبب التهاب السحايا والتهاب الرئة والتهاب الأذن الوسطى',
      dueWeeks: 6,
      doseNumber: 'الجرعة الأولى',
      route: 'intramuscular',
      site: 'الفخذ الأيسر الأمامي',
      color: '#8E44AD',
      iconEmoji: '🫁',
      sideEffects: ['ألم مكان الحقن', 'حرارة', 'نعاس'],
      contraindications: ['حساسية شديدة للجرعات السابقة'],
      notes: 'مهم جداً لحماية الرضع من الالتهابات الرئوية',
    ),
    Vaccine(
      id: 'rv1',
      nameAr: 'تطعيم الروتا فيروس - الجرعة الأولى',
      nameEn: 'Rotavirus Vaccine Dose 1',
      description: 'تطعيم فموي ضد فيروس الروتا المسبب للإسهال الشديد عند الرضع',
      dueWeeks: 6,
      doseNumber: 'الجرعة الأولى',
      route: 'oral',
      site: 'عن طريق الفم',
      color: '#1ABC9C',
      iconEmoji: '🦠',
      sideEffects: ['إسهال خفيف', 'قيء نادر'],
      contraindications: ['انسداد معوي', 'متلازمة روتا الفيروسي بعد جرعة سابقة'],
      notes: 'فموي وليس حقن! عمر أقصى للجرعة الأولى: 15 أسبوع',
    ),

    // ──────────── عمر 10 أسابيع ────────────
    Vaccine(
      id: 'opv2',
      nameAr: 'شلل الأطفال الفموي - الجرعة الثانية',
      nameEn: 'OPV2 - Oral Polio Vaccine Dose 2',
      description: 'الجرعة الثانية من تطعيم شلل الأطفال الفموي',
      dueWeeks: 10,
      doseNumber: 'الجرعة الثانية (OPV2)',
      route: 'oral',
      site: 'عن طريق الفم',
      color: '#27AE60',
      iconEmoji: '💧',
      sideEffects: [],
      contraindications: [],
      notes: 'فاصل 4 أسابيع عن الجرعة الأولى',
    ),
    Vaccine(
      id: 'pentavalent2',
      nameAr: 'التطعيم الخماسي - الجرعة الثانية',
      nameEn: 'Pentavalent Dose 2',
      description: 'الجرعة الثانية من التطعيم الخماسي',
      dueWeeks: 10,
      doseNumber: 'الجرعة الثانية',
      route: 'intramuscular',
      site: 'الفخذ الأيسر الأمامي',
      color: '#E67E22',
      iconEmoji: '5️⃣',
      sideEffects: ['ألم مكان الحقن', 'حرارة خفيفة'],
      contraindications: [],
      notes: 'فاصل 4 أسابيع عن الجرعة الأولى',
    ),
    Vaccine(
      id: 'pcv2',
      nameAr: 'التطعيم الرئوي - الجرعة الثانية',
      nameEn: 'PCV2',
      description: 'الجرعة الثانية من تطعيم المكورات الرئوية',
      dueWeeks: 10,
      doseNumber: 'الجرعة الثانية',
      route: 'intramuscular',
      site: 'الفخذ الأيسر الأمامي',
      color: '#8E44AD',
      iconEmoji: '🫁',
      sideEffects: ['ألم مكان الحقن'],
      contraindications: [],
      notes: '',
    ),
    Vaccine(
      id: 'rv2',
      nameAr: 'تطعيم الروتا فيروس - الجرعة الثانية',
      nameEn: 'Rotavirus Vaccine Dose 2',
      description: 'الجرعة الثانية من تطعيم الروتا فيروس',
      dueWeeks: 10,
      doseNumber: 'الجرعة الثانية',
      route: 'oral',
      site: 'عن طريق الفم',
      color: '#1ABC9C',
      iconEmoji: '🦠',
      sideEffects: [],
      contraindications: [],
      notes: 'فاصل 4 أسابيع عن الجرعة الأولى. عمر أقصى: 24 أسبوع',
    ),

    // ──────────── عمر 14 أسبوع ────────────
    Vaccine(
      id: 'opv3',
      nameAr: 'شلل الأطفال الفموي - الجرعة الثالثة',
      nameEn: 'OPV3',
      description: 'الجرعة الثالثة من تطعيم شلل الأطفال الفموي',
      dueWeeks: 14,
      doseNumber: 'الجرعة الثالثة (OPV3)',
      route: 'oral',
      site: 'عن طريق الفم',
      color: '#27AE60',
      iconEmoji: '💧',
      sideEffects: [],
      contraindications: [],
      notes: 'هذه الجرعة مكتملة لسلسلة التطعيم الأساسية لشلل الأطفال',
    ),
    Vaccine(
      id: 'pentavalent3',
      nameAr: 'التطعيم الخماسي - الجرعة الثالثة',
      nameEn: 'Pentavalent Dose 3',
      description: 'الجرعة الثالثة والأخيرة من التطعيم الخماسي',
      dueWeeks: 14,
      doseNumber: 'الجرعة الثالثة',
      route: 'intramuscular',
      site: 'الفخذ الأيسر الأمامي',
      color: '#E67E22',
      iconEmoji: '5️⃣',
      sideEffects: ['ألم مكان الحقن', 'حرارة خفيفة'],
      contraindications: [],
      notes: 'الجرعة الثالثة المكتملة - حماية كاملة',
    ),
    Vaccine(
      id: 'pcv3',
      nameAr: 'التطعيم الرئوي - الجرعة الثالثة',
      nameEn: 'PCV3',
      description: 'الجرعة الثالثة من تطعيم المكورات الرئوية',
      dueWeeks: 14,
      doseNumber: 'الجرعة الثالثة',
      route: 'intramuscular',
      site: 'الفخذ الأيسر الأمامي',
      color: '#8E44AD',
      iconEmoji: '🫁',
      sideEffects: [],
      contraindications: [],
      notes: 'الجرعة الثالثة المكتملة',
    ),
    Vaccine(
      id: 'ipv1',
      nameAr: 'شلل الأطفال الحقني (IPV) - الجرعة الأولى',
      nameEn: 'Inactivated Polio Vaccine - Dose 1',
      description: 'الجرعة الأولى من تطعيم شلل الأطفال الحقني',
      dueWeeks: 14,
      doseNumber: 'الجرعة الأولى',
      route: 'intramuscular',
      site: 'الفخذ الأيسر الأمامي',
      color: '#2C3E50',
      iconEmoji: '💉',
      sideEffects: ['ألم مكان الحقن', 'احمرار'],
      contraindications: [],
      notes: 'يُعطى مع OPV3 عند 14 أسبوع. الحد الأقصى: 5 سنوات',
    ),
    Vaccine(
      id: 'ipv2',
      nameAr: 'شلل الأطفال الحقني (IPV) - الجرعة الثانية',
      nameEn: 'Inactivated Polio Vaccine - Dose 2',
      description: 'الجرعة الثانية من تطعيم شلل الأطفال الحقني',
      dueMonths: 9,
      doseNumber: 'الجرعة الثانية',
      route: 'intramuscular',
      site: 'الفخذ الأيسر الأمامي',
      color: '#2C3E50',
      iconEmoji: '💉',
      sideEffects: ['ألم مكان الحقن', 'احمرار'],
      contraindications: [],
      notes: 'يُعطى مع MR1 عند 9 أشهر. الحد الأقصى: 5 سنوات',
    ),

    // ──────────── عمر 9 أشهر ────────────
    Vaccine(
      id: 'mr1',
      nameAr: 'الحصبة والحصبة الألمانية (MR) - الجرعة الأولى',
      nameEn: 'Measles-Rubella (MR) Dose 1',
      description: 'الجرعة الأولى من تطعيم الحصبة والحصبة الألمانية - يحمي من مرض الحصبة الخطير والحصبة الألمانية',
      dueMonths: 9,
      doseNumber: 'الجرعة الأولى',
      route: 'subcutaneous',
      site: 'الذراع الأيمن - فوق العضلة الدالية',
      color: '#C0392B',
      iconEmoji: '🔴',
      sideEffects: ['حرارة بعد 5-12 يوم', 'طفح جلدي خفيف', 'ألم مكان الحقن'],
      contraindications: ['ضعف المناعة الشديد'],
      notes: 'تطعيم مهم جداً! الحصبة خطيرة على الأطفال. يُعطى في عمر 9 أشهر. الحرارة بعد 5-12 يوم طبيعية',
    ),
    Vaccine(
      id: 'opv4',
      nameAr: 'شلل الأطفال الفموي - الجرعة الرابعة',
      nameEn: 'OPV4 - Oral Polio Vaccine Dose 4',
      description: 'الجرعة الرابعة من تطعيم شلل الأطفال الفموي - تُعطى في عمر 9 أشهر مع تطعيم الحصبة',
      dueMonths: 9,
      doseNumber: 'الجرعة الرابعة (OPV4)',
      route: 'oral',
      site: 'عن طريق الفم',
      color: '#27AE60',
      iconEmoji: '💧',
      sideEffects: ['لا توجد آثار جانبية شائعة'],
      contraindications: ['ضعف المناعة الشديد'],
      notes: 'تُعطى مع MR1 في عمر 9 أشهر لتعزيز المناعة ضد شلل الأطفال',
    ),

    // ──────────── عمر 9 أشهر (فيتامين أ) ────────────
    Vaccine(
      id: 'vitA_1',
      nameAr: 'فيتامين أ - جرعة 9 أشهر',
      nameEn: 'Vitamin A - 100,000 IU (9 months)',
      description: 'كبسولة فيتامين أ (100,000 وحدة دولية) — الجرعة الأولى',
      dueMonths: 9,
      doseNumber: 'جرعة واحدة (كبسولة زرقاء)',
      route: 'oral',
      site: 'عن طريق الفم',
      color: '#F39C12',
      iconEmoji: '🌟',
      sideEffects: ['لا توجد آثار جانبية شائعة'],
      contraindications: [],
      notes: 'تُعطى في عمر 9 أشهر مع MR1. كبسولة زرقاء (100,000 وحدة دولية). الحد الأقصى: 5 سنوات',
    ),

    // ──────────── عمر 18 شهر ────────────
    Vaccine(
      id: 'mr2',
      nameAr: 'الحصبة والحصبة الألمانية (MR) - الجرعة الثانية',
      nameEn: 'Measles-Rubella (MR) Dose 2',
      description: 'الجرعة الثانية من تطعيم الحصبة والحصبة الألمانية - تكمل الحماية ضد المرضين',
      dueMonths: 18,
      doseNumber: 'الجرعة الثانية',
      route: 'subcutaneous',
      site: 'الذراع الأيمن - فوق العضلة الدالية',
      color: '#C0392B',
      iconEmoji: '🔴',
      sideEffects: ['حرارة بعد 5-12 يوم', 'ألم مفاصل خفيف (نادر)'],
      contraindications: ['ضعف المناعة الشديد'],
      notes: 'الجرعة الثانية المكتملة - حماية كاملة ضد الحصبة والحصبة الألمانية. تُعطى في عمر 18 شهر',
    ),
    Vaccine(
      id: 'penta4',
      nameAr: 'التطعيم الخماسي - الجرعة التعزيزية (Penta4)',
      nameEn: 'Pentavalent Booster (Penta4)',
      description: 'جرعة تعزيزية من التطعيم الخماسي: الدفتيريا + الكزاز + السعال الديكي + الكبد B + المستديمة النزلية',
      dueMonths: 18,
      doseNumber: 'جرعة تعزيزية',
      route: 'intramuscular',
      site: 'الذراع الأيسر',
      color: '#E67E22',
      iconEmoji: '💪',
      sideEffects: ['ألم مكان الحقن', 'حرارة'],
      contraindications: [],
      notes: 'جرعة تعزيزية مهمة. تُعطى في عمر 18 شهر مع MR2 وOPV5. الحد الأقصى: 5 سنوات',
    ),
    Vaccine(
      id: 'opv5',
      nameAr: 'شلل الأطفال الفموي - الجرعة الخامسة',
      nameEn: 'OPV5 - Oral Polio Vaccine Dose 5',
      description: 'الجرعة الخامسة من تطعيم شلل الأطفال الفموي - جرعة معززة في عمر 18 شهر',
      dueMonths: 18,
      doseNumber: 'الجرعة الخامسة (OPV5)',
      route: 'oral',
      site: 'عن طريق الفم',
      color: '#27AE60',
      iconEmoji: '💧',
      sideEffects: ['لا توجد آثار جانبية شائعة'],
      contraindications: ['ضعف المناعة الشديد'],
      notes: 'تُعطى مع Penta4 وMR2 في عمر 18 شهر لتعزيز المناعة ضد شلل الأطفال',
    ),
    Vaccine(
      id: 'vitA_3',
      nameAr: 'فيتامين أ - جرعة 18 شهر',
      nameEn: 'Vitamin A - 200,000 IU (18 months)',
      description: 'كبسولة فيتامين أ (200,000 وحدة دولية) - تُعطى مع التطعيمات في عمر 18 شهر',
      dueMonths: 18,
      doseNumber: 'جرعة واحدة (كبسولة حمراء)',
      route: 'oral',
      site: 'عن طريق الفم',
      color: '#F39C12',
      iconEmoji: '🌟',
      sideEffects: ['لا توجد آثار جانبية شائعة'],
      contraindications: [],
      notes: 'تُعطى في عمر 18 شهر مع Penta4 وMR2 وOPV5. كبسولة حمراء (200,000 وحدة دولية)',
    ),

    // ──────────── عمر 6 سنوات (عند الالتحاق بالمدرسة) ────────────
    Vaccine(
      id: 'td_school',
      nameAr: 'الكزاز والخناق (Td) - جرعة المدرسة',
      nameEn: 'Td School Entry Booster',
      description: 'جرعة تعزيزية من Td (الكزاز والخناق) عند دخول المدرسة',
      dueMonths: 72, // 6 years
      doseNumber: 'جرعة واحدة',
      route: 'intramuscular',
      site: 'الذراع الأيسر',
      color: '#E67E22',
      iconEmoji: '🏫',
      sideEffects: ['ألم مكان الحقن'],
      contraindications: [],
      notes: 'Td وليس DTP! يُعطى عند دخول المدرسة (5-7 سنوات). الحد الأقصى: 7 سنوات',
    ),
    Vaccine(
      id: 'mr_school',
      nameAr: 'الحصبة والحصبة الألمانية (MR) - جرعة المدرسة',
      nameEn: 'MR School Entry Booster',
      description: 'جرعة معززة من تطعيم الحصبة والحصبة الألمانية عند دخول المدرسة',
      dueMonths: 72,
      doseNumber: 'جرعة معززة',
      route: 'subcutaneous',
      site: 'الذراع الأيمن - فوق العضلة الدالية',
      color: '#C0392B',
      iconEmoji: '🔴',
      sideEffects: ['حرارة بعد 5-12 يوم', 'ألم مكان الحقن'],
      contraindications: ['ضعف المناعة الشديد'],
      notes: 'جرعة معززة عند دخول المدرسة لضمان المناعة ضد الحصبة والحصبة الألمانية',
    ),
    Vaccine(
      id: 'vitA_school',
      nameAr: 'فيتامين أ - جرعة 6 سنوات',
      nameEn: 'Vitamin A - 200,000 IU (6 years)',
      description: 'كبسولة فيتامين أ (200,000 وحدة دولية) - تُعطى عند دخول المدرسة',
      dueMonths: 72,
      doseNumber: 'جرعة واحدة (كبسولة حمراء)',
      route: 'oral',
      site: 'عن طريق الفم',
      color: '#F39C12',
      iconEmoji: '🌟',
      sideEffects: ['لا توجد آثار جانبية شائعة'],
      contraindications: [],
      notes: 'تُعطى عند دخول المدرسة في عمر 6 سنوات',
    ),

  ];

  // ──── المحافظات اليمنية ────────────
  static const List<String> governorates = [
    'صنعاء',
    'عدن',
    'تعز',
    'الحديدة',
    'إب',
    'ذمار',
    'عمران',
    'حجة',
    'البيضاء',
    'الجوف',
    'مأرب',
    'صعدة',
    'المحويت',
    'ريمة',
    'الضالع',
    'لحج',
    'أبين',
    'شبوة',
    'المهرة',
    'حضرموت',
    'سقطرى',
    'أرخبيل سقطرى',
  ];

  // ──── الحصول على التطعيمات حسب العمر ────────────
  List<Vaccine> getVaccinesDueAtAge(int weeks, int months) {
    return allVaccines.where((v) {
      if (v.dueMonths > 0) return months >= v.dueMonths;
      return weeks >= v.dueWeeks;
    }).toList();
  }

  List<Vaccine> getUpcomingVaccines(int weeks, int months) {
    return allVaccines.where((v) {
      if (v.dueMonths > 0) {
        return v.dueMonths > months && v.dueMonths <= months + 2;
      }
      return v.dueWeeks > weeks && v.dueWeeks <= weeks + 4;
    }).toList();
  }

  List<Vaccine> getOverdueVaccines(int weeks, int months, List<String> givenIds) {
    return allVaccines.where((v) {
      if (givenIds.contains(v.id)) return false;
      if (v.dueMonths > 0) return months >= v.dueMonths;
      return weeks >= v.dueWeeks;
    }).toList();
  }

  // ──── جدول التطعيم الكامل (مُحدّث حسب الدليل الرسمي أغسطس 2025) ────────────
  Map<String, List<Vaccine>> getFullSchedule() {
    return {
      'عند الولادة': allVaccines.where((v) => v.dueWeeks == 0).toList(),
      '6 أسابيع': allVaccines.where((v) => v.dueWeeks == 6).toList(),
      '10 أسابيع': allVaccines.where((v) => v.dueWeeks == 10).toList(),
      '14 أسبوع': allVaccines.where((v) => v.dueWeeks == 14).toList(),
      '9 أشهر': allVaccines.where((v) => v.dueMonths == 9).toList(),
      
      '18 شهر': allVaccines.where((v) => v.dueMonths == 18).toList(),
      '5-7 سنوات (دخول المدرسة)': allVaccines.where((v) => v.dueMonths == 72).toList(),
      
    };
  }

  // ──── التطعيمات المتأخرة (overdue) ────────────
  List<Vaccine> getOverdueVaccinesDetailed(int weeks, int months, List<String> givenIds) {
    return allVaccines.where((v) {
      if (givenIds.contains(v.id)) return false;
      if (v.dueMonths > 0) return months >= v.dueMonths + 2; // أكثر من شهرين تأخير
      return weeks >= v.dueWeeks + 4; // أكثر من 4 أسابيع تأخير
    }).toList();
  }

  // ──── التطعيمات المكتملة ────────────
  List<Vaccine> getCompletedVaccines(int weeks, int months, List<String> givenIds) {
    return allVaccines.where((v) {
      if (!givenIds.contains(v.id)) return false;
      return true;
    }).toList();
  }

  // ──── نسبة الإنجاز ────────────
  double getCompletionPercentage(int weeks, int months, List<String> givenIds) {
    final due = getVaccinesDueAtAge(weeks, months);
    if (due.isEmpty) return 1.0;
    final completed = due.where((v) => givenIds.contains(v.id)).length;
    return completed / due.length;
  }
}
