import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/enums/injury_type.dart';
import '../../core/enums/report_status.dart';
import '../../core/services/camera_service.dart';
import '../../core/services/location_service.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/report_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/report_provider.dart';
import '../../widgets/common/isnad_app_bar.dart';
import '../../widgets/common/isnad_button.dart';
import '../../widgets/common/isnad_text_field.dart';
import '../../widgets/report/injury_type_selector.dart';

class QuickReportScreen extends StatefulWidget {
  const QuickReportScreen({super.key});

  @override
  State<QuickReportScreen> createState() => _QuickReportScreenState();
}

class _QuickReportScreenState extends State<QuickReportScreen> {
  InjuryType _injury = InjuryType.other;
  final _descCtrl = TextEditingController();
  double? _lat;
  double? _lng;
  String? _coordsLabel;
  String? _imagePath;
  bool _sending = false;

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pullLocation() async {
    final pos = await LocationService.getCurrentLocation();
    if (!mounted) return;
    if (pos == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر الحصول على الموقع')),
      );
      return;
    }
    setState(() {
      _lat = pos.latitude;
      _lng = pos.longitude;
      _coordsLabel =
          '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}';
    });
    try {
      final places = await geo.placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (places.isNotEmpty && mounted) {
        final p = places.first;
        final name = [p.locality, p.subAdministrativeArea, p.country]
            .where((e) => (e ?? '').isNotEmpty)
            .join('، ');
        if (name.isNotEmpty) {
          setState(() {
            _coordsLabel = '$_coordsLabel\n$name';
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _pickImage() async {
    final path = await CameraService.pickImage();
    if (!mounted) return;
    setState(() => _imagePath = path);
  }

  Future<bool> _hasConnection() async {
    final r = await Connectivity().checkConnectivity();
    if (r.isEmpty) return false;
    return r.any((e) => e != ConnectivityResult.none);
  }

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    final reportProv = context.read<ReportProvider>();
    final user = auth.currentUser;
    if (user == null) return;
    setState(() => _sending = true);
    final now = DateFormatter.nowIso();
    final uuid = const Uuid().v4();
    final synced = await _hasConnection();
    if (!mounted) return;
    final report = ReportModel(
      reportUuid: uuid,
      militaryId: user.militaryId,
      reporterName: user.fullName,
      injuryType: _injury.value,
      injuryDescription: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      locationLat: _lat,
      locationLng: _lng,
      locationName: null,
      mediaPath: _imagePath,
      status: ReportStatus.open.value,
      isSos: false,
      isSynced: synced,
      createdAt: now,
      updatedAt: now,
    );
    final ok = await reportProv.createReport(report);
    if (!mounted) return;
    setState(() => _sending = false);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.reportSentSuccess)),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر حفظ البلاغ')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: IsnadAppBar(
        title: 'بلاغ جديد',
        showBrandLogo: false,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.goldPrimary),
        ),
        onNotificationsTap: () => Navigator.of(context).pushNamed('/notifications'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.screenHorizontal,
          vertical: AppDimensions.screenVertical,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('نوع الإصابة', style: AppTextStyles.headline3),
            const SizedBox(height: 12),
            InjuryTypeSelector(
              selected: _injury,
              onChanged: (v) => setState(() => _injury = v),
            ),
            const SizedBox(height: 16),
            Text('الموقع', style: AppTextStyles.headline3),
            const SizedBox(height: 12),
            IsnadButton(
              label: 'سحب الموقع الحالي',
              variant: IsnadButtonVariant.outlinedGold,
              onPressed: _pullLocation,
            ),
            if (_coordsLabel != null) ...[
              const SizedBox(height: 12),
              Text(_coordsLabel!, style: AppTextStyles.bodyMedium),
            ],
            const SizedBox(height: 16),
            IsnadTextField(
              controller: _descCtrl,
              label: 'الوصف (اختياري)',
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            IsnadButton(
              label: 'إرفاق صورة',
              variant: IsnadButtonVariant.outlinedGold,
              onPressed: _pickImage,
            ),
            if (_imagePath != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                child: Image.file(
                  File(_imagePath!),
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            const SizedBox(height: 24),
            IsnadButton(
              label: 'إرسال البلاغ',
              loading: _sending,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
