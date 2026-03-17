import 'package:blithepay/features/students/presentation/bloc/invoice_bloc.dart/invoice_bloc.dart';
import 'package:blithepay/features/students/presentation/bloc/invoice_bloc.dart/invoice_event.dart';
import 'package:blithepay/features/students/presentation/bloc/students_event.dart';
import 'package:blithepay/features/students/presentation/views/linked_student/components/empty_state.dart';
import 'package:blithepay/features/students/presentation/views/linked_student_view/linked_student_appbar.dart';
import 'package:blithepay/features/students/presentation/views/linked_student_view/linked_student_body.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/students_bloc.dart';
import '../bloc/students_state.dart';
import '../../../../shared/widgets/loaders/shimmer_list_loader.dart';

class LinkedStudentsView extends StatelessWidget {
  const LinkedStudentsView({super.key});

  static StudentsLoaded? _lastLoaded;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const LinkedStudentsAppBar(),
      body: RefreshIndicator(
        onRefresh: () async {
          final studentsBloc = context.read<StudentsBloc>();

          studentsBloc.add(const GetLinkedStudentsEvent(refresh: true));

          await studentsBloc.stream.firstWhere(
            (state) => state is StudentsLoaded,
          );

          final loaded = studentsBloc.state as StudentsLoaded;

          for (final student in loaded.students) {
            context.read<InvoiceBloc>().add(
              GetInvoiceEvent(studentId: student.id, refresh: true),
            );
          }
        },
        child: BlocListener<StudentsBloc, StudentsState>(
          listener: (context, state) {
            if (state is StudentsLoaded) {
              _lastLoaded = state;
            }

            if (state is StudentsLoaded && state.errorMessage != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            }
          },
          child: BlocBuilder<StudentsBloc, StudentsState>(
            builder: (context, state) {
              if (state is StudentsLoading && _lastLoaded == null) {
                return const ShimmerListLoader();
              }

              final loaded = state is StudentsLoaded ? state : _lastLoaded;

              if (loaded == null) {
                return const ShimmerListLoader();
              }

              if (loaded.students.isEmpty) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 120),
                    buildEmptyState(context),
                  ],
                );
              }

              return LinkedStudentsBody(students: loaded.students);
            },
          ),
        ),
      ),
    );
  }
}

// class LinkedStudentsView extends StatelessWidget {
//   const LinkedStudentsView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return AppScaffold(
//       appBar: const LinkedStudentsAppBar(),
//       body: RefreshIndicator(
//         onRefresh: () async {
//           final studentsBloc = context.read<StudentsBloc>();

//           studentsBloc.add(const GetLinkedStudentsEvent(refresh: true));

//           await studentsBloc.stream.firstWhere(
//             (state) => state is StudentsLoaded,
//           );

//           final loaded = studentsBloc.state as StudentsLoaded;

//           for (final student in loaded.students) {
//             context.read<InvoiceBloc>().add(
//               GetInvoiceEvent(studentId: student.id, refresh: true),
//             );
//           }
//         },
//         child: BlocBuilder<StudentsBloc, StudentsState>(
//           builder: (context, state) {
//             if (state is StudentsLoading) {
//               return const ShimmerListLoader();
//             }

//             if (state is StudentsLoaded) {
//               if (state.students.isEmpty) {
//                 // Empty state MUST be scrollable
//                 return ListView(
//                   physics: const AlwaysScrollableScrollPhysics(),
//                   children: [
//                     const SizedBox(height: 120),
//                     buildEmptyState(context),
//                   ],
//                 );
//               }

//               return LinkedStudentsBody(students: state.students);
//             }

//             if (state is StudentsError) {
//               return ListView(
//                 physics: const AlwaysScrollableScrollPhysics(),
//                 children: [
//                   const SizedBox(height: 120),
//                   Center(child: Text(state.message)),
//                 ],
//               );
//             }

//             return const SizedBox.shrink();
//           },
//         ),
//       ),
//     );
//   }
// }
