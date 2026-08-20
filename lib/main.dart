import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'core/network/dio_client.dart';
import 'core/storage/token_storage.dart';
import 'core/theme/app_theme.dart';
import 'data/api/admin_api.dart';
import 'data/api/auth_api.dart';
import 'data/api/notifications_api.dart';
import 'data/api/promotions_api.dart';
import 'data/api/reviews_api.dart';
import 'logic/admin/admin_cubit.dart';
import 'logic/auth/auth_cubit.dart';
import 'logic/notifications/notifications_cubit.dart';
import 'logic/promotions/promotions_cubit.dart';
import 'routes/app_router.dart';
import 'core/config/api_config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ApiConfig.overrideBaseUrl = 'http://192.168.0.100:3000';
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  final tokenStorage = TokenStorage(const FlutterSecureStorage());
  final dio = DioClient(tokenStorage);

  final auth = AuthCubit(AuthApi(dio), tokenStorage);
  final admin = AdminCubit(AdminApi(dio), ReviewsApi(dio));
  final notifications = NotificationsCubit(NotificationsApi(dio));
  final promotions = PromotionsCubit(PromotionsApi(dio));

  runApp(AdminApp(
    auth: auth,
    admin: admin,
    notifications: notifications,
    promotions: promotions,
  ));
}

class AdminApp extends StatelessWidget {
  final AuthCubit auth;
  final AdminCubit admin;
  final NotificationsCubit notifications;
  final PromotionsCubit promotions;

  const AdminApp({
    super.key,
    required this.auth,
    required this.admin,
    required this.notifications,
    required this.promotions,
  });

  @override
  Widget build(BuildContext context) {
    final router = AppRouter(auth).router;
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: auth),
        BlocProvider.value(value: admin),
        BlocProvider.value(value: notifications),
        BlocProvider.value(value: promotions),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        listenWhen: (a, b) => a.status != b.status,
        listener: (context, state) {
          if (state.status == AuthStatus.authenticated) {
            admin.loadAll();
            notifications.attach();
          } else if (state.status == AuthStatus.unauthenticated) {
            notifications.detach();
          }
        },
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Admin — Healthy Mart',
          theme: AppTheme.lightTheme,
          routerConfig: router,
        ),
      ),
    );
  }
}
