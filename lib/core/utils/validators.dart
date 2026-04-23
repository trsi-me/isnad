class Validators {
  Validators._();

  static String? militaryId(String? v) {
    if (v == null || v.trim().isEmpty) {
      return 'أدخل رقم الهوية العسكرية';
    }
    if (v.trim().length < 3) {
      return 'رقم الهوية قصير جداً';
    }
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) {
      return 'أدخل كلمة المرور';
    }
    return null;
  }

  static String? requiredText(String? v, String message) {
    if (v == null || v.trim().isEmpty) return message;
    return null;
  }
}
