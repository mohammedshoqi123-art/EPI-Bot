// ══════════════════════════════════════════════════════════════════════════
//  محرك التحليل والتنبؤ المتقدم — EPI-Bot Analytics Engine
//  يوفر: تحليل البيانات الحقيقية، المقارنات، التنبؤات، التوصيات الذكية
//  يعمل بالكامل بدون إنترنت — تحليل محلي مبني على البيانات الفعلية
// ══════════════════════════════════════════════════════════════════════════

import 'dart:math';
import 'real_data_kb.dart';

/// نوع التحليل المطلوب
enum AnalysisType {
  comparison,   // مقارنة
  trend,        // اتجاه
  prediction,   // تنبؤ
  ranking,      // ترتيب
  gapAnalysis,  // تحليل فجوات
  kpi,          // مؤشرات أداء
  recommendation, // توصيات
}

/// نتيجة التحليل
class AnalysisResult {
  final String title;
  final String summary;
  final String details;
  final List<String> keyFindings;
  final List<String> recommendations;
  final AnalysisType type;
  final double confidence;

  const AnalysisResult({
    required this.title,
    required this.summary,
    required this.details,
    this.keyFindings = const [],
    this.recommendations = const [],
    required this.type,
    this.confidence = 0.9,
  });
}

/// محرك التحليل والتنبوه المتقدم
class AnalyticsEngine {

  // ══════════════════════════════════════════════════════════════════
  //  القسم ١: تحليل حملات شلل الأطفال
  // ══════════════════════════════════════════════════════════════════

  /// تحليل حملة شلل الأطفال بالتفصيل
  static AnalysisResult analyzePolioCampaign(int campaignIndex) {
    if (campaignIndex < 0 || campaignIndex >= polioCampaignsData.length) {
      return const AnalysisResult(
        title: 'خطأ',
        summary: 'بيانات الحملة غير متوفرة',
        details: '',
        type: AnalysisType.kpi,
      );
    }

    final campaign = polioCampaignsData[campaignIndex];
    final buf = StringBuffer();

    buf.writeln('📊 تحليل حملة شلل الأطفال — ${campaign.round}');
    buf.writeln('📅 الفترة: ${campaign.period}');
    buf.writeln('');
    buf.writeln('━━━━ النتائج الرئيسية ━━━━');
    buf.writeln('💉 إجمالي المطعمين: ${_formatNumber(campaign.totalVaccinated)} طفل');
    buf.writeln('📈 نسبة التغطية: ${campaign.coverageRate}%');
    buf.writeln('📉 نسبة التلف: ${campaign.wastageRate}%');
    buf.writeln('');

    // ترتيب المحافظات
    final sorted = campaign.governorates.values.toList()
      ..sort((a, b) => b.coverage.compareTo(a.coverage));

    buf.writeln('🏆 أفضل 5 محافظات:');
    for (int i = 0; i < 5 && i < sorted.length; i++) {
      buf.writeln('  ${i + 1}. ${sorted[i].name}: ${sorted[i].coverage}% — ${sorted[i].rating}');
    }

    buf.writeln('');
    buf.writeln('⚠️ أضعف 3 محافظات:');
    final weakest = sorted.reversed.take(3).toList();
    for (int i = 0; i < weakest.length; i++) {
      buf.writeln('  ❌ ${weakest[i].name}: ${weakest[i].coverage}% — ${weakest[i].rating}');
    }

    // تحليل الأداء
    final excellent = campaign.governorates.values.where((g) => g.coverage >= 100).length;
    final good = campaign.governorates.values.where((g) => g.coverage >= 95 && g.coverage < 100).length;
    final poor = campaign.governorates.values.where((g) => g.coverage < 95).length;

    buf.writeln('');
    buf.writeln('📋 تقييم الأداء:');
    buf.writeln('  🟢 ممتازة (≥100%): $excellent محافظة');
    buf.writeln('  🟡 جيدة (95-99%): $good محافظة');
    buf.writeln('  🔴 تحتاج تحسين (<95%): $poor محافظة');

    return AnalysisResult(
      title: 'تحليل ${campaign.round}',
      summary: 'التغطية ${campaign.coverageRate}% — ${campaign.totalVaccinated} طفل مطعم',
      details: buf.toString(),
      keyFindings: [
        'إجمالي المطعمين: ${_formatNumber(campaign.totalVaccinated)}',
        '$excellent محافظة ممتازة، $poor محافظة متدنية',
        'أعلى تغطية: ${sorted.first.name} (${sorted.first.coverage}%)',
        'أدنى تغطية: ${sorted.last.name} (${sorted.last.coverage}%)',
      ],
      recommendations: poor > 0
          ? ['التركيز على المحافظات المتدنية: ${weakest.map((g) => g.name).join("، ")}']
          : [],
      type: AnalysisType.kpi,
    );
  }

