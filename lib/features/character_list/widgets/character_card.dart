import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/game_constants.dart';
import '../../../data/models/character_model.dart';

class CharacterCard extends StatelessWidget {
  final CharacterModel character;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const CharacterCard({
    super.key,
    required this.character,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(60),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Level badge (left accent strip) ─────────────────────────
            Container(
              width: 60,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(22),
                borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(10)),
                border: Border(
                    right: BorderSide(
                        color: AppColors.primary.withAlpha(70), width: 1)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${character.level}',
                    style: GoogleFonts.cinzel(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'LVL',
                    style: GoogleFonts.cinzel(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDisabled,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),

            // ── Main content ─────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Name + DOWN badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            character.name,
                            style: GoogleFonts.cinzel(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                              letterSpacing: 0.4,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (character.isDown)
                          Container(
                            margin: const EdgeInsets.only(left: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.hp,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'DOWN',
                              style: GoogleFonts.cinzel(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),

                    // Class · Ancestry · Community
                    Text(
                      '${_cap(character.classId)} · ${_cap(character.ancestryId)}${character.isMixedAncestry && character.ancestryId2 != null ? '/${_cap(character.ancestryId2!)}' : ''} · ${_cap(character.communityId)}',
                      style: GoogleFonts.crimsonText(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 7),

                    // Stats row
                    Row(
                      children: [
                        _miniStat(
                          label: 'HP',
                          current: character.currentHp,
                          max: character.maxHpSlots,
                          activeColor: AppColors.hp,
                        ),
                        const SizedBox(width: 12),
                        _miniStat(
                          label: 'STRESS',
                          current: character.currentStress,
                          max: character.maxStressSlots,
                          activeColor: AppColors.stress,
                        ),
                        const SizedBox(width: 12),
                        // Hope diamonds
                        Row(
                          children: [
                            Text(
                              'HOPE ',
                              style: GoogleFonts.cinzel(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDisabled,
                                letterSpacing: 0.5,
                              ),
                            ),
                            ...List.generate(GameConstants.maxHope, (i) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 2),
                                child: Icon(
                                  i < character.hope
                                      ? Icons.diamond
                                      : Icons.diamond_outlined,
                                  size: 14,
                                  color: i < character.hope
                                      ? AppColors.hope
                                      : AppColors.textDisabled.withAlpha(80),
                                ),
                              );
                            }),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Delete button ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, size: 20),
                color: AppColors.textDisabled,
                tooltip: 'Delete character',
                padding: const EdgeInsets.all(10),
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat({
    required String label,
    required int current,
    required int max,
    required Color activeColor,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label ',
          style: GoogleFonts.cinzel(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: AppColors.textDisabled,
            letterSpacing: 0.5,
          ),
        ),
        // Show filled dots, cap at 10 to keep it compact
        ...List.generate(max.clamp(0, 10), (i) {
          return Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(right: 2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i < current
                  ? activeColor
                  : AppColors.textDisabled.withAlpha(50),
            ),
          );
        }),
        if (max > 10)
          Text(
            '+${max - 10}',
            style: GoogleFonts.cinzel(
              fontSize: 8,
              color: AppColors.textDisabled,
            ),
          ),
      ],
    );
  }

  String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
