import 'package:blithepay/core/network/dio_error_mapper.dart';
import 'package:blithepay/features/students/data/models/fee_transaction_model.dart';
import 'package:blithepay/features/students/data/models/invoice_model.dart';
import 'package:blithepay/features/students/data/models/verify_student_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/students_repository.dart';
import 'students_event.dart';
import 'students_state.dart';

class StudentsBloc extends Bloc<StudentsEvent, StudentsState> {
  final StudentsRepository repository;

  StudentsBloc({required this.repository}) : super(const StudentsInitial()) {
    on<VerifyChildEvent>(verifyStudent);
    on<LinkChildEvent>(linkStudent);
    on<UNLinkChildEvent>(unlinkStudent);
    on<GetLinkedStudentsEvent>(_onGetLinkedStudents);
    on<GetStudentDetailsEvent>(_onGetStudentDetails);
    on<GetFeeTransactionsEvent>(_onGetTransactions);
    on<GetInvoiceEvent>(_onGetInvoices);
  }

  bool _hasFetchedOnce = false;

  Future<void> _onGetLinkedStudents(
    GetLinkedStudentsEvent event,
    Emitter<StudentsState> emit,
  ) async {
    final currentState = state;

    List<VerifiedStudentModel> oldStudents = [];

    // Only append if paging
    if (!event.refresh && currentState is StudentsLoaded && event.page > 1) {
      oldStudents = currentState.students;
    }
    // Determine if we should show shimmer
    final showShimmer = !_hasFetchedOnce && !event.refresh;

    if (showShimmer) emit(const StudentsLoading());

    try {
      final result = await repository.getLinkedStudents(
        page: event.page,
        limit: event.limit,
        studentCode: event.studentCode ?? '',
      );

      final updatedStudents = [...oldStudents, ...result.students];
      _hasFetchedOnce = true;

      emit(
        StudentsLoaded(
          students: updatedStudents,
          nextPage: result.nextPage ?? 1,
        ),
      );
    } catch (e) {
      emit(StudentsError(message: extractError(e)));

      // Re-emit old state to prevent screen clearing
      if (currentState is StudentsLoaded) {
        emit(currentState);
      }
    }
  }

  Future<void> verifyStudent(
    VerifyChildEvent event,
    Emitter<StudentsState> emit,
  ) async {
    try {
      emit(VerifyStudentS());
      var res = await repository.verifyStudent(
        event.schoolId,
        event.regNum,
        event.studentCode,
      );
      emit(VerifyStudentSuccess(model: res));
    } catch (e) {
      emit(StudentsError(message: extractError(e)));
    }
  }

  Future<void> linkStudent(
    LinkChildEvent event,
    Emitter<StudentsState> emit,
  ) async {
    try {
      emit(
        StudentsLinking(studentId: event.studentId),
      ); // show spinner only for this student
      var res = await repository.linkStudent(
        event.studentId,
        event.studentCode,
      );
      emit(StudentsLinkSuccess(model: res));

      // Refresh list after unlink
      add(const GetLinkedStudentsEvent(page: 1, limit: 20));
    } catch (e) {
      emit(StudentsError(message: extractError(e)));
    }
  }

  Future<void> unlinkStudent(
    UNLinkChildEvent event,
    Emitter<StudentsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! StudentsLoaded) return;

    // Mark this student as loading
    emit(
      currentState.copyWith(
        loadingStudentIds: {...currentState.loadingStudentIds, event.studentId},
      ),
    );

