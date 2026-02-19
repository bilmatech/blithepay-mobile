abstract class WalletTransactionEvent {}

class GetTransactionsEvent extends WalletTransactionEvent {
  final int page;
  final int limit;
  final bool refresh;

   GetTransactionsEvent({
    this.page = 1,
    this.limit = 20,
    this.refresh = false,
  });
}
