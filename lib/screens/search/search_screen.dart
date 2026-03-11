import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../models/hostel_model.dart';
import '../../providers/hostel_provider.dart';
import '../../utils/price_formatter.dart';
import '../../widgets/common/app_empty_state.dart';
import '../../widgets/common/app_error_widget.dart';
import '../../widgets/common/app_loading_indicator.dart';
import '../../widgets/common/fade_up_widget.dart';
import '../../widgets/common/app_network_image.dart';
import '../../widgets/hostel/star_rating_bar.dart';
import '../../widgets/hostel/verified_badge.dart';
import 'filter_sheet.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchCtrl = TextEditingController();
  final _focusNode = FocusNode();

  // Active filter state — kept here so filter sheet can read & update it
  HostelFilterState _filters = const HostelFilterState();

  @override
  void initState() {
    super.initState();
    // Auto-focus search field on open
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _focusNode.requestFocus(),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ── Debounced search ───────────────────────────────────────────────────────
  void _onSearchChanged(String query) {
    if (_filters.hasActiveFilters) {
      // If filters are active, don't override with search
      return;
    }
    ref.read(hostelListProvider.notifier).search(query);
  }

  void _clearSearch() {
    _searchCtrl.clear();
    _focusNode.requestFocus();
    if (_filters.hasActiveFilters) {
      _applyFilters(_filters);
    } else {
      ref.read(hostelListProvider.notifier).refresh();
    }
  }

  // ── Apply filters from sheet ───────────────────────────────────────────────
  void _applyFilters(HostelFilterState filters) {
    setState(() => _filters = filters);
    ref
        .read(hostelListProvider.notifier)
        .applyFilters(
          minPrice: filters.minPrice,
          maxPrice: filters.maxPrice,
          amenities: filters.amenities.isEmpty ? null : filters.amenities,
          hasAvailableRooms: filters.availableOnly ? true : null,
        );
  }

  void _clearFilters() {
    setState(() => _filters = const HostelFilterState());
    final query = _searchCtrl.text.trim();
    if (query.isNotEmpty) {
      ref.read(hostelListProvider.notifier).search(query);
    } else {
      ref.read(hostelListProvider.notifier).refresh();
    }
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => FilterSheet(
        initial: _filters,
        onApply: (filters) {
          _applyFilters(filters);
          Navigator.pop(context);
        },
        onClear: () {
          _clearFilters();
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hostelsAsync = ref.watch(hostelListProvider);
    final hasFilters = _filters.hasActiveFilters;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimaryLight,
        elevation: 0,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: _SearchBar(
            controller: _searchCtrl,
            focusNode: _focusNode,
            onChanged: _onSearchChanged,
            onClear: _clearSearch,
          ),
        ),
        bottom: hasFilters
            ? PreferredSize(
                preferredSize: const Size.fromHeight(40),
                child: _FilterChipsBar(
                  filters: _filters,
                  onClear: _clearFilters,
                ),
              )
            : const PreferredSize(
                preferredSize: Size.fromHeight(1),
                child: Divider(height: 1, color: AppColors.borderLight),
              ),
      ),
      body: hostelsAsync.when(
        loading: () => const AppLoadingScreen(),
        error: (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.read(hostelListProvider.notifier).refresh(),
        ),
        data: (hostels) {
          if (hostels.isEmpty) {
            return AppEmptyState.noResults(
              onCta: _searchCtrl.text.isNotEmpty || hasFilters
                  ? () {
                      _searchCtrl.clear();
                      _clearFilters();
                    }
                  : null,
            );
          }
          return FadeUpWidget(child: _ResultsList(hostels: hostels));
        },
      ),

      // ── Filter FAB ─────────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openFilterSheet,
        backgroundColor: hasFilters ? AppColors.orangePrimary : Colors.white,
        foregroundColor: hasFilters ? Colors.white : AppColors.textPrimaryLight,
        elevation: hasFilters ? 4 : 2,
        icon: Icon(
          Icons.tune_rounded,
          color: hasFilters ? Colors.white : AppColors.orangeBright,
        ),
        label: Text(
          hasFilters ? 'Filters (${_filters.activeCount})' : 'Filter',
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: hasFilters ? Colors.white : AppColors.textPrimaryLight,
          ),
        ),
      ),
    );
  }
}

// ── Search bar ─────────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (_, value, __) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: onChanged,
          textInputAction: TextInputAction.search,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 14,
            color: AppColors.textPrimaryLight,
          ),
          decoration: InputDecoration(
            hintText: 'Search hostels, locations…',
            hintStyle: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14,
              color: AppColors.textHintLight,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              size: 20,
              color: AppColors.textHintLight,
            ),
            suffixIcon: value.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: AppColors.textHintLight,
                    ),
                    onPressed: onClear,
                  )
                : null,
            filled: true,
            fillColor: AppColors.backgroundLight,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.orangeBright,
                width: 1.5,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Active filter chips bar ────────────────────────────────────────────────────
