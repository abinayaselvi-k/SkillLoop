import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../models/exchange_request.dart';
import '../../models/review.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';

class SubmitReviewDialog extends StatefulWidget {
  final ExchangeRequest exchange;
  final String revieweeId;
  final String revieweeName;

  const SubmitReviewDialog({
    super.key,
    required this.exchange,
    required this.revieweeId,
    required this.revieweeName,
  });

  @override
  State<SubmitReviewDialog> createState() => _SubmitReviewDialogState();
}

class _SubmitReviewDialogState extends State<SubmitReviewDialog> {
  final _commentController = TextEditingController();
  double _rating = 5.0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    setState(() => _isSubmitting = true);

    final auth = context.read<AuthProvider>();
    final currentUser = auth.currentProfile;

    final review = Review(
      id: '',
      exchangeRequestId: widget.exchange.id,
      reviewerId: currentUser.id,
      reviewerName: currentUser.fullName,
      reviewerPhotoUrl: currentUser.photoUrl,
      revieweeId: widget.revieweeId,
      rating: _rating,
      comment: _commentController.text.trim(),
    );

    try {
      await FirestoreService().submitReview(review);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Thank you! Review submitted for ${widget.revieweeName} ⭐'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit review: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Rate Skill Exchange ⭐',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'How was your session with ${widget.revieweeName}?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 18),

              // Interactive Star Rating
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starValue = index + 1.0;
                  return IconButton(
                    icon: Icon(
                      _rating >= starValue
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 34,
                      color: AppColors.warning,
                    ),
                    onPressed: () {
                      setState(() {
                        _rating = starValue;
                      });
                    },
                  );
                }),
              ),

              Text(
                '${_rating.toInt()} of 5 Stars',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),

              const SizedBox(height: 16),

              // Review Feedback Box
              CustomTextField(
                controller: _commentController,
                labelText: 'Feedback (Optional)',
                hintText: 'Share what you learned or how helpful the session was...',
                maxLines: 3,
              ),

              const SizedBox(height: 22),

              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Cancel',
                      variant: ButtonVariant.outline,
                      height: 44,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomButton(
                      text: 'Submit',
                      isLoading: _isSubmitting,
                      height: 44,
                      onPressed: _handleSubmit,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
