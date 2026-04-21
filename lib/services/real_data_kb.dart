// ══════════════════════════════════════════════════════════════════════════
//  قاعدة معرفة البيانات الحقيقية — من التقارير الرسمية 2024-2025
//  مصادر: تقارير حملات شلل الأطفال + تقارير النشاط الايصالي التكاملي
//         + بيانات التغطية + مقارنة معدل الجلسة + المستهدف المقترح 2026
// ══════════════════════════════════════════════════════════════════════════

/// ═══════════════════════════════════════════════════════════════════════
///  القسم ١: بيانات حملات شلل الأطفال
/// ═══════════════════════════════════════════════════════════════════════

class PolioCampaignData {
  final String round;
  final String period;
  final int totalVaccinated;
  final double coverageRate;
  final double wastageRate;
  final Map<String, GovPolioData> governorates;

  const PolioCampaignData({
    required this.round,
    required this.period,
    required this.totalVaccinated,
    required this.coverageRate,
    required this.wastageRate,
    required this.governorates,
  });
}

class GovPolioData {
  final String name;
  final int vaccinated;
  final double coverage;
  final String rating;

  const GovPolioData({
    required this.name,
    required this.vaccinated,
    required this.coverage,
    required this.rating,
  });
}

/// البيانات الرسمية لحملات شلل الأطفال 2024-2025
const List<PolioCampaignData> polioCampaignsData = [
  // ─── فبراير 2024 — الجولة الأولى ───
  PolioCampaignData(
    round: 'الجولة الأولى 2024',
    period: '25-27 فبراير 2024',
    totalVaccinated: 1291196,
    coverageRate: 100,
    wastageRate: 0,
    governorates: {
      'أبين': GovPolioData(name: 'أبين', vaccinated: 95975, coverage: 101, rating: 'جيدة'),
      'الحديدة': GovPolioData(name: 'الحديدة', vaccinated: 42883, coverage: 151, rating: 'ممتازة'),
      'الضالع': GovPolioData(name: 'الضالع', vaccinated: 86918, coverage: 100, rating: 'جيدة'),
      'المهرة': GovPolioData(name: 'المهرة', vaccinated: 21330, coverage: 94, rating: 'مقبولة'),
      'تعز': GovPolioData(name: 'تعز', vaccinated: 336730, coverage: 102, rating: 'جيدة'),
      'حضرموت الساحل': GovPolioData(name: 'حضرموت الساحل', vaccinated: 103237, coverage: 98, rating: 'جيدة'),
      'حضرموت الوادي': GovPolioData(name: 'حضرموت الوادي', vaccinated: 76381, coverage: 90, rating: 'مقبولة'),
      'سقطرى': GovPolioData(name: 'سقطرى', vaccinated: 10805, coverage: 90, rating: 'مقبولة'),
      'شبوة': GovPolioData(name: 'شبوة', vaccinated: 112276, coverage: 93, rating: 'مقبولة'),
      'عدن': GovPolioData(name: 'عدن', vaccinated: 64295, coverage: 87, rating: 'متدنية'),
      'لحج': GovPolioData(name: 'لحج', vaccinated: 130284, coverage: 99, rating: 'جيدة'),
      'مأرب': GovPolioData(name: 'مأرب', vaccinated: 72325, coverage: 95, rating: 'مقبولة'),
      'حجة': GovPolioData(name: 'حجة', vaccinated: 55765, coverage: 89, rating: 'متدنية'),
      'البيضاء': GovPolioData(name: 'البيضاء', vaccinated: 18855, coverage: 82, rating: 'متدنية'),
      'الجوف': GovPolioData(name: 'الجوف', vaccinated: 13904, coverage: 79, rating: 'متدنية'),
    },
  ),

  // ─── يوليو 2024 — الجولة الثانية ───
  PolioCampaignData(
    round: 'الجولة الثانية 2024',
    period: '15-17 يوليو 2024',
    totalVaccinated: 1342025,
    coverageRate: 102,
    wastageRate: 0,
    governorates: {
      'أبين': GovPolioData(name: 'أبين', vaccinated: 95293, coverage: 99, rating: 'جيدة'),
      'الحديدة': GovPolioData(name: 'الحديدة', vaccinated: 47537, coverage: 117, rating: 'ممتازة'),
      'الضالع': GovPolioData(name: 'الضالع', vaccinated: 91904, coverage: 103, rating: 'جيدة'),
      'المهرة': GovPolioData(name: 'المهرة', vaccinated: 20728, coverage: 95, rating: 'مقبولة'),
      'تعز': GovPolioData(name: 'تعز', vaccinated: 347155, coverage: 106, rating: 'جيدة'),
      'حضرموت الساحل': GovPolioData(name: 'حضرموت الساحل', vaccinated: 105387, coverage: 99, rating: 'جيدة'),
      'حضرموت الوادي': GovPolioData(name: 'حضرموت الوادي', vaccinated: 82010, coverage: 95, rating: 'مقبولة'),
      'سقطرى': GovPolioData(name: 'سقطرى', vaccinated: 11186, coverage: 96, rating: 'مقبولة'),
      'شبوة': GovPolioData(name: 'شبوة', vaccinated: 112131, coverage: 93, rating: 'مقبولة'),
      'عدن': GovPolioData(name: 'عدن', vaccinated: 63909, coverage: 87, rating: 'متدنية'),
      'لحج': GovPolioData(name: 'لحج', vaccinated: 137000, coverage: 104, rating: 'جيدة'),
      'مأرب': GovPolioData(name: 'مأرب', vaccinated: 74313, coverage: 98, rating: 'جيدة'),
      'حجة': GovPolioData(name: 'حجة', vaccinated: 60261, coverage: 96, rating: 'مقبولة'),
      'البيضاء': GovPolioData(name: 'البيضاء', vaccinated: 19320, coverage: 84, rating: 'متدنية'),
      'الجوف': GovPolioData(name: 'الجوف', vaccinated: 14145, coverage: 80, rating: 'متدنية'),
    },
  ),

  // ─── يوليو 2025 — الجولة الأولى ───
  PolioCampaignData(
    round: 'الجولة الأولى 2025',
    period: '12-14 يوليو 2025',
    totalVaccinated: 1401786,
    coverageRate: 104,
    wastageRate: 11,
    governorates: {
      'أبين': GovPolioData(name: 'أبين', vaccinated: 98264, coverage: 100, rating: 'ممتازة'),
      'الحديدة': GovPolioData(name: 'الحديدة', vaccinated: 51184, coverage: 123, rating: 'ممتازة'),
      'الضالع': GovPolioData(name: 'الضالع', vaccinated: 97408, coverage: 105, rating: 'ممتازة'),
      'المهرة': GovPolioData(name: 'المهرة', vaccinated: 20517, coverage: 91, rating: 'مقبولة'),
      'تعز': GovPolioData(name: 'تعز', vaccinated: 358991, coverage: 107, rating: 'ممتازة'),
      'حضرموت الساحل': GovPolioData(name: 'حضرموت الساحل', vaccinated: 108325, coverage: 98, rating: 'جيدة'),
      'حضرموت الوادي': GovPolioData(name: 'حضرموت الوادي', vaccinated: 83842, coverage: 95, rating: 'مقبولة'),
      'سقطرى': GovPolioData(name: 'سقطرى', vaccinated: 11465, coverage: 93, rating: 'مقبولة'),
      'شبوة': GovPolioData(name: 'شبوة', vaccinated: 113755, coverage: 95, rating: 'مقبولة'),
      'عدن': GovPolioData(name: 'عدن', vaccinated: 67043, coverage: 91, rating: 'مقبولة'),
      'لحج': GovPolioData(name: 'لحج', vaccinated: 140650, coverage: 107, rating: 'ممتازة'),
      'مأرب': GovPolioData(name: 'مأرب', vaccinated: 76704, coverage: 101, rating: 'جيدة'),
      'حجة': GovPolioData(name: 'حجة', vaccinated: 63806, coverage: 102, rating: 'جيدة'),
      'البيضاء': GovPolioData(name: 'البيضاء', vaccinated: 20264, coverage: 88, rating: 'متدنية'),
      'الجوف': GovPolioData(name: 'الجوف', vaccinated: 14831, coverage: 84, rating: 'متدنية'),
    },
  ),

  // ─── سبتمبر 2025 — الجولة الثانية ───
  PolioCampaignData(
    round: 'الجولة الثانية 2025',
    period: 'سبتمبر 2025',
    totalVaccinated: 1440085,
    coverageRate: 107,
    wastageRate: 11,
    governorates: {
      'أبين': GovPolioData(name: 'أبين', vaccinated: 97374, coverage: 99, rating: 'ممتازة'),
      'الحديدة': GovPolioData(name: 'الحديدة', vaccinated: 54236, coverage: 131, rating: 'ممتازة'),
      'الضالع': GovPolioData(name: 'الضالع', vaccinated: 99418, coverage: 107, rating: 'ممتازة'),
      'المهرة': GovPolioData(name: 'المهرة', vaccinated: 21243, coverage: 94, rating: 'مقبولة'),
      'تعز': GovPolioData(name: 'تعز', vaccinated: 360398, coverage: 107, rating: 'ممتازة'),
      'حضرموت الساحل': GovPolioData(name: 'حضرموت الساحل', vaccinated: 110768, coverage: 100, rating: 'ممتازة'),
      'حضرموت الوادي': GovPolioData(name: 'حضرموت الوادي', vaccinated: 85993, coverage: 96, rating: 'جيدة'),
      'سقطرى': GovPolioData(name: 'سقطرى', vaccinated: 11723, coverage: 95, rating: 'مقبولة'),
      'شبوة': GovPolioData(name: 'شبوة', vaccinated: 116519, coverage: 97, rating: 'جيدة'),
      'عدن': GovPolioData(name: 'عدن', vaccinated: 67037, coverage: 91, rating: 'مقبولة'),
      'لحج': GovPolioData(name: 'لحج', vaccinated: 141781, coverage: 108, rating: 'ممتازة'),
      'مأرب': GovPolioData(name: 'مأرب', vaccinated: 77037, coverage: 101, rating: 'جيدة'),
      'حجة': GovPolioData(name: 'حجة', vaccinated: 64384, coverage: 103, rating: 'جيدة'),
      'البيضاء': GovPolioData(name: 'البيضاء', vaccinated: 20383, coverage: 88, rating: 'متدنية'),
      'الجوف': GovPolioData(name: 'الجوف', vaccinated: 14727, coverage: 84, rating: 'متدنية'),
    },
  ),
];

