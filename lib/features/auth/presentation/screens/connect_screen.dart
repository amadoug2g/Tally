import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  final _secretIdController = TextEditingController();
  final _secretKeyController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _secretIdController.dispose();
    _secretKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connecter Revolut')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Entre tes credentials GoCardless',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Crée un compte gratuit sur bankaccountdata.gocardless.com et génère un secret_id + secret_key.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white54),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _secretIdController,
              decoration: const InputDecoration(labelText: 'Secret ID', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _secretKeyController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Secret Key', border: OutlineInputBorder()),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _loading ? null : _onConnect,
                child: _loading ? const CircularProgressIndicator() : const Text('Connecter'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onConnect() async {
    setState(() => _loading = true);
    // TODO: call GoCardlessDataSource.getAccessToken + createRequisition + launch OAuth
    // Then navigate to dashboard after callback
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) context.go('/dashboard');
  }
}
