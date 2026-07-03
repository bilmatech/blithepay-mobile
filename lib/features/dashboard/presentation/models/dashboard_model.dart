import 'package:equatable/equatable.dart';

class DashboardModel extends Equatable {
  final String greeting;
  final String userName;
  final String avatarUrl;
  final String totalOutstanding;
  final String nextDueDate;
  final String walletBalance;
  final String selectedChildId;
  final String selectedChildName;
  final List<TransactionItem> transactions;

  const DashboardModel({
    required this.greeting,
    required this.userName,
    required this.avatarUrl,
    required this.totalOutstanding,
    required this.nextDueDate,
    required this.walletBalance,
    required this.selectedChildId,
    required this.selectedChildName,
    required this.transactions,
  });

  DashboardModel copyWith({
    String? greeting,
    String? userName,
    String? avatarUrl,

    String? totalOutstanding,
    String? nextDueDate,
    String? walletBalance,
    String? selectedChildId,
    String? selectedChildName,
    List<TransactionItem>? transactions,
  }) {
    return DashboardModel(
      greeting: greeting ?? this.greeting,
      userName: userName ?? this.userName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      totalOutstanding: totalOutstanding ?? this.totalOutstanding,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      walletBalance: walletBalance ?? this.walletBalance,
      selectedChildId: selectedChildId ?? this.selectedChildId,
      selectedChildName: selectedChildName ?? this.selectedChildName,
      transactions: transactions ?? this.transactions,
    );
  }

  factory DashboardModel.mock() {
    return const DashboardModel(
      greeting: 'Good morning,',
      userName: 'Emmanuel Seaman',
      avatarUrl: '',
      totalOutstanding: 'N120,000',
      nextDueDate: '13 June, 2026',
      walletBalance: 'N470,000',
      selectedChildId: '1',
      selectedChildName: 'Adesanmi Mi...',
      transactions: [
        TransactionItem(
          title: 'Tuition fee',
          amount: 'N300,000.00',
          date: '11-09-25',
          time: '11:15',
          status: 'Successful',
        ),
        TransactionItem(
          title: 'Wallet Deposit',
          amount: 'N200,000.00',
          date: '11-09-25',
          time: '11:15',
          status: 'Successful',
        ),
        TransactionItem(
          title: 'Wallet Withdrawal',
          amount: 'N100,000.00',
          date: '11-09-25',
          time: '11:15',
          status: 'Successful',
        ),
        TransactionItem(
          title: 'Textbooks',
          amount: 'N300,000.00',
          date: '11-09-25',
          time: '11:15',
          status: 'Successful',
        ),
        TransactionItem(
          title: 'Tuition fee',
          amount: 'N300,000.00',
          date: '11-09-25',
          time: '11:15',
          status: 'Successful',
        ),
      ],
    );
  }

  @override
  List<Object?> get props => [
    greeting,
    userName,
    totalOutstanding,
    nextDueDate,
    walletBalance,
    selectedChildId,
    selectedChildName,
    transactions,
  ];
}

class TransactionItem extends Equatable {
  final String title;
  final String amount;
  final String date;
  final String time;
  final String status;

  const TransactionItem({
    required this.title,
    required this.amount,
    required this.date,
    required this.time,
    required this.status,
  });

  @override
  List<Object?> get props => [title, amount, date, time, status];
}
