// ══════════════════════════════════════════════════════════════════════════
//  محرك التحليل والتنبؤ العميق — Deep Analytics & Prediction Engine
//  يوفر: تحليل مقارن عميق، تنبؤات متقدمة، تحليل سيركوري،
//  توصيات ذكية مبنية على البيانات، تقييم المخاطر، تحليلات الإشراف
//  يعمل محلياً + يرسل السياق للLLM عند الاتصال
// ══════════════════════════════════════════════════════════════════════════

import 'real_data_kb.dart';

/// نوع التحليل العميق
enum DeepAnalysisType {
  riskAssessment,       // تقييم المخاطر
  rootCauseAnalysis,    // تحليل السبب الجذري
  trendPrediction,      // تنبؤ الاتجاهات
  benchmarkComparison,  // مقارنة معيارية
  supervisionAnalysis,  // تحليل إشرافي
  coverageProjection,   // إسقاط التغطية
  campaignOptimization, // تحسين الحملات
  defaulterRisk,        // خطر التسرب
  resourceAllocation,   // تخصيص الموارد
  outbreakRisk,         // خطر الأوبئة
}

/// نتيجة التحليل العميق
class DeepAnalysisResult {
  final String title;
  final String executiveSummary;
  final String detailedAnalysis;
  final List<String> keyFindings;
  final List<String> recommendations;
  final List<String> actionItems;
  final DeepAnalysisType type;
  final double confidence;
  final String riskLevel; // منخفض، متوسط، مرتفع، حرج

  const DeepAnalysisResult({
    required this.title,
    required this.executiveSummary,
    required this.detailedAnalysis,
    this.keyFindings = const [],
    this.recommendations = const [],
    this.actionItems = const [],
    required this.type,
    this.confidence = 0.85,
    this.riskLevel = 'متوسط',
  });
}

/// محرك التحليل والتنبؤ العميق
class DeepAnalyticsEngine {

  // ══════════════════════════════════════════════════════════════════
  //  القسم ١: تقييم المخاطر
  // ══════════════════════════════════════════════════════════════════

