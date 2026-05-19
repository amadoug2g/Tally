import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../auth/domain/entities/bucket_config.dart';
import '../../../auth/presentation/providers/bucket_config_provider.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';
import '../../../../core/theme/app_theme.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txsAsync = ref.watch(transactionsProvider);
    final configAsync = ref.watch(bucketConfigProvider);
    final month = DateFormat('MMMM yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: TallyColors.groupedBackground,
      body: txsAsync.when(
        loading: () => _LoadingView(month: month),
        error: (e, _) => _ErrorView(
          month: month,
          error: e.toString(),
          onRetry: () => ref.read(transactionsProvider.notifier).refresh(),
        ),
        data: (txs) {
          final config = configAsync.valueOrNull;
          return _DashboardBody(
            month: month,
            transactions: txs,
            config: config,
            onRefresh: () => ref.read(transactionsProvider.notifier).refresh(),
          );
        },
      ),
    );
  }
}

// ─── Loading ──────────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  final String month;
  const _LoadingView({required this.month});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _LargeTitleBar(month: month),
        const SliverFillRemaining(
          child: Center(
            child: CupertinoActivityIndicator(radius: 14),
          ),
        ),
      ],
    );
  }
}

// ─── Error ────────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String month, error;
  final VoidCallback onRetry;
  const _ErrorView(
      {required this.month, required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _LargeTitleBar(month: month),
        SliverFillRemaining(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(CupertinoIcons.exclamationmark_circle,
                    size: 48, color: TallyColors.systemRed),
                const SizedBox(height: 16),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 15, color: TallyColors.secondaryLabel),
                ),
                const SizedBox(height: 24),
                CupertinoButton(
                  onPressed: onRetry,
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Main body ────────────────────────────────────────────────────────────────

class _DashboardBody extends StatelessWidget {
  final String month;
  final List<Transaction> transactions;
  final BucketConfig? config;
  final VoidCallback onRefresh;

  const _DashboardBody({
    required this.month,
    required this.transactions,
    required this.config,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    // Compute spent per bucket
    double lifeSpent = 0, bufferSpent = 0, vaultSpent = 0, billsSpent = 0;
    for (final t in transactions) {
      if (t.type == TransactionType.fund || t.type == TransactionType.income) {
        continue;
      }
      final abs = t.amount.abs();
      switch (t.bucket) {
        case TransactionBucket.life:
          { lifeSpent += abs; }
        case TransactionBucket.buffer:
          { bufferSpent += abs; }
        case TransactionBucket.vault:
          { vaultSpent += abs; }
        case TransactionBucket.bills:
          { billsSpent += abs; }
        default:
          break;
      }
    }

    // Budget from saved config, or 0 if not set
    final lifeBudget = config?.lifeAmount ?? 0;
    final bufferBudget = config?.bufferAmount ?? 0;
    final vaultBudget = config?.vaultAmount ?? 0;
    final billsBudget = config?.billsAmount ?? 0;

    final income = transactions
        .where((t) => t.isIncome)
        .fold(0.0, (s, t) => s + t.amount);
    final spent = transactions
        .where((t) => t.isExpense && t.type != TransactionType.fund)
        .fold(0.0, (s, t) => s + t.amount.abs());
    final remaining = income - spent;

    final recent = transactions
        .where((t) =>
            t.type != TransactionType.fund &&
            t.type != TransactionType.income)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return CustomScrollView(
      slivers: [
        _LargeTitleBar(
          month: month,
          onTransactions: (ctx) => ctx.go('/dashboard/transactions'),
          onBuckets: (ctx) => ctx.go('/dashboard/buckets'),
        ),
        SliverToBoxAdapter(
          child: RefreshIndicator.adaptive(
            onRefresh: () async => onRefresh(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SummaryCard(
                      income: income, spent: spent, remaining: remaining),
                  const SizedBox(height: 36),
                  const _SectionLabel(title: 'Buckets'),
                  const SizedBox(height: 8),
                  _BucketsGroup(
                    buckets: [
                      _BucketData('Life', lifeBudget, lifeSpent,
                          TallyColors.life),
                      _BucketData('Buffer', bufferBudget, bufferSpent,
                          TallyColors.buffer),
                      _BucketData('Vault', vaultBudget, vaultSpent,
                          TallyColors.vault),
                      _BucketData('Bills', billsBudget, billsSpent,
                          TallyColors.bills),
                    ],
                  ),
                  const SizedBox(height: 36),
                  Builder(builder: (ctx) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const _SectionLabel(title: 'Récentes'),
                        TextButton(
                          onPressed: () =>
                              ctx.go('/dashboard/transactions'),
                          style: TextButton.styleFrom(
                            foregroundColor: TallyColors.systemBlue,
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('Voir tout',
                              style: TextStyle(fontSize: 15)),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 8),
                  _TransactionGroup(transactions: recent.take(8).toList()),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Large title app bar ──────────────────────────────────────────────────────

class _LargeTitleBar extends StatelessWidget {
  final String month;
  final void Function(BuildContext)? onTransactions;
  final void Function(BuildContext)? onBuckets;

  const _LargeTitleBar({
    required this.month,
    this.onTransactions,
    this.onBuckets,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 100,
      backgroundColor: TallyColors.groupedBackground,
      scrolledUnderElevation: 0.5,
      shadowColor: TallyColors.separator,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding:
            const EdgeInsetsDirectional.only(start: 20, bottom: 14),
        expandedTitleScale: 1.0,
        title: Text(
          month,
          style: const TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.bold,
            color: TallyColors.label,
            letterSpacing: 0.37,
          ),
        ),
      ),
      actions: [
        Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(CupertinoIcons.list_bullet),
            color: TallyColors.systemBlue,
            onPressed:
                onTransactions != null ? () => onTransactions!(ctx) : null,
            tooltip: 'Transactions',
          ),
        ),
        Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(CupertinoIcons.slider_horizontal_3),
            color: TallyColors.systemBlue,
            onPressed: onBuckets != null ? () => onBuckets!(ctx) : null,
            tooltip: 'Buckets',
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}

// ─── Section label ────────────────────────────────────────────────────────────

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

// ─── Summary card ─────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final double income, spent, remaining;
  const _SummaryCard(
      {required this.income, required this.spent, required this.remaining});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(
        locale: 'fr_FR', symbol: '€', decimalDigits: 2);
    return Container(
      decoration: BoxDecoration(
        color: TallyColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Revenu du mois',
            style: TextStyle(
              fontSize: 13,
              color: TallyColors.secondaryLabel,
              letterSpacing: -0.08,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            fmt.format(income),
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: TallyColors.label,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(
              height: 1,
              thickness: 0.5,
              indent: 0,
              endIndent: 0,
              color: TallyColors.separator),
          const SizedBox(height: 16),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _SummaryPill(
                    label: 'Dépensé',
                    value: fmt.format(spent),
                    isNegative: true,
                  ),
                ),
                const VerticalDivider(
                    width: 1,
                    thickness: 0.5,
                    color: TallyColors.separator),
                Expanded(
                  child: _SummaryPill(
                    label: 'Restant',
                    value: fmt.format(remaining),
                    isNegative: remaining < 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  final String label, value;
  final bool isNegative;
  const _SummaryPill(
      {required this.label, required this.value, required this.isNegative});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 12, color: TallyColors.secondaryLabel)),
            const SizedBox(height: 3),
            Text(
              value,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.4,
                color: isNegative
                    ? TallyColors.systemRed
                    : TallyColors.label,
              ),
            ),
          ],
        ),
      );
}

// ─── Buckets group ────────────────────────────────────────────────────────────

class _BucketData {
  final String label;
  final double allocated, spent;
  final Color color;
  _BucketData(this.label, this.allocated, this.spent, this.color);

  double get remaining => allocated - spent;
  double get progress =>
      allocated > 0 ? (spent / allocated).clamp(0.0, 1.0) : 0.0;
  Color get trackColor {
    if (progress < 0.7) return color;
    if (progress < 0.9) return TallyColors.systemOrange;
    return TallyColors.systemRed;
  }
}

class _BucketsGroup extends StatelessWidget {
  final List<_BucketData> buckets;
  const _BucketsGroup({required this.buckets});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(
        locale: 'fr_FR', symbol: '€', decimalDigits: 0);
    return Container(
      decoration: BoxDecoration(
        color: TallyColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          for (int i = 0; i < buckets.length; i++) ...[
            _BucketRow(data: buckets[i], fmt: fmt),
            if (i < buckets.length - 1)
              const Divider(
                  height: 1,
                  thickness: 0.5,
                  indent: 16,
                  endIndent: 0,
                  color: TallyColors.separator),
          ],
        ],
      ),
    );
  }
}

class _BucketRow extends StatelessWidget {
  final _BucketData data;
  final NumberFormat fmt;
  const _BucketRow({required this.data, required this.fmt});

  @override
  Widget build(BuildContext context) => Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                      color: data.color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 10),
                Text(data.label,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: TallyColors.label,
                      letterSpacing: -0.4,
                    )),
                const Spacer(),
                Text(
                  '${fmt.format(data.remaining)} restant',
                  style: const TextStyle(
                      fontSize: 15, color: TallyColors.secondaryLabel),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: data.progress,
                backgroundColor: const Color(0xFFE5E5EA),
                valueColor:
                    AlwaysStoppedAnimation<Color>(data.trackColor),
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${fmt.format(data.spent)} dépensé',
                    style: const TextStyle(
                        fontSize: 12,
                        color: TallyColors.secondaryLabel)),
                Text(fmt.format(data.allocated),
                    style: const TextStyle(
                        fontSize: 12,
                        color: TallyColors.tertiaryLabel)),
              ],
            ),
          ],
        ),
      );
}

// ─── Transaction list ─────────────────────────────────────────────────────────

class _TransactionGroup extends StatelessWidget {
  final List<Transaction> transactions;
  const _TransactionGroup({required this.transactions});

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
    return Container(
      decoration: BoxDecoration(
        color: TallyColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          for (int i = 0; i < transactions.length; i++) ...[
            _buildRow(transactions[i], fmt),
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

  Widget _buildRow(Transaction t, NumberFormat fmt) {
    final isExpense = t.amount < 0;
    final bucketColor =
        _bucketColors[t.bucket] ?? const Color(0xFF8E8E93);
    final icon = _icons[t.type] ?? CupertinoIcons.circle;

    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  t.description,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: TallyColors.label,
                    letterSpacing: -0.24,
                  ),
                ),
                if (t.receiver != null && t.receiver!.isNotEmpty)
                  Text(
                    t.receiver!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: TallyColors.secondaryLabel,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${isExpense ? '−' : '+'}${fmt.format(t.amount.abs())}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: isExpense
                  ? TallyColors.label
                  : TallyColors.systemGreen,
              letterSpacing: -0.24,
            ),
          ),
        ],
      ),
    );
  }
}
