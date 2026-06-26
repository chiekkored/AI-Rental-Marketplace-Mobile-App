import 'package:cloud_firestore/cloud_firestore.dart';

class Rating {
  final int rating;
  final String review;
  final String userId;
  final Timestamp timestamp;

  Rating({
    required this.rating,
    required this.review,
    required this.userId,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'rating': rating,
      'review': review,
      'userId': userId,
      'timestamp': timestamp,
    };
  }

  factory Rating.fromMap(Map<String, dynamic> map) {
    return Rating(
      rating: map['rating'] as int,
      review: map['review'] as String,
      userId: map['userId'] as String,
      timestamp: map['timestamp'] as Timestamp,
    );
  }
}
