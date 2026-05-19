import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/connect_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/providers/bucket_config_provider.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/transactions/presentation/screens/transactions_screen.dart';
import '../../features/buckets/presentation/screens/buckets_screen.dart';
import '../../features/bills/presentation/screens/bills_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/onboarding',
    redirect: (context, state) async {
      final config = await ref.read(bucketConfigProvider.future);
      final isOnboarding = state.matchedLocation == '/onboarding';

      // Skip onboarding if already configured
      if (config != null && isOnboarding) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: '/connect', builder: (context, state) => const ConnectScreen()),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
        routes: [
          GoRoute(path: 'transactions', builder: (context, state) => const TransactionsScreen()),
          GoRoute(path: 'buckets', builder: (context, state) => const BucketsScreen()),
          GoRoute(path: 'bills', builder: (context, state) => const BillsScreen()),
        ],
      ),
    ],
  );
});
