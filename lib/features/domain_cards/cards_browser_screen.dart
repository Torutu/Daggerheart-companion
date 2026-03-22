import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/game_constants.dart';
import '../../data/srd/classes_data.dart';
import '../../data/srd/domains_data.dart';
import '../../domain/providers/character_provider.dart';
import 'widgets/domain_card_tile.dart';

class CardsBrowserScreen extends ConsumerStatefulWidget {
  final String characterId;
  const CardsBrowserScreen({super.key, required this.characterId});

  @override
  ConsumerState<CardsBrowserScreen> createState() => _CardsBrowserScreenState();
}

class _CardsBrowserScreenState extends ConsumerState<CardsBrowserScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Filters
  String? _filterDomain;
  String? _filterType;
  double _filterMaxLevel = 10;

  final List<String> _allTypes = ['ability', 'spell', 'grimoire'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 10, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
        appBar: AppBar(title: const Text('Cards Browser')),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final classDef = classById(character.classId);
    final characterDomains = classDef?.domains ?? [];
    final multiclassDef = character.multiclassId != null
        ? classById(character.multiclassId!)
        : null;
    final allDomains = <String>{
      ...characterDomains,
      ...?multiclassDef?.domains,
    }.toList();

    // Get all cards for character's domains, filtered
    var cards = allDomainCards.where((card) {
      if (_filterDomain != null && card.domain != _filterDomain) return false;
      if (_filterType != null && card.type != _filterType) return false;
      if (card.level > _filterMaxLevel) return false;
      // Only show cards in character's domains
      if (!allDomains.contains(card.domain)) return false;
      return true;
    }).toList();

    // Sort by domain then level
    cards.sort((a, b) {
      final domainCmp = a.domain.compareTo(b.domain);
      if (domainCmp != 0) return domainCmp;
      return a.level.compareTo(b.level);
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Domain Cards',
          style: GoogleFonts.cinzel(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter bar
          _buildFilterBar(character.level, allDomains),
          // Stats bar
          _buildStatsBar(character),
          const Divider(height: 1),
          // Card list
          Expanded(
            child: cards.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.style_outlined,
                          size: 48,
                          color: AppColors.textDisabled,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No cards match the current filters.',
                          style: GoogleFonts.crimsonText(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: cards.length,
                    itemBuilder: (context, i) {
                      final card = cards[i];
                      final inLoadout = character.loadoutCardIds.contains(
                        card.id,
                      );
                      final inVault = character.vaultCardIds.contains(card.id);
                      final canAddToLoadout =
                          !inLoadout &&
                          character.loadoutCardIds.length <
                              GameConstants.maxLoadoutCards &&
                          card.level <= character.level;

                      return DomainCardTile(
                        card: card,
                        inLoadout: inLoadout,
                        inVault: inVault,
                        onAddToLoadout: canAddToLoadout
                            ? () => notifier.addToLoadout(card.id)
                            : null,
                        onMoveToVault: inLoadout
                            ? () => notifier.moveToVault(card.id)
                            : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(int characterLevel, List<String> availableDomains) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Domain filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChip(
                  label: 'All Domains',
                  selected: _filterDomain == null,
                  onTap: () => setState(() => _filterDomain = null),
                ),
                ...availableDomains.map(
                  (domain) => _filterChip(
                    label: domain.toUpperCase(),
                    selected: _filterDomain == domain,
                    color: AppColors.domainColor(domain),
                    onTap: () => setState(() {
                      _filterDomain = _filterDomain == domain ? null : domain;
                    }),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          // Type filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChip(
                  label: 'All Types',
                  selected: _filterType == null,
                  onTap: () => setState(() => _filterType = null),
                ),
                ..._allTypes.map(
                  (type) => _filterChip(
                    label: type.toUpperCase(),
                    selected: _filterType == type,
                    onTap: () => setState(() {
                      _filterType = _filterType == type ? null : type;
                    }),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          // Level slider
          Row(
            children: [
              Text(
                'Max Level: ${_filterMaxLevel.toInt()}',
                style: GoogleFonts.cinzel(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.primary,
                    inactiveTrackColor: AppColors.divider,
                    thumbColor: AppColors.primary,
                    overlayColor: AppColors.primary.withAlpha(40),
                  ),
                  child: Slider(
                    value: _filterMaxLevel,
                    min: 1,
                    max: 10,
                    divisions: 9,
                    onChanged: (v) => setState(() => _filterMaxLevel = v),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar(character) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.cardBackground,
      child: Row(
        children: [
          const Icon(Icons.style, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            'Loadout: ${character.loadoutCardIds.length}/${GameConstants.maxLoadoutCards}',
            style: GoogleFonts.cinzel(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color:
                  character.loadoutCardIds.length >=
                      GameConstants.maxLoadoutCards
                  ? AppColors.secondary
                  : AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          const Icon(
            Icons.inventory_2_outlined,
            size: 14,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 6),
          Text(
            'Vault: ${character.vaultCardIds.length}',
            style: GoogleFonts.cinzel(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            'Char. Level ${character.level}',
            style: GoogleFonts.cinzel(
              fontSize: 11,
              color: AppColors.textDisabled,
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    Color? color,
  }) {
    final chipColor = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? chipColor.withAlpha(50) : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected ? chipColor : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.cinzel(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: selected ? chipColor : AppColors.textDisabled,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
