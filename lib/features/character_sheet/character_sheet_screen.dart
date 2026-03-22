import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/game_constants.dart';
import '../../domain/providers/character_provider.dart';
import '../../data/models/character_model.dart';
import '../../data/srd/classes_data.dart';
import 'widgets/hp_tracker.dart';
import 'widgets/stress_tracker.dart';
import 'widgets/hope_tracker.dart';
import 'widgets/armor_tracker.dart';
import 'widgets/gold_tracker.dart';
import 'widgets/sheet_section_banner.dart';
import 'widgets/damage_thresholds_widget.dart';
import 'sheet_layout.dart';
import 'sheet_grid_editor.dart';

class CharacterSheetScreen extends ConsumerStatefulWidget {
  final String characterId;
  const CharacterSheetScreen({super.key, required this.characterId});

  @override
  ConsumerState<CharacterSheetScreen> createState() =>
      _CharacterSheetScreenState();
}

class _CharacterSheetScreenState extends ConsumerState<CharacterSheetScreen> {
  final _notesController = TextEditingController();
  final _inventoryController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    _inventoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final character = ref.watch(activeCharacterProvider(widget.characterId));
    final notifier = ref.read(
      activeCharacterProvider(widget.characterId).notifier,
    );
    final layout = ref.watch(sheetLayoutProvider(widget.characterId));
    final layoutNotifier = ref.read(
      sheetLayoutProvider(widget.characterId).notifier,
    );

