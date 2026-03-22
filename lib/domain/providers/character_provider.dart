import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/game_constants.dart';
import '../../data/models/character_model.dart';
import '../../data/repositories/character_repository.dart';

final characterRepositoryProvider = Provider<CharacterRepository>((ref) {
  return CharacterRepository();
});

/// Async list of all characters
final characterListProvider =
    AsyncNotifierProvider<CharacterListNotifier, List<CharacterModel>>(
  CharacterListNotifier.new,
);

class CharacterListNotifier extends AsyncNotifier<List<CharacterModel>> {
  CharacterRepository get _repo => ref.read(characterRepositoryProvider);

  @override
  Future<List<CharacterModel>> build() => _repo.loadAll();

  Future<void> create(CharacterModel character) async {
    await _repo.create(character);
    state = AsyncValue.data(await _repo.loadAll());
  }

  Future<void> updateCharacter(CharacterModel character) async {
    await _repo.update(character);
    state = AsyncValue.data(await _repo.loadAll());
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    state = AsyncValue.data(await _repo.loadAll());
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = AsyncValue.data(await _repo.loadAll());
  }
}

/// Provider for a single character's live state (for the character sheet)
final activeCharacterProvider =
    StateNotifierProvider.family<CharacterSheetNotifier, CharacterModel?, String>(
  (ref, id) => CharacterSheetNotifier(id, ref),
);

class CharacterSheetNotifier extends StateNotifier<CharacterModel?> {
  final String id;
  final Ref ref;

  CharacterSheetNotifier(this.id, this.ref) : super(null) {
    _load();
  }

  CharacterRepository get _repo => ref.read(characterRepositoryProvider);

  Future<void> _load() async {
    state = await _repo.findById(id);
  }

  Future<void> _save() async {
    if (state != null) {
      await _repo.update(state!);
      ref.read(characterListProvider.notifier).refresh();
    }
  }

  // ── HP ────────────────────────────────────────────────────────────────────
  Future<void> markHp(int slots) async {
    if (state == null) return;
    state = state!.copyWith(
      currentHp: (state!.currentHp + slots).clamp(0, state!.maxHpSlots),
    );
    await _save();
  }

  Future<void> clearHp(int slots) async {
    if (state == null) return;
    state = state!.copyWith(
      currentHp: (state!.currentHp - slots).clamp(0, state!.maxHpSlots),
    );
    await _save();
  }

  Future<void> setHp(int value) async {
    if (state == null) return;
    state = state!.copyWith(currentHp: value.clamp(0, state!.maxHpSlots));
    await _save();
  }

  // ── Stress ────────────────────────────────────────────────────────────────
  Future<void> setStress(int value) async {
    if (state == null) return;
    state = state!.copyWith(currentStress: value.clamp(0, state!.maxStressSlots));
    await _save();
  }

  // ── Hope ──────────────────────────────────────────────────────────────────
  Future<void> setHope(int value) async {
    if (state == null) return;
    state = state!.copyWith(hope: value.clamp(0, GameConstants.maxHope));
    await _save();
  }

  // ── Armor ─────────────────────────────────────────────────────────────────
  Future<void> setArmorMarked(int slots) async {
    if (state == null) return;
    state = state!.copyWith(
      armorMarkedSlots: slots.clamp(0, state!.armorBaseScore),
    );
    await _save();
  }

  Future<void> clearAllArmor() async {
    if (state == null) return;
    state = state!.copyWith(armorMarkedSlots: 0);
    await _save();
  }

  // ── Conditions ────────────────────────────────────────────────────────────
  Future<void> toggleCondition(String condition) async {
    if (state == null) return;
    final conditions = List<String>.from(state!.activeConditions);
    if (conditions.contains(condition)) {
      conditions.remove(condition);
    } else {
      conditions.add(condition);
    }
    state = state!.copyWith(activeConditions: conditions);
    await _save();
  }

  // ── Gold ──────────────────────────────────────────────────────────────────
  Future<void> addHandfuls(int amount) async {
    if (state == null) return;
    var handfuls = state!.goldHandfuls + amount;
    var bags = state!.goldBags;
    var chests = state!.goldChests;
    while (handfuls >= 12) {
      handfuls -= 12;
      bags++;
    }
    while (bags >= 12) {
      bags -= 12;
      if (chests < 1) chests++;
    }
    state = state!.copyWith(
      goldHandfuls: handfuls, goldBags: bags, goldChests: chests,
    );
    await _save();
  }

  Future<void> setGold(int handfuls, int bags, int chests) async {
    if (state == null) return;
    state = state!.copyWith(
      goldHandfuls: handfuls.clamp(0, 11),
      goldBags: bags.clamp(0, 11),
      goldChests: chests.clamp(0, 1),
    );
    await _save();
  }

  // ── Domain Cards ──────────────────────────────────────────────────────────
  Future<void> addToLoadout(String cardId) async {
    if (state == null) return;
    final loadout = List<String>.from(state!.loadoutCardIds);
    if (loadout.length >= 5 || loadout.contains(cardId)) return;
    loadout.add(cardId);
    final vault = List<String>.from(state!.vaultCardIds)..remove(cardId);
    state = state!.copyWith(loadoutCardIds: loadout, vaultCardIds: vault);
    await _save();
  }

  Future<void> moveToVault(String cardId) async {
    if (state == null) return;
    final vault = List<String>.from(state!.vaultCardIds);
    if (!vault.contains(cardId)) vault.add(cardId);
    final loadout = List<String>.from(state!.loadoutCardIds)..remove(cardId);
    state = state!.copyWith(loadoutCardIds: loadout, vaultCardIds: vault);
    await _save();
  }

  // ── Inventory ─────────────────────────────────────────────────────────────
  Future<void> addInventoryItem(String item) async {
    if (state == null) return;
    final inv = List<String>.from(state!.inventory)..add(item);
    state = state!.copyWith(inventory: inv);
    await _save();
  }

  Future<void> removeInventoryItem(String item) async {
    if (state == null) return;
    final inv = List<String>.from(state!.inventory)..remove(item);
    state = state!.copyWith(inventory: inv);
    await _save();
  }

  // ── Notes ─────────────────────────────────────────────────────────────────
  Future<void> setNotes(String notes) async {
    if (state == null) return;
    state = state!.copyWith(notes: notes);
    await _save();
  }

  // ── Full character update (for creation / level up) ───────────────────────
  Future<void> replace(CharacterModel character) async {
    state = character;
    await _save();
  }
}
