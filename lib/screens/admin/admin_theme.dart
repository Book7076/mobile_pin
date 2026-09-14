import 'package:flutter/material.dart';

class AdminTheme {
  // Primary Palette matching Image 2
  static const Color primaryMaroon = Color(0xFF7B182D);
  static const Color primaryMaroonDark = Color(0xFF5A0E1E);
  static const Color primaryMaroonLight = Color(0xFF9B2A42);
  static const Color accentPink = Color(0xFFF9EAEF);
  
  // Background & Surface
  static const Color background = Color(0xFFFDFBFB);
  static const Color cardBg = Color(0xFFFFF9F9);
  static const Color cardBorder = Color(0xFFF6ECEE);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1E1E1E);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textMuted = Color(0xFF9E9E9E);
  
  // Status Colors
  static const Color statusPending = Color(0xFFF59E0B);
  static const Color statusApproved = Color(0xFF10B981);
  static const Color statusRejected = Color(0xFFEF4444);
  
  // Pill & Search Bar
  static const Color searchBorder = Color(0xFFE5E5EA);
  static const Color searchBg = Color(0xFFFFFFFF);
  static const Color searchIcon = Color(0xFF2E2E2E);
  
  // Floating Bottom Nav
  static const Color navBarBg = Color(0xFFFFFFFF);
  static const Color navSelected = Color(0xFF7B182D);
  static const Color navUnselected = Color(0xFFBDBDBD);

  // Card Shadow
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 12,
      spreadRadius: 0,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: primaryMaroon.withOpacity(0.02),
      blurRadius: 4,
      spreadRadius: 0,
      offset: const Offset(0, 1),
    ),
  ];

  // Floating Nav Shadow
  static List<BoxShadow> get navShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 20,
      spreadRadius: 2,
      offset: const Offset(0, 6),
    ),
  ];
}