  /// تقييم مخاطر برنامج التحصين على مستوى المحافظة
  static DeepAnalysisResult assessGovernorateRisk(String governorate) {
    final buf = StringBuffer();
    final findings = <String>[];
    final recs = <String>[];
    final actions = <String>[];
    String riskLevel = 'منخفض';

    // البحث في بيانات حملات شلل الأطفال
    double? polioCoverage;
    String? polioRating;
    int? vaccinated;

    for (final campaign in polioCampaignsData) {
      final gov = campaign.governorates[governorate];
      if (gov != null) {
        polioCoverage = gov.coverage;
        polioRating = gov.rating;
        vaccinated = gov.vaccinated;
      }
    }

    // البحث في بيانات التغطية الروتينية
    double? mr1Cov, penta1Cov, penta3Cov;
    for (final cov in coverageByGov) {
      if (cov.governorate == governorate) {
        mr1Cov = cov.mr1Coverage;
        penta1Cov = cov.penta1Coverage;
        penta3Cov = cov.penta3Coverage;
      }
    }

    buf.writeln('🎯 تقييم مخاطر التحصين — محافظة $governorate');
    buf.writeln('');

    // تحليل حملات شلل الأطفال
    buf.writeln('━━━━ تحليل حملات شلل الأطفال ━━━━');
    if (polioCoverage != null) {
      buf.writeln('💉 آخر تغطية: $polioCoverage% ($polioRating)');
      buf.writeln('👥 عدد المطعمين: ${_fmt(vaccinated!)}');

      if (polioCoverage < 85) {
        riskLevel = 'حرج';
        findings.add('تغطية شلل الأطفال حرجة: $polioCoverage%');
        recs.add('تدخل عاجل: حملة استجابة + فرق متنقلة');
        actions.add('إطلاق حملة استجابة خلال أسبوع');
      } else if (polioCoverage < 95) {
        riskLevel = _worstRisk(riskLevel, 'مرتفع');
        findings.add('تغطية شلل الأطفال تحت الهدف: $polioCoverage%');
        recs.add('زيادة الجلسات وتكثيف التوعية');
        actions.add('وضع خطة تحسين خلال أسبوعين');
      } else {
        buf.writeln('✅ التغطية فوق الهدف');
      }
    } else {
      buf.writeln('⚠️ لا تتوفر بيانات حملات لهذه المحافظة');
    }
    buf.writeln('');

    // تحليل التغطية الروتينية
    buf.writeln('━━━━ تحليل التغطية الروتينية ━━━━');
    if (mr1Cov != null) {
      buf.writeln('💉 MR1: $mr1Cov%');
      buf.writeln('💉 Penta1: $penta1Cov%');
      buf.writeln('💉 Penta3: $penta3Cov%');

      final dropout = penta1Cov! - penta3Cov!;
      buf.writeln('📉 فجوة التسرب: ${dropout.toStringAsFixed(1)}%');

      if (mr1Cov < 80) {
        riskLevel = _worstRisk(riskLevel, 'حرج');
        findings.add('تغطية MR1 حرجة: $mr1Cov% (الهدف: 90%)');
        recs.add('تدخل شامل: توعية + جلسات إضافية + تتبع متخلفين');
        actions.add('تشكيل فريق عمل لمواجهة انخفاض MR1');
      } else if (mr1Cov < 90) {
        riskLevel = _worstRisk(riskLevel, 'مرتفع');
        findings.add('تغطية MR1 تحت الهدف: $mr1Cov%');
        recs.add('تعزيز التوعية وزيادة الجلسات');
      }

      if (dropout > 10) {
        riskLevel = _worstRisk(riskLevel, 'مرتفع');
        findings.add('فجوة تسرب مرتفعة: ${dropout.toStringAsFixed(1)}%');
        recs.add('تفعيل برنامج تتبع المتخلفين');
        actions.add('إعداد قائمة المتخلفين خلال أسبوع');
      }
    } else {
      buf.writeln('⚠️ لا تتوفر بيانات التغطية الروتينية');
    }
    buf.writeln('');

    // تقييم شامل
    buf.writeln('━━━━ التقييم الشامل ━━━━');
    buf.writeln('📊 مستوى المخاطر: $riskLevel');

    final riskEmoji = riskLevel == 'حرج' ? '🔴' :
                      riskLevel == 'مرتفع' ? '🟠' :
                      riskLevel == 'متوسط' ? '🟡' : '🟢';
    buf.writeln('$riskEmoji التصنيف: $riskLevel');

    return DeepAnalysisResult(
      title: 'تقييم مخاطر $governorate',
      executiveSummary: 'مستوى المخاطر: $riskLevel — ${findings.length} نتائج رئيسية',
      detailedAnalysis: buf.toString(),
      keyFindings: findings,
      recommendations: recs,
      actionItems: actions,
      type: DeepAnalysisType.riskAssessment,
      confidence: 0.85,
      riskLevel: riskLevel,
    );
  }

  // ══════════════════════════════════════════════════════════════════
  //  القسم ٢: تنبؤات متقدمة
  // ══════════════════════════════════════════════════════════════════

