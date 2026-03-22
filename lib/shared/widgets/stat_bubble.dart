import 'package:flutter/material.dart';

/// A reusable small circular bubble widget for HP, Stress, and Armor trackers.
class StatBubble extends StatelessWidget {
  final bool filled;
  final Color filledColor;
  final Color emptyColor;
  final double size;
  final VoidCallback? onTap;

  const StatBubble({
    super.key,
    required this.filled,
    required this.filledColor,
    required this.emptyColor,
    this.size = 24,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: filled ? filledColor : emptyColor,
          border: Border.all(
            color: filled ? filledColor.withAlpha(200) : filledColor.withAlpha(80),
            width: 1.5,
          ),
          boxShadow: filled
              ? [
                  BoxShadow(
                    color: filledColor.withAlpha(100),
                    blurRadius: 4,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
      ),
    );
  }
}
