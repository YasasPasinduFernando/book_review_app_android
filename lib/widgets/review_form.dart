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
  late TextEditingController titleController;
  late TextEditingController authorController;
  late TextEditingController reviewController;
  late double rating;

  @override
  void initState() {
    super.initState();
    initializeControllers();
  }

  @override
  void didUpdateWidget(ReviewForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    // This ensures the form updates when initialReview changes
    if (widget.initialReview != oldWidget.initialReview) {
      initializeControllers();
    }
  }

  void initializeControllers() {
    // Initialize controllers with initial values or empty strings
    titleController = TextEditingController(text: widget.initialReview?.bookTitle ?? '');
    authorController = TextEditingController(text: widget.initialReview?.author ?? '');
    reviewController = TextEditingController(text: widget.initialReview?.reviewText ?? '');
    rating = widget.initialReview?.rating ?? 5.0;
    
    // Force rebuild to update the UI
    setState(() {});
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
      id: widget.initialReview?.id,  // Preserve the original ID if editing
      bookTitle: titleController.text,
      author: authorController.text,
      rating: rating,
      reviewText: reviewController.text,
      dateAdded: widget.initialReview?.dateAdded ?? DateTime.now(),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.initialReview != null ? 'Edit Review' : 'Add New Review',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
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
              Row(
                children: [
                  Text('Rating: ', style: Theme.of(context).textTheme.titleMedium),
                  RatingBar.builder(
                    initialRating: rating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (value) {
                      setState(() => rating = value);
                    },
                  ),
                ],
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
                        widget.initialReview != null ? 'Update Review' : 'Add Review',
                      ),
                    ),
                  ),
                  if (widget.initialReview != null) ...[
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        widget.onCancel();
                        initializeControllers(); // Reset form when canceling
                      },
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