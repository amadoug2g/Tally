import 'package:flutter/material.dart';

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

  Color get progressColor {
    if (progress < 0.7) return color;
    if (progress < 0.9) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Text(label, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                Text(
                  '€${remaining.toStringAsFixed(2)} restant',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white54),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation(progressColor),
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('€${spent.toStringAsFixed(2)} dépensé', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white54)),
                Text('/ €${allocated.toStringAsFixed(2)}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white38)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
