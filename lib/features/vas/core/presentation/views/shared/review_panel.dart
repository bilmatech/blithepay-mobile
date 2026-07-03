import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/navigation/index.dart';
import 'package:blithepay/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:blithepay/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:blithepay/features/vas/core/presentation/bloc/service_bloc/service_bloc.dart';
import 'package:blithepay/features/vas/core/presentation/views/shared/bottom_panel.dart';
import 'package:blithepay/features/vas/core/presentation/views/shared/success_panel.dart';
import 'package:blithepay/shared/widgets/buttons/primary_button.dart';
import 'package:flutter/material.dart';

class ReviewPanel extends StatelessWidget {
  final ServiceState state;

  const ReviewPanel({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return BottomPanel(
      maxHeightFactor: 0.76,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 16, 28, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PanelBackButton(
              onTap: () {
                context.read<ServiceBloc>().add(ServiceReviewClosed());
              },
            ),

            const SizedBox(height: 14),
            Center(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: '₦${state.amountWhole}'),
                    TextSpan(
                      text: '.${state.amountDecimal}',
                      style: const TextStyle(
                        color: Color(0xFF687298),
                        fontSize: 28,
                      ),
                    ),
                  ],
                ),
                style: const TextStyle(
                  color: Color(0xFF061657),
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 28),
            ReviewRow(label: 'Product', value: state.config.title),
            const SizedBox(height: 20),
            ReviewRow(
              label: 'Recipient',
              value: state.recipient.isEmpty ? 'N/A' : state.recipient,
            ),
            const SizedBox(height: 20),
            ReviewRow(label: 'Provider', value: state.selectedProvider),
            const SizedBox(height: 20),
            ReviewRow(label: 'Amount', value: state.formattedAmount),
            const SizedBox(height: 36),
            const Text(
              'Payment Method',
              style: TextStyle(
                color: Color(0xFF061657),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            BalancePaymentCard(state: state),
            const SizedBox(height: 34),
            PrimaryButton(
              onPressed: () {
                context.read<ServiceBloc>().add(ServicePinRequested());
              },
              label: 'Pay',
            ),
          ],
        ),
      ),
    );
  }
}

class ReviewRow extends StatelessWidget {
  final String label;
  final String value;

  const ReviewRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF4B4B52),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF061657),
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class BalancePaymentCard extends StatelessWidget {
  final ServiceState state;

  const BalancePaymentCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final dashboardState = context.read<DashboardBloc>().state;

    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9ECF6)),
      ),
      child: Row(
        children: [
          Container(
            width: 5,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.horizontal(left: Radius.circular(16)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dashboardState is DashboardLoaded
                        ? 'Available balance'
                        : 'Loading balance...',

                    style: const TextStyle(
                      color: Color(0xFF55555D),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 8),

                  const Spacer(),
                  const Divider(color: Color(0xFFE4E7F1), height: 1),
                  const SizedBox(height: 14),
                  Text(
                    dashboardState is DashboardLoaded
                        ? dashboardState.dashboard.walletBalance
                        : '',
                    style: const TextStyle(
                      color: Color(0xFF061657),
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SuccessPPanel extends StatelessWidget {
  final ServiceState state;

  const SuccessPPanel({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return BottomPanel(
      maxHeightFactor: 0.42,
      child: SuccessPanel(
        title: 'Payment Successful',
        description: '${state.config.title} payment completed',
        onDownloadReceipt: () async {
          context.read<ServiceBloc>().add(ServiceSuccessDismissed());
        },
        onGoHome: () {
          context.read<ServiceBloc>().add(ServiceSuccessDismissed());
        },
      ),

      //  Padding(
      //   padding: const EdgeInsets.fromLTRB(40, 64, 40, 42),
      //   child: Column(
      //     children: [
      //       const Center(
      //         child: Icon(Icons.check, color: AppColors.white, size: 45),
      //       ),

      //       // Container(
      //       //   width: 150,
      //       //   height: 150,
      //       //   decoration: const BoxDecoration(
      //       //     color: Color(0xFFEAFBF1),
      //       //     shape: BoxShape.circle,
      //       //   ),
      //       //   child: Center(
      //       //     child: Container(
      //       //       width: 63,
      //       //       height: 63,
      //       //       decoration: const BoxDecoration(
      //       //         color: AppColors.primary,
      //       //         shape: BoxShape.circle,
      //       //       ),
      //       //       child: const Icon(
      //       //         Icons.check,
      //       //         color: AppColors.white,
      //       //         size: 45,
      //       //       ),
      //       //     ),
      //       //   ),
      //       // ),
      //       // const SizedBox(height: 22),
      //       const Text(
      //         'Successful',
      //         style: TextStyle(
      //           color: Colors.black,
      //           fontSize: 26,
      //           fontWeight: FontWeight.w800,
      //         ),
      //       ),
      //       const SizedBox(height: 12),
      //       Text(
      //         '${state.config.title} payment completed',
      //         textAlign: TextAlign.center,
      //         style: const TextStyle(
      //           color: Color(0xFF4B4B52),
      //           fontSize: 16,
      //           fontWeight: FontWeight.w500,
      //         ),
      //       ),
      //       const SizedBox(height: 24),
      //       Row(
      //         children: [
      //           Expanded(
      //             child: SecondaryOutlinedButton(
      //               onPressed: () {
      //                 context.read<ServiceBloc>().add(
      //                   ServiceSuccessDismissed(),
      //                 );
      //               },
      //               label: 'Download receipt',
      //             ),
      //           ),
      //           Expanded(
      //             child: PrimaryButton(
      //               onPressed: () {
      //                 context.read<ServiceBloc>().add(
      //                   ServiceSuccessDismissed(),
      //                 );
      //               },

      //               label: 'Done',
      //             ),
      //           ),
      //         ],
      //       ),
      //     ],
      //   ),
      // ),
    );
  }
}

class PanelBackButton extends StatelessWidget {
  final VoidCallback onTap;

  const PanelBackButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onTap,
      child: Ink(
        width: 56,
        height: 56,
        decoration: const BoxDecoration(
          color: Color(0xFFF0F1F3),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
      ),
    );
  }
}
