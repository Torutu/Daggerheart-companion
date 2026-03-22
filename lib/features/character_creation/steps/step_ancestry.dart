import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/srd/ancestries_data.dart';

/// Ancestry selection step.
///
/// Single-ancestry: tap to select, both features shown, gold highlight.
///
/// Mixed-ancestry: the same list becomes a two-pick list.
///   - First pick  → highlighted gold  → provides Feature 1.
///   - Second pick → highlighted purple → provides Feature 2.
///   Tapping the first pick again clears it (and promotes second to first).
///   Tapping the second pick clears the second slot.
class StepAncestry extends StatelessWidget {
  final String? selected;
  final bool isMixed;
  final String? selected2;
  final void Function(String ancestryId, bool isMixed, String? ancestryId2)
      onChanged;

  const StepAncestry({
    super.key,
    required this.selected,
    required this.isMixed,
    required this.selected2,
    required this.onChanged,
  });

  void _handleTap(String id) {
    if (!isMixed) {
      // Simple single select / deselect
      onChanged(id == selected ? '' : id, false, null);
      return;
    }

    // Mixed mode logic
    if (id == selected) {
      // Tapped primary — clear it; promote secondary to primary if present
      onChanged(selected2 ?? '', true, null);
    } else if (id == selected2) {
      // Tapped secondary — clear secondary
      onChanged(selected ?? '', true, null);
    } else if (selected == null || selected!.isEmpty) {
      // Nothing picked yet — set as primary
      onChanged(id, true, selected2);
    } else if (selected2 == null || selected2!.isEmpty) {
      // Primary set, secondary empty — set as secondary
      onChanged(selected!, true, id);
    } else {
      // Both set — replace secondary
      onChanged(selected!, true, id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose Your Ancestry',
            style: GoogleFonts.cinzel(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your ancestry shapes your innate gifts and physical form.',
            style: GoogleFonts.crimsonText(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),

          // ── Mixed ancestry toggle ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Switch(
                  value: isMixed,
                  onChanged: (v) {
                    // When turning off mixed, keep primary, clear secondary
                    onChanged(selected ?? '', v, v ? selected2 : null);
                  },
                  activeColor: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mixed Ancestry',
                        style: GoogleFonts.cinzel(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (isMixed)
                        Text(
                          'Pick two — 1st gives Feature 1, 2nd gives Feature 2.',
                          style: GoogleFonts.crimsonText(
                            fontSize: 12,
                            color: AppColors.textDisabled,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Mixed status pills ─────────────────────────────────────────
          if (isMixed) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                _slotPill(
                  label: '① Primary',
                  value: selected != null && selected!.isNotEmpty
                      ? ancestryById(selected!)?.name ?? selected!
                      : null,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                _slotPill(
                  label: '② Secondary',
                  value: selected2 != null && selected2!.isNotEmpty
                      ? ancestryById(selected2!)?.name ?? selected2!
                      : null,
                  color: AppColors.secondary,
                ),
              ],
            ),
          ],

          const SizedBox(height: 14),

          // ── Ancestry list ──────────────────────────────────────────────
          ...allAncestries.map((ancestry) {
            final isPrimary = ancestry.id == selected;
            final isSecondary = ancestry.id == selected2;
            final isAnySelected = isPrimary || isSecondary;

            // Highlight color: gold for primary / purple for secondary
            final highlightColor =
                isPrimary ? AppColors.primary : AppColors.secondary;

            return GestureDetector(
              onTap: () => _handleTap(ancestry.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: isAnySelected
                      ? highlightColor.withAlpha(18)
                      : AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isAnySelected ? highlightColor : AppColors.border,
                    width: isAnySelected ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name header
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isAnySelected
                            ? highlightColor.withAlpha(30)
                            : AppColors.surfaceVariant,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(7),
                          topRight: Radius.circular(7),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            ancestry.name,
                            style: GoogleFonts.cinzel(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isAnySelected
                                  ? highlightColor
                                  : AppColors.textPrimary,
                            ),
                          ),
                          // Only show slot badges in mixed mode
                          if (isMixed && isPrimary) ...[
                            const Spacer(),
                            _badge('① Feature 1', AppColors.primary),
                          ] else if (isMixed && isSecondary) ...[
                            const Spacer(),
                            _badge('② Feature 2', AppColors.secondary),
                          ],
                        ],
                      ),
                    ),
                    // Feature 1 row
                    _featureRow(
                      label: isMixed ? '①' : '◆',
                      text: ancestry.featureTop,
                      highlight: isMixed ? isPrimary : isAnySelected,
                      highlightColor: AppColors.primary,
                    ),
                    // Feature 2 row
                    _featureRow(
                      label: isMixed ? '②' : '◆',
                      text: ancestry.featureBottom,
                      highlight: isMixed ? isSecondary : isAnySelected,
                      highlightColor: isMixed ? AppColors.secondary : AppColors.primary,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _featureRow({
    required String label,
    required String text,
    required bool highlight,
    required Color highlightColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: highlight ? highlightColor.withAlpha(15) : Colors.transparent,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label ',
            style: GoogleFonts.cinzel(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: highlight ? highlightColor : AppColors.textDisabled,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.crimsonText(
                fontSize: 12,
                color: highlight ? AppColors.textPrimary : AppColors.textSecondary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _slotPill({
    required String label,
    required String? value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: value != null ? color : AppColors.border,
            width: value != null ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.cinzel(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: value != null ? color : AppColors.textDisabled,
                letterSpacing: 0.8,
              ),
            ),
            Text(
              value ?? 'Not selected',
              style: GoogleFonts.crimsonText(
                fontSize: 13,
                color: value != null ? AppColors.textPrimary : AppColors.textDisabled,
                fontStyle: value == null ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(40),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(120)),
      ),
      child: Text(
        text,
        style: GoogleFonts.cinzel(
          fontSize: 8,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
