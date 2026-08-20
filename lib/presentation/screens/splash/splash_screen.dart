import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../logic/auth/auth_cubit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthCubit>().loadSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(26),
              decoration: const BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
              ),
              child: const Text('🛡️', style: TextStyle(fontSize: 52)),
            ),
            const SizedBox(height: 22),
            Text('Admin Console',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.white, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text('Healthy Mart Management',
                style: TextStyle(color: AppColors.white.withValues(alpha: 0.9))),
            const SizedBox(height: 36),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation(AppColors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
