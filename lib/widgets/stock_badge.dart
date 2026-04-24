import 'package:flutter/material.dart';

class StockBadge extends StatelessWidget {
  final int quantity;

  const StockBadge({super.key, required this.quantity});

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    if (quantity >= 5) {
      badgeColor = const Color(0xFF16A34A); // Hijau
    } else if (quantity > 0) {
      badgeColor = const Color(0xFFD97706); // Kuning
    } else {
      badgeColor = const Color(0xFFDC2626); // Merah
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor, width: 1),
      ),
      child: Text(
        '$quantity',
        style: TextStyle(
          color: badgeColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
