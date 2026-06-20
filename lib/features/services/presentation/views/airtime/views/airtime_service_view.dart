import 'package:blithepay/core/navigation/index.dart';
import 'package:blithepay/features/dashboard/presentation/models/service_model.dart';
import 'package:blithepay/features/services/data/repositories/service_repository.dart';
import 'package:blithepay/features/services/presentation/views/shared/reusable_service_view.dart';
import 'package:blithepay/features/services/presentation/views/shared/service_overlays.dart';
import 'package:blithepay/features/services/presentation/widgets/phone_number_container.dart';
import 'package:flutter/material.dart';

class AirtimeServiceView extends StatelessWidget {
  final ServiceEntity? service;

  const AirtimeServiceView({super.key, this.service});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ServiceBloc(
        serviceRepository: context.read<ServiceRepository>(),
        serviceId: service?.id,
        config: const ServiceConfig(
          title: 'Airtime',
          recipientLabel: 'Phone Number',
          recipientHint: 'Enter phone number',
          providerLabel: 'Select network',
          providerOptions: ['MTN', 'GLO', 'Airtel', '9mobile'],
          plans: [],
          presetAmounts: [300000, 500000, 850000, 1000000, 1500000, 2000000],
          availableBalanceKobo: 9455272,
        ),
      ),
      child: const _AirtimeView(),
    );
  }
}

class _AirtimeView extends StatefulWidget {
  const _AirtimeView();

  @override
  State<_AirtimeView> createState() => _AirtimeViewState();
}

class _AirtimeViewState extends State<_AirtimeView> {
  TextEditingController? _phoneController;
  TextEditingController? _amountController;

  @override
  void initState() {
    super.initState();
    final initialState = context.read<ServiceBloc>().state;
    _phoneController = TextEditingController(text: initialState.phoneNumber);
    _amountController = TextEditingController(
      text: _amountInputText(initialState.amountKobo),
    );
  }

  @override
  void dispose() {
    _phoneController?.dispose();
    _amountController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ServiceView<ServiceBloc, ServiceState>(
      title: 'Airtime',
      formBuilder: (context, state) => AirtimeServiceForm(
        state: state,
        phoneController: _ensurePhoneController(state),
        amountController: _ensureAmountController(state),
      ),
      overlayBuilder: (context, state) => ServiceStageOverlay(state: state),
    );
  }

  String _amountInputText(int amountKobo) {
    final whole = amountKobo ~/ 100;
    final decimal = amountKobo.remainder(100).toString().padLeft(2, '0');
    return '$whole.$decimal';
  }

  TextEditingController _ensurePhoneController(ServiceState state) {
    return _phoneController ??= TextEditingController(text: state.phoneNumber);
  }

  TextEditingController _ensureAmountController(ServiceState state) {
    return _amountController ??= TextEditingController(
      text: _amountInputText(state.amountKobo),
    );
  }
}

class AirtimeServiceForm extends StatefulWidget {
  final ServiceState state;
  final TextEditingController phoneController;
  final TextEditingController amountController;

  const AirtimeServiceForm({
    super.key,
    required this.state,
    required this.phoneController,
    required this.amountController,
  });

  @override
  State<AirtimeServiceForm> createState() => _AirtimeServiceFormState();
}

class _AirtimeServiceFormState extends State<AirtimeServiceForm> {
  @override
  Widget build(BuildContext context) {
    return PhoneNumberContainer(
      state: widget.state,
      phoneController: widget.phoneController,
      amountController: widget.amountController,
    );
  }
}