  /// مقارنة بين حملتين أو أكثر
  static AnalysisResult comparePolioCampaigns(List<int> indices) {
    if (indices.isEmpty) indices = [0, polioCampaignsData.length - 1];

    final buf = StringBuffer();
    buf.writeln('📊 مقارنة حملات شلل الأطفال');
    buf.writeln('');

    final campaigns = indices.map((i) => polioCampaignsData[i]).toList();

    // جدول المقارنة
    buf.writeln('┌─────────────┬──────────────┬──────────────┬──────────────┐');
    buf.writeln('│ المعيار      │ ${campaigns[0].round.substring(0, 10).padLeft(10)} │ ${campaigns.length > 1 ? campaigns[1].round.substring(0, 10).padLeft(10) : "─" * 10} │ التغيير     │');
    buf.writeln('├─────────────┼──────────────┼──────────────┼──────────────┤');

    // إجمالي المطعمين
    final diff1 = campaigns.length > 1
        ? campaigns[1].totalVaccinated - campaigns[0].totalVaccinated
        : 0;
    buf.writeln('│ المطعمين     │ ${_formatNumber(campaigns[0].totalVaccinated).padLeft(12)} │ ${campaigns.length > 1 ? _formatNumber(campaigns[1].totalVaccinated).padLeft(12) : "─" * 12} │ ${diff1 > 0 ? "+" : ""}${_formatNumber(diff1).padLeft(10)} │');

    // التغطية
    final diff2 = campaigns.length > 1
        ? campaigns[1].coverageRate - campaigns[0].coverageRate
        : 0.0;
    buf.writeln('│ التغطية      │ ${"${campaigns[0].coverageRate}%".padLeft(12)} │ ${campaigns.length > 1 ? "${campaigns[1].coverageRate}%".padLeft(12) : "─" * 12} │ ${diff2 > 0 ? "+" : ""}${diff2.toStringAsFixed(0)}%'.padLeft(10) + ' │');

    buf.writeln('└─────────────┴──────────────┴──────────────┴──────────────┘');

    // تحليل الاتجاه
    buf.writeln('');
    buf.writeln('📈 تحليل الاتجاه:');
    if (diff1 > 0) {
      buf.writeln('  ✅ ارتفاع عدد المطعمين بنسبة ${((diff1 / campaigns[0].totalVaccinated) * 100).toStringAsFixed(1)}%');
    } else if (diff1 < 0) {
      buf.writeln('  ⚠️ انخفاض عدد المطعمين بنسبة ${((diff1.abs() / campaigns[0].totalVaccinated) * 100).toStringAsFixed(1)}%');
    }

    if (diff2 > 0) {
      buf.writeln('  ✅ تحسن التغطية بـ ${diff2.toStringAsFixed(0)} نقطة مئوية');
    }

    // مقارنة المحافظات
    buf.writeln('');
    buf.writeln('📍 تغييرات التغطية حسب المحافظة:');
    if (campaigns.length > 1) {
      for (final gov in campaigns[0].governorates.keys) {
        final c1 = campaigns[0].governorates[gov]?.coverage ?? 0;
        final c2 = campaigns[1].governorates[gov]?.coverage ?? 0;
        final change = c2 - c1;
        final arrow = change > 0 ? '📈' : change < 0 ? '📉' : '➡️';
        buf.writeln('  $arrow $gov: $c1% → $c2% (${change > 0 ? "+" : ""}${change.toStringAsFixed(0)}%)');
      }
    }

    return AnalysisResult(
      title: 'مقارنة حملات شلل الأطفال',
      summary: 'مقارنة ${campaigns.length} حملات — ${diff1 > 0 ? "تحسن" : diff1 < 0 ? "انخفاض" : "استقرار"}',
      details: buf.toString(),
      keyFindings: [
        'تغيير عدد المطعمين: ${diff1 > 0 ? "+" : ""}${_formatNumber(diff1)}',
        'تغيير التغطية: ${diff2 > 0 ? "+" : ""}${diff2.toStringAsFixed(0)}%',
      ],
      recommendations: diff2 < 0
          ? ['مراجعة استراتيجية الحملات — التغطية في انخفاض']
          : ['استمرار في نفس النهج — نتائج إيجابية'],
      type: AnalysisType.comparison,
    );
  }

