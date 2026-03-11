import '../../models/room_model.dart';
import '../../supabase/supabase_client.dart';

class RoomRepository {
  const RoomRepository();

  static const _table = 'rooms';

  // ── Fetch all rooms for a hostel ───────────────────────────────────────────
  Future<List<RoomModel>> fetchByHostel(String hostelId) async {
    final response = await supabase
        .from(_table)
        .select()
        .eq('hostel_id', hostelId)
        .eq('is_active', true)
        .order('price_per_semester', ascending: true);

    return (response as List)
        .map((e) => RoomModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Fetch single room ──────────────────────────────────────────────────────
  Future<RoomModel> fetchById(String roomId) async {
    final response = await supabase
        .from(_table)
        .select()
        .eq('id', roomId)
        .single();

    return RoomModel.fromJson(response);
  }

  // ── Fetch available rooms for a hostel ────────────────────────────────────
  Future<List<RoomModel>> fetchAvailable(String hostelId) async {
    final response = await supabase
        .from(_table)
        .select()
        .eq('hostel_id', hostelId)
        .eq('is_active', true)
        .gt('available_slots', 0)
        .order('price_per_semester', ascending: true);

    return (response as List)
        .map((e) => RoomModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Create room ────────────────────────────────────────────────────────────
  Future<RoomModel> create(Map<String, dynamic> data) async {
    final response = await supabase.from(_table).insert(data).select().single();

    return RoomModel.fromJson(response);
  }

  // ── Update room ────────────────────────────────────────────────────────────
  Future<RoomModel> update(String roomId, Map<String, dynamic> data) async {
    final response = await supabase
        .from(_table)
        .update(data)
        .eq('id', roomId)
        .select()
        .single();

    return RoomModel.fromJson(response);
  }

  // ── Decrement available slots (called after booking) ──────────────────────
  Future<void> decrementAvailableSlots(String roomId) async {
    await supabase.rpc('decrement_room_slots', params: {'room_id': roomId});
  }

  // ── Delete room ────────────────────────────────────────────────────────────
  Future<void> delete(String roomId) async {
    await supabase.from(_table).delete().eq('id', roomId);
  }

  // ── Realtime stream — rooms for a hostel ──────────────────────────────────
  Stream<List<RoomModel>> streamByHostel(String hostelId) {
    return supabase
        .from(_table)
        .stream(primaryKey: ['id'])
        .eq('hostel_id', hostelId)
        .map(
          (rows) => rows
              .map((e) => RoomModel.fromJson(e as Map<String, dynamic>))
              .toList(),
        );
  }
}
