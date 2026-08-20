import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/order.dart';
import '../../../logic/admin/admin_cubit.dart';
import '../../widgets/error_view.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<AdminCubit>().state.ordersStatus == Load.initial) {
        context.read<AdminCubit>().loadOrders();
      }
    });
  }

  Color _color(OrderStatus s) => switch (s) {
        OrderStatus.delivered => AppColors.primary,
        OrderStatus.cancelled => AppColors.error,
        OrderStatus.ready ||
        OrderStatus.pickedUp ||
        OrderStatus.onTheWay =>
          AppColors.info,
        _ => AppColors.warning,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Orders'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => context.read<AdminCubit>().loadOrders(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: BlocBuilder<AdminCubit, AdminState>(
          builder: (context, state) {
            if (state.ordersStatus == Load.loading ||
                state.ordersStatus == Load.initial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.ordersStatus == Load.error) {
              return ErrorView(
                message: state.error ?? 'Could not load orders.',
                onRetry: () => context.read<AdminCubit>().loadOrders(),
              );
            }
            if (state.orders.isEmpty) {
              return const Center(
                child: Text('No orders yet.',
                    style: TextStyle(color: AppColors.textSecondary)),
              );
            }
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => context.read<AdminCubit>().loadOrders(),
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                itemCount: state.orders.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final o = state.orders[i];
                  final color = _color(o.status);
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Order #${o.id}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700)),
                              Text(
                                '${o.customer?.name ?? 'Customer'} · ${o.itemCount} items'
                                '${o.createdAt != null ? ' · ${DateFormat('MMM d').format(o.createdAt!)}' : ''}',
                                style: const TextStyle(
                                    color: AppColors.textTertiary,
                                    fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('\$${o.totalAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary)),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(o.status.label,
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: color)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
