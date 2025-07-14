// lib/models/rating_model.dart
class RatingModel {
  final String id;
  final String raterId; // Who gave the rating
  final String raterName;
  final String ratedUserId; // Who received the rating
  final String ratedUserName;
  final double rating; // 1-5 stars
  final String? comment;
  final String skillSwapId; // Reference to the skill swap request
  final String skillName; // What skill was taught/learned
  final DateTime createdAt;

  RatingModel({
    required this.id,
    required this.raterId,
    required this.raterName,
    required this.ratedUserId,
    required this.ratedUserName,
    required this.rating,
    this.comment,
    required this.skillSwapId,
    required this.skillName,
    required this.createdAt,
  });

  factory RatingModel.fromMap(Map<String, dynamic> map, String id) {
    return RatingModel(
      id: id,
      raterId: map['raterId'] ?? '',
      raterName: map['raterName'] ?? '',
      ratedUserId: map['ratedUserId'] ?? '',
      ratedUserName: map['ratedUserName'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      comment: map['comment'],
      skillSwapId: map['skillSwapId'] ?? '',
      skillName: map['skillName'] ?? '',
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'raterId': raterId,
      'raterName': raterName,
      'ratedUserId': ratedUserId,
      'ratedUserName': ratedUserName,
      'rating': rating,
      'comment': comment,
      'skillSwapId': skillSwapId,
      'skillName': skillName,
      'createdAt': createdAt,
    };
  }
}

// User rating summary
class UserRatingInfo {
  final double averageRating;
  final int totalRatings;
  final Map<int, int> ratingDistribution; // star -> count
  final List<RatingModel> recentRatings;

  UserRatingInfo({
    required this.averageRating,
    required this.totalRatings,
    required this.ratingDistribution,
    required this.recentRatings,
  });
}
