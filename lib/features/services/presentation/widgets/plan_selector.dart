// import 'package:flutter/material.dart';
// import 'package:blithepay/core/constants/app_colors.dart';

// class PlanSelector extends StatelessWidget {
//   final int selectedIndex;
//   final List<ServicePlan> plans;
//   final ValueChanged<int> onSelected;

//   const PlanSelector({
//     super.key,
//     required this.selectedIndex,
//     required this.plans,
//     required this.onSelected,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ListView.separated(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: plans.length,
//       separatorBuilder: (_, __) => const SizedBox(height: 12),
//       itemBuilder: (context, index) {
//         final plan = plans[index];
//         final isSelected = index == selectedIndex;

//         return InkWell(
//           onTap: () => onSelected(index),
//           borderRadius: BorderRadius.circular(12),
//           child: Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: isSelected
//                   ? AppColors.primary.withOpacity(0.1)
//                   : AppColors.white,
//               border: Border.all(
//                 color: isSelected ? AppColors.primary : const Color(0xFFE3E7F2),
//                 width: isSelected ? 2 : 1,
//               ),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         plan.title,
//                         style: const TextStyle(
//                           color: Color(0xFF061657),
//                           fontSize: 16,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         plan.description,
//                         style: const TextStyle(
//                           color: Color(0xFF4B4B52),
//                           fontSize: 14,
//                           fontWeight: FontWeight.w400,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Text(
//                   plan.priceLabel,
//                   style: const TextStyle(
//                     color: Color(0xFF061657),
//                     fontSize: 16,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// class ServicePlan {
//   final String title;
//   final String description;
//   final int amountKobo;
//   final String priceLabel;

//   const ServicePlan({
//     required this.title,
//     required this.description,
//     required this.amountKobo,
//     required this.priceLabel,
//   });
// }
