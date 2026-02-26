import 'package:blithepay/features/students/data/models/verify_student_model.dart';
import 'package:blithepay/features/students/presentation/bloc/transaction_bloc.dart/transaction_bloc.dart';
import 'package:blithepay/features/students/presentation/bloc/transaction_bloc.dart/transaction_event.dart';
import 'package:blithepay/features/students/presentation/bloc/transaction_bloc.dart/transaction_state.dart';
import 'package:blithepay/features/students/presentation/views/linked_student_view/payment_history_section.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:blithepay/shared/widgets/loaders/shimmer_table_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class FeesTransactionsView extends StatefulWidget {
  const FeesTransactionsView({super.key, required this.student});
  final VerifiedStudentModel student;

  @override
  State<FeesTransactionsView> createState() => _FeesTransactionsViewState();
}

class _FeesTransactionsViewState extends State<FeesTransactionsView> {
  final ScrollController _scrollController = ScrollController();

  String? currentFilter;
  String? currentSort;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 100) {
      final state = context.read<StudentTransactionsBloc>().state;

      if (state is StudentTransactionLoaded &&
          state.nextPage != null &&
          !state.isFetchingMore) {
        context.read<StudentTransactionsBloc>().add(
          GetPaymentHistoryEvent(
            page: state.nextPage!,
            limit: 20,
            studentId: widget.student.id,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        title: const Text('Payment History'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 26),
        child: BlocBuilder<StudentTransactionsBloc, StudentTransactionState>(
          builder: (context, state) {
            if (state is StudentTransactionLoading) {
              return const ShimmerTableLoader();
            }

            if (state is StudentTransactionError) {
              return Center(child: Text(state.message));
            }

            if (state is StudentTransactionLoaded) {
              return state.studentTransaction.isEmpty
                  ? const Center(child: Text('No payment history available.'))
                  : RefreshIndicator(
                      onRefresh: () async {
                        context.read<StudentTransactionsBloc>().add(
                          GetPaymentHistoryEvent(
                            page: 1,
                            limit: 20,
                            refresh: true,
                            studentId: widget.student.id,
                          ),
                        );
                      },
                      child: ListView.separated(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        itemCount:
                            state.studentTransaction.length +
                            (state.isFetchingMore ? 1 : 0),
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          if (index < state.studentTransaction.length) {
                            final transaction = state.studentTransaction[index];
                            return StudentTransactionContainer(
                              transaction: transaction,
                            );
                          }

                          // Bottom loader
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        },
                      ),
                    );
            }

                  return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
