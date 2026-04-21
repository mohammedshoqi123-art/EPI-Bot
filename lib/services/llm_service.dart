// ══════════════════════════════════════════════════════════════════════════
//  محرك الذكاء الاصطناعي الحقيقي — LLM Service مع RAG
//  يدعم: OpenAI-compatible API، استرجاع المعرفة (RAG)،
//  ذاكرة المحادثة، سياق الطفل، استجابة عاطفية
//  يعمل مع إنترنت، ويرجع للنظام المحلي بدون إنترنت
// ══════════════════════════════════════════════════════════════════════════

import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'knowledge_base.dart';
import 'smart_nlp.dart';
import 'real_data_kb.dart';
import 'advanced_immunization_kb.dart';
import 'intermediate_management_kb.dart';

/// حالة اتصال AI
enum AIIStatus {
  online,    // متصل بالذكاء الاصطناعي
  offline,   // بدون إنترنت — يستخدم النظام المحلي
  error,     // خطأ في الاتصال
  loading,   // جاري الاتصال
}

/// نتيجة استجابة AI
class AIResponse {
  final String text;
  final bool isFromLLM;
  final List<String> relevantTopics;
  final AIIStatus status;

  const AIResponse({
    required this.text,
    this.isFromLLM = false,
    this.relevantTopics = const [],
    this.status = AIIStatus.offline,
  });
}

/// خدمة الذكاء الاصطناعي المتقدمة مع RAG
class LLMService {
  // ══════════════════════════════════════════════════════════════════
  //  إعدادات API — قابلة للتعديل من الإعدادات
  // ══════════════════════════════════════════════════════════════════

  static String _apiKey = '';
  static String _apiBaseUrl = 'https://api.openai.com/v1';
  static String _model = 'gpt-4o-mini';
  static double _temperature = 0.6;
  static int _maxTokens = 2048;
  static AIIStatus _currentStatus = AIIStatus.offline;

  static String get apiKey => _apiKey;
  static String get apiBaseUrl => _apiBaseUrl;
  static String get model => _model;
  static AIIStatus get currentStatus => _currentStatus;
  static bool get isOnline => _currentStatus == AIIStatus.online;

  /// تحديث إعدادات API
  static Future<void> configure({
    required String apiKey,
    String? baseUrl,
    String? model,
    double? temperature,
    int? maxTokens,
  }) async {
    _apiKey = apiKey;
    if (baseUrl != null) _apiBaseUrl = baseUrl;
    if (model != null) _model = model;
    if (temperature != null) _temperature = temperature;
    if (maxTokens != null) _maxTokens = maxTokens;

    // حفظ الإعدادات
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('llm_api_key', _apiKey);
    await prefs.setString('llm_base_url', _apiBaseUrl);
    await prefs.setString('llm_model', _model);
    await prefs.setDouble('llm_temperature', _temperature);
    await prefs.setInt('llm_max_tokens', _maxTokens);
  }

  /// تحميل الإعدادات المحفوظة
  static Future<void> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    _apiKey = prefs.getString('llm_api_key') ?? '';
    _apiBaseUrl = prefs.getString('llm_base_url') ?? 'https://api.openai.com/v1';
    _model = prefs.getString('llm_model') ?? 'gpt-4o-mini';
    _temperature = prefs.getDouble('llm_temperature') ?? 0.6;
    _maxTokens = prefs.getInt('llm_max_tokens') ?? 2048;

