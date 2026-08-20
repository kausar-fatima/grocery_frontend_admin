import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/app_user.dart';
import '../../../logic/admin/admin_cubit.dart';
import '../../widgets/error_view.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  String _filter = 'ALL';

  static const _filters = {
    'ALL': 'All',
    'PENDING': 'Pending',
    'CUSTOMER': 'Customers',
    'STORE_OWNER': 'Owners',
    'RIDER': 'Riders',
  };

  List<AppUser> _apply(List<AppUser> users) {
    switch (_filter) {
      case 'PENDING':
        return users
            .where((u) => !u.isApproved && u.role != 'CUSTOMER')
            .toList();
      case 'ALL':
        return users;
      default:
        return users.where((u) => u.role == _filter).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => context.read<AdminCubit>().loadUsers(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            SizedBox(
              height: 46,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                children: _filters.entries.map((e) {
                  final selected = _filter == e.key;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(e.value),
                      selected: selected,
                      onSelected: (_) => setState(() => _filter = e.key),
                      labelStyle: TextStyle(
                        color:
                            selected ? AppColors.white : AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      showCheckmark: false,
                    ),
                  );
                }).toList(),
              ),
            ),
            Expanded(
              child: BlocBuilder<AdminCubit, AdminState>(
                builder: (context, state) {
                  if (state.usersStatus == Load.loading ||
                      state.usersStatus == Load.initial) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.usersStatus == Load.error) {
                    return ErrorView(
                      message: state.error ?? 'Could not load users.',
                      onRetry: () => context.read<AdminCubit>().loadUsers(),
                    );
                  }
                  final users = _apply(state.users);
                  if (users.isEmpty) {
                    return const Center(
                      child: Text('No users in this view.',
                          style: TextStyle(color: AppColors.textSecondary)),
                    );
                  }
                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () => context.read<AdminCubit>().loadUsers(),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: users.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => _UserTile(user: users[i]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final AppUser user;
  const _UserTile({required this.user});

  Color get _roleColor => switch (user.role) {
        'ADMIN' => AppColors.error,
        'STORE_OWNER' => AppColors.info,
        'RIDER' => AppColors.warning,
        _ => AppColors.primary,
      };

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AdminCubit>();
    final canApprove = user.role != 'CUSTOMER' && user.role != 'ADMIN';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: _roleColor.withValues(alpha: 0.15),
            child: Text(
              user.username.isNotEmpty ? user.username[0].toUpperCase() : '?',
              style: TextStyle(color: _roleColor, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(user.username,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _roleColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(user.role,
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: _roleColor)),
                    ),
                  ],
                ),
                Text(user.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppColors.textTertiary, fontSize: 12)),
                if (canApprove)
                  Text(user.isApproved ? 'Approved' : 'Pending approval',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: user.isApproved
                              ? AppColors.primary
                              : AppColors.warning)),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
            onSelected: (v) {
              switch (v) {
                case 'approve':
                  cubit.approve(user.id, true);
                  break;
                case 'revoke':
                  cubit.approve(user.id, false);
                  break;
                case 'delete':
                  _confirmDelete(context, cubit);
                  break;
              }
            },
            itemBuilder: (_) => [
              if (canApprove && !user.isApproved)
                const PopupMenuItem(value: 'approve', child: Text('Approve')),
              if (canApprove && user.isApproved)
                const PopupMenuItem(value: 'revoke', child: Text('Revoke')),
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, AdminCubit cubit) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete user?'),
        content: Text('Permanently remove ${user.username}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              cubit.deleteUser(user.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
