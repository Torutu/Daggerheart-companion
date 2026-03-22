/// Daggerheart SRD v1.0 — Domain Card Data
class DomainCard {
  final String id;
  final String domain;
  final int level;
  final String type; // 'ability' | 'spell' | 'grimoire'
  final String name;
  final int recallCost;
  final String description;
  const DomainCard({
    required this.id,
    required this.domain,
    required this.level,
    required this.type,
    required this.name,
    required this.recallCost,
    required this.description,
  });
}

const List<DomainCard> allDomainCards = [
  // ── ARCANA ────────────────────────────────────────────────────────────────
  DomainCard(
    id: 'arcana_rune_ward_1',
    domain: 'arcana',
    level: 1,
    type: 'spell',
    recallCost: 1,
    name: 'Rune Ward',
    description:
        'Create a magical ward on a surface or object. The next creature to cross or touch it triggers an alarm or takes d6 magic damage (choose when casting).',
  ),
  DomainCard(
    id: 'arcana_unleash_chaos_1',
    domain: 'arcana',
    level: 1,
    type: 'spell',
    recallCost: 1,
    name: 'Unleash Chaos',
    description:
        'Hurl a bolt of raw magical energy. Make a Spellcast Roll; on success, deal 2d6 magic damage to a target within Far range.',
  ),
  DomainCard(
    id: 'arcana_wall_walk_1',
    domain: 'arcana',
    level: 1,
    type: 'spell',
    recallCost: 1,
    name: 'Wall Walk',
    description:
        'You can walk on walls and ceilings as though they were floors until the end of the scene.',
  ),
  DomainCard(
    id: 'arcana_cinder_grasp_2',
    domain: 'arcana',
    level: 2,
    type: 'spell',
    recallCost: 1,
    name: 'Cinder Grasp',
    description:
        'Your hands ignite with flame. Melee attacks deal an extra d4 fire damage. Lasts until end of scene or until you choose to end it.',
  ),
  DomainCard(
    id: 'arcana_floating_eye_2',
    domain: 'arcana',
    level: 2,
    type: 'spell',
    recallCost: 0,
    name: 'Floating Eye',
    description:
        'Create an invisible magical sensor within Close range. You see and hear through it. Lasts 10 minutes.',
  ),
  DomainCard(
    id: 'arcana_counterspell_1',
    domain: 'arcana',
    level: 1,
    type: 'spell',
    recallCost: 2,
    name: 'Counterspell',
    description:
        'Reaction: when a creature within Far range casts a spell, make a Spellcast Roll against their roll. On success, negate the spell entirely.',
  ),
  DomainCard(
    id: 'arcana_flight_3',
    domain: 'arcana',
    level: 3,
    type: 'spell',
    recallCost: 2,
    name: 'Flight',
    description:
        'You gain a fly speed equal to your movement speed until the end of the scene.',
  ),
  DomainCard(
    id: 'arcana_blink_out_3',
    domain: 'arcana',
    level: 3,
    type: 'spell',
    recallCost: 2,
    name: 'Blink Out',
    description:
        'Teleport to any unoccupied space you can see within Very Far range.',
  ),
  DomainCard(
    id: 'arcana_chain_lightning_5',
    domain: 'arcana',
    level: 5,
    type: 'spell',
    recallCost: 3,
    name: 'Chain Lightning',
    description:
        'Strike a target within Far range for 3d8 lightning damage. The bolt then leaps to up to 2 additional targets within Close of the first.',
  ),
  DomainCard(
    id: 'arcana_telekinesis_7',
    domain: 'arcana',
    level: 7,
    type: 'spell',
    recallCost: 3,
    name: 'Telekinesis',
    description:
        'Move any object or creature within Far range using only your mind. Creatures may resist with a Strength roll against your Spellcast Roll.',
  ),
  DomainCard(
    id: 'arcana_earthquake_9',
    domain: 'arcana',
    level: 9,
    type: 'spell',
    recallCost: 4,
    name: 'Earthquake',
    description:
        'Shake the ground in a Very Far radius. All creatures must succeed on an Agility roll or fall prone and take 4d6 damage.',
  ),
  DomainCard(
    id: 'arcana_adjust_reality_10',
    domain: 'arcana',
    level: 10,
    type: 'spell',
    recallCost: 5,
    name: 'Adjust Reality',
    description:
        'Rewrite a moment of reality. Undo a single event that occurred in the last minute, or declare that one thing is true for the rest of the session.',
  ),

  // ── BLADE ─────────────────────────────────────────────────────────────────
  DomainCard(
    id: 'blade_get_back_up_1',
    domain: 'blade',
    level: 1,
    type: 'ability',
    recallCost: 1,
    name: 'Get Back Up',
    description:
        'Once per scene, when you would be Downed, succeed on a Strength roll (12) to remain standing at 1 HP instead.',
  ),
  DomainCard(
    id: 'blade_whirlwind_1',
    domain: 'blade',
    level: 1,
    type: 'ability',
    recallCost: 1,
    name: 'Whirlwind',
    description:
        'Attack all enemies within Melee range with a single spinning strike. Roll once and apply to all targets.',
  ),
  DomainCard(
    id: 'blade_reckless_1',
    domain: 'blade',
    level: 1,
    type: 'ability',
    recallCost: 0,
    name: 'Reckless',
    description:
        'Before attacking, declare Reckless. You have advantage on the attack roll but enemies have advantage against you until your next turn.',
  ),
  DomainCard(
    id: 'blade_versatile_fighter_3',
    domain: 'blade',
    level: 3,
    type: 'ability',
    recallCost: 2,
    name: 'Versatile Fighter',
    description:
        'You can wield two weapons simultaneously. When you attack, roll both damage dice and keep the higher result.',
  ),
  DomainCard(
    id: 'blade_rage_up_5',
    domain: 'blade',
    level: 5,
    type: 'ability',
    recallCost: 2,
    name: 'Rage Up',
    description:
        'Mark 2 Stress to enter a Rage. While Raging, add your Proficiency to all damage rolls. Rage ends when combat ends or you choose to end it.',
  ),
  DomainCard(
    id: 'blade_battle_cry_7',
    domain: 'blade',
    level: 7,
    type: 'ability',
    recallCost: 3,
    name: 'Battle Cry',
    description:
        'Once per scene, unleash a battle cry. All allies within Far range gain +2 to their next attack or damage roll.',
  ),
  DomainCard(
    id: 'blade_onslaught_10',
    domain: 'blade',
    level: 10,
    type: 'ability',
    recallCost: 4,
    name: 'Onslaught',
    description:
        'Make three separate melee attacks against any combination of targets within range. Each is a separate roll.',
  ),

  // ── BONE ──────────────────────────────────────────────────────────────────
  DomainCard(
    id: 'bone_deft_maneuvers_1',
    domain: 'bone',
    level: 1,
    type: 'ability',
    recallCost: 1,
    name: 'Deft Maneuvers',
    description:
        'Once per scene, move through an enemy\'s space without provoking a reaction and end in any unoccupied adjacent space.',
  ),
  DomainCard(
    id: 'bone_i_see_it_1',
    domain: 'bone',
    level: 1,
    type: 'ability',
    recallCost: 0,
    name: 'I See It Coming',
    description:
        'Reaction: when you are attacked, spend Hope to add your Instinct modifier to your Evasion against that attack.',
  ),
  DomainCard(
    id: 'bone_prey_sense_3',
    domain: 'bone',
    level: 3,
    type: 'ability',
    recallCost: 1,
    name: 'Prey Sense',
    description:
        'You always know the general direction of any creature you have seen in the last 24 hours, up to Very Far range.',
  ),
  DomainCard(
    id: 'bone_anatomist_5',
    domain: 'bone',
    level: 5,
    type: 'ability',
    recallCost: 2,
    name: 'Anatomist',
    description:
        'Once per scene, identify a weak point on an adversary. Your next attack against them ignores their armor and deals maximum damage on the damage dice.',
  ),
  DomainCard(
    id: 'bone_ghost_step_7',
    domain: 'bone',
    level: 7,
    type: 'ability',
    recallCost: 3,
    name: 'Ghost Step',
    description:
        'Until the end of your next turn, you leave no tracks, make no sound, and cannot be detected by non-magical senses.',
  ),
  DomainCard(
    id: 'bone_deadeye_10',
    domain: 'bone',
    level: 10,
    type: 'ability',
    recallCost: 4,
    name: 'Deadeye',
    description:
        'Once per scene, make a ranged attack that automatically succeeds with a critical hit. Choose one: deal double damage, ignore all armor, or Restrain the target.',
  ),

  // ── CODEX ─────────────────────────────────────────────────────────────────
  DomainCard(
    id: 'codex_book_ava_1',
    domain: 'codex',
    level: 1,
    type: 'grimoire',
    recallCost: 1,
    name: 'Book of Ava',
    description:
        'Contains three spells — Power Push: push a target within Close range up to Far distance. Tava\'s Armor: grant a creature +2 to their Minor/Major thresholds until their next rest. Ice Spike: deal d8 cold damage and Restrain a target within Far range on success.',
  ),
  DomainCard(
    id: 'codex_book_illiat_2',
    domain: 'codex',
    level: 2,
    type: 'grimoire',
    recallCost: 1,
    name: 'Book of Illiat',
    description:
        'Contains three spells — Slumber: target within Close range falls asleep (Spellcast Roll vs. their Instinct). Arcane Barrage: 3 missiles each dealing d4 magic damage, target any combination. Telepathy: communicate telepathically with any willing creature you can see for the rest of the scene.',
  ),
  DomainCard(
    id: 'codex_book_tyfar_3',
    domain: 'codex',
    level: 3,
    type: 'grimoire',
    recallCost: 2,
    name: 'Book of Tyfar',
    description:
        'Contains three spells — Wild Flame: cone of fire dealing 2d6 to all in Close. Magic Hand: invisible hand manipulates objects up to Far range. Mysterious Mist: fill Close area with fog, all within are Hidden.',
  ),
  DomainCard(
    id: 'codex_book_sitil_5',
    domain: 'codex',
    level: 5,
    type: 'grimoire',
    recallCost: 2,
    name: 'Book of Sitil',
    description:
        'Contains three spells — Adjust Appearance: change your physical appearance at will. Mass Suggestion: all creatures in Close range must succeed Presence roll or follow one reasonable suggestion. Time Bubble: slow time in a Close area; creatures within act last for one round.',
  ),
  DomainCard(
    id: 'codex_book_elder_8',
    domain: 'codex',
    level: 8,
    type: 'grimoire',
    recallCost: 3,
    name: 'Elder Codex',
    description:
        'Contains three powerful spells — Soul Trap: capture a dying creature\'s soul in a gem. Wish Fragment: describe a specific, limited wish; the GM determines the most literal outcome. Undo: reverse all effects of a single spell cast within the last minute.',
  ),

  // ── GRACE ─────────────────────────────────────────────────────────────────
  DomainCard(
    id: 'grace_charming_words_1',
    domain: 'grace',
    level: 1,
    type: 'spell',
    recallCost: 0,
    name: 'Charming Words',
    description:
        'Attempt to charm a creature within Close range. Make a Spellcast Roll; on success, they are Distracted and treat you as a friend until they take damage or the scene ends.',
  ),
  DomainCard(
    id: 'grace_distracting_flourish_1',
    domain: 'grace',
    level: 1,
    type: 'spell',
    recallCost: 1,
    name: 'Distracting Flourish',
    description:
        'Create a dazzling display. All enemies within Close range must succeed on a Presence roll or have disadvantage on their next action.',
  ),
  DomainCard(
    id: 'grace_silver_tongue_3',
    domain: 'grace',
    level: 3,
    type: 'ability',
    recallCost: 1,
    name: 'Silver Tongue',
    description:
        'Once per scene, convince any non-hostile NPC of one simple false statement without a roll. Hostile NPCs still require a Presence Roll.',
  ),
  DomainCard(
    id: 'grace_mesmerize_5',
    domain: 'grace',
    level: 5,
    type: 'spell',
    recallCost: 2,
    name: 'Mesmerize',
    description:
        'Lock eyes with a creature within Close range. They are Restrained and Vulnerable as long as you maintain concentration (costs 1 Stress per round after the first).',
  ),
  DomainCard(
    id: 'grace_puppet_master_8',
    domain: 'grace',
    level: 8,
    type: 'spell',
    recallCost: 3,
    name: 'Puppet Master',
    description:
        'Take full control of a creature within Close range. Make a Spellcast Roll vs their level+8. On success, control them for up to 1 minute; they act on your turn.',
  ),

  // ── MIDNIGHT ──────────────────────────────────────────────────────────────
  DomainCard(
    id: 'midnight_shadow_meld_1',
    domain: 'midnight',
    level: 1,
    type: 'ability',
    recallCost: 0,
    name: 'Shadow Meld',
    description:
        'While in dim light or darkness, you can become Hidden as a free action, without needing to move.',
  ),
  DomainCard(
    id: 'midnight_smoke_bomb_1',
    domain: 'midnight',
    level: 1,
    type: 'ability',
    recallCost: 1,
    name: 'Smoke Bomb',
    description:
        'Create a smoke cloud filling Close range. All within are Hidden from each other. Lasts until end of your next turn.',
  ),
  DomainCard(
    id: 'midnight_darkness_3',
    domain: 'midnight',
    level: 3,
    type: 'spell',
    recallCost: 1,
    name: 'Darkness',
    description:
        'Magical darkness fills a Close area, blocking all non-magical light. You can see through your own darkness. Lasts 10 minutes.',
  ),
  DomainCard(
    id: 'midnight_phase_step_5',
    domain: 'midnight',
    level: 5,
    type: 'spell',
    recallCost: 2,
    name: 'Phase Step',
    description:
        'Pass through solid objects as though they weren\'t there until the end of your next turn. You can\'t end your movement inside an object.',
  ),
  DomainCard(
    id: 'midnight_night_terror_8',
    domain: 'midnight',
    level: 8,
    type: 'spell',
    recallCost: 3,
    name: 'Night Terror',
    description:
        'Plunge a creature within Close range into their worst nightmare. They are Restrained, Vulnerable, and Distracted simultaneously for the scene or until they take Severe damage.',
  ),

  // ── SAGE ──────────────────────────────────────────────────────────────────
  DomainCard(
    id: 'sage_thorn_wall_1',
    domain: 'sage',
    level: 1,
    type: 'spell',
    recallCost: 1,
    name: 'Thorn Wall',
    description:
        'Raise a wall of thorns in any configuration within Close range. The wall is 10 feet high. Creatures passing through take d6 damage and are Restrained until freed.',
  ),
  DomainCard(
    id: 'sage_beast_call_1',
    domain: 'sage',
    level: 1,
    type: 'spell',
    recallCost: 0,
    name: 'Beast Call',
    description:
        'Call a small to medium wild animal to your location. The animal will help with one simple task before leaving.',
  ),
  DomainCard(
    id: 'sage_barkskin_3',
    domain: 'sage',
    level: 3,
    type: 'spell',
    recallCost: 1,
    name: 'Barkskin',
    description:
        'Your skin hardens like bark. Gain +3 to your Minor and Major thresholds until your next rest. You must not be wearing heavy armor.',
  ),
  DomainCard(
    id: 'sage_regrowth_5',
    domain: 'sage',
    level: 5,
    type: 'spell',
    recallCost: 2,
    name: 'Regrowth',
    description:
        'Touch a creature and restore 2d6 HP. If used on a plant or tree, instantly grow it to full size.',
  ),
  DomainCard(
    id: 'sage_natures_wrath_8',
    domain: 'sage',
    level: 8,
    type: 'spell',
    recallCost: 3,
    name: 'Nature\'s Wrath',
    description:
        'Call a storm of vines, lightning, and wind. All enemies in Very Far range take 3d10 damage; those in Close range are Restrained.',
  ),

  // ── SPLENDOR ──────────────────────────────────────────────────────────────
  DomainCard(
    id: 'splendor_healing_touch_1',
    domain: 'splendor',
    level: 1,
    type: 'spell',
    recallCost: 0,
    name: 'Healing Touch',
    description: 'Touch a creature and clear d4 HP from them.',
  ),
  DomainCard(
    id: 'splendor_radiant_burst_1',
    domain: 'splendor',
    level: 1,
    type: 'spell',
    recallCost: 1,
    name: 'Radiant Burst',
    description:
        'Emit a burst of holy light. All undead and fiends in Close range take 2d6 radiant damage. Allies in Close range clear 1 Stress.',
  ),
  DomainCard(
    id: 'splendor_revive_3',
    domain: 'splendor',
    level: 3,
    type: 'spell',
    recallCost: 2,
    name: 'Revive',
    description:
        'Touch a Downed creature and spend 3 Hope. They immediately return to consciousness with 1 HP.',
  ),
  DomainCard(
    id: 'splendor_mass_heal_5',
    domain: 'splendor',
    level: 5,
    type: 'spell',
    recallCost: 3,
    name: 'Mass Heal',
    description: 'All allies within Close range clear d6 HP each.',
  ),
  DomainCard(
    id: 'splendor_miracle_8',
    domain: 'splendor',
    level: 8,
    type: 'spell',
    recallCost: 4,
    name: 'Miracle',
    description:
        'Perform a divine miracle. Describe the effect to your GM; it can achieve anything within divine power — curing disease, raising the dead (for 1 day), or negating a catastrophe.',
  ),
  DomainCard(
    id: 'splendor_divine_judgment_10',
    domain: 'splendor',
    level: 10,
    type: 'spell',
    recallCost: 5,
    name: 'Divine Judgment',
    description:
        'Call down the judgment of your god on a creature within Very Far range. They take 6d12 radiant damage. If this Downs them, they are disintegrated.',
  ),

  // ── VALOR ─────────────────────────────────────────────────────────────────
  DomainCard(
    id: 'valor_shield_bash_1',
    domain: 'valor',
    level: 1,
    type: 'ability',
    recallCost: 0,
    name: 'Shield Bash',
    description:
        'When you successfully attack, you may push the target to any adjacent space and knock them prone (Restrained until they use an action to stand).',
  ),
  DomainCard(
    id: 'valor_stand_firm_1',
    domain: 'valor',
    level: 1,
    type: 'ability',
    recallCost: 1,
    name: 'Stand Firm',
    description:
        'Once per scene, reduce any single instance of damage by your level (minimum 1).',
  ),
  DomainCard(
    id: 'valor_guardian_angel_3',
    domain: 'valor',
    level: 3,
    type: 'ability',
    recallCost: 1,
    name: 'Guardian Angel',
    description:
        'Choose an ally within Close range. Until the start of your next turn, all attacks targeting them target you instead.',
  ),
  DomainCard(
    id: 'valor_divine_shield_5',
    domain: 'valor',
    level: 5,
    type: 'spell',
    recallCost: 2,
    name: 'Divine Shield',
    description:
        'Create a glowing shield around yourself or an ally within Close range. Until their next rest, mark Stress instead of HP when they would take Major or Severe damage (once per scene).',
  ),
  DomainCard(
    id: 'valor_fortress_8',
    domain: 'valor',
    level: 8,
    type: 'ability',
    recallCost: 3,
    name: 'Fortress',
    description:
        'Until the end of the scene, you and all allies within Close range add your Proficiency to all damage thresholds.',
  ),
  DomainCard(
    id: 'valor_avatar_10',
    domain: 'valor',
    level: 10,
    type: 'spell',
    recallCost: 5,
    name: 'Avatar of Valor',
    description:
        'Become a divine avatar. Until the end of the scene: all allies within Far range cannot be Downed, you have advantage on all rolls, and your attacks deal maximum damage.',
  ),
];

List<DomainCard> cardsForDomain(String domain) =>
    allDomainCards.where((c) => c.domain == domain).toList();

List<DomainCard> cardsForDomains(List<String> domains) =>
    allDomainCards.where((c) => domains.contains(c.domain)).toList();

List<DomainCard> cardsAtOrBelowLevel(List<String> domains, int level) =>
    allDomainCards
        .where((c) => domains.contains(c.domain) && c.level <= level)
        .toList();

DomainCard? cardById(String id) {
  try {
    return allDomainCards.firstWhere((c) => c.id == id);
  } catch (_) {
    return null;
  }
}
