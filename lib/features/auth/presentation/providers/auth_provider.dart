import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/plaid_auth_repository.dart';
import '../../../transactions/data/datasources/plaid_datasource.dart';

final plaidDataSourceProvider =
    Provider<PlaidDataSource>((_) => PlaidDataSource());

final authRepositoryProvider = Provider<PlaidAuthRepository>(
  (ref) => PlaidAuthRepository(ref.read(plaidDataSourceProvider)),
);

sealed class AuthState {}

class AuthInitial extends AuthState {}

class AuthAuthenticating extends AuthState {}

/// link_token prêt — déclenche l'ouverture du SDK Plaid Link natif.
class AuthLinkReady extends AuthState {
  final String linkToken;
  AuthLinkReady(this.linkToken);
}

/// Échange du public_token en cours.
class AuthConnecting extends AuthState {}

class AuthConnected extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref.read(authRepositoryProvider)),
);

class AuthNotifier extends StateNotifier<AuthState> {
  final PlaidAuthRepository _repo;

  AuthNotifier(this._repo) : super(AuthInitial()) {
    _checkExistingConnection();
  }

  Future<void> _checkExistingConnection() async {
    if (await _repo.isConnected()) {
      state = AuthConnected();
    }
  }

  Future<void> connect(String clientId, String secret) async {
    state = AuthAuthenticating();
    try {
      final linkToken = await _repo.createLinkToken(clientId, secret);
      state = AuthLinkReady(linkToken);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> handlePlaidSuccess(String publicToken) async {
    state = AuthConnecting();
    try {
      await _repo.exchangePublicToken(publicToken);
      state = AuthConnected();
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  void reset() => state = AuthInitial();
}
