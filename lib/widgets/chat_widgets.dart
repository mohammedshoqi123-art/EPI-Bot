import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_theme.dart';

/// مؤشر "يكتب الآن..."
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, right: 50),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                return AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final delay = index * 0.3;
                    final value = (_controller.value - delay).clamp(0.0, 1.0);
                    final opacity = (0.4 + 0.6 * (value < 0.5 ? value * 2 : 2 - value * 2))
                        .clamp(0.3, 1.0);
                    final scale = 0.8 + 0.2 * (value < 0.5 ? value * 2 : 2 - value * 2);

                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(opacity),
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }
}

/// بطاقة تطعيم مدمجة في الشات
class InlineVaccineCard extends StatelessWidget {
  final String vaccineName;
  final String emoji;
  final String doseNumber;
  final String route;
  final String site;
  final VoidCallback? onTap;

  const InlineVaccineCard({
    super.key,
    required this.vaccineName,
    required this.emoji,
    required this.doseNumber,
    required this.route,
    required this.site,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Text(emoji, style: const TextStyle(fontSize: 22))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vaccineName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$doseNumber • $route',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade400),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1, end: 0);
  }
}

/// شريط بحث سريع
class QuickSearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final String hintText;

  const QuickSearchBar({
    super.key,
    required this.onSearch,
    this.hintText = 'ابحث عن تطعيم، مرض، أو سؤال...',
  });

  @override
  State<QuickSearchBar> createState() => _QuickSearchBarState();
}

class _QuickSearchBarState extends State<QuickSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _isExpanded ? 56 : 48,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_isExpanded ? 0.1 : 0.05),
            blurRadius: _isExpanded ? 15 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 12, left: 8),
            child: Icon(Icons.search, color: AppTheme.primaryColor, size: 22),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                  fontFamily: 'Tajawal',
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
              style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14),
              onTap: () => setState(() => _isExpanded = true),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  widget.onSearch(value.trim());
                }
                setState(() => _isExpanded = false);
              },
              onChanged: (value) {
                if (value.isEmpty) setState(() => _isExpanded = false);
              },
            ),
          ),
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: () {
                _controller.clear();
                setState(() => _isExpanded = false);
              },
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}

/// بطاقة إحصائية مصغّرة
class MiniStatCard extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final Color color;

  const MiniStatCard({
    super.key,
    required this.emoji,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
              fontFamily: 'Tajawal',
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontFamily: 'Tajawal',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// زر تفاعل متحرك
class AnimatedActionButton extends StatefulWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const AnimatedActionButton({
    super.key,
    required this.emoji,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  State<AnimatedActionButton> createState() => _AnimatedActionButtonState();
}

class _AnimatedActionButtonState extends State<AnimatedActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: (widget.color ?? AppTheme.primaryColor).withOpacity(_isPressed ? 0.15 : 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: (widget.color ?? AppTheme.primaryColor).withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: widget.color ?? AppTheme.primaryColor,
                fontFamily: 'Tajawal',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// بطاقة تذكير
class ReminderCard extends StatelessWidget {
  final String vaccineName;
  final String childName;
  final DateTime dueDate;
  final String emoji;
  final VoidCallback? onDismiss;
  final VoidCallback? onTap;

  const ReminderCard({
    super.key,
    required this.vaccineName,
    required this.childName,
    required this.dueDate,
    required this.emoji,
    this.onDismiss,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final daysLeft = dueDate.difference(DateTime.now()).inDays;
    final isOverdue = daysLeft < 0;
    final isUrgent = daysLeft <= 7 && daysLeft >= 0;

    return Dismissible(
      key: Key('reminder_${vaccineName}_$childName'),
      onDismissed: (_) => onDismiss?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.red),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isOverdue
                ? Colors.red.shade50
                : isUrgent
                    ? Colors.orange.shade50
                    : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isOverdue
                  ? Colors.red.shade200
                  : isUrgent
                      ? Colors.orange.shade200
                      : Colors.grey.shade200,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isOverdue
                      ? Colors.red.shade100
                      : isUrgent
                          ? Colors.orange.shade100
                          : AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vaccineName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      childName,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isOverdue
                      ? Colors.red.shade100
                      : isUrgent
                          ? Colors.orange.shade100
                          : Colors.green.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isOverdue
                      ? 'متأخر!'
                      : isUrgent
                          ? '$daysLeft أيام'
                          : '${(daysLeft / 7).ceil()} أسابيع',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isOverdue
                        ? Colors.red.shade700
                        : isUrgent
                            ? Colors.orange.shade700
                            : Colors.green.shade700,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 100 * (dueDate.millisecondsSinceEpoch % 5)));
  }
}

/// شريط تقدم دائري مصغّر
class MiniProgressIndicator extends StatelessWidget {
  final double progress;
  final String label;
  final Color color;
  final double size;

  const MiniProgressIndicator({
    super.key,
    required this.progress,
    required this.label,
    this.color = AppTheme.primaryColor,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: size * 0.25,
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontFamily: 'Tajawal',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontFamily: 'Tajawal',
          ),
        ),
      ],
    );
  }
}
