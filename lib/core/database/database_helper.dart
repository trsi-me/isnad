import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/date_formatter.dart';
import 'database_migrations.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dir = await getDatabasesPath();
    final path = p.join(dir, 'isnad.db');
    return openDatabase(
      path,
      version: DatabaseMigrations.currentVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: DatabaseMigrations.onCreate,
      onUpgrade: DatabaseMigrations.onUpgrade,
    );
  }

  Future<void> _seedDatabase(Database db) async {
    final users = await db.query('users', limit: 1);
    if (users.isNotEmpty) return;

    final now = DateFormatter.nowIso();
    final seedUsers = <Map<String, Object?>>[
      {
        'military_id': '1001',
        'full_name': 'جندي أحمد التجريبي',
        'role': 'soldier',
        'unit': 'الكتيبة الأولى — اللواء المدرّع الثاني',
        'phone': '0500000101',
        'password_hash': 'soldier123',
        'created_at': now,
      },
      {
        'military_id': '1002',
        'full_name': 'عريف خالد الشمري',
        'role': 'soldier',
        'unit': 'السرية الثانية — مشاة آلية',
        'phone': '0500000102',
        'password_hash': 'soldier123',
        'created_at': now,
      },
      {
        'military_id': '1003',
        'full_name': 'جندي أول سعد العنزي',
        'role': 'soldier',
        'unit': 'كتيبة الدفاع الجوي الخفيف',
        'phone': '0500000103',
        'password_hash': 'soldier123',
        'created_at': now,
      },
      {
        'military_id': '1004',
        'full_name': 'رقيب فهد القحطاني',
        'role': 'soldier',
        'unit': 'وحدة مهام خاصة — إسناد لوجستي',
        'phone': '0500000104',
        'password_hash': 'soldier123',
        'created_at': now,
      },
      {
        'military_id': '1005',
        'full_name': 'جندي ناصر الدوسري',
        'role': 'soldier',
        'unit': 'شركة الإمداد والتموين الميداني',
        'phone': '0500000105',
        'password_hash': 'soldier123',
        'created_at': now,
      },
      {
        'military_id': '1006',
        'full_name': 'جندي أول مشعل الحربي',
        'role': 'soldier',
        'unit': 'كتيبة هندسة ميدانية',
        'phone': '0500000106',
        'password_hash': 'soldier123',
        'created_at': now,
      },
      {
        'military_id': '1007',
        'full_name': 'عريف طلال الغامدي',
        'role': 'soldier',
        'unit': 'نقطة تفتيش — محور الوديعة (تجريبي)',
        'phone': '0500000107',
        'password_hash': 'soldier123',
        'created_at': now,
      },
      {
        'military_id': '1008',
        'full_name': 'جندي ياسر الزهراني',
        'role': 'soldier',
        'unit': 'سرية اتصالات — مركز القيادة الرقمية',
        'phone': '0500000108',
        'password_hash': 'soldier123',
        'created_at': now,
      },
      {
        'military_id': '1009',
        'full_name': 'جندي أول عبدالله المطيري',
        'role': 'soldier',
        'unit': 'كتيبة استطلاع — دوريات حدودية',
        'phone': '0500000109',
        'password_hash': 'soldier123',
        'created_at': now,
      },
      {
        'military_id': '1010',
        'full_name': 'رقيب ثاني سلطان البقمي',
        'role': 'soldier',
        'unit': 'لواء الحرس الوطني — مناور شمال غرب',
        'phone': '0500000110',
        'password_hash': 'soldier123',
        'created_at': now,
      },
      {
        'military_id': '1011',
        'full_name': 'جندي فيصل الرشيدي',
        'role': 'soldier',
        'unit': 'وحدة إسعاف ميداني — طب طوارئ',
        'phone': '0500000111',
        'password_hash': 'soldier123',
        'created_at': now,
      },
      {
        'military_id': '1012',
        'full_name': 'جندي أول ماجد العتيبي',
        'role': 'soldier',
        'unit': 'سرية مدفعية — بطارية دعم ناري',
        'phone': '0500000112',
        'password_hash': 'soldier123',
        'created_at': now,
      },
      {
        'military_id': '2001',
        'full_name': 'قائد محمد التجريبي',
        'role': 'command',
        'unit': 'قيادة المنطقة',
        'phone': '0500000002',
        'password_hash': 'command123',
        'created_at': now,
      },
      {
        'military_id': '3001',
        'full_name': 'مستشفى الميدان',
        'role': 'hospital',
        'unit': 'مستشفى عسكري',
        'phone': '0500000003',
        'password_hash': 'hospital123',
        'created_at': now,
      },
    ];
    for (final u in seedUsers) {
      await db.insert('users', u);
    }
  }

  Future<void> _seedSampleReports(Database db) async {
    final n = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM reports'),
        ) ??
        0;
    if (n > 0) return;

    final now = DateFormatter.nowIso();
    const uuid = Uuid();

    Future<void> insertReport({
      required String reportUuid,
      required String militaryId,
      required String reporterName,
      required String injuryType,
      String? injuryDescription,
      double? lat,
      double? lng,
      String? locationName,
      required String status,
      required int isSos,
      required int isSynced,
    }) async {
      final resolvedLocation = locationName ??
          (lat != null ? 'منطقة تبوك (تجريبي)' : null);
      await db.insert('reports', {
        'report_uuid': reportUuid,
        'military_id': militaryId,
        'reporter_name': reporterName,
        'injury_type': injuryType,
        'injury_description': injuryDescription,
        'location_lat': lat,
        'location_lng': lng,
        'location_name': resolvedLocation,
        'media_path': null,
        'status': status,
        'is_sos': isSos,
        'is_synced': isSynced,
        'created_at': now,
        'updated_at': now,
      });
    }

    final samples = <({
      String militaryId,
      String reporterName,
      String injuryType,
      String injuryDescription,
      double? lat,
      double? lng,
      String? locationName,
      String status,
      int isSos,
    })>[
      (
        militaryId: '1001',
        reporterName: 'جندي أحمد التجريبي',
        injuryType: 'gunshot',
        injuryDescription: 'إصابة طلق ناري في الطرف السفلي — مستقر نسبياً',
        lat: 28.3998,
        lng: 36.5705,
        locationName: 'محور تجمع شمال تبوك',
        status: 'open',
        isSos: 0,
      ),
      (
        militaryId: '1002',
        reporterName: 'عريف خالد الشمري',
        injuryType: 'shrapnel',
        injuryDescription: 'شظايا طفيفة في الكتف أثناء مناورة ليلية',
        lat: 28.4172,
        lng: 36.5489,
        locationName: 'ميدان مناورات الملك خالد',
        status: 'responding',
        isSos: 0,
      ),
      (
        militaryId: '1003',
        reporterName: 'جندي أول سعد العنزي',
        injuryType: 'burn',
        injuryDescription: 'حروق درجة ثانية من ملامسة أنبوب حار',
        lat: 28.3815,
        lng: 36.5921,
        locationName: 'ورشة صيانة الدفاع الجوي',
        status: 'received',
        isSos: 0,
      ),
      (
        militaryId: '1004',
        reporterName: 'رقيب فهد القحطاني',
        injuryType: 'blast',
        injuryDescription: 'دوخة وطنين بعد انفجار عبوة قريبة — طوارئ',
        lat: 28.3720,
        lng: 36.6010,
        locationName: 'طريق الإمداد الشرقي',
        status: 'open',
        isSos: 1,
      ),
      (
        militaryId: '1005',
        reporterName: 'جندي ناصر الدوسري',
        injuryType: 'fracture',
        injuryDescription: 'اشتباه كسر في الكاحل أثناء تحميل معدات',
        lat: 28.4288,
        lng: 36.5344,
        locationName: 'مستودع الإمداد المركزي',
        status: 'arrived',
        isSos: 0,
      ),
      (
        militaryId: '1006',
        reporterName: 'جندي أول مشعل الحربي',
        injuryType: 'other',
        injuryDescription: 'جسم غريب في العين — يحتاج فحص طبي',
        lat: null,
        lng: null,
        locationName: 'معسكر الهندسة الميدانية (بدون إحداثيات)',
        status: 'open',
        isSos: 0,
      ),
      (
        militaryId: '1007',
        reporterName: 'عريف طلال الغامدي',
        injuryType: 'gunshot',
        injuryDescription: 'بلاغ خطير — طلق من جهة مجهولة',
        lat: 28.3580,
        lng: 36.6125,
        locationName: 'نقطة تفتيش محور الوديعة',
        status: 'responding',
        isSos: 1,
      ),
      (
        militaryId: '1008',
        reporterName: 'جندي ياسر الزهراني',
        injuryType: 'shrapnel',
        injuryDescription: 'جرح سطحي من شظايا زجاج مركبة',
        lat: 28.4065,
        lng: 36.5788,
        locationName: 'مركز القيادة الرقمية — خارج البوابة',
        status: 'closed',
        isSos: 0,
      ),
      (
        militaryId: '1009',
        reporterName: 'جندي أول عبدالله المطيري',
        injuryType: 'burn',
        injuryDescription: 'حرق كيميائي طفيف من مادة تنظيف',
        lat: 28.3944,
        lng: 36.5622,
        locationName: 'دورية استطلاع — وادي قريب',
        status: 'received',
        isSos: 0,
      ),
      (
        militaryId: '1010',
        reporterName: 'رقيب ثاني سلطان البقمي',
        injuryType: 'fracture',
        injuryDescription: 'إصابة في الضلوع بعد سقوط من ارتفاع منخفض',
        lat: 28.4199,
        lng: 36.5197,
        locationName: 'موقع الحرس الوطني — شمال غرب',
        status: 'open',
        isSos: 0,
      ),
      (
        militaryId: '1011',
        reporterName: 'جندي فيصل الرشيدي',
        injuryType: 'other',
        injuryDescription: 'إغماء مفاجئ أثناء الحر تحت الشمس',
        lat: 28.3877,
        lng: 36.5455,
        locationName: 'نقطة إسعاف ميداني متحركة',
        status: 'responding',
        isSos: 1,
      ),
      (
        militaryId: '1012',
        reporterName: 'جندي أول ماجد العتيبي',
        injuryType: 'blast',
        injuryDescription: 'طنين أذني بعد انفجار مدفعية قريبة',
        lat: 28.4331,
        lng: 36.5866,
        locationName: 'موقع بطارية مدفعية — تجريبي',
        status: 'closed',
        isSos: 0,
      ),
      (
        militaryId: '1001',
        reporterName: 'جندي أحمد التجريبي',
        injuryType: 'shrapnel',
        injuryDescription: 'متابعة بلاغ قديم — تحسّن الحالة',
        lat: 28.4022,
        lng: 36.5511,
        locationName: 'منطقة تبوك العامة',
        status: 'responding',
        isSos: 0,
      ),
      (
        militaryId: '1003',
        reporterName: 'جندي أول سعد العنزي',
        injuryType: 'gunshot',
        injuryDescription: 'تدريب محاكاة إصابة — للعرض في الواجهة',
        lat: null,
        lng: null,
        locationName: 'قاعة المحاكاة (بدون موقع)',
        status: 'closed',
        isSos: 0,
      ),
      (
        militaryId: '2001',
        reporterName: 'قائد محمد التجريبي',
        injuryType: 'fracture',
        injuryDescription: 'بلاغ مسجَّل من حساب القيادة — متابعة عبر الغرفة',
        lat: 28.4100,
        lng: 36.5600,
        locationName: 'مقر القيادة الإقليمية',
        status: 'received',
        isSos: 0,
      ),
      (
        militaryId: '1005',
        reporterName: 'جندي ناصر الدوسري',
        injuryType: 'other',
        injuryDescription: 'اشتباه تسمم غذائي جماعي خفيف',
        lat: 28.3911,
        lng: 36.5278,
        locationName: 'مطبخ ميداني — تجريبي',
        status: 'open',
        isSos: 0,
      ),
      (
        militaryId: '1008',
        reporterName: 'جندي ياسر الزهراني',
        injuryType: 'blast',
        injuryDescription: 'اهتزاز قوي من انفجار بعيد — فحص طبي احترازي',
        lat: 28.3688,
        lng: 36.5399,
        locationName: 'خط اتصالات ميداني',
        status: 'arrived',
        isSos: 0,
      ),
    ];

    for (final s in samples) {
      await insertReport(
        reportUuid: uuid.v4(),
        militaryId: s.militaryId,
        reporterName: s.reporterName,
        injuryType: s.injuryType,
        injuryDescription: s.injuryDescription,
        lat: s.lat,
        lng: s.lng,
        locationName: s.locationName,
        status: s.status,
        isSos: s.isSos,
        isSynced: 1,
      );
    }
  }

  Future<int> updateUserProfile({
    required int userId,
    required String fullName,
    String? unit,
    String? phone,
  }) async {
    final db = await database;
    return db.update(
      'users',
      {
        'full_name': fullName,
        'unit': unit,
        'phone': phone,
        'last_active': DateFormatter.nowIso(),
      },
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<Database> ensureSeeded() async {
    final db = await database;
    await _seedDatabase(db);
    await _seedSampleReports(db);
    return db;
  }
}
