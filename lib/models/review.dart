class Review {
  final String reviewerName;
  final double rating;
  final DateTime date;
  final String comment;
  final String? reviewerAvatarUrl;

  const Review({
    required this.reviewerName,
    required this.rating,
    required this.date,
    required this.comment,
    this.reviewerAvatarUrl,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    reviewerName: json['reviewerName'] as String? ?? 'Someone',
    rating: (json['rating'] as num?)?.toDouble() ?? 0,
    date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
    comment: json['comment'] as String? ?? '',
    reviewerAvatarUrl: json['reviewerAvatarUrl'] as String?,
  );
}