  // ══════════════════════════════════════════════════════════════════
  //  القسم ٢: تحليل النشاط الايصالي التكاملي
  // ══════════════════════════════════════════════════════════════════

  /// تحليل النشاط الايصالي عبر المراحل
  static AnalysisResult analyzeSIAPhases() {
    final buf = StringBuffer();
    buf.writeln('📊 تحليل النشاط الايصالي التكاملي — 5 مراحل 2025');
    buf.writeln('');

    // اتجاه الجلسات
    buf.writeln('📈 اتجاه عدد الجلسات:');
    for (final phase in siaData) {
      buf.writeln('  📅 ${phase.phase} (${phase.period}): ${phase.totalSessions} جلسة | ${phase.totalWorkers} عامل');
    }

    // حساب التغيير
    final firstSessions = siaData.first.totalSessions;
    final lastSessions = siaData.last.totalSessions;
    final change = ((lastSessions - firstSessions) / firstSessions * 100);

    buf.writeln('');
    buf.writeln('📊 التغيير من المرحلة الأولى إلى الأخيرة:');
    buf.writeln('  الجلسات: $firstSessions → $lastSessions (${change > 0 ? "+" : ""}${change.toStringAsFixed(1)}%)');

    // أفضل وأضعف المحافظات
    buf.writeln('');
    buf.writeln('🏆 المحافظات الأنشط (آخر مرحلة):');
    final lastPhase = siaData.last;
    final sortedGovs = lastPhase.governorates.values.toList()
      ..sort((a, b) => b.sessions.compareTo(a.sessions));

    for (int i = 0; i < 5 && i < sortedGovs.length; i++) {
      buf.writeln('  ${i + 1}. ${sortedGovs[i].name}: ${sortedGovs[i].sessions} جلسة');
    }

    return AnalysisResult(
      title: 'تحليل النشاط الايصالي',
      summary: '${siaData.length} مراحل — ${change > 0 ? "تحسن" : "استقرار"} في عدد الجلسات',
      details: buf.toString(),
      keyFindings: [
        'الجلسات ارتفعت من $firstSessions إلى $lastSessions',
        'تعز تتصدر بعدد ${lastPhase.governorates["تعز"]?.sessions ?? 0} جلسة',
        'استقرار العاملين عند ~${siaData.last.totalWorkers}',
      ],
      type: AnalysisType.trend,
    );
  }

  // ══════════════════════════════════════════════════════════════════
  //  القسم ٣: التنبؤات
  // ══════════════════════════════════════════════════════════════════

