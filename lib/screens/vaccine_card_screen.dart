import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../constants/app_theme.dart';
import '../models/vaccine_model.dart';
import '../services/vaccination_service.dart';

class VaccineCardScreen extends StatefulWidget {
  const VaccineCardScreen({super.key});

  @override
  State<VaccineCardScreen> createState() => _VaccineCardScreenState();
}

class _VaccineCardScreenState extends State<VaccineCardScreen> {
  final VaccinationService _service = VaccinationService();
  ChildRecord? _childRecord;
  final Set<String> _completedVaccines = {};
  bool _isSetupMode = true;

  // Form controllers
  final _nameController = TextEditingController();
  final _parentController = TextEditingController();
  DateTime? _birthDate;
  String _selectedGender = 'ذكر';
  String _selectedGovernorate = 'صنعاء';

  @override
  Widget build(BuildContext context) {
    if (_isSetupMode) {
      return _buildSetupScreen();
    }
    return _buildCardScreen();
  }

  // ══════════════════════════════════════════════════════════════
  //  شاشة إدخال بيانات الطفل
  // ══════════════════════════════════════════════════════════════
  Widget _buildSetupScreen() {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        ),
        title: const Text('👶 بيانات الطفل'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.secondaryColor.withOpacity(0.15),
                    AppTheme.secondaryColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.secondaryColor.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Text('📋', style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 12),
                  const Text(
                    'بطاقة التطعيم الرقمية',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'أدخل بيانات طفلك لمتابعة تطعيماته',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontFamily: 'Tajawal',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 500.ms),

            const SizedBox(height: 24),

            // Child name
            _buildTextField(
              controller: _nameController,
              label: 'اسم الطفل',
              icon: Icons.child_care,
              hint: 'أدخل اسم الطفل',
            ),

            const SizedBox(height: 16),

            // Parent name
            _buildTextField(
              controller: _parentController,
              label: 'اسم ولي الأمر',
              icon: Icons.person,
              hint: 'اسم الأب أو الأم',
            ),

            const SizedBox(height: 16),

            // Birth date
            _buildDateSelector(),

            const SizedBox(height: 16),

            // Gender
            _buildGenderSelector(),

            const SizedBox(height: 16),

            // Governorate
            _buildGovernorateSelector(),

            const SizedBox(height: 30),

            // Save button
            ElevatedButton.icon(
              onPressed: _saveChildData,
              icon: const Icon(Icons.save),
              label: const Text('حفظ ومتابعة التطعيمات'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18, fontFamily: 'Tajawal'),
              ),
            ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3, end: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: 'Tajawal',
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppTheme.primaryColor),
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'تاريخ الميلاد',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: 'Tajawal',
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2023),
              lastDate: DateTime.now(),
              locale: const Locale('ar'),
            );
            if (date != null) setState(() => _birthDate = date);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: AppTheme.primaryColor),
                const SizedBox(width: 12),
                Text(
                  _birthDate != null
                      ? DateFormat('yyyy/MM/dd').format(_birthDate!)
                      : 'اختر تاريخ الميلاد',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 15,
                    color: _birthDate != null ? Colors.black87 : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'الجنس',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: 'Tajawal',
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: ['ذكر', 'أنثى'].map((gender) {
            final isSelected = _selectedGender == gender;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: gender == 'ذكر' ? 8 : 0, right: gender == 'أنثى' ? 8 : 0),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedGender = gender),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryColor : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
                      ),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(gender == 'ذكر' ? '👦' : '👧', style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Text(
                            gender,
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGovernorateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'المحافظة',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: 'Tajawal',
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedGovernorate,
              isExpanded: true,
              items: VaccinationService.governorates.map((g) {
                return DropdownMenuItem(
                  value: g,
                  child: Text(g, style: const TextStyle(fontFamily: 'Tajawal')),
                );
              }).toList(),
              onChanged: (v) => setState(() => _selectedGovernorate = v!),
            ),
          ),
        ),
      ],
    );
  }

  void _saveChildData() {
    if (_nameController.text.isEmpty || _birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال اسم الطفل وتاريخ الميلاد'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() {
      _childRecord = ChildRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        childName: _nameController.text,
        parentName: _parentController.text,
        birthDate: _birthDate!,
        gender: _selectedGender,
        governorate: _selectedGovernorate,
        district: '',
        healthFacility: '',
      );
      _isSetupMode = false;
    });
  }

  // ══════════════════════════════════════════════════════════════
  //  شاشة بطاقة التطعيم
  // ══════════════════════════════════════════════════════════════
  Widget _buildCardScreen() {
    final child = _childRecord!;
    final now = DateTime.now();
    final ageDays = now.difference(child.birthDate).inDays;
    final ageWeeks = ageDays ~/ 7;
    final ageMonths = (ageDays / 30.44).floor();

    final schedule = _service.getFullSchedule();
    final allVaccines = VaccinationService.allVaccines;
    final completedCount = _completedVaccines.length;
    final totalCount = allVaccines.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        ),
        title: const Text('📋 بطاقة التطعيم'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => setState(() => _isSetupMode = true),
            tooltip: 'تعديل البيانات',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Child info card
            _buildChildInfoCard(child, ageMonths, ageWeeks),

            const SizedBox(height: 16),

            // Progress card
            _buildProgressCard(progress, completedCount, totalCount),

            const SizedBox(height: 16),

            // Vaccination checklist
            ...schedule.entries.map((entry) {
              return _buildPhaseChecklist(entry.key, entry.value);
            }),

            const SizedBox(height: 20),

            // Print / share button
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildChildInfoCard(ChildRecord child, int months, int weeks) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.secondaryColor.withOpacity(0.1),
              AppTheme.secondaryColor.withOpacity(0.03),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Avatar
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.secondaryColor.withOpacity(0.3),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  child.gender == 'ذكر' ? '👦' : '👧',
                  style: const TextStyle(fontSize: 35),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              child.childName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Tajawal',
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'العمر: ${months > 0 ? "$months أشهر" : "$weeks أسابيع"}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Tajawal',
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _infoChip('📅', DateFormat('yyyy/MM/dd').format(child.birthDate)),
                _infoChip(child.gender == 'ذكر' ? '👦' : '👧', child.gender),
                _infoChip('📍', child.governorate),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.95, 0.95));
  }

  Widget _infoChip(String emoji, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 12, fontFamily: 'Tajawal')),
        ],
      ),
    );
  }

  Widget _buildProgressCard(double progress, int completed, int total) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircularPercentIndicator(
              radius: 45,
              lineWidth: 10,
              percent: progress,
              center: Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Tajawal',
                ),
              ),
              progressColor: AppTheme.successColor,
              backgroundColor: Colors.grey.shade200,
              circularStrokeCap: CircularStrokeCap.round,
              animation: true,
              animationDuration: 800,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'نسبة الإنجاز',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$completed من $total تطعيم مكتمل',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearPercentIndicator(
                    padding: EdgeInsets.zero,
                    lineHeight: 8,
                    percent: progress,
                    progressColor: AppTheme.successColor,
                    backgroundColor: Colors.grey.shade200,
                    barRadius: const Radius.circular(4),
                    animation: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildPhaseChecklist(String phase, List<Vaccine> vaccines) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        initiallyExpanded: true,
        title: Row(
          children: [
            Text(
              phase,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Tajawal',
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${vaccines.where((v) => _completedVaccines.contains(v.id)).length}/${vaccines.length}',
                style: const TextStyle(
                  color: AppTheme.successColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  fontFamily: 'Tajawal',
                ),
              ),
            ),
          ],
        ),
        children: vaccines.map((vaccine) {
          final isCompleted = _completedVaccines.contains(vaccine.id);
          return CheckboxListTile(
            value: isCompleted,
            onChanged: (val) {
              setState(() {
                if (val == true) {
                  _completedVaccines.add(vaccine.id);
                } else {
                  _completedVaccines.remove(vaccine.id);
                }
              });
            },
            title: Row(
              children: [
                Text(vaccine.iconEmoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    vaccine.nameAr,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontWeight: isCompleted ? FontWeight.normal : FontWeight.w600,
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      color: isCompleted ? Colors.grey : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Text(
              vaccine.doseNumber,
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'Tajawal',
                color: Colors.grey.shade500,
              ),
            ),
            activeColor: AppTheme.successColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم حفظ بطاقة التطعيم ✅'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                },
                icon: const Icon(Icons.save),
                label: const Text('حفظ البطاقة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.successColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('ميزة المشاركة قريباً! 📤'),
                    ),
                  );
                },
                icon: const Icon(Icons.share),
                label: const Text('مشاركة'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppTheme.primaryColor),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _parentController.dispose();
    super.dispose();
  }
}
