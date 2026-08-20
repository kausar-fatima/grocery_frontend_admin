import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../logic/notifications/notifications_cubit.dart';
import '../../routes/app_routes.dart';

/// A bell icon with an unread-count badge that opens the notifications screen.
///
/// [boxed] renders the customer-home style rounded square; otherwise a plain
/// app-bar icon button.
class NotificationBell extends StatelessWidget {
  final bool boxed;
  const NotificationBell({super.key, this.boxed = false});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsCubit, NotificationsState>(
      buildWhen: (a, b) => a.unread != b.unread,
      builder: (context, state) {
        final badge = state.unread > 0
            ? Positioned(
                right: boxed ? 4 : 6,
                top: boxed ? 4 : 6,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  constraints:
                      const BoxConstraints(minWidth: 16, minHeight: 16),
                  decoration: const BoxDecoration(
                      color: AppColors.error, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Text(
                    state.unread > 9 ? '9+' : '${state.unread}',
                    style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              )
            : const SizedBox.shrink();

        final child = boxed
            ? Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(Icons.notifications_none_rounded,
                    color: AppColors.textPrimary),
              )
            : const Padding(
                padding: EdgeInsets.all(12),
                child: Icon(Icons.notifications_none_rounded),
              );

        return InkWell(
          onTap: () => context.push(AppRoutes.notifications),
          borderRadius: BorderRadius.circular(boxed ? 14 : 24),
          child: Stack(clipBehavior: Clip.none, children: [child, badge]),
        );
      },
    );
  }
}