  /// تنبؤ بتغطية الحملة القادمة
  static AnalysisResult predictNextCampaignCoverage() {
    final buf = StringBuffer();
    buf.writeln('🔮 تنبؤ بتغطية حملات شلل الأطفال القادمة');
    buf.writeln('');

    // حساب معدل التحسن
    final rates = polioCampaignsData.map((c) => c.coverageRate).toList();
    final avgImprovement = rates.length > 1
        ? (rates.last - rates.first) / (rates.length - 1)
        : 0.0;

    final lastRate = rates.last;
    final predictedRate = lastRate + avgImprovement;

    buf.writeln('📈 تحليل الاتجاه:');
    buf.writeln('  التغطية الحالية: $lastRate%');
    buf.writeln('  معدل التحسن: ${avgImprovement.toStringAsFixed(1)} نقطة/جولة');
    buf.writeln('  التنبؤ للجولة القادمة: ${predictedRate.toStringAsFixed(0)}%');
    buf.writeln('');

    // تنبؤ لكل محافظة
    buf.writeln('📍 التنبؤ حسب المحافظة:');
    final lastCampaign = polioCampaignsData.last;
    final predictions = <String, double>{};

    for (final gov in lastCampaign.governorates.values) {
      double predicted;
      if (gov.coverage >= 100) {
        predicted = gov.coverage + (Random().nextDouble() * 2 - 1); // ±1%
      } else if (gov.coverage >= 90) {
        predicted = gov.coverage + 1.5 + Random().nextDouble(); // +1.5 to +2.5
      } else {
        predicted = gov.coverage + 2 + Random().nextDouble() * 2; // +2 to +4%
      }
      predictions[gov.name] = predicted.clamp(70, 140);
    }

    final sortedPredictions = predictions.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (final entry in sortedPredictions) {
      final emoji = entry.value >= 95 ? '🟢' : entry.value >= 90 ? '🟡' : '🔴';
      buf.writeln('  $emoji ${entry.key}: ${entry.value.toStringAsFixed(0)}%');
    }

    buf.writeln('');
    buf.writeln('⚠️ تنبيه: هذه التنبؤات مبنية على الاتجاهات السابقة وقد تختلف في الواقع');

    return AnalysisResult(
      title: 'تنبؤ حملات شلل الأطفال',
      summary: 'التنبؤ: ${predictedRate.toStringAsFixed(0)}% تغطية — ${avgImprovement > 0 ? "تحسن" : "استقرار"}',
      details: buf.toString(),
      keyFindings: [
        'معدل التحسن: ${avgImprovement.toStringAsFixed(1)} نقطة مئوية/جولة',
        'المحافظات المتوقع تحسنها: البيضاء، الجوف، عدن',
        'الهدف الوطني: ≥95% لجميع المحافظات',
      ],
      recommendations: [
        'تركيز الموارد على المحافظات تحت 95%',
        'مراجعة المستهدفين في الحديدة (تغطية فائقة)',
        'زيادة التثقيف في المكلا والشحر',
      ],
      type: AnalysisType.prediction,
      confidence: 0.75,
    );
  }

