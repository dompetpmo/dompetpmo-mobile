import 'package:confindant/app/theme/app_colors.dart';
import 'package:confindant/app/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CategoryLimitFormCard extends StatelessWidget {
  const CategoryLimitFormCard({
    super.key,
    required this.categoryController,
    required this.limitController,
    this.onAddTap,
  });

  final TextEditingController categoryController;
  final TextEditingController limitController;
  final VoidCallback? onAddTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add New Limit',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textPrimary,
              fontSize: 16,
              height: 24 / 16,
            ),
          ),
          const SizedBox(height: 12),
          CategoryLiteInput(
            controller: categoryController,
            hint: 'Category (e.g., Food)',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CategoryLiteInput(
                  controller: limitController,
                  hint: 'Limit (Rp)',
                  numeric: true,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 52,
                height: 42,
                child: Material(
                  color: AppColors.accentAction,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: onAddTap,
                    borderRadius: BorderRadius.circular(10),
                    child: const Icon(
                      Icons.add_rounded,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CategoryLiteInput extends StatelessWidget {
  const CategoryLiteInput({
    super.key,
    required this.controller,
    required this.hint,
    this.numeric = false,
  });

  final TextEditingController controller;
  final String hint;
  final bool numeric;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: TextField(
        controller: controller,
        keyboardType: numeric
            ? const TextInputType.numberWithOptions(decimal: false)
            : TextInputType.text,
        inputFormatters: numeric
            ? [FilteringTextInputFormatter.digitsOnly]
            : null,
        style: AppTextStyles.body.copyWith(
          color: AppColors.textPrimary,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.border),
          ),
        ),
      ),
    );
  }
}
