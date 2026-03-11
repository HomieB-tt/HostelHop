import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/hostel_model.dart';
import '../../repositories/hostel_repository.dart';

part 'hostel_provider.g.dart';

// ── Hostel list ────────────────────────────────────────────────────────────────
/// Watched by home_screen.dart as:
///   final hostelState = ref.watch(hostelListProvider);
///   hostelState.when(loading:..., error:..., data:...)
@riverpod
class HostelList extends _$HostelList {
  late final HostelRepository _repo;

  @override
  Future<List<HostelModel>> build() async {
    _repo = const HostelRepository();
    return _repo.fetchAll();
  }

  // ── Refresh (pull-to-refresh) ──────────────────────────────────────────────
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.fetchAll());
  }

  // ── Search ─────────────────────────────────────────────────────────────────
  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      await refresh();
      return;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.search(query.trim()));
  }

  // ── Filter ─────────────────────────────────────────────────────────────────
  Future<void> applyFilters({
    int? maxPrice,
    int? minPrice,
    List<String>? amenities,
    bool? hasAvailableRooms,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _repo.fetchFiltered(
        maxPrice: maxPrice,
        minPrice: minPrice,
        amenities: amenities,
        hasAvailableRooms: hasAvailableRooms,
      ),
    );
  }
}

// ── Hostel detail (family) ─────────────────────────────────────────────────────
/// Watched by hostel_detail_screen and booking_screen as:
///   final hostelAsync = ref.watch(hostelDetailProvider(hostelId));
@riverpod
Future<HostelModel> hostelDetail(Ref ref, String hostelId) async {
  final repo = const HostelRepository();
  return repo.fetchById(hostelId);
}

// ── Owner hostel list ──────────────────────────────────────────────────────────
/// Watched by owner dashboard as:
///   final hostelsAsync = ref.watch(ownerHostelListProvider);
@riverpod
Future<List<HostelModel>> ownerHostelList(Ref ref) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return [];
  return const HostelRepository().fetchByOwner(userId);
}
