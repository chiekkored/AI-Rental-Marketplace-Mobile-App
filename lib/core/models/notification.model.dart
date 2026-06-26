import 'package:cloud_firestore/cloud_firestore.dart';

class LNDNotification {
  final String id;
  final String title;
  final String body;
  final String type;
  final String? imageUrl;
  final Map<String, dynamic> data;
  final Timestamp? createdAt;
  final Timestamp? readAt;

  const LNDNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.imageUrl,
    required this.data,
    required this.createdAt,
    required this.readAt,
  });

  bool get isUnread => readAt == null;

  factory LNDNotification.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final map = doc.data() ?? <String, dynamic>{};
    final data = map['data'];
    final notificationData =
        data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};

    return LNDNotification(
      id: doc.id,
      title: map['title']?.toString() ?? 'Notification',
      body: map['body']?.toString() ?? '',
      type:
          map['type']?.toString() ??
          notificationData['type']?.toString() ??
          'general',
      imageUrl: notificationData['imageUrl']?.toString(),
      data: notificationData,
      createdAt: map['createdAt'] is Timestamp ? map['createdAt'] : null,
      readAt: map['readAt'] is Timestamp ? map['readAt'] : null,
    );
  }
}
