import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/game_constants.dart';
import '../../../shared/widgets/section_header.dart';

/// Gold Tracker widget — Handfuls, Bags, Chests with +/- buttons.
/// Auto-carries when handfuls hit 12 → bags, bags hit 12 → chest.
class GoldTracker extends StatelessWidget {
  final int handfuls;
  final int bags;
  final int chests;
  final void Function(int handfuls, int bags, int chests) onChanged;

  const GoldTracker({
    super.key,
    required this.handfuls,
    required this.bags,
    required this.chests,
    required this.onChanged,
  });

  void _addHandfuls(int amount) {
    var h = handfuls + amount;
    var b = bags;
    var c = chests;

    if (h < 0) {
      // Borrow from bags
      if (b > 0) {
        b--;
        h += GameConstants.handfulPerBag;
      } else {
        h = 0;
      }
    } else {
      while (h >= GameConstants.handfulPerBag) {
        h -= GameConstants.handfulPerBag;
        b++;
      }
      while (b >= GameConstants.bagPerChest) {
        b -= GameConstants.bagPerChest;
        if (c < GameConstants.maxChests) c++;
      }
    }
    onChanged(h.clamp(0, 11), b.clamp(0, 11), c.clamp(0, 1));
  }

  void _addBags(int amount) {
    var b = bags + amount;
    var c = chests;

    if (b < 0) {
      b = 0;
    } else {
      while (b >= GameConstants.bagPerChest) {
        b -= GameConstants.bagPerChest;
        if (c < GameConstants.maxChests) c++;
      }
    }
    onChanged(handfuls, b.clamp(0, 11), c.clamp(0, 1));
  }

  void _addChests(int amount) {
    final c = (chests + amount).clamp(0, GameConstants.maxChests);
    onChanged(handfuls, bags, c);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Gold'),
          const SizedBox(height: 8),
          _buildRow(
            icon: Icons.grain,
            label: 'Handfuls',
            value: handfuls,
            max: 11,
            onAdd: () => _addHandfuls(1),
            onSubtract: () => _addHandfuls(-1),
          ),
          const SizedBox(height: 8),
          _buildRow(
            icon: Icons.shopping_bag_outlined,
            label: 'Bags',
            value: bags,
            max: 11,
            onAdd: () => _addBags(1),
            onSubtract: () => _addBags(-1),
          ),
          const SizedBox(height: 8),
          _buildRow(
            icon: Icons.inventory_2_outlined,
            label: 'Chests',
            value: chests,
            max: 1,
            onAdd: () => _addChests(1),
            onSubtract: () => _addChests(-1),
          ),
        ],
      ),
    );
  }

  Widget _buildRow({
    required IconData icon,
    required String label,
    required int value,
    required int max,
    required VoidCallback onAdd,
    required VoidCallback onSubtract,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.crimsonText(
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        _CounterButton(
          icon: Icons.remove,
          onPressed: value > 0 ? onSubtract : null,
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 36,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: GoogleFonts.cinzel(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        _CounterButton(
          icon: Icons.add,
          onPressed: value < max ? onAdd : null,
        ),
        const SizedBox(width: 4),
        Text(
          '/ $max',
          style: GoogleFonts.crimsonText(
            fontSize: 12,
            color: AppColors.textDisabled,
          ),
        ),
      ],
    );
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _CounterButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      height: 30,
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 16),
        color: AppColors.primary,
        disabledColor: AppColors.textDisabled,
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: AppColors.surfaceVariant,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: const BorderSide(color: AppColors.border),
          ),
        ),
      ),
    );
  }
}
