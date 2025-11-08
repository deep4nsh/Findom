import 'package:cloud_firestore/cloud_firestore.dart';

enum SubscriptionTier { free, premium }

class Subscription {
  final String uid;
  final SubscriptionTier tier;
  final Timestamp expirationDate;

  Subscription({
    required this.uid,
    this.tier = SubscriptionTier.free,
    required this.expirationDate,
  });

  // Corrected: Convert Timestamp to DateTime before comparison
  bool get isActive => expirationDate.toDate().isAfter(DateTime.now());

  factory Subscription.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Subscription(
      uid: doc.id,
      tier: SubscriptionTier.values.firstWhere(
        (e) => e.toString() == data['tier'],
        orElse: () => SubscriptionTier.free,
      ),
      expirationDate: data['expirationDate'] ?? Timestamp.fromMicrosecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'tier': tier.toString(),
      'expirationDate': expirationDate,
    };
  }
}
