// lib/widgets/user_rating_display.dart
import 'package:flutter/material.dart';
import 'package:skillsync/models/rating_models.dart';
import 'package:skillsync/repositories/rating_repository.dart';

class UserRatingDisplay extends StatefulWidget {
  final String userId;
  final RatingRepository ratingRepository;
  final bool showReviews;

  const UserRatingDisplay({
    super.key,
    required this.userId,
    required this.ratingRepository,
    this.showReviews = false,
  });

  @override
  State<UserRatingDisplay> createState() => _UserRatingDisplayState();
}

class _UserRatingDisplayState extends State<UserRatingDisplay> {
  UserRatingInfo? _ratingInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRatingInfo();
  }

  Future<void> _loadRatingInfo() async {
    try {
      final ratingInfo = await widget.ratingRepository.getUserRatingInfo(
        widget.userId,
      );
      if (mounted) {
        setState(() {
          _ratingInfo = ratingInfo;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (_ratingInfo == null || _ratingInfo!.totalRatings == 0) {
      return const Text(
        'No ratings yet',
        style: TextStyle(color: Colors.grey, fontSize: 12),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRatingSummary(),
        if (widget.showReviews && _ratingInfo!.recentRatings.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildRecentReviews(),
        ],
      ],
    );
  }

  Widget _buildRatingSummary() {
    return Row(
      children: [
        // Average rating with stars
        Row(
          children: [
            ...List.generate(5, (index) {
              return Icon(
                index < _ratingInfo!.averageRating
                    ? Icons.star
                    : Icons.star_border,
                color: Colors.amber,
                size: 16,
              );
            }),
            const SizedBox(width: 4),
            Text(
              _ratingInfo!.averageRating.toStringAsFixed(1),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(width: 8),
        Text(
          '(${_ratingInfo!.totalRatings} rating${_ratingInfo!.totalRatings != 1 ? 's' : ''})',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildRecentReviews() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Reviews',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        ...(_ratingInfo!.recentRatings
            .take(3)
            .map((rating) => _buildReviewCard(rating))),
      ],
    );
  }

  Widget _buildReviewCard(RatingModel rating) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    rating.raterName.isNotEmpty
                        ? rating.raterName[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rating.raterName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        rating.skillName,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < rating.rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 14,
                    );
                  }),
                ),
              ],
            ),
            if (rating.comment != null && rating.comment!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                rating.comment!,
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              _formatDate(rating.createdAt),
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
