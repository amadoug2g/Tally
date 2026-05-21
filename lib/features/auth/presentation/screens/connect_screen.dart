import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:plaid_flutter/plaid_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class ConnectScreen extends ConsumerStatefulWidget {
  const ConnectScreen({super.key});

  @override
  ConsumerState<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends ConsumerState<ConnectScreen> {
  final _clientIdCtrl = TextEditingController();
  final _secretCtrl = TextEditingController();
  StreamSubscription<LinkSuccess>? _successSub;
  StreamSubscription<LinkExit>? _exitSub;

  @override
  void dispose() {
    _successSub?.cancel();
    _exitSub?.cancel();
    _clientIdCtrl.dispose();
    _secretCtrl.dispose();
    super.dispose();
  }

  Future<void> _openPlaidLink(String linkToken) async {
    final config = LinkTokenConfiguration(token: linkToken);
    await PlaidLink.create(configuration: config);

    _successSub = PlaidLink.onSuccess.listen((event) {
      ref.read(authProvider.notifier).handlePlaidSuccess(event.publicToken);
    });

    _exitSub = PlaidLink.onExit.listen((event) {
      if (event.error != null) {
        ref.read(authProvider.notifier).reset();
      }
    });

    PlaidLink.open();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen(authProvider, (_, next) {
      if (next is AuthLinkReady) {
        _openPlaidLink(next.linkToken);
      } else if (next is AuthConnected) {
        context.go('/dashboard');
      }
    });

    return Scaffold(
      backgroundColor: TallyColors.groupedBackground,
      appBar: AppBar(
        title: const Text('Connecter un compte'),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.chevron_back),
          color: TallyColors.systemBlue,
          onPressed: () => context.go('/onboarding'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _buildBody(authState),
        ),
      ),
    );
  }

  Widget _buildBody(AuthState state) {
    if (state is AuthLinkReady ||
        state is AuthAuthenticating ||
        state is AuthConnecting) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoActivityIndicator(radius: 14),
            SizedBox(height: 16),
            Text(
              'Connexion en cours…',
              style: TextStyle(
                  fontSize: 15, color: TallyColors.secondaryLabel),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          'Credentials Plaid',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        const Text(
          'Crée un compte sur dashboard.plaid.com → "Keys" pour récupérer ton Client ID et Secret (sandbox).',
          style: TextStyle(fontSize: 15, color: TallyColors.secondaryLabel),
        ),
        const SizedBox(height: 28),
        _IOSTextField(
          controller: _clientIdCtrl,
          placeholder: 'Client ID',
          autofillHint: AutofillHints.username,
        ),
        const SizedBox(height: 1),
        _IOSTextField(
          controller: _secretCtrl,
          placeholder: 'Secret',
          obscureText: true,
          autofillHint: AutofillHints.password,
        ),
        if (state is AuthError) ...[
          const SizedBox(height: 16),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: TallyColors.systemRed.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(CupertinoIcons.exclamationmark_circle,
                    color: TallyColors.systemRed, size: 17),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    state.message,
                    style: const TextStyle(
                        color: TallyColors.systemRed, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
        const Spacer(),
        FilledButton(
          onPressed: _onConnect,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            backgroundColor: TallyColors.systemBlue,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Connecter',
              style:
                  TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  void _onConnect() {
    final clientId = _clientIdCtrl.text.trim();
    final secret = _secretCtrl.text.trim();
    if (clientId.isEmpty || secret.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Remplis les deux champs')),
      );
      return;
    }
    ref.read(authProvider.notifier).connect(clientId, secret);
  }
}

// ─── iOS-style grouped text field ─────────────────────────────────────────────

class _IOSTextField extends StatelessWidget {
  final TextEditingController controller;
  final String placeholder;
  final bool obscureText;
  final String? autofillHint;

  const _IOSTextField({
    required this.controller,
    required this.placeholder,
    this.obscureText = false,
    this.autofillHint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: TallyColors.systemBackground,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        autofillHints: autofillHint != null ? [autofillHint!] : null,
        style: const TextStyle(
            fontSize: 17, color: TallyColors.label, letterSpacing: -0.4),
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: const TextStyle(
              fontSize: 17, color: TallyColors.tertiaryLabel),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
