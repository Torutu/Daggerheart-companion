import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/game_constants.dart';

/// Hope Tracker — diamond/rhombus shapes matching the official Daggerheart sheet.
/// Filled diamonds = active Hope. Outlined diamonds = empty slots.
class HopeTracker extends StatelessWidget {
  final int value;
  final void Function(int) onChanged;

  const HopeTracker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'HOPE  ',
          style: GoogleFonts.cinzel(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.hope,
            letterSpacing: 1.0,
          ),
        ),
        ...List.generate(GameConstants.maxHope, (i) {
          final filled = i < value;
          return GestureDetector(
            onTap: () {
              final tappedValue = i + 1;
              onChanged(tappedValue == value ? value - 1 : tappedValue);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: _DiamondIcon(filled: filled),
            ),
          );
        }),
      ],
    );
  }
}

/// A single diamond/rhombus token — matches the official sheet's Hope tokens.
class _DiamondIcon extends StatelessWidget {
  final bool filled;
  const _DiamondIcon({required this.filled});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 20,
      height: 20,
      child: CustomPaint(
        painter: _DiamondPainter(filled: filled),
      ),
    );
  }
}

class _DiamondPainter extends CustomPainter {
  final bool filled;
  const _DiamondPainter({required this.filled});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.44;

    final path = Path()
      ..moveTo(cx, cy - r)   // top
      ..lineTo(cx + r, cy)   // right
      ..lineTo(cx, cy + r)   // bottom
      ..lineTo(cx - r, cy)   // left
      ..close();

    if (filled) {
      // Filled diamond with inner highlight
      canvas.drawPath(
        path,
        Paint()
          ..color = AppColors.hope
          ..style = PaintingStyle.fill,
      );
      // Inner smaller diamond (like the official sheet's design)
      final innerR = r * 0.45;
      final innerPath = Path()
        ..moveTo(cx, cy - innerR)
        ..lineTo(cx + innerR, cy)
        ..lineTo(cx, cy + innerR)
        ..lineTo(cx - innerR, cy)
        ..close();
      canvas.drawPath(
        innerPath,
        Paint()
          ..color = AppColors.textOnPrimary.withAlpha(60)
          ..style = PaintingStyle.fill,
      );
    } else {
      // Outlined diamond
      canvas.drawPath(
        path,
        Paint()
          ..color = AppColors.textDisabled
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(_DiamondPainter old) => old.filled != filled;
}
