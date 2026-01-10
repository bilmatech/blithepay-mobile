import 'package:equatable/equatable.dart';

class TransactionModel extends Equatable {
  final String id;
  final String title;
  final String amount;
  final String date;
  final String time;
  final String status;
  final String icon;

  const TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.time,
    required this.status,
    required this.icon,
  });

  @override
  List<Object?> get props => [id, title, amount, date, time, status, icon];
}
