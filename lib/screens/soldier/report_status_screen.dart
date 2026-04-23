import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/report_provider.dart';
import '../../widgets/common/isnad_app_bar.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../widgets/report/report_list_item.dart';

class ReportStatusScreen extends StatefulWidget {
  const ReportStatusScreen({super.key});

  @override
  State<ReportStatusScreen> createState() => _ReportStatusScreenState();
}

class _ReportStatusScreenState extends State<ReportStatusScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final auth = context.read<AuthProvider>();
    final mid = auth.currentUser?.militaryId;
    await context.read<ReportProvider>().loadReports(militaryId: mid);
  }

  @override
  Widget build(BuildContext context) {
    final rp = context.watch<ReportProvider>();
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: IsnadAppBar(
        title: 'بلاغاتي',
        showBrandLogo: false,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.goldPrimary),
        ),
        onNotificationsTap: () => Navigator.of(context).pushNamed('/notifications'),
      ),
      body: LoadingOverlay(
        loading: rp.isLoading,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.screenHorizontal,
            vertical: AppDimensions.screenVertical,
          ),
          child: rp.reports.isEmpty
              ? Center(
                  child: Text(
                    'لا توجد بلاغات بعد',
                    style: AppTextStyles.bodyMedium,
                  ),
                )
              : ListView.separated(
                  itemCount: rp.reports.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) {
                    final r = rp.reports[i];
                    return ReportListItem(
                      report: r,
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          '/report_detail',
                          arguments: {'reportId': r.id ?? 0},
                        );
                      },
                    );
                  },
                ),
        ),
      ),
    );
  }
}
