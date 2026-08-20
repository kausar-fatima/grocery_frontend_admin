import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/promotion.dart';
import '../../../logic/promotions/promotions_cubit.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/error_view.dart';
import '../../widgets/primary_button.dart';

/// Admin screen to create, edit, toggle and delete promotional discounts.
/// The newest active promotion drives the customer home banner and is applied
/// to the cart subtotal at checkout.
class PromotionsScreen extends StatefulWidget {
  const PromotionsScreen({super.key});

  @override
  State<PromotionsScreen> createState() => _PromotionsScreenState();
}

class _PromotionsScreenState extends State<PromotionsScreen> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<PromotionsCubit>();
    if (cubit.state.status == PromoLoad.initial) cubit.load();
  }

  Future<void> _openForm({Promotion? existing}) =>
      _PromotionForm.show(context, existing: existing);

  Future<void> _delete(Promotion p) async {
    final cubit = context.read<PromotionsCubit>();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete promotion?'),
        content: Text('Remove "${p.title}"? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) cubit.remove(p.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Promotions'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('New promotion'),
      ),
      body: SafeArea(
        top: false,
        child: BlocBuilder<PromotionsCubit, PromotionsState>(
          builder: (context, state) {
            if (state.status == PromoLoad.loading ||
                state.status == PromoLoad.initial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == PromoLoad.error) {
              return ErrorView(
                message: state.error ?? 'Could not load promotions.',
                onRetry: () => context.read<PromotionsCubit>().load(),
              );
            }
            if (state.items.isEmpty) {
              return _empty(context);
            }
            return RefreshIndicator(
              onRefresh: () => context.read<PromotionsCubit>().load(),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
                children: [
                  const Text(
                    'The newest ACTIVE promotion is shown on the customer home banner and applied automatically at checkout.',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  for (final p in state.items)
                    _PromoCard(
                      promo: p,
                      onToggle: () =>
                          context.read<PromotionsCubit>().toggleActive(p),
                      onEdit: () => _openForm(existing: p),
                      onDelete: () => _delete(p),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _empty(BuildContext context) => ListView(
        children: [
          const SizedBox(height: 120),
          const Icon(Icons.local_offer_outlined,
              size: 56, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          const Center(
            child: Text('No promotions yet',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          ),
          const SizedBox(height: 6),
          const Center(
            child: Text('Create one to run a discount for customers.',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
        ],
      );
}

class _PromoCard extends StatelessWidget {
  final Promotion promo;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PromoCard({
    required this.promo,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: promo.active ? AppColors.primary : AppColors.border,
          width: promo.active ? 1.4 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('${promo.discountPercent}%',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(promo.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                    if (promo.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(promo.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ],
                ),
              ),
              Switch.adaptive(
                value: promo.active,
                activeThumbColor: AppColors.primary,
                onChanged: (_) => onToggle(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _chip(promo.active ? 'Active' : 'Inactive',
                  promo.active ? AppColors.primary : AppColors.textTertiary),
              if (promo.firstOrderOnly) _chip('First order only', AppColors.info),
              if (promo.minSubtotal > 0)
                _chip('Min \$${promo.minSubtotal.toStringAsFixed(0)}',
                    AppColors.warning),
            ],
          ),
          const Divider(height: 22),
          Row(
            children: [
              const Spacer(),
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit'),
              ),
              TextButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Delete'),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(text,
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700, color: color)),
      );
}

class _PromotionForm extends StatefulWidget {
  final Promotion? existing;
  const _PromotionForm({this.existing});

  static Future<void> show(BuildContext context, {Promotion? existing}) {
    final cubit = context.read<PromotionsCubit>();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: _PromotionForm(existing: existing),
      ),
    );
  }

  @override
  State<_PromotionForm> createState() => _PromotionFormState();
}

class _PromotionFormState extends State<_PromotionForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _percent;
  late final TextEditingController _minSubtotal;
  late bool _active;
  late bool _firstOrderOnly;
  bool _saving = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    _title = TextEditingController(text: p?.title ?? '');
    _description = TextEditingController(text: p?.description ?? '');
    _percent = TextEditingController(
        text: p == null ? '' : p.discountPercent.toString());
    _minSubtotal = TextEditingController(
        text: p == null || p.minSubtotal == 0
            ? ''
            : p.minSubtotal.toStringAsFixed(0));
    _active = p?.active ?? true;
    _firstOrderOnly = p?.firstOrderOnly ?? false;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _percent.dispose();
    _minSubtotal.dispose();
    super.dispose();
  }

  String? _requiredText(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;

  String? _percentValidator(String? v) {
    final n = int.tryParse((v ?? '').trim());
    if (n == null) return 'Enter a number';
    if (n < 1 || n > 100) return '1–100';
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final cubit = context.read<PromotionsCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final body = <String, dynamic>{
      'title': _title.text.trim(),
      'description': _description.text.trim(),
      'discountPercent': int.parse(_percent.text.trim()),
      'active': _active,
      'firstOrderOnly': _firstOrderOnly,
      'minSubtotal': double.tryParse(_minSubtotal.text.trim()) ?? 0,
    };

    setState(() => _saving = true);
    final ok = _isEdit
        ? await cubit.update(widget.existing!.id, body)
        : await cubit.create(body);
    if (!mounted) return;
    setState(() => _saving = false);

    if (ok) {
      navigator.pop();
    } else {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(cubit.state.error ?? 'Could not save promotion.'),
        ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(_isEdit ? 'Edit promotion' : 'New promotion',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                AppTextField(
                  hint: 'Title (e.g. 30% OFF your order)',
                  controller: _title,
                  validator: _requiredText,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  hint: 'Description (shown on the banner)',
                  controller: _description,
                  maxLines: 2,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        hint: 'Discount %',
                        controller: _percent,
                        keyboardType: TextInputType.number,
                        validator: _percentValidator,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        hint: 'Min subtotal (\$)',
                        controller: _minSubtotal,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: AppColors.primary,
                  title: const Text('Active',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: const Text('Show on the customer banner + apply at checkout',
                      style: TextStyle(fontSize: 12)),
                  value: _active,
                  onChanged: (v) => setState(() => _active = v),
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: AppColors.primary,
                  title: const Text('First order only',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: const Text('Applies only to a customer’s first order',
                      style: TextStyle(fontSize: 12)),
                  value: _firstOrderOnly,
                  onChanged: (v) => setState(() => _firstOrderOnly = v),
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  label: _isEdit ? 'Save changes' : 'Create promotion',
                  isLoading: _saving,
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
