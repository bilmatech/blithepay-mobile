import 'package:equatable/equatable.dart';

enum TransactionStatus {
  PENDING,
  SUCCESS,
  REVERSED,
  FAILED,
}

class TransactionEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final double amount;
  final TransactionStatus status;
  final DateTime dateTime;
  final String serviceType;
  final String reference;
  final String paymentMethod;

  const TransactionEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.status,
    required this.dateTime,
    required this.serviceType,
    required this.reference,
    required this.paymentMethod,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    amount,
    status,
    dateTime,
    serviceType,
    reference,
    paymentMethod,
  ];
}