  /// تنبؤ بالتغطية المستقبلية مع سيناريوهات
  static DeepAnalysisResult predictCoverageWithScenarios() {
    final buf = StringBuffer();
    final findings = <String>[];
    final recs = <String>[];

    buf.writeln('🔮 تنبؤات التغطية مع السيناريوهات الثلاثة');
    buf.writeln('');

    // حساب الاتجاهات من البيانات الحقيقية
    final polioRates = polioCampaignsData.map((c) => c.coverageRate).toList();
    final improvementPerRound = polioRates.length > 1
        ? (polioRates.last - polioRates.first) / (polioRates.length - 1)
        : 1.5;
    final lastPolioRate = polioRates.last;

    final avgMr1 = coverageByGov.isNotEmpty
        ? coverageByGov.map((c) => c.mr1Coverage).reduce((a, b) => a + b) / coverageByGov.length
        : 82.0;
    final avgPenta3 = coverageByGov.isNotEmpty
        ? coverageByGov.map((c) => c.penta3Coverage).reduce((a, b) => a + b) / coverageByGov.length
        : 85.0;

    // السيناريو المتفائل
    buf.writeln('━━━━ السيناريو المتفائل (تحسن 5% سنوياً) ━━━━');
    buf.writeln('💉 شلل الأطفال: ${(lastPolioRate + 5).toStringAsFixed(0)}%');
    buf.writeln('💉 MR1: ${(avgMr1 + 5).toStringAsFixed(0)}%');
    buf.writeln('💉 Penta3: ${(avgPenta3 + 5).toStringAsFixed(0)}%');
    buf.writeln('📊 شروط التحقيق: استقرار أمني + تمويل كافي + كوادر متوفرة');
    buf.writeln('');

    // السيناريو الأكثر احتمالاً
    buf.writeln('━━━━ السيناريو الأكثر احتمالاً (تحسن 2-3% سنوياً) ━━━━');
    buf.writeln('💉 شلل الأطفال: ${(lastPolioRate + improvementPerRound).toStringAsFixed(0)}%');
    buf.writeln('💉 MR1: ${(avgMr1 + 3).toStringAsFixed(0)}%');
    buf.writeln('💉 Penta3: ${(avgPenta3 + 2.5).toStringAsFixed(0)}%');
    buf.writeln('📊 الشروط: استمرار الوضع الحالي مع تحسين تدريجي');
    buf.writeln('');

    // السيناريو المتشائم
    buf.writeln('━━━━ السيناريو المتشائم (استقرار أو تراجع) ━━━━');
    buf.writeln('💉 شلل الأطفال: ${lastPolioRate.toStringAsFixed(0)}%');
    buf.writeln('💉 MR1: ${avgMr1.toStringAsFixed(0)}%');
    buf.writeln('💉 Penta3: ${(avgPenta3 - 2).toStringAsFixed(0)}%');
    buf.writeln('📊 الشروط: تدهور أمني + نقص تمويل + كوادر');
    buf.writeln('');

    // تحليل المخاطر
    buf.writeln('━━━━ المخاطر الرئيسية ━━━━');
    buf.writeln('1️⃣ تفشي الحصبة إذا بقيت MR1 تحت 90%');
    buf.writeln('2️⃣ ظهور حالات شلل أطفال في المحافظات المتدنية');
    buf.writeln('3️⃣ اتساع فجوة التسرب في عدن والمكلا');
    buf.writeln('4️⃣ تدهور سلسلة التبريد في المناطق النائية');

    findings.add('السيناريو الأكثر احتمالاً: تحسن 2-3 نقاط سنوياً');
    findings.add('MR1 يحتاج 5-8 سنوات للوصول لـ90% بالوتيرة الحالية');
    findings.add('المكلا: التحدي الأكبر (MR1=68%)');
    recs.add('التركيز على MR1 كأولوية قصوى');
    recs.add('حملات تكميلية في المحافظات المتدنية');
    recs.add('تخصيص موارد إضافية للمكلا والبيضاء والجوف');

    return DeepAnalysisResult(
      title: 'تنبؤات التغطية مع السيناريوهات',
      executiveSummary: 'السيناريو الأكثر احتمالاً: تحسن 2-3% — يحتاج 5-8 سنوات للهدف',
      detailedAnalysis: buf.toString(),
      keyFindings: findings,
      recommendations: recs,
      type: DeepAnalysisType.trendPrediction,
      confidence: 0.75,
      riskLevel: 'مرتفع',
    );
  }

  // ══════════════════════════════════════════════════════════════════
  //  القسم ٣: تحليل مقارن عميق بين المحافظات
  // ══════════════════════════════════════════════════════════════════

