enum InjuryType {
  gunshot,
  shrapnel,
  burn,
  fracture,
  blast,
  other,
}

extension InjuryTypeExtension on InjuryType {
  String get displayName {
    switch (this) {
      case InjuryType.gunshot:
        return 'طلق ناري';
      case InjuryType.shrapnel:
        return 'شظايا';
      case InjuryType.burn:
        return 'حروق';
      case InjuryType.fracture:
        return 'كسر';
      case InjuryType.blast:
        return 'إصابة انفجارية';
      case InjuryType.other:
        return 'أخرى';
    }
  }

  String get value => name;
}

InjuryType? injuryTypeFromString(String? raw) {
  if (raw == null) return null;
  for (final t in InjuryType.values) {
    if (t.value == raw) return t;
  }
  return null;
}
