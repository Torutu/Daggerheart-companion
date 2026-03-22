/// Daggerheart SRD v1.0 — Ancestries (18 + Mixed)
class AncestryDefinition {
  final String id;
  final String name;
  final String featureTop;
  final String featureBottom;
  const AncestryDefinition({
    required this.id, required this.name,
    required this.featureTop, required this.featureBottom,
  });
}

const List<AncestryDefinition> allAncestries = [
  AncestryDefinition(id: 'clank', name: 'Clank',
    featureTop: 'Automaton Body: You don\'t need to breathe, eat, or sleep, and are immune to poison and disease.',
    featureBottom: 'Mechanical Precision: Once per long rest, treat one action roll result as a 10.'),
  AncestryDefinition(id: 'drakona', name: 'Drakona',
    featureTop: 'Draconic Breath: Once per short rest, exhale a cone or line of elemental energy (choose type at creation). Close range, d6+tier damage.',
    featureBottom: 'Scaled Hide: Your Severe damage threshold permanently increases by +2.'),
  AncestryDefinition(id: 'dwarf', name: 'Dwarf',
    featureTop: 'Stalwart: Once per long rest, when you would be Downed, you instead remain at 1 HP and clear all Stress.',
    featureBottom: 'Darkvision: You can see in darkness as though it were dim light.'),
  AncestryDefinition(id: 'elf', name: 'Elf',
    featureTop: 'Trance: Instead of sleeping, you enter a meditative trance for 4 hours, gaining the benefits of a full rest.',
    featureBottom: 'Fleet of Foot: Your movement is never impeded by difficult terrain.'),
  AncestryDefinition(id: 'faerie', name: 'Faerie',
    featureTop: 'Fae Wings: You can fly. You can\'t fly while wearing heavy or very heavy armor.',
    featureBottom: 'Glamour: Once per short rest, spend Hope to create a convincing illusion no larger than yourself (lasts 10 minutes or until touched).'),
  AncestryDefinition(id: 'faun', name: 'Faun',
    featureTop: 'Sure-Footed: You have advantage on rolls to avoid being knocked prone or moved against your will.',
    featureBottom: 'Nature\'s Touch: Once per long rest, speak a calming phrase to calm any non-hostile animal or beast.'),
  AncestryDefinition(id: 'firbolg', name: 'Firbolg',
    featureTop: 'Powerful Build: You count as one size larger for carrying capacity and grappling.',
    featureBottom: 'Speak with Beasts: You can communicate simple ideas with beasts and understand their responses.'),
  AncestryDefinition(id: 'fungril', name: 'Fungril',
    featureTop: 'Spore Cloud: Once per short rest, release a spore cloud in Close range. Targets must succeed on an Instinct roll (12) or become Distracted.',
    featureBottom: 'Decomposer: You can consume otherwise inedible organic matter for sustenance, and are immune to ingested poisons.'),
  AncestryDefinition(id: 'galapa', name: 'Galapa',
    featureTop: 'Shell Retreat: Once per short rest, retreat into your shell, gaining +4 to all damage thresholds until the start of your next turn.',
    featureBottom: 'Aquatic: You can breathe underwater and swim at full speed.'),
  AncestryDefinition(id: 'giant', name: 'Giant',
    featureTop: 'Titanic Strength: Your unarmed strikes deal d6 damage and you can throw objects and creatures as a weapon.',
    featureBottom: 'Imposing Presence: When you make an Intimidation attempt, add your level to the roll.'),
  AncestryDefinition(id: 'goblin', name: 'Goblin',
    featureTop: 'Nimble Escape: Once per short rest, after being hit, immediately move to anywhere within Close range without provoking reactions.',
    featureBottom: 'Darkvision: You can see in darkness as though it were dim light.'),
  AncestryDefinition(id: 'halfling', name: 'Halfling',
    featureTop: 'Lucky: Once per long rest, reroll any single die result and keep either result.',
    featureBottom: 'Brave: You have advantage on rolls to resist fear effects and the Frightened condition.'),
  AncestryDefinition(id: 'human', name: 'Human',
    featureTop: 'Adaptable: Gain one additional Experience at character creation.',
    featureBottom: 'Determined: Once per long rest, when you fail a roll, gain 2 Hope instead of the failure consequence.'),
  AncestryDefinition(id: 'infernis', name: 'Infernis',
    featureTop: 'Infernal Resistance: You have resistance to fire damage (reduce Fire damage severity by one step).',
    featureBottom: 'Darkvision: You can see in darkness as though it were dim light.'),
  AncestryDefinition(id: 'katari', name: 'Katari',
    featureTop: 'Cat\'s Grace: You always land on your feet and take no damage from falls of 30 feet or less.',
    featureBottom: 'Night Vision: You have advantage on Instinct rolls made in darkness.'),
  AncestryDefinition(id: 'orc', name: 'Orc',
    featureTop: 'Relentless Endurance: Once per long rest, when you would be Downed, you instead drop to 1 HP.',
    featureBottom: 'Savage Attacks: When you score a critical success on a melee attack, add an extra damage die to the roll.'),
  AncestryDefinition(id: 'ribbet', name: 'Ribbet',
    featureTop: 'Powerful Leap: You can jump twice as far as normal, and can jump vertically up to half your normal horizontal jump distance.',
    featureBottom: 'Amphibious: You can breathe both air and water and swim at full speed.'),
  AncestryDefinition(id: 'simiah', name: 'Simiah',
    featureTop: 'Prehensile Tail: Your tail functions as a third hand — you can hold objects, hang from surfaces, or use tools with it.',
    featureBottom: 'Tree Climber: You have a climb speed equal to your movement speed and never need to make rolls to climb.'),
];

AncestryDefinition? ancestryById(String id) {
  try {
    return allAncestries.firstWhere((a) => a.id == id);
  } catch (_) {
    return null;
  }
}
