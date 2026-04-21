import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../constants/app_theme.dart';
import '../services/vaccination_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _selectedTab = 0;

  // بيانات وهمية للتوضيح (في التطبيق الحقيقي تُجلب من قاعدة بيانات)
  final Map<String, double> _coverageData = {
    'BCG': 85.2,
    'Penta3': 78.5,
    'PCV3': 76.3,
    'MR1': 72.1,
    'OPV3': 80.4,
  };

  final Map<String, double> _dropoutRates = {
    'Penta1→Penta3': 8.2,
    'OPV1→OPV3': 5.1,
    'BCG→MR1': 15.3,
  };

  final List<Map<String, dynamic>> _governorateData = [
    {'name': 'صنعاء', 'coverage': 88.5, 'color': AppTheme.successColor},
    {'name': 'عدن', 'coverage': 82.3, 'color': AppTheme.successColor},
    {'name': 'تعز', 'coverage': 75.1, 'color': AppTheme.warningColor},
    {'name': 'الحديدة', 'coverage': 68.2, 'color': AppTheme.warningColor},
    {'name': 'إب', 'coverage': 71.8, 'color': AppTheme.warningColor},
    {'name': 'ذمار', 'coverage': 79.5, 'color': AppTheme.successColor},
    {'name': 'عمران', 'coverage': 62.4, 'color': AppTheme.errorColor},
    {'name': 'حجة', 'coverage': 58.9, 'color': AppTheme.errorColor},
    {'name': 'البيضاء', 'coverage': 65.3, 'color': AppTheme.warningColor},
    {'name': 'الجوف', 'coverage': 70.1, 'color': AppTheme.warningColor},
    {'name': 'مأرب', 'coverage': 67.8, 'color': AppTheme.warningColor},
    {'name': 'صعدة', 'coverage': 55.2, 'color': AppTheme.errorColor},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2E86AB), Color(0xFF3498DB)],
            ),
          ),
        ),
        title: const Text('📊 تحليل بيانات النظام'),
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final tabs = ['التغطية', 'التسرب', 'المحافظات', 'الحملات'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final isSelected = _selectedTab == entry.key;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = entry.key),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF2E86AB) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF2E86AB) : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  entry.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : Colors.black87,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildContent() {
    switch (_selectedTab) {
      case 0: return _buildCoverageTab();
      case 1: return _buildDropoutTab();
      case 2: return _buildGovernorateTab();
      case 3: return _buildCampaignTab();
      default: return _buildCoverageTab();
    }
  }

  Widget _buildCoverageTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSummaryCard(),
        const SizedBox(height: 16),
        ..._coverageData.entries.map((e) => _buildCoverageBar(e.key, e.value)),
      ],
    );
  }

  Widget _buildSummaryCard() {
    final avg = _coverageData.values.reduce((a, b) => a + b) / _coverageData.length;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF2E86AB), Color(0xFF3498DB)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: const Color(0xFF2E86AB).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          CircularPercentIndicator(
            radius: 50,
            lineWidth: 10,
            percent: avg / 100,
            center: Text(
              '${avg.toStringAsFixed(1)}%',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            progressColor: avg >= 80 ? AppTheme.successColor : AppTheme.warningColor,
            backgroundColor: Colors.white.withOpacity(0.2),
            circularStrokeCap: CircularStrokeCap.round,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'متوسط التغطية الإجمالي',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Tajawal'),
                ),
                const SizedBox(height: 8),
                Text(
                  avg >= 80 ? '✅ أداء جيد' : '⚠️ يحتاج تحسين',
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13, fontFamily: 'Tajawal'),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildCoverageBar(String vaccine, double coverage) {
    final color = coverage >= 80
        ? AppTheme.successColor
        : coverage >= 60
            ? AppTheme.warningColor
            : AppTheme.errorColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(vaccine, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Tajawal', fontSize: 15)),
              Text(
                '${coverage.toStringAsFixed(1)}%',
                style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LinearPercentIndicator(
            padding: EdgeInsets.zero,
            lineHeight: 10,
            percent: coverage / 100,
            backgroundColor: Colors.grey.shade200,
            progressColor: color,
            barRadius: const Radius.circular(5),
            animation: true,
            animationDuration: 800,
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 100 * _coverageData.keys.toList().indexOf(vaccine)));
  }

  Widget _buildDropoutTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.warningColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.warningColor.withOpacity(0.3)),
          ),
          child: const Row(
            children: [
              Text('⚠️', style: TextStyle(fontSize: 24)),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'معدل التسرب يقيس نسبة الأطفال الذين بدأوا التطعيم لكن لم يكملوه',
                  style: TextStyle(fontFamily: 'Tajawal', fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ..._dropoutRates.entries.map((e) {
          final color = e.value < 10 ? AppTheme.successColor : AppTheme.errorColor;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                  child: Center(child: Text('${e.value}%', style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16))),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Tajawal')),
                      const SizedBox(height: 4),
                      Text(
                        e.value < 10 ? '✅ ضمن المعدل المقبول' : '🚨 أعلى من المعدل المقبول (10%)',
                        style: TextStyle(fontSize: 12, color: color, fontFamily: 'Tajawal'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: Duration(milliseconds: 100 * _dropoutRates.keys.toList().indexOf(e.key)));
        }),
      ],
    );
  }

  Widget _buildGovernorateTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          '📊 التغطية حسب المحافظة',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Tajawal'),
        ),
        const SizedBox(height: 4),
        Text(
          'ترتيب تصاعدي حسب مستوى التغطية',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontFamily: 'Tajawal'),
        ),
        const SizedBox(height: 16),
        ..._governorateData.map((g) {
          final color = g['color'] as Color;
          final coverage = g['coverage'] as double;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withOpacity(0.3)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)],
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 40,
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(g['name'], style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Tajawal')),
                ),
                Text(
                  '${coverage.toStringAsFixed(1)}%',
                  style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16),
                ),
              ],
            ),
          ).animate().fadeIn(delay: Duration(milliseconds: 50 * _governorateData.indexOf(g)));
        }),
      ],
    );
  }

  Widget _buildCampaignTab() {
    final campaigns = [
      {'name': 'حملة شلل الأطفال Q1', 'target': 2500000, 'achieved': 2125000, 'coverage': 85.0},
      {'name': 'حملة الحصبة', 'target': 1800000, 'achieved': 1530000, 'coverage': 85.0},
      {'name': 'تكميم فيتامين أ', 'target': 1200000, 'achieved': 1080000, 'coverage': 90.0},
      {'name': 'حملة شلل الأطفال Q2', 'target': 2500000, 'achieved': 2375000, 'coverage': 95.0},
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          '🚐 نتائج الحملات',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Tajawal'),
        ),
        const SizedBox(height: 16),
        ...campaigns.map((c) {
          final coverage = c['coverage'] as double;
          final color = coverage >= 90
              ? AppTheme.successColor
              : coverage >= 80
                  ? AppTheme.warningColor
                  : AppTheme.errorColor;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(c['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Tajawal')),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        '${coverage.toStringAsFixed(0)}%',
                        style: TextStyle(fontWeight: FontWeight.bold, color: color),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCampaignStat('🎯 المستهدف', '${(c['target'] as int) ~/ 1000}K'),
                    _buildCampaignStat('✅ المحقق', '${(c['achieved'] as int) ~/ 1000}K'),
                    _buildCampaignStat('📊 التغطية', '${coverage.toStringAsFixed(1)}%'),
                  ],
                ),
                const SizedBox(height: 10),
                LinearPercentIndicator(
                  padding: EdgeInsets.zero,
                  lineHeight: 8,
                  percent: coverage / 100,
                  backgroundColor: Colors.grey.shade200,
                  progressColor: color,
                  barRadius: const Radius.circular(4),
                  animation: true,
                ),
              ],
            ),
          ).animate().fadeIn(delay: Duration(milliseconds: 100 * campaigns.indexOf(c)));
        }),
      ],
    );
  }

  Widget _buildCampaignStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontFamily: 'Tajawal')),
      ],
    );
  }
}
