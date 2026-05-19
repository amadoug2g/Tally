import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/bucket_config.dart';
import '../../../../core/constants/app_constants.dart';

class BucketConfigRepository {
  static const _key = AppConstants.keyBucketConfig;

  Future<BucketConfig?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json == null) return null;
    return BucketConfig.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  Future<void> save(BucketConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(config.toJson()));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