/// ═══════════════════════════════════════════════════════════════════════
///  القسم ٢: بيانات النشاط الايصالي التكاملي (5 مراحل 2025)
/// ═══════════════════════════════════════════════════════════════════════

class SIAData {
  final String phase;
  final String period;
  final int totalDistricts;
  final int totalSessions;
  final int totalWorkers;
  final Map<String, SIAGovData> governorates;

  const SIAData({
    required this.phase,
    required this.period,
    required this.totalDistricts,
    required this.totalSessions,
    required this.totalWorkers,
    required this.governorates,
  });
}

class SIAGovData {
  final String name;
  final int districts;
  final int sessions;
  final int workers;

  const SIAGovData({
    required this.name,
    required this.districts,
    required this.sessions,
    required this.workers,
  });
}

const List<SIAData> siaData = [
  SIAData(
    phase: 'المرحلة الأولى',
    period: 'أبريل-مايو 2025',
    totalDistricts: 117,
    totalSessions: 1873,
    totalWorkers: 7620,
    governorates: {
      'أبين': SIAGovData(name: 'أبين', districts: 11, sessions: 229, workers: 916),
      'البيضاء': SIAGovData(name: 'البيضاء', districts: 1, sessions: 19, workers: 76),
      'الحديدة': SIAGovData(name: 'الحديدة', districts: 2, sessions: 37, workers: 148),
      'الضالع': SIAGovData(name: 'الضالع', districts: 6, sessions: 178, workers: 712),
      'المهرة': SIAGovData(name: 'المهرة', districts: 9, sessions: 58, workers: 232),
      'تعز': SIAGovData(name: 'تعز', districts: 17, sessions: 387, workers: 1548),
      'المكلا': SIAGovData(name: 'المكلا', districts: 12, sessions: 142, workers: 568),
      'سيئون': SIAGovData(name: 'سيئون', districts: 10, sessions: 114, workers: 456),
      'سقطرى': SIAGovData(name: 'سقطرى', districts: 2, sessions: 20, workers: 80),
      'شبوة': SIAGovData(name: 'شبوة', districts: 17, sessions: 236, workers: 944),
      'لحج': SIAGovData(name: 'لحج', districts: 15, sessions: 256, workers: 1024),
      'مأرب': SIAGovData(name: 'مأرب', districts: 5, sessions: 167, workers: 668),
      'عدن': SIAGovData(name: 'عدن', districts: 8, sessions: 0, workers: 128),
      'حجة': SIAGovData(name: 'حجة', districts: 1, sessions: 20, workers: 80),
      'الجوف': SIAGovData(name: 'الجوف', districts: 1, sessions: 10, workers: 40),
    },
  ),
  SIAData(
    phase: 'المرحلة الثانية',
    period: 'يونيو-يوليو 2025',
    totalDistricts: 121,
    totalSessions: 2164,
    totalWorkers: 8802,
    governorates: {
      'أبين': SIAGovData(name: 'أبين', districts: 11, sessions: 258, workers: 1032),
      'البيضاء': SIAGovData(name: 'البيضاء', districts: 2, sessions: 27, workers: 108),
      'الحديدة': SIAGovData(name: 'الحديدة', districts: 2, sessions: 42, workers: 168),
      'الضالع': SIAGovData(name: 'الضالع', districts: 6, sessions: 216, workers: 864),
      'المهرة': SIAGovData(name: 'المهرة', districts: 9, sessions: 66, workers: 264),
      'تعز': SIAGovData(name: 'تعز', districts: 17, sessions: 441, workers: 1764),
      'المكلا': SIAGovData(name: 'المكلا', districts: 12, sessions: 155, workers: 620),
      'سيئون': SIAGovData(name: 'سيئون', districts: 11, sessions: 122, workers: 488),
      'سقطرى': SIAGovData(name: 'سقطرى', districts: 2, sessions: 21, workers: 84),
      'شبوة': SIAGovData(name: 'شبوة', districts: 17, sessions: 262, workers: 1048),
      'لحج': SIAGovData(name: 'لحج', districts: 15, sessions: 286, workers: 1144),
      'مأرب': SIAGovData(name: 'مأرب', districts: 5, sessions: 197, workers: 788),
      'عدن': SIAGovData(name: 'عدن', districts: 8, sessions: 0, workers: 146),
      'حجة': SIAGovData(name: 'حجة', districts: 4, sessions: 53, workers: 212),
      'الجوف': SIAGovData(name: 'الجوف', districts: 1, sessions: 18, workers: 72),
    },
  ),
  SIAData(
    phase: 'المرحلة الثالثة',
    period: 'سبتمبر 2025',
    totalDistricts: 121,
    totalSessions: 2114,
    totalWorkers: 8602,
    governorates: {
      'أبين': SIAGovData(name: 'أبين', districts: 11, sessions: 247, workers: 988),
      'البيضاء': SIAGovData(name: 'البيضاء', districts: 2, sessions: 25, workers: 100),
      'الحديدة': SIAGovData(name: 'الحديدة', districts: 2, sessions: 42, workers: 168),
      'الضالع': SIAGovData(name: 'الضالع', districts: 6, sessions: 211, workers: 844),
      'المهرة': SIAGovData(name: 'المهرة', districts: 9, sessions: 65, workers: 260),
      'تعز': SIAGovData(name: 'تعز', districts: 17, sessions: 436, workers: 1744),
      'المكلا': SIAGovData(name: 'المكلا', districts: 12, sessions: 148, workers: 592),
      'سيئون': SIAGovData(name: 'سيئون', districts: 10, sessions: 117, workers: 468),
      'سقطرى': SIAGovData(name: 'سقطرى', districts: 2, sessions: 20, workers: 80),
      'شبوة': SIAGovData(name: 'شبوة', districts: 17, sessions: 257, workers: 1028),
      'لحج': SIAGovData(name: 'لحج', districts: 15, sessions: 279, workers: 1116),
      'مأرب': SIAGovData(name: 'مأرب', districts: 5, sessions: 196, workers: 784),
      'عدن': SIAGovData(name: 'عدن', districts: 8, sessions: 0, workers: 146),
      'حجة': SIAGovData(name: 'حجة', districts: 4, sessions: 53, workers: 212),
      'الجوف': SIAGovData(name: 'الجوف', districts: 1, sessions: 18, workers: 72),
    },
  ),
  SIAData(
    phase: 'المرحلة الرابعة',
    period: 'نوفمبر 2025',
    totalDistricts: 121,
    totalSessions: 2171,
    totalWorkers: 8538,
    governorates: {
      'أبين': SIAGovData(name: 'أبين', districts: 11, sessions: 245, workers: 980),
      'البيضاء': SIAGovData(name: 'البيضاء', districts: 2, sessions: 27, workers: 108),
      'الحديدة': SIAGovData(name: 'الحديدة', districts: 2, sessions: 42, workers: 168),
      'الضالع': SIAGovData(name: 'الضالع', districts: 6, sessions: 211, workers: 844),
      'المهرة': SIAGovData(name: 'المهرة', districts: 9, sessions: 64, workers: 256),
      'تعز': SIAGovData(name: 'تعز', districts: 17, sessions: 432, workers: 1728),
      'المكلا': SIAGovData(name: 'المكلا', districts: 12, sessions: 148, workers: 592),
      'سيئون': SIAGovData(name: 'سيئون', districts: 10, sessions: 119, workers: 476),
      'سقطرى': SIAGovData(name: 'سقطرى', districts: 2, sessions: 20, workers: 80),
      'شبوة': SIAGovData(name: 'شبوة', districts: 17, sessions: 254, workers: 1016),
      'لحج': SIAGovData(name: 'لحج', districts: 15, sessions: 273, workers: 1092),
      'مأرب': SIAGovData(name: 'مأرب', districts: 5, sessions: 194, workers: 776),
      'عدن': SIAGovData(name: 'عدن', districts: 8, sessions: 73, workers: 146),
      'حجة': SIAGovData(name: 'حجة', districts: 4, sessions: 53, workers: 212),
      'الجوف': SIAGovData(name: 'الجوف', districts: 1, sessions: 16, workers: 64),
    },
  ),
  SIAData(
    phase: 'المرحلة الخامسة',
    period: 'ديسمبر 2025',
    totalDistricts: 121,
    totalSessions: 2171,
    totalWorkers: 8538,
    governorates: {
      'أبين': SIAGovData(name: 'أبين', districts: 11, sessions: 245, workers: 980),
      'البيضاء': SIAGovData(name: 'البيضاء', districts: 2, sessions: 27, workers: 108),
      'الحديدة': SIAGovData(name: 'الحديدة', districts: 2, sessions: 42, workers: 168),
      'الضالع': SIAGovData(name: 'الضالع', districts: 6, sessions: 211, workers: 844),
      'المهرة': SIAGovData(name: 'المهرة', districts: 9, sessions: 64, workers: 256),
      'تعز': SIAGovData(name: 'تعز', districts: 17, sessions: 432, workers: 1728),
      'المكلا': SIAGovData(name: 'المكلا', districts: 12, sessions: 148, workers: 592),
      'سيئون': SIAGovData(name: 'سيئون', districts: 10, sessions: 119, workers: 476),
      'سقطرى': SIAGovData(name: 'سقطرى', districts: 2, sessions: 20, workers: 80),
      'شبوة': SIAGovData(name: 'شبوة', districts: 17, sessions: 254, workers: 1016),
      'لحج': SIAGovData(name: 'لحج', districts: 15, sessions: 273, workers: 1092),
      'مأرب': SIAGovData(name: 'مأرب', districts: 5, sessions: 194, workers: 776),
      'عدن': SIAGovData(name: 'عدن', districts: 8, sessions: 73, workers: 146),
      'حجة': SIAGovData(name: 'حجة', districts: 4, sessions: 53, workers: 212),
      'الجوف': SIAGovData(name: 'الجوف', districts: 1, sessions: 16, workers: 64),
    },
  ),
];

