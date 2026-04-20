/// ثوابت التطبيق - اليمن EPI
class AppConstants {
  // معلومات التطبيق
  static const String appName = 'مستشار التحصين';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'مستشار برنامج التحصين الصحي الموسع باليمن';

  // معلومات البرنامج
  static const String epiFullName = 'برنامج التحصين الصحي الموسع';
  static const String ministryName = 'وزارة الصحة العامة والسكان';
  static const String countryName = 'جمهورية اليمن';

  // الروابط
  static const String guidelinesUrl =
      'https://drive.google.com/drive/folders/1or0W34GOXarw4UUySnUa4UAWJUAK9oTZ';
  static const String whoUrl = 'https://www.who.int';
  static const String unicefUrl = 'https://www.unicef.org';

  // نصائح يومية
  static const List<String> dailyTips = [
    '💡 تأكد من حمل بطاقة التطعيم عند كل زيارة للمركز الصحي',
    '⏰ لا تتأخر عن موعد التطعيم - كل يوم تأخير = خطر أكبر',
    '🤱 الرضاعة الطبيعية تزيد مناعة طفلك الطبيعية',
    '📋 احتفظ ببطاقة التطعيم في مكان آمن',
    '🌡️ الحرارة البسيطة بعد التطعيم طبيعية ومؤقتة',
    '💪 التطعيم هو أفضل حماية لأطفالك من الأمراض الخطيرة',
    '🇾🇪 جميع تطعيمات البرنامج مجانية في المراكز الصحية الحكومية',
    '🏥 زور المركز الصحي الأقرب لطفلك للتطعيم',
  ];

  // أرقام الطوارئ
  static const String emergencyHotline = '190';
  static const String healthMinistryPhone = '+967-1-XXXXXXX';

  // الألوان حسب نوع التطعيم
  static const int colorBcg = 0xFFE74C3C;
  static const int colorPolio = 0xFF27AE60;
  static const int colorPentavalent = 0xFFE67E22;
  static const int colorPcv = 0xFF8E44AD;
  static const int colorRotavirus = 0xFF1ABC9C;
  static const int colorMeasles = 0xFFC0392B;
  static const int colorIpv = 0xFF2C3E50;
  static const int colorDtp = 0xFFE67E22;
  static const int colorMmr = 0xFFC0392B;
}