  /// مقارنة معيارية بين المحافظات
  static DeepAnalysisResult benchmarkGovernorates() {
    final buf = StringBuffer();
    final findings = <String>[];
    final recs = <String>[];

    buf.writeln('📊 المقارنة المعيارية بين المحافظات');
    buf.writeln('');

    // ترتيب المحافظات حسب التغطية
    final lastCampaign = polioCampaignsData.last;
    final sorted = lastCampaign.governorates.values.toList()
      ..sort((a, b) => b.coverage.compareTo(a.coverage));

    buf.writeln('━━━━ ترتيب المحافظات حسب تغطية شلل الأطفال ━━━━');
    for (int i = 0; i < sorted.length; i++) {
      final emoji = sorted[i].coverage >= 100 ? '🟢' :
                    sorted[i].coverage >= 95 ? '🟡' : '🔴';
      buf.writeln('  ${i + 1}. $emoji ${sorted[i].name}: ${sorted[i].coverage}% — ${sorted[i].rating}');
    }
    buf.writeln('');

    // تحليل الفجوة بين الأعلى والأدنى
    final best = sorted.first;
    final worst = sorted.last;
    final gap = best.coverage - worst.coverage;

    buf.writeln('━━━━ تحليل الفجوة ━━━━');
    buf.writeln('🏆 الأعلى: ${best.name} (${best.coverage}%)');
    buf.writeln('❌ الأدنى: ${worst.name} (${worst.coverage}%)');
    buf.writeln('📊 الفجوة: ${gap.toStringAsFixed(0)} نقطة مئوية');
    buf.writeln('');

    if (gap > 20) {
      buf.writeln('⚠️ فجوة كبيرة! تدل على تفاوت كبير في الوصول والبنية التحتية');
      findings.add('فجوة ${gap.toStringAsFixed(0)} نقطة بين الأعلى والأدنى');
      recs.add('نقل أفضل الممارسات من ${best.name} إلى المحافظات المتدنية');
    }

    // مقارنة التغطية الروتينية
    buf.writeln('━━━━ مقارنة التغطية الروتينية ━━━━');
    final sortedRoutine = coverageByGov.toList()
      ..sort((a, b) => b.mr1Coverage.compareTo(a.mr1Coverage));

    for (final cov in sortedRoutine) {
      final emoji = cov.mr1Coverage >= 90 ? '🟢' :
                    cov.mr1Coverage >= 80 ? '🟡' : '🔴';
      final dropout = cov.penta1Coverage - cov.penta3Coverage;
      buf.writeln('  $emoji ${cov.governorate}: MR1=${cov.mr1Coverage}% | تسرب=${dropout.toStringAsFixed(1)}%');
    }

    findings.add('المكلا: أدنى تغطية روتينية (MR1=68%)');
    findings.add('أبين: أعلى تغطية روتينية (MR1=93%)');
    recs.add('نقل تجربة أبين إلى المحافظات المتدنية');
    recs.add('تحليل أسباب نجاح أبين وتعميمها');

    return DeepAnalysisResult(
      title: 'المقارنة المعيارية بين المحافظات',
      executiveSummary: 'فجوة ${gap.toStringAsFixed(0)} نقطة بين الأعلى والأدنى — تحسين مطلوب',
      detailedAnalysis: buf.toString(),
      keyFindings: findings,
      recommendations: recs,
      type: DeepAnalysisType.benchmarkComparison,
      confidence: 0.9,
      riskLevel: gap > 25 ? 'مرتفع' : 'متوسط',
    );
  }

  // ══════════════════════════════════════════════════════════════════
  //  القسم ٤: تحليل الإشراف الداعم
  // ══════════════════════════════════════════════════════════════════