/// ═══════════════════════════════════════════════════════════════════════
///  القسم ٣: بيانات التغطية الشهرية 2025 (من DHIS2)
/// ═══════════════════════════════════════════════════════════════════════

class CoverageData {
  final String governorate;
  final String district;
  final double mr1Coverage;
  final double penta1Coverage;
  final double penta3Coverage;

  const CoverageData({
    required this.governorate,
    required this.district,
    required this.mr1Coverage,
    required this.penta1Coverage,
    required this.penta3Coverage,
  });
}

/// بيانات التغطية حتى ديسمبر 2025 — إجمالي المحافظات
const List<CoverageData> coverageByGov = [
  CoverageData(governorate: 'أبين', district: 'الإجمالي', mr1Coverage: 93, penta1Coverage: 100.7, penta3Coverage: 93.2),
  CoverageData(governorate: 'عدن', district: 'الإجمالي', mr1Coverage: 87, penta1Coverage: 97.7, penta3Coverage: 87.8),
  CoverageData(governorate: 'المكلا', district: 'الإجمالي', mr1Coverage: 68, penta1Coverage: 82.2, penta3Coverage: 79.2),
  CoverageData(governorate: 'الضالع', district: 'الإجمالي', mr1Coverage: 85, penta1Coverage: 97.8, penta3Coverage: 86.5),
  CoverageData(governorate: 'لحج', district: 'الإجمالي', mr1Coverage: 84, penta1Coverage: 95.5, penta3Coverage: 82.7),
  CoverageData(governorate: 'شبوة', district: 'الإجمالي', mr1Coverage: 82, penta1Coverage: 92.1, penta3Coverage: 82.2),
  CoverageData(governorate: 'مأرب', district: 'الإجمالي', mr1Coverage: 78, penta1Coverage: 94.5, penta3Coverage: 82.4),
  CoverageData(governorate: 'تعز', district: 'الإجمالي', mr1Coverage: 82, penta1Coverage: 95.3, penta3Coverage: 85),
];

