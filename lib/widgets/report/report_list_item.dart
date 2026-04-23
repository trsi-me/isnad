import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/enums/injury_type.dart';
import '../../core/enums/report_status.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/report_model.dart';

class ReportListItem extends StatelessWidget {
  const ReportListItem({
    super.key,
    required this.report,
    required this.onTap,
  });

  final ReportModel report;
  final VoidCallback onTap;

  Color _statusColor() {
    final s = reportStatusFromString(report.status);
    if (report.isSos) return AppColors.statusSOS;
    switch (s) {
      case ReportStatus.closed:
        return AppColors.statusClosed;
      case ReportStatus.open:
        return AppColors.goldPrimary;
      case ReportStatus.received:
      case ReportStatus.responding:
        return AppColors.statusPending;
      case ReportStatus.arrived:
        return AppColors.statusActive;
      case null:
        return AppColors.silverDark;
    }
  }

  String _statusLabel() {
    if (report.isSos) return 'طوارئ';
    return reportStatusFromString(report.status)?.displayName ?? report.status;
  }

  @override
  Widget build(BuildContext context) {
    final inj = injuryTypeFromString(report.injuryType)?.displayName ?? report.injuryType;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(color: AppColors.borderColor, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(inj, style: AppTextStyles.bodyLarge),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _statusColor().withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  ),
                  child: Text(
                    _statusLabel(),
                    style: AppTextStyles.caption.copyWith(color: _statusColor()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              DateFormatter.formatIsoOrRaw(report.createdAt),
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: 4),
            Text(
              'رقم البلاغ: ${report.reportUuid}',
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }
}
