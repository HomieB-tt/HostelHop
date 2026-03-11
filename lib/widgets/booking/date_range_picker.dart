import 'package:flutter/material.dart';

import '../../../config/app_theme.dart';
import '../../../utils/constants.dart';
import '../../../utils/date_helpers.dart';

/// A date range selector widget for the booking screen.
///
/// Shows two tappable date tiles (check-in / check-out) that open
/// Flutter's built-in date picker. Also provides quick semester
/// preset buttons.
///
/// Usage:
///   DateRangePicker(
///     checkIn: _checkIn,
///     checkOut: _checkOut,
///     onChanged: (in, out) => setState(() { _checkIn = in; _checkOut = out; }),
///   )
class DateRangePicker extends StatelessWidget {
  const DateRangePicker({
    super.key,
    required this.checkIn,
    required this.checkOut,
    required this.onChanged,
    this.minDate,
    this.maxDate,
  });

  final DateTime? checkIn;
  final DateTime? checkOut;
  final void Function(DateTime checkIn, DateTime checkOut) onChanged;
  final DateTime? minDate;
  final DateTime? maxDate;

  // ── Semester presets ───────────────────────────────────────────────────────
  static final _presets = <_Preset>[
    _Preset(
      label: 'Sem 1',
      sublabel: 'Feb – Jul',
      checkIn: DateTime(DateTime.now().year, 2, 1),
      checkOut: DateTime(DateTime.now().year, 7, 31),
    ),
    _Preset(
      label: 'Sem 2',
      sublabel: 'Aug – Jan',
      checkIn: DateTime(DateTime.now().year, 8, 1),
      checkOut: DateTime(DateTime.now().year + 1, 1, 31),
    ),
    _Preset(
      label: 'Full Year',
      sublabel: 'Both sems',
      checkIn: DateTime(DateTime.now().year, 2, 1),
      checkOut: DateTime(DateTime.now().year + 1, 1, 31),
    ),
  ];

  Future<void> _pickDate({
    required BuildContext context,
    required bool isCheckIn,
  }) async {
    final firstDate = minDate ?? DateTime.now();
    final lastDate = maxDate ?? DateTime(DateTime.now().year + 2);
    final initial = isCheckIn
        ? (checkIn ?? DateTime.now())
        : (checkOut ??
              (checkIn?.add(const Duration(days: AppConstants.semesterDays)) ??
                  DateTime.now()));

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.orangeBright,
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );

    if (picked == null) return;

    if (isCheckIn) {
      final newCheckOut = picked.add(
        const Duration(days: AppConstants.semesterDays),
      );
      onChanged(picked, newCheckOut);
    } else {
      onChanged(checkIn ?? DateTime.now(), picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Preset buttons ───────────────────────────────────────────────────
        Row(
          children: _presets.map((p) {
            final isActive =
                checkIn != null &&
                checkOut != null &&
                _isSameDay(checkIn!, p.checkIn) &&
                _isSameDay(checkOut!, p.checkOut);

            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(p.checkIn, p.checkOut),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: EdgeInsets.only(right: p == _presets.last ? 0 : 8),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.orangeBright
                        : AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isActive
                          ? AppColors.orangeBright
                          : AppColors.borderLight,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        p.label,
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isActive
                              ? Colors.white
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        p.sublabel,
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 10,
                          color: isActive
                              ? Colors.white70
                              : AppColors.textHintLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 12),

        // ── Date tiles ───────────────────────────────────────────────────────
        Row(
          children: [
            // Check-in
            Expanded(
              child: _DateTile(
                icon: Icons.flight_land_rounded,
                label: 'Check-in',
                date: checkIn,
                onTap: () => _pickDate(context: context, isCheckIn: true),
              ),
            ),
            const SizedBox(width: 10),

            // Arrow
            const Icon(
              Icons.arrow_forward_rounded,
              size: 16,
              color: AppColors.textHintLight,
            ),

            const SizedBox(width: 10),

            // Check-out
            Expanded(
              child: _DateTile(
                icon: Icons.flight_takeoff_rounded,
                label: 'Check-out',
                date: checkOut,
                onTap: () => _pickDate(context: context, isCheckIn: false),
              ),
            ),
          ],
        ),

        // ── Duration label ───────────────────────────────────────────────────
        if (checkIn != null && checkOut != null) ...[
          const SizedBox(height: 8),
          Center(
            child: Text(
              '📅 ${DateHelpers.durationLabel(checkIn!, checkOut!)}',
              style: const TextStyle(
                fontFamily: 'Sora',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.orangeBright,
              ),
            ),
          ),
        ],
      ],
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// ── Date tile ──────────────────────────────────────────────────────────────────
class _DateTile extends StatelessWidget {
  const _DateTile({
    required this.icon,
    required this.label,
    required this.date,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasDate = date != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasDate ? AppColors.orangeBright : AppColors.borderLight,
            width: hasDate ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: hasDate ? AppColors.orangeBright : AppColors.textHintLight,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 10,
                      color: AppColors.textHintLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasDate ? DateHelpers.formatShort(date!) : 'Select date',
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: hasDate
                          ? AppColors.textPrimaryLight
                          : AppColors.textHintLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Preset model ───────────────────────────────────────────────────────────────
class _Preset {
  const _Preset({
    required this.label,
    required this.sublabel,
    required this.checkIn,
    required this.checkOut,
  });

  final String label;
  final String sublabel;
  final DateTime checkIn;
  final DateTime checkOut;
}
