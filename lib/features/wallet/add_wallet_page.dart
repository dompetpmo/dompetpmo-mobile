import 'package:confindant/app/theme/app_colors.dart';
import 'package:confindant/app/theme/app_gradients.dart';
import 'package:confindant/app/theme/app_radius.dart';
import 'package:confindant/app/theme/app_text_styles.dart';
import 'package:confindant/app/widgets/widgets.dart';
import 'package:confindant/features/wallet/presentation/view_models/wallet_view_model.dart';
import 'package:confindant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddWalletPage extends StatelessWidget {
  const AddWalletPage({super.key});

  static Future<void> showSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _AddWalletBody(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.appBackground),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              const _AddWalletBody(isPage: true),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddWalletBody extends ConsumerStatefulWidget {
  const _AddWalletBody({this.isPage = false});

  final bool isPage;

  @override
  ConsumerState<_AddWalletBody> createState() => _AddWalletBodyState();
}

class _AddWalletBodyState extends ConsumerState<_AddWalletBody> {
  final _nameController = TextEditingController();
  Color _selectedColor = const Color(0xFFF97316);
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    return AppCardContainer(
      radius: AppRadius.md,
      padding: EdgeInsets.fromLTRB(24, widget.isPage ? 24 : 8, 24, 24 + bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.isPage)
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          Row(
            children: [
              Text(
                l10n.addWalletTitle,
                style: AppTextStyles.sectionTitle.copyWith(
                  fontSize: 24,
                  height: 32 / 24,
                ),
              ),
              const Spacer(),
              const LanguageSwitcherButton(
                iconColor: AppColors.accentAction,
                size: 22,
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.close_rounded,
                  color: Color(0xFF99A1AF),
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.addWalletWalletName,
            style: AppTextStyles.label.copyWith(
              fontSize: 14,
              color: const Color(0xFF364153),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textPrimary,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: l10n.addWalletWalletNameHint,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.addWalletColor,
            style: AppTextStyles.label.copyWith(
              fontSize: 14,
              color: const Color(0xFF364153),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _walletColors.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final color = _walletColors[index];
                final selected = _selectedColor == color;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.55),
                                blurRadius: 10,
                                spreadRadius: 3,
                              ),
                            ]
                          : null,
                    ),
                    child: selected
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 22,
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          AppPrimaryButton(
            label: l10n.addWalletCreateButton,
            isLoading: _loading,
            onPressed: _loading ? null : _submit,
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _loading = true);
    try {
      await ref.read(walletViewModelProvider.notifier).createWallet(
            name: name,
            balance: 0,
            color: '#${_selectedColor.toARGB32().toRadixString(16)}',
          );
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.addWalletCreateFailed)),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

const _walletColors = [
  Color(0xFFF97316),
  Color(0xFFEF4444),
  Color(0xFFEAB308),
  Color(0xFF22C55E),
  Color(0xFF3B82F6),
  Color(0xFFA855F7),
  Color(0xFFEC4899),
];
