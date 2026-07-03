import 'package:blithepay/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:blithepay/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:blithepay/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:blithepay/features/wallet/presentation/bloc/wallet_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

int getWalletBalanceKobo(BuildContext context) {
  final walletState = context.read<WalletBloc>().state;
  final dashboardState = context.read<DashboardBloc>().state;

  double? walletBalance;
  if (walletState is WalletLoaded) {
    walletBalance = walletState.wallet.balance.toDouble();
  }

  double? dashboardBalance;
  if (dashboardState is DashboardLoaded) {
    final rawBalance = dashboardState.dashboard.walletBalance;
    final cleanString = rawBalance.replaceAll(RegExp(r'[^\d.]'), '');
    dashboardBalance = double.tryParse(cleanString);
  }

  // If both balances are available, use the larger/fresh non-zero value
  if (walletBalance != null && dashboardBalance != null) {
    final selectedBalance = walletBalance > dashboardBalance ? walletBalance : dashboardBalance;
    return (selectedBalance * 100).round();
  }

  if (walletBalance != null) {
    return (walletBalance * 100).round();
  }

  if (dashboardBalance != null) {
    return (dashboardBalance * 100).round();
  }

  return 9455272; // default fallback mock balance
}
