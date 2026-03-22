import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/srd/armor_data.dart';

class StepArmor extends StatelessWidget {
  final String? selected;
  final void Function(String) onChanged;

  const StepArmor({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tier1Armors = armorForTier(1);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose Starting Armor',
            style: GoogleFonts.cinzel(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your armor determines your protection, armor slots, and movement capabilities.',
            style: GoogleFonts.crimsonText(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          ...tier1Armors.map((armor) {
            final isSelected = armor.id == selected;
            return GestureDetector(
              onTap: () => onChanged(armor.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.armor.withAlpha(25) : AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.armor : AppColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Armor icon / selection indicator
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? AppColors.armor.withAlpha(60) : AppColors.surfaceVariant,
                        border: Border.all(
                          color: isSelected ? AppColors.armor : AppColors.border,
                        ),
                      ),
                      child: Icon(
                        isSelected ? Icons.shield : Icons.shield_outlined,
                        size: 22,
                        color: isSelected ? AppColors.armor : AppColors.textDisabled,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                armor.name,
                                style: GoogleFonts.cinzel(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? AppColors.armor : AppColors.textPrimary,
                                ),
                              ),
                              const Spacer(),
                              _tagChip(armor.tag),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            armor.description,
                            style: GoogleFonts.crimsonText(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              _statPill('Slots', '${armor.baseScore}', AppColors.armor),
                              _statPill('Minor', '${armor.minorBase}', Colors.green.shade700),
                              _statPill('Major', '${armor.majorBase}', Colors.orange.shade700),
                              _statPill('Severe', '${armor.severeBase}', AppColors.secondary),
                              _statPill(
                                'Evasion',
                                armor.evasionMod >= 0
                                    ? '+${armor.evasionMod}'
                                    : '${armor.evasionMod}',
                                AppColors.primary,
                              ),
                              if (armor.agilityMod != null)
                                _statPill(
                                  'Agility',
                                  '${armor.agilityMod}',
                                  AppColors.secondary,
                                ),
                            ],
                          ),
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

  Widget _tagChip(String tag) {
    final label = switch (tag) {
      'flexible' => 'FLEXIBLE',
      'standard' => 'STANDARD',
      'heavy' => 'HEAVY',
      'veryheavy' => 'V.HEAVY',
      _ => tag.toUpperCase(),
    };
    final color = switch (tag) {
      'flexible' => Colors.green.shade600,
      'standard' => AppColors.primary,
      'heavy' => Colors.orange.shade700,
      'veryheavy' => AppColors.secondary,
      _ => AppColors.textDisabled,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(40),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(120)),
      ),
      child: Text(
        label,
        style: GoogleFonts.cinzel(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _statPill(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: GoogleFonts.crimsonText(fontSize: 12, color: AppColors.textDisabled),
            ),
            TextSpan(
              text: value,
              style: GoogleFonts.cinzel(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
