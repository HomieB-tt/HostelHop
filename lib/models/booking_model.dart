class BookingModel {
  const BookingModel({
    required this.id,
    required this.userId,
    required this.hostelId,
    required this.hostelName,
    required this.roomType,
    required this.reference,
    required this.status,
    required this.totalAmount,
    required this.commitmentFeeAmount,
    required this.commitmentFeePaid,
    required this.checkInDate,
    required this.checkOutDate,
    required this.createdAt,
    this.hostelImageUrl,
    this.paymentMethod,
    this.paymentPhone,
    this.notes,
  });

  final String id;
  final String userId;
  final String hostelId;
  final String hostelName;
  final String roomType;
  final String reference;
  final BookingStatus status;
  final int totalAmount;
  final int commitmentFeeAmount;
  final int commitmentFeePaid;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final DateTime createdAt;
  final String? hostelImageUrl;
  final String? paymentMethod;
  final String? paymentPhone;
  final String? notes;

  // ── Convenience ────────────────────────────────────────────────────────────
  int get balanceDue => totalAmount - commitmentFeePaid;
  bool get isFullyPaid => balanceDue <= 0;
  bool get isPending => status == BookingStatus.pending;
  bool get isConfirmed => status == BookingStatus.confirmed;

  String get dateRangeLabel {
    final inMonth = _monthLabel(checkInDate.month);
    final outMonth = _monthLabel(checkOutDate.month);
    return '$inMonth ${checkInDate.day} – $outMonth ${checkOutDate.day}, '
        '${checkOutDate.year}';
  }

  String _monthLabel(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month];
  }

  // ── Serialisation ──────────────────────────────────────────────────────────
  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      hostelId: json['hostel_id'] as String,
      hostelName: json['hostel_name'] as String? ?? '',
      roomType: json['room_type'] as String? ?? 'Single Room',
      reference: json['reference'] as String,
      status: BookingStatus.fromString(json['status'] as String? ?? 'pending'),
      totalAmount: (json['total_amount'] as num).toInt(),
      commitmentFeeAmount: (json['commitment_fee_amount'] as num).toInt(),
      commitmentFeePaid: (json['commitment_fee_paid'] as num?)?.toInt() ?? 0,
      checkInDate: DateTime.parse(json['check_in_date'] as String),
      checkOutDate: DateTime.parse(json['check_out_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      hostelImageUrl: json['hostel_image_url'] as String?,
      paymentMethod: json['payment_method'] as String?,
      paymentPhone: json['payment_phone'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'hostel_id': hostelId,
      'hostel_name': hostelName,
      'room_type': roomType,
      'reference': reference,
      'status': status.value,
      'total_amount': totalAmount,
      'commitment_fee_amount': commitmentFeeAmount,
      'commitment_fee_paid': commitmentFeePaid,
      'check_in_date': checkInDate.toIso8601String(),
      'check_out_date': checkOutDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      if (hostelImageUrl != null) 'hostel_image_url': hostelImageUrl,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (paymentPhone != null) 'payment_phone': paymentPhone,
      if (notes != null) 'notes': notes,
    };
  }

  BookingModel copyWith({
    BookingStatus? status,
    int? commitmentFeePaid,
    String? paymentMethod,
    String? paymentPhone,
    String? notes,
    String? hostelImageUrl,
  }) {
    return BookingModel(
      id: id,
      userId: userId,
      hostelId: hostelId,
      hostelName: hostelName,
      roomType: roomType,
      reference: reference,
      status: status ?? this.status,
      totalAmount: totalAmount,
      commitmentFeeAmount: commitmentFeeAmount,
      commitmentFeePaid: commitmentFeePaid ?? this.commitmentFeePaid,
      checkInDate: checkInDate,
      checkOutDate: checkOutDate,
      createdAt: createdAt,
      hostelImageUrl: hostelImageUrl ?? this.hostelImageUrl,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentPhone: paymentPhone ?? this.paymentPhone,
      notes: notes ?? this.notes,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookingModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// ── BookingStatus ──────────────────────────────────────────────────────────────
enum BookingStatus {
  pending('pending'),
  confirmed('confirmed'),
  completed('completed'),
  cancelled('cancelled');

  const BookingStatus(this.value);
  final String value;

  static BookingStatus fromString(String v) {
    return BookingStatus.values.firstWhere(
      (e) => e.value == v,
      orElse: () => BookingStatus.pending,
    );
  }
}
