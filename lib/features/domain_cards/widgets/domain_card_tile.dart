import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/srd/domains_data.dart';

/// A Card widget showing a single domain card with domain color chip, level badge,
/// recall cost, type badge, name, and description.
class DomainCardTile extends StatelessWidget {
  final DomainCard card;
  final bool inLoadout;
  final bool inVault;
  final VoidCallback? onAddToLoadout;
  final VoidCallback? onMoveToVault;

  const DomainCardTile({
    super.key,
    required this.card,
    required this.inLoadout,
    required this.inVault,
    this.onAddToLoadout,
    this.onMoveToVault,
  });

  @override
  Widget build(BuildContext context) {
    final domainColor = AppColors.domainColor(card.domain);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: inLoadout
              ? AppColors.primary.withAlpha(180)
              : inVault
                  ? AppColors.armor.withAlpha(180)
                  : AppColors.border,
          width: (inLoadout || inVault) ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            decoration: BoxDecoration(
              color: domainColor.withAlpha(20),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
              border: Border(
                bottom: BorderSide(color: AppColors.border, width: 1),
              ),
            ),
            child: Row(
              children: [
                // Domain chip
                _domainChip(domainColor),
                const SizedBox(width: 8),
                // Level badge
                _levelBadge(),
                const SizedBox(width: 8),
                // Name
                Expanded(
                  child: Text(
                    card.name,
                    style: GoogleFonts.cinzel(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                // Type badge
                _typeBadge(),
                if (inLoadout) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(40),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'LOADOUT',
                      style: GoogleFonts.cinzel(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ] else if (inVault) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.armor.withAlpha(40),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'VAULT',
                      style: GoogleFonts.cinzel(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        color: AppColors.armor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Description
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            child: Text(
              card.description,
              style: GoogleFonts.crimsonText(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
          // Recall cost + action buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: Row(
              children: [
                // Recall cost
                if (card.recallCost > 0) ...[
                  const Icon(Icons.bolt, size: 14, color: AppColors.textDisabled),
                  Text(
                    ' Recall ${card.recallCost}',
                    style: GoogleFonts.crimsonText(
                      fontSize: 12,
                      color: AppColors.textDisabled,
                    ),
                  ),
                ] else
                  Text(
                    'No recall cost',
                    style: GoogleFonts.crimsonText(
                      fontSize: 12,
                      color: AppColors.textDisabled,
                    ),
                  ),
                const Spacer(),
                // Action buttons
                if (onAddToLoadout != null && !inLoadout)
                  TextButton.icon(
                    onPressed: onAddToLoadout,
                    icon: const Icon(Icons.add, size: 14),
                    label: Text(
                      'Loadout',
                      style: GoogleFonts.cinzel(fontSize: 11),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                if (onMoveToVault != null && inLoadout) ...[
                  const SizedBox(width: 6),
                  TextButton.icon(
                    onPressed: onMoveToVault,
                    icon: const Icon(Icons.archive_outlined, size: 14),
                    label: Text(
                      'Vault',
                      style: GoogleFonts.cinzel(fontSize: 11),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.armor,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _domainChip(Color domainColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: domainColor.withAlpha(50),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: domainColor.withAlpha(150)),
      ),
      child: Text(
        card.domain.toUpperCase(),
        style: GoogleFonts.cinzel(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: domainColor,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _levelBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        'LVL ${card.level}',
        style: GoogleFonts.cinzel(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _typeBadge() {
    final color = switch (card.type) {
      'spell' => AppColors.domainArcana,
      'grimoire' => AppColors.domainCodex,
      'ability' => AppColors.domainBlade,
      _ => AppColors.textDisabled,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(
        card.type.toUpperCase(),
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
