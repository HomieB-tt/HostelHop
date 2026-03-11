import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hostelhop/providers/auth_provider.dart';

import '../../config/app_theme.dart';
import '../../models/hostel_model.dart';
import '../../providers/hostel_provider.dart';
import '../../repositories/hostel_repository.dart';
import '../../services/storage_service.dart';
import '../../utils/validators.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/app_network_image.dart';

/// Create or edit a hostel.
/// Pass [hostel] via GoRouter `extra` to enter edit mode.
///
/// Route: AppRoutes.manageHostel
/// Extra: HostelModel? (null = create, non-null = edit)
class ManageHostelScreen extends ConsumerStatefulWidget {
  const ManageHostelScreen({super.key, this.hostel});

  final HostelModel? hostel;

  @override
  ConsumerState<ManageHostelScreen> createState() => _ManageHostelScreenState();
}

class _ManageHostelScreenState extends ConsumerState<ManageHostelScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late final TextEditingController _nameCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _commitmentCtrl;
  late final TextEditingController _totalRoomsCtrl;
  late final TextEditingController _latCtrl;
  late final TextEditingController _lngCtrl;
  late final TextEditingController _distanceCtrl;

  // State
  List<String> _imageUrls = [];
  List<String> _selectedAmenities = [];
  String _primaryRoomType = 'Single Room';
  bool _isActive = true;
  bool _isSaving = false;
  bool _isUploadingImages = false;

  bool get _isEdit => widget.hostel != null;

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
    'Swimming Pool',
    'Air Conditioning',
    'Balcony',
    'TV',
  ];

  static const _roomTypes = [
    'Single Room',
    'Double Room',
    'Triple Room',
    'Self Contained',
  ];

  @override
  void initState() {
    super.initState();
    final h = widget.hostel;
    _nameCtrl = TextEditingController(text: h?.name ?? '');
    _locationCtrl = TextEditingController(text: h?.location ?? '');
    _descCtrl = TextEditingController(text: h?.description ?? '');
    _priceCtrl = TextEditingController(
      text: h != null ? '${h.pricePerSemester}' : '',
    );
    _commitmentCtrl = TextEditingController(
      text: h != null ? '${h.commitmentFee}' : '',
    );
    _totalRoomsCtrl = TextEditingController(
      text: h != null ? '${h.totalRooms}' : '',
    );
    _latCtrl = TextEditingController(
      text: h?.latitude != null ? '${h!.latitude}' : '',
    );
    _lngCtrl = TextEditingController(
      text: h?.longitude != null ? '${h!.longitude}' : '',
    );
    _distanceCtrl = TextEditingController(
      text: h?.distanceFromCampus != null ? '${h!.distanceFromCampus}' : '',
    );
    _imageUrls = List.from(h?.imageUrls ?? []);
    _selectedAmenities = List.from(h?.amenities ?? []);
    _primaryRoomType = h?.primaryRoomType ?? 'Single Room';
    _isActive = h?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _commitmentCtrl.dispose();
    _totalRoomsCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    _distanceCtrl.dispose();
    super.dispose();
  }

  // ── Upload images ──────────────────────────────────────────────────────────
  Future<void> _uploadImages() async {
    setState(() => _isUploadingImages = true);
    try {
      final storageService = StorageService();
      final hostelId = widget.hostel?.id ?? 'new';
      final ownerId = ref.read(authProvider).user?.id ?? 'unknown';
      final urls = await storageService.pickAndUploadGallery(
        ownerId: ownerId,
        hostelId: hostelId,
      );
      setState(() => _imageUrls = [..._imageUrls, ...urls]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image upload failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingImages = false);
    }
  }

  // ── Save ───────────────────────────────────────────────────────────────────
  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_imageUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one image.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final ownerId = ref.read(authProvider).user!.id;
      final data = {
        'owner_id': ownerId,
        'name': _nameCtrl.text.trim(),
        'location': _locationCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'price_per_semester': int.parse(_priceCtrl.text.trim()),
        'commitment_fee': int.parse(_commitmentCtrl.text.trim()),
        'total_rooms': int.parse(_totalRoomsCtrl.text.trim()),
        'rooms_available': _isEdit
            ? widget.hostel!.roomsAvailable
            : int.parse(_totalRoomsCtrl.text.trim()),
        'amenities': _selectedAmenities,
        'image_urls': _imageUrls,
        'primary_room_type': _primaryRoomType,
        'is_active': _isActive,
        if (_latCtrl.text.isNotEmpty)
          'latitude': double.parse(_latCtrl.text.trim()),
        if (_lngCtrl.text.isNotEmpty)
          'longitude': double.parse(_lngCtrl.text.trim()),
        if (_distanceCtrl.text.isNotEmpty)
          'distance_from_campus': double.parse(_distanceCtrl.text.trim()),
      };

      if (_isEdit) {
        await const HostelRepository().update(widget.hostel!.id, data);
      } else {
        await const HostelRepository().create(data);
      }

      ref.invalidate(ownerHostelListProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEdit ? 'Hostel updated!' : 'Hostel created!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
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
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          _isEdit ? 'Edit Hostel' : 'Add Hostel',
          style: const TextStyle(
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
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Images ────────────────────────────────────────────────────────
            _Section(
              title: 'Photos',
              child: Column(
                children: [
                  if (_imageUrls.isNotEmpty)
                    SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _imageUrls.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) => Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: AppNetworkImage(
                                url: _imageUrls[i],
                                width: 100,
                                height: 100,
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _imageUrls.removeAt(i)),
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                    color: AppColors.error,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  AppButton.outlined(
                    label: _isUploadingImages ? 'Uploading…' : 'Add Photos',
                    onPressed: _isUploadingImages ? null : _uploadImages,
                    isLoading: _isUploadingImages,
                    icon: Icons.add_photo_alternate_outlined,
                    fullWidth: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Basic info ────────────────────────────────────────────────────
            _Section(
              title: 'Basic Info',
              child: Column(
                children: [
                  AppTextField(
                    label: 'Hostel Name',
                    hint: 'e.g. Sunrise Hostel',
                    controller: _nameCtrl,
                    validator: Validators.required,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Location',
                    hint: 'e.g. Kikoni, Makerere',
                    controller: _locationCtrl,
                    validator: Validators.required,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  AppTextField.multiline(
                    label: 'Description',
                    hint: 'Describe your hostel…',
                    controller: _descCtrl,
                    validator: Validators.required,
                    minLines: 3,
                    maxLines: 5,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Pricing ───────────────────────────────────────────────────────
            _Section(
              title: 'Pricing',
              child: Column(
                children: [
                  AppTextField(
                    label: 'Price Per Semester (UGX)',
                    hint: '1200000',
                    controller: _priceCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: Validators.required,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Commitment Fee (UGX)',
                    hint: '300000',
                    controller: _commitmentCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: Validators.required,
                    textInputAction: TextInputAction.next,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Rooms ─────────────────────────────────────────────────────────
            _Section(
              title: 'Rooms',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    label: 'Total Rooms',
                    hint: '20',
                    controller: _totalRoomsCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: Validators.required,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Primary Room Type',
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
                    children: _roomTypes.map((t) {
                      final selected = _primaryRoomType == t;
                      return GestureDetector(
                        onTap: () => setState(() => _primaryRoomType = t),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.orangeBright
                                : Colors.white,
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              color: selected
                                  ? AppColors.orangeBright
                                  : AppColors.borderLight,
                            ),
                          ),
                          child: Text(
                            t,
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
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Amenities ─────────────────────────────────────────────────────
            _Section(
              title: 'Amenities',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _allAmenities.map((a) {
                  final selected = _selectedAmenities.contains(a);
                  return GestureDetector(
                    onTap: () => setState(
                      () => selected
                          ? _selectedAmenities.remove(a)
                          : _selectedAmenities.add(a),
                    ),
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
            ),

            const SizedBox(height: 16),

            // ── Location coords (optional) ─────────────────────────────────
            _Section(
              title: 'Location Coordinates (Optional)',
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'Latitude',
                          hint: '0.3476',
                          controller: _latCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          label: 'Longitude',
                          hint: '32.5825',
                          controller: _lngCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Distance from Campus (km)',
                    hint: '0.5',
                    controller: _distanceCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textInputAction: TextInputAction.done,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Visibility toggle ─────────────────────────────────────────────
            _Section(
              title: 'Visibility',
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
                activeThumbColor: AppColors.orangeBright,
                title: Text(
                  _isActive ? 'Listed (visible to students)' : 'Unlisted',
                  style: const TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                subtitle: Text(
                  _isActive
                      ? 'Students can find and book this hostel.'
                      : 'This hostel is hidden from search.',
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 12,
                    color: AppColors.textHintLight,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ── Save button ───────────────────────────────────────────────────
            AppButton(
              label: _isEdit ? 'Save Changes' : 'Create Hostel',
              onPressed: _isSaving ? null : _save,
              isLoading: _isSaving,
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ── Section wrapper ────────────────────────────────────────────────────────────
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Sora',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
