import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/game_constants.dart';
import '../../domain/providers/character_provider.dart';
import '../../data/models/character_model.dart';
import '../../data/srd/classes_data.dart';
import '../../data/srd/domains_data.dart';
import '../../data/srd/ancestries_data.dart';
import '../../data/srd/communities_data.dart';
import 'widgets/hp_tracker.dart';
import 'widgets/stress_tracker.dart';
import 'widgets/hope_tracker.dart';
import 'widgets/armor_tracker.dart';
import 'widgets/gold_tracker.dart';
import 'widgets/sheet_section_banner.dart';
import 'widgets/damage_thresholds_widget.dart';

// Sub-actions displayed below each trait name on the official sheet
const _traitSubActions = {
  'agility':   ['Sprint', 'Leap', 'Maneuver'],
  'strength':  ['Lift', 'Smash', 'Grapple'],
  'finesse':   ['Control', 'Hide', 'Tinker'],
  'instinct':  ['Perceive', 'Sense', 'Navigate'],
  'presence':  ['Charm', 'Perform', 'Deceive'],
  'knowledge': ['Recall', 'Analyze', 'Comprehend'],
};

class CharacterSheetScreen extends ConsumerStatefulWidget {
  final String characterId;
  const CharacterSheetScreen({super.key, required this.characterId});

  @override
  ConsumerState<CharacterSheetScreen> createState() =>
      _CharacterSheetScreenState();
}

class _CharacterSheetScreenState extends ConsumerState<CharacterSheetScreen> {
  final _notesController = TextEditingController();

  // One controller per scrollable column so RawScrollbar can attach properly
  final _leftScrollCtrl    = ScrollController();
  final _rightScrollCtrl   = ScrollController();
  final _sidebarScrollCtrl = ScrollController();

  // Sidebar domain-cards / features dropdown toggle
  bool _cardsExpanded = false;

  // ── Mobile page state ──────────────────────────────────────────────────────
  int _mobilePage = 0;
  final _mobilePageCtrl = PageController();

