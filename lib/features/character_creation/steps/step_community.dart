import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/srd/communities_data.dart';

class StepCommunity extends StatelessWidget {
  final String? selected;
  final void Function(String) onChanged;

  const StepCommunity({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selectedCommunity =
        selected != null ? communityById(selected!) : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose Your Community',
            style: GoogleFonts.cinzel(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Where you were raised shapes your unique background feature.',
            style: GoogleFonts.crimsonText(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),

          // ── Community list ─────────────────────────────────────────────
          ...allCommunities.map((community) {
            final isSelected = community.id == selected;
            return GestureDetector(
              onTap: () => onChanged(community.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 130),
                margin: const EdgeInsets.only(bottom: 5),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withAlpha(18)
                      : AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name row
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                      child: Row(
                        children: [
                          if (isSelected)
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Icon(
                                Icons.check_circle,
                                size: 13,
                                color: AppColors.primary,
                              ),
                            ),
                          Expanded(
                            child: Text(
                              community.name,
                              style: GoogleFonts.cinzel(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Text(
                            community.flavour.split(' ').take(4).join(' ') +
                                '…',
                            style: GoogleFonts.crimsonText(
                              fontSize: 11,
                              color: AppColors.textDisabled,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Feature — always visible, compact
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                      child: Text(
                        community.feature,
                        style: GoogleFonts.crimsonText(
                          fontSize: 12,
                          color: isSelected
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          height: 1.35,
                        ),
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
}
