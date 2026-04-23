import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/injury_record_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/injury_record_provider.dart';
import '../../widgets/common/isnad_app_bar.dart';

class InjuryRecordScreen extends StatefulWidget {
  const InjuryRecordScreen({super.key});

  @override
  State<InjuryRecordScreen> createState() => _InjuryRecordScreenState();
}

class _InjuryRecordScreenState extends State<InjuryRecordScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final auth = context.read<AuthProvider>();
    final mid = auth.currentUser?.militaryId;
    if (mid == null) return;
    await context.read<InjuryRecordProvider>().loadRecordsForUser(mid);
  }

  String _legalLabel(String s) {
    switch (s) {
      case 'approved':
        return 'مُعتمد';
      case 'rejected':
        return 'مرفوض';
      default:
        return 'قيد المراجعة';
    }
  }

  Color _legalColor(String s) {
    switch (s) {
      case 'approved':
        return AppColors.statusActive;
      case 'rejected':
        return AppColors.statusSOS;
      default:
        return AppColors.statusPending;
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<InjuryRecordProvider>();
    final views = prov.recordViews;
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: IsnadAppBar(
        title: 'محاضر الإصابة',
        showBrandLogo: false,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.goldPrimary),
        ),
        onNotificationsTap: () => Navigator.of(context).pushNamed('/notifications'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.screenHorizontal,
          vertical: AppDimensions.screenVertical,
        ),
        child: views.isEmpty
            ? Center(
                child: Text(
                  'لا توجد محاضر مرتبطة بحسابك',
                  style: AppTextStyles.bodyMedium,
                ),
              )
            : ListView.separated(
                itemCount: views.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (ctx, i) {
                  final v = views[i];
                  final r = v.record;
                  return InkWell(
                    onTap: () => _openDetail(context, r),
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
                          Text('بلاغ رقم ${r.reportId}', style: AppTextStyles.bodyLarge),
                          const SizedBox(height: 8),
                          Text(
                            InjuryRecordProvider.injuryLabel(v.injuryTypeKey),
                            style: AppTextStyles.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            DateFormatter.formatIsoOrRaw(r.createdAt),
                            style: AppTextStyles.caption,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _legalColor(r.legalStatus).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                            ),
                            child: Text(
                              _legalLabel(r.legalStatus),
                              style: AppTextStyles.caption.copyWith(
                                color: _legalColor(r.legalStatus),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  void _openDetail(BuildContext context, InjuryRecordModel r) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.backgroundSecondary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('تفاصيل المحضر', style: AppTextStyles.headline2),
                const SizedBox(height: 12),
                _line('ملخص الإصابة', r.injurySummary),
                _line('المستشفى', r.hospitalName ?? '—'),
                _line('الطبيب', r.doctorName ?? '—'),
                _line('التقرير الطبي', r.medicalReport ?? '—'),
                _line('تفاصيل العلاج', r.treatmentDetails ?? '—'),
                _line('تاريخ الدخول', r.admissionDate ?? '—'),
                _line('تاريخ الخروج', r.dischargeDate ?? '—'),
                _line('الحالة القانونية', _legalLabel(r.legalStatus)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _line(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(k, style: AppTextStyles.labelText),
          const SizedBox(height: 4),
          Text(v, style: AppTextStyles.bodyLarge),
        ],
      ),
    );
  }
}
