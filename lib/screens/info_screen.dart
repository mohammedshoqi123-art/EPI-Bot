import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_theme.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        ),
        title: const Text('ℹ️ معلومات ودليل'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            _buildHeaderCard(),

            const SizedBox(height: 16),

            // About EPI
            _buildInfoCard(
              icon: '🏥',
              title: 'عن برنامج التحصين الموسع',
              content:
                  'برنامج التحصين الصحي الموسع (EPI) هو برنامج وطني تتبناه وزارة الصحة العامة والسكان في اليمن بالتعاون مع منظمة الصحة العالمية ومنظمة اليونيسيف.\n\n'
                  'البرنامج يقدم تطعيمات مجانية لجميع الأطفال في اليمن ضد 12 مرضًا خطيرًا لضمان حماية شاملة للأجيال القادمة.',
              color: AppTheme.primaryColor,
            ),

            const SizedBox(height: 12),

            // Diseases prevented
            _buildInfoCard(
              icon: '🛡️',
              title: 'الأمراض التي تحمي منها التطعيمات',
              content:
                  '1. السل (Tuberculosis)\n'
                  '2. شلل الأطفال (Poliomyelitis)\n'
                  '3. الخناق (Diphtheria)\n'
                  '4. الكزاز (Tetanus)\n'
                  '5. السعال الديبي (Pertussis/Whooping Cough)\n'
                  '6. التهاب الكبد B (Hepatitis B)\n'
                  '7. التهاب الأغشية المخية بـ Hib\n'
                  '8. الحصبة (Measles)\n'
                  '9. النكاف (Mumps)\n'
                  '10. الحصبة الألمانية (Rubella)\n'
                  '11. الالتهابات الرئوية بالمكورات الرئوية\n'
                  '12. الإسهال الحاد بالروتا فيروس',
              color: AppTheme.accentColor,
            ),

            const SizedBox(height: 12),

            // Important tips
            _buildInfoCard(
              icon: '💡',
              title: 'نصائح مهمة قبل وبعد التطعيم',
              content:
                  '✅ قبل التطعيم:\n'
                  '• تأكد من أن الطفل بصحة جيدة\n'
                  '• أحضر بطاقة التطعيم السابقة\n'
                  '• أخبر الممرضة بأي حساسية أو أمراض\n\n'
                  '✅ بعد التطعيم:\n'
                  '• انتظر 15-30 دقيقة في المركز\n'
                  '• تعامل مع الحرارة الخفيفة بكمادات باردة\n'
                  '• لا تترك مكان الحقن يلمس ماء\n'
                  '• راقب الطفل خلال 48 ساعة\n\n'
                  '🚨 اطلب طبيبًا فورًا إذا:\n'
                  '• حرارة أعلى من 39 درجة\n'
                  '• تشنجات أو نوبات\n'
                  '• صعوبة في التنفس\n'
                  '• تورم في الوجه أو الحلق',
              color: AppTheme.warningColor,
            ),

            const SizedBox(height: 12),

            // Vaccine safety
            _buildInfoCard(
              icon: '🔬',
              title: 'أمان التطعيمات',
              content:
                  'جميع التطعيمات المقدمة في برنامج التحصين الموسع:\n\n'
                  '• ✅ معتمدة من منظمة الصحة العالمية\n'
                  '• ✅ تخضع لرقابة صارمة للجودة\n'
                  '• ✅ مخزنة وفق معايير السلسلة الباردة\n'
                  '• ✅ ملايين الأطفال تلقواها بأمان\n'
                  '• ✅ فوائدها تفوق بكثير أي مخاطر\n\n'
                  '🛡️ التطعيم هو أفضل استثمار في صحة طفلك!',
              color: AppTheme.successColor,
            ),

            const SizedBox(height: 12),

            // Cold chain
            _buildInfoCard(
              icon: '❄️',
              title: 'السلسلة الباردة',
              content:
                  'التطعيمات حساسة للحرارة ويجب تخزينها بعناية:\n\n'
                  '• تُخزن في درجات حرارة 2-8 درجة مئوية\n'
                  '• تُنقل في ثلاجات متنقلة مخصصة\n'
                  '• تُراقب درجة الحرارة باستمرار\n'
                  '• إذا لاحظت لونًا غريبًا → لا تستخدمها\n\n'
                  'هذا يضمن فعالية التطعيم وسلامة طفلك.',
              color: Colors.blue,
            ),

            const SizedBox(height: 12),

            // Quick contact
            _buildContactCard(context),

            const SizedBox(height: 12),

            // Disclaimer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    '⚕️ إخلاء مسؤولية',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'هذا التطبيق للأغراض المعلوماتية فقط ولا يغني عن استشارة الطبيب المختص. '
                    'يرجى مراجعة المركز الصحي للحصول على المشورة الطبية المتخصصة.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontFamily: 'Tajawal',
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // App info
            Center(
              child: Column(
                children: [
                  const Text(
                    'مستشار التحصين الصحي الموسع',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Tajawal',
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'بناءً على دليل التحصين الموسع - اليمن أغسطس 2025',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'الإصدار 1.0.0',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text('🇾🇪', style: TextStyle(fontSize: 50)),
          const SizedBox(height: 16),
          const Text(
            'دليل التحصين الصحي الموسع',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Tajawal',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'وزارة الصحة العامة والسكان',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
              fontFamily: 'Tajawal',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'جمهورية اليمن',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.6),
              fontFamily: 'Tajawal',
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildInfoCard({
    required String icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(icon, style: const TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                height: 1.7,
                fontFamily: 'Tajawal',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Text('📞', style: TextStyle(fontSize: 22)),
                SizedBox(width: 12),
                Text(
                  'للتواصل والاستفسار',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildContactRow('🏥', 'المركز الصحي الحكومي الأقرب لك'),
            _buildContactRow('📞', 'الخط الساخن لوزارة الصحة'),
            _buildContactRow('🌐', 'www.mophp-ye.org'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final url = Uri.parse(
                      'https://drive.google.com/drive/folders/1or0W34GOXarw4UUySnUa4UAWJUAK9oTZ');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                icon: const Icon(Icons.download),
                label: const Text('تحميل الدليل الكامل (PDF)'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(String icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'Tajawal',
            ),
          ),
        ],
      ),
    );
  }
}
