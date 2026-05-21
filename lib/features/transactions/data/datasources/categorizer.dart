import '../../domain/entities/transaction.dart';

class TransactionCategorizer {
  static const Map<String, TransactionType> _receiverTypeMap = {
    // Eating out
    'krusty': TransactionType.eatingOut,
    'mcdonald': TransactionType.eatingOut,
    'mcdo': TransactionType.eatingOut,
    'uber eats': TransactionType.eatingOut,
    'ubereats': TransactionType.eatingOut,
    'deliveroo': TransactionType.eatingOut,
    'just eat': TransactionType.eatingOut,
    'starbucks': TransactionType.eatingOut,
    'paul': TransactionType.eatingOut,
    'eric keyser': TransactionType.eatingOut,
    'maison gabestan': TransactionType.eatingOut,
    'clint sentier': TransactionType.eatingOut,
    'hôtel du sentier': TransactionType.eatingOut,
    'boulangerie': TransactionType.eatingOut,
    'restaurant': TransactionType.eatingOut,
    'cafe': TransactionType.eatingOut,
    'café': TransactionType.eatingOut,
    'sushi': TransactionType.eatingOut,
    'pizza': TransactionType.eatingOut,
    'burger': TransactionType.eatingOut,
    'bistro': TransactionType.eatingOut,
    'brasserie': TransactionType.eatingOut,
    'traiteur': TransactionType.eatingOut,

    // Groceries
    'leclerc': TransactionType.groceries,
    'e.leclerc': TransactionType.groceries,
    'carrefour': TransactionType.groceries,
    'franprix': TransactionType.groceries,
    'monoprix': TransactionType.groceries,
    'lidl': TransactionType.groceries,
    'aldi': TransactionType.groceries,
    'intermarché': TransactionType.groceries,
    'intermarch': TransactionType.groceries,
    'casino': TransactionType.groceries,
    'auchan': TransactionType.groceries,
    'super u': TransactionType.groceries,
    'picard': TransactionType.groceries,
    'bio c bon': TransactionType.groceries,
    'biocoop': TransactionType.groceries,
    'naturalia': TransactionType.groceries,
    'marché': TransactionType.groceries,

    // Shopping
    'amazon': TransactionType.shopping,
    'showroom prive': TransactionType.shopping,
    'showroom privé': TransactionType.shopping,
    'zara': TransactionType.shopping,
    'h&m': TransactionType.shopping,
    'mango': TransactionType.shopping,
    'asos': TransactionType.shopping,
    'la redoute': TransactionType.shopping,
    'decathlon': TransactionType.shopping,
    'ikea': TransactionType.shopping,
    'fnac': TransactionType.shopping,
    'darty': TransactionType.shopping,
    'boulanger': TransactionType.shopping,
    'cdiscount': TransactionType.shopping,
    'vinted': TransactionType.shopping,
    'leboncoin': TransactionType.shopping,
    'primark': TransactionType.shopping,
    'uniqlo': TransactionType.shopping,
    'nature et decouvertes': TransactionType.shopping,

    // Utilities / subscriptions
    'google': TransactionType.utilities,
    'apple': TransactionType.utilities,
    'bouygues': TransactionType.utilities,
    'orange': TransactionType.utilities,
    'sfr': TransactionType.utilities,
    'free': TransactionType.utilities,
    'prixtel': TransactionType.utilities,
    'evian': TransactionType.utilities,
    'hetzner': TransactionType.utilities,
    'pyannote': TransactionType.utilities,
    'ovh': TransactionType.utilities,
    'scaleway': TransactionType.utilities,
    'cloudflare': TransactionType.utilities,
    'edf': TransactionType.utilities,
    'engie': TransactionType.utilities,
    'veolia': TransactionType.utilities,
    'gaz de france': TransactionType.utilities,
    'total energies': TransactionType.utilities,

    // Entertainment
    'disney': TransactionType.entertainment,
    'netflix': TransactionType.entertainment,
    'spotify': TransactionType.entertainment,
    'prime video': TransactionType.entertainment,
    'canal+': TransactionType.entertainment,
    'canal plus': TransactionType.entertainment,
    'deezer': TransactionType.entertainment,
    'twitch': TransactionType.entertainment,
    'youtube': TransactionType.entertainment,
    'xbox': TransactionType.entertainment,
    'playstation': TransactionType.entertainment,
    'steam': TransactionType.entertainment,
    'apple tv': TransactionType.entertainment,

    // Health
    'harmonie mutuelle': TransactionType.health,
    'mutuelle': TransactionType.health,
    'doctolib': TransactionType.health,
    'pharmacie': TransactionType.health,
    'medecin': TransactionType.health,
    'médecin': TransactionType.health,
    'dentiste': TransactionType.health,
    'opticien': TransactionType.health,
    'kiné': TransactionType.health,
    'kinesitherapie': TransactionType.health,
    'hopital': TransactionType.health,
    'hôpital': TransactionType.health,
    'clinique': TransactionType.health,
    'cpam': TransactionType.health,
    'ameli': TransactionType.health,

    // Transport
    'navigo': TransactionType.transport,
    'ile-de-france mobilités': TransactionType.transport,
    'île-de-france mobilités': TransactionType.transport,
    'ratp': TransactionType.transport,
    'sncf': TransactionType.transport,
    'ouigo': TransactionType.transport,
    'thalys': TransactionType.transport,
    'eurostar': TransactionType.transport,
    'blablacar': TransactionType.transport,
    'uber': TransactionType.transport,
    'bolt': TransactionType.transport,
    'free2move': TransactionType.transport,
    'lime': TransactionType.transport,
    'bird': TransactionType.transport,
    'cityscoot': TransactionType.transport,
    'vélib': TransactionType.transport,
    'aeroport': TransactionType.transport,
    'aéroport': TransactionType.transport,
    'parking': TransactionType.transport,
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

  static const Set<String> _fundKeywords = {
    'bills', 'buffer', 'vault', 'épargne', 'savings',
    'virement compte dédié', 'to bills', 'to buffer', 'to vault',
    'pocket bills', 'pocket buffer', 'pocket vault',
  };

  static const Set<String> _incomeKeywords = {
    'salaire', 'salary', 'payroll', 'virement cash', 'virement entrant',
    'freelance', 'prime', 'revenu', 'honoraires', 'prestation',
    'remboursement employeur', 'aides', 'allocation', 'caf',
  };

  TransactionType categorizeType(String? receiver, String description) {
    final receiverLower = receiver?.toLowerCase() ?? '';
    final descLower = description.toLowerCase();

    // Fund transfer (bucket allocation) — check first
    for (final kw in _fundKeywords) {
      if (descLower.contains(kw) || receiverLower.contains(kw)) {
        return TransactionType.fund;
      }
    }

    // Income keywords
    for (final kw in _incomeKeywords) {
      if (descLower.contains(kw) || receiverLower.contains(kw)) {
        return TransactionType.income;
      }
    }

    // Receiver / description keyword match
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
