import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    connectToDatabase();
  }

  @override
  void dispose() {
    _databaseService.close();
    _scrollController.dispose();
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
      if (mounted) {
        setState(() {
          reviews = fetchedReviews;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        showError('Failed to fetch reviews');
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> saveReview(BookReview review) async {
    try {
      await _databaseService.saveReview(review);
      if (mounted) {
        setState(() => editingReview = null);
        await fetchReviews();
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(review.id != null
                ? 'Review updated successfully!'
                : 'Review added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      showError('Failed to save review');
    }
  }

  Future<void> deleteReview(String id) async {
    try {
      await _databaseService.deleteReview(id);
      if (mounted) {
        await fetchReviews();
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      showError('Failed to delete review');
    }
  }

  void startEditing(BookReview review) {
    setState(() {
      editingReview = review;
      // Scroll to top where the form is
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void resetForm() {
    setState(() {
      editingReview = null;
    });
  }

  void showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'yasaspasindufernando@gmail.com',
      query: 'subject=Book Review App Feedback',
    );

    try {
      await launchUrl(emailUri);
    } catch (e) {
      showError('Could not launch email client');
    }
  }

  Future<void> _launchGitHub() async {
    final Uri githubUri = Uri.parse(
        'https://github.com/YasasPasinduFernando/book_review_app_android');

    try {
      await launchUrl(githubUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      showError('Could not launch GitHub');
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.book_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No reviews yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first book review above!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📚 Book Reviews'),
        centerTitle: true,
        elevation: 2,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchReviews,
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
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
                      const SizedBox(height: 24),
                      if (reviews.isEmpty && !isLoading)
                        _buildEmptyState()
                      else
                        ...reviews
                            .map((review) => ReviewCard(
                                  review: review,
                                  onEdit: startEditing,
                                  onDelete: deleteReview,
                                ))
                            .toList(),
                    ],
                  ),
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
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.email, color: Colors.white),
                  onPressed: _launchEmail,
                  tooltip: 'Send email',
                ),
                IconButton(
                  icon: const Icon(Icons.code, color: Colors.white),
                  onPressed: _launchGitHub,
                  tooltip: 'View source code',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
