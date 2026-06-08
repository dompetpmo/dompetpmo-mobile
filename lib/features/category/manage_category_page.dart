import 'package:confindant/app/theme/app_colors.dart';
import 'package:confindant/app/theme/app_radius.dart';
import 'package:confindant/app/theme/app_spacing.dart';
import 'package:confindant/app/theme/app_text_styles.dart';
import 'package:confindant/app/widgets/widgets.dart';
import 'package:confindant/features/category/widgets/category_ui.dart';
import 'package:confindant/features/wallet/presentation/view_models/wallet_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ManageCategoryPage extends ConsumerStatefulWidget {
  const ManageCategoryPage({super.key});

  static Future<void> showSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _ManageCategorySheetBody(),
    );
  }

  @override
  ConsumerState<ManageCategoryPage> createState() => _ManageCategoryPageState();
}

class _ManageCategoryPageState extends ConsumerState<ManageCategoryPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: _ManageCategorySheetBody(isFullPage: true),
    );
  }
}

class _ManageCategorySheetBody extends ConsumerStatefulWidget {
  const _ManageCategorySheetBody({this.isFullPage = false});

  final bool isFullPage;

  @override
  ConsumerState<_ManageCategorySheetBody> createState() => _ManageCategorySheetBodyState();
}

class _ManageCategorySheetBodyState extends ConsumerState<_ManageCategorySheetBody> {
  final _categoryController = TextEditingController();
  final _limitController = TextEditingController();
  String? _editingBudgetId;

  @override
  void dispose() {
    _categoryController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(walletViewModelProvider);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    final content = SingleChildScrollView(
      padding: EdgeInsets.only(bottom: bottomPadding + 16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Category Spending Limits',
                        style: AppTextStyles.sectionTitle.copyWith(fontSize: 20),
                      ),
                      Text(
                        'Set monthly spending limits per category',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.close_rounded, color: AppColors.textTertiary),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            CategoryLimitFormCard(
              categoryController: _categoryController,
              limitController: _limitController,
              onAddTap: _addLimit,
            ),
            const SizedBox(height: AppSpacing.md),
            if (state.budgets.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'No category limits set. Add one above!',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body.copyWith(
                      color: const Color(0xFF99A1AF),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            for (final item in state.budgets)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['category']?.toString() ?? '-',
                            style: AppTextStyles.label.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Rp ${item['limit_amount']?.toString() ?? '0'}',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      padding: EdgeInsets.zero,
                      onPressed: () => _editLimit(item),
                      icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.accentAction),
                    ),
                    IconButton(
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      padding: EdgeInsets.zero,
                      onPressed: () async {
                        final id = item['id']?.toString() ?? '';
                        if (id.isEmpty) return;
                        await ref.read(walletViewModelProvider.notifier).deleteBudget(id);
                      },
                      icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Color(0xFFC10007)),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.sm),
            AppPrimaryButton(
              label: _editingBudgetId == null ? 'Save Limit' : 'Update Limit',
              icon: const Icon(Icons.check_rounded, color: AppColors.white, size: 20),
              onPressed: _addLimit,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );

    if (widget.isFullPage) {
      return Container(
        color: AppColors.card,
        child: SafeArea(child: content),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: content,
    );
  }

  Future<void> _addLimit() async {
    final category = _categoryController.text.trim();
    final limitText = _limitController.text.trim();
    final limit = double.tryParse(limitText) ?? 0;

    if (category.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan nama kategori terlebih dahulu.')),
      );
      return;
    }
    if (limit <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan nominal limit yang valid (angka > 0).')),
      );
      return;
    }

    final vm = ref.read(walletViewModelProvider.notifier);
    final editingId = _editingBudgetId;
    try {
      if (editingId == null) {
        await vm.createBudget(category: category, limitAmount: limit);
      } else {
        await vm.updateBudget(id: editingId, category: category, limitAmount: limit);
      }
      _categoryController.clear();
      _limitController.clear();
      if (mounted) setState(() => _editingBudgetId = null);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan limit: $e')),
      );
    }
  }

  void _editLimit(Map<String, dynamic> item) {
    final id = item['id']?.toString() ?? '';
    if (id.isEmpty) return;
    _categoryController.text = item['category']?.toString() ?? '';
    _limitController.text = item['limit_amount']?.toString() ?? '';
    setState(() => _editingBudgetId = id);
  }
}
