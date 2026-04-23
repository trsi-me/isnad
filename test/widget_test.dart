import 'package:flutter_test/flutter_test.dart';
import 'package:isnad/app.dart';
import 'package:isnad/providers/auth_provider.dart';
import 'package:isnad/providers/injury_record_provider.dart';
import 'package:isnad/providers/report_provider.dart';
import 'package:isnad/providers/response_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('IsnadApp يعرض شاشة البداية ثم تسجيل الدخول', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(
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
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('تسجيل الدخول'), findsOneWidget);
  });
}
