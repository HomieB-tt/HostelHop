import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../config/app_theme.dart';
import '../../utils/price_formatter.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';

// ── Filter state model ─────────────────────────────────────────────────────────
/// Immutable filter state passed between SearchScreen and FilterSheet.
class HostelFilterState {
  const HostelFilterState({
    this.minPrice,
    this.maxPrice,
    this.amenities = const [],
    this.availableOnly = false,
  });

  final int? minPrice;
  final int? maxPrice;
  final List<String> amenities;
  final bool availableOnly;

  bool get hasActiveFilters =>
      minPrice != null ||
      maxPrice != null ||
      amenities.isNotEmpty ||
      availableOnly;

  int get activeCount {
    int count = 0;
    if (minPrice != null || maxPrice != null) count++;
    if (availableOnly) count++;
    count += amenities.length;
    return count;
  }

  HostelFilterState copyWith({
    int? minPrice,
    int? maxPrice,
    List<String>? amenities,
    bool? availableOnly,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
  }) {
    return HostelFilterState(
      minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
      amenities: amenities ?? this.amenities,
      availableOnly: availableOnly ?? this.availableOnly,
    );
  }
}

// ── Filter sheet ───────────────────────────────────────────────────────────────
/// Bottom sheet launched from SearchScreen.
/// Not a GoRouter route — opened with showModalBottomSheet.
///
/// Usage (in SearchScreen):
///   showModalBottomSheet(
///     context: context,
///     isScrollControlled: true,
///     builder: (_) => FilterSheet(
///       initial: _filters,
///       onApply: (f) { ... },
///       onClear: () { ... },
///     ),
///   );
class FilterSheet extends StatefulWidget {
  const FilterSheet({
    super.key,
    required this.initial,
    required this.onApply,
    required this.onClear,
  });

  final HostelFilterState initial;
  final void Function(HostelFilterState) onApply;
  final VoidCallback onClear;

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late final TextEditingController _minPriceCtrl;
  late final TextEditingController _maxPriceCtrl;
  late List<String> _amenities;
  late bool _availableOnly;

  static const _allAmenities = [
    'WiFi',
    'Water',
    'Security',
    'Parking',
    'Laundry',
    'Kitchen',
    'Study Room',
    'Generator',
    'CCTV',
    'Cleaning',
    'Gym',
    'Air Conditioning',
    'Balcony',
    'TV',
  ];

  // Quick price presets (UGX)
  static const _pricePresets = <_PricePreset>[
    _PricePreset(label: 'Under 500K', max: 500000),
    _PricePreset(label: '500K–1M', min: 500000, max: 1000000),
    _PricePreset(label: '1M–2M', min: 1000000, max: 2000000),
    _PricePreset(label: '2M+', min: 2000000),
  ];

  @override
  void initState() {
    super.initState();
    final f = widget.initial;
    _minPriceCtrl = TextEditingController(
      text: f.minPrice != null ? '${f.minPrice}' : '',
    );
    _maxPriceCtrl = TextEditingController(
      text: f.maxPrice != null ? '${f.maxPrice}' : '',
    );
    _amenities = List.from(f.amenities);
    _availableOnly = f.availableOnly;
  }

  @override
  void dispose() {
    _minPriceCtrl.dispose();
    _maxPriceCtrl.dispose();
    super.dispose();
  }

  void _applyPreset(_PricePreset preset) {
    setState(() {
      _minPriceCtrl.text = preset.min != null ? '${preset.min}' : '';
      _maxPriceCtrl.text = preset.max != null ? '${preset.max}' : '';
    });
  }

  bool _isPresetActive(_PricePreset preset) {
    final min = _minPriceCtrl.text.isNotEmpty
        ? int.tryParse(_minPriceCtrl.text)
        : null;
    final max = _maxPriceCtrl.text.isNotEmpty
        ? int.tryParse(_maxPriceCtrl.text)
        : null;
    return min == preset.min && max == preset.max;
  }

  void _toggleAmenity(String amenity) {
    setState(() {
      if (_amenities.contains(amenity)) {
        _amenities.remove(amenity);
      } else {
        _amenities.add(amenity);
      }
    });
  }

