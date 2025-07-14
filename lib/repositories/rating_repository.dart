// lib/repositories/rating_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skillsync/models/rating_models.dart';

class RatingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'ratings';

  // Add a rating
  Future<String> addRating(RatingModel rating) async {
    try {
      // Check if user already rated this skill swap
      final existingRating =
          await _firestore
              .collection(_collection)
              .where('raterId', isEqualTo: rating.raterId)
              .where('skillSwapId', isEqualTo: rating.skillSwapId)
              .get();

      if (existingRating.docs.isNotEmpty) {
        throw Exception('You have already rated this skill swap');
      }

      final docRef = await _firestore.collection(_collection).add({
        'raterId': rating.raterId,
        'raterName': rating.raterName,
        'ratedUserId': rating.ratedUserId,
        'ratedUserName': rating.ratedUserName,
        'rating': rating.rating,
        'comment': rating.comment,
        'skillSwapId': rating.skillSwapId,
        'skillName': rating.skillName,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add rating: $e');
    }
  }

  // Get ratings for a specific user
  Stream<List<RatingModel>> getUserRatings(String userId) {
    return _firestore
        .collection(_collection)
        .where('ratedUserId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => RatingModel.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  // Get user's rating summary
  Future<UserRatingInfo> getUserRatingInfo(String userId) async {
    try {
      final snapshot =
          await _firestore
              .collection(_collection)
              .where('ratedUserId', isEqualTo: userId)
              .get();

      if (snapshot.docs.isEmpty) {
        return UserRatingInfo(
          averageRating: 0.0,
          totalRatings: 0,
          ratingDistribution: {},
          recentRatings: [],
        );
      }

      final ratings =
          snapshot.docs
              .map((doc) => RatingModel.fromMap(doc.data(), doc.id))
              .toList();

      // Calculate average rating
      double totalRating = 0.0;
      Map<int, int> distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

      for (final rating in ratings) {
        totalRating += rating.rating;
        distribution[rating.rating.round()] =
            (distribution[rating.rating.round()] ?? 0) + 1;
      }

      final averageRating = totalRating / ratings.length;

      // Get recent ratings (last 5)
      ratings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final recentRatings = ratings.take(5).toList();

      return UserRatingInfo(
        averageRating: averageRating,
        totalRatings: ratings.length,
        ratingDistribution: distribution,
        recentRatings: recentRatings,
      );
    } catch (e) {
      throw Exception('Failed to get user rating info: $e');
    }
  }

  // Check if user can rate a specific skill swap
  Future<bool> canRateSkillSwap(String userId, String skillSwapId) async {
    try {
      final existingRating =
          await _firestore
              .collection(_collection)
              .where('raterId', isEqualTo: userId)
              .where('skillSwapId', isEqualTo: skillSwapId)
              .get();

      return existingRating.docs.isEmpty;
    } catch (e) {
      return false;
    }
  }

  // Get rating given by a user for a specific skill swap
  Future<RatingModel?> getRatingForSkillSwap(
    String raterId,
    String skillSwapId,
  ) async {
    try {
      final snapshot =
          await _firestore
              .collection(_collection)
              .where('raterId', isEqualTo: raterId)
              .where('skillSwapId', isEqualTo: skillSwapId)
              .get();

      if (snapshot.docs.isNotEmpty) {
        return RatingModel.fromMap(
          snapshot.docs.first.data(),
          snapshot.docs.first.id,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Update a rating
  Future<void> updateRating(
    String ratingId,
    double newRating,
    String? newComment,
  ) async {
    try {
      await _firestore.collection(_collection).doc(ratingId).update({
        'rating': newRating,
        'comment': newComment,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update rating: $e');
    }
  }

  // Delete a rating
  Future<void> deleteRating(String ratingId) async {
    try {
      await _firestore.collection(_collection).doc(ratingId).delete();
    } catch (e) {
      throw Exception('Failed to delete rating: $e');
    }
  }

  // Get all ratings given by a user
  Stream<List<RatingModel>> getRatingsGivenByUser(String userId) {
    return _firestore
        .collection(_collection)
        .where('raterId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => RatingModel.fromMap(doc.data(), doc.id))
              .toList();
        });
  }
}
