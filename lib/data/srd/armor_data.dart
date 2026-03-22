/// Daggerheart SRD v1.0 — Armor Table
class ArmorDefinition {
  final String id;
  final String name;
  final int baseScore; // = armor slots
  final int minorBase; // base Minor threshold
  final int majorBase; // base Major threshold
  final int evasionMod;
  final int? agilityMod;
  final String tag; // 'flexible' | 'standard' | 'heavy' | 'veryheavy'
  final String description;
  final int tier;

  const ArmorDefinition({
    required this.id, required this.name, required this.baseScore,
    required this.minorBase, required this.majorBase,
    required this.evasionMod, this.agilityMod, required this.tag,
    required this.description, required this.tier,
  });

  int get severeBase => majorBase + (majorBase - minorBase);
}

const List<ArmorDefinition> allArmor = [
  // ── Tier 1 (Level 1) ─────────────────────────────────────────────────────
  ArmorDefinition(id: 'gambeson_t1', name: 'Gambeson', baseScore: 2,
    minorBase: 4, majorBase: 6, evasionMod: 1, tag: 'flexible',
    description: 'Padded cloth armor, light and flexible.', tier: 1),
  ArmorDefinition(id: 'leather_t1', name: 'Leather', baseScore: 3,
    minorBase: 5, majorBase: 7, evasionMod: 0, tag: 'standard',
    description: 'Hardened leather armor, the adventurer\'s standard.', tier: 1),
  ArmorDefinition(id: 'chainmail_t1', name: 'Chainmail', baseScore: 4,
    minorBase: 6, majorBase: 8, evasionMod: -2, tag: 'heavy',
    description: 'Interlocking metal rings, solid protection.', tier: 1),
  ArmorDefinition(id: 'fullplate_t1', name: 'Full Plate', baseScore: 5,
    minorBase: 7, majorBase: 9, evasionMod: -2, agilityMod: -1,
    tag: 'veryheavy',
    description: 'Complete plate armor, maximum protection.', tier: 1),
  // ── Tier 2 (Levels 2–4) ───────────────────────────────────────────────────
  ArmorDefinition(id: 'gambeson_t2', name: 'Improved Gambeson', baseScore: 3,
    minorBase: 5, majorBase: 7, evasionMod: 1, tag: 'flexible',
    description: 'Reinforced padded armor.', tier: 2),
  ArmorDefinition(id: 'leather_t2', name: 'Improved Leather', baseScore: 4,
    minorBase: 6, majorBase: 8, evasionMod: 0, tag: 'standard',
    description: 'Superior hardened leather.', tier: 2),
  ArmorDefinition(id: 'chainmail_t2', name: 'Improved Chainmail', baseScore: 5,
    minorBase: 7, majorBase: 9, evasionMod: -2, tag: 'heavy',
    description: 'Finely crafted chainmail.', tier: 2),
  ArmorDefinition(id: 'fullplate_t2', name: 'Improved Full Plate', baseScore: 6,
    minorBase: 8, majorBase: 10, evasionMod: -2, agilityMod: -1,
    tag: 'veryheavy',
    description: 'Master-crafted plate armor.', tier: 2),
  // ── Tier 3 (Levels 5–7) ───────────────────────────────────────────────────
  ArmorDefinition(id: 'gambeson_t3', name: 'Advanced Gambeson', baseScore: 4,
    minorBase: 6, majorBase: 8, evasionMod: 1, tag: 'flexible',
    description: 'Magically reinforced padded armor.', tier: 3),
  ArmorDefinition(id: 'leather_t3', name: 'Advanced Leather', baseScore: 5,
    minorBase: 7, majorBase: 9, evasionMod: 0, tag: 'standard',
    description: 'Magically treated leather armor.', tier: 3),
  ArmorDefinition(id: 'chainmail_t3', name: 'Advanced Chainmail', baseScore: 6,
    minorBase: 8, majorBase: 10, evasionMod: -2, tag: 'heavy',
    description: 'Enchanted chainmail.', tier: 3),
  ArmorDefinition(id: 'fullplate_t3', name: 'Advanced Full Plate', baseScore: 7,
    minorBase: 9, majorBase: 11, evasionMod: -2, agilityMod: -1,
    tag: 'veryheavy',
    description: 'Enchanted full plate.', tier: 3),
  // ── Tier 4 (Levels 8–10) ──────────────────────────────────────────────────
  ArmorDefinition(id: 'gambeson_t4', name: 'Legendary Gambeson', baseScore: 5,
    minorBase: 7, majorBase: 9, evasionMod: 1, tag: 'flexible',
    description: 'Legendary padded armor, impossibly light yet strong.', tier: 4),
  ArmorDefinition(id: 'leather_t4', name: 'Legendary Leather', baseScore: 6,
    minorBase: 8, majorBase: 10, evasionMod: 0, tag: 'standard',
    description: 'Legendary dragon-hide leather.', tier: 4),
  ArmorDefinition(id: 'chainmail_t4', name: 'Legendary Chainmail', baseScore: 7,
    minorBase: 9, majorBase: 11, evasionMod: -2, tag: 'heavy',
    description: 'Legendary mithral chainmail.', tier: 4),
  ArmorDefinition(id: 'fullplate_t4', name: 'Legendary Full Plate', baseScore: 8,
    minorBase: 10, majorBase: 12, evasionMod: -2, agilityMod: -1,
    tag: 'veryheavy',
    description: 'Legendary adamantine full plate.', tier: 4),
];

List<ArmorDefinition> armorForTier(int tier) =>
    allArmor.where((a) => a.tier == tier).toList();

ArmorDefinition? armorById(String id) {
  try {
    return allArmor.firstWhere((a) => a.id == id);
  } catch (_) {
    return null;
  }
}

/// Get the base armor type key ('gambeson'|'leather'|'chainmail'|'fullplate')
String armorTypeKey(String armorId) {
  if (armorId.startsWith('gambeson')) return 'gambeson';
  if (armorId.startsWith('leather')) return 'leather';
  if (armorId.startsWith('chainmail')) return 'chainmail';
  if (armorId.startsWith('fullplate')) return 'fullplate';
  return 'leather';
}

/// Get the tier-appropriate armor for a given type and tier
ArmorDefinition armorForTypeAndTier(String type, int tier) {
  final id = '${type}_t$tier';
  return armorById(id) ?? allArmor.first;
}