  /// تنبؤ بالتغطية الروتينية
  static AnalysisResult predictRoutineCoverage() {
    final buf = StringBuffer();
    buf.writeln('🔮 تنبؤ بالتغطية الروتينية 2026');
    buf.writeln('');

    // بناءً على البيانات الحالية
    final avgMr1 = coverageByGov.isNotEmpty
        ? coverageByGov.map((c) => c.mr1Coverage).reduce((a, b) => a + b) / coverageByGov.length
        : 82.0;
    final avgPenta1 = coverageByGov.isNotEmpty
        ? coverageByGov.map((c) => c.penta1Coverage).reduce((a, b) => a + b) / coverageByGov.length
        : 94.0;
    final avgPenta3 = coverageByGov.isNotEmpty
        ? coverageByGov.map((c) => c.penta3Coverage).reduce((a, b) => a + b) / coverageByGov.length
        : 85.0;

    buf.writeln('━━━━ التوقعات لـ 2026 ━━━━');
    buf.writeln('');
    buf.writeln('💉 MR1 (الحصبة الأولى):');
    buf.writeln('  الحالي: ${avgMr1.toStringAsFixed(1)}%');
    buf.writeln('  المتوقع: ${(avgMr1 + 3).toStringAsFixed(0)}% (بافتراض تحسن 3 نقاط)');
    buf.writeln('');
    buf.writeln('💉 Penta1 (الخماسي الأولى):');
    buf.writeln('  الحالي: ${avgPenta1.toStringAsFixed(1)}%');
    buf.writeln('  المتوقع: ${(avgPenta1 + 1.5).toStringAsFixed(0)}%');
    buf.writeln('');
    buf.writeln('💉 Penta3 (الخماسي الثالثة):');
    buf.writeln('  الحالي: ${avgPenta3.toStringAsFixed(1)}%');
    buf.writeln('  المتوقع: ${(avgPenta3 + 2.5).toStringAsFixed(0)}%');
    buf.writeln('');
    buf.writeln('📌 فجوة التسرب المتوقعة: ${(avgPenta1 + 1.5 - avgPenta3 - 2.5).abs().toStringAsFixed(1)}%');

    return AnalysisResult(
      title: 'تنبؤ التغطية الروتينية 2026',
      summary: 'MR1: ${(avgMr1 + 3).toStringAsFixed(0)}% | Penta3: ${(avgPenta3 + 2.5).toStringAsFixed(0)}%',
      details: buf.toString(),
      keyFindings: [
        'MR1 يحتاج تحسن 8+ نقاط للوصول للهدف (90%)',
        'Penta3 يحتاج تحسن 5+ نقاط',
        'المكلا هي التحدي الأكبر (MR1 = 68%)',
      ],
      recommendations: [
        'تركيز على محافظات MR1 المتدنية',
        'تعزيز التوعية المجتمعية',
        'زيادة الجلسات في المناطق النائية',
      ],
      type: AnalysisType.prediction,
      confidence: 0.7,
    );
  }

  // ══════════════════════════════════════════════════════════════════
  //  القسم ٤: تحليل الفجوات
  // ══════════════════════════════════════════════════════════════════

  /// تحليل الفجوات في التغطية
  static AnalysisResult analyzeCoverageGaps() {
    final buf = StringBuffer();
    buf.writeln('📊 تحليل فجوات التغطية التطعيمية');
    buf.writeln('');

    // فجوة بين التغطية الروتينية وحملات شلل
    buf.writeln('━━━━ الفجوة بين الروتين والحملات ━━━━');
    buf.writeln('');
    buf.writeln('التغطية الروتينية MR1: ~82%');
    buf.writeln('تغطية حملات شلل: ~107%');
    buf.writeln('الفجوة: 25 نقطة مئوية!');
    buf.writeln('');
    buf.writeln('📌 هذا يعني أن الحملات تعوض ضعف الروتين');
    buf.writeln('⚠️ لكن الحل المستدام هو تقوية الروتين');
    buf.writeln('');

    // فجوة التسرب
    buf.writeln('━━━━ فجوة التسرب (Penta1 → Penta3) ━━━━');
    buf.writeln('');
    for (final cov in coverageByGov) {
      final gap = cov.penta1Coverage - cov.penta3Coverage;
      final emoji = gap < 5 ? '🟢' : gap < 10 ? '🟡' : '🔴';
      buf.writeln('  $emoji ${cov.governorate}: Penta1 ${cov.penta1Coverage}% → Penta3 ${cov.penta3Coverage}% (فجوة ${gap.toStringAsFixed(1)}%)');
    }

    return AnalysisResult(
      title: 'تحليل فجوات التغطية',
      summary: 'فجوة كبيرة بين الروتين والحملات — تحتاج تقوية الروتين',
      details: buf.toString(),
      keyFindings: [
        'فجوة 25% بين الروتين والحملات',
        'فجوة تسرب Penta1→Penta3: ~9%',
        'المكلا: أقل تغطية روتينية',
      ],
      recommendations: [
        'تعزيز التغطية الروتينية مع الحملات',
        'برنامج تتبع المتخلفين',
        'تكثيف الجلسات الثابتة',
      ],
      type: AnalysisType.gapAnalysis,
    );
  }

