import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/enums/user_role.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _go());
  }

  Future<void> _go() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    await auth.checkSavedSession();
    if (!mounted) return;
    if (auth.isLoggedIn) {
      _openHome(auth.userRole);
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  void _openHome(UserRole role) {
    if (role == UserRole.soldier) {
      Navigator.of(context).pushReplacementNamed('/soldier_home');
    } else {
      Navigator.of(context).pushReplacementNamed('/command_home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.screenHorizontal,
          vertical: AppDimensions.screenVertical,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/Logo2.png',
                width: 160,
                height: 160,
              ),
              const SizedBox(height: 16),
              Text(AppStrings.appName, style: AppTextStyles.headline1),
              const SizedBox(height: 12),
              Text(
                AppStrings.appSubtitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
