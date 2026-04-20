import 'package:flutter/material.dart';
import '../models/vaccine_model.dart';

class VaccinationService extends ChangeNotifier {
  // ══════════════════════════════════════════════════════════════
  // اليمن - برنامج التحصين الصحي الموسع (EPI)
  // الجدول الكامل للتطعيمات حسب الدليل الرسمي أغسطس 2025
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
      contraindications: ['ضعف المناعة الشديد', 'ال hatırla المرضية الشديدة'],
      notes: 'يُعطى عند الولادة أو في أقرب فرصة. العلامة الطبيعية (التندب) تظهر بعد 6-8 أسابيع',
    ),
    Vaccine(
      id: 'hepb0',
      nameAr: 'التهاب الكبد ب - جرعة الولادة',
      nameEn: 'Hepatitis B - Birth Dose',
      description: 'الجرعة الأولى من تطعيم التهاب الكبد B - تُعطى خلال 24 ساعة من الولادة',
      dueWeeks: 0,
      doseNumber: 'جرعة الولادة',
      route: 'intramuscular',
      site: 'الفخذ الأمامي الخارجي',
      color: '#3498DB',
      iconEmoji: '💉',
      sideEffects: ['ألم بسيط مكان الحقن', 'حرارة خفيفة'],
      contraindications: ['حساسية شديدة لمكونات التطعيم'],
      notes: 'تعطى خلال أول 24 ساعة من الولادة، خاصة للأمهات الحاملات للفيروس',
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
      site: 'الفخذ الأمامي الخارجي (اليسار)',
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
      site: 'الفخذ الأمامي الخارجي (اليمين)',
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
      site: 'الفخذ الأمامي الخارجي',
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
      site: 'الفخذ الأمامي الخارجي',
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
      site: 'الفخذ الأمامي الخارجي',
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
      site: 'الفخذ الأمامي الخارجي',
      color: '#8E44AD',
      iconEmoji: '🫁',
      sideEffects: [],
      contraindications: [],
      notes: 'الجرعة الثالثة المكتملة',
    ),
    Vaccine(
      id: 'ipv',
      nameAr: 'شلل الأطفال الحقني (IPV)',
      nameEn: 'Inactivated Polio Vaccine',
      description: 'تطعيم شلل الأطفال الحقني - يُعطى جرعة واحدة مع الجرعة الثالثة من OPV',
      dueWeeks: 14,
      doseNumber: 'جرعة واحدة',
      route: 'intramuscular',
      site: 'الفخذ الأمامي الخارجي',
      color: '#2C3E50',
      iconEmoji: '💉',
      sideEffects: ['ألم مكان الحقن', 'احمرار'],
      contraindications: [],
      notes: 'يُعطى مع OPV3 لتعزيز المناعة',
    ),

    // ──────────── عمر 9 أشهر ────────────
    Vaccine(
      id: 'measles1',
      nameAr: 'الحصبة - الجرعة الأولى',
      nameEn: 'Measles Vaccine Dose 1',
      description: 'الجرعة الأولى من تطعيم الحصبة - تحمي من مرض الحصبة الخطير',
      dueMonths: 9,
      doseNumber: 'الجرعة الأولى',
      route: 'subcutaneous',
      site: 'الذراع الأيمن - فوق العضلة الدالية',
      color: '#C0392B',
      iconEmoji: '🔴',
      sideEffects: ['حرارة بعد 5-12 يوم', 'طفح جلدي خفيف', 'ألم مكان الحقن'],
      contraindications: ['ضعف المناعة الشديد', 'ال hatırla'],
      notes: 'تطعيم مهم جداً! الحصبة خطيرة على الأطفال. يُعطى في عمر 9 أشهر',
    ),

    // ──────────── عمر 12 شهر ────────────
    Vaccine(
      id: 'mmr',
      nameAr: 'الحصبة والنكاف والحصبة الألمانية (MMR)',
      nameEn: 'Measles, Mumps, Rubella (MMR)',
      description: 'الجرعة الثانية - تطعيم ثلاثي ضد الحصبة والنكاف والحصبة الألمانية',
      dueMonths: 12,
      doseNumber: 'الجرعة الثانية',
      route: 'subcutaneous',
      site: 'الذراع الأيمن',
      color: '#C0392B',
      iconEmoji: '🔴',
      sideEffects: ['حرارة بعد 5-12 يوم', 'ألم مفاصل خفيف (نادر)'],
      contraindications: ['ضعف المناعة الشديد'],
      notes: 'تُعطى بعد الحصبة الأولى بـ 3 أشهر على الأقل',
    ),

    // ──────────── عمر 18 شهر ────────────
    Vaccine(
      id: 'dtp_booster',
      nameAr: 'الخناق والكزاز والسعال الديبي (DTP) - جرعة معززة',
      nameEn: 'DTP Booster',
      description: 'جرعة معززة من التطعيم الثلاثي للخناق والكزاز والسعال الديبي',
      dueMonths: 18,
      doseNumber: 'جرعة معززة',
      route: 'intramuscular',
      site: 'الذراع الأيسر',
      color: '#E67E22',
      iconEmoji: '💪',
      sideEffects: ['ألم مكان الحقن', 'حرارة'],
      contraindications: [],
      notes: 'جرعة معززة مهمة للحفاظ على المناعة',
    ),

    // ──────────── عمر 24 شهر (⬡ متاح حسب البرنامج) ────────────
    Vaccine(
      id: 'mmr2',
      nameAr: 'الحصبة والنكاف والحصبة الألمانية - الجرعة الثانية',
      nameEn: 'MMR Dose 2',
      description: 'الجرعة الثانية من تطعيم MMR (حسب توفر التطعيم)',
      dueMonths: 24,
      doseNumber: 'الجرعة الثانية',
      route: 'subcutaneous',
      site: 'الذراع الأيمن',
      color: '#C0392B',
      iconEmoji: '🔴',
      sideEffects: [],
      contraindications: [],
      notes: 'حسب توفر التطعيم في المرفق الصحي',
    ),

    // ──────────── عمر 6 سنوات (عند الالتحاق بالمدرسة) ────────────
    Vaccine(
      id: 'dtp_school',
      nameAr: 'DTP - جرعة المدرسة',
      nameEn: 'DTP School Entry Booster',
      description: 'جرعة معززة عند دخول المدرسة',
      dueMonths: 72, // 6 years
      doseNumber: 'جرعة المدرسة',
      route: 'intramuscular',
      site: 'الذراع',
      color: '#E67E22',
      iconEmoji: '🏫',
      sideEffects: ['ألم مكان الحقن'],
      contraindications: [],
      notes: 'جرعة معززة عند دخول المدرسة',
    ),
  ];

  // ──── المحافظات اليمنية ────
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

  // ──── الحصول على التطعيمات حسب العمر ────
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

  // ──── جدول التطعيم الكامل ────
  Map<String, List<Vaccine>> getFullSchedule() {
    return {
      'عند الولادة': allVaccines.where((v) => v.dueWeeks == 0).toList(),
      '6 أسابيع': allVaccines.where((v) => v.dueWeeks == 6).toList(),
      '10 أسابيع': allVaccines.where((v) => v.dueWeeks == 10).toList(),
      '14 أسبوع': allVaccines.where((v) => v.dueWeeks == 14).toList(),
      '9 أشهر': allVaccines.where((v) => v.dueMonths == 9).toList(),
      '12 شهر': allVaccines.where((v) => v.dueMonths == 12).toList(),
      '18 شهر': allVaccines.where((v) => v.dueMonths == 18).toList(),
      '24 شهر': allVaccines.where((v) => v.dueMonths == 24).toList(),
      '6 سنوات': allVaccines.where((v) => v.dueMonths == 72).toList(),
    };
  }
}
