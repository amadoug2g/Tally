class BucketConfig {
  final double monthlyIncome;
  final double lifeAmount;
  final double bufferAmount;
  final double vaultAmount;
  final double billsAmount;

  const BucketConfig({
    required this.monthlyIncome,
    required this.lifeAmount,
    required this.bufferAmount,
    required this.vaultAmount,
    required this.billsAmount,
  });

  double get lifePercent => monthlyIncome > 0 ? lifeAmount / monthlyIncome * 100 : 0;
  double get bufferPercent => monthlyIncome > 0 ? bufferAmount / monthlyIncome * 100 : 0;
  double get vaultPercent => monthlyIncome > 0 ? vaultAmount / monthlyIncome * 100 : 0;
  double get billsPercent => monthlyIncome > 0 ? billsAmount / monthlyIncome * 100 : 0;

  Map<String, dynamic> toJson() => {
        'monthlyIncome': monthlyIncome,
        'lifeAmount': lifeAmount,
        'bufferAmount': bufferAmount,
        'vaultAmount': vaultAmount,
        'billsAmount': billsAmount,
      };

  factory BucketConfig.fromJson(Map<String, dynamic> json) => BucketConfig(
        monthlyIncome: (json['monthlyIncome'] as num).toDouble(),
        lifeAmount: (json['lifeAmount'] as num).toDouble(),
        bufferAmount: (json['bufferAmount'] as num).toDouble(),
        vaultAmount: (json['vaultAmount'] as num).toDouble(),
        billsAmount: (json['billsAmount'] as num).toDouble(),
      );
}
