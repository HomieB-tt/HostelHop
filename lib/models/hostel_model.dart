class HostelModel {
  const HostelModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.location,
    required this.description,
    required this.pricePerSemester,
    required this.commitmentFee,
    required this.totalRooms,
    required this.roomsAvailable,
    required this.amenities,
    required this.imageUrls,
    required this.rating,
    required this.reviewCount,
    required this.isVerified,
    required this.isActive,
    required this.createdAt,
    this.primaryRoomType = 'Single Room',
    this.semesterLabel = 'Semester 1 · Jan – May 2025',
    this.durationLabel = '1 Semester (5 months)',
    this.latitude,
    this.longitude,
    this.distanceFromCampus,
  });

  final String id;
  final String ownerId;
  final String name;
  final String location;
  final String description;
  final int pricePerSemester;
  final int commitmentFee;
  final int totalRooms;
  final int roomsAvailable;
  final List<String> amenities;
  final List<String> imageUrls;
  final double rating;
  final int reviewCount;
  final bool isVerified;
  final bool isActive;
  final DateTime createdAt;
  final String primaryRoomType;
  final String semesterLabel;
  final String durationLabel;
  final double? latitude;
  final double? longitude;
  final double? distanceFromCampus; // km

  // ── Convenience ────────────────────────────────────────────────────────────
  bool get isSoldOut => roomsAvailable == 0;
  bool get isAlmostFull => roomsAvailable <= 5;
  double get occupancyFraction =>
      totalRooms > 0 ? (totalRooms - roomsAvailable) / totalRooms : 0;

  // ── Serialisation ──────────────────────────────────────────────────────────
  factory HostelModel.fromJson(Map<String, dynamic> json) {
    return HostelModel(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      description: json['description'] as String? ?? '',
      pricePerSemester: (json['price_per_semester'] as num).toInt(),
      commitmentFee: (json['commitment_fee'] as num).toInt(),
      totalRooms: (json['total_rooms'] as num).toInt(),
      roomsAvailable: (json['rooms_available'] as num).toInt(),
      amenities: List<String>.from(json['amenities'] as List? ?? []),
      imageUrls: List<String>.from(json['image_urls'] as List? ?? []),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
      isVerified: json['is_verified'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      primaryRoomType: json['primary_room_type'] as String? ?? 'Single Room',
      semesterLabel:
          json['semester_label'] as String? ?? 'Semester 1 · Jan – May 2025',
      durationLabel:
          json['duration_label'] as String? ?? '1 Semester (5 months)',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      distanceFromCampus: (json['distance_from_campus'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'name': name,
      'location': location,
      'description': description,
      'price_per_semester': pricePerSemester,
      'commitment_fee': commitmentFee,
      'total_rooms': totalRooms,
      'rooms_available': roomsAvailable,
      'amenities': amenities,
      'image_urls': imageUrls,
      'rating': rating,
      'review_count': reviewCount,
      'is_verified': isVerified,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'primary_room_type': primaryRoomType,
      'semester_label': semesterLabel,
      'duration_label': durationLabel,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (distanceFromCampus != null)
        'distance_from_campus': distanceFromCampus,
    };
  }

  HostelModel copyWith({
    String? name,
    String? location,
    String? description,
    int? pricePerSemester,
    int? commitmentFee,
    int? totalRooms,
    int? roomsAvailable,
    List<String>? amenities,
    List<String>? imageUrls,
    double? rating,
    int? reviewCount,
    bool? isVerified,
    bool? isActive,
    String? primaryRoomType,
    String? semesterLabel,
    String? durationLabel,
    double? latitude,
    double? longitude,
    double? distanceFromCampus,
  }) {
    return HostelModel(
      id: id,
      ownerId: ownerId,
      name: name ?? this.name,
      location: location ?? this.location,
      description: description ?? this.description,
      pricePerSemester: pricePerSemester ?? this.pricePerSemester,
      commitmentFee: commitmentFee ?? this.commitmentFee,
      totalRooms: totalRooms ?? this.totalRooms,
      roomsAvailable: roomsAvailable ?? this.roomsAvailable,
      amenities: amenities ?? this.amenities,
      imageUrls: imageUrls ?? this.imageUrls,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      primaryRoomType: primaryRoomType ?? this.primaryRoomType,
      semesterLabel: semesterLabel ?? this.semesterLabel,
      durationLabel: durationLabel ?? this.durationLabel,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      distanceFromCampus: distanceFromCampus ?? this.distanceFromCampus,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HostelModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
