import 'dart:convert';

/// Full character data model — serialized to/from JSON for SharedPreferences.
class CharacterModel {
  final String id;
  final String name;
  final String pronouns;
  final int level;

  // Heritage
  final String ancestryId;
  final bool isMixedAncestry;
  final String? ancestryId2;
  final String communityId;

  // Class
  final String classId;
  final String subclassId;
  final String subclassTier; // 'foundation' | 'specialization' | 'mastery'
  final String? multiclassId;
  final String? multiclassSubclassId;

  // Traits (modifiers)
  final int agility;
  final int strength;
  final int finesse;
  final int instinct;
  final int presence;
  final int knowledge;
  final List<String> markedTraits; // traits increased this tier

  // Vitals
  final int currentHp;
  final int maxHpSlots;
  final int currentStress;
  final int maxStressSlots;
  final int hope;
  final int evasion;

  // Armor
  final String armorType; // 'gambeson' | 'leather' | 'chainmail' | 'fullplate'
  final int armorBaseScore;
  final int armorMarkedSlots;

  // Damage thresholds
  final int minorThreshold;
  final int majorThreshold;
  final int severeThreshold;

  // Advancement
  final int proficiency;
  final List<ExperienceEntry> experiences;

  // Domain cards
  final List<String> loadoutCardIds; // max 5
  final List<String> vaultCardIds;

  // Gold
  final int goldHandfuls;
  final int goldBags;
  final int goldChests;

  // Misc
  final List<String> inventory;
  final List<String> activeConditions;
  final String notes;

  const CharacterModel({
    required this.id,
    required this.name,
    required this.pronouns,
    required this.level,
    required this.ancestryId,
    required this.isMixedAncestry,
    this.ancestryId2,
    required this.communityId,
    required this.classId,
    required this.subclassId,
    required this.subclassTier,
    this.multiclassId,
    this.multiclassSubclassId,
    required this.agility,
    required this.strength,
    required this.finesse,
    required this.instinct,
    required this.presence,
    required this.knowledge,
    required this.markedTraits,
    required this.currentHp,
    required this.maxHpSlots,
    required this.currentStress,
    required this.maxStressSlots,
    required this.hope,
    required this.evasion,
    required this.armorType,
    required this.armorBaseScore,
    required this.armorMarkedSlots,
    required this.minorThreshold,
    required this.majorThreshold,
    required this.severeThreshold,
    required this.proficiency,
    required this.experiences,
    required this.loadoutCardIds,
    required this.vaultCardIds,
    required this.goldHandfuls,
    required this.goldBags,
    required this.goldChests,
    required this.inventory,
    required this.activeConditions,
    required this.notes,
  });

  int get tier {
    if (level >= 8) return 4;
    if (level >= 5) return 3;
    if (level >= 2) return 2;
    return 1;
  }

  bool get isDown => currentHp >= maxHpSlots;

  int traitValue(String trait) {
    switch (trait.toLowerCase()) {
      case 'agility':   return agility;
      case 'strength':  return strength;
      case 'finesse':   return finesse;
      case 'instinct':  return instinct;
      case 'presence':  return presence;
      case 'knowledge': return knowledge;
      default: return 0;
    }
  }

