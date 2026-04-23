import 'package:flutter/material.dart';

import 'report_detail_screen.dart';

class RespondScreen extends StatelessWidget {
  const RespondScreen({super.key, required this.reportId});

  final int reportId;

  @override
  Widget build(BuildContext context) {
    return ReportDetailScreen(reportId: reportId);
  }
}
