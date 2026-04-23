import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'app.dart';
import 'core/database/database_helper.dart';
import 'core/services/notification_service.dart';
import 'providers/auth_provider.dart';
import 'providers/injury_record_provider.dart';
import 'providers/report_provider.dart';
import 'providers/response_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Web: يحتاج factory صحيح لـ openDatabase (بدونها يفشل runtime مع Uncaught Error)
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }
  await initializeDateFormatting('ar');
  try {
    await Firebase.initializeApp();
  } catch (e) {
    if (kDebugMode) {
      debugPrint('Firebase init: $e');
    }
  }
  if (!kIsWeb) {
    await NotificationService.initialize();
  }
  final dbHelper = DatabaseHelper.instance;
  await dbHelper.ensureSeeded();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        ChangeNotifierProvider(create: (_) => ResponseProvider()),
        ChangeNotifierProvider(create: (_) => InjuryRecordProvider()),
      ],
      child: const IsnadApp(),
    ),
  );
}