  CharacterModel copyWith({
    String? id, String? name, String? pronouns, int? level,
    String? ancestryId, bool? isMixedAncestry, String? ancestryId2,
    String? communityId, String? classId, String? subclassId,
    String? subclassTier, String? multiclassId, String? multiclassSubclassId,
    int? agility, int? strength, int? finesse, int? instinct,
    int? presence, int? knowledge, List<String>? markedTraits,
    int? currentHp, int? maxHpSlots, int? currentStress, int? maxStressSlots,
    int? hope, int? evasion,
    String? armorType, int? armorBaseScore, int? armorMarkedSlots,
    int? minorThreshold, int? majorThreshold, int? severeThreshold,
    int? proficiency, List<ExperienceEntry>? experiences,
    List<String>? loadoutCardIds, List<String>? vaultCardIds,
    int? goldHandfuls, int? goldBags, int? goldChests,
    List<String>? inventory, List<String>? activeConditions, String? notes,
  }) {
    return CharacterModel(
      id: id ?? this.id,
      name: name ?? this.name,
      pronouns: pronouns ?? this.pronouns,
      level: level ?? this.level,
      ancestryId: ancestryId ?? this.ancestryId,
      isMixedAncestry: isMixedAncestry ?? this.isMixedAncestry,
      ancestryId2: ancestryId2 ?? this.ancestryId2,
      communityId: communityId ?? this.communityId,
      classId: classId ?? this.classId,
      subclassId: subclassId ?? this.subclassId,
      subclassTier: subclassTier ?? this.subclassTier,
      multiclassId: multiclassId ?? this.multiclassId,
      multiclassSubclassId: multiclassSubclassId ?? this.multiclassSubclassId,
      agility: agility ?? this.agility,
      strength: strength ?? this.strength,
      finesse: finesse ?? this.finesse,
      instinct: instinct ?? this.instinct,
      presence: presence ?? this.presence,
      knowledge: knowledge ?? this.knowledge,
      markedTraits: markedTraits ?? this.markedTraits,
      currentHp: currentHp ?? this.currentHp,
      maxHpSlots: maxHpSlots ?? this.maxHpSlots,
      currentStress: currentStress ?? this.currentStress,
      maxStressSlots: maxStressSlots ?? this.maxStressSlots,
      hope: hope ?? this.hope,
      evasion: evasion ?? this.evasion,
      armorType: armorType ?? this.armorType,
      armorBaseScore: armorBaseScore ?? this.armorBaseScore,
      armorMarkedSlots: armorMarkedSlots ?? this.armorMarkedSlots,
      minorThreshold: minorThreshold ?? this.minorThreshold,
      majorThreshold: majorThreshold ?? this.majorThreshold,
      severeThreshold: severeThreshold ?? this.severeThreshold,
      proficiency: proficiency ?? this.proficiency,
      experiences: experiences ?? this.experiences,
      loadoutCardIds: loadoutCardIds ?? this.loadoutCardIds,
      vaultCardIds: vaultCardIds ?? this.vaultCardIds,
      goldHandfuls: goldHandfuls ?? this.goldHandfuls,
      goldBags: goldBags ?? this.goldBags,
      goldChests: goldChests ?? this.goldChests,
      inventory: inventory ?? this.inventory,
      activeConditions: activeConditions ?? this.activeConditions,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'pronouns': pronouns, 'level': level,
    'ancestryId': ancestryId, 'isMixedAncestry': isMixedAncestry,
    'ancestryId2': ancestryId2, 'communityId': communityId,
    'classId': classId, 'subclassId': subclassId, 'subclassTier': subclassTier,
    'multiclassId': multiclassId, 'multiclassSubclassId': multiclassSubclassId,
    'agility': agility, 'strength': strength, 'finesse': finesse,
    'instinct': instinct, 'presence': presence, 'knowledge': knowledge,
    'markedTraits': markedTraits,
    'currentHp': currentHp, 'maxHpSlots': maxHpSlots,
    'currentStress': currentStress, 'maxStressSlots': maxStressSlots,
    'hope': hope, 'evasion': evasion,
    'armorType': armorType, 'armorBaseScore': armorBaseScore,
    'armorMarkedSlots': armorMarkedSlots,
    'minorThreshold': minorThreshold, 'majorThreshold': majorThreshold,
    'severeThreshold': severeThreshold,
    'proficiency': proficiency,
    'experiences': experiences.map((e) => e.toJson()).toList(),
    'loadoutCardIds': loadoutCardIds, 'vaultCardIds': vaultCardIds,
    'goldHandfuls': goldHandfuls, 'goldBags': goldBags, 'goldChests': goldChests,
    'inventory': inventory, 'activeConditions': activeConditions, 'notes': notes,
  };

  factory CharacterModel.fromJson(Map<String, dynamic> j) => CharacterModel(
    id: j['id'] as String,
    name: j['name'] as String,
    pronouns: j['pronouns'] as String? ?? '',
    level: j['level'] as int,
    ancestryId: j['ancestryId'] as String,
    isMixedAncestry: j['isMixedAncestry'] as bool? ?? false,
    ancestryId2: j['ancestryId2'] as String?,
    communityId: j['communityId'] as String,
    classId: j['classId'] as String,
    subclassId: j['subclassId'] as String,
    subclassTier: j['subclassTier'] as String? ?? 'foundation',
    multiclassId: j['multiclassId'] as String?,
    multiclassSubclassId: j['multiclassSubclassId'] as String?,
    agility: j['agility'] as int,
    strength: j['strength'] as int,
    finesse: j['finesse'] as int,
    instinct: j['instinct'] as int,
    presence: j['presence'] as int,
    knowledge: j['knowledge'] as int,
    markedTraits: List<String>.from(j['markedTraits'] ?? []),
    currentHp: j['currentHp'] as int,
    maxHpSlots: j['maxHpSlots'] as int,
    currentStress: j['currentStress'] as int,
    maxStressSlots: j['maxStressSlots'] as int,
    hope: j['hope'] as int,
    evasion: j['evasion'] as int,
    armorType: j['armorType'] as String? ?? 'leather',
    armorBaseScore: j['armorBaseScore'] as int? ?? 3,
    armorMarkedSlots: j['armorMarkedSlots'] as int? ?? 0,
    minorThreshold: j['minorThreshold'] as int,
    majorThreshold: j['majorThreshold'] as int,
    severeThreshold: j['severeThreshold'] as int,
    proficiency: j['proficiency'] as int? ?? 1,
    experiences: (j['experiences'] as List<dynamic>? ?? [])
        .map((e) => ExperienceEntry.fromJson(e as Map<String, dynamic>))
        .toList(),
    loadoutCardIds: List<String>.from(j['loadoutCardIds'] ?? []),
    vaultCardIds: List<String>.from(j['vaultCardIds'] ?? []),
    goldHandfuls: j['goldHandfuls'] as int? ?? 1,
    goldBags: j['goldBags'] as int? ?? 0,
    goldChests: j['goldChests'] as int? ?? 0,
    inventory: List<String>.from(j['inventory'] ?? []),
    activeConditions: List<String>.from(j['activeConditions'] ?? []),
    notes: j['notes'] as String? ?? '',
  );

  String toJsonString() => jsonEncode(toJson());
  factory CharacterModel.fromJsonString(String s) =>
      CharacterModel.fromJson(jsonDecode(s) as Map<String, dynamic>);
}

class ExperienceEntry {
  final String name;
  final int modifier;
  const ExperienceEntry({required this.name, required this.modifier});

  Map<String, dynamic> toJson() => {'name': name, 'modifier': modifier};
  factory ExperienceEntry.fromJson(Map<String, dynamic> j) =>
      ExperienceEntry(name: j['name'] as String, modifier: j['modifier'] as int);
}
