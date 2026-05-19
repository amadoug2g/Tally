import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _incomeController = TextEditingController();
  final _lifeController = TextEditingController();
  final _bufferController = TextEditingController();
  final _vaultController = TextEditingController();
  final _billsController = TextEditingController();

  @override
  void dispose() {
    _incomeController.dispose();
    _lifeController.dispose();
    _bufferController.dispose();
    _vaultController.dispose();
    _billsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text('Tally', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Configure tes buckets', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white54)),
              const SizedBox(height: 40),
              _AmountField(label: 'Revenu mensuel', controller: _incomeController, icon: Icons.account_balance_wallet),
              const SizedBox(height: 16),
              _AmountField(label: 'Life', controller: _lifeController, color: const Color(0xFF4CAF50)),
              const SizedBox(height: 12),
              _AmountField(label: 'Buffer', controller: _bufferController, color: const Color(0xFF2196F3)),
              const SizedBox(height: 12),
              _AmountField(label: 'Vault', controller: _vaultController, color: const Color(0xFF9C27B0)),
              const SizedBox(height: 12),
              _AmountField(label: 'Bills', controller: _billsController, color: const Color(0xFFFF9800)),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _onNext,
                  child: const Text('Connecter Revolut'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onNext() {
    // TODO: save BucketConfig then navigate to connect
    context.go('/connect');
  }
}

class _AmountField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final Color? color;
  final IconData? icon;

  const _AmountField({required this.label, required this.controller, this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null
            ? Icon(icon)
            : Container(width: 4, color: color, margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
        prefixIconConstraints: icon != null ? null : const BoxConstraints(minWidth: 20),
        suffixText: '€',
        border: const OutlineInputBorder(),
      ),
    );
  }
}
