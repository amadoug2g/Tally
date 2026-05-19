import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/gocardless_auth_repository.dart';
import '../../../transactions/data/datasources/gocardless_datasource.dart';
import '../../../../core/constants/app_constants.dart';

final gocardlessDatasourceProvider = Provider<GoCardlessDataSource>((_) => GoCardlessDataSource());

final authRepositoryProvider = Provider<GoCardlessAuthRepository>(
  (ref) => GoCardlessAuthRepository(ref.read(gocardlessDatasourceProvider)),
);

sealed class AuthState {}
class AuthInitial extends AuthState {}
class AuthAuthenticating extends AuthState {}
class AuthWaitingOAuth extends AuthState {
  final String link;
  AuthWaitingOAuth(this.link);
}
class AuthFetchingAccounts extends AuthState {}
class AuthConnected extends AuthState {}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref.read(authRepositoryProvider)),
);

class AuthNotifier extends StateNotifier<AuthState> {
  final GoCardlessAuthRepository _repo;

  AuthNotifier(this._repo) : super(AuthInitial()) {
    _checkExistingConnection();
  }

  Future<void> _checkExistingConnection() async {
    if (await _repo.isConnected()) {
      state = AuthConnected();
    }
  }

  Future<void> connect(String secretId, String secretKey) async {
    state = AuthAuthenticating();
    try {
      final tokens = await _repo.authenticate(secretId, secretKey);
      final link = await _repo.createRequisitionLink(
        tokens.accessToken,
        AppConstants.revoltInstitutionId,
      );
      state = AuthWaitingOAuth(link);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> handleOAuthCallback() async {
    state = AuthFetchingAccounts();
    try {
      final token = await _repo.getStoredAccessToken();
      final requisitionId = await _repo.getStoredRequisitionId();
      if (token == null || requisitionId == null) {
        state = AuthError('Session expirée. Recommence la connexion.');
        return;
      }
      final accountId = await _repo.getLinkedAccountId(token, requisitionId);
      if (accountId == null) {
        state = AuthError('Aucun compte trouvé. Vérifie que tu as bien autorisé Revolut.');
        return;
      }
      state = AuthConnected();
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  void reset() => state = AuthInitial();
}
