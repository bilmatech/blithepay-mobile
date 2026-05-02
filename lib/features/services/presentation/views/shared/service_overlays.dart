import 'package:blithepay/core/navigation/index.dart';
import 'package:blithepay/features/fees/presentation/views/widgets/pin_bottom_sheet_content.dart';
import 'package:blithepay/features/services/presentation/views/shared/review_panel.dart';
import 'package:blithepay/features/services/presentation/views/shared/success_panel.dart';
import 'package:flutter/material.dart';

import '../../bloc/service_bloc/service_bloc.dart';

class ServiceStageOverlay extends StatefulWidget {
  final ServiceState state;

  const ServiceStageOverlay({super.key, required this.state});

  @override
  State<ServiceStageOverlay> createState() => _ServiceStageOverlayState();
}

class _ServiceStageOverlayState extends State<ServiceStageOverlay> {
  ServiceStage? _lastStage;

  @override
  void didUpdateWidget(covariant ServiceStageOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newStage = widget.state.stage;

    if (newStage != _lastStage) {
      _lastStage = newStage;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleStage(newStage);
      });
    }
  }

  void _handleStage(ServiceStage stage) {
    switch (stage) {
      case ServiceStage.review:
        _showReview();
        break;
      case ServiceStage.pin:
        _showPin();
        break;
      case ServiceStage.success:
        _showSuccess();
        break;
      case ServiceStage.entry:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(); // no UI anymore
  }

  void _showReview() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true, // IMPORTANT (fixes clipping)
      builder: (_) => BlocProvider.value(
        value: context.read<ServiceBloc>(),
        child: ReviewPanel(state: widget.state),
      ),
    );
  }

  void _showPin() async {
    final pin = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (_) {
        return PinBottomSheetContent(
          isLoading: false,
          errorMessage: widget.state.pin,
          onSubmit: (pin) async {
            print('pin submitted: $pin');
            context.read<ServiceBloc>().add(ServicePinDigitPressed(pin));
            // context.read<ServiceBloc>().add(ServicePinSubmitted(pin));
          },
          onForgotPin: () {
            context.push(AppRoutes.setupOtp);
          },
        );
      },
    );
  }

  void _showSuccess() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (_) {
        return BlocProvider.value(
          value: context.read<ServiceBloc>(),
          child: SuccessPanel(
            title: 'Payment Successful',
            description: 'Your transaction was successful.',
            onDownloadReceipt: () {
              Navigator.of(
                context,
                rootNavigator: true,
              ).popUntil((route) => route.isFirst);
              context.read<ServiceBloc>().add(ServiceSuccessDismissed());
            },

            onGoHome: () {
              Navigator.of(
                context,
                rootNavigator: true,
              ).popUntil((route) => route.isFirst);
              context.read<ServiceBloc>().add(ServiceSuccessDismissed());
            },
          ),
        );
      },
    );
  }
}
