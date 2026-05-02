import 'package:blithepay/shared/widgets/buttons/primary_button.dart';
import 'package:blithepay/shared/widgets/buttons/secondary_outlined_button.dart';
import 'package:flutter/material.dart';

class SuccessPanel extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onDownloadReceipt;
  final VoidCallback onGoHome;

  const SuccessPanel({
    super.key,
    required this.title,
    required this.description,
    required this.onDownloadReceipt,
    required this.onGoHome,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Wrap(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(40, 40, 40, 30),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, size: 80, color: Colors.green),
                const SizedBox(height: 20),

                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 10),

                Text(description),

                const SizedBox(height: 30),

                Row(
                  children: [
                    Expanded(
                      child: SecondaryOutlinedButton(
                        onPressed: onDownloadReceipt,
                        label: 'Download Receipt',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: PrimaryButton(
                        height: 40,
                        onPressed: onGoHome,
                        label: 'Cancel',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// class _SuccessPanel extends StatelessWidget {
//   final ServiceState state;

//   const _SuccessPanel({required this.state});

//   @override
//   Widget build(BuildContext context) {
//     return _BottomPanel(
//       maxHeightFactor: 0.42,
//       child: Padding(
//         padding: const EdgeInsets.fromLTRB(40, 64, 40, 42),
//         child: Column(
//           children: [
//             const Center(
//               child: Icon(Icons.check, color: AppColors.white, size: 45),
//             ),

//             // Container(
//             //   width: 150,
//             //   height: 150,
//             //   decoration: const BoxDecoration(
//             //     color: Color(0xFFEAFBF1),
//             //     shape: BoxShape.circle,
//             //   ),
//             //   child: Center(
//             //     child: Container(
//             //       width: 63,
//             //       height: 63,
//             //       decoration: const BoxDecoration(
//             //         color: AppColors.primary,
//             //         shape: BoxShape.circle,
//             //       ),
//             //       child: const Icon(
//             //         Icons.check,
//             //         color: AppColors.white,
//             //         size: 45,
//             //       ),
//             //     ),
//             //   ),
//             // ),
//             // const SizedBox(height: 22),
//             const Text(
//               'Successful',
//               style: TextStyle(
//                 color: Colors.black,
//                 fontSize: 26,
//                 fontWeight: FontWeight.w800,
//               ),
//             ),
//             const SizedBox(height: 12),
//             Text(
//               '${state.config.title} payment completed',
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 color: Color(0xFF4B4B52),
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             const SizedBox(height: 24),
//             Row(
//               children: [
//                 Expanded(
//                   child: SecondaryOutlinedButton(
//                     onPressed: () {
//                       context.read<ServiceBloc>().add(
//                         ServiceSuccessDismissed(),
//                       );
//                     },
//                     label: 'Download receipt',
//                   ),
//                 ),
//                 Expanded(
//                   child: PrimaryButton(
//                     onPressed: () {
//                       context.read<ServiceBloc>().add(
//                         ServiceSuccessDismissed(),
//                       );
//                     },

//                     label: 'Done',
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
