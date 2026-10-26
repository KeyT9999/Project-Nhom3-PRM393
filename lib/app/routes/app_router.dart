import 'package:go_router/go_router.dart';

import '../app.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/orders/order_detail_screen.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) =>
            SplashScreen(onContinue: () => context.go('/')),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const SmartStoreMainShell(),
      ),
      GoRoute(
        path: '/orders/:id',
        builder: (context, state) =>
            OrderDetailScreen(orderId: state.pathParameters['id']!),
      ),
    ],
  );
}
