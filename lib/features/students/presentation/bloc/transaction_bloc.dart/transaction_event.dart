abstract class StudentTransactionEvent {
  const StudentTransactionEvent();
}

class GetPaymentHistoryEvent extends StudentTransactionEvent {
  final int page;
  final int limit;
  final String studentId;

  final bool refresh;

  const GetPaymentHistoryEvent({
    this.page = 1,
    this.limit = 20,
    required this.studentId,
    this.refresh = false,
  });

  List<Object?> get props => [page, limit, studentId, refresh];
}
