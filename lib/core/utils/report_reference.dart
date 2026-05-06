class ReportReference {
  ReportReference._();

  /// رقم مرجعي قصير وثابت للعرض والمتابعة: BLG-YYYY-NNNNNN
  static String format(int id, String createdAtIso) {
    final year = (createdAtIso.length >= 4)
        ? createdAtIso.substring(0, 4)
        : DateTime.now().year.toString();
    return 'BLG-$year-${id.toString().padLeft(6, '0')}';
  }
}
