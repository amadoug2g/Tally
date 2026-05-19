import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/bucket_config_provider.dart';
import '../../domain/entities/bucket_config.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _incomeCtrl = TextEditingController();
  final _lifeCtrl = TextEditingController();
  final _bufferCtrl = TextEditingController();
  final _vaultCtrl = TextEditingController();
  final _billsCtrl = TextEditingController();
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

  double get _totalAllocated =>
      _parse(_lifeCtrl.text) + _parse(_bufferCtrl.text) + _parse(_vaultCtrl.text) + _parse(_billsCtrl.text);

  double _parse(String v) => double.tryParse(v.replaceAll(',', '.')) ?? 0;

  String? _validateAmount(String? v) {
    if (v == null || v.isEmpty) return 'Requis';
    if (_parse(v) <= 0) return 'Montant invalide';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final income = _parse(_incomeCtrl.text);
    final remaining = income - _totalAllocated;

    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 32),
              Text('Tally', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Configure tes buckets', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white54)),
              const SizedBox(height: 40),
              _BucketField(
                label: 'Revenu mensuel',
                controller: _incomeCtrl,
                icon: Icons.account_balance_wallet_outlined,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 24),
              const _SectionLabel('Répartition'),
              const SizedBox(height: 12),
              _BucketField(
                label: 'Life',
                controller: _lifeCtrl,
                color: const Color(0xFF4CAF50),
                hint: 'Courses, restos, quotidien',
                validator: _validateAmount,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              _BucketField(
                label: 'Buffer',
                controller: _bufferCtrl,
                color: const Color(0xFF2196F3),
                hint: 'Fond anti-burnout',
                validator: _validateAmount,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              _BucketField(
                label: 'Vault',
                controller: _vaultCtrl,
                color: const Color(0xFF9C27B0),
                hint: 'Épargne intouchable',
                validator: _validateAmount,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              _BucketField(
                label: 'Bills',
                controller: _billsCtrl,
                color: const Color(0xFFFF9800),
                hint: 'Charges fixes',
                validator: _validateAmount,
                onChanged: (_) => setState(() {}),
              ),
              if (income > 0) ...[
                const SizedBox(height: 20),
                _AllocationSummary(income: income, allocated: _totalAllocated, remaining: remaining),
              ],
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _saving ? null : _onSave,
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                child: _saving
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Continuer'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    final income = _parse(_incomeCtrl.text);
    if (income <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Entre ton revenu mensuel')));
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
    if (mounted) context.go('/connect');
  }
}

class _BucketField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final Color? color;
  final IconData? icon;
  final String? hint;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const _BucketField({
    required this.label,
    required this.controller,
    this.color,
    this.icon,
    this.hint,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null
            ? Icon(icon)
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                child: Container(width: 4, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
              ),
        prefixIconConstraints: icon != null ? null : const BoxConstraints(minWidth: 24),
        suffixText: '€',
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) =>
      Text(text, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white54, letterSpacing: 1));
}

class _AllocationSummary extends StatelessWidget {
  final double income;
  final double allocated;
  final double remaining;

  const _AllocationSummary({required this.income, required this.allocated, required this.remaining});

  @override
  Widget build(BuildContext context) {
    final isOver = remaining < 0;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isOver ? Colors.red.withAlpha(30) : Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isOver ? Colors.redAccent.withAlpha(80) : Colors.white12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(isOver ? 'Dépassement' : 'Non alloué', style: TextStyle(color: isOver ? Colors.redAccent : Colors.white54, fontSize: 13)),
          Text(
            '${remaining >= 0 ? '+' : ''}€${remaining.toStringAsFixed(2)}',
            style: TextStyle(
              color: isOver ? Colors.redAccent : Colors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
