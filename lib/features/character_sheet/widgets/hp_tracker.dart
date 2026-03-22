import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

/// HP Tracker — rectangular slot boxes matching the official Daggerheart sheet.
/// Filled slots = solid red. Empty slots = outlined rectangle with dotted look.
class HpTracker extends StatelessWidget {
  final int current;
  final int max;
  final void Function(int) onChanged;

  const HpTracker({
    super.key,
    required this.current,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDown = max > 0 && current >= max;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label row
        Row(
          children: [
            Text(
              'HIT POINTS',
              style: GoogleFonts.cinzel(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 1.2,
              ),
            ),
            if (isDown) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.hp,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  'DOWN',
                  style: GoogleFonts.cinzel(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
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
        // Slot grid — wraps into rows of up to 10
        Wrap(
          spacing: 3,
          runSpacing: 3,
          children: List.generate(max, (i) {
            final filled = i < current;
            return GestureDetector(
              onTap: () {
                final tapped = i + 1;
                // Tapping the top filled slot clears it; tapping empty fills to there
                onChanged(tapped == current ? current - 1 : tapped);
              },
              child: _HpSlot(filled: filled),
            );
          }),
        ),
      ],
    );
  }
}

class _HpSlot extends StatelessWidget {
  final bool filled;
  const _HpSlot({required this.filled});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      width: 18,
      height: 14,
      decoration: BoxDecoration(
        color: filled ? AppColors.hp : Colors.transparent,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(
          color: filled
              ? AppColors.hp
              : AppColors.textDisabled.withAlpha(160),
          width: filled ? 0 : 1,
        ),
      ),
    );
  }
}
