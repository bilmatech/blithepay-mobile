// invoice_bloc.dart
import 'package:blithepay/features/students/data/models/invoice_model.dart';
import 'package:blithepay/features/students/data/repositories/students_repository.dart';
import 'package:blithepay/features/students/presentation/bloc/invoice_bloc.dart/invoice_event.dart';
import 'package:blithepay/features/students/presentation/bloc/invoice_bloc.dart/invoice_state.dart';
import 'package:bloc/bloc.dart';

class InvoiceBloc extends Bloc<InvoiceEvent, InvoiceState> {
  final StudentsRepository repository;
  final Map<String, List<InvoiceModel>> _cache = {};
  final Map<String, int?> _nextPage = {};
  final Set<String> _loadingStudents = {};

  InvoiceBloc({required this.repository}) : super(const InvoiceInitial()) {
    on<GetInvoiceEvent>(_onGetInvoices);
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
    if (event.page == 1 && !event.refresh)
      emit(InvoiceLoading(studentId: studentId));

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
}
