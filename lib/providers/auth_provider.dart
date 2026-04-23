import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/database/database_helper.dart';
import '../core/enums/user_role.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;

  UserRole get userRole {
    final raw = _currentUser?.role;
    return UserRole.values.firstWhere(
      (r) => r.value == raw,
      orElse: () => UserRole.soldier,
    );
  }

  Future<bool> login(String militaryId, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final db = await DatabaseHelper.instance.ensureSeeded();
      final rows = await db.query(
        'users',
        where: 'military_id = ?',
        whereArgs: [militaryId.trim()],
        limit: 1,
      );
      if (rows.isEmpty) {
        _errorMessage = 'بيانات الدخول غير صحيحة';
        return false;
      }
      final row = rows.first;
      if (row['password_hash'] != password) {
        _errorMessage = 'بيانات الدخول غير صحيحة';
        return false;
      }
      final user = UserModel.fromMap(row);
      _currentUser = user;
      await _persistSession(user);
      return true;
    } catch (e) {
      _errorMessage = 'حدث خطأ أثناء تسجيل الدخول';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _persistSession(UserModel user) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('isnad_user_id', user.id ?? 0);
    await p.setString('isnad_military_id', user.militaryId);
    await p.setString('isnad_full_name', user.fullName);
    await p.setString('isnad_role', user.role);
  }

  Future<void> logout() async {
    final p = await SharedPreferences.getInstance();
    await p.remove('isnad_user_id');
    await p.remove('isnad_military_id');
    await p.remove('isnad_full_name');
    await p.remove('isnad_role');
    _currentUser = null;
    notifyListeners();
  }

  Future<void> checkSavedSession() async {
    _isLoading = true;
    notifyListeners();
    try {
      final p = await SharedPreferences.getInstance();
      final id = p.getInt('isnad_user_id');
      final mid = p.getString('isnad_military_id');
      if (id == null || id == 0 || mid == null) {
        return;
      }
      final db = await DatabaseHelper.instance.ensureSeeded();
      final rows = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (rows.isEmpty) {
        await logout();
        return;
      }
      _currentUser = UserModel.fromMap(rows.first);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    required String fullName,
    String? unit,
    String? phone,
  }) async {
    final u = _currentUser;
    final id = u?.id;
    if (u == null || id == null) return false;
    final name = fullName.trim();
    if (name.isEmpty) return false;
    String? trimOrNull(String? s) {
      if (s == null) return null;
      final t = s.trim();
      return t.isEmpty ? null : t;
    }

    try {
      await DatabaseHelper.instance.updateUserProfile(
        userId: id,
        fullName: name,
        unit: trimOrNull(unit),
        phone: trimOrNull(phone),
      );
      _currentUser = u.copyWith(
        fullName: name,
        unit: trimOrNull(unit),
        phone: trimOrNull(phone),
      );
      await _persistSession(_currentUser!);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
