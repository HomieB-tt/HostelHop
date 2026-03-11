/// Date formatting utilities.
/// No external packages — pure Dart.
///
/// Usage:
///   DateHelpers.format(date)         → 'Jan 5, 2025'
///   DateHelpers.timeAgo(date)        → '3 days ago'
///   DateHelpers.dateRange(d1, d2)    → 'Jan 5 – May 30, 2025'
abstract final class DateHelpers {
  DateHelpers._();

  static const _months = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static const _fullMonths = [
    '',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  // ── Short date: Jan 5, 2025 ───────────────────────────────────────────────
  static String format(DateTime date) =>
      '${_months[date.month]} ${date.day}, ${date.year}';

  // ── Full date: January 5, 2025 ────────────────────────────────────────────
  static String formatFull(DateTime date) =>
      '${_fullMonths[date.month]} ${date.day}, ${date.year}';

  // ── Day + month only: Jan 5 ───────────────────────────────────────────────
  static String formatShort(DateTime date) =>
      '${_months[date.month]} ${date.day}';

  // ── Date range: Jan 5 – May 30, 2025 ─────────────────────────────────────
  static String dateRange(DateTime from, DateTime to) {
    final inMonth = _months[from.month];
    final outMonth = _months[to.month];
    if (from.year == to.year) {
      return '$inMonth ${from.day} – $outMonth ${to.day}, ${to.year}';
    }
    return '${format(from)} – ${format(to)}';
  }

  // ── Relative time: 3 days ago / just now ─────────────────────────────────
  static String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} weeks ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()} months ago';
    return '${(diff.inDays / 365).floor()} years ago';
  }

  // ── Duration label: 5 months ──────────────────────────────────────────────
  static String durationLabel(DateTime from, DateTime to) {
    final days = to.difference(from).inDays;
    if (days < 7) return '$days days';
    if (days < 30) return '${(days / 7).floor()} weeks';
    if (days < 365) return '${(days / 30).floor()} months';
    return '${(days / 365).floor()} years';
  }

  // ── Semester label: Semester 1 · Jan – May 2025 ───────────────────────────
  static String semesterLabel(DateTime from, DateTime to) {
    final semester = from.month <= 6 ? '1' : '2';
    return 'Semester $semester · ${_months[from.month]} – '
        '${_months[to.month]} ${to.year}';
  }

  // ── ISO to DateTime (safe parse) ──────────────────────────────────────────
  static DateTime? tryParse(String? iso) {
    if (iso == null || iso.isEmpty) return null;
    return DateTime.tryParse(iso);
  }

  static DateTime parseOrNow(String? iso) => tryParse(iso) ?? DateTime.now();
}
