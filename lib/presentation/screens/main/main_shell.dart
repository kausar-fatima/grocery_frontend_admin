import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../logic/admin/admin_cubit.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const MainShell({super.key, required this.navigationShell});

  void _go(int index) => navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      );

  @override
  Widget build(BuildContext context) {
    final i = navigationShell.currentIndex;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                    icon: Icons.dashboard_outlined,
                    active: Icons.dashboard_rounded,
                    label: 'Dashboard',
                    selected: i == 0,
                    onTap: () => _go(0)),
                _NavItem(
                    icon: Icons.people_outline_rounded,
                    active: Icons.people_rounded,
                    label: 'Users',
                    selected: i == 1,
                    onTap: () => _go(1),
                    badge: true),
                _NavItem(
                    icon: Icons.storefront_outlined,
                    active: Icons.storefront_rounded,
                    label: 'Stores',
                    selected: i == 2,
                    onTap: () => _go(2)),
                _NavItem(
                    icon: Icons.receipt_long_outlined,
                    active: Icons.receipt_long_rounded,
                    label: 'Orders',
                    selected: i == 3,
                    onTap: () => _go(3)),
                _NavItem(
                    icon: Icons.person_outline_rounded,
                    active: Icons.person_rounded,
                    label: 'Profile',
                    selected: i == 4,
                    onTap: () => _go(4)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData active;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool badge;

  const _NavItem({
    required this.icon,
    required this.active,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textTertiary;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(selected ? active : icon, color: color, size: 24),
                  if (badge) Positioned(right: -8, top: -6, child: _Badge()),
                ],
              ),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                      fontSize: 10.5,
                      color: color,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w400)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminCubit, AdminState>(
      buildWhen: (a, b) => a.pending.length != b.pending.length,
      builder: (context, state) {
        final count = state.pending.length;
        if (count == 0) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
          decoration: const BoxDecoration(
              color: AppColors.error, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text('$count',
              style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700)),
        );
      },
    );
  }
}
