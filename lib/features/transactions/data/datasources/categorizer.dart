import '../../domain/entities/transaction.dart';

class TransactionCategorizer {
  static const Map<String, TransactionType> _receiverTypeMap = {
    'krusty': TransactionType.eatingOut,
    'mcdonalds': TransactionType.eatingOut,
    'uber eats': TransactionType.eatingOut,
    'deliveroo': TransactionType.eatingOut,
    'leclerc': TransactionType.groceries,
    'carrefour': TransactionType.groceries,
    'franprix': TransactionType.groceries,
    'monoprix': TransactionType.groceries,
    'lidl': TransactionType.groceries,
    'aldi': TransactionType.groceries,
    'amazon': TransactionType.shopping,
    'showroom prive': TransactionType.shopping,
    'showroom privé': TransactionType.shopping,
    'google': TransactionType.utilities,
    'apple': TransactionType.utilities,
    'bouygues': TransactionType.utilities,
    'orange': TransactionType.utilities,
    'sfr': TransactionType.utilities,
    'evian': TransactionType.utilities,
    'disney': TransactionType.entertainment,
    'netflix': TransactionType.entertainment,
    'spotify': TransactionType.entertainment,
    'hetzner': TransactionType.utilities,
    'pyannote': TransactionType.utilities,
    'harmonie mutuelle': TransactionType.health,
    'mutuelle': TransactionType.health,
    'navigo': TransactionType.transport,
    'ratp': TransactionType.transport,
    'sncf': TransactionType.transport,
    'ile-de-france mobilités': TransactionType.transport,
  };

  static const Map<String, TransactionBucket> _typeBucketMap = {
    'eatingOut': TransactionBucket.life,
    'groceries': TransactionBucket.life,
    'shopping': TransactionBucket.life,
    'transport': TransactionBucket.bills,
    'utilities': TransactionBucket.bills,
    'entertainment': TransactionBucket.bills,
    'health': TransactionBucket.bills,
    'income': TransactionBucket.income,
    'fund': TransactionBucket.extra,
    'extra': TransactionBucket.extra,
  };

  static const Set<String> _fundKeywords = {'bills', 'buffer', 'vault', 'épargne', 'savings', 'virement compte dédié'};

  TransactionType categorizeType(String? receiver, String description) {
    final receiverLower = receiver?.toLowerCase() ?? '';
    final descLower = description.toLowerCase();

    // Check if it's a fund transfer (bucket allocation)
    for (final kw in _fundKeywords) {
      if (descLower.contains(kw) || receiverLower.contains(kw)) {
        return TransactionType.fund;
      }
    }

    // Match by receiver
    for (final entry in _receiverTypeMap.entries) {
      if (receiverLower.contains(entry.key) || descLower.contains(entry.key)) {
        return entry.value;
      }
    }

    return TransactionType.extra;
  }

  TransactionBucket categorizeBucket(TransactionType type, double amount) {
    if (amount > 0) return TransactionBucket.income;
    if (type == TransactionType.fund) return TransactionBucket.extra;
    return _typeBucketMap[type.name] ?? TransactionBucket.extra;
  }
}
