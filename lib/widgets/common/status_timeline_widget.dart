import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/enums/report_status.dart';
import '../../core/utils/date_formatter.dart';

class StatusTimelineWidget extends StatelessWidget {
  const StatusTimelineWidget({
    super.key,
    required this.currentStatus,
    this.timesByStatus,
  });

  final String currentStatus;
  final Map<String, String>? timesByStatus;

  @override
  Widget build(BuildContext context) {
    final stages = <MapEntry<ReportStatus, String>>[
      MapEntry(ReportStatus.open, ReportStatus.open.displayName),
      MapEntry(ReportStatus.received, ReportStatus.received.displayName),
      MapEntry(ReportStatus.responding, ReportStatus.responding.displayName),
      MapEntry(ReportStatus.arrived, ReportStatus.arrived.displayName),
      MapEntry(ReportStatus.closed, ReportStatus.closed.displayName),
    ];

    final current = reportStatusFromString(currentStatus) ?? ReportStatus.open;
    final currentIndex = stages.indexWhere((e) => e.key == current);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < stages.length; i++) ...[
          _StageRow(
            title: stages[i].value,
            time: timesByStatus?[stages[i].key.value],
            state: i < currentIndex
                ? _StageState.done
                : i == currentIndex
                    ? _StageState.current
                    : _StageState.upcoming,
            showLineBelow: i < stages.length - 1,
          ),
        ],
      ],
    );
  }
}

enum _StageState { done, current, upcoming }

class _StageRow extends StatelessWidget {
  const _StageRow({
    required this.title,
    required this.time,
    required this.state,
    required this.showLineBelow,
  });

  final String title;
  final String? time;
  final _StageState state;
  final bool showLineBelow;

  Color get _dotColor {
    switch (state) {
      case _StageState.done:
        return AppColors.statusActive;
      case _StageState.current:
        return AppColors.goldPrimary;
      case _StageState.upcoming:
        return AppColors.silverDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeText =
        time != null ? DateFormatter.formatIsoOrRaw(time) : '—';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: _dotColor,
                shape: BoxShape.circle,
              ),
            ),
            if (showLineBelow)
              Container(
                width: 2,
                height: 36,
                color: AppColors.dividerColor,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyLarge),
                Text(timeText, style: AppTextStyles.caption),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