/// ═══════════════════════════════════════════════════════════════════════
///  القسم ٤: قاعدة المعرفة النصية المشتقة من البيانات الحقيقية
/// ═══════════════════════════════════════════════════════════════════════

const Map<String, String> realDataKnowledgeBase = {

  // ─── تحليل حملات شلل الأطفال ───
  'ملخص حملات شلل الأطفال':
      '📊 ملخص حملات التطعيم ضد شلل الأطفال 2024-2025:\n\n'
      '━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n'
      '📅 فبراير 2024 (الجولة الأولى):\n'
      '   • إجمالي المطعمين: 1,291,196 طفل\n'
      '   • التغطية العامة: 100%\n\n'
      '📅 يوليو 2024 (الجولة الثانية):\n'
      '   • إجمالي المطعمين: 1,342,025 طفل\n'
      '   • التغطية العامة: 102%\n\n'
      '📅 يوليو 2025 (الجولة الأولى):\n'
      '   • إجمالي المطعمين: 1,401,786 طفل\n'
      '   • التغطية العامة: 104%\n'
      '   • الأطفال المستهدفون: 1,345,317\n'
      '   • عدد الفرق: 6,924 (845 ثابتة + 6,079 متحركة)\n'
      '   • إجمالي العاملين: 13,003\n'
      '   • نسبة التلف للقاح: 11%\n\n'
      '📅 سبتمبر 2025 (الجولة الثانية):\n'
      '   • إجمالي المطعمين: 1,440,085 طفل\n'
      '   • التغطية العامة: 107%\n'
      '   • نسبة التلف للقاح: 11%\n\n'
      '📈 الاتجاه العام: تحسن مستمر في أعداد المطعمين ونسب التغطية من 2024 إلى 2025',

  'أفضل المحافظات تغطية شلل':
      '🏆 أفضل المحافظات في تغطية حملات شلل الأطفال:\n\n'
      '━━━━ الجولة الثانية سبتمبر 2025 ━━━━\n'
      '🥇 الحديدة: 131% — أداء ممتاز جداً\n'
      '🥈 لحج: 108% — أداء ممتاز\n'
      '🥉 تعز: 107% — أداء ممتاز\n'
      '4️⃣ الضالع: 107% — أداء ممتاز\n'
      '5️⃣ حجة: 103% — أداء جيد\n'
      '6️⃣ مأرب: 101% — أداء جيد\n'
      '7️⃣ حضرموت الساحل: 100% — أداء ممتاز\n\n'
      '📌 ملاحظة: تعز تساهم بأكبر عدد من المطعمين (360,398 طفل)',

  'أضعف المحافظات تغطية شلل':
      '⚠️ المحافظات التي تحتاج تحسين في تغطية شلل الأطفال:\n\n'
      '━━━━ الجولة الثانية سبتمبر 2025 ━━━━\n'
      '❌ البيضاء: 88% — أقل من الحد الأدنى (95%)\n'
      '❌ الجوف: 84% — أقل من الحد الأدنى\n'
      '❌ عدن: 91% — أقل من الحد الأدنى\n'
      '⚠️ المهرة: 94% — قريبة لكن تحت الحد\n'
      '⚠️ سقطرى: 95% — على الحد الأدنى\n\n'
      '📌 الأسباب المحتملة:\n'
      '• صعوبة الوصول في البيضاء والجوف\n'
      '• أعداد السكان النازحين\n'
      '• ضعف البنية التحتية الصحية\n'
      '• مقاومة مجتمعية في بعض المناطق\n\n'
      '💡 التوصية: تركيز الجهود والتدخلات على هذه المحافظات',

  'مقارنة تغطية شلل بين الجولات':
      '📊 مقارنة تغطية حملات شلل الأطفال بين الجولات:\n\n'
      '┌─────────────┬──────────┬──────────┬──────────┬──────────┐\n'
      '│ المحافظة     │ فبراير   │ يوليو    │ يوليو    │ سبتمبر   │\n'
      '│             │ 2024     │ 2024     │ 2025     │ 2025     │\n'
      '├─────────────┼──────────┼──────────┼──────────┼──────────┤\n'
      '│ أبين         │ 101%     │ 99%      │ 100%     │ 99%      │\n'
      '│ الحديدة      │ 151%     │ 117%     │ 123%     │ 131%     │\n'
      '│ الضالع       │ 100%     │ 103%     │ 105%     │ 107%     │\n'
      '│ المهرة       │ 94%      │ 95%      │ 91%      │ 94%      │\n'
      '│ تعز          │ 102%     │ 106%     │ 107%     │ 107%     │\n'
      '│ عدن          │ 87%      │ 87%      │ 91%      │ 91%      │\n'
      '│ البيضاء      │ 82%      │ 84%      │ 88%      │ 88%      │\n'
      '│ الجوف        │ 79%      │ 80%      │ 84%      │ 84%      │\n'
      '└─────────────┴──────────┴──────────┴──────────┴──────────┘\n\n'
      '📈 الاتجاهات:\n'
      '• الحديدة: ارتفاع ملحوظ من 117% إلى 131%\n'
      '• الضالع: تحسن تدريجي من 100% إلى 107%\n'
      '• البيضاء والجوف: تحسن بطيء لكن لا يزال تحت 95%\n'
      '• عدن: تحسن طفيف من 87% إلى 91%',

  // ─── تحليل النشاط الايصالي التكاملي ───
  'ملخص النشاط الايصالي':
      '📊 ملخص النشاط الايصالي التكاملي 2025:\n\n'
      '━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n'
      'المرحلة الأولى (أبريل-مايو 2025):\n'
      '   • المديريات: 117 | الجلسات: 1,873 | العاملين: 7,620\n\n'
      'المرحلة الثانية (يونيو-يوليو 2025):\n'
      '   • المديريات: 121 | الجلسات: 2,164 | العاملين: 8,802\n\n'
      'المرحلة الثالثة (سبتمبر 2025):\n'
      '   • المديريات: 121 | الجلسات: 2,114 | العاملين: 8,602\n\n'
      'المرحلة الرابعة (نوفمبر 2025):\n'
      '   • المديريات: 121 | الجلسات: 2,171 | العاملين: 8,538\n\n'
      'المرحلة الخامسة (ديسمبر 2025):\n'
      '   • المديريات: 121 | الجلسات: 2,171 | العاملين: 8,538\n\n'
      '📈 التحليل:\n'
      '• ارتفاع عدد الجلسات من 1,873 إلى 2,171 (+16%)\n'
      '• استقرار العاملين عند ~8,500 في المراحل الأخيرة\n'
      '• تعز تتصدر بعدد الجلسات الأعلى (~432 جلسة)\n'
      '• البرنامج مستمر منذ 2008 ويتوسع سنوياً',

  'معدل الجلسة في النشاط الايصالي':
      '📊 معدل الجلسة في النشاط الايصالي التكاملي:\n\n'
      '📌 ما هو معدل الجلسة؟\n'
      'هو متوسط عدد الأطفال المطعمين في الجلسة الواحدة.\n\n'
      '━━━━ مقارنة معدل الجلسة بين المراحل ━━━━\n'
      'المرحلة الأولى: معدل جلسة ~29 طفل/جلسة\n'
      'المرحلة الثانية: معدل جلسة ~32 طفل/جلسة\n'
      'المرحلة الثالثة: معدل جلسة ~30 طفل/جلسة\n'
      'المرحلة الرابعة: معدل جلسة ~30 طفل/جلسة\n'
      'المرحلة الخامسة: معدل جلسة ~30 طفل/جلسة\n\n'
      '━━━━ تباين معدل الجلسة حسب المحافظة ━━━━\n'
      '• تعز: أعلى معدل (40+ طفل/جلسة)\n'
      '• الضالع: معدل مرتفع (35-40)\n'
      '• المهرة: أقل معدل (7-15 طفل/جلسة)\n'
      '• سقطرى: معدل منخفض (4-6 طفل/جلسة)\n\n'
      '💡 معدل الجلسة يعكس كثافة السكان وكفاءة التخطيط',

  // ─── بيانات التغطية الشهرية ───
  'ملخص التغطية 2025':
      '📊 ملخص التغطية التطعيمية حتى ديسمبر 2025:\n\n'
      '━━━━ المؤشرات الرئيسية ━━━━\n'
      '💉 MR1 (الحصبة الأولى تحت سنة):\n'
      '   • أعلى تغطية: أبين 93%\n'
      '   • أدنى تغطية: المكلا 68%\n'
      '   • المتوسط الوطني: ~82%\n\n'
      '💉 Penta1 (الخماسي الأولى تحت سنة):\n'
      '   • أعلى تغطية: أبين 100.7%\n'
      '   • أدنى تغطية: المكلا 82.2%\n'
      '   • المتوسط الوطني: ~94%\n\n'
      '💉 Penta3 (الخماسي الثالثة تحت سنة):\n'
      '   • أعلى تغطية: أبين 93.2%\n'
      '   • أدنى تغطية: المكلا 79.2%\n'
      '   • المتوسط الوطني: ~85%\n\n'
      '📌 الفجوة بين Penta1 و Penta3:\n'
      '   • التسرب = Penta1 - Penta3\n'
      '   • المتوسط: ~9% (الهدف: أقل من 10%)\n'
      '   • المكلا: 3% فقط — ممتاز\n'
      '   • عدن: 9.9% — يحتاج تحسين',

  'تغطية المكلا 2025':
      '📊 تحليل تغطية المكلا (حضرموت الساحل) 2025:\n\n'
      '⚠️ المكلا تعاني من تدني التغطية!\n\n'
      '💉 MR1: 68% — أقل من الحد الأدنى (90%)\n'
      '💉 Penta1: 82.2% — أقل من الحد الأدنى\n'
      '💉 Penta3: 79.2% — أقل من الحد الأدنى\n\n'
      '📍 تفصيل المديريات:\n'
      '   • الشحر: MR1 = 56% (الأدنى!)\n'
      '   • المكلا المدينة: MR1 = 67%\n'
      '   • الديس: MR1 = 70%\n'
      '   • بروم ميفع: MR1 = 70%\n'
      '   • الريدة وقصيعر: MR1 = 83%\n'
      '   • الضليعة: MR1 = 88%\n\n'
      '💡 التوصيات:\n'
      '   1. تكثيف التوعية في الشحر والمكلا\n'
      '   2. زيادة عدد الجلسات الثابتة\n'
      '   3. تفعيل فرق متنقلة للمناطق النائية',

  'تغطية عدن 2025':
      '📊 تحليل تغطية عدن 2025:\n\n'
      '💉 MR1: 87% — أقل من الحد الأدنى (90%)\n'
      '💉 Penta1: 97.7% — جيدة\n'
      '💉 Penta3: 87.8% — أقل من الحد الأدنى\n\n'
      '📍 تفصيل المديريات:\n'
      '   • البريقة: MR1 = 107% — ممتاز\n'
      '   • التواهي: MR1 = 93% — جيدة\n'
      '   • كريتر: MR1 = 92% — جيدة\n'
      '   • الشيخ عثمان: MR1 = 91% — جيدة\n'
      '   • دار سعد: MR1 = 83% — متدنية\n'
      '   • المنصورة: MR1 = 83% — متدنية\n'
      '   • خور مكسر: MR1 = 73% — متدنية\n'
      '   • المعلا: MR1 = 63% — الأدنى!\n\n'
      '📌 الفجوة:\n'
      '   • Penta1 - Penta3 = 9.9% (فوق الحد)\n'
      '   • المعلا وخور مكسر يحتاجان تدخل عاجل\n'
      '   • البريقة نموذج ممتاز يمكن تعميمه',

  // ─── تحليل الاتجاهات والتنبؤات ───
  'اتجاهات التغطية':
      '📈 اتجاهات التغطية التطعيمية في اليمن:\n\n'
      '━━━━ الاتجاهات الإيجابية ━━━━\n'
      '✅ تحسن تدريجي في تغطية حملات شلل الأطفال:\n'
      '   • 2024: 100-102% → 2025: 104-107%\n'
      '✅ زيادة أعداد المطعمين:\n'
      '   • 1,291,196 (فبراير 2024) → 1,440,085 (سبتمبر 2025)\n'
      '   • زيادة بنسبة 11.5%\n'
      '✅ استقرار النشاط الايصالي عند ~2,171 جلسة\n\n'
      '━━━━ التحديات ━━━━\n'
      '⚠️ تدني تغطية MR1 في بعض المحافظات:\n'
      '   • المكلا: 68% — أقل بكثير من الهدف (90%)\n'
      '   • مأرب: 78%\n'
      '   • شبوة: 82%\n'
      '⚠️ فجوة التسرب (Penta1 → Penta3) لا تزال مرتفعة\n'
      '⚠️ المحافظات الشمالية (البيضاء، الجوف) تحت 88%\n\n'
      '🔮 التوقعات لـ 2026:\n'
      '   • استمرار تحسن التغطية بنسبة 2-5% سنوياً\n'
      '   • الحاجة لتركيز الجهود على المحافظات المتدنية\n'
      '   • زيادة عدد الجلسات في المناطق النائية',

  'تنبؤات 2026':
      '🔮 التنبؤات والتوقعات لبرنامج التحصين 2026:\n\n'
      '━━━━ التوقعات المبنية على البيانات ━━━━\n\n'
      '📊 حملات شلل الأطفال:\n'
      '   • نتوقع تغطية 108-112% في الجولات القادمة\n'
      '   • استمرار تحسن الأعداد المستهدفة\n'
      '   • التركيز على المحافظات المتدنية (البيضاء، الجوف، عدن)\n\n'
      '📊 التغطية الروتينية:\n'
      '   • MR1: نتوقع تحسن من 82% إلى 85-88%\n'
      '   • Penta3: نتوقع تحسن من 85% إلى 88-90%\n'
      '   • الفجوة بين Penta1 و Penta3: انخفاض تدريجي\n\n'
      '📊 النشاط الايصالي:\n'
      '   • استمرار عند 2,171+ جلسة لكل مرحلة\n'
      '   • توسع جغرافي ليشمل محافظات إضافية\n'
      '   • تحسن معدل الجلسة في المحافظات المنخفضة\n\n'
      '💡 التوصيات الاستراتيجية:\n'
      '   1. أولوية قصوى للمكلا والشحر\n'
      '   2. زيادة التثقيف في البيضاء والجوف\n'
      '   3. تعزيز الإشراف الداعم في عدن\n'
      '   4. توسيع نطاق الفرق المتنقلة',

  // ─── مقارنات بين المحافظات ───
  'مقارنة تعز والحديدة':
      '📊 مقارنة بين تعز والحديدة في حملات شلل الأطفال:\n\n'
      '━━━━ تعز ━━━━\n'
      '• أكبر مساهم بأعداد المطعمين\n'
      '• سبتمبر 2025: 360,398 طفل (107% تغطية)\n'
      '• اتجاه تصاعدي: 336,730 → 347,155 → 358,991 → 360,398\n'
      '• تحسن مستمر ومستقر\n\n'
      '━━━━ الحديدة ━━━━\n'
      '• أعلى نسبة تغطية على الإطلاق\n'
      '• سبتمبر 2025: 54,236 طفل (131% تغطية)\n'
      '• تغطية مرتفعة جداً تتجاوز المستهدف\n'
      '• السبب المحتمل: تقدير منخفض للمستهدف أو نازحين\n\n'
      '📌 الفرق الرئيسي:\n'
      '• تعز: حجم كبير + تغطية ممتازة = المحافظة الأهم\n'
      '• الحديدة: تغطية فائقة = تحتاج مراجعة المستهدفين',

  'محافظات تحتاج تدخل':
      '🚨 المحافظات التي تحتاج تدخل عاجل:\n\n'
      '━━━━ الأولوية القصوى ━━━━\n'
      '1️⃣ البيضاء:\n'
      '   • تغطية شلل: 88% (أقل من 95%)\n'
      '   • تغطية روتينية محدودة\n'
      '   • عدد مديريات نشطة: 2 فقط\n'
      '   • السبب: صعوبة الوصول + النزاع\n\n'
      '2️⃣ الجوف:\n'
      '   • تغطية شلل: 84% (أقل من 95%)\n'
      '   • مديرية واحدة نشطة فقط\n'
      '   • السبب: انعدام الأمن + نقص الكوادر\n\n'
      '3️⃣ المكلا:\n'
      '   • MR1: 68% (أقل من 90% بكثير)\n'
      '   • الشحر: 56% فقط!\n'
      '   • السبب: ضعف التوعية + نقص الجلسات\n\n'
      '━━━━ الأولوية المتوسطة ━━━━\n'
      '4️⃣ عدن:\n'
      '   • MR1: 87% — المعلا 63%!\n'
      '   • فجوة تسرب 9.9%\n\n'
      '5️⃣ المهرة:\n'
      '   • تغطية شلل: 94% (قريبة لكن تحت 95%)\n'
      '   • معدل جلسة منخفض جداً (7-15)',

  // ─── مؤشرات الأداء الرئيسية ───
  'KPI التحصين 2025':
      '📊 مؤشرات الأداء الرئيسية (KPIs) للتحصين 2025:\n\n'
      '━━━━ مؤشرات حملات شلل الأطفال ━━━━\n'
      '✅ التغطية الوطنية: 107% (الهدف: ≥95%)\n'
      '✅ إجمالي المطعمين: 1,440,085\n'
      '⚠️ نسبة التلف: 11% (الهدف: ≤10%)\n'
      '❌ محافظات تحت 95%: 4 (البيضاء، الجوف، عدن، المهرة)\n\n'
      '━━━━ مؤشرات التغطية الروتينية ━━━━\n'
      '✅ Penta1 الوطني: ~94% (الهدف: ≥90%)\n'
      '⚠️ MR1 الوطني: ~82% (الهدف: ≥90%) — فجوة!\n'
      '⚠️ Penta3 الوطني: ~85% (الهدف: ≥90%) — فجوة!\n'
      '⚠️ فجوة التسرب Penta1→Penta3: ~9% (الهدف: <10%)\n\n'
      '━━━━ مؤشرات النشاط الايصالي ━━━━\n'
      '✅ عدد الجلسات: 2,171 (مستقر)\n'
      '✅ عدد العاملين: 8,538\n'
      '✅ المديريات المغطاة: 121\n'
      '⚠️ معدل الجلسة متباين: 4-54 طفل/جلسة',

  'فجوة التسرب':
      '📊 تحليل فجوة التسرب (Drop-out Rate) في التحصين:\n\n'
      '📌 ما هي فجوة التسرب؟\n'
      'هي الفرق بين عدد الأطفال الذين بدأوا التطعيم وأكملوه.\n\n'
      '━━━━ التحليل الوطني ━━━━\n'
      '• Penta1 → Penta3 فجوة: ~9%\n'
      '• Penta1 → MR1 فجوة: ~12%\n'
      '• الهدف: فجوة أقل من 10%\n\n'
      '━━━━ المحافظات الأعلى تسرباً ━━━━\n'
      '❌ عدن: فجوة Penta1→Penta3 = 9.9%\n'
      '⚠️ أبين: فجوة = 7.5%\n'
      '⚠️ الضالع: فجوة = 11.3%\n\n'
      '━━━━ المحافظات الأقل تسرباً ━━━━\n'
      '✅ المكلا: فجوة = 3% فقط\n'
      '✅ شبوة: فجوة = 9.9%\n\n'
      '💡 أسباب التسرب:\n'
      '• بُعد المراكز الصحية\n'
      '• نقص التوعية بأهمية إكمال التطعيم\n'
      '• الآثار الجانبية التي تخيف الأهالي\n'
      '• النزوح والنزاعات\n\n'
      '📋 استراتيجيات الحد من التسرب:\n'
      '1. تتبع المتخلفين (Defaulter Tracing)\n'
      '2. تذكيرات عبر الرسائل\n'
      '3. فرق بحث عن المتخلفين\n'
      '4. تثقيف مكثف عن أهمية إكمال الجرعات',
};
