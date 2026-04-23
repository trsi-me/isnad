import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/enums/injury_type.dart';
import '../../core/enums/report_status.dart';
import '../../core/enums/user_role.dart';
import '../../core/services/location_service.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/injury_record_model.dart';
import '../../models/report_model.dart';
import '../../models/response_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/injury_record_provider.dart';
import '../../providers/report_provider.dart';
import '../../providers/response_provider.dart';
import '../../widgets/common/isnad_app_bar.dart';
import '../../widgets/common/isnad_button.dart';
import '../../widgets/common/isnad_text_field.dart';
import '../../widgets/common/status_timeline_widget.dart';

class ReportDetailScreen extends StatefulWidget {
  const ReportDetailScreen({super.key, required this.reportId});

  final int reportId;

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  ReportModel? _report;
  List<ResponseModel> _responses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final rp = context.read<ReportProvider>();
    final respProv = context.read<ResponseProvider>();
    final r = await rp.getReportById(widget.reportId);
    if (!mounted) return;
    final resp = await respProv.getResponsesForReport(widget.reportId);
    if (!mounted) return;
    setState(() {
      _report = r;
      _responses = resp;
      _loading = false;
    });
  }

  Map<String, String> _buildTimes() {
    final m = <String, String>{};
    final rep = _report;
    if (rep == null) return m;
    m[ReportStatus.open.value] = rep.createdAt;
    for (final x in _responses) {
      final st = ResponseProvider.statusForAction(x.actionType);
      m[st] = x.actionTime;
    }
    m[rep.status] = rep.updatedAt;
    return m;
  }

  Future<void> _applyAction(String actionType) async {
    final auth = context.read<AuthProvider>();
    final respProv = context.read<ResponseProvider>();
    final reportProv = context.read<ReportProvider>();
    final user = auth.currentUser;
    final rep = _report;
    if (user == null || rep == null || rep.id == null) return;
    final reportId = rep.id!;

    if (actionType == 'closed' &&
        auth.userRole == UserRole.hospital &&
        rep.status == ReportStatus.arrived.value) {
      final ok = await _showHospitalDialog(rep);
      if (!ok || !mounted) return;
    }

    final newStatus = ResponseProvider.statusForAction(actionType);
    final ok = await respProv.updateReportStatus(reportId, newStatus);
    if (!ok || !mounted) return;
    final response = ResponseModel(
      reportId: reportId,
      responderId: user.militaryId,
      responderName: user.fullName,
      actionType: actionType,
      notes: null,
      actionTime: DateFormatter.nowIso(),
    );
    await respProv.addResponse(response);
    if (!mounted) return;
    await reportProv.refreshReports();
    if (!mounted) return;
    await _load();
  }

  Future<bool> _showHospitalDialog(ReportModel rep) async {
    final hospitalCtrl = TextEditingController();
    final doctorCtrl = TextEditingController();
    final summaryCtrl = TextEditingController();
    final treatCtrl = TextEditingController();
    final admitCtrl = TextEditingController();
    final dischargeCtrl = TextEditingController();
    final medicalCtrl = TextEditingController();
    final injuryProv = context.read<InjuryRecordProvider>();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.backgroundSecondary,
          title: Text('تقرير طبي', style: AppTextStyles.headline3),
          content: SingleChildScrollView(
            child: Column(
              children: [
                IsnadTextField(controller: hospitalCtrl, label: 'اسم المستشفى'),
                const SizedBox(height: 12),
                IsnadTextField(controller: doctorCtrl, label: 'اسم الطبيب'),
                const SizedBox(height: 12),
                IsnadTextField(controller: summaryCtrl, label: 'ملخص الإصابة'),
                const SizedBox(height: 12),
                IsnadTextField(controller: treatCtrl, label: 'تفاصيل العلاج', maxLines: 3),
                const SizedBox(height: 12),
                IsnadTextField(controller: admitCtrl, label: 'تاريخ الدخول'),
                const SizedBox(height: 12),
                IsnadTextField(controller: dischargeCtrl, label: 'تاريخ الخروج'),
                const SizedBox(height: 12),
                IsnadTextField(controller: medicalCtrl, label: 'التقرير الطبي', maxLines: 3),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text('إلغاء', style: AppTextStyles.buttonTextSecondary),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text('حفظ', style: AppTextStyles.buttonTextSecondary),
            ),
          ],
        );
      },
    );
    if (result != true) {
      hospitalCtrl.dispose();
      doctorCtrl.dispose();
      summaryCtrl.dispose();
      treatCtrl.dispose();
      admitCtrl.dispose();
      dischargeCtrl.dispose();
      medicalCtrl.dispose();
      return false;
    }
    final record = InjuryRecordModel(
      reportId: rep.id!,
      militaryId: rep.militaryId,
      injurySummary: summaryCtrl.text.trim().isEmpty ? '—' : summaryCtrl.text.trim(),
      hospitalName: hospitalCtrl.text.trim().isEmpty ? null : hospitalCtrl.text.trim(),
      medicalReport: medicalCtrl.text.trim().isEmpty ? null : medicalCtrl.text.trim(),
      treatmentDetails: treatCtrl.text.trim().isEmpty ? null : treatCtrl.text.trim(),
      doctorName: doctorCtrl.text.trim().isEmpty ? null : doctorCtrl.text.trim(),
      admissionDate: admitCtrl.text.trim().isEmpty ? null : admitCtrl.text.trim(),
      dischargeDate: dischargeCtrl.text.trim().isEmpty ? null : dischargeCtrl.text.trim(),
      legalStatus: 'pending',
      createdAt: DateFormatter.nowIso(),
    );
    hospitalCtrl.dispose();
    doctorCtrl.dispose();
    summaryCtrl.dispose();
    treatCtrl.dispose();
    admitCtrl.dispose();
    dischargeCtrl.dispose();
    medicalCtrl.dispose();
    if (!mounted) return false;
    await injuryProv.createInjuryRecord(record);
    return true;
  }

  List<Widget> _actionButtons(UserRole role, ReportModel r) {
    if (role == UserRole.soldier) return [];
    final s = r.status;
    final out = <Widget>[];
    if (s == ReportStatus.open.value) {
      out.add(IsnadButton(label: 'تم الاستلام', onPressed: () => _applyAction('received')));
    }
    if (s == ReportStatus.received.value) {
      out.add(IsnadButton(label: 'تم إرسال فريق', onPressed: () => _applyAction('team_sent')));
    }
    if (s == ReportStatus.responding.value) {
      out.add(IsnadButton(label: 'تم الوصول', onPressed: () => _applyAction('arrived')));
    }
    if (s == ReportStatus.arrived.value) {
      out.add(IsnadButton(label: 'إغلاق الحالة', onPressed: () => _applyAction('closed')));
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final rep = _report;
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: IsnadAppBar(
        title: 'تفاصيل البلاغ',
        showBrandLogo: false,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.goldPrimary),
        ),
        onNotificationsTap: () => Navigator.of(context).pushNamed('/notifications'),
      ),
      body: _loading || rep == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.goldPrimary))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.screenHorizontal,
                vertical: AppDimensions.screenVertical,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _kv('المُبلِّغ', rep.reporterName),
                  _kv('الرقم العسكري', rep.militaryId),
                  _kv(
                    'نوع الإصابة',
                    injuryTypeFromString(rep.injuryType)?.displayName ?? rep.injuryType,
                  ),
                  if (rep.injuryDescription != null && rep.injuryDescription!.isNotEmpty)
                    _kv('الوصف', rep.injuryDescription!),
                  if (rep.locationLat != null && rep.locationLng != null)
                    _kv(
                      'إحداثيات البلاغ',
                      '${rep.locationLat!.toStringAsFixed(5)}, ${rep.locationLng!.toStringAsFixed(5)}',
                    ),
                  if (rep.locationName != null && rep.locationName!.isNotEmpty)
                    _kv('اسم الموقع', rep.locationName!),
                  if (rep.mediaPath != null && rep.mediaPath!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                      child: Image.file(File(rep.mediaPath!), fit: BoxFit.cover),
                    ),
                  ],
                  const SizedBox(height: 12),
                  IsnadButton(
                    label: 'تحديث موقعي على الخريطة (معاينة)',
                    variant: IsnadButtonVariant.outlinedGold,
                    onPressed: () async {
                      final pos = await LocationService.getCurrentLocation();
                      if (!context.mounted || pos == null) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'موقعك: ${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}',
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text('مسار الحالة', style: AppTextStyles.headline3),
                  const SizedBox(height: 12),
                  StatusTimelineWidget(
                    currentStatus: rep.status,
                    timesByStatus: _buildTimes(),
                  ),
                  const SizedBox(height: 16),
                  ..._actionButtons(auth.userRole, rep).map(
                    (w) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: w,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _kv(String k, String v) {
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
