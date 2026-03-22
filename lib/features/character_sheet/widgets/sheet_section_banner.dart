import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

/// Dark chevron banner matching the official Daggerheart sheet section headers.
/// Draws a full-width ribbon with small pointed indents on the left and right
/// edges. Text is cream/light so it reads clearly on the dark background.
class SheetSectionBanner extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const SheetSectionBanner({
    super.key,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 26,
      child: CustomPaint(
        painter: _BannerPainter(),
        child: Padding(
          // Inset text away from the pointed edges
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                title.toUpperCase(),
                style: GoogleFonts.cinzel(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  // textPrimary (lavender-white) is fully readable on dark bg
                  color: AppColors.textPrimary,
                  letterSpacing: 1.6,
                ),
              ),
              if (trailing != null) ...[
                const Spacer(),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _BannerPainter extends CustomPainter {
  static const _bannerColor = Color(0xFF1A1438); // slightly lighter than card bg
  static const _borderColor = AppColors.border;

  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height;
    final w = size.width;
    final notch = h * 0.38; // depth of the chevron indent

    // Hexagonal ribbon: full width with pointed left & right indent
    final ribbon = Path()
      ..moveTo(0, 0)
      ..lineTo(w - notch, 0)
      ..lineTo(w, h / 2)
      ..lineTo(w - notch, h)
      ..lineTo(notch, h)
      ..lineTo(0, h / 2)
      ..close();

    canvas.drawPath(
      ribbon,
      Paint()
        ..color = _bannerColor
        ..style = PaintingStyle.fill,
    );

    // Subtle border / glow on top & bottom edges
    canvas.drawPath(
      ribbon,
      Paint()
        ..color = _borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // Thin gold accent line on the top edge only
    canvas.drawLine(
      Offset(notch, 0),
      Offset(w - notch, 0),
      Paint()
        ..color = AppColors.primary.withAlpha(120)
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_BannerPainter old) => false;
}
