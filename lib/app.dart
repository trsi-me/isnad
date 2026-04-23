import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_text_styles.dart';
import 'core/services/sync_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/command/command_home_screen.dart';
import 'screens/command/live_map_screen.dart';
import 'screens/command/report_detail_screen.dart';
import 'screens/soldier/injury_record_screen.dart';
import 'screens/soldier/quick_report_screen.dart';
import 'screens/soldier/report_status_screen.dart';
import 'screens/soldier/soldier_home_screen.dart';
import 'screens/shared/notifications_screen.dart';
import 'screens/shared/profile_screen.dart';

class IsnadApp extends StatefulWidget {
  const IsnadApp({super.key});

  @override
  State<IsnadApp> createState() => _IsnadAppState();
}

class _IsnadAppState extends State<IsnadApp> {
  @override
  void initState() {
    super.initState();
    SyncService.connectivityStream.listen((online) async {
      if (online) {
        await SyncService.syncPendingReports();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar', 'SA'),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
      theme: ThemeData(
        fontFamily: AppTextStyles.fontFamily,
        scaffoldBackgroundColor: AppColors.backgroundPrimary,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.goldPrimary,
          secondary: AppColors.silverLight,
          surface: AppColors.backgroundSecondary,
          error: AppColors.statusSOS,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.backgroundSecondary,
          foregroundColor: AppColors.silverLight,
          elevation: 0,
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: AppColors.backgroundSecondary,
          contentTextStyle: AppTextStyles.bodyMedium,
        ),
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (_) => const SplashScreen(),
        '/login': (_) => const LoginScreen(),
        '/soldier_home': (_) => const SoldierHomeScreen(),
        '/command_home': (_) => const CommandHomeScreen(),
        '/quick_report': (_) => const QuickReportScreen(),
        '/report_status': (_) => const ReportStatusScreen(),
        '/injury_record': (_) => const InjuryRecordScreen(),
        '/live_map': (_) => const LiveMapScreen(),
        '/notifications': (_) => const NotificationsScreen(),
        '/profile': (_) => const ProfileScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/report_detail') {
          final args = settings.arguments;
          var id = 0;
          if (args is Map && args['reportId'] is int) {
            id = args['reportId'] as int;
          }
          return MaterialPageRoute<void>(
            builder: (_) => ReportDetailScreen(reportId: id),
            settings: settings,
          );
        }
        return null;
      },
    );
  }
}