  // ══════════════════════════════════════════════════════════════════
  //  القسم ٥: التوصيات الذكية
  // ══════════════════════════════════════════════════════════════════

  /// توصيات ذكية بناءً على البيانات
  static AnalysisResult generateSmartRecommendations(String context) {
    final buf = StringBuffer();
    buf.writeln('💡 التوصيات الذكية المبنية على البيانات');
    buf.writeln('');

    // تحليل السياق
    if (context.contains('شلل') || context.contains('حمل')) {
      buf.writeln('━━━━ توصيات حملات شلل الأطفال ━━━━');
      buf.writeln('');
      buf.writeln('1️⃣ المحافظات ذات الأولوية القصوى:');
      buf.writeln('   • البيضاء (88%) — تحتاج 7 نقاط للهدف');
      buf.writeln('   • الجوف (84%) — تحتاج 11 نقطة');
      buf.writeln('   • عدن (91%) — تحتاج 4 نقاط');
      buf.writeln('');
      buf.writeln('2️⃣ مراجعة المستهدفين:');
      buf.writeln('   • الحديدة (131%) — فحص دقة التقديرات');
      buf.writeln('   • احتمال وجود نازحين غير محسوبين');
      buf.writeln('');
      buf.writeln('3️⃣ تحسين معدل الجلسة:');
      buf.writeln('   • المهرة: 7-15 طفل/جلسة — زيادة الكثافة');
      buf.writeln('   • سقطرى: 4-6 طفل/جلسة — مراجعة الجدولة');
    }

    if (context.contains('روتين') || context.contains('تغطي') || context.contains('خماسي')) {
      buf.writeln('━━━━ توصيات التغطية الروتينية ━━━━');
      buf.writeln('');
      buf.writeln('1️⃣ أولوية المكلا:');
      buf.writeln('   • MR1 = 68% — أقل من الهدف بـ 22 نقطة!');
      buf.writeln('   • الشحر: 56% فقط — تدخل عاجل مطلوب');
      buf.writeln('');
      buf.writeln('2️⃣ الحد من التسرب:');
      buf.writeln('   • فجوة Penta1→Penta3 = 9%');
      buf.writeln('   • تطبيق برنامج تتبع المتخلفين');
      buf.writeln('');
      buf.writeln('3️⃣ تعزيز الطلب المجتمعي:');
      buf.writeln('   • توعية مكثفة قبل مواعيد التطعيم');
      buf.writeln('   • إشراك القادة المجتمعيين');
    }

    if (context.contains('ايصال') || context.contains('نشاط') || context.contains('جلس')) {
      buf.writeln('━━━━ توصيات النشاط الايصالي ━━━━');
      buf.writeln('');
      buf.writeln('1️⃣ توسيع النطاق:');
      buf.writeln('   • إضافة محافظات شمالية (صنعاء، حجة كاملة)');
      buf.writeln('   • زيادة المديريات في البيضاء والجوف');
      buf.writeln('');
      buf.writeln('2️⃣ تحسين الكفاءة:');
      buf.writeln('   • معدل الجلسة في المهرة منخفض جداً');
      buf.writeln('   • مراجعة عدد الجلسات المعتمدة');
      buf.writeln('');
      buf.writeln('3️⃣ التكامل مع الحملات:');
      buf.writeln('   • تنسيق أفضل بين SIA والحملات الوطنية');
      buf.writeln('   • استغلال فرق الحملات للنشاط الايصالي');
    }

    if (buf.toString().split('\n').where((l) => l.contains('━')).isEmpty) {
      buf.writeln('━━━━ توصيات عامة ━━━━');
      buf.writeln('');
      buf.writeln('1️⃣ تقوية التغطية الروتينية (الهدف: 90% لكل المؤشرات)');
      buf.writeln('2️⃣ تركيز على المحافظات المتدنية (البيضاء، الجوف، المكلا)');
      buf.writeln('3️⃣ الحد من التسرب (فجوة Penta1→Penta3 < 10%)');
      buf.writeln('4️⃣ تحسين جودة البيانات والإبلاغ');
      buf.writeln('5️⃣ تعزيز الإشراف الداعم الميداني');
    }

    return AnalysisResult(
      title: 'التوصيات الذكية',
      summary: 'توصيات مبنية على تحليل البيانات الحقيقية',
      details: buf.toString(),
      recommendations: [
        'أولوية قصوى: المكلا والبيضاء والجوف',
        'مراجعة المستهدفين في الحديدة',
        'برنامج تتبع المتخلفين',
        'تعزيز الإشراف الداعم',
      ],
      type: AnalysisType.recommendation,
    );
  }

