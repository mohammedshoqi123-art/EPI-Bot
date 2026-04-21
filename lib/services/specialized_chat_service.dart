import 'dart:math';
import 'package:flutter/material.dart';
import '../models/vaccine_model.dart';
import 'smart_nlp.dart';
import 'context_manager.dart';

/// بوت استشارة متخصص — يمكن تهيئته بأي قاعدة معرفة
class SpecializedChatService extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  final ContextManager _ctx = ContextManager();

  final String botName;
  final String botEmoji;
  final String welcomeMessage;
  final Map<String, String> knowledgeBase;
  final Map<String, List<String>> keywordMap;
  final List<QuickReply> defaultReplies;
  final Map<String, List<QuickReply>> contextReplies;

  SpecializedChatService({
    required this.botName,
    required this.botEmoji,
    required this.welcomeMessage,
    required this.knowledgeBase,
    required this.keywordMap,
    required this.defaultReplies,
    this.contextReplies = const {},
  });

  void initialize() {
    if (_messages.isEmpty) {
      _addBotMessage(welcomeMessage, quickReplies: defaultReplies);
    }
  }

  void sendMessage(String text) {
    _messages.add(ChatMessage(id: _gid(), text: text, isBot: false, timestamp: DateTime.now()));
    notifyListeners();

    final ms = (200 + (text.length * 5)).clamp(200, 1200);
    Future.delayed(Duration(milliseconds: ms.toInt()), () {
      final resp = _process(text);
      _addBotMessage(resp.text, quickReplies: resp.quickReplies);
    });
  }

  _Resp _process(String raw) {
    final norm = SmartNLP.normalize(raw);

    // كشف الشكر
    if (SmartNLP.isThanking(norm)) {
      return _Resp('العفو! 😊 أي سؤال ثاني أنا موجود!', defaultReplies);
    }

    // تحية
    if (SmartNLP.isGreeting(norm)) {
      return _Resp('$botEmoji أهلاً! أنا $botName — كيف أقدر أساعدك؟', defaultReplies);
    }

    // متابعة
    if (RegExp(r'^(نعم|ايوه|ايه|اي|يب|لا|اشرح|وضح|بالتفصيل|تفاصيل|طيب|تمام|اوكي|زين|اوك|فاهمت|فهمت|واضح|شكرا|thanks)')
        .hasMatch(norm)) {
      return _handleFollowUp(norm);
    }

    // بحث في قاعدة المعرفة
    final found = _searchKB(norm);
    if (found != null) {
      _ctx.lastTopic = found;
      final replies = contextReplies[found] ?? defaultReplies;
      return _Resp(knowledgeBase[found] ?? 'عذراً، لا تتوفر معلومات حالياً', replies);
    }

    // بحث بالكلمات المفتاحية
    final keywordFound = _searchByKeywords(norm);
    if (keywordFound != null) {
      _ctx.lastTopic = keywordFound;
      final replies = contextReplies[keywordFound] ?? defaultReplies;
      return _Resp(knowledgeBase[keywordFound] ?? 'عذراً', replies);
    }

    // رد افتراضي
    return _handleDefault(norm);
  }

  String? _searchKB(String n) {
    for (final key in knowledgeBase.keys) {
      final kn = SmartNLP.normalize(key);
      if (n.contains(kn) || kn.contains(n)) return key;
    }
    return null;
  }

  String? _searchByKeywords(String n) {
    for (final entry in keywordMap.entries) {
      for (final kw in entry.value) {
        if (n.contains(SmartNLP.normalize(kw))) return entry.key;
      }
    }
    // بحث بالكلمات الفردية
    final words = n.split(' ').where((w) => w.length > 2).toList();
    for (final word in words) {
      for (final key in knowledgeBase.keys) {
        final kn = SmartNLP.normalize(key);
        if (kn.contains(word) && word.length > 3) return key;
      }
    }
    return null;
  }

  _Resp _handleFollowUp(String n) {
    if (RegExp(r'^(نعم|ايوه|ايه|اي|يب)').hasMatch(n)) {
      if (_ctx.lastTopic.isNotEmpty && knowledgeBase.containsKey(_ctx.lastTopic)) {
        return _Resp(knowledgeBase[_ctx.lastTopic] ?? '', contextReplies[_ctx.lastTopic] ?? defaultReplies);
      }
    }
    if (RegExp(r'^(لا|ما ابي|مو)').hasMatch(n)) {
      return _Resp('👍 تمام! إذا احتجت شيء ثاني أنا هنا.', defaultReplies);
    }
    if (RegExp(r'اشرح|وضح|بالتفصيل|تفاصيل|فهمني اكثر|اكثر').hasMatch(n)) {
      if (_ctx.lastTopic.isNotEmpty && knowledgeBase.containsKey(_ctx.lastTopic)) {
        return _Resp(knowledgeBase[_ctx.lastTopic] ?? '', contextReplies[_ctx.lastTopic] ?? defaultReplies);
      }
    }
    if (RegExp(r'^(طيب|تمام|زين|اوكي|اوك|شكرا|thanks|فاهمت|فهمت|واضح)').hasMatch(n)) {
      if (_ctx.lastTopic.isNotEmpty) {
        return _Resp('💡 تمام! تبي تعرف أكثر عن "${_ctx.lastTopic}"؟ أو عندك سؤال ثاني؟', defaultReplies);
      }
    }
    return _Resp('🤔 ممكن توضح أكثر وش تقصد؟', defaultReplies);
  }

  _Resp _handleDefault(String n) {
    if (_ctx.lastTopic.isNotEmpty) {
      return _Resp(
        '🤔 مش فاهم قصدك بالضبط. تبي تعرف أكثر عن "${_ctx.lastTopic}"؟\n\n'
        '💡 أو جرب تسأل بطريقة ثانية — أنا $botName وأقدر أساعدك!',
        defaultReplies,
      );
    }
    return _Resp(
      '🤖 أنا $botName $botEmoji\n\n'
      'أقدر أساعدك في كل شيء متعلق بالموضوع!\n\n'
      '💡 جرب تسأل عن أي شيء من الاقتراحات 👇',
      defaultReplies,
    );
  }

  void _addBotMessage(String text, {List<QuickReply>? quickReplies}) {
    _messages.add(ChatMessage(id: _gid(), text: text, isBot: true, timestamp: DateTime.now(), quickReplies: quickReplies));
    notifyListeners();
  }

  String _gid() => '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(99999)}';

  void clearChat() {
    _messages.clear(); _ctx.reset();
    notifyListeners(); initialize();
  }
}

class _Resp {
  final String text;
  final List<QuickReply>? quickReplies;
  _Resp(this.text, this.quickReplies);
}
