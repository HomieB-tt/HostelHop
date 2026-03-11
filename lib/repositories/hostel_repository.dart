import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/hostel_model.dart';
import '../../supabase/supabase_client.dart';

class HostelRepository {
  const HostelRepository();

  // ── Table name ─────────────────────────────────────────────────────────────
  static const _table = 'hostels';

  // ── Fetch all active hostels ───────────────────────────────────────────────
  Future<List<HostelModel>> fetchAll() async {
    final response = await supabase
        .from(_table)
        .select()
        .eq('is_active', true)
        .order('created_at', ascending: false);

    return (response as List)
        .map((e) => HostelModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Fetch single hostel by id ──────────────────────────────────────────────
  Future<HostelModel> fetchById(String hostelId) async {
    final response = await supabase
        .from(_table)
        .select()
        .eq('id', hostelId)
        .single();

    return HostelModel.fromJson(response);
  }

  // ── Fetch hostels by owner ─────────────────────────────────────────────────
  Future<List<HostelModel>> fetchByOwner(String ownerId) async {
    final response = await supabase
        .from(_table)
        .select()
        .eq('owner_id', ownerId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((e) => HostelModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Search hostels by name or location ────────────────────────────────────
  Future<List<HostelModel>> search(String query) async {
    final response = await supabase
        .from(_table)
        .select()
        .eq('is_active', true)
        .or('name.ilike.%$query%,location.ilike.%$query%')
        .order('rating', ascending: false);

    return (response as List)
        .map((e) => HostelModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Filter hostels ─────────────────────────────────────────────────────────
  Future<List<HostelModel>> fetchFiltered({
    int? maxPrice,
    int? minPrice,
    List<String>? amenities,
    bool? hasAvailableRooms,
  }) async {
    var query = supabase.from(_table).select().eq('is_active', true);

    if (maxPrice != null) {
      query = query.lte('price_per_semester', maxPrice);
    }
    if (minPrice != null) {
      query = query.gte('price_per_semester', minPrice);
    }
    if (hasAvailableRooms == true) {
      query = query.gt('rooms_available', 0);
    }

    final response = await query.order('rating', ascending: false);

    var results = (response as List)
        .map((e) => HostelModel.fromJson(e as Map<String, dynamic>))
        .toList();

    // Amenity filter is done client-side (Supabase array contains)
    if (amenities != null && amenities.isNotEmpty) {
      results = results.where((h) {
        return amenities.every((a) => h.amenities.contains(a));
      }).toList();
    }

    return results;
  }

  // ── Create hostel ──────────────────────────────────────────────────────────
  Future<HostelModel> create(Map<String, dynamic> data) async {
    final response = await supabase.from(_table).insert(data).select().single();

    return HostelModel.fromJson(response);
  }

  // ── Update hostel ──────────────────────────────────────────────────────────
  Future<HostelModel> update(String hostelId, Map<String, dynamic> data) async {
    final response = await supabase
        .from(_table)
        .update(data)
        .eq('id', hostelId)
        .select()
        .single();

    return HostelModel.fromJson(response);
  }

  // ── Decrement rooms available (called after booking) ──────────────────────
  Future<void> decrementRoomsAvailable(String hostelId) async {
    await supabase.rpc(
      'decrement_rooms_available',
      params: {'hostel_id': hostelId},
    );
  }

  // ── Delete hostel (owner only) ─────────────────────────────────────────────
  Future<void> delete(String hostelId) async {
    await supabase.from(_table).delete().eq('id', hostelId);
  }

  // ── Realtime stream — single hostel ───────────────────────────────────────
  Stream<HostelModel> streamById(String hostelId) {
    return supabase
        .from(_table)
        .stream(primaryKey: ['id'])
        .eq('id', hostelId)
        .map((rows) {
          if (rows.isEmpty) throw Exception('Hostel not found');
          return HostelModel.fromJson(rows.first);
        });
  }
}
