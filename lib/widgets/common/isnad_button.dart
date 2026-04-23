import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';

enum IsnadButtonVariant { filledGold, outlinedGold, danger }

class IsnadButton extends StatelessWidget {
  const IsnadButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = IsnadButtonVariant.filledGold,
    this.loading = false,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IsnadButtonVariant variant;
  final bool loading;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = (loading || !enabled) ? null : onPressed;

    final child = loading
        ? SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: variant == IsnadButtonVariant.filledGold
                  ? AppColors.backgroundPrimary
                  : AppColors.goldPrimary,
            ),
          )
        : Text(
            label,
            style: variant == IsnadButtonVariant.outlinedGold
                ? AppTextStyles.buttonTextSecondary
                : variant == IsnadButtonVariant.danger
                    ? AppTextStyles.buttonText.copyWith(color: AppColors.silverLight)
                    : AppTextStyles.buttonText,
          );

    switch (variant) {
      case IsnadButtonVariant.filledGold:
        return SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.goldPrimary,
              foregroundColor: AppColors.backgroundPrimary,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.buttonPaddingH,
                vertical: AppDimensions.buttonPaddingV,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
            ),
            onPressed: effectiveOnPressed,
            child: child,
          ),
        );
      case IsnadButtonVariant.outlinedGold:
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.goldPrimary,
              side: const BorderSide(color: AppColors.goldPrimary, width: 1),
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.buttonPaddingH,
                vertical: AppDimensions.buttonPaddingV,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
            ),
            onPressed: effectiveOnPressed,
            child: child,
          ),
        );
      case IsnadButtonVariant.danger:
        return SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.statusSOS,
              foregroundColor: AppColors.silverLight,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.buttonPaddingH,
                vertical: AppDimensions.buttonPaddingV,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
            ),
            onPressed: effectiveOnPressed,
            child: child,
          ),
        );
    }
  }
}
