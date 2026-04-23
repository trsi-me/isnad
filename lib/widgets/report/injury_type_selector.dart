import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/enums/injury_type.dart';

class InjuryTypeSelector extends StatelessWidget {
  const InjuryTypeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final InjuryType selected;
  final ValueChanged<InjuryType> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = InjuryType.values;
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.4,
      children: items.map((t) {
        final isSel = t == selected;
        return InkWell(
          onTap: () => onChanged(t),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSel ? AppColors.backgroundTertiary : AppColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              border: Border.all(
                color: isSel ? AppColors.goldPrimary : AppColors.borderColor,
                width: isSel ? 1.2 : 0.5,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              t.displayName,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isSel ? AppColors.goldLight : AppColors.silverPrimary,
                fontWeight: isSel ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
