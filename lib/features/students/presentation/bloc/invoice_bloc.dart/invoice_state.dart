import 'package:blithepay/features/students/data/models/invoice_model.dart';
import 'package:blithepay/features/students/data/models/view_invoice_model.dart';

abstract class InvoiceState {
  const InvoiceState();
}

class InvoiceInitial extends InvoiceState {
  const InvoiceInitial();
}

class InvoiceLoaded extends InvoiceState {
  final String studentId;
  //final Fee fee;

  final List<InvoiceModel> invoice;
  final int? nextPage;
  final bool isFetchingMore;

  const InvoiceLoaded({
    required this.studentId,
    // required this.fee,
    required this.invoice,
    this.nextPage,
    this.isFetchingMore = false,
  });

  InvoiceLoaded copyWith({
    String? studentId,

    //  final Fee? fee,
    List<InvoiceModel>? invoice,
    int? nextPage,
    bool? isFetchingMore,
  }) {
    return InvoiceLoaded(
      studentId: studentId ?? this.studentId,

      //  fee: fee ?? this.fee,
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

class InvoiceByIdLoading extends InvoiceState {
  final List<InvoiceModel>? existingInvoices;
  const InvoiceByIdLoading({this.existingInvoices});
}

class InvoiceByIdLoaded extends InvoiceState {
  final InvoiceModel invoice;

  InvoiceByIdLoaded({required this.invoice});
}

class InvoiceByIdViewLoaded extends InvoiceState {
  final ViewInvoiceModel invoice;
  final List<InvoiceModel>? existingInvoices;
  final int? nextPage;

  const InvoiceByIdViewLoaded({
    required this.invoice,
    this.existingInvoices,
    this.nextPage,
  });
}

class InvoiceByIdError extends InvoiceState {
  final String message;

  InvoiceByIdError({required this.message});
}

enum InvoiceDownloadStatus { idle, inProgress, success, failure }

class InvoiceDownloadState extends InvoiceState {
  final dynamic invoice;
  final InvoiceDownloadStatus downloadStatus;
  final String? downloadedFilePath;
  final String? errorMessage;

  const InvoiceDownloadState({
    this.invoice,
    this.downloadStatus = InvoiceDownloadStatus.idle,
    this.downloadedFilePath,
    this.errorMessage,
  });

  InvoiceDownloadState copyWith({
    InvoiceDownloadStatus? downloadStatus,
    String? downloadedFilePath,
    String? errorMessage,
  }) {
    return InvoiceDownloadState(
      invoice: invoice,
      downloadStatus: downloadStatus ?? this.downloadStatus,
      downloadedFilePath: downloadedFilePath ?? this.downloadedFilePath,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
