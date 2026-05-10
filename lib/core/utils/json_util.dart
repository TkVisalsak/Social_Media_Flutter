
class JsonUtils {
  static int toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool toBool(dynamic value) {
    if (value is bool) return value;
    final v = value?.toString().toLowerCase();
    return v == 'true' || v == '1';
  }

  static DateTime toDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    return DateTime.tryParse(value.toString()) ?? DateTime.now();
  }

  static String? nullableString(dynamic value) {
    if (value == null) return null;
    final s = value.toString().trim();
    return s.isEmpty ? null : s;
  }
}