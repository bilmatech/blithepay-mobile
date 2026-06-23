import 'package:blithepay/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:blithepay/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:blithepay/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:blithepay/features/wallet/presentation/bloc/wallet_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

int getWalletBalanceKobo(BuildContext context) {
  final walletState = context.read<WalletBloc>().state;
  if (walletState is WalletLoaded) {
    return (walletState.wallet.balance * 100).round();
  }

  final dashboardState = context.read<DashboardBloc>().state;
  if (dashboardState is DashboardLoaded) {
    final rawBalance = dashboardState.dashboard.walletBalance;
    final cleanString = rawBalance.replaceAll(RegExp(r'[^\d.]'), '');
    final doubleValue = double.tryParse(cleanString);
    if (doubleValue != null) {
      return (doubleValue * 100).round();
    }
  }

  return 9455272; // default fallback mock balance
}
