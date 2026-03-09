class RoomModel {
  const RoomModel({
    required this.id,
    required this.hostelId,
    required this.type,
    required this.pricePerSemester,
    required this.totalSlots,
    required this.availableSlots,
    required this.isActive,
    required this.createdAt,
    this.description,
    this.imageUrls = const [],
    this.amenities = const [],
    this.floorNumber,
    this.roomNumber,
  });

  final String id;
  final String hostelId;
  final RoomType type;
  final int pricePerSemester;
  final int totalSlots;
  final int availableSlots;
  final bool isActive;
  final DateTime createdAt;
  final String? description;
  final List<String> imageUrls;
  final List<String> amenities;
  final int? floorNumber;
  final String? roomNumber;

  // ── Convenience ────────────────────────────────────────────────────────────
  bool get isAvailable => availableSlots > 0 && isActive;
  bool get isSoldOut => availableSlots == 0;
  double get occupancyFraction =>
      totalSlots > 0 ? (totalSlots - availableSlots) / totalSlots : 0;

  // ── Serialisation ──────────────────────────────────────────────────────────
  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] as String,
      hostelId: json['hostel_id'] as String,
      type: RoomType.fromString(json['type'] as String? ?? 'single'),
      pricePerSemester: (json['price_per_semester'] as num).toInt(),
      totalSlots: (json['total_slots'] as num).toInt(),
      availableSlots: (json['available_slots'] as num).toInt(),
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      description: json['description'] as String?,
      imageUrls: List<String>.from(json['image_urls'] as List? ?? []),
      amenities: List<String>.from(json['amenities'] as List? ?? []),
      floorNumber: (json['floor_number'] as num?)?.toInt(),
      roomNumber: json['room_number'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hostel_id': hostelId,
      'type': type.value,
      'price_per_semester': pricePerSemester,
      'total_slots': totalSlots,
      'available_slots': availableSlots,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      if (description != null) 'description': description,
      'image_urls': imageUrls,
      'amenities': amenities,
      if (floorNumber != null) 'floor_number': floorNumber,
      if (roomNumber != null) 'room_number': roomNumber,
    };
  }

  RoomModel copyWith({
    RoomType? type,
    int? pricePerSemester,
    int? totalSlots,
    int? availableSlots,
    bool? isActive,
    String? description,
    List<String>? imageUrls,
    List<String>? amenities,
    int? floorNumber,
    String? roomNumber,
  }) {
    return RoomModel(
      id: id,
      hostelId: hostelId,
      type: type ?? this.type,
      pricePerSemester: pricePerSemester ?? this.pricePerSemester,
      totalSlots: totalSlots ?? this.totalSlots,
      availableSlots: availableSlots ?? this.availableSlots,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      description: description ?? this.description,
      imageUrls: imageUrls ?? this.imageUrls,
      amenities: amenities ?? this.amenities,
      floorNumber: floorNumber ?? this.floorNumber,
      roomNumber: roomNumber ?? this.roomNumber,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoomModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// ── RoomType ───────────────────────────────────────────────────────────────────
enum RoomType {
  single('single', 'Single Room'),
  double_('double', 'Double Room'),
  triple('triple', 'Triple Room'),
  selfContained('self_contained', 'Self Contained');

  const RoomType(this.value, this.label);
  final String value;
  final String label;

  static RoomType fromString(String v) {
    return RoomType.values.firstWhere(
      (e) => e.value == v,
      orElse: () => RoomType.single,
    );
  }
}
