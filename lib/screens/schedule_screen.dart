import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_theme.dart';
import '../models/vaccine_model.dart';
import '../services/vaccination_service.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final VaccinationService _service = VaccinationService();
  int _selectedPhase = 0;

  final List<_SchedulePhase> _phases = [
    _SchedulePhase('عند الولادة', '0', '🟢', 0, 0),
    _SchedulePhase('6 أسابيع', '6 أسابيع', '🟡', 6, 0),
    _SchedulePhase('10 أسابيع', '10 أسابيع', '🟠', 10, 0),
    _SchedulePhase('14 أسبوع', '14 أسبوع', '🔴', 14, 0),
    _SchedulePhase('9 أشهر', '9 أشهر', '🟣', 0, 9),
    _SchedulePhase('15 شهر', '15 شهر', '🔵', 0, 15),
    _SchedulePhase('18 شهر', '18 شهر', '💪', 0, 18),
    _SchedulePhase('6 سنوات', '6 سنوات', '🏫', 0, 72),
    _SchedulePhase('12 سنة', '12 سنة (بنات)', '👧', 0, 144),
  ];

  @override
  Widget build(BuildContext context) {
    final schedule = _service.getFullSchedule();
    final phaseKeys = schedule.keys.toList();

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        ),
        title: const Text('📅 جدول التطعيمات'),
      ),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                const Text(
                  '💉 الجدول الوطني للتحصين',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Tajawal',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'دليل التحصين الصحي الموسع - اليمن 2025',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ],
            ),
          ),

          // Phase selector
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              itemCount: _phases.length,
              itemBuilder: (context, index) {
                final phase = _phases[index];
                final isSelected = _selectedPhase == index;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedPhase = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primaryColor
                              : Colors.grey.shade300,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppTheme.primaryColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(phase.emoji,
                              style: const TextStyle(fontSize: 18)),
                          const SizedBox(height: 4),
                          Text(
                            phase.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.black87,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Vaccine list for selected phase
          Expanded(
            child: _selectedPhase < phaseKeys.length
                ? _buildVaccineList(schedule[phaseKeys[_selectedPhase]]!)
                : const Center(child: Text('لا توجد بيانات')),
          ),
        ],
      ),
    );
  }

  Widget _buildVaccineList(List<Vaccine> vaccines) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: vaccines.length,
      itemBuilder: (context, index) {
        final vaccine = vaccines[index];
        return _buildVaccineCard(vaccine, index);
      },
    );
  }

  Widget _buildVaccineCard(Vaccine vaccine, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showVaccineDetails(vaccine),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Color(
                          int.parse(vaccine.color.substring(1), radix: 16) +
                              0xFF000000)
                      .withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(vaccine.iconEmoji,
                      style: const TextStyle(fontSize: 26)),
                ),
              ),
              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vaccine.nameAr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      vaccine.doseNumber,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        vaccine.route == 'oral'
                            ? 'فموي 💧'
                            : 'حقن 💉',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.primaryColor,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 100 * index))
        .slideX(begin: 0.1, end: 0);
  }

  void _showVaccineDetails(Vaccine vaccine) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _VaccineDetailSheet(vaccine: vaccine),
    );
  }
}

class _SchedulePhase {
  final String label;
  final String subtitle;
  final String emoji;
  final int weeks;
  final int months;
  _SchedulePhase(this.label, this.subtitle, this.emoji, this.weeks, this.months);
}

// ──── Bottom Sheet لتفاصيل التطعيم ────
class _VaccineDetailSheet extends StatelessWidget {
  final Vaccine vaccine;
  const _VaccineDetailSheet({required this.vaccine});

  @override
  Widget build(BuildContext context) {
    final color = Color(
        int.parse(vaccine.color.substring(1), radix: 16) + 0xFF000000);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Header
              Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Center(
                      child: Text(vaccine.iconEmoji,
                          style: const TextStyle(fontSize: 32)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vaccine.nameAr,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                        Text(
                          vaccine.nameEn,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Description
              _buildSection('📝 الوصف', vaccine.description),

              // Details
              _buildInfoRow('💉 الجرعة', vaccine.doseNumber),
              _buildInfoRow('🩺 طريقة الإعطاء', vaccine.route == 'oral' ? 'عن طريق الفم' : 'حقن عضلي'),
              _buildInfoRow('📍 مكان الحقن', vaccine.site),

              // Side effects
              if (vaccine.sideEffects.isNotEmpty)
                _buildListSection('⚠️ الآثار الجانبية المحتملة', vaccine.sideEffects),

              // Contraindications
              if (vaccine.contraindications.isNotEmpty)
                _buildListSection('🚫 موانع الاستعمال', vaccine.contraindications),

              // Notes
              if (vaccine.notes.isNotEmpty)
                _buildSection('💡 ملاحظات مهمة', vaccine.notes),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Tajawal',
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            height: 1.6,
            fontFamily: 'Tajawal',
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontFamily: 'Tajawal',
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Tajawal',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Tajawal',
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontSize: 16)),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ),
                ],
              ),
            )),
        const SizedBox(height: 16),
      ],
    );
  }
}
