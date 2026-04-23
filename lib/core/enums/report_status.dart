enum ReportStatus {
  open,
  received,
  responding,
  arrived,
  closed,
}

extension ReportStatusExtension on ReportStatus {
  String get displayName {
    switch (this) {
      case ReportStatus.open:
        return 'مفتوح';
      case ReportStatus.received:
        return 'تم الاستلام';
      case ReportStatus.responding:
        return 'فريق في الطريق';
      case ReportStatus.arrived:
        return 'تم الوصول';
      case ReportStatus.closed:
        return 'مغلق';
    }
  }

  String get value => name;
}

ReportStatus? reportStatusFromString(String? raw) {
  if (raw == null) return null;
  for (final s in ReportStatus.values) {
    if (s.value == raw) return s;
  }
  return null;
}
