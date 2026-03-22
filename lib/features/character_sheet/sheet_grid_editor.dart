import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import 'sheet_layout.dart';

/// Interactive 10-column grid with content-driven or viewport-fraction heights.
///
/// ── Width (colSpan) ──────────────────────────────────────────────────────────
/// • Drag right-edge pill  → snaps to nearest column unit (1–10).
/// • Tap  right-edge pill  → cycles 10 → 7 → 5 → 3 → 10 …
///
/// ── Height (rowSpan) ─────────────────────────────────────────────────────────
/// • rowSpan = 0.0  → auto: block is exactly its content height (default).
/// • rowSpan > 0    → fixed: block height = rowSpan × viewport height.
/// • Drag bottom-edge pill → snaps to nearest 5 % of viewport height.
/// • Tap  bottom-edge pill → cycles 0 % (auto) → 25 % → 50 % → 75 % → 0 %
///
/// Blocks in the same greedy row are top-aligned and fully independent in
/// height — a short block leaves empty space beneath it without pushing its
/// neighbours to be taller.
class InteractiveSheetGrid extends StatefulWidget {
  final List<SheetBlock> blocks;

  /// Called with (blockId, rowSpan) so builders can adapt layout to the
  /// available vertical space (e.g. Expanded TextField when rowSpan > 0).
  final Widget Function(String blockId, double rowSpan) blockBuilder;
  final void Function(List<SheetBlock> newLayout) onLayoutChanged;

  const InteractiveSheetGrid({
    super.key,
    required this.blocks,
    required this.blockBuilder,
    required this.onLayoutChanged,
  });

  @override
  State<InteractiveSheetGrid> createState() => _InteractiveSheetGridState();
}

