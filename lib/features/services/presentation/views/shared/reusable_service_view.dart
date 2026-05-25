import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:blithepay/shared/widgets/buttons/arrow_button_icon.dart';
import 'package:blithepay/shared/widgets/layouts/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ServiceView<TBloc extends BlocBase<TState>, TState>
    extends StatelessWidget {
  final String title;

  final Widget Function(BuildContext, TState) formBuilder;
  final Widget Function(BuildContext, TState) overlayBuilder;

  const ServiceView({
    super.key,
    required this.title,
    required this.formBuilder,
    required this.overlayBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showBackButton: true,
      appBar: AppBar(
        leading: const BackArrowButtonIcon(),
        title: const BodySm('Services'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: BlocBuilder<TBloc, TState>(
          builder: (context, state) {
            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 22, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.h4.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 24),
                      formBuilder(context, state),
                    ],
                  ),
                ),
                overlayBuilder(context, state),
              ],
            );
          },
        ),
      ),
    );
  }
}
