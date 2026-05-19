import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/transaction.dart';
import '../providers/transaction_provider.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txsAsync = ref.watch(transactionsProvider);

    return Scaffold(
      backgroundColor: TallyColors.groupedBackground,
      appBar: AppBar(
        title: const Text('Transactions'),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.chevron_back),
          color: TallyColors.systemBlue,
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: txsAsync.when(
        loading: () => const Center(child: CupertinoActivityIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(CupertinoIcons.exclamationmark_circle,
                    size: 40, color: TallyColors.systemRed),
                const SizedBox(height: 12),
                Text(e.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 15, color: TallyColors.secondaryLabel)),
                const SizedBox(height: 20),
                CupertinoButton(
                  onPressed: () =>
                      ref.read(transactionsProvider.notifier).refresh(),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
        data: (txs) {
          final visible = txs
              .where((t) =>
                  t.type != TransactionType.fund &&
                  t.type != TransactionType.income)
              .toList()
            ..sort((a, b) => b.date.compareTo(a.date));

          if (visible.isEmpty) {
            return const Center(
              child: Text(
                'Aucune transaction ce mois',
                style: TextStyle(
                    fontSize: 17, color: TallyColors.secondaryLabel),
              ),
            );
          }

          return RefreshIndicator.adaptive(
            onRefresh: () async =>
                ref.read(transactionsProvider.notifier).refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              itemCount: visible.length,
              itemBuilder: (context, i) {
                final t = visible[i];
                final prevDate =
                    i > 0 ? visible[i - 1].date : null;
                final showHeader = prevDate == null ||
                    !_sameDay(prevDate, t.date);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showHeader) _DateHeader(date: t.date),
                    _TransactionTile(transaction: t),
                    if (i < visible.length - 1 &&
                        !_sameDay(t.date, visible[i + 1].date))
                      const SizedBox(height: 0)
                    else if (i < visible.length - 1)
                      const Divider(
                          height: 1,
                          thickness: 0.5,
                          indent: 60,
                          color: TallyColors.separator),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _DateHeader extends StatelessWidget {
  final DateTime date;
  const _DateHeader({required this.date});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('d MMMM', 'fr_FR');
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        fmt.format(date),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: TallyColors.secondaryLabel,
          letterSpacing: -0.08,
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Transaction transaction;
  const _TransactionTile({required this.transaction});

  static const Map<TransactionType, IconData> _icons = {
    TransactionType.eatingOut: CupertinoIcons.flame,
    TransactionType.groceries: CupertinoIcons.bag,
    TransactionType.shopping: CupertinoIcons.bag_badge_plus,
    TransactionType.transport: CupertinoIcons.car,
    TransactionType.utilities: CupertinoIcons.bolt,
    TransactionType.entertainment: CupertinoIcons.play_circle,
    TransactionType.health: CupertinoIcons.heart,
    TransactionType.income: CupertinoIcons.arrow_down_left,
    TransactionType.fund: CupertinoIcons.arrow_right_arrow_left,
    TransactionType.extra: CupertinoIcons.ellipsis,
  };

  static const Map<TransactionBucket, Color> _bucketColors = {
    TransactionBucket.life: TallyColors.life,
    TransactionBucket.buffer: TallyColors.buffer,
    TransactionBucket.vault: TallyColors.vault,
    TransactionBucket.bills: TallyColors.bills,
    TransactionBucket.income: TallyColors.income,
    TransactionBucket.extra: Color(0xFF8E8E93),
  };

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(
        locale: 'fr_FR', symbol: '€', decimalDigits: 2);
    final isExpense = transaction.amount < 0;
    final bucketColor =
        _bucketColors[transaction.bucket] ?? const Color(0xFF8E8E93);
    final icon = _icons[transaction.type] ?? CupertinoIcons.circle;

    return Container(
      color: TallyColors.systemBackground,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: bucketColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: bucketColor, size: 17),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: TallyColors.label,
                    letterSpacing: -0.24,
                  ),
                ),
                if (transaction.receiver != null &&
                    transaction.receiver!.isNotEmpty)
                  Text(
                    transaction.receiver!,
                    style: const TextStyle(
                        fontSize: 12, color: TallyColors.secondaryLabel),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${isExpense ? '−' : '+'}${fmt.format(transaction.amount.abs())}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: isExpense ? TallyColors.label : TallyColors.systemGreen,
              letterSpacing: -0.24,
            ),
          ),
        ],
      ),
    );
  }
}
