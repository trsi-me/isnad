import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class ReportMapPin extends StatelessWidget {
  const ReportMapPin({
    super.key,
    required this.color,
    this.size = 28,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.location_on, color: color, size: size);
  }
}

Color statusPinColor({
  required bool isSos,
  required String status,
}) {
  if (isSos) return AppColors.statusSOS;
  if (status == 'open') return AppColors.goldPrimary;
  if (status == 'responding') return AppColors.statusActive;
  return AppColors.statusPending;
}
