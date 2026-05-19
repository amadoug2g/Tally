import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../buckets/presentation/widgets/bucket_card.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../../core/constants/mock_data.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final month = DateFormat('MMMM yyyy').format(DateTime.now());
    final txs = mockTransactions;

    final lifeBudget = 558.0;
    final bufferBudget = 335.0;
    final vaultBudget = 224.27;
    final billsBudget = 250.0;

    double lifeSpent = 0, bufferSpent = 0, vaultSpent = 0, billsSpent = 0;
    for (final t in txs) {
      if (t.type == TransactionType.fund || t.type == TransactionType.income) {
        continue;
      }
      final abs = t.amount.abs();
      switch (t.bucket) {
        case TransactionBucket.life: lifeSpent += abs;
        case TransactionBucket.buffer: bufferSpent += abs;
        case TransactionBucket.vault: vaultSpent += abs;
        case TransactionBucket.bills: billsSpent += abs;
        default: break;
      }
    }

    final income = txs.where((t) => t.isIncome).fold(0.0, (s, t) => s + t.amount);
    final spent = txs.where((t) => t.isExpense && t.type != TransactionType.fund).fold(0.0, (s, t) => s + t.amount.abs());
    final remaining = income - spent;

    final recent = txs
        .where((t) => t.type != TransactionType.fund && t.type != TransactionType.income)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: AppBar(
        title: Text(month),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long),
            onPressed: () => context.go('/dashboard/transactions'),
          ),
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () => context.go('/dashboard/buckets'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _MonthSummaryCard(income: income, spent: spent, remaining: remaining),
            const SizedBox(height: 16),
            BucketCard(label: 'Life', allocated: lifeBudget, spent: lifeSpent, color: const Color(0xFF4CAF50)),
            const SizedBox(height: 10),
            BucketCard(label: 'Buffer', allocated: bufferBudget, spent: bufferSpent, color: const Color(0xFF2196F3)),
            const SizedBox(height: 10),
            BucketCard(label: 'Vault', allocated: vaultBudget, spent: vaultSpent, color: const Color(0xFF9C27B0)),
            const SizedBox(height: 10),
            BucketCard(label: 'Bills', allocated: billsBudget, spent: billsSpent, color: const Color(0xFFFF9800)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Récent', style: Theme.of(context).textTheme.titleMedium),
                TextButton(
                  onPressed: () => context.go('/dashboard/transactions'),
                  child: const Text('Voir tout'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...recent.take(8).map((t) => _TransactionTile(transaction: t)),
          ],
        ),
      ),
    );
  }
}

class _MonthSummaryCard extends StatelessWidget {
  final double income;
  final double spent;
  final double remaining;

  const _MonthSummaryCard({required this.income, required this.spent, required this.remaining});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'fr_FR', symbol: '€', decimalDigits: 2);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Revenu du mois', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white54)),
            const SizedBox(height: 4),
            Text(fmt.format(income), style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _Item(label: 'Dépensé', value: fmt.format(spent), color: Colors.redAccent),
                _Item(label: 'Restant', value: fmt.format(remaining), color: remaining >= 0 ? Colors.greenAccent : Colors.redAccent),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _Item({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white54)),
      Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color, fontWeight: FontWeight.bold)),
    ],
  );
}

class _TransactionTile extends StatelessWidget {
  final Transaction transaction;
  const _TransactionTile({required this.transaction});

  static const Map<TransactionType, IconData> _icons = {
    TransactionType.eatingOut: Icons.restaurant,
    TransactionType.groceries: Icons.shopping_cart,
    TransactionType.shopping: Icons.storefront,
    TransactionType.transport: Icons.directions_bus,
    TransactionType.utilities: Icons.bolt,
    TransactionType.entertainment: Icons.play_circle_outline,
    TransactionType.health: Icons.favorite_outline,
    TransactionType.income: Icons.south_west,
    TransactionType.fund: Icons.swap_horiz,
    TransactionType.extra: Icons.more_horiz,
  };

  static const Map<TransactionBucket, Color> _bucketColors = {
    TransactionBucket.life: Color(0xFF4CAF50),
    TransactionBucket.buffer: Color(0xFF2196F3),
    TransactionBucket.vault: Color(0xFF9C27B0),
    TransactionBucket.bills: Color(0xFFFF9800),
    TransactionBucket.income: Color(0xFF00BCD4),
    TransactionBucket.extra: Color(0xFF607D8B),
  };

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'fr_FR', symbol: '€', decimalDigits: 2);
    final isExpense = transaction.amount < 0;
    final bucketColor = _bucketColors[transaction.bucket] ?? Colors.grey;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(color: bucketColor.withAlpha(30), borderRadius: BorderRadius.circular(10)),
            child: Icon(_icons[transaction.type] ?? Icons.circle, color: bucketColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transaction.description, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                Text(
                  transaction.receiver ?? '',
                  style: const TextStyle(fontSize: 12, color: Colors.white38),
                ),
              ],
            ),
          ),
          Text(
            '${isExpense ? '' : '+'}${fmt.format(transaction.amount)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isExpense ? Colors.white70 : Colors.greenAccent,
            ),
          ),
        ],
      ),
    );
  }
}
