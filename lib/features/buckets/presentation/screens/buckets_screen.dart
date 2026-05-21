import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/domain/entities/bucket_config.dart';
import '../../../auth/presentation/providers/bucket_config_provider.dart';

class BucketsScreen extends ConsumerStatefulWidget {
  const BucketsScreen({super.key});

  @override
  ConsumerState<BucketsScreen> createState() => _BucketsScreenState();
}

class _BucketsScreenState extends ConsumerState<BucketsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _incomeCtrl = TextEditingController();
  final _lifeCtrl = TextEditingController();
  final _bufferCtrl = TextEditingController();
  final _vaultCtrl = TextEditingController();
  final _billsCtrl = TextEditingController();
  bool _initialized = false;
  bool _saving = false;

  @override
  void dispose() {
    _incomeCtrl.dispose();
    _lifeCtrl.dispose();
    _bufferCtrl.dispose();
    _vaultCtrl.dispose();
    _billsCtrl.dispose();
    super.dispose();
  }

  double _parse(String v) => double.tryParse(v.replaceAll(',', '.')) ?? 0;

  double get _totalAllocated =>
      _parse(_lifeCtrl.text) +
      _parse(_bufferCtrl.text) +
      _parse(_vaultCtrl.text) +
      _parse(_billsCtrl.text);

  void _populateFromConfig(BucketConfig? config) {
    if (config == null || _initialized) return;
    _incomeCtrl.text = config.monthlyIncome.toStringAsFixed(0);
    _lifeCtrl.text = config.lifeAmount.toStringAsFixed(0);
    _bufferCtrl.text = config.bufferAmount.toStringAsFixed(0);
    _vaultCtrl.text = config.vaultAmount.toStringAsFixed(0);
    _billsCtrl.text = config.billsAmount.toStringAsFixed(0);
    _initialized = true;
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    final income = _parse(_incomeCtrl.text);
    if (income <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entre ton revenu mensuel')));
      return;
    }

    setState(() => _saving = true);
    final config = BucketConfig(
      monthlyIncome: income,
      lifeAmount: _parse(_lifeCtrl.text),
      bufferAmount: _parse(_bufferCtrl.text),
      vaultAmount: _parse(_vaultCtrl.text),
      billsAmount: _parse(_billsCtrl.text),
    );

    await ref.read(bucketConfigProvider.notifier).save(config);
    setState(() => _saving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Buckets mis à jour')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final configAsync = ref.watch(bucketConfigProvider);
    _populateFromConfig(configAsync.valueOrNull);

    final income = _parse(_incomeCtrl.text);
    final remaining = income - _totalAllocated;
    final fmt =
        NumberFormat.currency(locale: 'fr_FR', symbol: '€', decimalDigits: 0);

    return Scaffold(
      backgroundColor: TallyColors.groupedBackground,
      appBar: AppBar(
        title: const Text('Buckets'),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.chevron_back),
          color: TallyColors.systemBlue,
          onPressed: () => context.go('/dashboard'),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : _onSave,
            child: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Enregistrer',
                    style: TextStyle(
                        color: TallyColors.systemBlue,
                        fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            _SectionHeader(title: 'REVENU'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: TallyColors.systemBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              child: _InlineField(
                label: 'Revenu mensuel',
                controller: _incomeCtrl,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: 28),
            _SectionHeader(title: 'RÉPARTITION'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: TallyColors.systemBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _BucketRow(
                    label: 'Life',
                    subtitle: 'Courses, restos, quotidien',
                    color: TallyColors.life,
                    controller: _lifeCtrl,
                    onChanged: (_) => setState(() {}),
                  ),
                  const Divider(
                      height: 1,
                      thickness: 0.5,
                      indent: 32,
                      color: TallyColors.separator),
                  _BucketRow(
                    label: 'Buffer',
                    subtitle: 'Fond anti-burnout',
                    color: TallyColors.buffer,
                    controller: _bufferCtrl,
                    onChanged: (_) => setState(() {}),
                  ),
                  const Divider(
                      height: 1,
                      thickness: 0.5,
                      indent: 32,
                      color: TallyColors.separator),
                  _BucketRow(
                    label: 'Vault',
                    subtitle: 'Épargne intouchable',
                    color: TallyColors.vault,
                    controller: _vaultCtrl,
                    onChanged: (_) => setState(() {}),
                  ),
                  const Divider(
                      height: 1,
                      thickness: 0.5,
                      indent: 32,
                      color: TallyColors.separator),
                  _BucketRow(
                    label: 'Bills',
                    subtitle: 'Charges fixes',
                    color: TallyColors.bills,
                    controller: _billsCtrl,
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),
            if (income > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: remaining < 0
                      ? TallyColors.systemRed.withValues(alpha: 0.06)
                      : TallyColors.systemGreen.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      remaining < 0 ? 'Dépassement' : 'Non alloué',
                      style: TextStyle(
                        fontSize: 14,
                        color: remaining < 0
                            ? TallyColors.systemRed
                            : TallyColors.secondaryLabel,
                      ),
                    ),
                    Text(
                      '${remaining >= 0 ? '+' : ''}${fmt.format(remaining)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: remaining < 0
                            ? TallyColors.systemRed
                            : TallyColors.systemGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 2),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: TallyColors.secondaryLabel,
            letterSpacing: 0.5,
          ),
        ),
      );
}

class _InlineField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final void Function(String)? onChanged;

  const _InlineField({
    required this.label,
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        keyboardType:
            const TextInputType.numberWithOptions(decimal: true),
        onChanged: onChanged,
        style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: TallyColors.label),
        decoration: InputDecoration(
          labelText: label,
          suffixText: '€',
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      );
}

class _BucketRow extends StatelessWidget {
  final String label, subtitle;
  final Color color;
  final TextEditingController controller;
  final void Function(String)? onChanged;

  const _BucketRow({
    required this.label,
    required this.subtitle,
    required this.color,
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 38,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: TallyColors.label)),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12,
                          color: TallyColors.secondaryLabel)),
                ],
              ),
            ),
            SizedBox(
              width: 110,
              child: TextFormField(
                controller: controller,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: onChanged,
                textAlign: TextAlign.right,
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: TallyColors.label),
                decoration: const InputDecoration(
                  suffixText: '€',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      );
}
