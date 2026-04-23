import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/isnad_app_bar.dart';
import '../../widgets/common/sos_floating_button.dart';

class SoldierHomeScreen extends StatelessWidget {
  const SoldierHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final name = auth.currentUser?.fullName ?? '—';
    final unit = auth.currentUser?.unit;
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: IsnadAppBar(
        title: 'الرئيسية',
        onNotificationsTap: () {
          Navigator.of(context).pushNamed('/notifications');
        },
      ),
      floatingActionButton: const SosFloatingButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.screenHorizontal,
          vertical: AppDimensions.screenVertical,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                border: Border.all(color: AppColors.borderColor, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundTertiary,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                        ),
                        child: const Icon(
                          Icons.shield_outlined,
                          color: AppColors.goldPrimary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('مرحباً', style: AppTextStyles.caption),
                            const SizedBox(height: 4),
                            Text(
                              name,
                              style: AppTextStyles.headline3,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (unit != null && unit.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(unit, style: AppTextStyles.bodyMedium),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundTertiary,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                    ),
                    child: Text(
                      'عسكري ميداني',
                      style: AppTextStyles.caption.copyWith(color: AppColors.goldLight),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text('خدمات سريعة', style: AppTextStyles.headline3),
            const SizedBox(height: 8),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.05,
                children: [
                  _HomeTile(
                    label: 'بلاغ جديد',
                    subtitle: 'تسجيل حالة',
                    icon: Icons.add_circle_outline,
                    iconColor: AppColors.goldPrimary,
                    onTap: () => Navigator.of(context).pushNamed('/quick_report'),
                  ),
                  _HomeTile(
                    label: 'بلاغاتي',
                    subtitle: 'متابعة الحالة',
                    icon: Icons.list_alt,
                    iconColor: AppColors.silverLight,
                    onTap: () => Navigator.of(context).pushNamed('/report_status'),
                  ),
                  _HomeTile(
                    label: 'محاضر الإصابة',
                    subtitle: 'سجلات طبية',
                    icon: Icons.description_outlined,
                    iconColor: AppColors.silverLight,
                    onTap: () => Navigator.of(context).pushNamed('/injury_record'),
                  ),
                  _HomeTile(
                    label: 'الملف الشخصي',
                    subtitle: 'تعديل البيانات',
                    icon: Icons.person_outline,
                    iconColor: AppColors.silverLight,
                    onTap: () => Navigator.of(context).pushNamed('/profile'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTile extends StatelessWidget {
  const _HomeTile({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: Border.all(color: AppColors.borderColor, width: 0.5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: 32),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLarge,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
