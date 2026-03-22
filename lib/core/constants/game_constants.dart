/// Daggerheart SRD v1.0 — Game Constants
class GameConstants {
  GameConstants._();

  // ── Hope ──────────────────────────────────────────────────────────────────
  static const int maxHope = 6;
  static const int startingHope = 3;

  // ── Stress ────────────────────────────────────────────────────────────────
  static const int baseStressSlots = 6;

  // ── Domain Cards ──────────────────────────────────────────────────────────
  static const int maxLoadoutCards = 5;

  // ── Gold ──────────────────────────────────────────────────────────────────
  static const int handfulPerBag = 11;
  static const int bagPerChest = 11;
  static const int maxChests = 1;

  // ── Leveling ──────────────────────────────────────────────────────────────
  static const int minLevel = 1;
  static const int maxLevel = 10;
  static const int advancementsPerLevel = 2;

  /// Tier boundaries
  static int tierForLevel(int level) {
    if (level >= 8) return 4;
    if (level >= 5) return 3;
    if (level >= 2) return 2;
    return 1;
  }

  /// Levels where the PC gets a new Experience + Proficiency increase
  static const List<int> tierBoundaryLevels = [2, 5, 8];

  /// Multiclass domain card level cap: ceil(level / 2)
  static int multiclassDomainCap(int level) => (level / 2).ceil();

  // ── Proficiency ───────────────────────────────────────────────────────────
  static const int startingProficiency = 1;

  // ── Traits ────────────────────────────────────────────────────────────────
  /// Starting trait modifiers to assign (in any order)
  static const List<int> startingTraitValues = [2, 1, 1, 0, 0, -1];
  static const List<String> traitNames = [
    'agility',
    'strength',
    'finesse',
    'instinct',
    'presence',
    'knowledge',
  ];
  static const Map<String, String> traitLabels = {
    'agility': 'Agility',
    'strength': 'Strength',
    'finesse': 'Finesse',
    'instinct': 'Instinct',
    'presence': 'Presence',
    'knowledge': 'Knowledge',
  };
  static const Map<String, String> traitVerbs = {
    'agility': 'Sprint, Leap, Maneuver',
    'strength': 'Lift, Smash, Grapple',
    'finesse': 'Control, Hide, Tinker',
    'instinct': 'Perceive, Sense, Navigate',
    'presence': 'Charm, Perform, Deceive',
    'knowledge': 'Recall, Analyze, Comprehend',
  };

  // ── Conditions ────────────────────────────────────────────────────────────
  static const List<String> standardConditions = [
    'Hidden',
    'Restrained',
    'Vulnerable',
    'Poisoned',
    'On Fire',
    'Asleep',
    'Distracted',
  ];
}
