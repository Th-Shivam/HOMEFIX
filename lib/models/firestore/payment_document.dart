import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/db/collections.dart';
import '../../core/db/firestore_mapper.dart';

class PaymentDocument {
  final String paymentId;
  final String userId;
  final String subscriptionId;
  final double amount;
  final String currency;
  final String planType;
  final String status;
  final String method;
  final String idempotencyKey;
  final String? gatewayReference;
  final String? proofImageUrl;
  final DateTime? createdAt;

  const PaymentDocument({
    required this.paymentId,
    required this.userId,
    required this.subscriptionId,
    required this.amount,
    required this.currency,
    required this.planType,
    required this.status,
    required this.method,
    required this.idempotencyKey,
    this.gatewayReference,
    this.proofImageUrl,
    this.createdAt,
  });

  factory PaymentDocument.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snap,
  ) {
    final data = snap.data() ?? {};
    return PaymentDocument(
      paymentId: snap.id,
      userId: FirestoreMapper.readString(data, DbFields.userId),
      subscriptionId: FirestoreMapper.readString(data, DbFields.subscriptionId),
      amount: FirestoreMapper.readDouble(data, DbFields.amount),
      currency: FirestoreMapper.readString(data, DbFields.currency, fallback: 'INR'),
      planType: FirestoreMapper.readString(data, DbFields.planType),
      status: FirestoreMapper.readString(data, DbFields.status),
      method: FirestoreMapper.readString(data, DbFields.method),
      idempotencyKey: FirestoreMapper.readString(data, DbFields.idempotencyKey),
      gatewayReference: data[DbFields.gatewayReference] as String?,
      proofImageUrl: data[DbFields.proofImageUrl] as String?,
      createdAt: FirestoreMapper.timestampToDate(data[DbFields.createdAt]),
    );
  }

  Map<String, dynamic> toCreateMap() {
    return {
      ...FirestoreMapper.baseFields(),
      DbFields.paymentId: paymentId,
      DbFields.userId: userId,
      DbFields.subscriptionId: subscriptionId,
      DbFields.amount: amount,
      DbFields.currency: currency,
      DbFields.planType: planType,
      DbFields.status: status,
      DbFields.method: method,
      DbFields.idempotencyKey: idempotencyKey,
      if (gatewayReference != null) DbFields.gatewayReference: gatewayReference,
      if (proofImageUrl != null) DbFields.proofImageUrl: proofImageUrl,
    };
  }
}
