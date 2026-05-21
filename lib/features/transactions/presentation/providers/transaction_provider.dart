import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/mock_data.dart';
import '../../data/datasources/categorizer.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../domain/entities/transaction.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final _categorizerProvider = Provider<TransactionCategorizer>(
  (_) => TransactionCategorizer(),
);

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository(
    ref.read(plaidDataSourceProvider),
    ref.read(_categorizerProvider),
  );
});

/// Loads transactions for the current month.
/// In mock mode: returns hardcoded data.
/// In real mode: fetches from Plaid.
final transactionsProvider =
    AsyncNotifierProvider<_TransactionsNotifier, List<Transaction>>(
  _TransactionsNotifier.new,
);

class _TransactionsNotifier extends AsyncNotifier<List<Transaction>> {
  @override
  Future<List<Transaction>> build() async {
    if (kMockMode) return mockTransactions;
    final repo = ref.read(transactionRepositoryProvider);
    return repo.fetchMonthlyTransactions();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => kMockMode
          ? Future.value(mockTransactions)
          : ref.read(transactionRepositoryProvider).fetchMonthlyTransactions(),
    );
  }
}

/// Current balance. Null if not connected or unavailable.
final balanceProvider = FutureProvider<double?>((ref) async {
  if (kMockMode) return 1_367.27;
  final repo = ref.read(transactionRepositoryProvider);
  return repo.fetchBalance();
});
