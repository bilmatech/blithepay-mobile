// invoice_bloc.dart
import 'dart:io';

import 'package:blithepay/features/students/data/models/invoice_model.dart';
import 'package:blithepay/features/students/data/repositories/students_repository.dart';
import 'package:blithepay/features/students/presentation/bloc/invoice_bloc.dart/invoice_event.dart';
import 'package:blithepay/features/students/presentation/bloc/invoice_bloc.dart/invoice_state.dart';
import 'package:bloc/bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class InvoiceBloc extends Bloc<InvoiceEvent, InvoiceState> {
  final StudentsRepository repository;
  final Map<String, List<InvoiceModel>> _cache = {};
  final Map<String, int?> _nextPage = {};
  final Set<String> _loadingStudents = {};

  InvoiceBloc({required this.repository}) : super(const InvoiceInitial()) {
    on<GetInvoiceEvent>(_onGetInvoices);
    on<GetInvoiceByIdEvent>(_onGetInvoiceById);
    on<GetInvoiceByIdViewEvent>(_onGetInvoiceByIdView);
    on<GetInvoiceByIdDownloadEvent>(_onGetInvoiceByIdDownload);
  }

  Future<void> _onGetInvoices(
    GetInvoiceEvent event,
    Emitter<InvoiceState> emit,
  ) async {
    final studentId = event.studentId;

    if (_loadingStudents.contains(studentId)) return;

    final existing = _cache[studentId] ?? [];
    if (!event.refresh && existing.isNotEmpty && event.page == 1) {
      emit(
        InvoiceLoaded(
          studentId: studentId,
          invoice: existing,
          nextPage: _nextPage[studentId],
        ),
      );
      return;
    }

    _loadingStudents.add(studentId);
    if (event.page == 1 && !event.refresh) {
      emit(InvoiceLoading(studentId: studentId));
    }

    try {
      final result = await repository.getInvoices(
        studentId,
        page: event.page,
        limit: event.limit,
      );

      final updated = event.refresh
          ? result.invoices
          : [...existing, ...result.invoices];

      _cache[studentId] = updated;
      _nextPage[studentId] = result.nextPage;

      emit(
        InvoiceLoaded(
          studentId: studentId,
          invoice: updated,
          nextPage: result.nextPage,
        ),
      );
    } catch (e) {
      emit(InvoiceError(studentId: studentId, message: e.toString()));
    } finally {
      _loadingStudents.remove(studentId);
    }
  }

  Future<void> _onGetInvoiceById(
    GetInvoiceByIdEvent event,
    Emitter<InvoiceState> emit,
  ) async {
    emit(const InvoiceByIdLoading());

    try {
      final invoice = await repository.getInvoiceById(event.invoiceId);
      emit(InvoiceByIdLoaded(invoice: invoice));
    } catch (e) {
      emit(InvoiceByIdError(message: e.toString()));
    }
  }

  Future<void> _onGetInvoiceByIdView(
    GetInvoiceByIdViewEvent event,
    Emitter<InvoiceState> emit,
  ) async {
    final currentState = state;

    // Keep the loaded invoice list if it exists
    List<InvoiceModel> existingInvoices = [];
    int? nextPage;

    if (currentState is InvoiceLoaded) {
      existingInvoices = currentState.invoice;
      nextPage = currentState.nextPage;
    }

    emit(InvoiceByIdLoading(existingInvoices: existingInvoices));

    try {
      final invoice = await repository.getInvoiceView(
        event.invoiceId,
        event.feesItemIds!,
      );

      emit(
        InvoiceByIdViewLoaded(
          invoice: invoice,
          existingInvoices: existingInvoices,
          nextPage: nextPage,
        ),
      );
    } catch (e) {
      emit(InvoiceByIdError(message: e.toString()));
    }
  }

  // Bloc
  Future<void> _onGetInvoiceByIdDownload(
    GetInvoiceByIdDownloadEvent event,
    Emitter<InvoiceState> emit,
  ) async {
    // Get the current invoice from state
    final currentInvoice = state is InvoiceByIdLoaded
        ? (state as InvoiceByIdLoaded).invoice
        : state is InvoiceDownloadState
        ? (state as InvoiceDownloadState).invoice
        : null;

    if (currentInvoice == null) {
      // Cannot download without a loaded invoice
      emit(
        const InvoiceDownloadState(
          invoice: null, // Optional: you can make this nullable
          downloadStatus: InvoiceDownloadStatus.failure,
          errorMessage: 'No invoice loaded to download',
        ),
      );
      return;
    }

    emit(
      InvoiceDownloadState(
        invoice: currentInvoice,
        downloadStatus: InvoiceDownloadStatus.inProgress,
      ),
    );

    try {
      if (Platform.isAndroid) {
        final status = await Permission.manageExternalStorage.request();
        if (!status.isGranted) {
          emit(
            InvoiceDownloadState(
              invoice: currentInvoice,
              downloadStatus: InvoiceDownloadStatus.failure,
              errorMessage: 'Storage permission denied',
            ),
          );
          return;
        }
      }

      final bytes = await repository.downloadInvoice(event.invoiceId);

      String filePath;
      if (Platform.isAndroid) {
        final dir = Directory('/storage/emulated/0/Download');
        if (!await dir.exists()) await dir.create(recursive: true);
        filePath = '${dir.path}/invoice_${event.invoiceId}.pdf';
      } else {
        final dir = await getApplicationDocumentsDirectory();
        filePath = '${dir.path}/invoice_${event.invoiceId}.pdf';
      }

      final file = File(filePath);
      await file.writeAsBytes(bytes, flush: true);

      emit(
        InvoiceDownloadState(
          invoice: currentInvoice,
          downloadStatus: InvoiceDownloadStatus.success,
          downloadedFilePath: filePath,
        ),
      );
    } catch (e) {
      emit(
        InvoiceDownloadState(
          invoice: currentInvoice,
          downloadStatus: InvoiceDownloadStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
