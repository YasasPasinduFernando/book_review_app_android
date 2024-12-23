import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../models/book_review.dart';
import '../utils/validators.dart';

class ReviewForm extends StatefulWidget {
  final BookReview? initialReview;
  final Function(BookReview) onSubmit;
  final VoidCallback onCancel;

  const ReviewForm({
    super.key,
    this.initialReview,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  State<ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<ReviewForm> {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final authorController = TextEditingController();
  final reviewController = TextEditingController();
  double rating = 5.0;

  @override
  void initState() {
    super.initState();
    if (widget.initialReview != null) {
      titleController.text = widget.initialReview!.bookTitle;
      authorController.text = widget.initialReview!.author;
      reviewController.text = widget.initialReview!.reviewText;
      rating = widget.initialReview!.rating;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    authorController.dispose();
    reviewController.dispose();
    super.dispose();
  }

  void submitForm() {
    if (!formKey.currentState!.validate()) return;

    final review = BookReview(
      id: widget.initialReview?.id,
      bookTitle: titleController.text,
      author: authorController.text,
      rating: rating,
      reviewText: reviewController.text,
      dateAdded: DateTime.now(),
    );

    widget.onSubmit(review);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Book Title',
                  border: OutlineInputBorder(),
                ),
                validator: Validators.validateBookTitle,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: authorController,
                decoration: const InputDecoration(
                  labelText: 'Author',
                  border: OutlineInputBorder(),
                ),
                validator: Validators.validateAuthor,
              ),
              const SizedBox(height: 16),
              RatingBar.builder(
                initialRating: rating,
                minRating: 1,
                direction: Axis.horizontal,
                itemCount: 5,
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (value) => rating = value,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: reviewController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Review',
                  border: OutlineInputBorder(),
                ),
                validator: Validators.validateReview,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: submitForm,
                      child: Text(
                        widget.initialReview != null
                            ? 'Update Review'
                            : 'Add Review',
                      ),
                    ),
                  ),
                  if (widget.initialReview != null) ...[
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: widget.onCancel,
                      child: const Text('Cancel'),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}