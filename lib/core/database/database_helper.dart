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
        'unit': 'الكتيبة الأولى',
        'phone': '0500000001',
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
      required String status,
      required int isSos,
      required int isSynced,
    }) async {
      await db.insert('reports', {
        'report_uuid': reportUuid,
        'military_id': militaryId,
        'reporter_name': reporterName,
        'injury_type': injuryType,
        'injury_description': injuryDescription,
        'location_lat': lat,
        'location_lng': lng,
        'location_name': lat != null ? 'منطقة تبوك (تجريبي)' : null,
        'media_path': null,
        'status': status,
        'is_sos': isSos,
        'is_synced': isSynced,
        'created_at': now,
        'updated_at': now,
      });
    }

    await insertReport(
      reportUuid: uuid.v4(),
      militaryId: '1001',
      reporterName: 'جندي أحمد التجريبي',
      injuryType: 'gunshot',
      injuryDescription: 'بلاغ تجريبي — إصابة طلق ناري (عرض)',
      lat: 28.3998,
      lng: 36.5705,
      status: 'open',
      isSos: 0,
      isSynced: 1,
    );
    await insertReport(
      reportUuid: uuid.v4(),
      militaryId: '1001',
      reporterName: 'جندي أحمد التجريبي',
      injuryType: 'shrapnel',
      injuryDescription: 'بلاغ قيد المتابعة (تجريبي)',
      lat: 28.4150,
      lng: 36.5550,
      status: 'responding',
      isSos: 0,
      isSynced: 1,
    );
    await insertReport(
      reportUuid: uuid.v4(),
      militaryId: '1001',
      reporterName: 'جندي أحمد التجريبي',
      injuryType: 'other',
      injuryDescription: 'بلاغ طوارئ تجريبي',
      lat: 28.3800,
      lng: 36.5800,
      status: 'open',
      isSos: 1,
      isSynced: 1,
    );
    await insertReport(
      reportUuid: uuid.v4(),
      militaryId: '2001',
      reporterName: 'قائد محمد التجريبي',
      injuryType: 'fracture',
      injuryDescription: 'بلاغ من حساب القيادة (عرض)',
      lat: 28.4100,
      lng: 36.5600,
      status: 'received',
      isSos: 0,
      isSynced: 1,
    );
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
