import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

/// Armor Tracker widget — shows armor type name and baseScore slots as shield icons.
/// Filled = blue (used), unfilled = dark.
class ArmorTracker extends StatelessWidget {
  final String armorType;
  final int baseScore;
  final int markedSlots;
  final void Function(int) onChanged;

  const ArmorTracker({
    super.key,
    required this.armorType,
    required this.baseScore,
    required this.markedSlots,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Armor',
                style: GoogleFonts.cinzel(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.armor,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            _capitalize(armorType),
            style: GoogleFonts.crimsonText(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 5,
            runSpacing: 5,
            alignment: WrapAlignment.center,
            children: List.generate(baseScore, (i) {
              final slotIndex = i + 1;
              final filled = i < markedSlots;
              return GestureDetector(
                onTap: () {
                  if (filled && slotIndex == markedSlots) {
                    onChanged(markedSlots - 1);
                  } else {
                    onChanged(slotIndex);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 26,
                  height: 26,
                  child: Icon(
                    Icons.shield,
                    size: 26,
                    color: filled ? AppColors.armor : AppColors.armorEmpty,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 6),
          TextButton.icon(
            onPressed: markedSlots > 0 ? () => onChanged(0) : null,
            icon: const Icon(Icons.refresh, size: 14),
            label: Text(
              'Clear All',
              style: GoogleFonts.crimsonText(fontSize: 12),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
