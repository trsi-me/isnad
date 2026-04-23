import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/services/location_service.dart';
import '../../core/services/notification_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/report_provider.dart';

class SosFloatingButton extends StatelessWidget {
  const SosFloatingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.large(
      backgroundColor: AppColors.statusSOS,
      foregroundColor: AppColors.silverLight,
      onPressed: () => _onSos(context),
      child: Text(
        'SOS',
        style: AppTextStyles.buttonText.copyWith(
          color: AppColors.silverLight,
          fontSize: 20,
        ),
      ),
    );
  }

  Future<void> _onSos(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final reports = context.read<ReportProvider>();
    final user = auth.currentUser;
    if (user == null) return;

    final pos = await LocationService.getCurrentLocation();
    final locLabel = pos == null
        ? 'غير متاح'
        : '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}';

    final ok = await reports.createSOSReport(
      militaryId: user.militaryId,
      name: user.fullName,
      lat: pos?.latitude,
      lng: pos?.longitude,
    );

    if (!context.mounted) return;
    if (ok) {
      await NotificationService.showSOSAlert(
        reporterName: user.fullName,
        location: locLabel,
      );
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.backgroundSecondary,
          title: Text('تأكيد', style: AppTextStyles.headline3),
          content: Text(
            'تم إرسال بلاغ الطوارئ',
            style: AppTextStyles.bodyLarge,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('حسناً', style: AppTextStyles.buttonTextSecondary),
            ),
          ],
        ),
      );
    }
  }
}
