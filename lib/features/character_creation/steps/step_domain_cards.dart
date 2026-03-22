import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/srd/classes_data.dart';
import '../../../data/srd/domains_data.dart';

class StepDomainCards extends StatelessWidget {
  final String classId;
  final List<String> selected;
  final void Function(List<String>) onChanged;

  const StepDomainCards({
    super.key,
    required this.classId,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final classDef = classById(classId);
    if (classDef == null) {
      return Center(
        child: Text(
          'Class not found.',
          style: GoogleFonts.crimsonText(color: AppColors.textSecondary, fontSize: 16),
        ),
      );
    }

    final availableCards = cardsAtOrBelowLevel(classDef.domains, 1);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Starting Domain Cards',
            style: GoogleFonts.cinzel(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Pick 2 level-1 cards from your class domains (${classDef.domains.map((d) => d.toUpperCase()).join(' & ')}) to start your loadout.',
            style: GoogleFonts.crimsonText(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          // Selected count badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: selected.length == 2
                      ? AppColors.primary.withAlpha(40)
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: selected.length == 2 ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Text(
                  '${selected.length} / 2 selected',
                  style: GoogleFonts.cinzel(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected.length == 2 ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ...availableCards.map((card) {
            final isSelected = selected.contains(card.id);
            final canSelect = isSelected || selected.length < 2;

            return GestureDetector(
              onTap: canSelect
                  ? () {
                      final newSelected = List<String>.from(selected);
                      if (isSelected) {
                        newSelected.remove(card.id);
                      } else {
                        newSelected.add(card.id);
                      }
                      onChanged(newSelected);
                    }
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withAlpha(25)
                      : canSelect
                          ? AppColors.cardBackground
                          : AppColors.cardBackground.withAlpha(150),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Selection indicator
                    Container(
                      width: 24,
                      height: 24,
                      margin: const EdgeInsets.only(right: 10, top: 2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, size: 14, color: AppColors.textOnPrimary)
                          : null,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  card.name,
                                  style: GoogleFonts.cinzel(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected
                                        ? AppColors.primary
                                        : canSelect
                                            ? AppColors.textPrimary
                                            : AppColors.textDisabled,
                                  ),
                                ),
                              ),
                              // Domain chip
                              _domainChip(card.domain),
                              const SizedBox(width: 6),
                              // Type chip
                              _typeChip(card.type),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            card.description,
                            style: GoogleFonts.crimsonText(
                              fontSize: 13,
                              color: canSelect ? AppColors.textSecondary : AppColors.textDisabled,
                              height: 1.3,
                            ),
                          ),
                          if (card.recallCost > 0) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.bolt, size: 13, color: AppColors.textDisabled),
                                Text(
                                  ' Recall ${card.recallCost}',
                                  style: GoogleFonts.crimsonText(
                                    fontSize: 12,
                                    color: AppColors.textDisabled,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
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

  Widget _domainChip(String domain) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.domainColor(domain).withAlpha(50),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.domainColor(domain).withAlpha(120)),
      ),
      child: Text(
        domain.toUpperCase(),
        style: GoogleFonts.cinzel(
          fontSize: 8,
          fontWeight: FontWeight.w700,
          color: AppColors.domainColor(domain),
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _typeChip(String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        type.toUpperCase(),
        style: GoogleFonts.cinzel(
          fontSize: 8,
          fontWeight: FontWeight.w600,
          color: AppColors.textDisabled,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
