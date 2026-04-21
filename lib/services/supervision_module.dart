// ══════════════════════════════════════════════════════════════════════════
//  وحدة الإشراف الداعم المتقدمة — Advanced Supervision Module
//  قابلة للربط بنظام الإشراف داخل التطبيق (Supervision System)
//  تشمل: نماذج الزيارة الإشرافية، التقييم، خطة العمل، المتابعة
//  جاهزة لربط Supabase لاحقاً
// ══════════════════════════════════════════════════════════════════════════

import 'dart:convert';

/// حالة الزيارة الإشرافية
enum VisitStatus {
  planned,     // مخططة
  inProgress,  // جارية
  completed,   // مكتملة
  followUp,    // متابعة
}

/// مستوى الأداء
enum PerformanceLevel {
  excellent,  // ممتاز
  good,       // جيد
  satisfactory, // مقبول
  needsImprovement, // يحتاج تحسين
  critical,   // حرج
}

/// تصنيف الملاحظة
enum ObservationCategory {
  coldChain,       // سلسلة التبريد
  vaccineAdmin,    // إعطاء اللقاح
  recordKeeping,   // التسجيل
  wasteManagement, // إدارة النفايات
  communication,   // التواصل
  sessionPlanning, // تخطيط الجلسات
  dataQuality,     // جودة البيانات
  aefi,            // الآثار الضارة
  community,       // المجتمع
  staffing,        // الكوادر
}

/// ملاحظة إشرافية
class SupervisionObservation {
  final String id;
  final ObservationCategory category;
  final String description;
  final PerformanceLevel performance;
  final String? evidence;
  final List<String> photos; // URLs — لربط Supabase Storage
  final String recommendation;

  SupervisionObservation({
    required this.id,
    required this.category,
    required this.description,
    required this.performance,
    this.evidence,
    this.photos = const [],
    required this.recommendation,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category.name,
    'description': description,
    'performance': performance.name,
    'evidence': evidence,
    'photos': photos,
    'recommendation': recommendation,
  };

  factory SupervisionObservation.fromJson(Map<String, dynamic> json) =>
      SupervisionObservation(
        id: json['id'],
        category: ObservationCategory.values.firstWhere((e) => e.name == json['category']),
        description: json['description'],
        performance: PerformanceLevel.values.firstWhere((e) => e.name == json['performance']),
        evidence: json['evidence'],
        photos: (json['photos'] as List?)?.cast<String>() ?? [],
        recommendation: json['recommendation'],
      );
}

/// خطة عمل
class ActionPlan {
  final String id;
  final String action;
  final String responsible;
  final String deadline;
  final String status; // pending, inProgress, completed
  final String? notes;