    if (_apiKey.isNotEmpty) {
      _currentStatus = AIIStatus.online;
    }
  }

  /// التحقق من الاتصال
  static Future<bool> testConnection() async {
    if (_apiKey.isEmpty) return false;
    try {
      _currentStatus = AIIStatus.loading;
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/models'),
        headers: _headers(),
      ).timeout(const Duration(seconds: 10));
      _currentStatus = response.statusCode == 200 ? AIIStatus.online : AIIStatus.error;
      return _currentStatus == AIIStatus.online;
    } catch (e) {
      _currentStatus = AIIStatus.error;
      return false;
    }
  }

  // ══════════════════════════════════════════════════════════════════
  //  RAG — استرجاع المعرفة ذات الصلة
  // ══════════════════════════════════════════════════════════════════

  /// استرجاع المحتوى ذي الصلة من قاعدة المعرفة
  static String retrieveRelevantContext(String userMessage, {int maxEntries = 5}) {
    final norm = SmartNLP.normalize(userMessage);
    final keywords = SmartNLP.extractKeywords(norm);
    final expandedKeywords = SmartNLP.expandWithClusters(keywords);

    // حساب نقاط الصلة لكل مدخل في قاعدة المعرفة
    final scoredEntries = <MapEntry<String, String>, double>{};

    // دمج جميع قواعد المعرفة — الرئيسية + التقارير + المتقدمة + الإدارة الوسيطة
    final combinedKB = <String, String>{
      ...mainKnowledgeBase,
      ...realDataKnowledgeBase,
      ...advancedImmunizationKB,
      ...intermediateManagementKB,
    };

    for (final entry in combinedKB.entries) {
      double score = 0.0;
      final keyNorm = SmartNLP.normalize(entry.key);
      final valueNorm = SmartNLP.normalize(entry.value);

      // تطابق مع مفتاح المدخل
      for (final kw in expandedKeywords) {
        final kwNorm = SmartNLP.normalize(kw);
        if (keyNorm.contains(kwNorm)) score += 3.0;
        if (valueNorm.contains(kwNorm)) score += 1.5;

        // مطابقة ضبابية
        final fuzzy = SmartNLP.fuzzyMatch(kwNorm, keyNorm);
        if (fuzzy > 0.7) score += fuzzy * 2.0;
      }

      // تطابق مع مرادفات
      for (final kw in keywords) {
        final syns = SmartNLP.synonyms[kw] ?? [];
        for (final syn in syns) {
          final synNorm = SmartNLP.normalize(syn);
          if (valueNorm.contains(synNorm)) score += 0.8;
          if (keyNorm.contains(synNorm)) score += 1.5;
        }
      }

      // تعزيز لبيانات التقارير الحقيقية
      if (realDataKnowledgeBase.containsKey(entry.key)) {
        final dataTerms = ['تغطي', 'حمل', 'شلل', 'ايصال', 'محافظ', 'تنب', 'تسرب', 'فجوه', 'جلس', 'kpi', 'مؤشر'];
        for (final term in dataTerms) {
          if (norm.contains(term) && keyNorm.contains(term)) {
            score += 2.0; // تعزيز إضافي للبيانات الحقيقية
          }
        }
      }

      if (score > 0) {
        scoredEntries[entry] = score;
      }
    }

    // ترتيب حسب الصلة وأخذ أفضل النتائج
    final sorted = scoredEntries.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final selected = <String>[];
    int totalLength = 0;
    final maxLength = 10000; // حد أقصى للسياق — زِدنا من 6000 إلى 10000

    for (int i = 0; i < sorted.length && i < maxEntries; i++) {
      final entry = sorted[i].key;
      if (totalLength + entry.value.length <= maxLength) {
        selected.add('【${entry.key}】\n${entry.value}');
        totalLength += entry.value.length;
      }
    }

    return selected.join('\n\n---\n\n');
  }

  /// بناء سياق الطفل من المحادثة
  static String buildChildContext(Map<String, dynamic> childProfile) {
    if (childProfile.isEmpty) return '';
    final buf = StringBuffer('📋 معلومات الطفل:\n');
    if (childProfile['ageMonths'] != null) buf.writeln('  العمر: ${childProfile['ageMonths']} أشهر');
    if (childProfile['ageWeeks'] != null) buf.writeln('  العمر بالأسابيع: ${childProfile['ageWeeks']} أسبوع');
    if (childProfile['gender'] != null) buf.writeln('  الجنس: ${childProfile['gender']}');
    if (childProfile['name'] != null) buf.writeln('  الاسم: ${childProfile['name']}');
    if (childProfile['isPremature'] == true) buf.writeln('  مبتسر: نعم');
    if (childProfile['hasChronicDisease'] == true) buf.writeln('  مرض مزمن: ${childProfile['chronicDiseaseType'] ?? 'غير محدد'}');
    if (childProfile['givenVaccines'] != null) {
      final vaccines = (childProfile['givenVaccines'] as List).cast<String>();
      if (vaccines.isNotEmpty) buf.writeln('  تطعيمات سابقة: ${vaccines.join(', ')}');
    }
    if (childProfile['mentionedSymptoms'] != null) {
      final symptoms = (childProfile['mentionedSymptoms'] as List).cast<String>();
      if (symptoms.isNotEmpty) buf.writeln('  أعراض مذكورة: ${symptoms.join(', ')}');
    }
    return buf.toString();
  }

  // ══════════════════════════════════════════════════════════════════
  //  إرسال الرسالة للذكاء الاصطناعي
  // ══════════════════════════════════════════════════════════════════

  /// System Prompt المتقدم — شامل ومتخصص
  static String _buildSystemPrompt(String relevantContext, String childContext) {
    return '''أنت مستشار التحصين الذكي المتقدم 🇾🇪 — مساعد طبي وإداري متخصص في برنامج التحصين الصحي الموسع (EPI) في اليمن.

🎯 هويتك:
- اسمك: مستشار التحصين الذكي
- أنت خبير متعدد التخصصات: طبي (تحصين)، إداري (إدارة المستوى الوسيط)، تحليلي (بيانات وتقارير)، إشرافي (إشراف داعم)
- تتحدث باللهجة اليمنية/العربية بأسلوب ودي ومبسط
- تستخدم الإيموجي لتوضيح المعلومات وجعلها أسهل للفهم

🧠 قدراتك المتقدمة:
1. التحليل: تحليل بيانات التغطية والتقارير واستخلاص النتائج
2. المقارنة: مقارنة المحافظات والحملات والأداء بين الفترات
3. التنبؤ: توقع الاتجاهات المستقبلية بناءً على البيانات
4. التوصيات: تقديم توصيات ذكية مبنية على الأدلة
5. تقييم المخاطر: تحديد المحافظات والمناطق عالية المخاطر
6. الإشراف: تقديم إرشادات إشرافية داعمة
7. التخطيط: المساعدة في التخطيط الدقيق (Microplanning)

📋 قواعد صارمة:
1. أجب فقط عن الأسئلة المتعلقة بالتحصين والأمراض المعدية والصحة العامة والإدارة الصحية
2. إذا سُئلت عن شيء خارج تخصصك، اعتذر بلطف وأعد توجيه المستخدم
3. لا تقدم تشخيصاً طبياً — شجع دائماً على استشارة الطبيب للحالات المعقدة
4. استخدم المعلومات من قاعدة المعرفة أدناه كمرجع أساسي
5. إذا كانت المعلومة غير موجودة في قاعدة المعرفة، استخدم معرفتك العامة مع التنويه
6. لا تخترع معلومات طبية أو بيانات — إذا لم تكن متأكداً، قل ذلك بوضوح
7. في حالات الطوارئ، أشر دائماً لطلب المساعدة الطبية فوراً
8. كن تعاطفياً مع المخاوف، لكن قدم الحقائق العلمية بوضوح
9. عند تحليل البيانات، قدم أرقاماً محددة وتوصيات عملية
10. عند سؤالك عن الإدارة أو الإشراف، أجب كمستشار إداري خبير

📚 قاعدة المعرفة (المصدر الأساسي):
$relevantContext

$childContext

💡 أسلوب الرد:
- ابدأ بالإجابة المباشرة ثم أضف التفاصيل
- استخدم نقاط واضحة ومنظمة
- أضف أرقاماً وبيانات عند التحليل
- قدم توصيات عملية قابلة للتنفيذ
- اختم بسؤال أو اقتراح لمتابعة
- استخدم اللهجة اليمنية المبسطة (وش، ايش، ليش، الخ)
- أضف الإيموجي المناسب لكل قسم
- عند طلب التحليل: قدم ملخص تنفيذي + تفاصيل + توصيات''';
  }

  /// إرسال رسالة للLLM مع RAG
  static Future<AIResponse> sendMessage({
    required String userMessage,
    required List<Map<String, String>> conversationHistory,
    Map<String, dynamic> childProfile = const {},
  }) async {
    if (_apiKey.isEmpty) {
      return const AIResponse(
        text: '',
        isFromLLM: false,
        status: AIIStatus.offline,
      );
    }

    try {
      _currentStatus = AIIStatus.loading;

      // 1. استرجاع السياق ذي الصلة (RAG)
      final relevantContext = retrieveRelevantContext(userMessage);
      final childContext = buildChildContext(childProfile);

      // 2. بناء الرسائل
      final messages = <Map<String, String>>[];

      // System message مع RAG context
      messages.add({
        'role': 'system',
        'content': _buildSystemPrompt(relevantContext, childContext),
      });

      // إضافة تاريخ المحادثة (آخر 10 رسائل)
      final historyToAdd = conversationHistory.length > 10
          ? conversationHistory.sublist(conversationHistory.length - 10)
          : conversationHistory;
      messages.addAll(historyToAdd);

      // الرسالة الحالية
      messages.add({'role': 'user', 'content': userMessage});

      // 3. إرسال الطلب
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/chat/completions'),
        headers: _headers(),
        body: jsonEncode({
          'model': _model,
          'messages': messages,
          'temperature': _temperature,
          'max_tokens': _maxTokens,
          'top_p': 0.9,
          'frequency_penalty': 0.3,
          'presence_penalty': 0.3,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices']?[0]?['message']?['content'] as String?;
        _currentStatus = AIIStatus.online;

        if (content != null && content.isNotEmpty) {
          // استخراج المواضيع ذات الصلة
          final topics = _extractRelatedTopics(userMessage);

          return AIResponse(
            text: content.trim(),
            isFromLLM: true,
            relevantTopics: topics,
            status: AIIStatus.online,
          );
        }
      }

      _currentStatus = AIIStatus.error;
      return const AIResponse(
        text: '',
        isFromLLM: false,
        status: AIIStatus.error,
      );
    } on TimeoutException {
      _currentStatus = AIIStatus.error;
      return const AIResponse(
        text: '',
        isFromLLM: false,
        status: AIIStatus.error,
      );
    } catch (e) {
      _currentStatus = AIIStatus.error;
      return const AIResponse(
        text: '',
        isFromLLM: false,
        status: AIIStatus.error,
      );
    }
  }

  /// Headers الخاصة بالAPI
  static Map<String, String> _headers() => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $_apiKey',
  };

  /// استخراج المواضيع ذات الصلة لاقتراحات المتابعة
  static List<String> _extractRelatedTopics(String message) {
    final norm = SmartNLP.normalize(message);
    final topics = <String>[];

    final topicMap = {
      'تطعيم|لقاح|تحصين': 'تطعيمات طفلك',
      'اثار|جانبي|اعراض': 'الآثار الجانبية',
      'حراره|سخونه': 'حرارة بعد التطعيم',
      'حصبه|mr': 'تطعيم الحصبة',
      'شلل|opv|ipv': 'شلل الأطفال',
      'خماسي|penta': 'التطعيم الخماسي',
      'رئوي|pcv': 'التطعيم الرئوي',
      'روتا': 'الروتا فيروس',
      'مجاني|بلاش': 'هل التطعيم مجاني؟',
      'توحد|اوتيزم': 'التطعيم والتوحد',
      'مبتسر|خديج': 'الأطفال المبتسرين',
      'حوامل|حامل': 'تطعيم الحوامل',
      'اشراف|supervision': 'الإشراف الداعم',
      'وسيط|intermediate': 'إدارة المستوى الوسيط',
      'سلسله|تبريد|cold': 'سلسلة التبريد',
      'حمل|nids|campaign': 'حملات التطعيم',
      'مدرس|school': 'تحصين المدارس',
      'تسرب|dropout': 'تحليل التسرب',
      'مخزون|stock': 'إدارة المخزون',
      'وباء|outbreak': 'الاستجابة للأوبئة',
      'vvm': 'مؤشر صلاحية اللقاح',
      'فيتامين|vitamin': 'فيتامين أ',
      'bcg|سل|درن': 'تطعيم BCG',
    };

    for (final entry in topicMap.entries) {
      final patterns = entry.key.split('|');
      for (final pattern in patterns) {
        if (norm.contains(pattern)) {
          if (!topics.contains(entry.value)) topics.add(entry.value);
          break;
        }
      }
    }

    return topics;
  }

  /// بناء اقتراحات رد سريع بناءً على سياق المحادثة
  static List<String> generateQuickReplySuggestions(String userMessage, String aiResponse) {
    final suggestions = <String>[];
    final norm = SmartNLP.normalize(userMessage);

    // اقتراحات حسب السياق
    if (norm.contains('تطعيم') || norm.contains('لقاح')) {
      suggestions.addAll(['وش الآثار الجانبية؟', 'هل التطعيم مجاني؟', 'وين أطعم؟']);
    }
    if (norm.contains('اثار') || norm.contains('جانبي')) {
      suggestions.addAll(['متى أروح الطبيب؟', 'وش أسوي؟', 'هل طبيعي؟']);
    }
    if (norm.contains('حصبه')) {
      suggestions.addAll(['كم جرعة؟', 'متى الجرعة الثانية؟', 'وش خطورة الحصبة؟']);
    }
    if (norm.contains('شلل')) {
      suggestions.addAll(['الفرق بين OPV و IPV؟', 'هل اليمن خالية؟', 'كم جرعة شلل؟']);
    }
    if (norm.contains('مبتسر') || norm.contains('خديج')) {
      suggestions.addAll(['متى أطعمه؟', 'وش الفرق عن الطفل العادي؟', 'هل يحتاج رعاية خاصة؟']);
    }
    if (norm.contains('اشراف') || norm.contains('وسيط')) {
      suggestions.addAll(['وش المؤشرات المطلوبة؟', 'كيف التخطيط الدقيق؟', 'وش دور المدير؟']);
    }
    if (norm.contains('حراره') || norm.contains('سخونه')) {
      suggestions.addAll(['متى أخاف؟', 'وش أسوي للحرارة؟', 'هل أطعم وهو حرارته عالية؟']);
    }

    // اقتراحات عامة إذا كانت القائمة فارغة
    if (suggestions.isEmpty) {
      suggestions.addAll([
        'تطعيمات طفلي حسب عمره',
        'وش الآثار الجانبية؟',
        'هل التطعيم مجاني؟',
        'الإشراف الداعم',
        'إدارة المستوى الوسيط',
      ]);
    }

    return suggestions.take(4).toList();
  }
}
