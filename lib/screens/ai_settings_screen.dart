// ══════════════════════════════════════════════════════════════════════════
//  شاشة إعدادات الذكاء الاصطناعي — EPI-Bot AI Configuration
// ══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../services/chat_service.dart';
import '../services/llm_service.dart';

class AISettingsScreen extends StatefulWidget {
  const AISettingsScreen({super.key});

  @override
  State<AISettingsScreen> createState() => _AISettingsScreenState();
}

class _AISettingsScreenState extends State<AISettingsScreen> {
  final _apiKeyController = TextEditingController();
  final _baseUrlController = TextEditingController();
  final _modelController = TextEditingController();
  bool _isConnecting = false;
  bool _obscureApiKey = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await LLMService.loadConfig();
    setState(() {
      _apiKeyController.text = LLMService.apiKey;
      _baseUrlController.text = LLMService.apiBaseUrl;
      _modelController.text = LLMService.model;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        ),
        title: const Text(
          '🧠 إعدادات الذكاء الاصطناعي',
          style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<ChatService>(
        builder: (context, chatService, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusCard(chatService),
                const SizedBox(height: 20),
                _buildApiKeySection(),
                const SizedBox(height: 16),
                _buildBaseUrlSection(),
                const SizedBox(height: 16),
                _buildModelSection(),
                const SizedBox(height: 24),
                _buildConnectButton(chatService),
                const SizedBox(height: 24),
                _buildInfoSection(),
                const SizedBox(height: 24),
                _buildToggleSection(chatService),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(ChatService chatService) {
    final status = chatService.aiStatus;
    final isOnline = status == AIIStatus.online;
    final isLoading = status == AIIStatus.loading;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isOnline
              ? [Colors.green.shade50, Colors.green.shade100]
              : isLoading
                  ? [Colors.orange.shade50, Colors.orange.shade100]
                  : [Colors.red.shade50, Colors.red.shade100],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOnline
              ? Colors.green.shade300
              : isLoading
                  ? Colors.orange.shade300
                  : Colors.red.shade300,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: (isOnline ? Colors.green : isLoading ? Colors.orange : Colors.red).withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: isLoading
                  ? const CircularProgressIndicator(strokeWidth: 3)
                  : Icon(
                      isOnline ? Icons.smart_toy : Icons.smart_toy_outlined,
                      size: 28,
                      color: isOnline ? Colors.green : Colors.red,
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOnline
                      ? 'الذكاء الاصطناعي متصل ✅'
                      : isLoading
                          ? 'جاري الاتصال... ⏳'
                          : 'الذكاء الاصطناعي غير متصل ❌',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Tajawal',
                    color: isOnline ? Colors.green.shade800 : Colors.red.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isOnline
                      ? 'البوت يستخدم ذكاء اصطناعي حقيقي للرد على أسئلتك'
                      : 'أدخل مفتاح API لتفعيل الذكاء الاصطناعي',
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'Tajawal',
                    color: isOnline ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApiKeySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🔑 مفتاح API',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Tajawal'),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _apiKeyController,
          obscureText: _obscureApiKey,
          textDirection: TextDirection.ltr,
          decoration: InputDecoration(
            hintText: 'sk-...',
            hintStyle: const TextStyle(fontFamily: 'monospace'),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: IconButton(
              icon: Icon(_obscureApiKey ? Icons.visibility : Icons.visibility_off),
              onPressed: () => setState(() => _obscureApiKey = !_obscureApiKey),
            ),
          ),
          style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildBaseUrlSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🌐 رابط API (اختياري)',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Tajawal'),
        ),
        const SizedBox(height: 4),
        Text(
          'الافتراضي: https://api.openai.com/v1',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontFamily: 'Tajawal'),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _baseUrlController,
          textDirection: TextDirection.ltr,
          decoration: InputDecoration(
            hintText: 'https://api.openai.com/v1',
            hintStyle: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildModelSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🤖 النموذج',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Tajawal'),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _modelController.text.isEmpty ? 'gpt-4o-mini' : _modelController.text,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          items: const [
            DropdownMenuItem(value: 'gpt-4o-mini', child: Text('GPT-4o Mini (سريع واقتصادي)')),
            DropdownMenuItem(value: 'gpt-4o', child: Text('GPT-4o (أقوى وأدق)')),
            DropdownMenuItem(value: 'gpt-4-turbo', child: Text('GPT-4 Turbo')),
            DropdownMenuItem(value: 'gpt-3.5-turbo', child: Text('GPT-3.5 Turbo (أسرع)')),
          ],
          onChanged: (value) {
            if (value != null) {
              _modelController.text = value;
            }
          },
        ),
      ],
    );
  }

  Widget _buildConnectButton(ChatService chatService) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isConnecting ? null : () => _connect(chatService),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: _isConnecting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Text(
                '🔗 اتصال وتفعيل الذكاء الاصطناعي',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Tajawal',
                ),
              ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '💡 كيف يعمل الذكاء الاصطناعي في البوت؟',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Tajawal'),
          ),
          const SizedBox(height: 10),
          _infoPoint('🧠', 'يستخدم نموذج لغة كبير (LLM) لفهم أسئلتك بالعربية'),
          _infoPoint('📚', 'يسترجع معلومات من قاعدة المعرفة المتخصصة (RAG)'),
          _infoPoint('🧬', 'يتذكر سياق المحادثة ومعلومات طفلك'),
          _infoPoint('🔄', 'إذا فشل الاتصال، يرجع للنظام المحلي تلقائياً'),
          _infoPoint('🔒', 'بياناتك محفوظة على جهازك فقط'),
        ],
      ),
    );
  }

  Widget _infoPoint(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, fontFamily: 'Tajawal', height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleSection(ChatService chatService) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: SwitchListTile(
        title: const Text(
          'تفعيل الذكاء الاصطناعي',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Tajawal'),
        ),
        subtitle: Text(
          chatService.isAIEnabled
              ? 'البوت يستخدم AI للرد على أسئلتك'
              : 'البوت يستخدم النظام المحلي فقط',
          style: TextStyle(fontSize: 12, fontFamily: 'Tajawal', color: Colors.grey.shade600),
        ),
        value: chatService.isAIEnabled,
        activeColor: AppTheme.primaryColor,
        onChanged: chatService.aiStatus == AIIStatus.online
            ? (value) => chatService.setAIEnabled(value)
            : null,
      ),
    );
  }

  Future<void> _connect(ChatService chatService) async {
    if (_apiKeyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('أدخل مفتاح API أولاً!', style: TextStyle(fontFamily: 'Tajawal')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isConnecting = true);

    final success = await chatService.configureAI(
      _apiKeyController.text.trim(),
      baseUrl: _baseUrlController.text.trim().isNotEmpty
          ? _baseUrlController.text.trim()
          : null,
      model: _modelController.text.trim().isNotEmpty
          ? _modelController.text.trim()
          : null,
    );

    setState(() => _isConnecting = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? '✅ تم الاتصال بالذكاء الاصطناعي بنجاح!'
                : '❌ فشل الاتصال — تأكد من مفتاح API',
            style: const TextStyle(fontFamily: 'Tajawal'),
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _baseUrlController.dispose();
    _modelController.dispose();
    super.dispose();
  }
}