  /// تحليل احتياجات الإشراف الداعم
  static DeepAnalysisResult analyzeSupervisionNeeds() {
    final buf = StringBuffer();
    final findings = <String>[];
    final recs = <String>[];
    final actions = <String>[];

    buf.writeln('🏥 تحليل احتياجات الإشراف الداعم');
    buf.writeln('');

    // تحديد المحافظات التي تحتاج إشراف مكثف
    buf.writeln('━━━━ المحافظات ذات الأولوية للإشراف ━━━━');
    buf.writeln('');

    final highPriority = <String>[];
    final mediumPriority = <String>[];

    for (final campaign in polioCampaignsData) {
      for (final gov in campaign.governorates.values) {
        if (gov.coverage < 90 && !highPriority.contains(gov.name)) {
          highPriority.add(gov.name);
        } else if (gov.coverage >= 90 && gov.coverage < 95 && !mediumPriority.contains(gov.name)) {
          mediumPriority.add(gov.name);
        }
      }
    }

    buf.writeln('🔴 أولوية قصوى:');
    for (final gov in highPriority) {
      buf.writeln('   • $gov — تحتاج زيارات إشرافية أسبوعية');
    }
    buf.writeln('');
    buf.writeln('🟡 أولوية متوسطة:');
    for (final gov in mediumPriority) {
      buf.writeln('   • $gov — تحتاج زيارات نصف شهرية');
    }
    buf.writeln('');

    // تحليل النشاط الإيصالي
    buf.writeln('━━━━ تحليل النشاط الإيصالي ━━━━');
    for (final phase in siaData) {
      buf.writeln('📅 ${phase.phase}: ${phase.totalSessions} جلسة | ${phase.totalWorkers} عامل');
      final zeroSessionGovs = phase.governorates.values.where((g) => g.sessions == 0).toList();
      if (zeroSessionGovs.isNotEmpty) {
        buf.writeln('   ⚠️ محافظات بلا جلسات: ${zeroSessionGovs.map((g) => g.name).join("، ")}');
      }
    }
    buf.writeln('');

    // التوصيات
    buf.writeln('━━━━ خطة الإشراف المقترحة ━━━━');
    buf.writeln('1️⃣ زيارات أسبوعية: البيضاء، الجوف');
    buf.writeln('2️⃣ زيارات نصف شهرية: عدن، المهرة، المكلا');
    buf.writeln('3️⃣ زيارات شهرية: شبوة، مأرب');
    buf.writeln('4️⃣ متابعة خاصة: عدن (0 جلسات في المراحل الأولى)');
    buf.writeln('');
    buf.writeln('📌 محاور كل زيارة:');
    buf.writeln('   • فحص سلسلة التبريد');
    buf.writeln('   • مراقبة جلسة تحصين');
    buf.writeln('   • مراجعة السجلات');
    buf.writeln('   • تقييم جودة البيانات');
    buf.writeln('   • التدريب على رأس العمل');

    findings.add('${highPriority.length} محافظات تحتاج إشراف مكثف');
    findings.add('عدن لم تنفذ جلسات في المراحل الأولى من SIA');
    recs.add('خطة إشرافية مفصلة لكل محافظة حسب مستوى المخاطر');
    recs.add('تفعيل عدن في النشاط الإيصالي');
    actions.add('إعداد جدول زيارات إشرافية ربع سنوي');

    return DeepAnalysisResult(
      title: 'تحليل احتياجات الإشراف الداعم',
      executiveSummary: '${highPriority.length} محافظات بأولوية قصوى — خطة إشرافية مقترحة',
      detailedAnalysis: buf.toString(),
      keyFindings: findings,
      recommendations: recs,
      actionItems: actions,
      type: DeepAnalysisType.supervisionAnalysis,
      confidence: 0.9,
      riskLevel: 'مرتفع',
    );
  }

  // ══════════════════════════════════════════════════════════════════
  //  القسم ٥: تحليل مخاطر الأوبئة
  // ══════════════════════════════════════════════════════════════════

