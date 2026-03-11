import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_theme.dart';
import '../../models/room_model.dart';
import '../../repositories/room_repository.dart';
import '../../utils/price_formatter.dart';
import '../../utils/validators.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_empty_state.dart';
import '../../widgets/common/app_error_widget.dart';
import '../../widgets/common/app_loading_indicator.dart';
import '../../widgets/common/app_text_field.dart';

/// Manage rooms for a specific hostel.
/// Receives [hostelId] via GoRouter `extra`.
///
/// Route: AppRoutes.manageRooms
/// Extra: String hostelId
class ManageRoomsScreen extends ConsumerStatefulWidget {
  const ManageRoomsScreen({super.key, required this.hostelId});

  final String hostelId;

  @override
  ConsumerState<ManageRoomsScreen> createState() => _ManageRoomsScreenState();
}

class _ManageRoomsScreenState extends ConsumerState<ManageRoomsScreen> {
  List<RoomModel> _rooms = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final rooms = await const RoomRepository().fetchByHostel(widget.hostelId);
      setState(() => _rooms = rooms);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleActive(RoomModel room) async {
    try {
      await const RoomRepository().update(room.id, {
        'is_active': !room.isActive,
      });
      await _loadRooms();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteRoom(RoomModel room) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          'Delete Room?',
          style: TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w700),
        ),
        content: Text(
          'This will permanently delete ${room.type.label}. '
          'This cannot be undone.',
          style: const TextStyle(fontFamily: 'Roboto'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await const RoomRepository().delete(room.id);
      await _loadRooms();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showAddRoomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) =>
          _AddRoomSheet(hostelId: widget.hostelId, onSaved: _loadRooms),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Manage Rooms',
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimaryLight,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.borderLight),
        ),
      ),
      body: _isLoading
          ? const AppLoadingScreen()
          : _error != null
          ? AppErrorWidget(message: _error!, onRetry: _loadRooms)
          : _rooms.isEmpty
          ? AppEmptyState(
              emoji: '🛏️',
              title: 'No rooms yet',
              subtitle: 'Add rooms to specify types, slots and pricing.',
              ctaLabel: 'Add Room',
              onCta: _showAddRoomSheet,
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _rooms.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _RoomCard(
                room: _rooms[i],
                onToggle: () => _toggleActive(_rooms[i]),
                onDelete: () => _deleteRoom(_rooms[i]),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddRoomSheet,
        backgroundColor: AppColors.orangeBright,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Room',
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ── Room card ──────────────────────────────────────────────────────────────────
class _RoomCard extends StatelessWidget {
  const _RoomCard({
    required this.room,
    required this.onToggle,
    required this.onDelete,
  });

  final RoomModel room;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final fraction = (1 - room.occupancyFraction).clamp(0.0, 1.0);
    final occupied = room.totalSlots - room.availableSlots;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.orangeBright.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.bed_rounded,
                  size: 18,
                  color: AppColors.orangeBright,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.type.label,
                      style: const TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    if (room.roomNumber != null)
                      Text(
                        'Room ${room.roomNumber}'
                        '${room.floorNumber != null ? ' · Floor ${room.floorNumber}' : ''}',
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 11,
                          color: AppColors.textHintLight,
                        ),
                      ),
                  ],
                ),
              ),
              // Active toggle
              Switch(
                value: room.isActive,
                onChanged: (_) => onToggle(),
                activeThumbColor: AppColors.orangeBright,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Slots bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Occupancy',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 11,
                      color: AppColors.textHintLight,
                    ),
                  ),
                  Text(
                    '$occupied / ${room.totalSlots} slots',
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: room.isSoldOut
                          ? AppColors.error
                          : AppColors.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: 1 - fraction,
                  minHeight: 6,
                  backgroundColor: AppColors.borderLight,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    room.isSoldOut ? AppColors.error : AppColors.success,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Price + delete
          Row(
            children: [
              Text(
                PriceFormatter.perSemester(room.pricePerSemester),
                style: const TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  size: 20,
                  color: AppColors.error,
                ),
                tooltip: 'Delete room',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Add room bottom sheet ──────────────────────────────────────────────────────
class _AddRoomSheet extends ConsumerStatefulWidget {
  const _AddRoomSheet({required this.hostelId, required this.onSaved});

  final String hostelId;
  final VoidCallback onSaved;

  @override
  ConsumerState<_AddRoomSheet> createState() => _AddRoomSheetState();
}

class _AddRoomSheetState extends ConsumerState<_AddRoomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _priceCtrl = TextEditingController();
  final _slotsCtrl = TextEditingController();
  final _roomNumberCtrl = TextEditingController();
  final _floorCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  RoomType _selectedType = RoomType.single;
  bool _isSaving = false;

  @override
  void dispose() {
    _priceCtrl.dispose();
    _slotsCtrl.dispose();
    _roomNumberCtrl.dispose();
    _floorCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSaving = true);

    try {
      final slots = int.parse(_slotsCtrl.text.trim());
      await const RoomRepository().create({
        'hostel_id': widget.hostelId,
        'type': _selectedType.value,
        'price_per_semester': int.parse(_priceCtrl.text.trim()),
        'total_slots': slots,
        'available_slots': slots,
        'is_active': true,
        if (_roomNumberCtrl.text.isNotEmpty)
          'room_number': _roomNumberCtrl.text.trim(),
        if (_floorCtrl.text.isNotEmpty)
          'floor_number': int.parse(_floorCtrl.text.trim()),
        if (_descCtrl.text.isNotEmpty) 'description': _descCtrl.text.trim(),
      });

      widget.onSaved();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
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
              const SizedBox(height: 16),

              const Text(
                'Add Room',
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 16),

              // Room type selector
              const Text(
                'Room Type',
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: RoomType.values.map((t) {
                  final selected = _selectedType == t;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedType = t),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.orangeBright : Colors.white,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: selected
                              ? AppColors.orangeBright
                              : AppColors.borderLight,
                        ),
                      ),
                      child: Text(
                        t.label,
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? Colors.white
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Price / Semester (UGX)',
                      hint: '1200000',
                      controller: _priceCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: Validators.required,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      label: 'Total Slots',
                      hint: '4',
                      controller: _slotsCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: Validators.required,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Room Number (optional)',
                      hint: 'A1',
                      controller: _roomNumberCtrl,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      label: 'Floor (optional)',
                      hint: '2',
                      controller: _floorCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              AppTextField.multiline(
                label: 'Description (optional)',
                hint: 'Any extra details about this room…',
                controller: _descCtrl,
                minLines: 2,
                maxLines: 3,
              ),

              const SizedBox(height: 20),

              AppButton(
                label: 'Add Room',
                onPressed: _isSaving ? null : _save,
                isLoading: _isSaving,
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
