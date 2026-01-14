import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AppScaffold extends StatelessWidget {
  final String? title;
  final Widget body;
  final PreferredSizeWidget? appBar;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  const AppScaffold({
    super.key,
    this.title,
    required this.body,
    this.appBar,
    this.showBackButton = true,
    this.onBackPressed,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar:
          appBar ??
          (title != null
              ? AppBar(
                  title: Text(title!),
                  centerTitle: false,
                  elevation: 0,
                  backgroundColor: AppColors.white,
                  leading: showBackButton
                      ? IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: AppColors.textPrimary,
                          ),
                          onPressed:
                              onBackPressed ?? () => Navigator.pop(context),
                        )
                      : null,
                )
              : null),
      body: body,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}
