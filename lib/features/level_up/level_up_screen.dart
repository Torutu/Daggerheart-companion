import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/game_constants.dart';
import '../../data/models/character_model.dart';
import '../../data/srd/classes_data.dart';
import '../../data/srd/subclasses_data.dart';
import '../../domain/providers/character_provider.dart';

/// Advancement option model
class _Advancement {
  final String id;
  final String label;
  final int cost; // 1 or 2 (costs 2 = single pick only)
  final bool requiresExtra; // needs a picker

  const _Advancement({
    required this.id,
    required this.label,
    this.cost = 1,
    this.requiresExtra = false,
  });
}

const _allAdvancements = [
  _Advancement(id: 'trait', label: 'Increase a Trait (+1)', requiresExtra: true),
  _Advancement(id: 'hp', label: 'Add 1 HP Slot'),
  _Advancement(id: 'stress', label: 'Add 1 Stress Slot'),
  _Advancement(id: 'experience', label: 'Increase an Experience (+1)', requiresExtra: true),
  _Advancement(id: 'card', label: 'Take a Domain Card', requiresExtra: true),
  _Advancement(id: 'evasion', label: 'Increase Evasion (+1)'),
  _Advancement(id: 'subclass', label: 'Upgrade Subclass Tier', requiresExtra: true),
  _Advancement(id: 'proficiency', label: 'Increase Proficiency (+1)', cost: 2),
  _Advancement(id: 'multiclass', label: 'Multiclass (pick second class)', cost: 2, requiresExtra: true),
];

class LevelUpScreen extends ConsumerStatefulWidget {
  final String characterId;
  const LevelUpScreen({super.key, required this.characterId});

  @override
  ConsumerState<LevelUpScreen> createState() => _LevelUpScreenState();
}

class _LevelUpScreenState extends ConsumerState<LevelUpScreen> {
  int _step = 0; // 0=tier check, 1=advancements, 2=thresholds, 3=summary

  // Tier boundary state
  String _newExperienceName = '';

  // Advancement state
  final Set<String> _pickedAdvancementIds = {};
  String? _pickedTrait;
  String? _pickedExperienceId;
  String? _pickedMulticlassId;
  final _newExperienceController = TextEditingController();

  bool _isApplying = false;

  int get _totalCost => _pickedAdvancementIds.fold<int>(
        0,
        (sum, id) => sum + (_allAdvancements.firstWhere((a) => a.id == id).cost),
      );

  bool get _isAtTierBoundary {
    final character = ref.read(activeCharacterProvider(widget.characterId));
    if (character == null) return false;
    final newLevel = character.level + 1;
    return GameConstants.tierBoundaryLevels.contains(newLevel);
  }

  CharacterModel? get _character =>
      ref.read(activeCharacterProvider(widget.characterId));

