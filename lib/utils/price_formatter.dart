/// Price formatting utilities for Ugandan Shillings (UGX).
///
/// Usage:
///   PriceFormatter.format(250000)   → 'UGX 250,000'
///   PriceFormatter.compact(250000)  → 'UGX 250K'
///   PriceFormatter.raw(250000)      → '250,000'
abstract final class PriceFormatter {
  PriceFormatter._();

  // ── Full format: UGX 1,250,000 ────────────────────────────────────────────
  static String format(int amount) => 'UGX ${raw(amount)}';

  // ── Raw with commas: 1,250,000 ────────────────────────────────────────────
  static String raw(int amount) => amount
      .toString()
      .replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );

  // ── Compact: UGX 1.25M / UGX 250K ────────────────────────────────────────
  static String compact(int amount) {
    if (amount >= 1_000_000) {
      final m = amount / 1_000_000;
      final label = m == m.truncateToDouble() ? '${m.toInt()}M' : '${m.toStringAsFixed(1)}M';
      return 'UGX $label';
    }
    if (amount >= 1_000) {
      final k = amount / 1_000;
      final label = k == k.truncateToDouble() ? '${k.toInt()}K' : '${k.toStringAsFixed(1)}K';
      return 'UGX $label';
    }
    return format(amount);
  }

  // ── Per semester label: UGX 250,000 / sem ─────────────────────────────────
  static String perSemester(int amount) => '${format(amount)} / sem';

  // ── Commitment fee label: UGX 50,000 commitment ───────────────────────────
  static String commitment(int amount) => '${format(amount)} commitment';

  // ── Parse a formatted string back to int ──────────────────────────────────
  /// Strips 'UGX', commas, spaces → returns int.
  /// Returns 0 on parse failure.
  static int parse(String formatted) {
    final cleaned = formatted
        .replaceAll('UGX', '')
        .replaceAll(',', '')
        .replaceAll(' ', '')
        .trim();
    return int.tryParse(cleaned) ?? 0;
  }
}
