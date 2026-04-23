import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/enums/user_role.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/isnad_button.dart';
import '../../widgets/common/isnad_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _idCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;

  @override
  void dispose() {
    _idCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(_idCtrl.text.trim(), _pwCtrl.text);
    if (!mounted) return;
    if (ok) {
      final role = auth.userRole;
      if (role == UserRole.soldier) {
        Navigator.of(context).pushReplacementNamed('/soldier_home');
      } else {
        Navigator.of(context).pushReplacementNamed('/command_home');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'فشل تسجيل الدخول'),
          backgroundColor: AppColors.statusSOS,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.screenHorizontal,
            vertical: AppDimensions.screenVertical,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                Center(
                  child: Image.asset(
                    'assets/images/Logo2.png',
                    width: 100,
                    height: 100,
                  ),
                ),
                const SizedBox(height: 24),
                Text(AppStrings.loginTitle, style: AppTextStyles.headline2),
                const SizedBox(height: 24),
                IsnadTextField(
                  controller: _idCtrl,
                  label: AppStrings.militaryIdLabel,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'أدخل رقم الهوية';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                IsnadTextField(
                  controller: _pwCtrl,
                  label: AppStrings.passwordLabel,
                  obscure: _obscure,
                  onToggleObscure: () => setState(() => _obscure = !_obscure),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'أدخل كلمة المرور';
                    return null;
                  },
                ),
                const Spacer(),
                IsnadButton(
                  label: AppStrings.loginButton,
                  loading: auth.isLoading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
