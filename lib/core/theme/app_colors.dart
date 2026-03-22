import 'package:flutter/material.dart';

/// Daggerheart Companion — Hope × Fear Palette
/// Dark purple-indigo base (fear/dread) + golden amber accents (hope/light).
class AppColors {
  AppColors._();

  // ── Backgrounds ──────────────────────────────────────────────────────────
  static const Color background    = Color(0xFF0D0B18); // near-black, deep purple
  static const Color surface       = Color(0xFF16122A); // dark purple
  static const Color surfaceVariant= Color(0xFF1E1840); // medium purple
  static const Color cardBackground= Color(0xFF110E24); // deepest purple card

  // ── Primary accent: HOPE (golden amber) ──────────────────────────────────
  static const Color primary       = Color(0xFFD4920A); // old gold / hope light
  static const Color primaryDark   = Color(0xFF9E6B08); // darker gold
  static const Color primaryGlow   = Color(0xFFF5B93A); // bright hope highlight

  // ── Secondary accent: FEAR (vivid purple) ────────────────────────────────
  static const Color secondary     = Color(0xFF7C3AED); // vivid indigo-purple
  static const Color secondaryLight= Color(0xFF9D5CF5); // lighter fear

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFF0E6FA); // soft lavender-white
  static const Color textSecondary = Color(0xFFB8A8D4); // muted lavender
  static const Color textDisabled  = Color(0xFF5C4E7A); // dark muted purple
  static const Color textOnPrimary = Color(0xFF0D0B18); // dark text ON gold buttons

  // ── Game trackers ─────────────────────────────────────────────────────────
  static const Color hope          = Color(0xFFF59E0B); // bright amber flame
  static const Color hopeEmpty     = Color(0xFF1E1840);
  static const Color stress        = Color(0xFF9333EA); // fear-purple stress
  static const Color stressEmpty   = Color(0xFF1A1238);
  static const Color hp            = Color(0xFFDC4040); // blood red HP
  static const Color hpEmpty       = Color(0xFF2D1218);
  static const Color armor         = Color(0xFF60A5FA); // steel blue
  static const Color armorEmpty    = Color(0xFF152035);

  // ── Damage thresholds ─────────────────────────────────────────────────────
  static const Color thresholdMinor  = Color(0xFF4ADE80); // green
  static const Color thresholdMajor  = Color(0xFFFB923C); // orange
  static const Color thresholdSevere = Color(0xFFF87171); // red-pink

  // ── Domains ───────────────────────────────────────────────────────────────
  static const Color domainArcana   = Color(0xFFB57BEE); // vivid violet
  static const Color domainBlade    = Color(0xFFEF5350); // red
  static const Color domainBone     = Color(0xFFB0BEC5); // cool grey
  static const Color domainCodex    = Color(0xFF42A5F5); // sky blue
  static const Color domainGrace    = Color(0xFFFFC107); // gold
  static const Color domainMidnight = Color(0xFF546E7A); // dark slate
  static const Color domainSage     = Color(0xFF66BB6A); // green
  static const Color domainSplendor = Color(0xFFEC407A); // pink
  static const Color domainValor    = Color(0xFFFF7043); // deep orange

  // ── Dividers / borders ────────────────────────────────────────────────────
  static const Color divider = Color(0xFF2A2048);
  static const Color border  = Color(0xFF3D2E6A);

  static Color domainColor(String domain) {
    switch (domain.toLowerCase()) {
      case 'arcana':   return domainArcana;
      case 'blade':    return domainBlade;
      case 'bone':     return domainBone;
      case 'codex':    return domainCodex;
      case 'grace':    return domainGrace;
      case 'midnight': return domainMidnight;
      case 'sage':     return domainSage;
      case 'splendor': return domainSplendor;
      case 'valor':    return domainValor;
      default:         return primary;
    }
  }
}
