import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';
import '../../widgets/common/isnad_app_bar.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: IsnadAppBar(
        title: 'الإشعارات',
        showBrandLogo: false,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.goldPrimary),
        ),
        onNotificationsTap: null,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.screenHorizontal,
          vertical: AppDimensions.screenVertical,
        ),
        child: Text(
          'ستظهر هنا تنبيهات البلاغات والمزامنة عند تشغيل الخدمات على الجهاز.',
          style: AppTextStyles.bodyMedium,
        ),
      ),
    );
  }
}
