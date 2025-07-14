// lib/widgets/rating_dialog.dart
import 'package:flutter/material.dart';
import 'package:skillsync/models/rating_models.dart';
import 'package:skillsync/repositories/rating_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RatingDialog extends StatefulWidget {
  final String skillSwapId;
  final String ratedUserId;
  final String ratedUserName;
  final String skillName;
  final RatingRepository ratingRepository;
  final RatingModel? existingRating;

  const RatingDialog({
    super.key,
    required this.skillSwapId,
    required this.ratedUserId,
    required this.ratedUserName,
    required this.skillName,
    required this.ratingRepository,
    this.existingRating,
  });

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  double _rating = 5.0;
  final TextEditingController _commentController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingRating != null) {
      _rating = widget.existingRating!.rating;
      _commentController.text = widget.existingRating?.comment ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.existingRating != null
            ? 'Update Rating'
            : 'Rate ${widget.ratedUserName}',
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How was your experience learning/teaching "${widget.skillName}"?',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),

          // Star Rating
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _rating = index + 1.0;
                  });
                },
                child: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 36,
                ),
              );
            }),
          ),

          const SizedBox(height: 8),
          Center(
            child: Text(
              _getRatingText(_rating),
              style: TextStyle(
                color: _getRatingColor(_rating),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Comment TextField
          TextField(
            controller: _commentController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Share your experience (optional)',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitRating,
          child:
              _isLoading
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : Text(widget.existingRating != null ? 'Update' : 'Submit'),
        ),
      ],
    );
  }

  String _getRatingText(double rating) {
    switch (rating.round()) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent';
      default:
        return 'Rate';
    }
  }

  Color _getRatingColor(double rating) {
    switch (rating.round()) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.yellow[700]!;
      case 4:
        return Colors.lightGreen;
      case 5:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Future<void> _submitRating() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      if (widget.existingRating != null) {
        // Update existing rating
        await widget.ratingRepository.updateRating(
          widget.existingRating!.id,
          _rating,
          _commentController.text.trim().isEmpty
              ? null
              : _commentController.text.trim(),
        );
      } else {
        // Create new rating
        final rating = RatingModel(
          id: '',
          raterId: currentUser.uid,
          raterName: currentUser.displayName ?? 'Anonymous',
          ratedUserId: widget.ratedUserId,
          ratedUserName: widget.ratedUserName,
          rating: _rating,
          comment:
              _commentController.text.trim().isEmpty
                  ? null
                  : _commentController.text.trim(),
          skillSwapId: widget.skillSwapId,
          skillName: widget.skillName,
          createdAt: DateTime.now(),
        );

        await widget.ratingRepository.addRating(rating);
      }

      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
