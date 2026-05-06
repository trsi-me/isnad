import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/services/report_insights_service.dart';
import '../../providers/report_provider.dart';
import '../../widgets/common/isnad_app_bar.dart';
import '../../widgets/common/isnad_button.dart';

class AiInsightsScreen extends StatefulWidget {
  const AiInsightsScreen({super.key, this.reportId});

  final int? reportId;

  @override
  State<AiInsightsScreen> createState() => _AiInsightsScreenState();
}

class _AiInsightsScreenState extends State<AiInsightsScreen> {
  String? _overview;
  String? _single;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  Future<void> _run() async {
    setState(() => _loading = true);
    final reportProv = context.read<ReportProvider>();
    final overview = await ReportInsightsService.analyzeOverviewAr();
    String? single;
    if (widget.reportId != null && widget.reportId! > 0) {
      final r = await reportProv.getReportById(widget.reportId!);
      if (r != null) {
        single = await ReportInsightsService.analyzeSingleReportAr(r);
      }
    }
    if (!mounted) return;
    setState(() {
      _overview = overview;
      _single = single;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: IsnadAppBar(
        title: 'تحليل ذكي للبلاغات',
        showBrandLogo: false,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.goldPrimary),
        ),
        onNotificationsTap: () => Navigator.of(context).pushNamed('/notifications'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.goldPrimary))
          : RefreshIndicator(
              color: AppColors.goldPrimary,
              onRefresh: _run,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.screenHorizontal,
                  vertical: AppDimensions.screenVertical,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_single != null) ...[
                      Text('تحليل البلاغ الحالي', style: AppTextStyles.headline3),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundSecondary,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                          border: Border.all(color: AppColors.borderColor, width: 0.5),
                        ),
                        child: Text(_single!, style: AppTextStyles.bodyMedium),
                      ),
                      const SizedBox(height: 24),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: Text('نظرة على كل البيانات', style: AppTextStyles.headline3),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'يُحدَّث من السجلات المحلية فور السحب للتحديث.',
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundSecondary,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                        border: Border.all(color: AppColors.borderColor, width: 0.5),
                      ),
                      child: Text(_overview ?? '—', style: AppTextStyles.bodyMedium),
                    ),
                    const SizedBox(height: 20),
                    IsnadButton(
                      label: 'إعادة التحليل',
                      variant: IsnadButtonVariant.outlinedGold,
                      onPressed: _run,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