class _InteractiveSheetGridState extends State<InteractiveSheetGrid>
    with SingleTickerProviderStateMixin {
  // ── Working layout ─────────────────────────────────────────────────────────
  late List<SheetBlock> _blocks;

  // ── Drag state ─────────────────────────────────────────────────────────────
  Timer? _holdTimer;
  SheetBlock? _pending;
  int? _activePointer;
  Offset _pointerDown = Offset.zero;

  SheetBlock? _dragging;
  int _phantomIndex = 0;
  Offset _dragGlobal = Offset.zero;
  OverlayEntry? _overlay;

  final Map<String, GlobalKey> _keys = {};

  // ── Horizontal (colSpan) resize ────────────────────────────────────────────
  String? _resizingId;
  int? _resizePointer;
  double _resizeAccum = 0;
  int _resizeOrigSpan = 1;
  int _resizeLastSnap = 1;

  // ── Vertical (rowSpan) resize ──────────────────────────────────────────────
  String? _vertResizingId;
  int? _vertResizePointer;
  double _vertResizeAccum = 0;      // raw pixel accumulator
  double _vertResizeOrigSpan = 0.0; // rowSpan fraction at gesture start
  double _vertResizeLastSnap = 0.0; // last snapped fraction (for haptics)

  // ── Measured each build ────────────────────────────────────────────────────
  double _colWidth      = 0;
  double _viewportH     = 0; // used for percentage calculation

  // ── Phantom animation ──────────────────────────────────────────────────────
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  // ── Constants ──────────────────────────────────────────────────────────────
  static const _holdDuration    = Duration(milliseconds: 350);
  static const _cancelThreshold = 8.0;
  static const _resizeZone      = 22.0;
  static const _presetSpans     = [10, 7, 5, 3];
  // Tap the bottom pill to cycle through these rowSpan presets
  static const _vPresets        = [0.0, 0.25, 0.50, 0.75];
  // Drag snaps every 5 % of viewport height
  static const _vStep           = 0.05;

  @override
  void initState() {
    super.initState();
    _blocks = [...widget.blocks];
    _syncKeys();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 220));
    _fadeAnim =
        CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutCubic);
  }

  @override
  void didUpdateWidget(InteractiveSheetGrid old) {
    super.didUpdateWidget(old);
    if (old.blocks != widget.blocks && _dragging == null) {
      _blocks = [...widget.blocks];
      _syncKeys();
    }
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _removeOverlay();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _syncKeys() {
    for (final b in _blocks) {
      _keys.putIfAbsent(b.id, () => GlobalKey());
    }
  }

  // ── Display list ───────────────────────────────────────────────────────────

  List<_Item> get _displayItems {
    if (_dragging == null) return _blocks.map(_Item.real).toList();
    final rest = _blocks.where((b) => b.id != _dragging!.id).toList();
    final out = <_Item>[];
    for (int i = 0; i <= rest.length; i++) {
      if (i == _phantomIndex) out.add(_Item.phantom(_dragging!));
      if (i < rest.length) out.add(_Item.real(rest[i]));
    }
    return out;
  }

  // ── Pointer dispatch ───────────────────────────────────────────────────────

  void _onPointerDown(SheetBlock block, PointerDownEvent e) {
    final key = _keys[block.id];
    if (key?.currentContext != null) {
      final box = key!.currentContext!.findRenderObject() as RenderBox?;
      if (box != null) {
        final local = box.globalToLocal(e.position);
        final w = box.size.width;
        final h = box.size.height;
        if (local.dx >= w - _resizeZone) {
          _startHResize(block.id, e.pointer);
          return;
        }
        if (local.dy >= h - _resizeZone && local.dx < w - _resizeZone) {
          _startVResize(block.id, e.pointer);
          return;
        }
      }
    }
    _holdTimer?.cancel();
    _pending = block;
    _activePointer = e.pointer;
    _pointerDown = e.position;
    _holdTimer = Timer(_holdDuration, () {
      if (_pending?.id == block.id && mounted) _liftBlock(block, _pointerDown);
    });
  }

  void _onPointerMove(PointerMoveEvent e) {
    if (e.pointer == _resizePointer)     { _updateHResize(e.delta.dx); return; }
    if (e.pointer == _vertResizePointer) { _updateVResize(e.delta.dy); return; }
    if (_dragging != null && e.pointer == _activePointer) {
      _dragGlobal = e.position;
      _overlay?.markNeedsBuild();
      _resolvePhantom(e.position);
      return;
    }
    if (_pending != null &&
        e.pointer == _activePointer &&
        (e.position - _pointerDown).distance > _cancelThreshold) {
      _holdTimer?.cancel();
      _pending = null;
      _activePointer = null;
    }
  }

  void _onPointerUp(PointerUpEvent e) {
    if (e.pointer == _resizePointer)     { _endHResize(); return; }
    if (e.pointer == _vertResizePointer) { _endVResize(); return; }
    _holdTimer?.cancel();
    _pending = null;
    if (_dragging != null && e.pointer == _activePointer) _dropBlock();
    _activePointer = null;
  }

  void _onPointerCancel(PointerCancelEvent e) {
    _holdTimer?.cancel();
    _pending = null;
    if (e.pointer == _resizePointer) {
      setState(() { _resizingId = null; _resizePointer = null; });
    }
    if (e.pointer == _vertResizePointer) {
      setState(() { _vertResizingId = null; _vertResizePointer = null; });
    }
    if (_dragging != null && e.pointer == _activePointer) {
      _removeOverlay();
      setState(() => _dragging = null);
    }
    _activePointer = null;
  }

  // ── Lift / drop ────────────────────────────────────────────────────────────

  void _liftBlock(SheetBlock block, Offset globalPos) {
    HapticFeedback.mediumImpact();
    final idx = _blocks.indexWhere((b) => b.id == block.id);
    setState(() {
      _dragging = block;
      _pending = null;
      _phantomIndex = idx.clamp(0, math.max(0, _blocks.length - 1));
      _dragGlobal = globalPos;
    });
    _fadeCtrl.forward(from: 0);
    _spawnOverlay();
  }

  void _dropBlock() {
    _removeOverlay();
    final rest = _blocks.where((b) => b.id != _dragging!.id).toList();
    rest.insert(_phantomIndex.clamp(0, rest.length), _dragging!);
    setState(() { _blocks = rest; _dragging = null; });
    widget.onLayoutChanged(_blocks);
    HapticFeedback.lightImpact();
  }

  // ── Phantom resolution ─────────────────────────────────────────────────────

  void _resolvePhantom(Offset globalPos) {
    final rest = _blocks.where((b) => b.id != _dragging!.id).toList();
    if (rest.isEmpty) {
      if (_phantomIndex != 0) setState(() => _phantomIndex = 0);
      return;
    }
    for (int i = 0; i < rest.length; i++) {
      final key = _keys[rest[i].id];
      if (key?.currentContext == null) continue;
      final box = key!.currentContext!.findRenderObject() as RenderBox?;
      if (box == null) continue;
      final rect = box.localToGlobal(Offset.zero) & box.size;
      if (!rect.contains(globalPos)) continue;
      final relX = (globalPos.dx - rect.left) / rect.width;
      final candidate = relX < 0.40 ? i : relX > 0.60 ? i + 1 : _phantomIndex;
      final c = candidate.clamp(0, rest.length);
      if (c != _phantomIndex) setState(() => _phantomIndex = c);
      return;
    }
  }

  // ── Overlay ────────────────────────────────────────────────────────────────

  void _spawnOverlay() {
    _removeOverlay();
    final block = _dragging!;
    final content = widget.blockBuilder(block.id, block.rowSpan);
    _overlay = OverlayEntry(
      builder: (_) => _FloatingBlock(
        block: block,
        globalPos: _dragGlobal,
        colWidth: _colWidth,
        viewportH: _viewportH,
        content: content,
      ),
    );
    Overlay.of(context).insert(_overlay!);
  }

  void _removeOverlay() { _overlay?.remove(); _overlay = null; }

  // ── Horizontal resize ──────────────────────────────────────────────────────

  void _startHResize(String id, int pointer) {
    final block = _blocks.firstWhere((b) => b.id == id);
    HapticFeedback.selectionClick();
    setState(() {
      _resizingId = id;  _resizePointer = pointer;
      _resizeAccum = 0;  _resizeOrigSpan = block.colSpan;
      _resizeLastSnap = block.colSpan;
    });
  }

  void _updateHResize(double dx) {
    if (_resizingId == null || _colWidth <= 0) return;
    _resizeAccum += dx;
    final newSpan =
        (_resizeOrigSpan + (_resizeAccum / _colWidth).round()).clamp(1, 10);
    if (newSpan != _resizeLastSnap) {
      HapticFeedback.selectionClick();
      _resizeLastSnap = newSpan;
    }
    final cur = _blocks.firstWhere((b) => b.id == _resizingId);
    if (cur.colSpan == newSpan) return;
    setState(() {
      _blocks = [for (final b in _blocks)
        if (b.id == _resizingId) b.copyWith(colSpan: newSpan) else b];
    });
  }

  void _endHResize() {
    if (_resizingId == null) return;
    final id = _resizingId!;
    if (_resizeAccum.abs() < 6) {
      final cur = _blocks.firstWhere((b) => b.id == id).colSpan;
      final next = _presetSpans.firstWhere(
          (s) => s < cur, orElse: () => _presetSpans.first);
      setState(() {
        _blocks = [for (final b in _blocks)
          if (b.id == id) b.copyWith(colSpan: next) else b];
        _resizingId = null; _resizePointer = null;
      });
      HapticFeedback.lightImpact();
    } else {
      setState(() { _resizingId = null; _resizePointer = null; });
    }
    widget.onLayoutChanged(_blocks);
  }

  // ── Vertical resize ────────────────────────────────────────────────────────

  void _startVResize(String id, int pointer) {
    final block = _blocks.firstWhere((b) => b.id == id);

    // When the block is in auto mode (rowSpan == 0), measure its actual
    // rendered height and convert to a viewport fraction so the drag starts
    // exactly at the block's current visual size, not from zero.
    double startSpan = block.rowSpan;
    if (startSpan == 0.0 && _viewportH > 0) {
      final key = _keys[id];
      if (key?.currentContext != null) {
        final box = key!.currentContext!.findRenderObject() as RenderBox?;
        if (box != null) {
          final fraction = box.size.height / _viewportH;
          // Snap to nearest 5 % step (minimum 5 %)
          startSpan = ((fraction / _vStep).round() * _vStep).clamp(_vStep, 1.0);
        }
      }
    }

    HapticFeedback.selectionClick();
    setState(() {
      _vertResizingId     = id;
      _vertResizePointer  = pointer;
      _vertResizeAccum    = 0;
      _vertResizeOrigSpan = startSpan;
      _vertResizeLastSnap = startSpan;
    });
  }

  void _updateVResize(double dy) {
    if (_vertResizingId == null || _viewportH <= 0) return;
    _vertResizeAccum += dy;

    // Convert raw pixels → fraction, then snap to nearest 5 %
    final rawFraction = _vertResizeOrigSpan + _vertResizeAccum / _viewportH;
    // Clamp: 0 means auto, so minimum manual value is _vStep (5 %)
    final snapped = rawFraction <= _vStep / 2
        ? 0.0 // snap back to auto when close to zero
        : (rawFraction / _vStep).round() * _vStep;
    final newSpan = snapped.clamp(0.0, 1.0);

    if ((newSpan - _vertResizeLastSnap).abs() > _vStep / 2) {
      HapticFeedback.selectionClick();
      _vertResizeLastSnap = newSpan;
    }
    final cur = _blocks.firstWhere((b) => b.id == _vertResizingId);
    // Avoid rebuilds for sub-step differences
    if ((cur.rowSpan - newSpan).abs() < _vStep / 4) return;
    setState(() {
      _blocks = [for (final b in _blocks)
        if (b.id == _vertResizingId) b.copyWith(rowSpan: newSpan) else b];
    });
  }

  void _endVResize() {
    if (_vertResizingId == null) return;
    final id = _vertResizingId!;
    if (_vertResizeAccum.abs() < 6) {
      // Tap → cycle presets: 0 % → 25 % → 50 % → 75 % → 0 %
      final cur = _blocks.firstWhere((b) => b.id == id).rowSpan;
      final next = _vPresets.firstWhere(
          (p) => p > cur + 0.01, orElse: () => _vPresets.first);
      setState(() {
        _blocks = [for (final b in _blocks)
          if (b.id == id) b.copyWith(rowSpan: next) else b];
        _vertResizingId = null; _vertResizePointer = null;
      });
      HapticFeedback.lightImpact();
    } else {
      setState(() { _vertResizingId = null; _vertResizePointer = null; });
    }
    widget.onLayoutChanged(_blocks);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    _viewportH = MediaQuery.of(context).size.height;

    return LayoutBuilder(builder: (_, constraints) {
      _colWidth = constraints.maxWidth / 10;
      final items = _displayItems;

      final rows = <List<_Item>>[];
      var row = <_Item>[];
      var spanAcc = 0;
      for (final item in items) {
        final s = item.colSpan.clamp(1, 10);
        if (spanAcc + s > 10 && row.isNotEmpty) {
          rows.add(row); row = []; spanAcc = 0;
        }
        row.add(item); spanAcc += s;
      }
      if (row.isNotEmpty) rows.add(row);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rows.map((rowItems) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rowItems.map((item) {
            final w = item.colSpan.clamp(1, 10) * _colWidth;
            return item.isPhantom
                ? _buildPhantom(w, item.block)
                : _buildBlockSlot(item.block, w);
          }).toList(),
        )).toList(),
      );
    });
  }

  // ── Phantom slot ───────────────────────────────────────────────────────────

  Widget _buildPhantom(double width, SheetBlock block) {
    final fixedH = block.rowSpan > 0 ? block.rowSpan * _viewportH : null;
    return AnimatedBuilder(
      animation: _fadeAnim,
      builder: (_, __) {
        final t = _fadeAnim.value;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          width: width,
          height: fixedH,
          child: Opacity(
            opacity: (t * 0.45).clamp(0.0, 1.0),
            child: Stack(
              fit: fixedH != null ? StackFit.expand : StackFit.loose,
              children: [
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: fixedH != null
                      ? SizedBox.expand(
                          child: widget.blockBuilder(block.id, block.rowSpan))
                      : widget.blockBuilder(block.id, block.rowSpan),
                ),
                Positioned.fill(
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.primary
                            .withAlpha((220 * t).round().clamp(0, 255)),
                        width: 2,
                      ),
                      color: AppColors.primary
                          .withAlpha((22 * t).round().clamp(0, 255)),
                    ),
                    child: Center(
                      child: Opacity(
                        opacity: t,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [BoxShadow(
                              color: AppColors.primary.withAlpha(140),
                              blurRadius: 14,
                            )],
                          ),
                          child: Text(
                            'DROP HERE',
                            style: GoogleFonts.cinzel(
                              fontSize: 8, fontWeight: FontWeight.w700,
                              color: AppColors.background, letterSpacing: 1.4,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Real block slot ────────────────────────────────────────────────────────

  Widget _buildBlockSlot(SheetBlock block, double width) {
    final isHResizing = _resizingId == block.id;
    final isVResizing = _vertResizingId == block.id;
    final isPending   = _pending?.id == block.id;

    // Fixed height when rowSpan > 0; null = auto (intrinsic content height).
    final fixedH = block.rowSpan > 0 ? block.rowSpan * _viewportH : null;

    // Whether the slot has a bounded height for StackFit and SizedBox.expand
    final hasFixedH = fixedH != null;

    return AnimatedContainer(
      key: _keys[block.id],
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      width: width,
      // AnimatedContainer smoothly animates width changes.
      // Height is handled by AnimatedSize below for auto↔fixed transitions.
    child: AnimatedSize(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        child: SizedBox(
          width: double.infinity,
          height: fixedH, // null = auto (intrinsic)
          child: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (e) => _onPointerDown(block, e),
            onPointerMove: _onPointerMove,
            onPointerUp: _onPointerUp,
            onPointerCancel: _onPointerCancel,
            child: Stack(
              // expand when there's a fixed height so content fills the cell;
              // loose when auto so the Stack sizes to its content.
              fit: hasFixedH ? StackFit.expand : StackFit.loose,
              children: [
                // ── Block content ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 160),
                    curve: Curves.easeOut,
                    scale: isPending ? 0.96 : 1.0,
                    // SizedBox.expand tells the block to fill the fixed height;
                    // without it the block uses its natural intrinsic height.
                    child: hasFixedH
                        ? SizedBox.expand(
                            child: widget.blockBuilder(block.id, block.rowSpan))
                        : widget.blockBuilder(block.id, block.rowSpan),
                  ),
                ),

                // ── Hold-to-move hint ──────────────────────────────────────
                Positioned(
                  top: 8, left: 8,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 180),
                    opacity: _dragging == null ? 0.40 : 0.0,
                    child: Container(
                      width: 22, height: 22,
                      decoration: BoxDecoration(
                        color: AppColors.surface.withAlpha(220),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(Icons.open_with,
                          size: 12, color: AppColors.textDisabled),
                    ),
                  ),
                ),

                // ── Right-edge pill — colSpan resize ──────────────────────
                Positioned(
                  top: 0, right: 0, bottom: _resizeZone, width: _resizeZone,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(6)),
                      color: isHResizing
                          ? AppColors.primary.withAlpha(40)
                          : Colors.transparent,
                    ),
                    child: Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 140),
                        width: isHResizing ? 4 : 3,
                        height: isHResizing ? 36 : 20,
                        decoration: BoxDecoration(
                          color: isHResizing
                              ? AppColors.primary
                              : AppColors.textDisabled.withAlpha(80),
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: isHResizing
                              ? [BoxShadow(
                                  color: AppColors.primary.withAlpha(160),
                                  blurRadius: 10)]
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Bottom-edge pill — rowSpan resize ─────────────────────
                // Shows current percentage when active
                Positioned(
                  bottom: 0, left: 0, right: _resizeZone, height: _resizeZone,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(6)),
                      color: isVResizing
                          ? AppColors.hope.withAlpha(40)
                          : Colors.transparent,
                    ),
                    child: Center(
                      child: isVResizing && block.rowSpan > 0
                          ? Text(
                              '${(block.rowSpan * 100).round()} %',
                              style: GoogleFonts.cinzel(
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                                color: AppColors.hope,
                                letterSpacing: 0.5,
                              ),
                            )
                          : AnimatedContainer(
                              duration: const Duration(milliseconds: 140),
                              width: isVResizing ? 36 : 20,
                              height: isVResizing ? 4 : 3,
                              decoration: BoxDecoration(
                                color: isVResizing
                                    ? AppColors.hope
                                    : AppColors.textDisabled.withAlpha(80),
                                borderRadius: BorderRadius.circular(3),
                                boxShadow: isVResizing
                                    ? [BoxShadow(
                                        color: AppColors.hope.withAlpha(160),
                                        blurRadius: 10)]
                                    : null,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void deactivate() { _removeOverlay(); super.deactivate(); }
}

// ── Floating block overlay ────────────────────────────────────────────────────

class _FloatingBlock extends StatelessWidget {
  final SheetBlock block;
  final Offset globalPos;
  final double colWidth;
  final double viewportH;
  final Widget content;

  const _FloatingBlock({
    required this.block,
    required this.globalPos,
    required this.colWidth,
    required this.viewportH,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final blockW = math.min(block.colSpan * colWidth, sw - 24.0);
    final blockH = block.rowSpan > 0 ? block.rowSpan * viewportH : null;

    final left = (globalPos.dx - blockW / 2).clamp(8.0, sw - blockW - 8);
    final top  = blockH != null
        ? globalPos.dy - blockH / 2
        : globalPos.dy - 55.0;

    return Positioned(
      left: left, top: top, width: blockW, height: blockH,
      child: IgnorePointer(
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primary, width: 2),
              boxShadow: [
                BoxShadow(color: AppColors.primary.withAlpha(100),
                    blurRadius: 32, spreadRadius: 2),
                BoxShadow(color: Colors.black.withAlpha(180),
                    blurRadius: 20, offset: const Offset(0, 12)),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: blockH != null ? SizedBox.expand(child: content) : content,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Internal item ─────────────────────────────────────────────────────────────

class _Item {
  final SheetBlock block;
  final bool isPhantom;
  const _Item.real(this.block)    : isPhantom = false;
  const _Item.phantom(this.block) : isPhantom = true;
  int get colSpan => block.colSpan;
}
