import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

/// Damage Thresholds — three boxes (Minor → Major → Severe) connected by
/// right-pointing arrows, matching the official Daggerheart character sheet.
class DamageThresholdsWidget extends StatelessWidget {
  final int minor;
  final int major;
  final int severe;

  const DamageThresholdsWidget({
    super.key,
    required this.minor,
    required this.major,
    required this.severe,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            _ThresholdBox(label: 'MINOR', value: minor, color: AppColors.thresholdMinor),
            _Arrow(),
            _ThresholdBox(label: 'MAJOR', value: major, color: AppColors.thresholdMajor),
            _Arrow(),
            _ThresholdBox(label: 'SEVERE', value: severe, color: AppColors.thresholdSevere),
          ],
        ),
      ],
    );
  }
}

class _ThresholdBox extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _ThresholdBox({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 62,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(100), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.cinzel(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$value',
            style: GoogleFonts.cinzel(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: color,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _Arrow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Icon(
        Icons.arrow_forward,
        size: 14,
        color: AppColors.textDisabled,
      ),
    );
  }
}