class _FilterChipsBar extends StatelessWidget {
  const _FilterChipsBar({required this.filters, required this.onClear});

  final HostelFilterState filters;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      color: Colors.white,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        children: [
          // Clear all chip
          _Chip(
            label: 'Clear all',
            icon: Icons.close_rounded,
            onTap: onClear,
            active: true,
            activeColor: AppColors.error,
          ),

          if (filters.minPrice != null || filters.maxPrice != null) ...[
            const SizedBox(width: 6),
            _Chip(label: _priceLabel(filters), icon: Icons.payments_outlined),
          ],

          if (filters.availableOnly) ...[
            const SizedBox(width: 6),
            const _Chip(
              label: 'Available only',
              icon: Icons.door_front_door_outlined,
            ),
          ],

          for (final a in filters.amenities) ...[
            const SizedBox(width: 6),
            _Chip(label: a, icon: Icons.check_circle_outline_rounded),
          ],
        ],
      ),
    );
  }

  String _priceLabel(HostelFilterState f) {
    if (f.minPrice != null && f.maxPrice != null) {
      return '${PriceFormatter.compact(f.minPrice!)} – '
          '${PriceFormatter.compact(f.maxPrice!)}';
    }
    if (f.maxPrice != null) {
      return 'Max ${PriceFormatter.compact(f.maxPrice!)}';
    }
    return 'Min ${PriceFormatter.compact(f.minPrice!)}';
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.icon,
    this.onTap,
    this.active = false,
    this.activeColor,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool active;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    final color = activeColor ?? AppColors.orangeBright;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Results list ───────────────────────────────────────────────────────────────
class _ResultsList extends StatelessWidget {
  const _ResultsList({required this.hostels});
  final List<HostelModel> hostels;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Result count
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Text(
            '${hostels.length} hostel${hostels.length == 1 ? '' : 's'} found',
            style: const TextStyle(
              fontFamily: 'Sora',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            itemCount: hostels.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _SearchResultCard(hostel: hostels[i]),
          ),
        ),
      ],
    );
  }
}

// ── Search result card ─────────────────────────────────────────────────────────
class _SearchResultCard extends StatefulWidget {
  const _SearchResultCard({required this.hostel});
  final HostelModel hostel;

  @override
  State<_SearchResultCard> createState() => _SearchResultCardState();
}

class _SearchResultCardState extends State<_SearchResultCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hostel = widget.hostel;
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        context.push(AppRoutes.hostelDetail(hostel.id));
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Image (Hero source)
              Hero(
                tag: 'hostel-image-${hostel.id}',
                child: ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(14),
                  ),
                  child: AppNetworkImage(
                    url: hostel.imageUrls.isNotEmpty
                        ? hostel.imageUrls.first
                        : null,
                    width: 110,
                    height: 110,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name + verified
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              hostel.name,
                              style: const TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimaryLight,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (hostel.isVerified) ...[
                            const SizedBox(width: 4),
                            const VerifiedBadge(),
                          ],
                        ],
                      ),

                      const SizedBox(height: 3),

                      // Location
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 11,
                            color: AppColors.textHintLight,
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              hostel.location,
                              style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 11,
                                color: AppColors.textHintLight,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // Star rating
                      StarRatingBar(
                        rating: hostel.rating,
                        reviewCount: hostel.reviewCount,
                        size: 11,
                      ),

                      const SizedBox(height: 6),

                      // Price + availability
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                PriceFormatter.format(hostel.pricePerSemester),
                                style: const TextStyle(
                                  fontFamily: 'Sora',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.orangeBright,
                                ),
                              ),
                              const Text(
                                'per semester',
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 9,
                                  color: AppColors.textHintLight,
                                ),
                              ),
                            ],
                          ),
                          _AvailabilityBadge(hostel: hostel),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ), // closes AnimatedBuilder child Container
      ), // closes AnimatedBuilder
    ); // closes GestureDetector
  }
}

// ── Availability badge ─────────────────────────────────────────────────────────
class _AvailabilityBadge extends StatelessWidget {
  const _AvailabilityBadge({required this.hostel});
  final HostelModel hostel;

  @override
  Widget build(BuildContext context) {
    if (hostel.isSoldOut) {
      return _badge('Sold out', AppColors.error);
    }
    if (hostel.isAlmostFull) {
      return _badge('${hostel.roomsAvailable} left', AppColors.warning);
    }
    return _badge('${hostel.roomsAvailable} available', AppColors.success);
  }

  Widget _badge(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(50),
      border: Border.all(color: color.withValues(alpha: 0.3)),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontFamily: 'Sora',
        fontSize: 9,
        fontWeight: FontWeight.w700,
        color: color,
      ),
    ),
  );
}
