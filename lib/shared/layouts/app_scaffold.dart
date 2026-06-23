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
  final bool? centerTitle;
  final Widget? background;
  final Widget? bottomNavigationBar;
  final bool useSafeArea;
  final Color? backgroundColor;

  const AppScaffold({
    super.key,
    this.title,
    required this.body,
    this.appBar,
    this.showBackButton = true,
    this.onBackPressed,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.centerTitle,
    this.background,
    this.bottomNavigationBar,
    this.useSafeArea = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final bodyWidget = background != null
        ? Stack(
            children: [
              background!,
              useSafeArea ? SafeArea(child: body) : body,
            ],
          )
        : (useSafeArea ? SafeArea(child: body) : body);

    return Scaffold(
      backgroundColor:
          backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      appBar:
          appBar ??
          (title != null
              ? AppBar(
                  title: Text(title!),
                  centerTitle: centerTitle ?? false,
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
      body: bodyWidget,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
