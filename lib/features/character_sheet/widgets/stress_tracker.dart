import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

/// Stress Tracker — rectangular slot boxes matching the official Daggerheart sheet.
/// Filled slots = solid purple. Empty slots = outlined rectangle.
class StressTracker extends StatelessWidget {
  final int current;
  final int max;
  final void Function(int) onChanged;

  const StressTracker({
    super.key,
    required this.current,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label row
        Row(
          children: [
            Text(
              'STRESS',
              style: GoogleFonts.cinzel(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 1.2,
              ),
            ),
            const Spacer(),
            Text(
              '$current/$max',
              style: GoogleFonts.cinzel(
                fontSize: 9,
                color: AppColors.textDisabled,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        // Slot grid
        Wrap(
          spacing: 3,
          runSpacing: 3,
          children: List.generate(max, (i) {
            final filled = i < current;
            return GestureDetector(
              onTap: () {
                final tapped = i + 1;
                onChanged(tapped == current ? current - 1 : tapped);
              },
              child: _StressSlot(filled: filled),
            );
          }),
        ),
      ],
    );
  }
}

class _StressSlot extends StatelessWidget {
  final bool filled;
  const _StressSlot({required this.filled});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      width: 18,
      height: 14,
      decoration: BoxDecoration(
        color: filled ? AppColors.stress : Colors.transparent,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(
          color: filled
              ? AppColors.stress
              : AppColors.textDisabled.withAlpha(160),
          width: filled ? 0 : 1,
        ),
      ),
    );
  }
}
