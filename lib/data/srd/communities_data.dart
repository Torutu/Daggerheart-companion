/// Daggerheart SRD v1.0 — Communities (9)
class CommunityDefinition {
  final String id;
  final String name;
  final String flavour;
  final String feature;
  const CommunityDefinition({
    required this.id, required this.name,
    required this.flavour, required this.feature,
  });
}

const List<CommunityDefinition> allCommunities = [
  CommunityDefinition(
    id: 'highborne', name: 'Highborne',
    flavour: 'Raised in wealth and privilege among the ruling class.',
    feature: 'Aristocratic Bearing: When interacting with nobility or high society, you have advantage on Presence rolls. Once per long rest, call in a favor from a noble contact.',
  ),
  CommunityDefinition(
    id: 'loreborne', name: 'Loreborne',
    flavour: 'Raised in libraries, academies, and centers of learning.',
    feature: 'Scholarly Mind: Once per long rest, recall an obscure piece of information relevant to the current situation. Add your level to Knowledge rolls when researching or recalling history.',
  ),
  CommunityDefinition(
    id: 'orderborne', name: 'Orderborne',
    flavour: 'Raised within a military order, guild, or organized institution.',
    feature: 'Rank and File: You understand chain of command and military structure. Once per session, invoke your Order\'s authority to gain a boon from any affiliated member.',
  ),
  CommunityDefinition(
    id: 'ridgeborne', name: 'Ridgeborne',
    flavour: 'Raised in mountains, highlands, and rugged terrain.',
    feature: 'Mountain Born: You ignore difficult terrain in mountainous or rocky environments. You have advantage on rolls to resist cold and altitude-related effects.',
  ),
  CommunityDefinition(
    id: 'seaborne', name: 'Seaborne',
    flavour: 'Raised on ships, coastal towns, and maritime culture.',
    feature: 'Salt-Seasoned: You have advantage on Agility rolls while on boats or ships. Once per session, read weather patterns to predict incoming storms or safe sailing windows.',
  ),
  CommunityDefinition(
    id: 'slyborne', name: 'Slyborne',
    flavour: 'Raised in criminal networks, black markets, and the shadows.',
    feature: 'Street Smarts: You always know the local criminal hierarchy in any city. Once per long rest, locate a black market or fence for stolen goods without a roll.',
  ),
  CommunityDefinition(
    id: 'underborne', name: 'Underborne',
    flavour: 'Raised in underground societies, cave networks, or subterranean cities.',
    feature: 'Subterranean Savvy: You have darkvision out to Far range. You have advantage on Instinct rolls in tunnels, caves, or underground environments.',
  ),
  CommunityDefinition(
    id: 'wanderborne', name: 'Wanderborne',
    flavour: 'Raised traveling constantly — roads, caravans, and open skies.',
    feature: 'Wayfarer\'s Instinct: You can always find your way back to any location you\'ve visited before. You have advantage on Instinct rolls to navigate or avoid getting lost.',
  ),
  CommunityDefinition(
    id: 'wildborne', name: 'Wildborne',
    flavour: 'Raised in deep wilderness, away from civilization.',
    feature: 'Nature\'s Ally: Wild animals are never hostile toward you unless attacked. Once per long rest, find food, water, and shelter for the party without a roll in a natural environment.',
  ),
];

CommunityDefinition? communityById(String id) {
  try {
    return allCommunities.firstWhere((c) => c.id == id);
  } catch (_) {
    return null;
  }
}
