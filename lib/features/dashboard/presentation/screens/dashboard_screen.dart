import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../buckets/presentation/widgets/bucket_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final month = DateFormat('MMMM yyyy', 'fr_FR').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text(month),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long),
            onPressed: () => context.go('/dashboard/transactions'),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go('/dashboard/buckets'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: trigger GoCardless sync
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _MonthSummaryCard(),
            const SizedBox(height: 16),
            const BucketCard(label: 'Life', allocated: 558, spent: 0, color: Color(0xFF4CAF50)),
            const SizedBox(height: 12),
            const BucketCard(label: 'Buffer', allocated: 335, spent: 0, color: Color(0xFF2196F3)),
            const SizedBox(height: 12),
            const BucketCard(label: 'Vault', allocated: 224.27, spent: 0, color: Color(0xFF9C27B0)),
            const SizedBox(height: 12),
            const BucketCard(label: 'Bills', allocated: 250, spent: 196.23, color: Color(0xFFFF9800)),
            const SizedBox(height: 24),
            _RecentTransactionsHeader(),
          ],
        ),
      ),
    );
  }
}

class _MonthSummaryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Revenu du mois', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white54)),
            const SizedBox(height: 4),
            Text('€1 367,27', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _SummaryItem(label: 'Dépensé', value: '€1 365,02', color: Colors.redAccent),
                _SummaryItem(label: 'Restant', value: '€10,99', color: Colors.greenAccent),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white54)),
        Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _RecentTransactionsHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Transactions récentes', style: Theme.of(context).textTheme.titleMedium),
        TextButton(
          onPressed: () => context.go('/dashboard/transactions'),
          child: const Text('Voir tout'),
        ),
      ],
    );
  }
}