  @override
  void dispose() {
    _newExperienceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final character = ref.watch(activeCharacterProvider(widget.characterId));

    if (character == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Level Up')),
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (character.level >= GameConstants.maxLevel) {
      return Scaffold(
        appBar: AppBar(title: const Text('Level Up')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, size: 64, color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                'Maximum Level!',
                style: GoogleFonts.cinzel(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${character.name} has reached Level 10.',
                style: GoogleFonts.crimsonText(fontSize: 16, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    final newLevel = character.level + 1;
    final newTier = GameConstants.tierForLevel(newLevel);

    return Scaffold(
      appBar: AppBar(
        title: Text('Level Up — ${character.name}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Step progress
          _buildStepIndicator(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildCurrentStep(character, newLevel, newTier),
            ),
          ),
          _buildStepNavigation(character, newLevel, newTier),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    final stepLabels = ['Tier Check', 'Advancements', 'Thresholds', 'Summary'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: List.generate(4, (i) {
          final isActive = i == _step;
          final isDone = i < _step;
          return Expanded(
            child: Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone
                            ? AppColors.primary
                            : isActive
                                ? AppColors.primary.withAlpha(60)
                                : AppColors.surfaceVariant,
                        border: Border.all(
                          color: isActive || isDone ? AppColors.primary : AppColors.border,
                          width: isActive ? 2 : 1,
                        ),
                      ),
                      child: Center(
                        child: isDone
                            ? const Icon(Icons.check, size: 14, color: AppColors.textOnPrimary)
                            : Text(
                                '${i + 1}',
                                style: GoogleFonts.cinzel(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isActive ? AppColors.primary : AppColors.textDisabled,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stepLabels[i],
                      style: GoogleFonts.cinzel(
                        fontSize: 8,
                        color: isActive ? AppColors.primary : AppColors.textDisabled,
                      ),
                    ),
                  ],
                ),
                if (i < 3)
                  Expanded(
                    child: Container(
                      height: 1,
                      margin: const EdgeInsets.only(bottom: 20),
                      color: isDone ? AppColors.primary : AppColors.divider,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStep(CharacterModel character, int newLevel, int newTier) {
    switch (_step) {
      case 0:
        return _buildTierCheckStep(character, newLevel, newTier);
      case 1:
        return _buildAdvancementsStep(character, newLevel);
      case 2:
        return _buildThresholdsStep(character);
      case 3:
        return _buildSummaryStep(character, newLevel, newTier);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTierCheckStep(CharacterModel character, int newLevel, int newTier) {
    final isBoundary = GameConstants.tierBoundaryLevels.contains(newLevel);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Level up header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(20),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withAlpha(100)),
          ),
          child: Row(
            children: [
              const Icon(Icons.trending_up, color: AppColors.primary, size: 36),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Level ${character.level} → Level $newLevel',
                      style: GoogleFonts.cinzel(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'Tier ${character.tier} → Tier $newTier',
                      style: GoogleFonts.crimsonText(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        if (isBoundary) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primary.withAlpha(120)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Tier Boundary!',
                      style: GoogleFonts.cinzel(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Reaching Level $newLevel marks a new tier. You automatically gain:',
                  style: GoogleFonts.crimsonText(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                _bulletPoint('Proficiency increases by +1 (auto-applied)'),
                _bulletPoint('Gain a new Experience (name it below)'),
                const SizedBox(height: 16),
                Text(
                  'New Experience Name',
                  style: GoogleFonts.cinzel(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _newExperienceController,
                  onChanged: (v) => setState(() => _newExperienceName = v),
                  style: GoogleFonts.crimsonText(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'e.g. Veteran Mercenary, Arcane Scholar...',
                    hintStyle: GoogleFonts.crimsonText(color: AppColors.textDisabled),
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.primary, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'This is not a tier boundary. You will gain ${GameConstants.advancementsPerLevel} advancement picks in the next step.',
                    style: GoogleFonts.crimsonText(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAdvancementsStep(CharacterModel character, int newLevel) {
    final remaining = GameConstants.advancementsPerLevel - _totalCost;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Advancements',
          style: GoogleFonts.cinzel(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'You have $remaining advancement point(s) remaining. Options marked (×2) cost both picks.',
          style: GoogleFonts.crimsonText(
            fontSize: 15,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 8),
        // Cost counter
        Row(
          children: [
            ...List.generate(GameConstants.advancementsPerLevel, (i) {
              final used = i < _totalCost;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: used ? AppColors.primary : AppColors.surfaceVariant,
                    border: Border.all(
                      color: used ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  child: used
                      ? const Icon(Icons.check, size: 14, color: AppColors.textOnPrimary)
                      : null,
                ),
              );
            }),
          ],
        ),
        const SizedBox(height: 16),

        ..._allAdvancements.map((adv) {
          final isPicked = _pickedAdvancementIds.contains(adv.id);
          final wouldExceed = !isPicked && (_totalCost + adv.cost > GameConstants.advancementsPerLevel);

          // Disable multiclass if already has one
          final isDisabled = (adv.id == 'multiclass' && character.multiclassId != null) ||
              (adv.id == 'subclass' && character.subclassTier == 'mastery') ||
              wouldExceed;

          return _buildAdvancementTile(adv, character, isPicked, isDisabled);
        }),
      ],
    );
  }

  Widget _buildAdvancementTile(
    _Advancement adv,
    CharacterModel character,
    bool isPicked,
    bool isDisabled,
  ) {
    return GestureDetector(
      onTap: isDisabled && !isPicked
          ? null
          : () {
              setState(() {
                if (isPicked) {
                  _pickedAdvancementIds.remove(adv.id);
                  // Clear extras
                  if (adv.id == 'trait') _pickedTrait = null;
                  if (adv.id == 'experience') _pickedExperienceId = null;
                  if (adv.id == 'multiclass') _pickedMulticlassId = null;
                } else {
                  _pickedAdvancementIds.add(adv.id);
                }
              });
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isPicked ? AppColors.primary.withAlpha(25) : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isPicked ? AppColors.primary : isDisabled ? AppColors.border.withAlpha(80) : AppColors.border,
            width: isPicked ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isPicked ? AppColors.primary : AppColors.surfaceVariant,
                    border: Border.all(
                      color: isPicked ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  child: isPicked
                      ? const Icon(Icons.check, size: 14, color: AppColors.textOnPrimary)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    adv.label,
                    style: GoogleFonts.crimsonText(
                      fontSize: 16,
                      color: isDisabled && !isPicked
                          ? AppColors.textDisabled
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (adv.cost == 2)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withAlpha(40),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.secondary.withAlpha(80)),
                    ),
                    child: Text(
                      '×2 cost',
                      style: GoogleFonts.cinzel(
                        fontSize: 10,
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            // Extra pickers when selected
            if (isPicked && adv.requiresExtra) ...[
              const SizedBox(height: 10),
              _buildAdvancementExtra(adv, character),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancementExtra(_Advancement adv, CharacterModel character) {
    switch (adv.id) {
      case 'trait':
        return _buildTraitPicker(character);
      case 'experience':
        return _buildExperiencePicker(character);
      case 'subclass':
        return _buildSubclassUpgradeInfo(character);
      case 'card':
        return TextButton.icon(
          onPressed: () => context.push('/character/${widget.characterId}/cards'),
          icon: const Icon(Icons.open_in_new, size: 14),
          label: const Text('Open Cards Browser'),
        );
      case 'multiclass':
        return _buildMulticlassPicker(character);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTraitPicker(CharacterModel character) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: GameConstants.traitNames.map((trait) {
        final val = character.traitValue(trait);
        final label = GameConstants.traitLabels[trait] ?? trait;
        final isSelected = _pickedTrait == trait;
        return GestureDetector(
          onTap: () => setState(() => _pickedTrait = trait),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withAlpha(40) : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
            ),
            child: Text(
              '$label (${val >= 0 ? '+$val' : '$val'} → ${val + 1 >= 0 ? '+${val + 1}' : '${val + 1}'})',
              style: GoogleFonts.crimsonText(
                fontSize: 13,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExperiencePicker(CharacterModel character) {
    if (character.experiences.isEmpty) {
      return Text(
        'No existing experiences to upgrade.',
        style: GoogleFonts.crimsonText(fontSize: 14, color: AppColors.textDisabled),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: character.experiences.asMap().entries.map((entry) {
        final i = entry.key;
        final exp = entry.value;
        final expId = '$i';
        final isSelected = _pickedExperienceId == expId;
        return GestureDetector(
          onTap: () => setState(() => _pickedExperienceId = expId),
          child: Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withAlpha(30) : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    exp.name,
                    style: GoogleFonts.crimsonText(
                      fontSize: 14,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  '+${exp.modifier} → +${exp.modifier + 1}',
                  style: GoogleFonts.cinzel(
                    fontSize: 12,
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSubclassUpgradeInfo(CharacterModel character) {
    final nextTier = switch (character.subclassTier) {
      'foundation' => 'specialization',
      'specialization' => 'mastery',
      _ => null,
    };
    if (nextTier == null) {
      return Text(
        'Already at mastery tier.',
        style: GoogleFonts.crimsonText(fontSize: 14, color: AppColors.textDisabled),
      );
    }
    final subclass = subclassById(character.subclassId);
    final tierCard = nextTier == 'specialization'
        ? subclass?.specialization
        : subclass?.mastery;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${character.subclassTier.toUpperCase()} → ${nextTier.toUpperCase()}',
            style: GoogleFonts.cinzel(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: 0.8,
            ),
          ),
          if (tierCard != null) ...[
            const SizedBox(height: 4),
            Text(
              tierCard.name,
              style: GoogleFonts.cinzel(fontSize: 13, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              tierCard.description,
              style: GoogleFonts.crimsonText(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.3,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMulticlassPicker(CharacterModel character) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose second class:',
          style: GoogleFonts.cinzel(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: allClasses
              .where((c) => c.id != character.classId)
              .map((c) {
            final isSelected = _pickedMulticlassId == c.id;
            return GestureDetector(
              onTap: () => setState(() => _pickedMulticlassId = c.id),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withAlpha(30) : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
                ),
                child: Text(
                  c.name,
                  style: GoogleFonts.crimsonText(
                    fontSize: 14,
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildThresholdsStep(CharacterModel character) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Damage Thresholds',
          style: GoogleFonts.cinzel(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'All damage thresholds increase by +1 when you level up.',
          style: GoogleFonts.crimsonText(
            fontSize: 15,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),
        _buildThresholdRow('Minor', character.minorThreshold, character.minorThreshold + 1, Colors.green.shade700),
        const SizedBox(height: 12),
        _buildThresholdRow('Major', character.majorThreshold, character.majorThreshold + 1, Colors.orange.shade700),
        const SizedBox(height: 12),
        _buildThresholdRow('Severe', character.severeThreshold, character.severeThreshold + 1, AppColors.secondary),
      ],
    );
  }

  Widget _buildThresholdRow(String label, int oldVal, int newVal, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.cinzel(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
          Text(
            '$oldVal',
            style: GoogleFonts.cinzel(
              fontSize: 20,
              color: AppColors.textDisabled,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Icon(Icons.arrow_forward, color: AppColors.primary, size: 18),
          ),
          Text(
            '$newVal',
            style: GoogleFonts.cinzel(
              fontSize: 24,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStep(CharacterModel character, int newLevel, int newTier) {
    final isBoundary = GameConstants.tierBoundaryLevels.contains(newLevel);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Level Up Summary',
          style: GoogleFonts.cinzel(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withAlpha(100)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${character.name}: Level ${character.level} → $newLevel',
                style: GoogleFonts.cinzel(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              // Threshold increase
              _summaryRow('Minor Threshold', '${character.minorThreshold} → ${character.minorThreshold + 1}'),
              _summaryRow('Major Threshold', '${character.majorThreshold} → ${character.majorThreshold + 1}'),
              _summaryRow('Severe Threshold', '${character.severeThreshold} → ${character.severeThreshold + 1}'),

              if (isBoundary) ...[
                _summaryRow('Proficiency', '${character.proficiency} → ${character.proficiency + 1}'),
                if (_newExperienceName.isNotEmpty)
                  _summaryRow('New Experience', _newExperienceName),
              ],
              const Divider(height: 16),
              // Advancements
              ..._pickedAdvancementIds.map((id) {
                final adv = _allAdvancements.firstWhere((a) => a.id == id);
                String detail = adv.label;
                if (id == 'trait' && _pickedTrait != null) {
                  detail += ' (${GameConstants.traitLabels[_pickedTrait!] ?? _pickedTrait!})';
                } else if (id == 'multiclass' && _pickedMulticlassId != null) {
                  final cls = classById(_pickedMulticlassId!);
                  detail += ' (${cls?.name ?? _pickedMulticlassId!})';
                }
                return _summaryRow('Advancement', detail);
              }),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: _isApplying
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : ElevatedButton.icon(
                  onPressed: () => _applyLevelUp(character, newLevel, isBoundary),
                  icon: const Icon(Icons.check),
                  label: Text(
                    'Confirm Level Up',
                    style: GoogleFonts.cinzel(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.arrow_right, size: 18, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            '$label: ',
            style: GoogleFonts.crimsonText(fontSize: 14, color: AppColors.textSecondary),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.crimsonText(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepNavigation(CharacterModel character, int newLevel, int newTier) {
    final isLastStep = _step == 3;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          if (_step > 0)
            OutlinedButton.icon(
              onPressed: () => setState(() => _step--),
              icon: const Icon(Icons.chevron_left),
              label: const Text('Back'),
            )
          else
            const SizedBox(width: 80),
          const Spacer(),
          if (!isLastStep)
            ElevatedButton.icon(
              onPressed: _canAdvanceStep(character, newLevel)
                  ? () => setState(() => _step++)
                  : null,
              icon: const Icon(Icons.chevron_right),
              iconAlignment: IconAlignment.end,
              label: Text(
                'Next',
                style: GoogleFonts.cinzel(fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }

  bool _canAdvanceStep(CharacterModel character, int newLevel) {
    switch (_step) {
      case 0:
        final isBoundary = GameConstants.tierBoundaryLevels.contains(newLevel);
        return !isBoundary || _newExperienceName.isNotEmpty;
      case 1:
        return _totalCost == GameConstants.advancementsPerLevel &&
            (!_pickedAdvancementIds.contains('trait') || _pickedTrait != null) &&
            (!_pickedAdvancementIds.contains('multiclass') || _pickedMulticlassId != null);
      case 2:
        return true;
      default:
        return true;
    }
  }

  Future<void> _applyLevelUp(CharacterModel character, int newLevel, bool isBoundary) async {
    setState(() => _isApplying = true);

    try {
      var updated = character.copyWith(
        level: newLevel,
        minorThreshold: character.minorThreshold + 1,
        majorThreshold: character.majorThreshold + 1,
        severeThreshold: character.severeThreshold + 1,
      );

      // Tier boundary: proficiency +1 + new experience
      if (isBoundary) {
        updated = updated.copyWith(proficiency: updated.proficiency + 1);
        if (_newExperienceName.isNotEmpty) {
          final exps = List<ExperienceEntry>.from(updated.experiences)
            ..add(ExperienceEntry(name: _newExperienceName.trim(), modifier: 1));
          updated = updated.copyWith(experiences: exps);
        }
      }

      // Apply advancements
      for (final id in _pickedAdvancementIds) {
        updated = _applyAdvancement(id, updated);
      }

      await ref.read(activeCharacterProvider(widget.characterId).notifier).replace(updated);

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${character.name} is now Level $newLevel!'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to apply level up: $e')),
        );
        setState(() => _isApplying = false);
      }
    }
  }

  CharacterModel _applyAdvancement(String id, CharacterModel c) {
    switch (id) {
      case 'hp':
        return c.copyWith(maxHpSlots: c.maxHpSlots + 1);
      case 'stress':
        return c.copyWith(maxStressSlots: c.maxStressSlots + 1);
      case 'evasion':
        return c.copyWith(evasion: c.evasion + 1);
      case 'proficiency':
        return c.copyWith(proficiency: c.proficiency + 1);
      case 'trait':
        if (_pickedTrait == null) return c;
        return switch (_pickedTrait!) {
          'agility' => c.copyWith(agility: c.agility + 1),
          'strength' => c.copyWith(strength: c.strength + 1),
          'finesse' => c.copyWith(finesse: c.finesse + 1),
          'instinct' => c.copyWith(instinct: c.instinct + 1),
          'presence' => c.copyWith(presence: c.presence + 1),
          'knowledge' => c.copyWith(knowledge: c.knowledge + 1),
          _ => c,
        };
      case 'experience':
        if (_pickedExperienceId == null) return c;
        final idx = int.tryParse(_pickedExperienceId!) ?? -1;
        if (idx < 0 || idx >= c.experiences.length) return c;
        final exps = List<ExperienceEntry>.from(c.experiences);
        final old = exps[idx];
        exps[idx] = ExperienceEntry(name: old.name, modifier: old.modifier + 1);
        return c.copyWith(experiences: exps);
      case 'subclass':
        final nextTier = switch (c.subclassTier) {
          'foundation' => 'specialization',
          'specialization' => 'mastery',
          _ => c.subclassTier,
        };
        return c.copyWith(subclassTier: nextTier);
      case 'multiclass':
        if (_pickedMulticlassId == null) return c;
        final subclasses = subclassesForClass(_pickedMulticlassId!);
        final firstSubId = subclasses.isNotEmpty ? subclasses.first.id : '';
        return c.copyWith(
          multiclassId: _pickedMulticlassId,
          multiclassSubclassId: firstSubId,
        );
      case 'card':
        // Card will be added via the cards browser
        return c;
      default:
        return c;
    }
  }

  Widget _bulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: AppColors.primary, fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.crimsonText(
                fontSize: 15,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
