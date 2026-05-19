import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/bucket_config_repository.dart';
import '../../domain/entities/bucket_config.dart';

final bucketConfigRepositoryProvider = Provider<BucketConfigRepository>((_) => BucketConfigRepository());

final bucketConfigProvider = AsyncNotifierProvider<BucketConfigNotifier, BucketConfig?>(BucketConfigNotifier.new);

class BucketConfigNotifier extends AsyncNotifier<BucketConfig?> {
  BucketConfigRepository get _repo => ref.read(bucketConfigRepositoryProvider);

  @override
  Future<BucketConfig?> build() => _repo.load();

  Future<void> save(BucketConfig config) async {
    await _repo.save(config);
    state = AsyncData(config);
  }

  Future<void> clear() async {
    await _repo.clear();
    state = const AsyncData(null);
  }
}
