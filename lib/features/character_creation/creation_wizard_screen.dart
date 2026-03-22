import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/game_constants.dart';
import '../../data/models/character_model.dart';
import '../../data/srd/classes_data.dart';
import '../../data/srd/subclasses_data.dart';
import '../../data/srd/armor_data.dart';
import '../../domain/providers/character_provider.dart';
import 'steps/step_identity.dart';
import 'steps/step_ancestry.dart';
import 'steps/step_community.dart';
import 'steps/step_class.dart';
import 'steps/step_subclass.dart';
import 'steps/step_traits.dart';
import 'steps/step_domain_cards.dart';
import 'steps/step_experiences.dart';
import 'steps/step_armor.dart';

/// Local mutable state for the wizard
class _CreationState {
  String name;
  String pronouns;
  String? ancestryId;
  bool isMixedAncestry;
  String? ancestryId2;
  String? communityId;
  String? classId;
  String? subclassId;
  Map<String, int> traits;
  List<String> selectedCardIds;
  List<ExperienceEntry> experiences;
  String? armorId;

  _CreationState({
    this.name = '',
    this.pronouns = '',
    this.ancestryId,
    this.isMixedAncestry = false,
    this.ancestryId2,
    this.communityId,
    this.classId,
    this.subclassId,
    Map<String, int>? traits,
    List<String>? selectedCardIds,
    List<ExperienceEntry>? experiences,
    this.armorId,
  }) : traits = traits ?? {},
       selectedCardIds = selectedCardIds ?? [],
       experiences = experiences ?? [];

  _CreationState copyWith({
    String? name,
    String? pronouns,
    String? ancestryId,
    bool? isMixedAncestry,
    String? ancestryId2,
    String? communityId,
    String? classId,
    String? subclassId,
    Map<String, int>? traits,
    List<String>? selectedCardIds,
    List<ExperienceEntry>? experiences,
    String? armorId,
  }) {
    return _CreationState(
      name: name ?? this.name,
      pronouns: pronouns ?? this.pronouns,
      ancestryId: ancestryId ?? this.ancestryId,
      isMixedAncestry: isMixedAncestry ?? this.isMixedAncestry,
      ancestryId2: ancestryId2 != null
          ? (ancestryId2 == '' ? null : ancestryId2)
          : this.ancestryId2,
      communityId: communityId ?? this.communityId,
      classId: classId ?? this.classId,
      subclassId: subclassId ?? this.subclassId,
      traits: traits ?? this.traits,
      selectedCardIds: selectedCardIds ?? this.selectedCardIds,
      experiences: experiences ?? this.experiences,
      armorId: armorId ?? this.armorId,
    );
  }
}

class CreationWizardScreen extends ConsumerStatefulWidget {
  const CreationWizardScreen({super.key});

  @override
  ConsumerState<CreationWizardScreen> createState() =>
      _CreationWizardScreenState();
}

