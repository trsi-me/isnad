import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/enums/user_role.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/isnad_app_bar.dart';
import '../../widgets/common/isnad_button.dart';
import '../../widgets/common/isnad_text_field.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _unitCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _editing = false;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _unitCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _syncFromUser() {
    final u = context.read<AuthProvider>().currentUser;
    _nameCtrl.text = u?.fullName ?? '';
    _unitCtrl.text = u?.unit ?? '';
    _phoneCtrl.text = u?.phone ?? '';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_editing) {
      _syncFromUser();
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final ok = await context.read<AuthProvider>().updateProfile(
          fullName: _nameCtrl.text,
          unit: _unitCtrl.text,
          phone: _phoneCtrl.text,
        );
    if (!mounted) return;
    setState(() {
      _saving = false;
      if (ok) _editing = false;
    });
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ التعديلات')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر حفظ التعديلات')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final u = auth.currentUser;
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: IsnadAppBar(
        title: 'الملف الشخصي',
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
            Container(
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
                      const Icon(Icons.info_outline, color: AppColors.goldPrimary, size: 22),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'يمكنك تعديل الاسم المعروض والوحدة ورقم الجوال. رقم الهوية والدور ثابتان في النسخة التجريبية.',
                          style: AppTextStyles.caption,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _readOnlyLine('رقم الهوية العسكرية', u?.militaryId ?? '—'),
            _readOnlyLine('الدور', auth.userRole.displayName),
            const SizedBox(height: 8),
            if (_editing) ...[
              IsnadTextField(
                controller: _nameCtrl,
                label: 'الاسم الكامل',
              ),
              const SizedBox(height: 12),
              IsnadTextField(
                controller: _unitCtrl,
                label: 'الوحدة / التشكيل',
              ),
              const SizedBox(height: 12),
              IsnadTextField(
                controller: _phoneCtrl,
                label: 'رقم الجوال',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              IsnadButton(
                label: 'حفظ التعديلات',
                loading: _saving,
                onPressed: _save,
              ),
              const SizedBox(height: 8),
              IsnadButton(
                label: 'إلغاء',
                variant: IsnadButtonVariant.outlinedGold,
                enabled: !_saving,
                onPressed: () {
                  setState(() {
                    _editing = false;
                    _syncFromUser();
                  });
                },
              ),
            ] else ...[
              _readOnlyLine('الاسم', u?.fullName ?? '—'),
              _readOnlyLine('الوحدة', u?.unit ?? '—'),
              _readOnlyLine('الهاتف', u?.phone ?? '—'),
              const SizedBox(height: 16),
              IsnadButton(
                label: 'تعديل البيانات',
                variant: IsnadButtonVariant.outlinedGold,
                onPressed: () => setState(() {
                  _editing = true;
                  _syncFromUser();
                }),
              ),
            ],
            const SizedBox(height: 24),
            IsnadButton(
              label: 'تسجيل الخروج',
              variant: IsnadButtonVariant.outlinedGold,
              onPressed: () async {
                await context.read<AuthProvider>().logout();
                if (!context.mounted) return;
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _readOnlyLine(String k, String v) {
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
