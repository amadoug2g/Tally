import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';

class BucketCard extends StatelessWidget {
  final String label;
  final double allocated;
  final double spent;
  final Color color;

  const BucketCard({
    super.key,
    required this.label,
    required this.allocated,
    required this.spent,
    required this.color,
  });

  double get remaining => allocated - spent;
  double get progress => allocated > 0 ? (spent / allocated).clamp(0.0, 1.0) : 0.0;

  Color get trackColor {
    if (progress < 0.7) return color;
    if (progress < 0.9) return TallyColors.systemOrange;
    return TallyColors.systemRed;
  }

  @override
  Widget build(BuildContext context) {
    final fmt =
        NumberFormat.currency(locale: 'fr_FR', symbol: '€', decimalDigits: 0);

    return Container(
      decoration: BoxDecoration(
        color: TallyColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: TallyColors.label,
                  letterSpacing: -0.4,
                ),
              ),
              const Spacer(),
              Text(
                '${fmt.format(remaining)} restant',
                style: const TextStyle(
                  fontSize: 15,
                  color: TallyColors.secondaryLabel,
                  letterSpacing: -0.24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFE5E5EA),
              valueColor: AlwaysStoppedAnimation<Color>(trackColor),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${fmt.format(spent)} dépensé',
                style: const TextStyle(
                    fontSize: 12, color: TallyColors.secondaryLabel),
              ),
              Text(
                fmt.format(allocated),
                style: const TextStyle(
                    fontSize: 12, color: TallyColors.tertiaryLabel),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