  /// تقييم خطر تفشي الأمراض
  static DeepAnalysisResult assessOutbreakRisk() {
    final buf = StringBuffer();
    final findings = <String>[];
    final recs = <String>[];

    buf.writeln('🦠 تقييم مخاطر تفشي الأمراض المعدية');
    buf.writeln('');

    // خطر الحصبة
    buf.writeln('━━━━ خطر تفشي الحصبة ━━━━');
    final lowMr1Govs = coverageByGov.where((c) => c.mr1Coverage < 85).toList();
    if (lowMr1Govs.isNotEmpty) {
      buf.writeln('🔴 محافظات معرضة لتفشي الحصبة:');
      for (final gov in lowMr1Govs) {
        final gap = 95 - gov.mr1Coverage;
        buf.writeln('   ❌ ${gov.governorate}: MR1=${gov.mr1Coverage}% (نحتاج +${gap.toStringAsFixed(0)}%)');
      }
      findings.add('${lowMr1Govs.length} محافظات معرضة لتفشي الحصبة');
      recs.add('حملات تحصين تكميلية ضد الحصبة في المحافظات المتدنية');
    } else {
      buf.writeln('🟢 لا توجد محافظات معرضة بشكل حرج');
    }
    buf.writeln('');

    // خطر شلل الأطفال
    buf.writeln('━━━━ خطر تفشي شلل الأطفال ━━━━');
    final lowPolioGovs = <String>[];
    for (final gov in polioCampaignsData.last.governorates.values) {
      if (gov.coverage < 90) lowPolioGovs.add('${gov.name} (${gov.coverage}%)');
    }
    if (lowPolioGovs.isNotEmpty) {
      buf.writeln('🔴 محافظات معرضة:');
      for (final gov in lowPolioGovs) {
        buf.writeln('   ⚠️ $gov');
      }
      findings.add('${lowPolioGovs.length} محافظات معرضة لشلل الأطفال');
      recs.add('حملات استجابة سريعة في البيضاء والجوف');
    }
    buf.writeln('');

    // خطر الكزاز الوليدي
    buf.writeln('━━━━ خطر الكزاز الوليدي ━━━━');
    buf.writeln('🟡 اليمن حقق القضاء على الكزاز الوليدي (2019)');
    buf.writeln('⚠️ لكن الحاجة لاستمرار Td للحوامل');
    buf.writeln('⚠️ الولادات في المنازل بدون رعاية صحية = خطر');

    // التقييم الشامل
    buf.writeln('');
    buf.writeln('━━━━ التقييم الشامل ━━━━');
    final overallRisk = lowMr1Govs.length >= 3 || lowPolioGovs.length >= 3 ? 'مرتفع' : 'متوسط';
    buf.writeln('📊 مستوى المخاطر العام: $overallRisk');
    buf.writeln('💉 الأمراض ذات الأولوية: الحصبة > شلل الأطفال > الكزاز');

    recs.add('نظام إنذار مبكر للأوبئة');
    recs.add('تدريب فرق الاستجابة السريعة');
    recs.add('مخزون احتياطي من اللقاحات للحالات الطارئة');

    return DeepAnalysisResult(
      title: 'تقييم مخاطر الأوبئة',
      executiveSummary: 'مستوى المخاطر: $overallRisk — الحصبة الخطر الأكبر',
      detailedAnalysis: buf.toString(),
      keyFindings: findings,
      recommendations: recs,
      type: DeepAnalysisType.outbreakRisk,
      confidence: 0.8,
      riskLevel: overallRisk,
    );
  }

  // ══════════════════════════════════════════════════════════════════
  //  القسم ٦: تحسين الحملات
  // ══════════════════════════════════════════════════════════════════

  /// اقتراحات لتحسين الحملات القادمة
  static DeepAnalysisResult optimizeNextCampaign() {
    final buf = StringBuffer();
    final recs = <String>[];
    final actions = <String>[];

    buf.writeln('🚀 تحسين الحملة القادمة — توصيات مبنية على البيانات');
    buf.writeln('');

    // تحليل آخر حملة
    final lastCampaign = polioCampaignsData.last;
    buf.writeln('━━━━ أداء آخر حملة ━━━━');
    buf.writeln('📅 ${lastCampaign.round}');
    buf.writeln('💉 المطعمين: ${_fmt(lastCampaign.totalVaccinated)}');
    buf.writeln('📈 التغطية: ${lastCampaign.coverageRate}%');
    buf.writeln('📉 التلف: ${lastCampaign.wastageRate}%');
    buf.writeln('');

    // المحافظات التي تحتاج تحسين
    final weakGovs = lastCampaign.governorates.values
        .where((g) => g.coverage < 95).toList()
      ..sort((a, b) => a.coverage.compareTo(b.coverage));

    buf.writeln('━━━━ المحافظات ذات الأولوية ━━━━');
    for (final gov in weakGovs) {
      final needed = ((95 - gov.coverage) / 100 * gov.vaccinated / gov.coverage * 100).toInt();
      buf.writeln('  ❌ ${gov.name}: ${gov.coverage}% — يحتاج ~$needed طفل إضافي للهدف');
    }
    buf.writeln('');

    // مقترحات تحسين
    buf.writeln('━━━━ مقترحات التحسين ━━━━');
    buf.writeln('1️⃣ زيادة عدد الفرق في المحافظات المتدنية بنسبة 30%');
    buf.writeln('2️⃣ تعيين منسق محلي في البيضاء والجوف');
    buf.writeln('3️⃣ حملة توعية مسبقة (أسبوع قبل الحملة)');
    buf.writeln('4️⃣ مراجعة بيانات المستهدفين في الحديدة (131%)');
    buf.writeln('5️⃣ إضافة جلسات مسائية في المناطق الحضرية');
    buf.writeln('6️⃣ فرق بحث عن الأطفال المفقودين في اليوم الثالث');

    recs.add('زيادة الفرق في المحافظات المتدنية بنسبة 30%');
    recs.add('حملة توعية قبل أسبوع من الحملة');
    recs.add('مراجعة المستهدفين في الحديدة');
    actions.add('إعداد خطة الحملة القادمة مع التوصيات');
    actions.add('تخصيص ميزانية إضافية للبيضاء والجوف');

    return DeepAnalysisResult(
      title: 'تحسين الحملة القادمة',
      executiveSummary: 'التركيز على ${weakGovs.length} محافظات متدنية + مراجعة المستهدفين',
      detailedAnalysis: buf.toString(),
      recommendations: recs,
      actionItems: actions,
      type: DeepAnalysisType.campaignOptimization,
      confidence: 0.85,
      riskLevel: 'متوسط',
    );
  }

