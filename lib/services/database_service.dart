import 'package:mongo_dart/mongo_dart.dart';
import '../config/mongodb_config.dart';
import '../models/book_review.dart';

class DatabaseService {
  late Db _db;
  bool isConnected = false;

  Future<void> connect() async {
    try {
      _db = await Db.create(MongoDBConfig.connectionString);
      await _db.open();
      isConnected = true;
    } catch (e) {
      isConnected = false;
      throw Exception('Failed to connect to database: $e');
    }
  }

  Future<void> close() async {
    await _db.close();
  }

  Future<List<BookReview>> getReviews() async {
    try {
      final collection = _db.collection(MongoDBConfig.reviewsCollection);
      final result = await collection.find().toList();
      return result
          .map((doc) => BookReview.fromMap(doc))
          .toList()
        ..sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
    } catch (e) {
      throw Exception('Failed to fetch reviews: $e');
    }
  }

  Future<void> saveReview(BookReview review) async {
    try {
      final collection = _db.collection(MongoDBConfig.reviewsCollection);
      if (review.id != null) {
        await collection.updateOne(
          where.id(review.id!),
          modify
            .set('bookTitle', review.bookTitle)
            .set('author', review.author)
            .set('rating', review.rating)
            .set('reviewText', review.reviewText),
        );
      } else {
        await collection.insertOne(review.toMap());
      }
    } catch (e) {
      throw Exception('Failed to save review: $e');
    }
  }

  Future<void> deleteReview(String id) async {
    try {
      final collection = _db.collection(MongoDBConfig.reviewsCollection);
      await collection.deleteOne(where.id(ObjectId.fromHexString(id)));
    } catch (e) {
      throw Exception('Failed to delete review: $e');
    }
  }
}