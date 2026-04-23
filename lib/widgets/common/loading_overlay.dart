import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    super.key,
    required this.loading,
    required this.child,
  });

  final bool loading;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (loading)
          Positioned.fill(
            child: Container(
              color: AppColors.backgroundPrimary.withValues(alpha: 0.55),
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.goldPrimary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