  // ══════════════════════════════════════════════════════════════════
  //  القسم ٧: تخصيص الموارد
  // ══════════════════════════════════════════════════════════════════

  /// اقتراحات تخصيص الموارد
  static DeepAnalysisResult allocateResources() {
    final buf = StringBuffer();
    final recs = <String>[];

    buf.writeln('💰 تخصيص الموارد — اقتراحات مبنية على البيانات');
    buf.writeln('');

    // تحليل كفاءة الموارد
    final lastSia = siaData.last;
    buf.writeln('━━━━ توزيع الموارد الحالي ━━━━');
    buf.writeln('📊 الجلسات: ${lastSia.totalSessions}');
    buf.writeln('👥 العاملين: ${lastSia.totalWorkers}');
    buf.writeln('📍 المديريات: ${lastSia.totalDistricts}');
    buf.writeln('');

    // كفاءة المحافظات
    buf.writeln('━━━━ كفاءة الموارد حسب المحافظة ━━━━');
    final efficiency = <String, double>{};
    for (final gov in lastSia.governorates.values) {
      if (gov.workers > 0) {
        efficiency[gov.name] = gov.sessions / gov.workers;
      }
    }

    final sortedEff = efficiency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (final entry in sortedEff) {
      final emoji = entry.value > 0.3 ? '🟢' : entry.value > 0.2 ? '🟡' : '🔴';
      buf.writeln('  $emoji ${entry.key}: ${entry.value.toStringAsFixed(2)} جلسة/عامل');
    }
    buf.writeln('');

    // التوصيات
    buf.writeln('━━━━ توصيات إعادة التخصيص ━━━━');
    buf.writeln('1️⃣ تعزيز الكوادر في المحافظات المتدنية تغطية');
    buf.writeln('2️⃣ تحسين كفاءة العاملين في المحافظات المنخفضة الإنتاجية');
    buf.writeln('3️⃣ تقليل الفائض في المحافظات ذات الكفاءة العالية');
    buf.writeln('4️⃣ استثمار المدخرات في فرق متنقلة جديدة');

    recs.add('إعادة توزيع الكوادر بناءً على الكفاءة والحاجة');
    recs.add('استثمار في فرق متنقلة للمناطق النائية');

    return DeepAnalysisResult(
      title: 'تخصيص الموارد',
      executiveSummary: 'إعادة توزيع الكوادر حسب الكفاءة — تركيز على المحافظات المتدنية',
      detailedAnalysis: buf.toString(),
      recommendations: recs,
      type: DeepAnalysisType.resourceAllocation,
      confidence: 0.8,
      riskLevel: 'متوسط',
    );
  }

  // ══════════════════════════════════════════════════════════════════
  //  القسم ٨: تحليل الاستفسارات العميق
  // ══════════════════════════════════════════════════════════════════

