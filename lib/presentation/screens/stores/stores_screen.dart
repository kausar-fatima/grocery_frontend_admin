import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../logic/admin/admin_cubit.dart';
import '../../widgets/error_view.dart';

class StoresScreen extends StatefulWidget {
  const StoresScreen({super.key});

  @override
  State<StoresScreen> createState() => _StoresScreenState();
}

class _StoresScreenState extends State<StoresScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<AdminCubit>().state.storesStatus == Load.initial) {
        context.read<AdminCubit>().loadStores();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stores'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => context.read<AdminCubit>().loadStores(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: BlocBuilder<AdminCubit, AdminState>(
          builder: (context, state) {
            if (state.storesStatus == Load.loading ||
                state.storesStatus == Load.initial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.storesStatus == Load.error) {
              return ErrorView(
                message: state.error ?? 'Could not load stores.',
                onRetry: () => context.read<AdminCubit>().loadStores(),
              );
            }
            if (state.stores.isEmpty) {
              return const Center(
                child: Text('No stores yet.',
                    style: TextStyle(color: AppColors.textSecondary)),
              );
            }
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => context.read<AdminCubit>().loadStores(),
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                itemCount: state.stores.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final s = state.stores[i];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: const Text('🏪',
                              style: TextStyle(fontSize: 24)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15)),
                              Text(s.address,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12)),
                              if (s.ownerName != null)
                                Text('Owner: ${s.ownerName}',
                                    style: const TextStyle(
                                        color: AppColors.textTertiary,
                                        fontSize: 11)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: (s.isActive
                                    ? AppColors.primary
                                    : AppColors.textTertiary)
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(s.isActive ? 'Active' : 'Inactive',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: s.isActive
                                      ? AppColors.primary
                                      : AppColors.textTertiary)),
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
