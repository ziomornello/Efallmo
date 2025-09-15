class AppDate {
  // Parse dd/MM/yyyy -> DateTime (local). Returns null if invalid.
  static DateTime? tryParseDdMmYyyy(String? text) {
    if (text == null) return null;
    final t = text.trim();
    if (t.isEmpty) return null;
    final parts = t.split('/');
    if (parts.length != 3) return null;
    final d = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final y = int.tryParse(parts[2]);
    if (d == null || m == null || y == null) return null;
    if (y < 100) return null;
    try {
      return DateTime(y, m, d);
    } catch (_) {
      return null;
    }
  }

  static bool isExpired(String? expiryText) {
    final dt = tryParseDdMmYyyy(expiryText);
    if (dt == null) return false;
    final now = DateTime.now();
    return dt.isBefore(DateTime(now.year, now.month, now.day));
  }
}