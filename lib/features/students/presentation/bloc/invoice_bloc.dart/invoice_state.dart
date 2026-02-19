import 'package:blithepay/features/students/data/models/invoice_model.dart';

abstract class InvoiceState {
  const InvoiceState();
}

class InvoiceInitial extends InvoiceState {
  const InvoiceInitial();
}

class InvoiceLoaded extends InvoiceState {
  final String studentId;
  final List<InvoiceModel> invoice;
  final int? nextPage;
  final bool isFetchingMore;

  const InvoiceLoaded({
    required this.studentId,
    required this.invoice,
    this.nextPage,
    this.isFetchingMore = false,
  });

  InvoiceLoaded copyWith({
    String? studentId,
    List<InvoiceModel>? invoice,
    int? nextPage,
    bool? isFetchingMore,
  }) {
    return InvoiceLoaded(
      studentId: studentId ?? this.studentId,
      invoice: invoice ?? this.invoice,
      nextPage: nextPage ?? this.nextPage,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
    );
  }
}

class InvoiceLoading extends InvoiceState {
  final String studentId;

  const InvoiceLoading({required this.studentId});
}

class InvoiceError extends InvoiceState {
  final String studentId;

  final String message;
  const InvoiceError({required this.message, required this.studentId});
}

class InvoiceByIdLoading extends InvoiceState {}

class InvoiceByIdLoaded extends InvoiceState {
  final InvoiceModel invoice;

  InvoiceByIdLoaded({required this.invoice});
}

class InvoiceByIdError extends InvoiceState {
  final String message;

  InvoiceByIdError({required this.message});
}
