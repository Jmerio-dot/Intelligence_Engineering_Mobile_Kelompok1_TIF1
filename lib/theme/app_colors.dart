import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ──────────── LIGHT THEME (app-theme.css) ────────────
  static const Color bg = Color(0xFFF0F7FF);
  static const Color bg2 = Color(0xFFE0F0FF);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFC8E6FA);
  static const Color cyan = Color(0xFF0096C7);
  static const Color ocean = Color(0xFF023E8A);
  static const Color sky = Color(0xFF48CAE4);
  static const Color skyLight = Color(0xFF90E0EF);
  static const Color primaryBlue = Color(0xFF0077B6);
  static const Color text = Color(0xFF0D2D4A);
  static const Color text2 = Color(0xFF3A6080);
  static const Color muted = Color(0xFF7AACC8);
  static const Color border = Color(0xFFC8E6FA);
  static const Color inputBg = Color(0xFFF5FBFF);
  static const Color hoverBg = Color(0xFFF5FBFF);

  // ──────────── DARK THEME (styles.css) ────────────
  static const Color darkBg = Color(0xFF050508);
  static const Color darkBgSecondary = Color(0xFF0D0D1A);
  static const Color darkCyan = Color(0xFF00D4FF);
  static const Color darkPurple = Color(0xFF8B5CF6);
  static const Color darkPurpleDark = Color(0xFF6D28D9);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);
  static const Color darkBorder = Color(0x14FFFFFF);
  static const Color darkCardBg = Color(0x0AFFFFFF);

  // ──────────── SIDEBAR GRADIENT ────────────
  static const Color sidebarTop = Color(0xFF012A6B);
  static const Color sidebarMid1 = Color(0xFF023E8A);
  static const Color sidebarMid2 = Color(0xFF0077B6);
  static const Color sidebarBottom = Color(0xFF0096C7);

  // ──────────── GRADIENTS ────────────
  static const LinearGradient gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [ocean, cyan, sky],
  );

  static const LinearGradient gradient2 = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryBlue, sky],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkCyan, darkPurple],
  );

  static const LinearGradient sidebarGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [sidebarTop, sidebarMid1, sidebarMid2, sidebarBottom],
  );

  static const LinearGradient loginLeftGradient = LinearGradient(
    begin: Alignment(-0.5, -1),
    end: Alignment(0.5, 1),
    colors: [
      Color(0xFF023E8A),
      Color(0xFF0077B6),
      Color(0xFF0096C7),
      Color(0xFF48CAE4),
      Color(0xFF90E0EF),
    ],
  );

  // ──────────── STATUS BADGE COLORS ────────────
  static const Map<String, Color> statusBg = {
    'todo': Color(0xFFF1F5F9),
    'in_progress': Color(0xFFE0F2FE),
    'in_review': Color(0xFFEDE9FE),
    'done': Color(0xFFDCFCE7),
  };

  static const Map<String, Color> statusText = {
    'todo': Color(0xFF64748B),
    'in_progress': Color(0xFF0369A1),
    'in_review': Color(0xFF6D28D9),
    'done': Color(0xFF15803D),
  };

  static const Map<String, String> statusLabel = {
    'todo': 'To Do',
    'in_progress': 'In Progress',
    'in_review': 'In Review',
    'done': 'Done',
  };

  // ──────────── PRIORITY COLORS ────────────
  static const Map<String, Color> priorityColor = {
    'critical': Color(0xFFDC2626),
    'high': Color(0xFFEA580C),
    'medium': Color(0xFFCA8A04),
    'low': Color(0xFF16A34A),
  };

  static const Map<String, Color> priorityBg = {
    'critical': Color(0xFFFEE2E2),
    'high': Color(0xFFFFEDD5),
    'medium': Color(0xFFFEF9C3),
    'low': Color(0xFFDCFCE7),
  };

  static const Map<String, Color> priorityText = {
    'critical': Color(0xFFB91C1C),
    'high': Color(0xFFC2410C),
    'medium': Color(0xFFA16207),
    'low': Color(0xFF15803D),
  };

  static const Map<String, String> priorityIcon = {
    'critical': '🔴',
    'high': '🟠',
    'medium': '🟡',
    'low': '🟢',
  };

  // ──────────── TYPE ICONS ────────────
  static const Map<String, String> typeIcon = {
    'story': '📗',
    'task': '✅',
    'bug': '🐛',
    'epic': '⚡',
    'subtask': '🔲',
  };

  // ──────────── ROLE BADGE COLORS ────────────
  static const Map<String, Color> roleBg = {
    'admin': Color(0xFFFEF3C7),
    'member': Color(0xFFE0F2FE),
    'viewer': Color(0xFFF1F5F9),
  };

  static const Map<String, Color> roleText = {
    'admin': Color(0xFF92400E),
    'member': Color(0xFF0369A1),
    'viewer': Color(0xFF64748B),
  };

  // ──────────── CHART COLORS ────────────
  static const Color chartTodo = Color(0xFF94A3B8);
  static const Color chartInProgress = Color(0xFF3B82F6);
  static const Color chartInReview = Color(0xFFF59E0B);
  static const Color chartDone = Color(0xFF22C55E);

  static const Color chartCritical = Color(0xFFEF4444);
  static const Color chartHigh = Color(0xFFF97316);
  static const Color chartMedium = Color(0xFFEAB308);
  static const Color chartLow = Color(0xFF22C55E);

  // ──────────── MISC ────────────
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color dangerBg = Color(0xFFFFF1F2);
  static const Color dangerBorder = Color(0xFFFECDD3);
  static const Color dangerText = Color(0xFFBE123C);
  static const Color dangerButton = Color(0xFFE11D48);
  static const Color teal = Color(0xFF0D9488);
  static const Color tealLight = Color(0xFF0891B2);
}
