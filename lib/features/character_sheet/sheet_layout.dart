import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Block identifiers ─────────────────────────────────────────────────────────

const kBlockIdentity    = 'identity';
const kBlockVitals      = 'vitals';
const kBlockHope        = 'hope';
const kBlockArmor       = 'armor';
const kBlockThresholds  = 'thresholds';
const kBlockTraits      = 'traits';
const kBlockConditions  = 'conditions';
const kBlockCards       = 'cards';
const kBlockExperiences = 'experiences';
const kBlockGold        = 'gold';
const kBlockInventory   = 'inventory';
const kBlockNotes       = 'notes';

// ── Model ─────────────────────────────────────────────────────────────────────

/// A single grid block.
///
/// [colSpan] — 1–10 columns (horizontal width, same 10-unit system as before).
///
/// [rowSpan] — fraction of the viewport height.
///   • 0.0  → auto / intrinsic: the block is exactly as tall as its content.
///   • 0.05 → 5 % of the viewport height (the minimum manual step).
///   • 1.0  → 100 % of the viewport height.
///
/// The bottom-edge handle snaps in 5 % steps (0.05 increments) when dragged,
/// and cycles through [0, 0.25, 0.50, 0.75] on a tap.
class SheetBlock {
  final String id;
  final int colSpan;      // 1–10
  final double rowSpan;   // 0.0 = auto, 0.05–1.0 = fraction of viewport height

  const SheetBlock({
    required this.id,
    required this.colSpan,
    this.rowSpan = 0.0,
  });

  SheetBlock copyWith({int? colSpan, double? rowSpan}) => SheetBlock(
        id: id,
        colSpan: colSpan ?? this.colSpan,
        rowSpan: rowSpan ?? this.rowSpan,
      );

  Map<String, dynamic> toJson() =>
      {'id': id, 'colSpan': colSpan, 'rowSpan': rowSpan};

  factory SheetBlock.fromJson(Map<String, dynamic> j) {
    // Migration: old layouts stored rowSpan as an integer (1-10 row units).
    // Any value ≥ 1 is from the old system → reset to 0.0 (auto).
    final raw = j['rowSpan'];
    double rowSpan = 0.0;
    if (raw is num) {
      final v = raw.toDouble();
      rowSpan = v >= 1.0 ? 0.0 : v.clamp(0.0, 1.0);
    }
    return SheetBlock(
      id: j['id'] as String,
      colSpan: j['colSpan'] as int,
      rowSpan: rowSpan,
    );
  }
}

// Blocks that have been merged into other blocks and must be stripped from
// any layout that was saved before this migration.
const _deprecatedBlockIds = {kBlockThresholds};

/// The default layout.  All blocks start at rowSpan 0.0 (auto-fit content).
const List<SheetBlock> defaultLayout = [
  SheetBlock(id: kBlockIdentity,    colSpan: 10),
  SheetBlock(id: kBlockVitals,      colSpan: 7),
  SheetBlock(id: kBlockHope,        colSpan: 3),
  SheetBlock(id: kBlockArmor,       colSpan: 5),
  SheetBlock(id: kBlockTraits,      colSpan: 5),
  SheetBlock(id: kBlockConditions,  colSpan: 10),
  SheetBlock(id: kBlockCards,       colSpan: 10),
  SheetBlock(id: kBlockExperiences, colSpan: 5),
  SheetBlock(id: kBlockGold,        colSpan: 5),
  SheetBlock(id: kBlockInventory,   colSpan: 5),
  SheetBlock(id: kBlockNotes,       colSpan: 5),
];

/// Human-readable labels for the edit mode.
const Map<String, String> blockLabels = {
  kBlockIdentity:    'Identity',
  kBlockVitals:      'Vitals',
  kBlockHope:        'Hope',
  kBlockArmor:       'Armor',
  kBlockThresholds:  'Thresholds',
  kBlockTraits:      'Traits',
  kBlockConditions:  'Conditions',
  kBlockCards:       'Domain Cards',
  kBlockExperiences: 'Experiences',
  kBlockGold:        'Gold',
  kBlockInventory:   'Inventory',
  kBlockNotes:       'Notes',
};

// ── Provider ──────────────────────────────────────────────────────────────────

final sheetLayoutProvider = StateNotifierProvider.family<
    SheetLayoutNotifier, List<SheetBlock>, String>(
  (ref, characterId) => SheetLayoutNotifier(characterId),
);

class SheetLayoutNotifier extends StateNotifier<List<SheetBlock>> {
  final String _characterId;
  static const _prefix = 'sheet_layout_';

  SheetLayoutNotifier(this._characterId) : super(defaultLayout) {
    _load();
  }

  String get _key => '$_prefix$_characterId';

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null) {
        var list = (jsonDecode(raw) as List)
            .map((e) => SheetBlock.fromJson(e as Map<String, dynamic>))
            .toList();
        list = list.where((b) => !_deprecatedBlockIds.contains(b.id)).toList();
        final existingIds = list.map((b) => b.id).toSet();
        for (final def in defaultLayout) {
          if (!existingIds.contains(def.id)) list.add(def);
        }
        state = list;
      }
    } catch (_) {
      state = defaultLayout;
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _key, jsonEncode(state.map((b) => b.toJson()).toList()));
  }

  void reorder(int oldIndex, int newIndex) {
    final list = [...state];
    if (newIndex > oldIndex) newIndex--;
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    state = list;
    _save();
  }

  void setColSpan(String id, int colSpan) {
    state = [
      for (final b in state)
        if (b.id == id) b.copyWith(colSpan: colSpan.clamp(1, 10)) else b,
    ];
    _save();
  }

  /// [rowSpan] is a fraction of the viewport height (0.0 = auto, 0.05–1.0).
  void setRowSpan(String id, double rowSpan) {
    state = [
      for (final b in state)
        if (b.id == id) b.copyWith(rowSpan: rowSpan.clamp(0.0, 1.0)) else b,
    ];
    _save();
  }

  void setLayout(List<SheetBlock> blocks) {
    state = blocks;
    _save();
  }

  void resetLayout() {
    state = defaultLayout;
    _save();
  }
}

// ── Legacy SheetGrid renderer (kept for backward compatibility) ───────────────

class SheetGrid extends StatelessWidget {
  final List<SheetBlock> blocks;
  final Widget Function(String blockId, double blockWidth) builder;

  const SheetGrid({
    super.key,
    required this.blocks,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final colWidth = totalWidth / 10;
        final rows = <List<SheetBlock>>[];
        var currentRow = <SheetBlock>[];
        var currentSpan = 0;
        for (final block in blocks) {
          final span = block.colSpan.clamp(1, 10);
          if (currentSpan + span > 10 && currentRow.isNotEmpty) {
            rows.add(currentRow);
            currentRow = [];
            currentSpan = 0;
          }
          currentRow.add(block);
          currentSpan += span;
        }
        if (currentRow.isNotEmpty) rows.add(currentRow);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rows.map((row) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: row.map((block) {
                final w = block.colSpan.clamp(1, 10) * colWidth;
                return SizedBox(width: w, child: builder(block.id, w));
              }).toList(),
            );
          }).toList(),
        );
      },
    );
  }
}
