import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors (Sleek Modern Linear/Notion inspired)
  static const Color primary = Color(0xFF6366F1); // Indigo Primary
  static const Color primaryVariant = Color(0xFF4F46E5);
  static const Color secondary = Color(0xFF10B981); // Emerald Secondary
  static const Color accent = Color(0xFFF59E0B); // Amber Accent

  // Background Colors - Dark Mode
  static const Color darkBackground = Color(0xFF0F172A); // Slate 900
  static const Color darkSurface = Color(0xFF1E293B); // Slate 800
  static const Color darkSurfaceElevated = Color(0xFF334155); // Slate 700
  static const Color darkBorder = Color(0xFF334155);

  // Background Colors - Light Mode
  static const Color lightBackground = Color(0xFFF8FAFC); // Slate 50
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFF1F5F9); // Slate 100
  static const Color lightBorder = Color(0xFFE2E8F0);

  // Text Colors
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);

  // Status & Alert Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Utilization Heatmap Gradients
  static const Color lowUtilization = Color(0xFF10B981); // Green (<50%)
  static const Color optimalUtilization = Color(0xFF3B82F6); // Blue (50-85%)
  static const Color highUtilization = Color(0xFFF59E0B); // Orange (85-95%)
  static const Color overloaded = Color(0xFFEF4444); // Red (>95%)
}
