import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../shared/layouts/app_scaffold.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';

class ChangePinView extends StatefulWidget {
  final String email;

  const ChangePinView({super.key, required this.email});

  @override
  State<ChangePinView> createState() => _ChangePinViewState();
}

class _ChangePinViewState extends State<ChangePinView> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.pinResetInitiated) {
          context.push(
            AppRoutes.verifyOtp,
            extra: {'email': widget.email, 'flow': OtpFlow.pinReset, 'fromProfile': true},
          );
        } else if (state.status == AuthStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Unable to reset PIN'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: AppScaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Change Transaction PIN'),
          centerTitle: true,
        ),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final isLoading = state.status == AuthStatus.loading;

            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  const Text(
                    'We’ll send a 6-digit verification code to your email before you set a new PIN.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 32),
                  PrimaryButton(
                    label: 'Send verification code',
                    onPressed: isLoading
                        ? () {}
                        : () {
                            context.read<AuthBloc>().add(
                              InitiatePinResetRequested(email: widget.email),
                            );
                          },
                    isLoading: isLoading,
                    isEnabled: !isLoading,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
