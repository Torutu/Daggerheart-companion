/// Daggerheart SRD v1.0 — Class Definitions
/// Starting stats sourced from official class character sheets.
class ClassDefinition {
  final String id;
  final String name;
  final String description;
  final int startingHp;
  final int startingEvasion;
  final int startingArmorSlots;
  final List<String> domains;
  final String? spellcastTrait;
  final String hopeFeatureName;
  final String hopeFeatureDescription;
  final String classFeatureName;
  final String classFeatureDescription;

  const ClassDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.startingHp,
    required this.startingEvasion,
    required this.startingArmorSlots,
    required this.domains,
    this.spellcastTrait,
    required this.hopeFeatureName,
    required this.hopeFeatureDescription,
    required this.classFeatureName,
    required this.classFeatureDescription,
  });
}

const List<ClassDefinition> allClasses = [
  ClassDefinition(
    id: 'bard',
    name: 'Bard',
    description: 'A performer and wordsmith who rallies allies and bends social situations with charm and melody.',
    startingHp: 6,
    startingEvasion: 11,
    startingArmorSlots: 3,
    domains: ['grace', 'codex'],
    spellcastTrait: 'presence',
    hopeFeatureName: 'Make a Scene',
    hopeFeatureDescription: 'Spend 2 Hope to Distract a target within Close range, giving them a penalty to their Difficulty.',
    classFeatureName: 'Rally',
    classFeatureDescription: 'Once per session, describe rallying the party; give yourself and each ally a Rally Die (d6 at level 1, d8 at level 4). A PC can spend it to add the result to an action, reaction, or damage roll, or clear Stress equal to the result.',
  ),
  ClassDefinition(
    id: 'druid',
    name: 'Druid',
    description: 'A shapeshifter and nature mage who transforms into beasts and channels elemental forces.',
    startingHp: 6,
    startingEvasion: 10,
    startingArmorSlots: 3,
    domains: ['arcana', 'sage'],
    spellcastTrait: 'instinct',
    hopeFeatureName: 'Evolution',
    hopeFeatureDescription: 'Spend 3 Hope to transform into a Beastform without marking Stress; choose one trait to raise by +2 until you drop out.',
    classFeatureName: 'Beastform',
    classFeatureDescription: 'Mark a Stress to transform into a creature of your tier or lower. You can\'t use weapons or cast spells while transformed. Drop out automatically when your last HP is marked.',
  ),
  ClassDefinition(
    id: 'guardian',
    name: 'Guardian',
    description: 'An unstoppable front-line warrior who absorbs damage and grows deadlier with each blow.',
    startingHp: 8,
    startingEvasion: 9,
    startingArmorSlots: 5,
    domains: ['valor', 'blade'],
    spellcastTrait: null,
    hopeFeatureName: 'Frontline Tank',
    hopeFeatureDescription: 'Spend 3 Hope to clear 2 Armor Slots.',
    classFeatureName: 'Unstoppable',
    classFeatureDescription: 'Once per long rest, become Unstoppable with an Unstoppable Die (d6 at level 1). Its value starts at 1 and increases when you deal 4+ HP damage. While Unstoppable: reduce physical damage severity by one threshold, add die value to damage, can\'t be Restrained or Vulnerable.',
  ),
  ClassDefinition(
    id: 'ranger',
    name: 'Ranger',
    description: 'A hunter and tracker who focuses prey with deadly precision — alone or with an animal companion.',
    startingHp: 6,
    startingEvasion: 11,
    startingArmorSlots: 4,
    domains: ['bone', 'sage'],
    spellcastTrait: 'agility',
    hopeFeatureName: 'Hold Them Off',
    hopeFeatureDescription: 'Spend 2 Hope on a successful attack to apply that same roll against two additional adversaries within range.',
    classFeatureName: 'Ranger\'s Focus',
    classFeatureDescription: 'Spend a Hope and make an attack. On success, temporarily make the target your Focus. Against your Focus: you know their direction, they mark Stress when you damage them, and you can end Focus to reroll Duality Dice on a failed attack.',
  ),
  ClassDefinition(
    id: 'rogue',
    name: 'Rogue',
    description: 'A shadow-dancer and opportunist who strikes from concealment and builds connections in the underworld.',
    startingHp: 5,
    startingEvasion: 12,
    startingArmorSlots: 3,
    domains: ['midnight', 'grace'],
    spellcastTrait: 'finesse',
    hopeFeatureName: 'Rogue\'s Dodge',
    hopeFeatureDescription: 'Spend 3 Hope to gain +3 Evasion until your next attack succeeds or until next rest.',
    classFeatureName: 'Sneak Attack',
    classFeatureDescription: 'On a successful attack while Cloaked or with an ally within Melee of the target, add a number of d6s equal to your tier to the damage roll.',
  ),
  ClassDefinition(
    id: 'seraph',
    name: 'Seraph',
    description: 'A divine warrior who wields sacred weapons, heals allies, and channels the power of their god through Prayer Dice.',
    startingHp: 7,
    startingEvasion: 10,
    startingArmorSlots: 4,
    domains: ['splendor', 'valor'],
    spellcastTrait: 'strength',
    hopeFeatureName: 'Life Support',
    hopeFeatureDescription: 'Spend 3 Hope to clear 1 HP on an ally within Close range.',
    classFeatureName: 'Prayer Dice',
    classFeatureDescription: 'At session start, roll a number of d6s equal to your Spellcast trait. Spend any Prayer Die to reduce incoming damage, add to a roll after rolling, or gain Hope equal to the result.',
  ),
  ClassDefinition(
    id: 'sorcerer',
    name: 'Sorcerer',
    description: 'A raw-magic wielder who senses the arcane, creates illusions, and channels power directly from their inner source.',
    startingHp: 5,
    startingEvasion: 11,
    startingArmorSlots: 3,
    domains: ['arcana', 'midnight'],
    spellcastTrait: 'instinct',
    hopeFeatureName: 'Volatile Magic',
    hopeFeatureDescription: 'Spend 3 Hope to reroll any number of damage dice on a magic damage attack.',
    classFeatureName: 'Channel Raw Power',
    classFeatureDescription: 'Once per long rest, vault a domain card and either gain Hope equal to the card\'s level OR gain a bonus to a damage roll equal to twice the card\'s level.',
  ),
  ClassDefinition(
    id: 'warrior',
    name: 'Warrior',
    description: 'A seasoned combatant who turns courage and slayer dice into raw destructive output.',
    startingHp: 8,
    startingEvasion: 10,
    startingArmorSlots: 4,
    domains: ['blade', 'bone'],
    spellcastTrait: null,
    hopeFeatureName: 'No Mercy',
    hopeFeatureDescription: 'Spend 3 Hope to gain +2 to attack rolls until next rest.',
    classFeatureName: 'Combat Training',
    classFeatureDescription: 'Ignore burden when equipping weapons. When dealing physical damage, gain a bonus to damage equal to your level.',
  ),
  ClassDefinition(
    id: 'wizard',
    name: 'Wizard',
    description: 'A scholar of the arcane who carries extra domain cards, masters Experiences, and finds strange patterns in every roll.',
    startingHp: 5,
    startingEvasion: 10,
    startingArmorSlots: 3,
    domains: ['codex', 'splendor'],
    spellcastTrait: 'knowledge',
    hopeFeatureName: 'Not This Time',
    hopeFeatureDescription: 'Spend 3 Hope to force an adversary within Far range to reroll an attack or damage roll.',
    classFeatureName: 'Strange Patterns',
    classFeatureDescription: 'Choose a number 1–10. When you roll that number on a Duality Die, gain Hope or clear Stress. Change the number on a long rest.',
  ),
];

ClassDefinition? classById(String id) {
  try {
    return allClasses.firstWhere((c) => c.id == id);
  } catch (_) {
    return null;
  }
}
