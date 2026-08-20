import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/admin_stats.dart';
import '../../../data/models/order.dart';
import '../../../logic/admin/admin_cubit.dart';
import '../../../logic/promotions/promotions_cubit.dart';
import '../../../routes/app_routes.dart';
import '../../widgets/error_view.dart';
import '../../widgets/notification_bell.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          const NotificationBell(),
          IconButton(
            onPressed: () => context.read<AdminCubit>().loadStats(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: BlocBuilder<AdminCubit, AdminState>(
          builder: (context, state) {
            if (state.statsStatus == Load.loading ||
                state.statsStatus == Load.initial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.statsStatus == Load.error || state.stats == null) {
              return ErrorView(
                message: state.error ?? 'Could not load stats.',
                onRetry: () => context.read<AdminCubit>().loadStats(),
              );
            }
            final s = state.stats!;
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => context.read<AdminCubit>().loadStats(),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  _revenueCard(s),
                  const SizedBox(height: 16),
                  _statsGrid(s),
                  if (s.pendingApprovals > 0) ...[
                    const SizedBox(height: 16),
                    _pendingCard(context, s.pendingApprovals),
                  ],
                  const SizedBox(height: 20),
                  _sectionRow(context, 'Orders by status'),
                  const SizedBox(height: 8),
                  _statusBreakdown(s),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Recent orders',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 16)),
                      TextButton(
                        onPressed: () => context.go(AppRoutes.orders),
                        child: const Text('View all'),
                      ),
                    ],
                  ),
                  ...s.recentOrders.take(6).map((o) => _orderRow(o)),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () {
                      context.read<AdminCubit>().loadReviews();
                      context.push(AppRoutes.reviews);
                    },
                    icon: const Icon(Icons.reviews_outlined),
                    label: Text('Moderate reviews (${s.totalReviews})'),
                    style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50)),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      context.read<PromotionsCubit>().load();
                      context.push(AppRoutes.promotions);
                    },
                    icon: const Icon(Icons.local_offer_outlined),
                    label: const Text('Manage promotions'),
                    style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50)),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _revenueCard(AdminStats s) => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Platform revenue',
                      style: TextStyle(
                          color: AppColors.white.withValues(alpha: 0.9),
                          fontSize: 13)),
                  const SizedBox(height: 6),
                  Text('\$${s.revenue.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w700)),
                  Text('${s.totalOrders} orders',
                      style: TextStyle(
                          color: AppColors.white.withValues(alpha: 0.9),
                          fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.trending_up_rounded,
                color: AppColors.white, size: 40),
          ],
        ),
      );

  Widget _statsGrid(AdminStats s) {
    final items = [
      _Stat(Icons.people_rounded, 'Users', '${s.totalUsers}', AppColors.info),
      _Stat(Icons.storefront_rounded, 'Stores', '${s.totalStores}',
          AppColors.primary),
      _Stat(Icons.inventory_2_rounded, 'Products', '${s.totalProducts}',
          AppColors.warning),
      _Stat(Icons.two_wheeler_rounded, 'Riders', '${s.riders}',
          AppColors.accent),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: items
          .map((i) => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: i.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(i.icon, color: i.color, size: 20),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(i.value,
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w700)),
                        Text(i.label,
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _pendingCard(BuildContext context, int count) => GestureDetector(
        onTap: () => context.go(AppRoutes.users),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              const Icon(Icons.pending_actions_rounded,
                  color: AppColors.warning),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '$count partner${count == 1 ? '' : 's'} awaiting approval',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.warning),
            ],
          ),
        ),
      );

  Widget _sectionRow(BuildContext context, String title) => Text(title,
      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16));

  Widget _statusBreakdown(AdminStats s) {
    if (s.ordersByStatus.isEmpty) {
      return const Text('No orders yet.',
          style: TextStyle(color: AppColors.textSecondary));
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: s.ordersByStatus.entries
            .map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(OrderStatusX.parse(e.key).label,
                          style: const TextStyle(
                              color: AppColors.textSecondary)),
                      Text('${e.value}',
                          style:
                              const TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _orderRow(Order o) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.receipt_long_outlined,
                  color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order #${o.id} · ${o.customer?.name ?? 'Customer'}',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    o.createdAt != null
                        ? DateFormat('MMM d, HH:mm').format(o.createdAt!)
                        : o.status.label,
                    style: const TextStyle(
                        color: AppColors.textTertiary, fontSize: 12),
                  ),
                ],
              ),
            ),
            Text('\$${o.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontWeight: FontWeight.w700, color: AppColors.primary)),
          ],
        ),
      );
}

class _Stat {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  _Stat(this.icon, this.label, this.value, this.color);
}
