import 'package:flutter/material.dart';

enum StatusBadgeType { success, warning, error, info, neutral }

class StatusBadge extends StatelessWidget {
  final String label;
  final StatusBadgeType type;

  const StatusBadge({
    super.key,
    required this.label,
    this.type = StatusBadgeType.neutral,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;

    switch (type) {
      case StatusBadgeType.success:
        bg = const Color(0xFF10B981).withOpacity(0.15);
        text = const Color(0xFF10B981);
        break;
      case StatusBadgeType.warning:
        bg = const Color(0xFFF59E0B).withOpacity(0.15);
        text = const Color(0xFFF59E0B);
        break;
      case StatusBadgeType.error:
        bg = const Color(0xFFEF4444).withOpacity(0.15);
        text = const Color(0xFFEF4444);
        break;
      case StatusBadgeType.info:
        bg = const Color(0xFF3B82F6).withOpacity(0.15);
        text = const Color(0xFF3B82F6);
        break;
      case StatusBadgeType.neutral:
        bg = Colors.grey.withOpacity(0.15);
        text = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: text.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: text),
      ),
    );
  }
}
