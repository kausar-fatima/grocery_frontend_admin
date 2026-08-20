import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/review.dart';
import '../../../logic/admin/admin_cubit.dart';
import '../../widgets/error_view.dart';

class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reviews'),
        leading: BackButton(onPressed: () => context.pop()),
        actions: [
          IconButton(
            onPressed: () => context.read<AdminCubit>().loadReviews(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: BlocBuilder<AdminCubit, AdminState>(
          builder: (context, state) {
            if (state.reviewsStatus == Load.loading ||
                state.reviewsStatus == Load.initial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.reviewsStatus == Load.error) {
              return ErrorView(
                message: state.error ?? 'Could not load reviews.',
                onRetry: () => context.read<AdminCubit>().loadReviews(),
              );
            }
            if (state.reviews.isEmpty) {
              return const Center(
                child: Text('No reviews yet.',
                    style: TextStyle(color: AppColors.textSecondary)),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: state.reviews.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _ReviewTile(review: state.reviews[i]),
            );
          },
        ),
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final Review review;
  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(review.userName,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < review.rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 16,
                    color: AppColors.warning,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _confirmDelete(context),
                icon: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.error, size: 20),
              ),
            ],
          ),
          if (review.comment.isNotEmpty)
            Text(review.comment,
                style: const TextStyle(color: AppColors.textSecondary)),
          if (review.productId != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('Product #${review.productId}',
                  style: const TextStyle(
                      color: AppColors.textTertiary, fontSize: 11)),
            ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final cubit = context.read<AdminCubit>();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete review?'),
        content: const Text('This review will be permanently removed.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              cubit.deleteReview(review.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
