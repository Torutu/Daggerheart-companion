import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/srd/classes_data.dart';

class StepClass extends StatefulWidget {
  final String? selected;
  final void Function(String) onChanged;

  const StepClass({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  State<StepClass> createState() => _StepClassState();
}

class _StepClassState extends State<StepClass>
    with SingleTickerProviderStateMixin {
  late final AnimationController _smokeCtrl;

  @override
  void initState() {
    super.initState();
    _smokeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _smokeCtrl.dispose();
    super.dispose();
  }

  List<Color> _domainColors() {
    if (widget.selected == null) return [];
    final cls = classById(widget.selected!);
    if (cls == null) return [];
    return cls.domains.map(AppColors.domainColor).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = _domainColors();

    return Stack(
      children: [
        // ── Swirling smoke background ────────────────────────────────────
        if (colors.isNotEmpty)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _smokeCtrl,
              builder: (_, __) => CustomPaint(
                painter: _SmokePainter(
                  colors: colors,
                  t: _smokeCtrl.value,
                ),
              ),
            ),
          ),

        // ── Content ──────────────────────────────────────────────────────
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose Your Class',
                style: GoogleFonts.cinzel(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Your class defines your role, abilities, and domain cards.',
                style: GoogleFonts.crimsonText(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 14),
              ...allClasses.map((classDef) => _buildClassCard(classDef)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClassCard(ClassDefinition classDef) {
    final isSelected = classDef.id == widget.selected;
    final domainColors =
        classDef.domains.map(AppColors.domainColor).toList();
    final accentColor = domainColors.isNotEmpty ? domainColors.first : AppColors.primary;

    return GestureDetector(
      onTap: () => widget.onChanged(classDef.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withAlpha(22)
              : AppColors.cardBackground.withAlpha(220),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? accentColor : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withAlpha(60),
                    blurRadius: 12,
                    spreadRadius: 0,
                  )
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: name + domain chips
            Container(
              padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
              decoration: BoxDecoration(
                color: isSelected
                    ? accentColor.withAlpha(30)
                    : AppColors.surfaceVariant,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(9)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      classDef.name,
                      style: GoogleFonts.cinzel(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? accentColor : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  // Domain chips
                  ...classDef.domains.map((domain) {
                    final c = AppColors.domainColor(domain);
                    return Container(
                      margin: const EdgeInsets.only(left: 5),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: c.withAlpha(40),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: c.withAlpha(130)),
                      ),
                      child: Text(
                        domain.toUpperCase(),
                        style: GoogleFonts.cinzel(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: c,
                          letterSpacing: 0.6,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            // Body: description + stats
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    classDef.description,
                    style: GoogleFonts.crimsonText(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Stat row
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _stat('HP', '${classDef.startingHp}'),
                      _stat('Evasion', '${classDef.startingEvasion}'),
                      _stat('Armor', '${classDef.startingArmorSlots}'),
                      if (classDef.spellcastTrait != null)
                        _stat('Cast',
                            _cap(classDef.spellcastTrait!)),
                    ],
                  ),
                  // Class feature — shown only when selected
                  if (isSelected) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: accentColor.withAlpha(14),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: accentColor.withAlpha(60)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            classDef.classFeatureName,
                            style: GoogleFonts.cinzel(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: accentColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            classDef.classFeatureDescription,
                            style: GoogleFonts.crimsonText(
                              fontSize: 12,
                              color: AppColors.textPrimary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.border),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label ',
              style: GoogleFonts.cinzel(
                  fontSize: 9, color: AppColors.textDisabled),
            ),
            TextSpan(
              text: value,
              style: GoogleFonts.cinzel(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ── Smoke painter ─────────────────────────────────────────────────────────────

class _SmokePainter extends CustomPainter {
  final List<Color> colors;
  final double t; // 0.0 → 1.0, repeating

  const _SmokePainter({required this.colors, required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    if (colors.isEmpty) return;

    // Each domain color gets 2 blobs orbiting at different speeds/phases
    final blobs = <_Blob>[];
    for (int ci = 0; ci < colors.length; ci++) {
      final color = colors[ci];
      // Two blobs per domain, offset in phase
      blobs.add(_Blob(
        color: color.withAlpha(55),
        cx: 0.25 + ci * 0.35,
        cy: 0.3 + ci * 0.15,
        rx: 0.28,
        ry: 0.18,
        phase: ci * math.pi * 0.7,
        speed: 1.0 + ci * 0.3,
        radius: size.shortestSide * 0.38,
      ));
      blobs.add(_Blob(
        color: color.withAlpha(35),
        cx: 0.6 - ci * 0.15,
        cy: 0.65 + ci * 0.1,
        rx: 0.22,
        ry: 0.25,
        phase: ci * math.pi * 1.3 + math.pi,
        speed: 0.7 + ci * 0.4,
        radius: size.shortestSide * 0.30,
      ));
    }

    for (final blob in blobs) {
      final angle = t * 2 * math.pi * blob.speed + blob.phase;
      final x = (blob.cx + math.sin(angle) * blob.rx) * size.width;
      final y = (blob.cy + math.cos(angle * 0.8) * blob.ry) * size.height;

      canvas.drawCircle(
        Offset(x, y),
        blob.radius,
        Paint()
          ..color = blob.color
          ..maskFilter =
              MaskFilter.blur(BlurStyle.normal, blob.radius * 0.55),
      );
    }
  }

  @override
  bool shouldRepaint(_SmokePainter old) =>
      old.t != t || old.colors != colors;
}

class _Blob {
  final Color color;
  final double cx, cy; // center fraction of canvas
  final double rx, ry; // orbit radius fraction
  final double phase;
  final double speed;
  final double radius;

  const _Blob({
    required this.color,
    required this.cx,
    required this.cy,
    required this.rx,
    required this.ry,
    required this.phase,
    required this.speed,
    required this.radius,
  });
}
