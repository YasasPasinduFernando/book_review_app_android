import 'package:mongo_dart/mongo_dart.dart';

class BookReview {
  final ObjectId? id;
  final String bookTitle;
  final String author;
  final double rating;
  final String reviewText;
  final DateTime dateAdded;

  BookReview({
    this.id,
    required this.bookTitle,
    required this.author,
    required this.rating,
    required this.reviewText,
    required this.dateAdded,
  });

  factory BookReview.fromMap(Map<String, dynamic> map) {
    return BookReview(
      id: map['_id'] as ObjectId?,
      bookTitle: map['bookTitle'] as String,
      author: map['author'] as String,
      rating: (map['rating'] as num).toDouble(),
      reviewText: map['reviewText'] as String,
      dateAdded: map['dateAdded'] as DateTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookTitle': bookTitle,
      'author': author,
      'rating': rating,
      'reviewText': reviewText,
      'dateAdded': dateAdded,
    };
  }
}