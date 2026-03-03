import 'package:blithepay/features/students/data/models/verify_student_model.dart';
import 'package:blithepay/features/students/presentation/bloc/students_bloc.dart';
import 'package:blithepay/features/students/presentation/bloc/students_event.dart';
import 'package:blithepay/features/students/presentation/bloc/students_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Widget UnlinkButton(BuildContext context, VerifiedStudentModel student) {
  return BlocBuilder<StudentsBloc, StudentsState>(
    builder: (context, state) {
      if (state is! StudentsLoaded) return const SizedBox.shrink();

      final isLoading = state.loadingStudentIds.contains(student.id);

      return TextButton.icon(
        icon: isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.link_off, color: Colors.red),
        label: Text(
          'Unlink Child',
          style: TextStyle(color: isLoading ? Colors.grey : Colors.red),
        ),
        onPressed: isLoading
            ? null
            : () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    title: const Text('Unlink Student'),
                    content: const Text(
                      'Are you sure you want to unlink this student?',
                      textAlign: TextAlign.center,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Unlink'),
                      ),
                    ],
                  ),
                );

                if (confirmed != true) return;

                context.read<StudentsBloc>().add(
                  UNLinkChildEvent(
                    studentId: student.id,
                    studentCode: student.school.schoolCode,
                  ),
                );
              },
      );
    },
  );
}
