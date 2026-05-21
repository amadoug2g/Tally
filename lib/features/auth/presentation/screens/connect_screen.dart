import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class ConnectScreen extends ConsumerStatefulWidget {
  const ConnectScreen({super.key});

  @override
  ConsumerState<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends ConsumerState<ConnectScreen> {
  final _appIdCtrl = TextEditingController();
  final _secretCtrl = TextEditingController();
  StreamSubscription<Uri>? _linkSub;

  @override
  void initState() {
    super.initState();
    _listenForDeepLink();
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    _appIdCtrl.dispose();
    _secretCtrl.dispose();
    super.dispose();
  }

  void _listenForDeepLink() {
    _linkSub = AppLinks().uriLinkStream.listen((uri) {
      if (uri.scheme == 'tally' && uri.host == 'auth') {
        // Salt Edge passes connection_id or id as query param
        final connectionId =
            uri.queryParameters['connection_id'] ?? uri.queryParameters['id'];
        if (connectionId != null) {
          ref.read(authProvider.notifier).handleDeepLink(connectionId);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen(authProvider, (_, next) {
      if (next is AuthConnected) context.go('/dashboard');
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
    if (state is AuthWaitingOAuth) {
      return _WaitingOAuthView(
        connectUrl: state.connectUrl,
        onRetry: () => ref.read(authProvider.notifier).reset(),
      );
    }

    if (state is AuthFetchingAccounts || state is AuthAuthenticating) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoActivityIndicator(radius: 14),
            SizedBox(height: 16),
            Text(
              'Connexion en cours…',
              style: TextStyle(fontSize: 15, color: TallyColors.secondaryLabel),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text('Credentials Salt Edge',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                const Text(
                  'saltedge.com → Settings → Applications → ton app → App ID + Secret.',
                  style: TextStyle(fontSize: 15, color: TallyColors.secondaryLabel),
                ),
                const SizedBox(height: 28),
                _IOSTextField(
                  controller: _appIdCtrl,
                  placeholder: 'App ID',
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
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                            (state as AuthError).message,
                            style: const TextStyle(
                                color: TallyColors.systemRed, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: state is AuthAuthenticating ? null : _onConnect,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            backgroundColor: TallyColors.systemBlue,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: state is AuthAuthenticating
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Text('Connecter',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  void _onConnect() {
    final appId = _appIdCtrl.text.trim();
    final secret = _secretCtrl.text.trim();
    if (appId.isEmpty || secret.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Remplis les deux champs')),
      );
      return;
    }
    ref.read(authProvider.notifier).connect(appId, secret);
  }
}

// ─── Waiting for OAuth ───────────────────────────────────────────────────────────────────────

class _WaitingOAuthView extends StatelessWidget {
  final String connectUrl;
  final VoidCallback onRetry;
  const _WaitingOAuthView({required this.connectUrl, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(CupertinoIcons.arrow_up_right_square,
            size: 56, color: TallyColors.secondaryLabel),
        const SizedBox(height: 24),
        const Text(
          'Connecte ta banque',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: TallyColors.label),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Une fois autorisé, tu seras redirigé automatiquement.',
          style: TextStyle(fontSize: 15, color: TallyColors.secondaryLabel),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        FilledButton.icon(
          onPressed: () => launchUrl(Uri.parse(connectUrl),
              mode: LaunchMode.externalApplication),
          icon: const Icon(CupertinoIcons.arrow_up_right_square),
          label: const Text('Ouvrir Salt Edge'),
          style: FilledButton.styleFrom(
            minimumSize: const Size(220, 52),
            backgroundColor: TallyColors.systemBlue,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: onRetry,
          style:
              TextButton.styleFrom(foregroundColor: TallyColors.secondaryLabel),
          child: const Text('Recommencer', style: TextStyle(fontSize: 15)),
        ),
      ],
    );
  }
}

// ─── iOS-style text field ─────────────────────────────────────────────────────────────────────

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
