import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/bucket_config_provider.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';

class BillsScreen extends ConsumerWidget {
  const BillsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txsAsync = ref.watch(transactionsProvider);
    final configAsync = ref.watch(bucketConfigProvider);

    return Scaffold(
      backgroundColor: TallyColors.groupedBackground,
      appBar: AppBar(
        title: const Text('Bills'),
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
          final billsTxs = txs
              .where((t) => t.bucket == TransactionBucket.bills)
              .toList();

          final upcoming = billsTxs
              .where((t) => t.isPending)
              .toList()
            ..sort((a, b) => a.date.compareTo(b.date));

          final paid = billsTxs
              .where((t) => !t.isPending)
              .toList()
            ..sort((a, b) => b.date.compareTo(a.date));

          final budget = configAsync.valueOrNull?.billsAmount ?? 0;
          final spent = paid.fold(0.0, (s, t) => s + t.amount.abs());

          if (billsTxs.isEmpty) {
            return RefreshIndicator.adaptive(
              onRefresh: () async =>
                  ref.read(transactionsProvider.notifier).refresh(),
              child: ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(
                    child: Text(
                      'Aucune facture ce mois',
                      style: TextStyle(
                          fontSize: 17, color: TallyColors.secondaryLabel),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator.adaptive(
            onRefresh: () async =>
                ref.read(transactionsProvider.notifier).refresh(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: [
                _BillsSummaryCard(spent: spent, budget: budget),
                if (upcoming.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  const _SectionLabel(title: 'À venir'),
                  const SizedBox(height: 8),
                  _BillsGroup(transactions: upcoming, isPending: true),
                ],
                if (paid.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  const _SectionLabel(title: 'Payé ce mois'),
                  const SizedBox(height: 8),
                  _BillsGroup(transactions: paid, isPending: false),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;
  const _SectionLabel({required this.title});

  @override
  Widget build(BuildContext context) => Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: TallyColors.label,
          letterSpacing: -0.45,
        ),
      );
}

class _BillsSummaryCard extends StatelessWidget {
  final double spent, budget;
  const _BillsSummaryCard({required this.spent, required this.budget});

  @override
  Widget build(BuildContext context) {
    final fmt =
        NumberFormat.currency(locale: 'fr_FR', symbol: '€', decimalDigits: 2);
    final progress =
        budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;
    final Color trackColor;
    if (progress < 0.7) {
      trackColor = TallyColors.bills;
    } else if (progress < 0.9) {
      trackColor = TallyColors.systemOrange;
    } else {
      trackColor = TallyColors.systemRed;
    }

    return Container(
      decoration: BoxDecoration(
        color: TallyColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Dépensé ce mois',
                  style: TextStyle(
                      fontSize: 13, color: TallyColors.secondaryLabel)),
              if (budget > 0)
                Text(fmt.format(budget),
                    style: const TextStyle(
                        fontSize: 13, color: TallyColors.tertiaryLabel)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            fmt.format(spent),
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: TallyColors.label,
              letterSpacing: -0.5,
            ),
          ),
          if (budget > 0) ...[
            const SizedBox(height: 12),
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
            Text(
              '${fmt.format(budget - spent)} restant',
              style: const TextStyle(
                  fontSize: 12, color: TallyColors.secondaryLabel),
            ),
          ],
        ],
      ),
    );
  }
}

class _BillsGroup extends StatelessWidget {
  final List<Transaction> transactions;
  final bool isPending;
  const _BillsGroup({required this.transactions, required this.isPending});

  static const Map<TransactionType, IconData> _icons = {
    TransactionType.utilities: CupertinoIcons.bolt,
    TransactionType.entertainment: CupertinoIcons.play_circle,
    TransactionType.health: CupertinoIcons.heart,
    TransactionType.transport: CupertinoIcons.car,
    TransactionType.extra: CupertinoIcons.doc_text,
  };

  @override
  Widget build(BuildContext context) {
    final fmt =
        NumberFormat.currency(locale: 'fr_FR', symbol: '€', decimalDigits: 2);
    final dateFmt = DateFormat('d MMM', 'fr_FR');

    return Container(
      decoration: BoxDecoration(
        color: TallyColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          for (int i = 0; i < transactions.length; i++) ...[
            _buildRow(transactions[i], fmt, dateFmt),
            if (i < transactions.length - 1)
              const Divider(
                  height: 1,
                  thickness: 0.5,
                  indent: 60,
                  endIndent: 0,
                  color: TallyColors.separator),
          ],
        ],
      ),
    );
  }

  Widget _buildRow(Transaction t, NumberFormat fmt, DateFormat dateFmt) {
    final color =
        isPending ? TallyColors.bills.withValues(alpha: 0.5) : TallyColors.bills;
    final icon = _icons[t.type] ?? CupertinoIcons.bolt;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: TallyColors.bills.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.description,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isPending
                        ? TallyColors.secondaryLabel
                        : TallyColors.label,
                    letterSpacing: -0.24,
                  ),
                ),
                Text(
                  dateFmt.format(t.date),
                  style: const TextStyle(
                      fontSize: 12, color: TallyColors.secondaryLabel),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '−${fmt.format(t.amount.abs())}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isPending
                      ? TallyColors.secondaryLabel
                      : TallyColors.label,
                  letterSpacing: -0.24,
                ),
              ),
              if (isPending)
                Container(
                  margin: const EdgeInsets.only(top: 3),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: TallyColors.bills.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'À venir',
                    style: TextStyle(
                      fontSize: 10,
                      color: TallyColors.bills,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