  @override
  void dispose() {
    _notesController.dispose();
    _leftScrollCtrl.dispose();
    _rightScrollCtrl.dispose();
    _sidebarScrollCtrl.dispose();
    _mobilePageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final character = ref.watch(activeCharacterProvider(widget.characterId));
    final notifier = ref.read(
      activeCharacterProvider(widget.characterId).notifier,
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

    // Mobile devices get a fully separate, page-based layout.
    // Web always uses the desktop two-column layout regardless of window size.
    final isMobile = !kIsWeb && MediaQuery.of(context).size.width < 700;
    if (isMobile) return _buildMobileScaffold(context, character, notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context, character),
      body: LayoutBuilder(
        builder: (_, constraints) {
          // Left 10 % = empty pad. Left col = 20 % of screen.
          // Sidebar = 28 % of screen, full-height (goes to the right edge,
          // no right padding). Right body = Expanded, fills the rest.
          final lPad     = constraints.maxWidth * 0.10;
          final leftW    = constraints.maxWidth * 0.20;
          final sidebarW = constraints.maxWidth * 0.28;

          // Gold scrollbar helper (thin, always visible).
          const thumbColor   = WidgetStatePropertyAll(AppColors.hope);
          const barThickness = WidgetStatePropertyAll(4.0);
          const barRadius    = Radius.circular(3);
          const barData = ScrollbarThemeData(
            thumbColor: thumbColor, thickness: barThickness,
            radius: barRadius, thumbVisibility: WidgetStatePropertyAll(true));

          Widget scrolled(ScrollController ctrl, Widget child) =>
            ScrollbarTheme(
              data: barData,
              child: Scrollbar(
                controller: ctrl,
                child: SingleChildScrollView(
                  controller: ctrl,
                  padding: const EdgeInsets.fromLTRB(10, 10, 14, 40),
                  child: child,
                ),
              ),
            );

          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Main sheet (left pad + left col + right body) ─────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header row — shrinks on the right to give the sidebar
                    // its column of width.
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(width: lPad),              // 10 % pad
                          SizedBox(
                            width: leftW,
                            child: _buildLeftHeader(character, notifier),
                          ),
                          Container(width: 1, color: AppColors.border),
                          Expanded(child: _buildRightHeader(character)),
                        ],
                      ),
                    ),
                    Container(height: 1, color: AppColors.border),
                    // Scrollable body
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: lPad),              // 10 % pad
                          SizedBox(
                            width: leftW,
                            child: scrolled(
                              _leftScrollCtrl,
                              _buildLeftBody(character, notifier),
                            ),
                          ),
                          Container(width: 1, color: AppColors.border),
                          Expanded(
                            child: scrolled(
                              _rightScrollCtrl,
                              _buildRightBody(character, notifier),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Full-height sidebar panel ─────────────────────────────
              Container(width: 1, color: AppColors.border),
              SizedBox(
                width: sidebarW,
                child: scrolled(
                  _sidebarScrollCtrl,
                  _buildSidebar(character, notifier),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // MOBILE LAYOUT — PageView with 4 tabs (Bio · Vitals · Cards · Gear)
  // Only shown when !kIsWeb && screen width < 700 px.
  // The web/desktop layout below is completely unchanged.
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildMobileScaffold(
    BuildContext context,
    CharacterModel character,
    CharacterSheetNotifier notifier,
  ) {
    const labels = ['Bio', 'Vitals', 'Cards', 'Gear'];
    const icons  = [
      Icons.person_outline,
      Icons.favorite_border,
      Icons.style_outlined,
      Icons.inventory_2_outlined,
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
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
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            Text(
              '${_cap(character.classId)} · Lvl ${character.level}',
              style: GoogleFonts.crimsonText(
                  fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          if (character.isDown)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                  color: AppColors.hp,
                  borderRadius: BorderRadius.circular(4)),
              child: Text(
                'DOWN',
                style: GoogleFonts.cinzel(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
            ),
          IconButton(
            icon:
                const Icon(Icons.trending_up, color: AppColors.textPrimary),
            tooltip: 'Level Up',
            onPressed: () => context
                .push('/character/${widget.characterId}/level-up'),
          ),
        ],
      ),
      body: PageView(
        controller: _mobilePageCtrl,
        onPageChanged: (i) => setState(() => _mobilePage = i),
        children: [
          _mobilePageBio(character),
          _mobilePageVitals(character, notifier),
          _mobilePageCards(character, notifier),
          _mobilePageGear(character, notifier),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _mobilePage,
        onTap: (i) {
          setState(() => _mobilePage = i);
          _mobilePageCtrl.animateToPage(i,
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeInOut);
        },
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textDisabled,
        selectedFontSize: 10,
        unselectedFontSize: 9,
        selectedLabelStyle: GoogleFonts.cinzel(fontWeight: FontWeight.w700),
        unselectedLabelStyle: GoogleFonts.cinzel(),
        elevation: 12,
        items: List.generate(
          labels.length,
          (i) => BottomNavigationBarItem(
            icon: Icon(icons[i], size: 22),
            label: labels[i],
          ),
        ),
      ),
    );
  }

  // ── Mobile Page 1 · Bio ────────────────────────────────────────────────────

  Widget _mobilePageBio(CharacterModel character) {
    final screenH = MediaQuery.of(context).size.height;
    final ancestry = character.isMixedAncestry && character.ancestryId2 != null
        ? '${_cap(character.ancestryId)} / ${_cap(character.ancestryId2!)}'
        : _cap(character.ancestryId);
    final classLabel = character.multiclassId != null
        ? '${_cap(character.classId)} / ${_cap(character.multiclassId!)}'
        : _cap(character.classId);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Hero image area — 60 % of viewport height ─────────────────
          SizedBox(
            height: screenH * 0.60,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background gradient — creates depth behind the portrait
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primary.withAlpha(50),
                        AppColors.surfaceVariant.withAlpha(160),
                        AppColors.background,
                      ],
                      stops: const [0.0, 0.55, 1.0],
                    ),
                  ),
                ),
                // Portrait placeholder — replace with an image when available
                Center(
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.primary, width: 2.5),
                      color: AppColors.surfaceVariant,
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.primary.withAlpha(90),
                            blurRadius: 28,
                            spreadRadius: 2),
                      ],
                    ),
                    child: const Icon(Icons.person_outline,
                        size: 70, color: AppColors.textDisabled),
                  ),
                ),
                // Level badge — bottom-right corner
                Positioned(
                  bottom: 20,
                  right: 16,
                  child: _levelBadge(character.level, character.tier),
                ),
                // Evasion + Armor — bottom-left corner
                Positioned(
                  bottom: 20,
                  left: 16,
                  child: Row(
                    children: [
                      _headerStatBadge(
                          icon: Icons.shield_outlined,
                          label: 'EVASION',
                          value: character.evasion),
                      const SizedBox(width: 8),
                      _headerStatBadge(
                          icon: Icons.security,
                          label: 'ARMOR',
                          value: character.armorBaseScore),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Identity ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + Pronouns
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: Text(
                        character.name,
                        style: GoogleFonts.cinzel(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (character.pronouns.isNotEmpty)
                      Text(
                        character.pronouns,
                        style: GoogleFonts.crimsonText(
                            fontSize: 14,
                            color: AppColors.textDisabled),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$ancestry · ${_cap(character.communityId)}',
                  style: GoogleFonts.crimsonText(
                      fontSize: 15, color: AppColors.textSecondary),
                ),
                Text(
                  '$classLabel · ${_cap(character.subclassId.replaceAll('_', ' '))}',
                  style: GoogleFonts.crimsonText(
                      fontSize: 15, color: AppColors.textSecondary),
                ),

                const SizedBox(height: 16),
                Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 14),

                // ── Traits — 2 rows of 3 ─────────────────────────────
                Row(
                  children: GameConstants.traitNames.take(3).map((t) =>
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: _TraitBadge(
                          label: GameConstants.traitLabels[t] ?? t,
                          value: character.traitValue(t),
                          subActions:
                              _traitSubActions[t] ?? const [],
                        ),
                      ),
                    ),
                  ).toList(),
                ),
                const SizedBox(height: 6),
                Row(
                  children: GameConstants.traitNames.skip(3).map((t) =>
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: _TraitBadge(
                          label: GameConstants.traitLabels[t] ?? t,
                          value: character.traitValue(t),
                          subActions:
                              _traitSubActions[t] ?? const [],
                        ),
                      ),
                    ),
                  ).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Mobile Page 2 · Vitals ─────────────────────────────────────────────────

  Widget _mobilePageVitals(
      CharacterModel character, CharacterSheetNotifier notifier) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Quick-access HP + Stress callout at the very top
          _buildDamageHealthSection(character, notifier),
          const SizedBox(height: 12),
          _buildHopeSection(character, notifier),
          const SizedBox(height: 12),
          _buildConditionsSection(character, notifier),
        ],
      ),
    );
  }

  // ── Mobile Page 3 · Cards & Features ──────────────────────────────────────

  Widget _mobilePageCards(
      CharacterModel character, CharacterSheetNotifier notifier) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Class feature (editable notes box)
          _buildClassFeatureSection(character, notifier),
          const SizedBox(height: 12),
          // Experiences help determine how Hope is spent
          _buildExperiencesSection(character),
          const SizedBox(height: 12),
          // Heritage / community / class features + loadout domain cards
          // Always expanded on mobile (no dropdown toggle needed)
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              border:
                  Border(bottom: BorderSide(color: AppColors.hope, width: 1.5)),
            ),
            child: Text(
              'DOMAIN CARDS & FEATURES',
              style: GoogleFonts.cinzel(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppColors.hope,
                letterSpacing: 0.8,
              ),
            ),
          ),
          _buildCardsDropdown(character),
        ],
      ),
    );
  }

  // ── Mobile Page 4 · Gear ──────────────────────────────────────────────────

  Widget _mobilePageGear(
      CharacterModel character, CharacterSheetNotifier notifier) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Active weapons are most critical combat gear
          _buildWeaponsSection(character),
          const SizedBox(height: 12),
          _buildActiveArmorSection(character, notifier),
          const SizedBox(height: 12),
          _buildGoldSection(character, notifier),
          const SizedBox(height: 12),
          _buildInventorySection(character, notifier),
          const SizedBox(height: 12),
          _buildClassFeatureSection(character, notifier),
        ],
      ),
    );
  }

  // ── App bar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(
      BuildContext context, CharacterModel character) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Material(
        color: AppColors.surface,
        elevation: 4,
        shadowColor: Colors.black45,
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: kToolbarHeight,
            child: LayoutBuilder(
              builder: (_, constraints) {
                // 10% padding each side → content occupies 80% of the bar width
                final hPad = constraints.maxWidth * 0.10;
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPad),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: AppColors.textPrimary),
                        onPressed: () => context.pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                            minWidth: 40, minHeight: 40),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
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
                      ),
                      if (character.isDown)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
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
                      IconButton(
                        icon: const Icon(Icons.style_outlined,
                            color: AppColors.textPrimary),
                        tooltip: 'Domain Cards',
                        onPressed: () => context
                            .push('/character/${widget.characterId}/cards'),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                            minWidth: 40, minHeight: 40),
                      ),
                      IconButton(
                        icon: const Icon(Icons.trending_up,
                            color: AppColors.textPrimary),
                        tooltip: 'Level Up',
                        onPressed: () => context
                            .push('/character/${widget.characterId}/level-up'),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                            minWidth: 40, minHeight: 40),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // LEFT HEADER — portrait + evasion + proficiency + active conditions
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildLeftHeader(
      CharacterModel character, CharacterSheetNotifier notifier) {
    // Top-left area: only Evasion badge and Armor slots badge.
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _headerStatBadge(
              icon: Icons.shield_outlined,
              label: 'EVASION',
              value: character.evasion),
          const SizedBox(width: 10),
          _headerStatBadge(
              icon: Icons.security,
              label: 'ARMOR',
              value: character.armorBaseScore),
        ],
      ),
    );
  }

  Widget _headerStatBadge(
      {required IconData icon, required String label, required int value}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 13, color: AppColors.textDisabled),
              const SizedBox(width: 5),
              Text(
                '$value',
                style: GoogleFonts.cinzel(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: GoogleFonts.cinzel(
            fontSize: 7,
            fontWeight: FontWeight.w700,
            color: AppColors.textDisabled,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // RIGHT HEADER — identity fields + 6 trait badges
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildRightHeader(CharacterModel character) {
    final ancestry = character.isMixedAncestry && character.ancestryId2 != null
        ? '${_cap(character.ancestryId)} / ${_cap(character.ancestryId2!)}'
        : _cap(character.ancestryId);
    final subclassLabel = _cap(character.subclassId.replaceAll('_', ' '));
    final classLabel = character.multiclassId != null
        ? '${_cap(character.classId)} / ${_cap(character.multiclassId!)}'
        : _cap(character.classId);

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Row 1: Name | Pronouns | Level ──────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                flex: 5,
                child: _sheetField(
                    label: 'NAME', value: character.name, large: true),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 110,
                child: _sheetField(
                    label: 'PRONOUNS',
                    value: character.pronouns.isEmpty
                        ? '—'
                        : character.pronouns),
              ),
              const SizedBox(width: 10),
              // Level badge (shield shape)
              _levelBadge(character.level, character.tier),
            ],
          ),
          const SizedBox(height: 8),
          // ── Row 2: Heritage | Class & Subclass ──────────────────────────
          Row(
            children: [
              Expanded(
                child: _sheetField(
                    label: 'HERITAGE',
                    value: '$ancestry · ${_cap(character.communityId)}'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _sheetField(
                    label: 'CLASS & SUBCLASS',
                    value: '$classLabel · $subclassLabel'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // ── Trait badges row ─────────────────────────────────────────────
          Row(
            children: GameConstants.traitNames.map((trait) {
              return Expanded(
                child: _TraitBadge(
                  label: GameConstants.traitLabels[trait] ?? trait,
                  value: character.traitValue(trait),
                  subActions:
                      _traitSubActions[trait] ?? const [],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // A paper-sheet style labeled field (display only — edit via creation wizard)
  Widget _sheetField(
      {required String label, required String value, bool large = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: large
              ? GoogleFonts.cinzel(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                )
              : GoogleFonts.crimsonText(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Container(
          height: 1,
          color: AppColors.border,
          margin: const EdgeInsets.symmetric(vertical: 2),
        ),
        Text(
          label,
          style: GoogleFonts.cinzel(
            fontSize: 7,
            fontWeight: FontWeight.w700,
            color: AppColors.textDisabled,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  Widget _levelBadge(int level, int tier) {
    return Container(
      width: 52,
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(18),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.primary.withAlpha(80)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'LVL',
            style: GoogleFonts.cinzel(
              fontSize: 7,
              fontWeight: FontWeight.w700,
              color: AppColors.textDisabled,
              letterSpacing: 0.8,
            ),
          ),
          Text(
            '$level',
            style: GoogleFonts.cinzel(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              height: 1.0,
            ),
          ),
          Text(
            'TIER $tier',
            style: GoogleFonts.cinzel(
              fontSize: 7,
              color: AppColors.textDisabled,
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // LEFT BODY — damage & health, hope, experiences, gold, class feature
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildLeftBody(
      CharacterModel character, CharacterSheetNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildDamageHealthSection(character, notifier),
        const SizedBox(height: 8),
        _buildHopeSection(character, notifier),
        const SizedBox(height: 8),
        _buildExperiencesSection(character),
        const SizedBox(height: 8),
        _buildGoldSection(character, notifier),
        const SizedBox(height: 8),
        _buildClassFeatureSection(character, notifier),
        if (character.activeConditions.isNotEmpty ||
            GameConstants.standardConditions.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildConditionsSection(character, notifier),
        ],
      ],
    );
  }

  // ── Damage & Health ────────────────────────────────────────────────────────

  Widget _buildDamageHealthSection(
      CharacterModel character, CharacterSheetNotifier notifier) {
    return _section(
      children: [
        const SheetSectionBanner(title: 'Damage & Health'),
        const SizedBox(height: 4),
        Text(
          'Add your current level to your damage thresholds.',
          style: GoogleFonts.crimsonText(
            fontSize: 11,
            color: AppColors.textDisabled,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 8),
        DamageThresholdsWidget(
          minor: character.minorThreshold,
          major: character.majorThreshold,
          severe: character.severeThreshold,
        ),
        const SizedBox(height: 10),
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
      ],
    );
  }

  // ── Hope ──────────────────────────────────────────────────────────────────

  Widget _buildHopeSection(
      CharacterModel character, CharacterSheetNotifier notifier) {
    final cls = classById(character.classId);
    return _section(
      children: [
        const SheetSectionBanner(title: 'Hope'),
        const SizedBox(height: 4),
        Text(
          'Spend a Hope to use an experience or help an ally.',
          style: GoogleFonts.crimsonText(
            fontSize: 11,
            color: AppColors.textDisabled,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: HopeTracker(
            value: character.hope,
            onChanged: notifier.setHope,
          ),
        ),
        if (cls != null) ...[
          const SizedBox(height: 10),
          Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 8),
          Text(
            cls.hopeFeatureName.toUpperCase(),
            style: GoogleFonts.cinzel(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: AppColors.hope,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            cls.hopeFeatureDescription,
            style: GoogleFonts.crimsonText(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
        ],
      ],
    );
  }

  // ── Experiences ───────────────────────────────────────────────────────────

  Widget _buildExperiencesSection(CharacterModel character) {
    return _section(
      children: [
        const SheetSectionBanner(title: 'Experience'),
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
              padding: const EdgeInsets.only(bottom: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Arrow icon matching the official sheet's right-arrow marks
                      const Icon(Icons.chevron_right,
                          size: 14, color: AppColors.textDisabled),
                      const SizedBox(width: 4),
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
                            horizontal: 7, vertical: 2),
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
                  Container(height: 1, color: AppColors.border.withAlpha(120),
                      margin: const EdgeInsets.only(top: 3)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ── Gold ──────────────────────────────────────────────────────────────────

  Widget _buildGoldSection(
      CharacterModel character, CharacterSheetNotifier notifier) {
    return _section(
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
    );
  }

  // ── Class feature + notes ─────────────────────────────────────────────────

  Widget _buildClassFeatureSection(
      CharacterModel character, CharacterSheetNotifier notifier) {
    final cls = classById(character.classId);
    return _section(
      children: [
        const SheetSectionBanner(title: 'Class Feature'),
        if (cls != null) ...[
          const SizedBox(height: 8),
          Text(
            cls.classFeatureName.toUpperCase(),
            style: GoogleFonts.cinzel(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            cls.classFeatureDescription,
            style: GoogleFonts.crimsonText(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
        const SizedBox(height: 10),
        Divider(height: 1, color: AppColors.border),
        const SizedBox(height: 8),
        Text(
          'NOTES',
          style: GoogleFonts.cinzel(
            fontSize: 8,
            fontWeight: FontWeight.w700,
            color: AppColors.textDisabled,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _notesController,
          maxLines: 6,
          textAlignVertical: TextAlignVertical.top,
          onChanged: notifier.setNotes,
          style: GoogleFonts.crimsonText(
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'Notes, reminders, session recaps...',
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
        ),
      ],
    );
  }

  // ── Conditions ────────────────────────────────────────────────────────────

  Widget _buildConditionsSection(
      CharacterModel character, CharacterSheetNotifier notifier) {
    return _section(
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.secondary.withAlpha(45)
                      : AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color:
                        isActive ? AppColors.secondary : AppColors.border,
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
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // RIGHT BODY — active weapons (placeholder), active armor, inventory
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildRightBody(
      CharacterModel character, CharacterSheetNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildWeaponsSection(character),
        const SizedBox(height: 8),
        _buildActiveArmorSection(character, notifier),
        const SizedBox(height: 8),
        _buildInventorySection(character, notifier),
      ],
    );
  }

  // ── Sidebar (items · domain cards · features) ─────────────────────────────

  Widget _buildSidebar(
      CharacterModel character, CharacterSheetNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Domain Cards & Features — expandable dropdown ─────────────
        GestureDetector(
          onTap: () => setState(() => _cardsExpanded = !_cardsExpanded),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              border: Border(
                bottom: BorderSide(
                  color: _cardsExpanded
                      ? AppColors.hope
                      : AppColors.border,
                  width: _cardsExpanded ? 1.5 : 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'DOMAIN CARDS & FEATURES',
                    style: GoogleFonts.cinzel(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: _cardsExpanded
                          ? AppColors.hope
                          : AppColors.textSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _cardsExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.expand_more,
                    size: 16,
                    color: _cardsExpanded
                        ? AppColors.hope
                        : AppColors.textDisabled,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Animated dropdown body
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          crossFadeState: _cardsExpanded
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: _buildCardsDropdown(character),
          secondChild: const SizedBox.shrink(),
        ),

        const SizedBox(height: 12),
        // ── Inventory ─────────────────────────────────────────────────
        _buildInventorySection(character, notifier),
      ],
    );
  }

  Widget _buildCardsDropdown(CharacterModel character) {
    final ancestry  = ancestryById(character.ancestryId);
    final ancestry2 = character.ancestryId2 != null
        ? ancestryById(character.ancestryId2!)
        : null;
    final community = communityById(character.communityId);
    final cls       = classById(character.classId);

    // Resolve loadout cards from SRD data
    final loadoutCards = character.loadoutCardIds
        .map((id) => allDomainCards.where((c) => c.id == id).firstOrNull)
        .whereType<DomainCard>()
        .toList();

    Widget featureTile(String title, String body) => Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: GoogleFonts.cinzel(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: AppColors.hope,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            body,
            style: GoogleFonts.crimsonText(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
        ],
      ),
    );

    Widget cardTile(DomainCard card) => Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: AppColors.primary.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  card.name,
                  style: GoogleFonts.cinzel(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Text(
                card.domain.toUpperCase(),
                style: GoogleFonts.cinzel(
                  fontSize: 7,
                  color: AppColors.textDisabled,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            card.description,
            style: GoogleFonts.crimsonText(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.3,
            ),
          ),
        ],
      ),
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 4),
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Heritage features
          if (ancestry != null) ...[
            _sidebarSubheader('Heritage — ${ancestry.name}'),
            featureTile(ancestry.name, ancestry.featureTop),
            featureTile('${ancestry.name} (alt)', ancestry.featureBottom),
          ],
          if (ancestry2 != null) ...[
            _sidebarSubheader('Heritage — ${ancestry2.name}'),
            featureTile(ancestry2.name, ancestry2.featureTop),
          ],
          if (community != null) ...[
            _sidebarSubheader('Community — ${community.name}'),
            featureTile(community.name, community.feature),
          ],
          // Class feature
          if (cls != null) ...[
            _sidebarSubheader('Class Feature — ${cls.name}'),
            featureTile(cls.hopeFeatureName, cls.hopeFeatureDescription),
          ],
          // Loadout domain cards
          if (loadoutCards.isNotEmpty) ...[
            _sidebarSubheader('Loadout Cards (${loadoutCards.length})'),
            ...loadoutCards.map(cardTile),
          ],
          if (loadoutCards.isEmpty && ancestry == null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'No domain cards in loadout.',
                style: GoogleFonts.crimsonText(
                  fontSize: 13,
                  color: AppColors.textDisabled,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _sidebarSubheader(String label) => Padding(
    padding: const EdgeInsets.only(top: 4, bottom: 6),
    child: Text(
      label.toUpperCase(),
      style: GoogleFonts.cinzel(
        fontSize: 8,
        fontWeight: FontWeight.w700,
        color: AppColors.textDisabled,
        letterSpacing: 1.0,
      ),
    ),
  );

  // ── Active Weapons (placeholder) ──────────────────────────────────────────

  Widget _buildWeaponsSection(CharacterModel character) {
    return _section(
      children: [
        SheetSectionBanner(
          title: 'Active Weapons',
          trailing: GestureDetector(
            onTap: () =>
                context.push('/character/${widget.characterId}/cards'),
            child: Text(
              'CARDS',
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
        // Proficiency circles
        Row(
          children: [
            Text(
              'PROFICIENCY',
              style: GoogleFonts.cinzel(
                fontSize: 8,
                fontWeight: FontWeight.w700,
                color: AppColors.textDisabled,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(width: 8),
            ...List.generate(6, (i) {
              final filled = i < character.proficiency;
              return Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  filled ? Icons.circle : Icons.circle_outlined,
                  size: 10,
                  color: filled
                      ? AppColors.primary
                      : AppColors.textDisabled.withAlpha(80),
                ),
              );
            }),
          ],
        ),
        const SizedBox(height: 12),
        _weaponSlot('PRIMARY'),
        const SizedBox(height: 12),
        _weaponSlot('SECONDARY'),
      ],
    );
  }

  Widget _weaponSlot(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Subsection label
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(3),
          ),
          child: Text(
            label,
            style: GoogleFonts.cinzel(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 0.6,
            ),
          ),
        ),
        const SizedBox(height: 6),
        // Field row: NAME | TRAIT & RANGE | DAMAGE DICE & TYPE
        Row(
          children: [
            Expanded(flex: 3, child: _blankField('NAME')),
            const SizedBox(width: 6),
            Expanded(flex: 2, child: _blankField('TRAIT & RANGE')),
            const SizedBox(width: 6),
            Expanded(flex: 2, child: _blankField('DAMAGE DICE & TYPE')),
          ],
        ),
        const SizedBox(height: 6),
        _blankField('FEATURE'),
      ],
    );
  }

  // A blank paper-style field with a label below a bottom-border line
  Widget _blankField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 22,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.border),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.cinzel(
            fontSize: 7,
            color: AppColors.textDisabled,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  // ── Active Armor ──────────────────────────────────────────────────────────

  Widget _buildActiveArmorSection(
      CharacterModel character, CharacterSheetNotifier notifier) {
    final armorName =
        character.armorType.isEmpty ? '—' : _cap(character.armorType);
    return _section(
      children: [
        const SheetSectionBanner(title: 'Active Armor'),
        const SizedBox(height: 8),
        // Name | Base Thresholds | Base Score
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              flex: 3,
              child: _labeledValue('NAME', armorName),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: _labeledValue(
                'BASE THRESHOLDS',
                '${character.minorThreshold} / ${character.majorThreshold}',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: _labeledValue(
                  'BASE SCORE', '${character.armorBaseScore}'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Mark/unmark armor slots
        ArmorTracker(
          armorType: character.armorType,
          baseScore: character.armorBaseScore,
          markedSlots: character.armorMarkedSlots,
          onChanged: notifier.setArmorMarked,
        ),
      ],
    );
  }

  // A value with a label below, like a paper field display
  Widget _labeledValue(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: GoogleFonts.crimsonText(
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Container(
          height: 1,
          color: AppColors.border,
          margin: const EdgeInsets.symmetric(vertical: 2),
        ),
        Text(
          label,
          style: GoogleFonts.cinzel(
            fontSize: 7,
            color: AppColors.textDisabled,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  // ── Inventory ─────────────────────────────────────────────────────────────

  Widget _buildInventorySection(
      CharacterModel character, CharacterSheetNotifier notifier) {
    return _section(
      children: [
        SheetSectionBanner(
          title: 'Inventory',
          trailing: GestureDetector(
            onTap: () => _showAddInventoryDialog(context, notifier),
            child: const Icon(Icons.add, size: 13, color: AppColors.primary),
          ),
        ),
        const SizedBox(height: 8),
        // Blank inventory lines (always show at least 8)
        ...List.generate(
          math.max(8, character.inventory.length),
          (i) {
            if (i < character.inventory.length) {
              final item = character.inventory[i];
              return _inventoryRow(
                text: item,
                onDelete: () => notifier.removeInventoryItem(item),
              );
            }
            // Blank line
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Container(
                height: 18,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.border.withAlpha(80)),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        // Add item button
        GestureDetector(
          onTap: () => _showAddInventoryDialog(context, notifier),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_circle_outline,
                  size: 12, color: AppColors.primary),
              const SizedBox(width: 5),
              Text(
                'ADD ITEM',
                style: GoogleFonts.cinzel(
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Inventory Weapon slots (placeholders matching the official sheet)
        _inventoryWeaponSlot(1),
        const SizedBox(height: 10),
        _inventoryWeaponSlot(2),
      ],
    );
  }

  Widget _inventoryRow({required String text, required VoidCallback onDelete}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 5, color: AppColors.textDisabled),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: GoogleFonts.crimsonText(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                Container(
                  height: 1,
                  color: AppColors.border.withAlpha(80),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onDelete,
            child: const Icon(Icons.close,
                size: 13, color: AppColors.textDisabled),
          ),
        ],
      ),
    );
  }

  Widget _inventoryWeaponSlot(int number) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(5),
        color: AppColors.surfaceVariant.withAlpha(60),
      ),
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'INVENTORY WEAPON',
                style: GoogleFonts.cinzel(
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDisabled,
                  letterSpacing: 0.7,
                ),
              ),
              const Spacer(),
              // PRIMARY / SECONDARY checkboxes placeholder
              _miniCheckbox('PRIMARY'),
              const SizedBox(width: 8),
              _miniCheckbox('SECONDARY'),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(flex: 3, child: _blankField('NAME')),
              const SizedBox(width: 6),
              Expanded(flex: 2, child: _blankField('TRAIT & RANGE')),
              const SizedBox(width: 6),
              Expanded(flex: 2, child: _blankField('DAMAGE DICE & TYPE')),
            ],
          ),
          const SizedBox(height: 5),
          _blankField('FEATURE'),
        ],
      ),
    );
  }

  Widget _miniCheckbox(String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: GoogleFonts.cinzel(
            fontSize: 7,
            color: AppColors.textDisabled,
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Shared helpers
  // ══════════════════════════════════════════════════════════════════════════

  // Card-style section container
  Widget _section({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  void _showAddInventoryDialog(
      BuildContext context, CharacterSheetNotifier notifier) {
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

  String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ── Trait badge ────────────────────────────────────────────────────────────────

class _TraitBadge extends StatelessWidget {
  final String label;
  final int value;
  final List<String> subActions;
  const _TraitBadge({
    required this.label,
    required this.value,
    this.subActions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final color = value > 0
        ? AppColors.primary
        : value < 0
            ? AppColors.secondary
            : AppColors.textSecondary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                const SizedBox(height: 2),
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
          ),
          // Sub-actions shown below the badge (Sprint, Leap, Maneuver…)
          if (subActions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Column(
                children: subActions
                    .map(
                      (a) => Text(
                        a,
                        style: GoogleFonts.crimsonText(
                          fontSize: 9,
                          color: AppColors.textDisabled,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}