  void _apply() {
    final min = _minPriceCtrl.text.isNotEmpty
        ? int.tryParse(_minPriceCtrl.text.trim())
        : null;
    final max = _maxPriceCtrl.text.isNotEmpty
        ? int.tryParse(_maxPriceCtrl.text.trim())
        : null;

    widget.onApply(
      HostelFilterState(
        minPrice: min,
        maxPrice: max,
        amenities: List.from(_amenities),
        availableOnly: _availableOnly,
      ),
    );
  }

  int get _activeCount {
    int count = 0;
    if (_minPriceCtrl.text.isNotEmpty || _maxPriceCtrl.text.isNotEmpty) {
      count++;
    }
    if (_availableOnly) count++;
    count += _amenities.length;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollCtrl) => Column(
        children: [
          // ── Handle + header ────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
            child: Column(
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text(
                      'Filter Results',
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    const Spacer(),
                    if (_activeCount > 0)
                      TextButton(
                        onPressed: () {
                          widget.onClear();
                        },
                        child: const Text(
                          'Clear all',
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppColors.textHintLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.borderLight),

          // ── Scrollable content ─────────────────────────────────────────────
          Expanded(
            child: ListView(
              controller: scrollCtrl,
              padding: const EdgeInsets.all(16),
              children: [
                // ── Availability ─────────────────────────────────────────────
                const _SectionLabel(title: 'Availability'),
                const SizedBox(height: 8),
                _ToggleTile(
                  icon: Icons.door_front_door_outlined,
                  label: 'Available rooms only',
                  subtitle: 'Hide fully booked hostels',
                  value: _availableOnly,
                  onChanged: (v) => setState(() => _availableOnly = v),
                ),

                const SizedBox(height: 20),

                // ── Price range ───────────────────────────────────────────────
                const _SectionLabel(title: 'Price per Semester (UGX)'),
                const SizedBox(height: 10),

                // Presets
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _pricePresets.map((p) {
                    final active = _isPresetActive(p);
                    return GestureDetector(
                      onTap: () => _applyPreset(p),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: active ? AppColors.orangeBright : Colors.white,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            color: active
                                ? AppColors.orangeBright
                                : AppColors.borderLight,
                          ),
                        ),
                        child: Text(
                          p.label,
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: active
                                ? Colors.white
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 12),

                // Custom range inputs
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'Min Price',
                        hint: '500000',
                        controller: _minPriceCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        label: 'Max Price',
                        hint: '2000000',
                        controller: _maxPriceCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        textInputAction: TextInputAction.done,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ── Amenities ─────────────────────────────────────────────────
                _SectionLabel(
                  title: 'Amenities',
                  trailing: _amenities.isNotEmpty
                      ? '${_amenities.length} selected'
                      : null,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _allAmenities.map((a) {
                    final selected = _amenities.contains(a);
                    return GestureDetector(
                      onTap: () => _toggleAmenity(a),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.orangeBright.withValues(alpha: 0.1)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            color: selected
                                ? AppColors.orangeBright
                                : AppColors.borderLight,
                          ),
                        ),
                        child: Text(
                          a,
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? AppColors.orangePrimary
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),

          // ── Apply button ───────────────────────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              12 + MediaQuery.of(context).padding.bottom,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.borderLight)),
            ),
            child: AppButton(
              label: _activeCount > 0
                  ? 'Apply ($_activeCount filter${_activeCount == 1 ? '' : 's'})'
                  : 'Apply Filters',
              onPressed: _apply,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Sora',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimaryLight,
          ),
        ),
        if (trailing != null)
          Text(
            trailing!,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 12,
              color: AppColors.orangeBright,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value ? AppColors.orangeBright : AppColors.borderLight,
          width: value ? 1.5 : 1,
        ),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        secondary: Icon(
          icon,
          color: value ? AppColors.orangeBright : AppColors.textSecondaryLight,
          size: 20,
        ),
        title: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Sora',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 11,
            color: AppColors.textHintLight,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.orangeBright,
      ),
    );
  }
}

// ── Price preset model ─────────────────────────────────────────────────────────
class _PricePreset {
  const _PricePreset({required this.label, this.min, this.max});

  final String label;
  final int? min;
  final int? max;
}
