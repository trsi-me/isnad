import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class IsnadAppBar extends StatelessWidget implements PreferredSizeWidget {
  const IsnadAppBar({
    super.key,
    required this.title,
    this.onNotificationsTap,
    this.onProfileTap,
    this.leading,
    this.showBrandLogo = true,
  });

  final String title;
  final VoidCallback? onNotificationsTap;
  /// Opens profile (e.g. logout). Shown before notifications when both exist.
  final VoidCallback? onProfileTap;
  final Widget? leading;
  final bool showBrandLogo;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.backgroundSecondary,
      leading: leading,
      centerTitle: false,
      titleSpacing: leading == null ? 16 : 0,
      title: showBrandLogo
          ? Row(
              children: [
                Image.asset(
                  'assets/images/Logo2.png',
                  width: 28,
                  height: 28,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.headline3,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            )
          : Text(
              title,
              style: AppTextStyles.headline3,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
      actions: [
        if (onProfileTap != null)
          IconButton(
            tooltip: 'الملف الشخصي',
            onPressed: onProfileTap,
            icon: const Icon(Icons.person_outline, color: AppColors.goldPrimary),
          ),
        if (onNotificationsTap != null)
          IconButton(
            tooltip: 'الإشعارات',
            onPressed: onNotificationsTap,
            icon: const Icon(Icons.notifications_none, color: AppColors.goldPrimary),
          ),
      ],
    );
  }
}
