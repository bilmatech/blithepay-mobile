import 'package:blithepay/core/navigation/app_routes.dart';
import 'package:blithepay/shared/widgets/buttons/arrow_button_icon.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LinkedStudentsAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const LinkedStudentsAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: BackArrowButtonIcon(
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(AppRoutes.home);
          }
        },
      ),
      title: const Text('Linked Childrens'),
      centerTitle: true,
      actions: [
        GestureDetector(
          onTap: () => context.push(AppRoutes.linkchildSchool),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.school_outlined, size: 22),
                SizedBox(height: 2),
                Text('Add Child', style: TextStyle(fontSize: 10)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
