import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../logic/auth/auth_cubit.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/dashboard/dashboard_screen.dart';
import '../presentation/screens/main/main_shell.dart';
import '../presentation/screens/notifications/notifications_screen.dart';
import '../presentation/screens/orders/orders_screen.dart';
import '../presentation/screens/profile/profile_screen.dart';
import '../presentation/screens/promotions/promotions_screen.dart';
import '../presentation/screens/reviews/reviews_screen.dart';
import '../presentation/screens/stores/stores_screen.dart';
import '../presentation/screens/users/users_screen.dart';
import '../presentation/screens/splash/splash_screen.dart';
import 'app_routes.dart';

class AppRouter {
  AppRouter(this._auth);
  final AuthCubit _auth;

  final _rootKey = GlobalKey<NavigatorState>();

  late final GoRouter router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: GoRouterRefreshStream(_auth.stream),
    redirect: _redirect,
    routes: _routes,
  );

  String? _redirect(BuildContext context, GoRouterState state) {
    final status = _auth.state.status;
    final loc = state.matchedLocation;
    final atSplash = loc == AppRoutes.splash;
    if (status == AuthStatus.unknown) return atSplash ? null : AppRoutes.splash;
    final loggedIn = status == AuthStatus.authenticated;
    final atLogin = loc == AppRoutes.login;
    if (!loggedIn) return atLogin ? null : AppRoutes.login;
    if (atSplash || atLogin) return AppRoutes.dashboard;
    return null;
  }

  List<RouteBase> get _routes => [
        GoRoute(path: AppRoutes.splash, builder: (_, _) => const SplashScreen()),
        GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginScreen()),
        StatefulShellRoute.indexedStack(
          parentNavigatorKey: _rootKey,
          builder: (_, _, shell) => MainShell(navigationShell: shell),
          branches: [
            StatefulShellBranch(routes: [
              GoRoute(
                  path: AppRoutes.dashboard,
                  builder: (_, _) => const DashboardScreen()),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                  path: AppRoutes.users,
                  builder: (_, _) => const UsersScreen()),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                  path: AppRoutes.stores,
                  builder: (_, _) => const StoresScreen()),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                  path: AppRoutes.orders,
                  builder: (_, _) => const OrdersScreen()),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                  path: AppRoutes.profile,
                  builder: (_, _) => const ProfileScreen()),
            ]),
          ],
        ),
        GoRoute(
          path: AppRoutes.reviews,
          parentNavigatorKey: _rootKey,
          builder: (_, _) => const ReviewsScreen(),
        ),
        GoRoute(
          path: AppRoutes.notifications,
          parentNavigatorKey: _rootKey,
          builder: (_, _) => const NotificationsScreen(),
        ),
        GoRoute(
          path: AppRoutes.promotions,
          parentNavigatorKey: _rootKey,
          builder: (_, _) => const PromotionsScreen(),
        ),
      ];
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _sub;
  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
