/// Daggerheart SRD v1.0 — Subclass Definitions
class SubclassCard {
  final String tier; // 'foundation' | 'specialization' | 'mastery'
  final String name;
  final String description;
  const SubclassCard({required this.tier, required this.name, required this.description});
}

class SubclassDefinition {
  final String id;
  final String classId;
  final String name;
  final String flavour;
  final SubclassCard foundation;
  final SubclassCard specialization;
  final SubclassCard mastery;
  const SubclassDefinition({
    required this.id, required this.classId, required this.name,
    required this.flavour, required this.foundation,
    required this.specialization, required this.mastery,
  });
}

const List<SubclassDefinition> allSubclasses = [
  // ── BARD ──────────────────────────────────────────────────────────────────
  SubclassDefinition(
    id: 'troubadour', classId: 'bard', name: 'Troubadour',
    flavour: 'Music-focused support — three songs that heal, empower, and inspire.',
    foundation: SubclassCard(tier: 'foundation', name: 'Gifted Performer',
      description: 'Three songs, once each per long rest: Relaxing Song (clear 1 HP for self and allies in Close), Epic Song (make one target in Close temporarily Vulnerable), Heartbreaking Song (self and allies in Close gain 1 Hope).'),
    specialization: SubclassCard(tier: 'specialization', name: 'Maestro',
      description: 'When giving an ally a Rally Die, they can also gain a Hope or clear a Stress.'),
    mastery: SubclassCard(tier: 'mastery', name: 'Virtuoso',
      description: 'Use each Gifted Performer song twice per long rest.'),
  ),
  SubclassDefinition(
    id: 'wordsmith', classId: 'bard', name: 'Wordsmith',
    flavour: 'Speech and social power — rouse allies and bend conversations.',
    foundation: SubclassCard(tier: 'foundation', name: 'Rousing Speech',
      description: 'Once per long rest, all allies in Far range clear 2 Stress. Heart of a Poet: spend Hope to add d6 to social rolls.'),
    specialization: SubclassCard(tier: 'specialization', name: 'Eloquent',
      description: 'Once per session, encouraging an ally lets them find a mundane object, Help an Ally without spending Hope, or gain an extra downtime move.'),
    mastery: SubclassCard(tier: 'mastery', name: 'Epic Poetry',
      description: 'Rally Die increases to d10; when helping an ally roll a d10 as the advantage die.'),
  ),
  // ── DRUID ─────────────────────────────────────────────────────────────────
  SubclassDefinition(
    id: 'warden_elements', classId: 'druid', name: 'Warden of the Elements',
    flavour: 'Channel elemental forces — fire, earth, water, or air.',
    foundation: SubclassCard(tier: 'foundation', name: 'Elemental Incarnation',
      description: 'Mark Stress to Channel one element (Fire, Earth, Water, or Air) with ongoing effects until Severe damage or next rest.'),
    specialization: SubclassCard(tier: 'specialization', name: 'Elemental Aura',
      description: 'Once per rest while Channeling, assume an aura affecting targets in Close range.'),
    mastery: SubclassCard(tier: 'mastery', name: 'Elemental Dominion',
      description: 'Additional passive benefit while Channeling, unique to each element.'),
  ),
  SubclassDefinition(
    id: 'warden_renewal', classId: 'druid', name: 'Warden of Renewal',
    flavour: 'Healing and protection through the power of nature.',
    foundation: SubclassCard(tier: 'foundation', name: 'Clarity of Nature',
      description: 'Once per long rest, create a natural space to clear Stress. Regeneration: touch a creature and spend 2 Hope to clear d3 HP.'),
    specialization: SubclassCard(tier: 'specialization', name: 'Regenerative Reach',
      description: 'Extend Regeneration to Very Close range. Warden\'s Protection: once per long rest, spend 2 Hope to clear 1 HP on d4 allies in Close.'),
    mastery: SubclassCard(tier: 'mastery', name: 'Defender',
      description: 'While in Beastform, mark Stress to reduce HP marked by nearby allies.'),
  ),
  // ── GUARDIAN ──────────────────────────────────────────────────────────────
  SubclassDefinition(
    id: 'stalwart', classId: 'guardian', name: 'Stalwart',
    flavour: 'The ultimate tank — absorb damage and protect your party.',
    foundation: SubclassCard(tier: 'foundation', name: 'Unwavering',
      description: '+2 to all damage thresholds. Iron Will: mark an extra Armor Slot to reduce physical damage severity by one step.'),
    specialization: SubclassCard(tier: 'specialization', name: 'Unrelenting',
      description: '+2 to all damage thresholds. Partners-in-Arms: mark an Armor Slot to reduce damage severity for nearby allies.'),
    mastery: SubclassCard(tier: 'mastery', name: 'Undaunted',
      description: '+2 to all damage thresholds. Loyal Protector: sprint to an ally with ≤1 HP remaining and take their damage instead.'),
  ),
  SubclassDefinition(
    id: 'vengeance', classId: 'guardian', name: 'Vengeance',
    flavour: 'Punish enemies who dare to strike you or your allies.',
    foundation: SubclassCard(tier: 'foundation', name: 'At Ease',
      description: 'Gain one extra Stress slot. Revenge: mark 2 Stress to force an attacker within Melee to mark 1 HP.'),
    specialization: SubclassCard(tier: 'specialization', name: 'Act of Reprisal',
      description: '+2 Proficiency bonus against the adversary who just damaged an ally in Melee range.'),
    mastery: SubclassCard(tier: 'mastery', name: 'Nemesis',
      description: 'Spend 3 Hope to Prioritize an adversary; you can swap Hope/Fear dice on attacks against them.'),
  ),
  // ── RANGER ────────────────────────────────────────────────────────────────
  SubclassDefinition(
    id: 'beastbound', classId: 'ranger', name: 'Beastbound',
    flavour: 'Bond with an animal companion who fights alongside you.',
    foundation: SubclassCard(tier: 'foundation', name: 'Companion',
      description: 'You have an animal companion with its own sheet, Evasion 6, two Experiences at +2, d4 Melee damage, and Stress. Command with a Spellcast Roll. Companion levels up with you.'),
    specialization: SubclassCard(tier: 'specialization', name: 'Expert Training',
      description: 'Extra companion level-up option. Battle-Bonded: +2 Evasion vs attacks while your companion is nearby.'),
    mastery: SubclassCard(tier: 'mastery', name: 'Advanced Training',
      description: 'Two extra level-up options. Loyal Friend: once per long rest, rush to intercept lethal damage for each other.'),
  ),
  SubclassDefinition(
    id: 'wayfinder', classId: 'ranger', name: 'Wayfinder',
    flavour: 'A deadly hunter who tracks prey across any terrain.',
    foundation: SubclassCard(tier: 'foundation', name: 'Ruthless Predator',
      description: 'Mark Stress for +2 Proficiency; Severe damage forces target to mark Stress. Path Forward: you know the shortest path to any previously visited place.'),
    specialization: SubclassCard(tier: 'specialization', name: 'Elusive Predator',
      description: '+2 Evasion against attacks from your current Focus.'),
    mastery: SubclassCard(tier: 'mastery', name: 'Apex Predator',
      description: 'Spend Hope before attacking your Focus; on success, remove a Fear from the GM\'s pool.'),
  ),
  // ── ROGUE ─────────────────────────────────────────────────────────────────
  SubclassDefinition(
    id: 'nightwalker', classId: 'rogue', name: 'Nightwalker',
    flavour: 'A shadow-dancer who teleports between darkness and strikes unseen.',
    foundation: SubclassCard(tier: 'foundation', name: 'Shadow Stepper',
      description: 'Move into darkness/shadow and mark Stress to teleport to another shadow within Far range and become Cloaked.'),
    specialization: SubclassCard(tier: 'specialization', name: 'Dark Cloud',
      description: 'Spellcast Roll to create a concealing dark cloud within Close range. Adrenaline: while Vulnerable, add your level to damage rolls.'),
    mastery: SubclassCard(tier: 'mastery', name: 'Fleeting Shadow',
      description: '+2 permanent Evasion; Shadow Stepper extends to Very Far range. Vanishing Act: mark Stress to become Cloaked at any time.'),
  ),
  SubclassDefinition(
    id: 'syndicate', classId: 'rogue', name: 'Syndicate',
    flavour: 'A well-connected criminal whose contacts solve problems.',
    foundation: SubclassCard(tier: 'foundation', name: 'Well-Connected',
      description: 'When arriving in a prominent location, you know someone there; choose one complicating fact about the contact.'),
    specialization: SubclassCard(tier: 'specialization', name: 'Contacts Everywhere',
      description: 'Once per session, call on a shady contact for gold/tool, a bonus to a die result, or sniper damage addition.'),
    mastery: SubclassCard(tier: 'mastery', name: 'Reliable Backup',
      description: 'Use Contacts Everywhere 3× per session; add two more benefits to the list.'),
  ),
  // ── SERAPH ────────────────────────────────────────────────────────────────
  SubclassDefinition(
    id: 'divine_wielder', classId: 'seraph', name: 'Divine Wielder',
    flavour: 'A sacred weapon that flies at your command.',
    foundation: SubclassCard(tier: 'foundation', name: 'Spirit Weapon',
      description: 'Your Melee/Very Close weapon can fly to attack targets within Close range; mark Stress to hit a second target. Sparing Touch: once per long rest, touch a creature to clear 2 HP or 2 Stress.'),
    specialization: SubclassCard(tier: 'specialization', name: 'Devout',
      description: 'Roll an extra Prayer Die and discard the lowest. Sparing Touch is usable twice per long rest.'),
    mastery: SubclassCard(tier: 'mastery', name: 'Sacred Resonance',
      description: 'When rolling damage for Spirit Weapon, matching die results are doubled.'),
  ),
  SubclassDefinition(
    id: 'winged_sentinel', classId: 'seraph', name: 'Winged Sentinel',
    flavour: 'Take to the skies and rain divine judgment from above.',
    foundation: SubclassCard(tier: 'foundation', name: 'Wings of Light',
      description: 'You can fly. While flying: mark Stress to carry a creature; spend Hope to deal extra d6 damage on successful attacks.'),
    specialization: SubclassCard(tier: 'specialization', name: 'Ethereal Visage',
      description: 'While flying, advantage on Presence Rolls; spend a Hope success to remove a Fear from the GM\'s pool.'),
    mastery: SubclassCard(tier: 'mastery', name: 'Ascendant',
      description: '+3 permanent Severe threshold. Power of the Gods: extra damage increases from d6 to d8 while flying.'),
  ),
  // ── SORCERER ──────────────────────────────────────────────────────────────
  SubclassDefinition(
    id: 'elemental_origin', classId: 'sorcerer', name: 'Elemental Origin',
    flavour: 'Your magic flows from a specific element — shape it to your will.',
    foundation: SubclassCard(tier: 'foundation', name: 'Elementalist',
      description: 'Choose one element (air, earth, fire, lightning, water) at creation. Shape it into harmless effects. Spend Hope to describe how it helps for +2 to a roll or +2 to damage.'),
    specialization: SubclassCard(tier: 'specialization', name: 'Natural Evasion',
      description: 'When hit, mark Stress and roll d6, adding the result to your Evasion against that attack.'),
    mastery: SubclassCard(tier: 'mastery', name: 'Transcendence',
      description: 'Once per long rest, transform into your element. Choose two benefits from: +5 Severe threshold, +2 to a trait, +2 Proficiency, +2 Evasion — until next rest.'),
  ),
  SubclassDefinition(
    id: 'primal_origin', classId: 'sorcerer', name: 'Primal Origin',
    flavour: 'Amplify every spell with raw, primal enhancement.',
    foundation: SubclassCard(tier: 'foundation', name: 'Manipulate Magic',
      description: 'After casting a spell or making a magic attack, mark Stress to: extend reach by one range, add +2 to the roll, double a damage die, or hit an additional target.'),
    specialization: SubclassCard(tier: 'specialization', name: 'Enchanted Aid',
      description: 'When helping an ally with a Spellcast Roll, roll d8 as advantage die; once per long rest swap their Duality Dice results after the roll.'),
    mastery: SubclassCard(tier: 'mastery', name: 'Arcane Charge',
      description: 'Become Charged when taking magic damage or spending 3 Hope. While Charged on a magic damage success, clear Charge for +3 damage or +3 to a reaction roll Difficulty.'),
  ),
  // ── WARRIOR ───────────────────────────────────────────────────────────────
  SubclassDefinition(
    id: 'call_brave', classId: 'warrior', name: 'Call of the Brave',
    flavour: 'Turn courage and camaraderie into power in the heat of battle.',
    foundation: SubclassCard(tier: 'foundation', name: 'Courage',
      description: 'Gain Hope when failing with Fear. Battle Ritual: once per long rest, describe a pre-danger ritual to clear 2 Stress and gain 2 Hope.'),
    specialization: SubclassCard(tier: 'specialization', name: 'Rise to the Challenge',
      description: 'Roll d12 as the Hope Die when you have ≤2 HP unmarked.'),
    mastery: SubclassCard(tier: 'mastery', name: 'Camaraderie',
      description: 'One additional Tag Team Roll per session; allies only need 1 Hope to initiate a Tag Team Roll with you.'),
  ),
  SubclassDefinition(
    id: 'call_slayer', classId: 'warrior', name: 'Call of the Slayer',
    flavour: 'Store power in Slayer Dice and unleash devastating strikes.',
    foundation: SubclassCard(tier: 'foundation', name: 'Slayer',
      description: 'When rolling with Hope, optionally place a d6 on this card instead of gaining Hope (pool up to Proficiency dice). Spend Slayer Dice on attack or damage rolls. Clear unspent dice at session end for 1 Hope each.'),
    specialization: SubclassCard(tier: 'specialization', name: 'Weapon Specialist',
      description: 'Spend Hope to add secondary weapon damage die; once per long rest reroll 1s on Slayer Dice.'),
    mastery: SubclassCard(tier: 'mastery', name: 'Martial Preparation',
      description: 'Party gains a new downtime move: you instruct/train; everyone who takes it gains a d6 Slayer Die.'),
  ),
  // ── WIZARD ────────────────────────────────────────────────────────────────
  SubclassDefinition(
    id: 'school_knowledge', classId: 'wizard', name: 'School of Knowledge',
    flavour: 'Carry more cards and squeeze every advantage from your Experiences.',
    foundation: SubclassCard(tier: 'foundation', name: 'Prepared',
      description: 'Take an extra domain card of your level or lower. Adept: mark Stress instead of spending Hope to Utilize an Experience, doubling the modifier.'),
    specialization: SubclassCard(tier: 'specialization', name: 'Accomplished',
      description: 'Take another extra domain card. Perfect Recall: once per rest, reduce a Recall Cost by 2.'),
    mastery: SubclassCard(tier: 'mastery', name: 'Brilliant',
      description: 'Take yet another extra domain card. Honed Expertise: roll d8 when using an Experience; on 5+, use it without spending Hope.'),
  ),
  SubclassDefinition(
    id: 'school_war', classId: 'wizard', name: 'School of War',
    flavour: 'Cast magic in the thick of battle and thrive in chaos.',
    foundation: SubclassCard(tier: 'foundation', name: 'Battlemage',
      description: 'Gain an extra Hit Point slot. Face Your Fear: on an attack success with Fear, deal extra d4 magic damage.'),
    specialization: SubclassCard(tier: 'specialization', name: 'Conjure Shield',
      description: 'While you have ≥1 Hope, add Proficiency to your Evasion. Fueled by Fear: Face Your Fear increases to d8.'),
    mastery: SubclassCard(tier: 'mastery', name: 'Thrive in Chaos',
      description: 'On attack success, mark Stress after damage to force target to mark extra HP. Have No Fear: Face Your Fear increases to d12.'),
  ),
];

List<SubclassDefinition> subclassesForClass(String classId) =>
    allSubclasses.where((s) => s.classId == classId).toList();

SubclassDefinition? subclassById(String id) {
  try {
    return allSubclasses.firstWhere((s) => s.id == id);
  } catch (_) {
    return null;
  }
}