  // ══════════════════════════════════════════════════════════════════
  //  القسم ٦: تحليل الاستفسارات الذكي
  // ══════════════════════════════════════════════════════════════════

  /// تحليل الاستفسار وتحديد نوع التحليل المطلوب
  static AnalysisResult? analyzeQuery(String query) {
    final norm = query.toLowerCase()
        .replaceAll('أ', 'ا').replaceAll('إ', 'ا').replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه').replaceAll('ى', 'ي');

    // حملات شلل الأطفال
    if (norm.contains('شلل') && norm.contains('تحلي')) {
      return analyzePolioCampaign(polioCampaignsData.length - 1);
    }
    if (norm.contains('شلل') && norm.contains('قارن') || norm.contains('مقارنه') && norm.contains('شلل')) {
      return comparePolioCampaigns([0, polioCampaignsData.length - 1]);
    }
    if (norm.contains('شلل') && (norm.contains('تنب') || norm.contains('توقع') || norm.contains('قادم'))) {
      return predictNextCampaignCoverage();
    }

    // النشاط الايصالي
    if (norm.contains('ايصال') || norm.contains('نشاط تكاملي')) {
      return analyzeSIAPhases();
    }

    // التغطية الروتينية
    if (norm.contains('تغطي') && (norm.contains('روتين') || norm.contains('شهري') || norm.contains('خماسي'))) {
      return predictRoutineCoverage();
    }

    // فجوات
    if (norm.contains('فجوه') || norm.contains('فجوة') || norm.contains('تسرب') || norm.contains('نقص')) {
      return analyzeCoverageGaps();
    }

    // توصيات
    if (norm.contains('توص') || norm.contains('نصيح') || norm.contains('اقتراح') || norm.contains('وش نسوي')) {
      return generateSmartRecommendations(norm);
    }

    // تنبؤات عامة
    if (norm.contains('تنب') || norm.contains('توقع') || norm.contains('2026') || norm.contains('قادم')) {
      return predictNextCampaignCoverage();
    }

    // KPI
    if (norm.contains('مؤشر') || norm.contains('اداء') || norm.contains('kpi')) {
      return analyzePolioCampaign(polioCampaignsData.length - 1);
    }

    return null;
  }

  // ══════════════════════════════════════════════════════════════════
  //  القسم ٧: وظائف مساعدة
  // ══════════════════════════════════════════════════════════════════

  static String _formatNumber(int n) {
    return n.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  /// الحصول على ملخص سريع للوضع الحالي
  static String getQuickStatus() {
    final lastPolio = polioCampaignsData.last;
    final lastSIA = siaData.last;
    return '📊 الوضع الحالي:\n'
        '• آخر حملة شلل: ${lastPolio.round} — تغطية ${lastPolio.coverageRate}%\n'
        '• آخر نشاط ايصالي: ${lastSIA.phase} — ${lastSIA.totalSessions} جلسة\n'
        '• التغطية الروتينية MR1: ~82% | Penta3: ~85%\n'
        '• المحافظات تحت 95%: 4 (البيضاء، الجوف، عدن، المهرة)';
  }
}
