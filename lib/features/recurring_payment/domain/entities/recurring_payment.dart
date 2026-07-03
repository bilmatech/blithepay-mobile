import 'package:equatable/equatable.dart';

class RecurringPayment extends Equatable {
  final String id;
  final String biller;
  final String type; // Prepaid or Postpaid
  final String meterNumber;
  final double amount;
  final String duration; // Weekly, Monthly, Quarterly, etc.
  final DateTime startDate;
  final DateTime? nextPaymentDate;
  final bool isActive;
  final int? totalPayments;
  final int? paymentsRemaining;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const RecurringPayment({
    required this.id,
    required this.biller,
    required this.type,
    required this.meterNumber,
    required this.amount,
    required this.duration,
    required this.startDate,
    this.nextPaymentDate,
    this.isActive = true,
    this.totalPayments,
    this.paymentsRemaining,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    biller,
    type,
    meterNumber,
    amount,
    duration,
    startDate,
    nextPaymentDate,
    isActive,
    totalPayments,
    paymentsRemaining,
    createdAt,
    updatedAt,
  ];

  RecurringPayment copyWith({
    String? id,
    String? biller,
    String? type,
    String? meterNumber,
    double? amount,
    String? duration,
    DateTime? startDate,
    DateTime? nextPaymentDate,
    bool? isActive,
    int? totalPayments,
    int? paymentsRemaining,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecurringPayment(
      id: id ?? this.id,
      biller: biller ?? this.biller,
      type: type ?? this.type,
      meterNumber: meterNumber ?? this.meterNumber,
      amount: amount ?? this.amount,
      duration: duration ?? this.duration,
      startDate: startDate ?? this.startDate,
      nextPaymentDate: nextPaymentDate ?? this.nextPaymentDate,
      isActive: isActive ?? this.isActive,
      totalPayments: totalPayments ?? this.totalPayments,
      paymentsRemaining: paymentsRemaining ?? this.paymentsRemaining,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