class _CreationWizardScreenState extends ConsumerState<CreationWizardScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  _CreationState _state = _CreationState();
  bool _isCreating = false;

  static const int _totalSteps = 9;

  static const List<String> _stepTitles = [
    'Identity',
    'Ancestry',
    'Community',
    'Class',
    'Subclass',
    'Traits',
    'Domain Cards',
    'Experiences',
    'Armor & Review',
  ];

  bool get _canAdvance {
    switch (_currentPage) {
      case 0:
        return _state.name.trim().isNotEmpty;
      case 1:
        return _state.ancestryId != null && _state.ancestryId!.isNotEmpty;
      case 2:
        return _state.communityId != null;
      case 3:
        return _state.classId != null;
      case 4:
        return _state.subclassId != null;
      case 5:
        return _state.traits.length == GameConstants.traitNames.length;
      case 6:
        return _state.selectedCardIds.length == 2;
      case 7:
        return true; // Experiences optional
      case 8:
        return _state.armorId != null;
      default:
        return true;
    }
  }

  void _next() {
    if (!_canAdvance) {
      _showValidationSnackbar();
      return;
    }
    if (_currentPage < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage++);
    } else {
      _create();
    }
  }

  void _prev() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage--);
    }
  }

  void _showValidationSnackbar() {
    final messages = [
      'Enter a character name to continue.',
      'Select an ancestry.',
      'Select a community.',
      'Select a class.',
      'Select a subclass.',
      'Assign all 6 trait values.',
      'Select exactly 2 domain cards.',
      '',
      'Select armor to continue.',
    ];
    final msg = messages[_currentPage];
    if (msg.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  Future<void> _create() async {
    if (_isCreating) return;
    setState(() => _isCreating = true);

    try {
      final id = _generateId();
      final character = _buildCharacter(id);
      await ref.read(characterListProvider.notifier).create(character);
      if (mounted) {
        context.go('/character/$id');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create character: $e')),
        );
        setState(() => _isCreating = false);
      }
    }
  }

  String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final name = _state.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    return '${name}_$timestamp';
  }

  CharacterModel _buildCharacter(String id) {
    final classDef = classById(_state.classId!)!;
    final armor = armorById(_state.armorId!)!;
    final subclass = subclassById(_state.subclassId!);

    final agility = _state.traits['agility'] ?? 0;
    final strength = _state.traits['strength'] ?? 0;
    final finesse = _state.traits['finesse'] ?? 0;
    final instinct = _state.traits['instinct'] ?? 0;
    final presence = _state.traits['presence'] ?? 0;
    final knowledge = _state.traits['knowledge'] ?? 0;

    // Stalwart subclass gives +2 to all thresholds
    final stalwartBonus = _state.subclassId == 'stalwart' ? 2 : 0;
    // Scaled hide (drakona) gives +2 severe
    final scaledHideBonus = _state.ancestryId == 'drakona' ? 2 : 0;

    return CharacterModel(
      id: id,
      name: _state.name.trim(),
      pronouns: _state.pronouns.trim(),
      level: 1,
      ancestryId: _state.ancestryId!,
      isMixedAncestry: _state.isMixedAncestry,
      ancestryId2: _state.ancestryId2,
      communityId: _state.communityId!,
      classId: _state.classId!,
      subclassId: _state.subclassId!,
      subclassTier: 'foundation',
      multiclassId: null,
      multiclassSubclassId: null,
      agility: agility,
      strength: strength,
      finesse: finesse,
      instinct: instinct,
      presence: presence,
      knowledge: knowledge,
      markedTraits: [],
      currentHp: 0,
      maxHpSlots: classDef.startingHp,
      currentStress: 0,
      maxStressSlots: GameConstants.baseStressSlots,
      hope: GameConstants.startingHope,
      evasion: classDef.startingEvasion + armor.evasionMod,
      armorType: armorTypeKey(_state.armorId!),
      armorBaseScore: armor.baseScore,
      armorMarkedSlots: 0,
      minorThreshold: armor.minorBase + stalwartBonus,
      majorThreshold: armor.majorBase + stalwartBonus,
      severeThreshold: armor.severeBase + stalwartBonus + scaledHideBonus,
      proficiency: GameConstants.startingProficiency,
      experiences: _state.experiences.where((e) => e.name.isNotEmpty).toList(),
      loadoutCardIds: _state.selectedCardIds,
      vaultCardIds: [],
      goldHandfuls: 1,
      goldBags: 0,
      goldChests: 0,
      inventory: [],
      activeConditions: [],
      notes: '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Discard Character?'),
                content: const Text('Your progress will be lost.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Keep Editing'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                    ),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      context.pop();
                    },
                    child: const Text('Discard'),
                  ),
                ],
              ),
            );
          },
        ),
        title: Text(_stepTitles[_currentPage]),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            children: [
              // Progress indicator
              _buildProgressBar(),
              // Step content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    // Step 1: Identity
                    StepIdentity(
                      name: _state.name,
                      pronouns: _state.pronouns,
                      onChanged: (name, pronouns) {
                        setState(() {
                          _state = _state.copyWith(
                            name: name,
                            pronouns: pronouns,
                          );
                        });
                      },
                    ),
                    // Step 2: Ancestry
                    StepAncestry(
                      selected: _state.ancestryId,
                      isMixed: _state.isMixedAncestry,
                      selected2: _state.ancestryId2,
                      onChanged: (id, isMixed, id2) {
                        setState(() {
                          _state = _state.copyWith(
                            ancestryId: id,
                            isMixedAncestry: isMixed,
                            ancestryId2: id2 ?? '',
                          );
                        });
                      },
                    ),
                    // Step 3: Community
                    StepCommunity(
                      selected: _state.communityId,
                      onChanged: (id) {
                        setState(() {
                          _state = _state.copyWith(communityId: id);
                        });
                      },
                    ),
                    // Step 4: Class
                    StepClass(
                      selected: _state.classId,
                      onChanged: (id) {
                        setState(() {
                          // Reset subclass and domain cards when class changes
                          _state = _state.copyWith(
                            classId: id,
                            subclassId: _getFirstSubclass(id),
                            selectedCardIds: [],
                          );
                        });
                      },
                    ),
                    // Step 5: Subclass
                    StepSubclass(
                      classId: _state.classId ?? '',
                      selected: _state.subclassId,
                      onChanged: (id) {
                        setState(() {
                          _state = _state.copyWith(subclassId: id);
                        });
                      },
                    ),
                    // Step 6: Traits
                    StepTraits(
                      traits: _state.traits,
                      onChanged: (traits) {
                        setState(() {
                          _state = _state.copyWith(traits: traits);
                        });
                      },
                    ),
                    // Step 7: Domain Cards
                    StepDomainCards(
                      classId: _state.classId ?? '',
                      selected: _state.selectedCardIds,
                      onChanged: (ids) {
                        setState(() {
                          _state = _state.copyWith(selectedCardIds: ids);
                        });
                      },
                    ),
                    // Step 8: Experiences
                    StepExperiences(
                      experiences: _state.experiences,
                      onChanged: (exp) {
                        setState(() {
                          _state = _state.copyWith(experiences: exp);
                        });
                      },
                    ),
                    // Step 9: Armor + Review
                    _buildArmorAndReview(),
                  ],
                ),
              ),
              // Navigation buttons
              _buildNavigation(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step ${_currentPage + 1} of $_totalSteps',
                style: GoogleFonts.cinzel(
                  fontSize: 11,
                  color: AppColors.textDisabled,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                _stepTitles[_currentPage].toUpperCase(),
                style: GoogleFonts.cinzel(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (_currentPage + 1) / _totalSteps,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildNavigation() {
    final isLastStep = _currentPage == _totalSteps - 1;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          if (_currentPage > 0)
            OutlinedButton.icon(
              onPressed: _prev,
              icon: const Icon(Icons.chevron_left),
              label: const Text('Back'),
            )
          else
            const SizedBox(width: 80),
          const Spacer(),
          if (isLastStep)
            _isCreating
                ? const CircularProgressIndicator(color: AppColors.primary)
                : ElevatedButton.icon(
                    onPressed: _canAdvance ? _create : null,
                    icon: const Icon(Icons.check),
                    label: Text(
                      'Create Character',
                      style: GoogleFonts.cinzel(fontWeight: FontWeight.w700),
                    ),
                  )
          else
            ElevatedButton.icon(
              onPressed: _canAdvance ? _next : null,
              icon: const Icon(Icons.chevron_right),
              label: Text(
                'Next',
                style: GoogleFonts.cinzel(fontWeight: FontWeight.w600),
              ),
              iconAlignment: IconAlignment.end,
            ),
        ],
      ),
    );
  }

  Widget _buildArmorAndReview() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StepArmor(
            selected: _state.armorId,
            onChanged: (id) {
              setState(() {
                _state = _state.copyWith(armorId: id);
              });
            },
          ),
          // Review summary
          if (_state.armorId != null) ...[
            const Divider(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildReviewSummary(),
            ),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewSummary() {
    final classDef = _state.classId != null ? classById(_state.classId!) : null;
    final armor = _state.armorId != null ? armorById(_state.armorId!) : null;

    return Container(
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
            'Character Summary',
            style: GoogleFonts.cinzel(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          _reviewRow('Name', _state.name),
          if (_state.pronouns.isNotEmpty)
            _reviewRow('Pronouns', _state.pronouns),
          _reviewRow('Ancestry', _state.ancestryId ?? '—'),
          _reviewRow('Community', _state.communityId ?? '—'),
          _reviewRow('Class', classDef?.name ?? '—'),
          _reviewRow(
            'Subclass',
            _state.subclassId?.replaceAll('_', ' ') ?? '—',
          ),
          if (classDef != null) ...[
            _reviewRow('Starting HP', '${classDef.startingHp}'),
            _reviewRow(
              'Evasion',
              '${classDef.startingEvasion + (armor?.evasionMod ?? 0)}',
            ),
          ],
          _reviewRow('Armor', armor?.name ?? '—'),
          if (_state.traits.isNotEmpty) ...[
            const Divider(height: 16),
            Text(
              'Traits',
              style: GoogleFonts.cinzel(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: GameConstants.traitNames.map((trait) {
                final val = _state.traits[trait] ?? 0;
                return _traitPill(
                  GameConstants.traitLabels[trait] ?? trait,
                  val,
                );
              }).toList(),
            ),
          ],
          if (_state.selectedCardIds.isNotEmpty) ...[
            const Divider(height: 16),
            _reviewRow(
              'Domain Cards',
              _state.selectedCardIds.length.toString(),
            ),
          ],
          if (_state.experiences.any((e) => e.name.isNotEmpty)) ...[
            const Divider(height: 16),
            Text(
              'Experiences',
              style: GoogleFonts.cinzel(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 6),
            ..._state.experiences
                .where((e) => e.name.isNotEmpty)
                .map((e) => _reviewRow(e.name, '+${e.modifier}')),
          ],
        ],
      ),
    );
  }

  Widget _reviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.crimsonText(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.crimsonText(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _traitPill(String label, int value) {
    final color = value > 0
        ? AppColors.primary
        : value < 0
        ? AppColors.secondary
        : AppColors.textDisabled;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(
        '$label: ${value >= 0 ? '+$value' : '$value'}',
        style: GoogleFonts.cinzel(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  String? _getFirstSubclass(String classId) {
    final subclasses = subclassesForClass(classId);
    return subclasses.isNotEmpty ? subclasses.first.id : null;
  }
}
