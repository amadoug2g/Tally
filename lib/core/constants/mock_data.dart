import '../../../features/transactions/domain/entities/transaction.dart';

const bool kMockMode = false;

final List<Transaction> mockTransactions = [
  Transaction(
    id: '1', date: DateTime(2026, 5, 1), amount: -250.00,
    description: 'Bills', receiver: 'Me', type: TransactionType.fund, bucket: TransactionBucket.bills,
  ),
  Transaction(
    id: '2', date: DateTime(2026, 5, 1), amount: -335.00,
    description: 'Buffer', receiver: 'Me', type: TransactionType.fund, bucket: TransactionBucket.buffer,
  ),
  Transaction(
    id: '3', date: DateTime(2026, 5, 1), amount: -224.27,
    description: 'Vault', receiver: 'Me', type: TransactionType.fund, bucket: TransactionBucket.vault,
  ),
  Transaction(
    id: '4', date: DateTime(2026, 5, 2), amount: -2.50,
    description: 'Boulangerie', receiver: 'Maison Gabestan', type: TransactionType.eatingOut, bucket: TransactionBucket.life,
  ),
  Transaction(
    id: '5', date: DateTime(2026, 5, 2), amount: -10.00,
    description: 'Déjeuner', receiver: 'Krusty', type: TransactionType.eatingOut, bucket: TransactionBucket.life,
  ),
  Transaction(
    id: '6', date: DateTime(2026, 5, 3), amount: -112.59,
    description: 'Online Shopping', receiver: 'Showroom Privé', type: TransactionType.shopping, bucket: TransactionBucket.life,
  ),
  Transaction(
    id: '7', date: DateTime(2026, 5, 3), amount: -43.59,
    description: 'Courses', receiver: 'E. Leclerc', type: TransactionType.groceries, bucket: TransactionBucket.life,
  ),
  Transaction(
    id: '8', date: DateTime(2026, 5, 4), amount: -107.65,
    description: 'Online Shopping', receiver: 'Showroom Privé', type: TransactionType.shopping, bucket: TransactionBucket.life,
  ),
  Transaction(
    id: '9', date: DateTime(2026, 5, 5), amount: -18.25,
    description: 'Petit Déjeuner', receiver: 'Clint Sentier', type: TransactionType.eatingOut, bucket: TransactionBucket.life,
  ),
  Transaction(
    id: '10', date: DateTime(2026, 5, 8), amount: -19.74,
    description: 'Courses', receiver: 'Franprix', type: TransactionType.groceries, bucket: TransactionBucket.life,
  ),
  Transaction(
    id: '11', date: DateTime(2026, 5, 1), amount: -6.90,
    description: 'Google Workspace', receiver: 'Google', type: TransactionType.utilities, bucket: TransactionBucket.bills,
  ),
  Transaction(
    id: '12', date: DateTime(2026, 5, 3), amount: -6.99,
    description: 'Disney+', receiver: 'Disney+', type: TransactionType.entertainment, bucket: TransactionBucket.bills,
  ),
  Transaction(
    id: '13', date: DateTime(2026, 5, 5), amount: -1.06,
    description: 'Hetzner', receiver: 'Hetzner', type: TransactionType.utilities, bucket: TransactionBucket.bills,
  ),
  Transaction(
    id: '14', date: DateTime(2026, 5, 7), amount: -34.74,
    description: 'Evian', receiver: 'Evian', type: TransactionType.utilities, bucket: TransactionBucket.bills,
  ),
  Transaction(
    id: '15', date: DateTime(2026, 5, 14), amount: -2.99,
    description: 'iCloud', receiver: 'Apple', type: TransactionType.utilities, bucket: TransactionBucket.bills,
  ),
  Transaction(
    id: '16', date: DateTime(2026, 5, 15), amount: -52.49,
    description: 'Harmonie Mutuelle', receiver: 'Harmonie Mutuelle', type: TransactionType.health, bucket: TransactionBucket.bills,
  ),
  Transaction(
    id: '17', date: DateTime(2026, 5, 17), amount: -16.99,
    description: 'Bouygues Telecom', receiver: 'Bouygues Telecom', type: TransactionType.utilities, bucket: TransactionBucket.bills,
  ),
  Transaction(
    id: '18', date: DateTime(2026, 5, 20), amount: -73.08,
    description: 'Navigo Liberté+', receiver: 'Île-de-France Mobilités', type: TransactionType.transport, bucket: TransactionBucket.bills,
  ),
  Transaction(
    id: '19', date: DateTime(2026, 5, 2), amount: 100.00,
    description: 'Virement Cash', receiver: 'Me', type: TransactionType.income, bucket: TransactionBucket.income,
  ),
  Transaction(
    id: '20', date: DateTime(2026, 5, 4), amount: 75.00,
    description: 'Virement Cash', receiver: 'Me', type: TransactionType.income, bucket: TransactionBucket.income,
  ),
];