    try {
      await repository.unlinkStudent(event.studentId, event.studentCode);

      final updatedStudents = currentState.students
          .where((s) => s.id != event.studentId)
          .toList();

      // Remove from loading set
      final newLoadingIds = Set<String>.from(currentState.loadingStudentIds)
        ..remove(event.studentId);

      emit(
        currentState.copyWith(
          students: updatedStudents,
          loadingStudentIds: newLoadingIds,
        ),
      );
    } catch (e) {
      final newLoadingIds = Set<String>.from(currentState.loadingStudentIds)
        ..remove(event.studentId);

      emit(currentState.copyWith(loadingStudentIds: newLoadingIds));
    }
  }

  // Future<void> _onGetLinkedStudents(
  //   GetLinkedStudentsEvent event,
  //   Emitter<StudentsState> emit,
  // ) async {
  //   if (state is StudentsLoaded) return;
  //   emit(const StudentsLoading());
  //   try {
  //     final students = await repository.getLinkedStudents();
  //     emit(StudentsLoaded(students: students));
  //   } catch (e) {
  //     emit(StudentsError(message: e.toString()));
  //   }
  // }

  Future<void> _onGetStudentDetails(
    GetStudentDetailsEvent event,
    Emitter<StudentsState> emit,
  ) async {
    emit(const StudentsLoading());
    try {
      final student = await repository.getStudentDetails(event.studentId);
      emit(StudentDetailsLoaded(student: student));
    } catch (e) {
      emit(StudentsError(message: extractError(e)));
    }
  }

  bool _hasWalletTFetchedOnce = false; // at bloc level

  Future<void> _onGetTransactions(
    GetFeeTransactionsEvent event,
    Emitter<StudentsState> emit,
  ) async {
    final currentState = state;

    List<FeeTransactionModel> oldTransactions = [];

    if (!event.refresh &&
        currentState is FeeTransactionLoaded &&
        event.page > 1) {
      oldTransactions = currentState.wallet;
    }

    final showShimmer = !_hasWalletTFetchedOnce && !event.refresh;

    if (showShimmer) {
      emit(const StudentsLoading());
      await Future.delayed(const Duration(milliseconds: 250));
    }
    if (_hasWalletTFetchedOnce && !event.refresh) return;

    try {
      final result = await repository.getWalletTransaction(
        page: event.page,
        limit: event.limit,
      );

      final updatedTransactions = event.refresh
          ? result.transactions
          : [...oldTransactions, ...result.transactions];

      _hasWalletTFetchedOnce = true;

      emit(
        FeeTransactionLoaded(
          wallet: updatedTransactions,
          nextPage: result.nextPage,
          isFetchingMore: false,
        ),
      );
    } catch (e) {
      emit(StudentsError(message: extractError(e)));

      // Re-emit old state to avoid clearing screen
      if (currentState is FeeTransactionLoaded) {
        emit(currentState);
      }
    }
  }

  bool _hasInvoiceFetchedOnce = false; // at bloc level

  Future<void> _onGetInvoices(
    GetInvoiceEvent event,
    Emitter<StudentsState> emit,
  ) async {
    final currentState = state;

    List<InvoiceModel> oldInvoice = [];

    if (!event.refresh &&
        currentState is InvoiceLoaded &&
        event.page > 1) {
      oldInvoice = currentState.invoice;
    }

    final showShimmer = !_hasInvoiceFetchedOnce && !event.refresh;

    if (showShimmer) {
      emit(const StudentsLoading());
      await Future.delayed(const Duration(milliseconds: 250));
    }
    if (_hasInvoiceFetchedOnce && !event.refresh) return;

    try {
      final result = await repository.getInvoices(
        event.studentId,
        page: event.page,
        limit: event.limit,
      );

      final updatedTransactions = event.refresh
          ? result.invoices
          : [...oldInvoice, ...result.invoices];

      _hasInvoiceFetchedOnce = true;

      emit(
        InvoiceLoaded(
          invoice: updatedTransactions,
          nextPage: result.nextPage,
          isFetchingMore: false,
        ),
      );
    } catch (e) {
      emit(StudentsError(message: extractError(e)));

      // Re-emit old state to avoid clearing screen
      if (currentState is InvoiceLoaded) {
        emit(currentState);
      }
    }
  }
}
