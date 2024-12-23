import 'package:flutter/material.dart';
import '../models/book_review.dart';
import '../services/database_service.dart';
import '../widgets/review_form.dart';
import '../widgets/review_card.dart';

class BookReviewPage extends StatefulWidget {
  const BookReviewPage({super.key});

  @override
  State<BookReviewPage> createState() => _BookReviewPageState();
}

class _BookReviewPageState extends State<BookReviewPage> {
  final DatabaseService _databaseService = DatabaseService();
  bool isLoading = true;
  List<BookReview> reviews = [];
  BookReview? editingReview;

  @override
  void initState() {
    super.initState();
    connectToDatabase();
  }

  @override
  void dispose() {
    _databaseService.close();
    super.dispose();
  }

  Future<void> connectToDatabase() async {
    try {
      await _databaseService.connect();
      fetchReviews();
    } catch (e) {
      showError('Failed to connect to database');
    }
  }

  Future<void> fetchReviews() async {
    try {
      setState(() => isLoading = true);
      final fetchedReviews = await _databaseService.getReviews();
      setState(() {
        reviews = fetchedReviews;
        isLoading = false;
      });
    } catch (e) {
      showError('Failed to fetch reviews');
      setState(() => isLoading = false);
    }
  }

  Future<void> saveReview(BookReview review) async {
    try {
      await _databaseService.saveReview(review);
      resetForm();
      fetchReviews();
    } catch (e) {
      showError('Failed to save review');
    }
  }

  Future<void> deleteReview(String id) async {
    try {
      await _databaseService.deleteReview(id);
      fetchReviews();
    } catch (e) {
      showError('Failed to delete review');
    }
  }

  void startEditing(BookReview review) {
    setState(() => editingReview = review);
  }

  void resetForm() {
    setState(() => editingReview = null);
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📚 Book Reviews'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ReviewForm(
                      initialReview: editingReview,
                      onSubmit: saveReview,
                      onCancel: resetForm,
                    ),
                    const SizedBox(height: 16),
                    ...reviews.map((review) => ReviewCard(
                      review: review,
                      onEdit: startEditing,
                      onDelete: deleteReview,
                    )).toList(),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: Container(
        color: Colors.blue,
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Developer: Yasas Pasindu Fernando',
              style: TextStyle(color: Colors.white),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.email, color: Colors.white),
                  onPressed: () {
                    // Add email functionality
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.code, color: Colors.white),
                  onPressed: () {
                    // Add GitHub link functionality
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}