import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_provider.dart';

class ConnectScreen extends ConsumerStatefulWidget {
  const ConnectScreen({super.key});

  @override
  ConsumerState<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends ConsumerState<ConnectScreen> {
  final _secretIdCtrl = TextEditingController();
  final _secretKeyCtrl = TextEditingController();
  StreamSubscription<Uri>? _linkSub;

  @override
  void initState() {
    super.initState();
    _listenForDeepLink();
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    _secretIdCtrl.dispose();
    _secretKeyCtrl.dispose();
    super.dispose();
  }

  void _listenForDeepLink() {
    final appLinks = AppLinks();
    _linkSub = appLinks.uriLinkStream.listen((uri) {
      if (uri.scheme == 'tally' && uri.host == 'auth') {
        ref.read(authProvider.notifier).handleOAuthCallback();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen(authProvider, (_, next) {
      if (next is AuthConnected) {
        context.go('/dashboard');
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connecter Revolut'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/onboarding'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _buildBody(authState),
      ),
    );
  }

  Widget _buildBody(AuthState state) {
    if (state is AuthWaitingOAuth) {
      return _WaitingOAuthView(
        link: state.link,
        onRetry: () => ref.read(authProvider.notifier).reset(),
      );
    }

    if (state is AuthFetchingAccounts) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Récupération de ton compte...', style: TextStyle(color: Colors.white54)),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Credentials GoCardless', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          'Crée un compte gratuit sur bankaccountdata.gocardless.com — section "User Secrets".',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white54),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _secretIdCtrl,
          decoration: const InputDecoration(labelText: 'Secret ID', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _secretKeyCtrl,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Secret Key', border: OutlineInputBorder()),
        ),
        if (state is AuthError) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withAlpha(30),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.redAccent.withAlpha(80)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text(state.message, style: const TextStyle(color: Colors.redAccent, fontSize: 13))),
              ],
            ),
          ),
        ],
        const Spacer(),
        FilledButton(
          onPressed: state is AuthAuthenticating ? null : _onConnect,
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
          child: state is AuthAuthenticating
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Connecter'),
        ),
      ],
    );
  }

  void _onConnect() {
    final id = _secretIdCtrl.text.trim();
    final key = _secretKeyCtrl.text.trim();
    if (id.isEmpty || key.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Remplis les deux champs')),
      );
      return;
    }
    ref.read(authProvider.notifier).connect(id, key);
  }
}

class _WaitingOAuthView extends StatelessWidget {
  final String link;
  final VoidCallback onRetry;

  const _WaitingOAuthView({required this.link, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.open_in_browser, size: 64, color: Colors.white38),
        const SizedBox(height: 24),
        Text(
          'Ouvre Revolut pour autoriser',
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Une fois autorisé, tu seras redirigé automatiquement.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white54),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        FilledButton.icon(
          onPressed: () => launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication),
          icon: const Icon(Icons.open_in_new),
          label: const Text('Ouvrir Revolut'),
          style: FilledButton.styleFrom(minimumSize: const Size(200, 48)),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: onRetry,
          child: const Text('Recommencer', style: TextStyle(color: Colors.white38)),
        ),
      ],
    );
  }
}
