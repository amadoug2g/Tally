import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/saltedge_auth_repository.dart';
import '../../../transactions/data/datasources/saltedge_datasource.dart';

final saltEdgeDataSourceProvider =
    Provider<SaltEdgeDataSource>((_) => SaltEdgeDataSource());

final authRepositoryProvider = Provider<SaltEdgeAuthRepository>(
  (ref) => SaltEdgeAuthRepository(ref.read(saltEdgeDataSourceProvider)),
);

sealed class AuthState {}

class AuthInitial extends AuthState {}

class AuthAuthenticating extends AuthState {}

/// connect_url prêt — ouvrir dans le navigateur externe.
class AuthWaitingOAuth extends AuthState {
  final String connectUrl;
  AuthWaitingOAuth(this.connectUrl);
}

/// Deep link reçu — récupération du compte en cours.
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
  final SaltEdgeAuthRepository _repo;

  AuthNotifier(this._repo) : super(AuthInitial()) {
    _checkExistingConnection();
  }

  Future<void> _checkExistingConnection() async {
    if (await _repo.isConnected()) state = AuthConnected();
  }

  Future<void> connect(String appId, String secret) async {
    state = AuthAuthenticating();
    try {
      final connectUrl = await _repo.startConnect(appId, secret);
      state = AuthWaitingOAuth(connectUrl);
    } catch (e) {
      state = AuthError(_errorMessage(e));
    }
  }

  Future<void> handleDeepLink(String connectionId) async {
    state = AuthFetchingAccounts();
    try {
      await _repo.handleCallback(connectionId);
      state = AuthConnected();
    } catch (e) {
      state = AuthError(_errorMessage(e));
    }
  }

  void reset() => state = AuthInitial();

  String _errorMessage(Object e) {
    if (e is DioException && e.response != null) {
      final data = e.response!.data;
      final status = e.response!.statusCode;
      // Salt Edge wraps errors in {"error": {"class": "...", "message": "..."}}
      if (data is Map) {
        final err = data['error'] as Map?;
        if (err != null) {
          return '${err['class'] ?? status}: ${err['message'] ?? data}';
        }
      }
      return 'HTTP $status — ${e.response!.requestOptions.uri} — $data';
    }
    return e.toString();
  }
}
