class ReviewModel {
  const ReviewModel({
    required this.id,
    required this.hostelId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.userAvatarUrl,
    this.ownerReply,
    this.ownerReplyAt,
    this.isVerifiedStay = false,
    this.helpfulCount = 0,
  });

  final String id;
  final String hostelId;
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final String? userAvatarUrl;
  final String? ownerReply;
  final DateTime? ownerReplyAt;
  final bool isVerifiedStay;
  final int helpfulCount;

  // ── Convenience ────────────────────────────────────────────────────────────
  String get userInitial =>
      userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

  bool get hasOwnerReply => ownerReply != null && ownerReply!.isNotEmpty;

  String get timeAgoLabel {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inDays >= 365) {
      final years = (diff.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    }
    if (diff.inDays >= 30) {
      final months = (diff.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    }
    if (diff.inDays > 0) {
      return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    }
    if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    }
    return 'Just now';
  }

  // ── Serialisation ──────────────────────────────────────────────────────────
  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      hostelId: json['hostel_id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String? ?? 'Anonymous',
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      userAvatarUrl: json['user_avatar_url'] as String?,
      ownerReply: json['owner_reply'] as String?,
      ownerReplyAt: json['owner_reply_at'] != null
          ? DateTime.parse(json['owner_reply_at'] as String)
          : null,
      isVerifiedStay: json['is_verified_stay'] as bool? ?? false,
      helpfulCount: (json['helpful_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hostel_id': hostelId,
      'user_id': userId,
      'user_name': userName,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
      if (userAvatarUrl != null) 'user_avatar_url': userAvatarUrl,
      if (ownerReply != null) 'owner_reply': ownerReply,
      if (ownerReplyAt != null)
        'owner_reply_at': ownerReplyAt!.toIso8601String(),
      'is_verified_stay': isVerifiedStay,
      'helpful_count': helpfulCount,
    };
  }

  ReviewModel copyWith({
    String? comment,
    double? rating,
    String? ownerReply,
    DateTime? ownerReplyAt,
    int? helpfulCount,
  }) {
    return ReviewModel(
      id: id,
      hostelId: hostelId,
      userId: userId,
      userName: userName,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt,
      userAvatarUrl: userAvatarUrl,
      ownerReply: ownerReply ?? this.ownerReply,
      ownerReplyAt: ownerReplyAt ?? this.ownerReplyAt,
      isVerifiedStay: isVerifiedStay,
      helpfulCount: helpfulCount ?? this.helpfulCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReviewModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
