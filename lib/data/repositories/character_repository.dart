import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/character_model.dart';

/// CRUD for characters stored as JSON in SharedPreferences.
class CharacterRepository {
  static const _key = 'daggerheart_characters';

  /// Load all characters
  Future<List<CharacterModel>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => CharacterModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Save all characters (overwrites)
  Future<void> saveAll(List<CharacterModel> characters) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(characters.map((c) => c.toJson()).toList());
    await prefs.setString(_key, json);
  }

  /// Create a new character (append and save)
  Future<void> create(CharacterModel character) async {
    final all = await loadAll();
    all.add(character);
    await saveAll(all);
  }

  /// Update an existing character by id
  Future<void> update(CharacterModel character) async {
    final all = await loadAll();
    final idx = all.indexWhere((c) => c.id == character.id);
    if (idx != -1) {
      all[idx] = character;
      await saveAll(all);
    }
  }

  /// Delete a character by id
  Future<void> delete(String id) async {
    final all = await loadAll();
    all.removeWhere((c) => c.id == id);
    await saveAll(all);
  }

  /// Retrieve a single character by id
  Future<CharacterModel?> findById(String id) async {
    final all = await loadAll();
    try {
      return all.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
