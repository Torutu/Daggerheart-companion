import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/game_constants.dart';

class StepTraits extends StatefulWidget {
  final Map<String, int> traits;
  final void Function(Map<String, int>) onChanged;

  const StepTraits({
    super.key,
    required this.traits,
    required this.onChanged,
  });

  @override
  State<StepTraits> createState() => _StepTraitsState();
}

class _StepTraitsState extends State<StepTraits> {
  int? _selectedPoolValue; // the value chip currently selected from pool

  /// Compute which pool values are still unassigned (unassigned = not yet placed)
  List<int> get _remainingPool {
    final pool = List<int>.from(GameConstants.startingTraitValues);
    for (final val in widget.traits.values) {
      pool.remove(val);
    }
    return pool;
  }

  bool get _allAssigned => widget.traits.length == GameConstants.traitNames.length;

  void _reset() {
    widget.onChanged({});
    setState(() => _selectedPoolValue = null);
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _remainingPool;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Assign Your Traits',
            style: GoogleFonts.cinzel(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap a value from the pool, then tap a trait to assign it. Values: +2, +1, +1, 0, 0, −1.',
            style: GoogleFonts.crimsonText(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),

          // Value pool
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'VALUE POOL',
                  style: GoogleFonts.cinzel(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDisabled,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                if (remaining.isEmpty)
                  Text(
                    'All values assigned!',
                    style: GoogleFonts.crimsonText(
                      fontSize: 14,
                      color: AppColors.primary,
                      fontStyle: FontStyle.italic,
                    ),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: remaining.map((val) {
                      final label = val >= 0 ? '+$val' : '$val';
                      final isSelected = _selectedPoolValue == val;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedPoolValue = isSelected ? null : val;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 120),
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : AppColors.border,
                              width: 2,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            label,
                            style: GoogleFonts.cinzel(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (_selectedPoolValue != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary.withAlpha(120)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.touch_app, size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    'Now tap a trait to assign ${_selectedPoolValue! >= 0 ? '+$_selectedPoolValue' : '$_selectedPoolValue'}',
                    style: GoogleFonts.crimsonText(
                      fontSize: 14,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Trait assignment
          ...GameConstants.traitNames.map((trait) {
            final label = GameConstants.traitLabels[trait] ?? trait;
            final verb = GameConstants.traitVerbs[trait] ?? '';
            final assigned = widget.traits[trait];
            final hasValue = assigned != null;

            return GestureDetector(
              onTap: _selectedPoolValue != null
                  ? () {
                      final newTraits = Map<String, int>.from(widget.traits);
                      // If trait already assigned, return old value to pool
                      if (hasValue) {
                        // Just overwrite — the old value goes back to pool automatically
                      }
                      newTraits[trait] = _selectedPoolValue!;
                      widget.onChanged(newTraits);
                      setState(() => _selectedPoolValue = null);
                    }
                  : hasValue
                      ? () {
                          // Tap assigned trait to unassign
                          final newTraits = Map<String, int>.from(widget.traits);
                          newTraits.remove(trait);
                          widget.onChanged(newTraits);
                        }
                      : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: _selectedPoolValue != null
                      ? AppColors.surfaceVariant
                      : hasValue
                          ? AppColors.cardBackground
                          : AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _selectedPoolValue != null
                        ? AppColors.primary.withAlpha(80)
                        : hasValue
                            ? AppColors.border
                            : AppColors.border,
                    width: _selectedPoolValue != null ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: GoogleFonts.cinzel(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: hasValue ? AppColors.primary : AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            verb,
                            style: GoogleFonts.crimsonText(
                              fontSize: 12,
                              color: AppColors.textDisabled,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (hasValue)
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(40),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.primary.withAlpha(120)),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          assigned >= 0 ? '+$assigned' : '$assigned',
                          style: GoogleFonts.cinzel(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '—',
                          style: GoogleFonts.cinzel(
                            fontSize: 20,
                            color: AppColors.textDisabled,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 16),
          if (widget.traits.isNotEmpty)
            TextButton.icon(
              onPressed: _reset,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Reset Assignments'),
            ),
        ],
      ),
    );
  }
}