    if (character == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_notesController.text != character.notes) {
      _notesController.text = character.notes;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context, character, layoutNotifier),
      // ── Fixed-width content area ──────────────────────────────────────────
      // The AppBar (back arrow / domain cards / level-up) is a Scaffold AppBar
      // and stays full-width automatically.
      //
      // Everything below it — identity card + every other grid block — lives
      // inside a ConstrainedBox(maxWidth: 1060).  As long as the viewport is
      // wider than 1060 px (true on any normal desktop even with Edge's side
      // ribbon open), the content is pinned at exactly 1060 px and never
      // reflows when the browser window changes.
      //
      // 10 % horizontal padding inside that box makes the actual content 80 %
      // of 1060 = 848 px, matching the user's "80 %" request.
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(106, 8, 106, 40),
            child: InteractiveSheetGrid(
              blocks: layout,
              blockBuilder: (blockId, rowSpan) =>
                  _buildBlock(blockId, character, notifier, rowSpan),
              onLayoutChanged: layoutNotifier.setLayout,
            ),
          ),
        ),
      ),
    );
  }

  // ── App bar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    CharacterModel character,
    SheetLayoutNotifier layoutNotifier,
  ) {
    return AppBar(
      backgroundColor: AppColors.surface,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        onPressed: () => context.pop(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            character.name,
            style: GoogleFonts.cinzel(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          Text(
            '${_cap(character.classId)} · Lvl ${character.level}',
            style: GoogleFonts.crimsonText(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      actions: [
        if (character.isDown)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.hp,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'DOWN',
              style: GoogleFonts.cinzel(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ),
        // Reset layout to default
        IconButton(
          icon: const Icon(
            Icons.dashboard_customize,
            color: AppColors.textDisabled,
          ),
          tooltip: 'Reset layout',
          onPressed: () => layoutNotifier.resetLayout(),
        ),
        IconButton(
          icon: const Icon(Icons.style_outlined, color: AppColors.textPrimary),
          tooltip: 'Domain Cards',
          onPressed: () =>
              context.push('/character/${widget.characterId}/cards'),
        ),
        IconButton(
          icon: const Icon(Icons.trending_up, color: AppColors.textPrimary),
          tooltip: 'Level Up',
          onPressed: () =>
              context.push('/character/${widget.characterId}/level-up'),
        ),
      ],
    );
  }

  // ── Block dispatcher ───────────────────────────────────────────────────────

  Widget _buildBlock(
    String id,
    CharacterModel character,
    CharacterSheetNotifier notifier,
    double rowSpan,
  ) {
    switch (id) {
      case kBlockIdentity:
        return _buildIdentityBlock(character);
      case kBlockVitals:
        return _buildVitalsBlock(character, notifier);
      case kBlockHope:
        return _buildHopeBlock(character, notifier);
      case kBlockArmor:
        return _buildArmorBlock(character, notifier);
      case kBlockTraits:
        return _buildTraitsBlock(character);
      case kBlockConditions:
        return _buildConditionsBlock(character, notifier);
      case kBlockCards:
        return _buildDomainCardsBlock(character, rowSpan);
      case kBlockExperiences:
        return _buildExperiencesBlock(character, rowSpan);
      case kBlockGold:
        return _buildGoldBlock(character, notifier);
      case kBlockInventory:
        return _buildInventoryBlock(character, notifier, rowSpan);
      case kBlockNotes:
        return _buildNotesBlock(character, notifier, rowSpan);
      default:
        return const SizedBox.shrink();
    }
  }

  // ── Shared card wrapper ────────────────────────────────────────────────────

  // Natural-height container — the grid slot wraps it in SizedBox.expand()
  // when rowSpan > 0, so the card fills the allocated cell automatically.
  Widget _card(Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }

  // ── Identity ───────────────────────────────────────────────────────────────

  Widget _buildIdentityBlock(CharacterModel character) {
    final ancestry = character.isMixedAncestry && character.ancestryId2 != null
        ? '${_cap(character.ancestryId)} / ${_cap(character.ancestryId2!)}'
        : _cap(character.ancestryId);
    return _card(
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (character.pronouns.isNotEmpty)
                  Text(
                    character.pronouns,
                    style: GoogleFonts.crimsonText(
                      fontSize: 11,
                      color: AppColors.textDisabled,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                _iRow(
                  'Class',
                  '${_cap(character.classId)} · ${_cap(character.subclassId.replaceAll('_', ' '))}',
                ),
                if (character.multiclassId != null)
                  _iRow('Multi', _cap(character.multiclassId!)),
                _iRow('Ancestry', ancestry),
                _iRow('Community', _cap(character.communityId)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 50,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(18),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.primary.withAlpha(70)),
            ),
            child: Column(
              children: [
                Text(
                  'LVL',
                  style: GoogleFonts.cinzel(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDisabled,
                    letterSpacing: 0.8,
                  ),
                ),
                Text(
                  '${character.level}',
                  style: GoogleFonts.cinzel(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    height: 1.0,
                  ),
                ),
                Text(
                  'T${character.tier}',
                  style: GoogleFonts.cinzel(
                    fontSize: 8,
                    color: AppColors.textDisabled,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _iRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 2),
    child: RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label: ',
            style: GoogleFonts.cinzel(
              fontSize: 9,
              color: AppColors.textDisabled,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(
            text: value,
            style: GoogleFonts.crimsonText(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    ),
  );

  // ── Vitals ─────────────────────────────────────────────────────────────────

  Widget _buildVitalsBlock(
    CharacterModel character,
    CharacterSheetNotifier notifier,
  ) {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SheetSectionBanner(title: 'Damage & Health'),
          const SizedBox(height: 8),
          // ── Damage thresholds (Minor → Major → Severe) ────────────────
          DamageThresholdsWidget(
            minor: character.minorThreshold,
            major: character.majorThreshold,
            severe: character.severeThreshold,
          ),
          const SizedBox(height: 10),
          // ── Hit points ────────────────────────────────────────────────
          HpTracker(
            current: character.currentHp,
            max: character.maxHpSlots,
            onChanged: notifier.setHp,
          ),
          const SizedBox(height: 8),
          StressTracker(
            current: character.currentStress,
            max: character.maxStressSlots,
            onChanged: notifier.setStress,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _quickStat('EVA', character.evasion),
              const SizedBox(width: 6),
              _quickStat('PROF', character.proficiency),
            ],
          ),
        ],
      ),
    );
  }

  // ── Hope ───────────────────────────────────────────────────────────────────

  Widget _buildHopeBlock(
    CharacterModel character,
    CharacterSheetNotifier notifier,
  ) {
    final cls = classById(character.classId);
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SheetSectionBanner(title: 'Hope'),
          const SizedBox(height: 8),

          // ── Class Hope feature ─────────────────────────────────────────
          if (cls != null) ...[
            Text(
              cls.hopeFeatureName.toUpperCase(),
              style: GoogleFonts.cinzel(
                fontSize: 8,
                fontWeight: FontWeight.w700,
                color: AppColors.hope,
                letterSpacing: 0.8,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              cls.hopeFeatureDescription,
              style: GoogleFonts.crimsonText(
                fontSize: 11,
                color: AppColors.textSecondary,
                height: 1.35,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
          ],

          // ── Hope diamonds — centered ────────────────────────────────────
          Center(
            child: HopeTracker(
              value: character.hope,
              onChanged: notifier.setHope,
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickStat(String label, int value) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      color: AppColors.surfaceVariant,
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label ',
          style: GoogleFonts.cinzel(
            fontSize: 8,
            fontWeight: FontWeight.w700,
            color: AppColors.textDisabled,
            letterSpacing: 0.6,
          ),
        ),
        Text(
          '$value',
          style: GoogleFonts.cinzel(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ],
    ),
  );

  // ── Armor ──────────────────────────────────────────────────────────────────

  Widget _buildArmorBlock(
    CharacterModel character,
    CharacterSheetNotifier notifier,
  ) {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SheetSectionBanner(title: 'Armor'),
          const SizedBox(height: 8),
          ArmorTracker(
            armorType: character.armorType,
            baseScore: character.armorBaseScore,
            markedSlots: character.armorMarkedSlots,
            onChanged: notifier.setArmorMarked,
          ),
        ],
      ),
    );
  }

  // ── Traits ─────────────────────────────────────────────────────────────────

  Widget _buildTraitsBlock(CharacterModel character) {
    return _card(
      Column(
        // crossAxisAlignment: stretch so the banner and wrap fill the card width
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SheetSectionBanner(title: 'Traits'),
          const SizedBox(height: 10),
          // Centre all trait badges horizontally
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: GameConstants.traitNames.map((trait) {
              final value = character.traitValue(trait);
              final label = GameConstants.traitLabels[trait] ?? trait;
              return _TraitBadge(label: label, value: value);
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Conditions ─────────────────────────────────────────────────────────────

  Widget _buildConditionsBlock(
    CharacterModel character,
    CharacterSheetNotifier notifier,
  ) {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SheetSectionBanner(title: 'Conditions'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 5,
            runSpacing: 5,
            children: GameConstants.standardConditions.map((condition) {
              final isActive = character.activeConditions.contains(condition);
              return GestureDetector(
                onTap: () => notifier.toggleCondition(condition),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.secondary.withAlpha(45)
                        : AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isActive ? AppColors.secondary : AppColors.border,
                      width: isActive ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    condition,
                    style: GoogleFonts.cinzel(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: isActive
                          ? AppColors.textPrimary
                          : AppColors.textDisabled,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Domain cards ───────────────────────────────────────────────────────────

  Widget _buildDomainCardsBlock(CharacterModel character, double rowSpan) {
    // When a fixed height is set, use the viewport fraction minus header overhead.
    // When auto (rowSpan == 0.0), fall back to a comfortable fixed list height.
    final listHeight = rowSpan > 0
        ? math.max(60.0, rowSpan * MediaQuery.of(context).size.height - 90.0)
        : 120.0;
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SheetSectionBanner(
            title: 'Domain Cards',
            trailing: GestureDetector(
              onTap: () =>
                  context.push('/character/${widget.characterId}/cards'),
              child: Text(
                'BROWSE',
                style: GoogleFonts.cinzel(
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          DefaultTabController(
            length: 2,
            child: Column(
              children: [
                TabBar(
                  labelStyle: GoogleFonts.cinzel(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                  tabs: [
                    Tab(
                      text:
                          'LOADOUT (${character.loadoutCardIds.length}/${GameConstants.maxLoadoutCards})',
                    ),
                    Tab(text: 'VAULT (${character.vaultCardIds.length})'),
                  ],
                ),
                SizedBox(
                  height: listHeight,
                  child: TabBarView(
                    children: [
                      _cardList(character.loadoutCardIds, true),
                      _cardList(character.vaultCardIds, false),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardList(List<String> ids, bool isLoadout) {
    if (ids.isEmpty) {
      return Center(
        child: Text(
          isLoadout ? 'No cards in loadout.' : 'No cards in vault.',
          style: GoogleFonts.crimsonText(
            fontSize: 12,
            color: AppColors.textDisabled,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 6),
      children: ids.map((id) {
        final name = id
            .split('_')
            .map(
              (w) =>
                  w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '',
            )
            .join(' ');
        return Row(
          children: [
            const Icon(Icons.style, size: 11, color: AppColors.primary),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                name,
                style: GoogleFonts.crimsonText(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  // ── Experiences ────────────────────────────────────────────────────────────

  Widget _buildExperiencesBlock(CharacterModel character, double rowSpan) {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SheetSectionBanner(title: 'Experiences'),
          const SizedBox(height: 8),
          if (character.experiences.isEmpty)
            Text(
              'No experiences yet.',
              style: GoogleFonts.crimsonText(
                fontSize: 13,
                color: AppColors.textDisabled,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            ...character.experiences.map(
              (exp) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        exp.name,
                        style: GoogleFonts.crimsonText(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        exp.modifier >= 0
                            ? '+${exp.modifier}'
                            : '${exp.modifier}',
                        style: GoogleFonts.cinzel(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Gold ───────────────────────────────────────────────────────────────────

  Widget _buildGoldBlock(
    CharacterModel character,
    CharacterSheetNotifier notifier,
  ) {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SheetSectionBanner(title: 'Gold'),
          const SizedBox(height: 8),
          GoldTracker(
            handfuls: character.goldHandfuls,
            bags: character.goldBags,
            chests: character.goldChests,
            onChanged: notifier.setGold,
          ),
        ],
      ),
    );
  }

  // ── Inventory ──────────────────────────────────────────────────────────────

  Widget _buildInventoryBlock(
    CharacterModel character,
    CharacterSheetNotifier notifier,
    double rowSpan,
  ) {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SheetSectionBanner(
            title: 'Inventory',
            trailing: GestureDetector(
              onTap: () => _showAddInventoryDialog(context, notifier),
              child: const Icon(Icons.add, size: 13, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 8),
          if (character.inventory.isEmpty)
            Text(
              'No items.',
              style: GoogleFonts.crimsonText(
                fontSize: 13,
                color: AppColors.textDisabled,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            ...character.inventory.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Row(
                  children: [
                    const Icon(
                      Icons.circle,
                      size: 5,
                      color: AppColors.textDisabled,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        item,
                        style: GoogleFonts.crimsonText(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => notifier.removeInventoryItem(item),
                      child: const Icon(
                        Icons.close,
                        size: 13,
                        color: AppColors.textDisabled,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Notes ──────────────────────────────────────────────────────────────────

  Widget _buildNotesBlock(
    CharacterModel character,
    CharacterSheetNotifier notifier,
    double rowSpan,
  ) {
    final hasFixedHeight = rowSpan > 0;

    final textField = TextField(
      controller: _notesController,
      // expands: true + null maxLines fills the Expanded space in fixed mode.
      // In auto mode (rowSpan == 0) we use maxLines: 5 instead — Expanded
      // cannot be used inside a Column with unbounded height.
      maxLines: hasFixedHeight ? null : 5,
      expands: hasFixedHeight,
      textAlignVertical: TextAlignVertical.top,
      onChanged: notifier.setNotes,
      style: GoogleFonts.crimsonText(
        fontSize: 14,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: 'Write your notes here...',
        hintStyle: GoogleFonts.crimsonText(
          color: AppColors.textDisabled,
          fontStyle: FontStyle.italic,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        contentPadding: const EdgeInsets.all(9),
      ),
    );

    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SheetSectionBanner(title: 'Notes'),
          const SizedBox(height: 8),
          // Expanded only works when the parent Column has a bounded height,
          // which happens when the grid slot has a fixed rowSpan.
          if (hasFixedHeight) Expanded(child: textField) else textField,
        ],
      ),
    );
  }

  // ── Dialogs ────────────────────────────────────────────────────────────────

  void _showAddInventoryDialog(
    BuildContext context,
    CharacterSheetNotifier notifier,
  ) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Add Item',
          style: GoogleFonts.cinzel(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: GoogleFonts.crimsonText(
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
          decoration: const InputDecoration(hintText: 'Item name...'),
          onSubmitted: (v) {
            if (v.trim().isNotEmpty) {
              notifier.addInventoryItem(v.trim());
              Navigator.of(ctx).pop();
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                notifier.addInventoryItem(ctrl.text.trim());
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ── Trait badge ───────────────────────────────────────────────────────────────

class _TraitBadge extends StatelessWidget {
  final String label;
  final int value;
  const _TraitBadge({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final color = value > 0
        ? AppColors.primary
        : value < 0
        ? AppColors.secondary
        : AppColors.textSecondary;
    return Container(
      width: 68,
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(4),
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.cinzel(
              fontSize: 7,
              fontWeight: FontWeight.w700,
              color: AppColors.textDisabled,
              letterSpacing: 0.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 3),
          Text(
            value >= 0 ? '+$value' : '$value',
            style: GoogleFonts.cinzel(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
