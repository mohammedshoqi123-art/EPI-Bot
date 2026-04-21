import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_theme.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const HomeScreen(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A6B3C),
              Color(0xFF0D4A28),
              Color(0xFF0A3D20),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated background circles
            ...List.generate(5, (i) {
              return Positioned(
                top: 100.0 + i * 120,
                left: -50.0 + i * 30,
                child: Container(
                  width: 200 + i * 50,
                  height: 200 + i * 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.03),
                  ),
                ).animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(duration: Duration(seconds: 3 + i), begin: const Offset(0.8, 0.8), end: const Offset(1.1, 1.1))
                    .then()
                    .fadeIn(duration: 500.ms),
              );
            }),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // Animated logo
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD4A843).withOpacity(0.3 + 0.2 * _pulseController.value),
                              blurRadius: 30 + 15 * _pulseController.value,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Background glow
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.primaryColor.withOpacity(0.05 + 0.05 * _pulseController.value),
                              ),
                            ),
                            // Icon
                            const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('💉', style: TextStyle(fontSize: 48)),
                                SizedBox(height: 4),
                                Text('🇾🇪', style: TextStyle(fontSize: 20)),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // Title with staggered animation
                  const Text(
                    'مستشار التحصين',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      fontFamily: 'Tajawal',
                      letterSpacing: 1,
                    ),
                  ).animate().fadeIn(delay: 200.ms, duration: 600.ms)
                      .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic),

                  const SizedBox(height: 10),

                  const Text(
                    'الذكي',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w300,
                      color: AppTheme.secondaryColor,
                      fontFamily: 'Tajawal',
                    ),
                  ).animate().fadeIn(delay: 400.ms, duration: 600.ms),

                  const SizedBox(height: 20),

                  // Subtitle
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: AppTheme.secondaryColor.withOpacity(0.4)),
                    ),
                    child: const Text(
                      '🇾🇪 برنامج التحصين الموسع - اليمن',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppTheme.secondaryColor,
                        fontFamily: 'Tajawal',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ).animate().fadeIn(delay: 600.ms, duration: 600.ms)
                      .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),

                  const SizedBox(height: 16),

                  // Feature pills
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _featurePill('🤖', 'ذكي'),
                      const SizedBox(width: 10),
                      _featurePill('📵', 'بدون إنترنت'),
                      const SizedBox(width: 10),
                      _featurePill('📚', '50+ موضوع'),
                    ],
                  ).animate().fadeIn(delay: 800.ms, duration: 600.ms),

                  const Spacer(flex: 2),

                  // Loading section
                  Column(
                    children: [
                      SizedBox(
                        width: 36,
                        height: 36,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ).animate().fadeIn(delay: 1000.ms),
                      const SizedBox(height: 16),
                      Text(
                        'جاري تحميل قاعدة المعرفة...',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 13,
                          fontFamily: 'Tajawal',
                        ),
                      ).animate().fadeIn(delay: 1200.ms),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Bottom info
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      children: [
                        Text(
                          'دليل التحصين الموسع - اليمن أغسطس 2025',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.3),
                            fontSize: 11,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'وزارة الصحة العامة والسكان',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.3),
                            fontSize: 11,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 1500.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _featurePill(String emoji, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontFamily: 'Tajawal',
            ),
          ),
        ],
      ),
    );
  }
}
