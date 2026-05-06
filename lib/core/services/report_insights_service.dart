import '../database/database_helper.dart';
import '../enums/injury_type.dart';
import '../enums/report_status.dart';
import '../../models/report_model.dart';

/// تحليل إحصائي للبلاغات (قواعد + تلخيص نصي) دون الاتصال بخدمة خارجية.
class ReportInsightsService {
  ReportInsightsService._();

  static Future<String> analyzeOverviewAr() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query('reports', orderBy: 'created_at DESC');
    if (rows.isEmpty) {
      return 'لا توجد بيانات بلاغات في النظام بعد.\n\n'
          'عند تسجيل أول بلاغ سيظهر هنا ملخص للأنماط والأولويات المقترحة.';
    }
    final reports = rows.map(ReportModel.fromMap).toList();
    final total = reports.length;
    final sos = reports.where((r) => r.isSos).length;
    final open = reports.where((r) => r.status == ReportStatus.open.value).length;
    final active = reports
        .where((r) =>
            r.status != ReportStatus.closed.value)
        .length;
    final withCoords =
        reports.where((r) => r.locationLat != null && r.locationLng != null).length;
    final withoutCoords = total - withCoords;

    final byStatus = <String, int>{};
    for (final r in reports) {
      byStatus[r.status] = (byStatus[r.status] ?? 0) + 1;
    }
    final byInjury = <String, int>{};
    for (final r in reports) {
      byInjury[r.injuryType] = (byInjury[r.injuryType] ?? 0) + 1;
    }
    final topInjury = byInjury.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top3 = topInjury.take(3).map((e) {
      final label = injuryTypeFromString(e.key)?.displayName ?? e.key;
      return '$label: ${e.value}';
    }).join('، ');

    final recent = reports.take(5).map((r) {
      final inj = injuryTypeFromString(r.injuryType)?.displayName ?? r.injuryType;
      final st = reportStatusFromString(r.status)?.displayName ?? r.status;
      return '• ${r.displayReference} — $inj — $st';
    }).join('\n');

    final buf = StringBuffer();
    buf.writeln('ملخص التحليل (نظرة عامة)\n');
    buf.writeln('إجمالي البلاغات: $total');
    buf.writeln('بلاغات نشطة (غير مغلقة): $active');
    buf.writeln('بلاغات بحالة «مفتوح»: $open');
    buf.writeln('بلاغات طوارئ (SOS): $sos');
    buf.writeln('بلاغات بإحداثيات: $withCoords');
    if (withoutCoords > 0) {
      buf.writeln('بلاغات بلا إحداثيات: $withoutCoords (يُفضّل طلب تحديث الموقع)');
    }
    buf.writeln('\nأكثر أنواع الإصابة تكراراً: $top3');

    buf.writeln('\nتوزيع الحالات:');
    for (final e in byStatus.entries) {
      final label = reportStatusFromString(e.key)?.displayName ?? e.key;
      buf.writeln('• $label: ${e.value}');
    }

    buf.writeln('\nأحدث البلاغات:\n$recent');

    buf.writeln('\nاستنتاجات مقترحة:');
    if (sos > 0 && open > 0) {
      buf.writeln('• يوجد بلاغات طوارئ؛ يُنصح بمراجعة البلاغات المفتوحة بأولوية.');
    }
    if (withoutCoords > total * 0.2) {
      buf.writeln('• نسبة ملحوظة من البلاغات بلا موقع دقيق؛ تعزيز استخدام تحديث GPS والخريطة يسرّع الإسناد.');
    }
    if (open > active * 0.5 && active > 3) {
      buf.writeln('• عدد «مفتوح» مرتفع مقارنة بالنشط؛ متابعة تدفق الاستلام والاستجابة.');
    }
    if (sos == 0 && open <= 2) {
      buf.writeln('• لا توجد مؤشرات طوارئ حرجة في العينة الحالية؛ الاستمرار بالمراقبة الدورية.');
    }

    buf.writeln(
      '\nهذا التحليل آلي ويستند إلى البيانات المحلية فقط؛ يُدمج مع معلومات القيادة الميدانية.',
    );
    return buf.toString();
  }

  static Future<String> analyzeSingleReportAr(ReportModel r) async {
    final inj = injuryTypeFromString(r.injuryType)?.displayName ?? r.injuryType;
    final st = reportStatusFromString(r.status)?.displayName ?? r.status;
    final hasLoc = r.locationLat != null && r.locationLng != null;
    final b = StringBuffer();
    b.writeln('تحليل البلاغ ${r.displayReference}\n');
    b.writeln('نوع الإصابة: $inj');
    b.writeln('حالة المسار: $st');
    b.writeln(r.isSos ? 'مستوى الأولوية: طوارئ' : 'مستوى الأولوية: اعتيادي');
    b.writeln(hasLoc ? 'الموقع: متوفر (إحداثيات)' : 'الموقع: غير مكتمل — يُنصح بتحديث الإحداثيات');
    if (r.injuryDescription != null && r.injuryDescription!.trim().isNotEmpty) {
      b.writeln('\nوصف المُبلِّغ:\n${r.injuryDescription!.trim()}');
    }
    b.writeln('\nمقترح إجرائي:');
    if (r.isSos && r.status == ReportStatus.open.value) {
      b.writeln('تأكيد استلام فوري وإرسال أقرب فريق؛ التحقق من الموقع الميداني.');
    } else if (!hasLoc) {
      b.writeln('طلب إرجاع بلاغ مصحوب بموقع GPS أو تحديد على الخريطة.');
    } else if (r.status == ReportStatus.open.value) {
      b.writeln('متابعة انتقال الحالة إلى «تم الاستلام» ثم تنسيق الإسناد حسب نوع الإصابة.');
    } else {
      b.writeln('متابعة المسار الحالي حتى الإغلاق مع توثيق أي استجابات في السجل.');
    }
    return b.toString();
  }
}