  /// تحليل استفسار المستخدم وتحديد نوع التحليل المطلوب
  static DeepAnalysisResult? analyzeQuery(String query) {
    final norm = query.toLowerCase()
        .replaceAll('أ', 'ا').replaceAll('إ', 'ا').replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه').replaceAll('ى', 'ي');

    // تقييم المخاطر
    if (norm.contains('خطر') || norm.contains('مخاطر') || norm.contains('تقييم') || norm.contains('تحليل مخاطر')) {
      // هل حدد محافظة؟
      for (final campaign in polioCampaignsData) {
        for (final gov in campaign.governorates.keys) {
          if (norm.contains(gov)) {
            return assessGovernorateRisk(gov);
          }
        }
      }
      // إذا لم يحدد — تقييم شامل
      return assessOutbreakRisk();
    }

    // تحليل إشرافي
    if (norm.contains('اشراف') || norm.contains('زياره اشرافي') || norm.contains('خطة اشراف') || norm.contains('احتياج اشراف')) {
      return analyzeSupervisionNeeds();
    }

    // تحسين الحملات
    if (norm.contains('تحسين حمل') || norm.contains('حمل قادم') || norm.contains('تخطيط حمل') || norm.contains('اقتراح حمل')) {
      return optimizeNextCampaign();
    }

    // تخصيص الموارد
    if (norm.contains('تخصيص مورد') || norm.contains('كوادر') || norm.contains('توزيع عامل') || norm.contains('كفاءه')) {
      return allocateResources();
    }

    // تنبؤات متقدمة
    if (norm.contains('سيناريو') || norm.contains('تنبؤ متقدم') || norm.contains('توقعات') || norm.contains('اسقاط')) {
      return predictCoverageWithScenarios();
    }

    // مقارنة معيارية
    if (norm.contains('مقارنه معيار') || norm.contains('بنشمارك') || norm.contains('ترتيب محافظ') || norm.contains('افضل محافظ') || norm.contains('اقوى محافظ')) {
      return benchmarkGovernorates();
    }

    // مخاطر الأوبئة
    if (norm.contains('وباء') || norm.contains('فاشي') || norm.contains('تفش') || norm.contains('خطر مرض') || norm.contains('حصبه خطر')) {
      return assessOutbreakRisk();
    }

    return null;
  }

  /// الحصول على ملخص تنفيذي شامل
  static String getExecutiveBriefing() {
    final lastPolio = polioCampaignsData.last;
    final lastSia = siaData.last;
    final avgMr1 = coverageByGov.isNotEmpty
        ? coverageByGov.map((c) => c.mr1Coverage).reduce((a, b) => a + b) / coverageByGov.length
        : 82.0;

    // حساب المحافظات المتدنية
    final weakGovs = lastPolio.governorates.values
        .where((g) => g.coverage < 95).map((g) => g.name).toList();

    return '📋 الإحاطة التنفيذية:\n\n'
        '━━━━ الوضع الحالي ━━━━\n'
        '💉 آخر حملة شلل: ${lastPolio.round} — تغطية ${lastPolio.coverageRate}%\n'
        '📊 التغطية الروتينية MR1: ${avgMr1.toStringAsFixed(0)}% (الهدف: 90%)\n'
        '🏥 النشاط الايصالي: ${lastSia.totalSessions} جلسة | ${lastSia.totalWorkers} عامل\n\n'
        '━━━━ المخاطر ━━━━\n'
        '🔴 محافظات تحت 95%: ${weakGovs.join("، ")}\n'
        '🔴 MR1 تحت 90%: المكلا، مأرب، شبوة، تعز\n'
        '🟡 فجوة تسرب: ~9% (الهدف: <10%)\n\n'
        '━━━━ الأولويات ━━━━\n'
        '1️⃣ المكلا: تدخل شامل (MR1=68%)\n'
        '2️⃣ البيضاء والجوف: حملات استجابة\n'
        '3️⃣ عدن: تفعيل النشاط الايصالي\n'
        '4️⃣ تعزيز الإشراف الداعم في جميع المحافظات المتدنية';
  }

  // ──── وظائف مساعدة ────

  static String _fmt(int n) {
    return n.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  static String _worstRisk(String current, String newRisk) {
    const order = ['منخفض', 'متوسط', 'مرتفع', 'حرج'];
    final currentIdx = order.indexOf(current);
    final newIdx = order.indexOf(newRisk);
    return order[currentIdx > newIdx ? currentIdx : newIdx];
  }
}