  ActionPlan({
    required this.id,
    required this.action,
    required this.responsible,
    required this.deadline,
    this.status = 'pending',
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'action': action,
    'responsible': responsible,
    'deadline': deadline,
    'status': status,
    'notes': notes,
  };

  factory ActionPlan.fromJson(Map<String, dynamic> json) => ActionPlan(
    id: json['id'],
    action: json['action'],
    responsible: json['responsible'],
    deadline: json['deadline'],
    status: json['status'] ?? 'pending',
    notes: json['notes'],
  );
}

/// زيارة إشرافية داعمة
class SupervisionVisit {
  final String id;
  final String facilityName;
  final String governorate;
  final String district;
  final DateTime visitDate;
  final VisitStatus status;
  final String supervisorName;
  final String supervisorTitle;
  final List<SupervisionObservation> observations;
  final List<ActionPlan> actionPlans;
  final String overallPerformance;
  final String summary;
  final String? nextVisitDate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  SupervisionVisit({
    required this.id,
    required this.facilityName,
    required this.governorate,
    required this.district,
    required this.visitDate,
    this.status = VisitStatus.planned,
    required this.supervisorName,
    required this.supervisorTitle,
    this.observations = const [],
    this.actionPlans = const [],
    this.overallPerformance = '',
    this.summary = '',
    this.nextVisitDate,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// حساب مستوى الأداء العام
  PerformanceLevel calculateOverallPerformance() {
    if (observations.isEmpty) return PerformanceLevel.satisfactory;

    final scores = <PerformanceLevel, int>{};
    for (final obs in observations) {
      scores[obs.performance] = (scores[obs.performance] ?? 0) + 1;
    }

    // حساب المتوسط المرجح
    const weights = {
      PerformanceLevel.excellent: 5,
      PerformanceLevel.good: 4,
      PerformanceLevel.satisfactory: 3,
      PerformanceLevel.needsImprovement: 2,
      PerformanceLevel.critical: 1,
    };

    double totalScore = 0;
    int totalObs = 0;
    for (final entry in scores.entries) {
      totalScore += entry.value * (weights[entry.key] ?? 3);
      totalObs += entry.value;
    }

    final avg = totalScore / totalObs;
    if (avg >= 4.5) return PerformanceLevel.excellent;
    if (avg >= 3.5) return PerformanceLevel.good;
    if (avg >= 2.5) return PerformanceLevel.satisfactory;
    if (avg >= 1.5) return PerformanceLevel.needsImprovement;
    return PerformanceLevel.critical;
  }

  /// توليد التقرير
  String generateReport() {
    final buf = StringBuffer();
    final perfLevel = calculateOverallPerformance();
    final perfArabic = _performanceToArabic(perfLevel);
    final perfEmoji = _performanceToEmoji(perfLevel);

    buf.writeln('🏥 تقرير الزيارة الإشرافية الداعمة');
    buf.writeln('');
    buf.writeln('━━━━ بيانات الزيارة ━━━━');
    buf.writeln('📍 المرفق: $facilityName');
    buf.writeln('🏛️ المحافظة: $governorate | المديرية: $district');
    buf.writeln('📅 تاريخ الزيارة: ${_formatDate(visitDate)}');
    buf.writeln('👤 المشرف: $supervisorName ($supervisorTitle)');
    buf.writeln('$perfEmoji مستوى الأداء العام: $perfArabic');
    buf.writeln('');

    // الملاحظات حسب التصنيف
    buf.writeln('━━━━ الملاحظات التفصيلية ━━━━');
    final byCategory = <ObservationCategory, List<SupervisionObservation>>{};
    for (final obs in observations) {
      byCategory.putIfAbsent(obs.category, () => []).add(obs);
    }

    for (final entry in byCategory.entries) {
      buf.writeln('');
      buf.writeln('📂 ${_categoryToArabic(entry.key)}:');
      for (final obs in entry.value) {
        final emoji = _performanceToEmoji(obs.performance);
        buf.writeln('  $emoji ${obs.description}');
        if (obs.recommendation.isNotEmpty) {
          buf.writeln('     💡 التوصية: ${obs.recommendation}');
        }
      }
    }

    // خطة العمل
    if (actionPlans.isNotEmpty) {
      buf.writeln('');
      buf.writeln('━━━━ خطة العمل ━━━━');
      for (int i = 0; i < actionPlans.length; i++) {
        final plan = actionPlans[i];
        final statusEmoji = plan.status == 'completed' ? '✅' :
                           plan.status == 'inProgress' ? '🔄' : '⏳';
        buf.writeln('  ${i + 1}. $statusEmoji ${plan.action}');
        buf.writeln('     المسؤول: ${plan.responsible} | الموعد: ${plan.deadline}');
      }
    }

    // الزيارة القادمة
    if (nextVisitDate != null) {
      buf.writeln('');
      buf.writeln('📅 الزيارة القادمة: $nextVisitDate');
    }

    return buf.toString();
  }

  /// تحويل لـ JSON — جاهز لـ Supabase
  Map<String, dynamic> toJson() => {
    'id': id,
    'facility_name': facilityName,
    'governorate': governorate,
    'district': district,
    'visit_date': visitDate.toIso8601String(),
    'status': status.name,
    'supervisor_name': supervisorName,
    'supervisor_title': supervisorTitle,
    'observations': observations.map((o) => o.toJson()).toList(),
    'action_plans': actionPlans.map((a) => a.toJson()).toList(),
    'overall_performance': overallPerformance,
    'summary': summary,
    'next_visit_date': nextVisitDate,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };

  factory SupervisionVisit.fromJson(Map<String, dynamic> json) => SupervisionVisit(
    id: json['id'],
    facilityName: json['facility_name'],
    governorate: json['governorate'],
    district: json['district'],
    visitDate: DateTime.parse(json['visit_date']),
    status: VisitStatus.values.firstWhere((e) => e.name == json['status']),
    supervisorName: json['supervisor_name'],
    supervisorTitle: json['supervisor_title'],
    observations: (json['observations'] as List?)
        ?.map((o) => SupervisionObservation.fromJson(o)).toList() ?? [],
    actionPlans: (json['action_plans'] as List?)
        ?.map((a) => ActionPlan.fromJson(a)).toList() ?? [],
    overallPerformance: json['overall_performance'] ?? '',
    summary: json['summary'] ?? '',
    nextVisitDate: json['next_visit_date'],
  );

  // ───ـ وظائف مساعدة ───ـ
  static String _formatDate(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static String _performanceToArabic(PerformanceLevel level) => {
    PerformanceLevel.excellent: 'ممتاز',
    PerformanceLevel.good: 'جيد',
    PerformanceLevel.satisfactory: 'مقبول',
    PerformanceLevel.needsImprovement: 'يحتاج تحسين',
    PerformanceLevel.critical: 'حرج',
  }[level]!;

  static String _performanceToEmoji(PerformanceLevel level) => {
    PerformanceLevel.excellent: '🟢',
    PerformanceLevel.good: '🔵',
    PerformanceLevel.satisfactory: '🟡',
    PerformanceLevel.needsImprovement: '🟠',
    PerformanceLevel.critical: '🔴',
  }[level]!;

  static String _categoryToArabic(ObservationCategory cat) => {
    ObservationCategory.coldChain: '❄️ سلسلة التبريد',
    ObservationCategory.vaccineAdmin: '💉 إعطاء اللقاح',
    ObservationCategory.recordKeeping: '📝 التسجيل',
    ObservationCategory.wasteManagement: '🗑️ إدارة النفايات',
    ObservationCategory.communication: '🗣️ التواصل',
    ObservationCategory.sessionPlanning: '📅 تخطيط الجلسات',
    ObservationCategory.dataQuality: '📊 جودة البيانات',
    ObservationCategory.aefi: '⚠️ الآثار الضارة',
    ObservationCategory.community: '🏘️ المجتمع',
    ObservationCategory.staffing: '👥 الكوادر',
  }[cat]!;
}


/// ═══════════════════════════════════════════════════════════════════════
///  خدمة الإشراف الداعم — طبقة منطق الأعمال
///  جاهزة لربط Supabase كخلفية بيانات
/// ═══════════════════════════════════════════════════════════════════════
class SupervisionService {
  // تخزين محلي مؤقت — سيتم استبداله بـ Supabase
  static final List<SupervisionVisit> _visits = [];

  /// إنشاء زيارة إشرافية جديدة
  static SupervisionVisit createVisit({
    required String facilityName,
    required String governorate,
    required String district,
    required String supervisorName,
    required String supervisorTitle,
  }) {
    final visit = SupervisionVisit(
      id: 'SV-${DateTime.now().millisecondsSinceEpoch}',
      facilityName: facilityName,
      governorate: governorate,
      district: district,
      visitDate: DateTime.now(),
      supervisorName: supervisorName,
      supervisorTitle: supervisorTitle,
    );
    _visits.add(visit);
    return visit;
  }

  /// الحصول على جميع الزيارات
  static List<SupervisionVisit> getVisits() => List.unmodifiable(_visits);

  /// الحصول على زيارات محافظة معينة
  static List<SupervisionVisit> getVisitsByGovernorate(String gov) =>
      _visits.where((v) => v.governorate == gov).toList();

  /// الحصول على الزيارات التي تحتاج متابعة
  static List<SupervisionVisit> getVisitsNeedingFollowUp() =>
      _visits.where((v) {
        final perf = v.calculateOverallPerformance();
        return perf == PerformanceLevel.needsImprovement ||
               perf == PerformanceLevel.critical;
      }).toList();

  /// إضافة ملاحظة لزيارة
  static SupervisionVisit addObservation(String visitId, SupervisionObservation obs) {
    final idx = _visits.indexWhere((v) => v.id == visitId);
    if (idx == -1) throw Exception('زيارة غير موجودة');
    final visit = _visits[idx];
    final updatedObs = [...visit.observations, obs];
    _visits[idx] = SupervisionVisit(
      id: visit.id,
      facilityName: visit.facilityName,
      governorate: visit.governorate,
      district: visit.district,
      visitDate: visit.visitDate,
      status: visit.status,
      supervisorName: visit.supervisorName,
      supervisorTitle: visit.supervisorTitle,
      observations: updatedObs,
      actionPlans: visit.actionPlans,
      overallPerformance: visit.overallPerformance,
      summary: visit.summary,
      nextVisitDate: visit.nextVisitDate,
      createdAt: visit.createdAt,
      updatedAt: DateTime.now(),
    );
    return _visits[idx];
  }

  /// إضافة خطة عمل
  static SupervisionVisit addActionPlan(String visitId, ActionPlan plan) {
    final idx = _visits.indexWhere((v) => v.id == visitId);
    if (idx == -1) throw Exception('زيارة غير موجودة');
    final visit = _visits[idx];
    final updatedPlans = [...visit.actionPlans, plan];
    _visits[idx] = SupervisionVisit(
      id: visit.id,
      facilityName: visit.facilityName,
      governorate: visit.governorate,
      district: visit.district,
      visitDate: visit.visitDate,
      status: visit.status,
      supervisorName: visit.supervisorName,
      supervisorTitle: visit.supervisorTitle,
      observations: visit.observations,
      actionPlans: updatedPlans,
      overallPerformance: visit.overallPerformance,
      summary: visit.summary,
      nextVisitDate: visit.nextVisitDate,
      createdAt: visit.createdAt,
      updatedAt: DateTime.now(),
    );
    return _visits[idx];
  }

  /// توليد ملخص إشرافي ذكي من البيانات
  static String generateSmartSummary(SupervisionVisit visit) {
    final perf = visit.calculateOverallPerformance();
    final perfArabic = _perfArabic(perf);

    final critical = visit.observations.where((o) =>
        o.performance == PerformanceLevel.critical).length;
    final needsImprovement = visit.observations.where((o) =>
        o.performance == PerformanceLevel.needsImprovement).length;
    final good = visit.observations.where((o) =>
        o.performance == PerformanceLevel.good ||
        o.performance == PerformanceLevel.excellent).length;

    final buf = StringBuffer();
    buf.writeln('📋 ملخص إشرافي — ${visit.facilityName}');
    buf.writeln('📊 الأداء العام: $perfArabic');
    buf.writeln('');

    if (critical > 0) {
      buf.writeln('🔴 ملاحظات حرجة: $critical — تحتاج تدخل فوري!');
    }
    if (needsImprovement > 0) {
      buf.writeln('🟠 تحتاج تحسين: $needsImprovement');
    }
    if (good > 0) {
      buf.writeln('✅ نقاط إيجابية: $good');
    }

    // توصيات ذكية
    buf.writeln('');
    buf.writeln('━━━━ التوصيات الذكية ━━━━');

    if (visit.observations.any((o) => o.category == ObservationCategory.coldChain &&
        o.performance == PerformanceLevel.critical)) {
      buf.writeln('❄️ عاجل: إصلاح سلسلة التبريد — اللقاحات معرضة للتلف!');
    }
    if (visit.observations.any((o) => o.category == ObservationCategory.vaccineAdmin &&
        o.performance.index >= PerformanceLevel.needsImprovement.index)) {
      buf.writeln('💉 تدريب فوري على تقنيات إعطاء اللقاح');
    }
    if (visit.observations.any((o) => o.category == ObservationCategory.dataQuality &&
        o.performance.index >= PerformanceLevel.needsImprovement.index)) {
      buf.writeln('📊 مراجعة نظام التسجيل والإبلاغ');
    }

    return buf.toString();
  }

  /// تصدير البيانات كـ JSON — جاهز لـ Supabase
  static String exportToJson() {
    return jsonEncode({
      'visits': _visits.map((v) => v.toJson()).toList(),
      'exported_at': DateTime.now().toIso8601String(),
      'version': '1.0',
    });
  }

  /// استيراد البيانات من JSON
  static void importFromJson(String jsonString) {
    final data = jsonDecode(jsonString);
    final visits = (data['visits'] as List)
        .map((v) => SupervisionVisit.fromJson(v))
        .toList();
    _visits.clear();
    _visits.addAll(visits);
  }

  static String _perfArabic(PerformanceLevel level) => {
    PerformanceLevel.excellent: 'ممتاز',
    PerformanceLevel.good: 'جيد',
    PerformanceLevel.satisfactory: 'مقبول',
    PerformanceLevel.needsImprovement: 'يحتاج تحسين',
    PerformanceLevel.critical: 'حرج',
  }[level]!;
}
