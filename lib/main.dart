import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'constants/app_theme.dart';
import 'services/chat_service.dart';
import 'services/vaccination_service.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // تهيئة الذكاء الاصطناعي في الخلفية
  final chatService = ChatService();
  chatService.initializeAI();
  runApp(YemenEPIBot(chatService: chatService));
}

class YemenEPIBot extends StatelessWidget {
  final ChatService chatService;
  const YemenEPIBot({super.key, required this.chatService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: chatService),
        ChangeNotifierProvider(create: (_) => VaccinationService()),
      ],
      child: MaterialApp(
        title: 'مستشار التحصين - اليمن',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        locale: const Locale('ar', 'YE'),
        supportedLocales: const [
          Locale('ar', 'YE'),
          Locale('en', 'US'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          );
        },
        home: const SplashScreen(),
      ),
    );
  }
}
