import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import 'consultation_center_screen.dart';
import 'schedule_screen.dart';
import 'vaccine_card_screen.dart';

// ══════════════════════════════════════════════════════════════
//  الشاشة الرئيسية — 3 تبويبات فقط
//  1. مركز الاستشارات (شات عام + شلل + إيصالي + تحليل)
//  2. الجدول الوطني
//  3. بطاقة التطعيم
// ══════════════════════════════════════════════════════════════

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          ConsultationCenterScreen(), // 0
          ScheduleScreen(),           // 1
          VaccineCardScreen(),        // 2
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: Colors.grey.shade400,
          selectedLabelStyle: const TextStyle(
            fontFamily: 'Tajawal',
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 10,
          ),
          iconSize: 24,
          items: [
            _navItem('🏥', 'الاستشارات', 0),
            _navItem('📅', 'الجدول', 1),
            _navItem('📋', 'البطاقة', 2),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _navItem(String emoji, String label, int index) {
    final isSelected = _currentIndex == index;
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutBack,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 14 : 4,
          vertical: isSelected ? 5 : 0,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          emoji,
          style: TextStyle(fontSize: isSelected ? 22 : 19),
        ),
      ),
      label: label,
    );
  }
}
