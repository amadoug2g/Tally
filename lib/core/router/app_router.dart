import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/connect_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/transactions/presentation/screens/transactions_screen.dart';
import '../../features/buckets/presentation/screens/buckets_screen.dart';
import '../../features/bills/presentation/screens/bills_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/onboarding',
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
