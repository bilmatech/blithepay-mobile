import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/features/dashboard/presentation/widgets/recent_transactions.dart';
import 'package:blithepay/features/students/presentation/bloc/students_bloc.dart';
import 'package:blithepay/features/students/presentation/bloc/students_state.dart';
import 'package:blithepay/features/wallet/data/models/wallet_transaction_model.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:blithepay/shared/widgets/buttons/app_outlined_icon_button.dart';
import 'package:blithepay/shared/widgets/inputs/dropdown_field.dart';
import 'package:blithepay/shared/widgets/loaders/shimmer_table_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class FeesTransactionsView extends StatefulWidget {
  const FeesTransactionsView({super.key});

  @override
  State<FeesTransactionsView> createState() => _FeeTransactionsViewState();
}

class _FeeTransactionsViewState extends State<FeesTransactionsView> {
  // String _searchQuery = '';
  String? currentFilter;
  String? currentSort;

  @override
  void initState() {
    super.initState();
    //context.read<WalletBloc>().add(const GetTransactionsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        title: const Text(' Fees Transactions'),
        centerTitle: true,
      ),
      body: BlocBuilder<StudentsBloc, StudentsState>(
        builder: (context, state) {
          if (state is StudentsLoading) {
            return const ShimmerTableLoader();
          } else if (state is StudentsLoaded) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: transactions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  return TransactionContainer(transaction: transaction);
                },
              ),
            );
          } else if (state is StudentsError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: transactions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return TransactionContainer(transaction: transaction);
              },
            ),
          );
          // return const SizedBox.shrink();
        },
      ),
    );
  }
}

final transactions = [
  WalletTransactionModel(
    amount: '300',
    status: 'success',
    id: 'cmlqkb0qr003e0vpczzqhii7l',
    name: 'Tuition fee',
    walletId: 'cmljgzu8w00070vp3yy5udkc8',
    fees: '10',
    netAmount: '190',
    reference: '1771330263964dmgr24pmlqkayzg',
    type: 'Deposit',
    flow: '',
    transactionAt: '2026-02-17T12:11:06.242Z',
    processedAt: '2026-02-17T12:11:07.027Z',
    isDeleted: false,
    createdAt: '2026-02-17T12:11:07.028Z',
    updatedAt: '2026-02-17T12:11:06.243Z',
  ),
  WalletTransactionModel(
    amount: '200',
    status: 'success',
    id: 'cmlqkb0qr003e0vpczzqhii7l',
    name: 'Tuition fee',
    walletId: 'cmljgzu8w00070vp3yy5udkc8',
    fees: '10',
    netAmount: '190',
    reference: '1771330263964dmgr24pmlqkayzg',
    type: 'Deposit',
    flow: '',
    transactionAt: '2026-02-17T12:11:06.242Z',
    processedAt: '2026-02-17T12:11:07.027Z',
    isDeleted: false,
    createdAt: '2026-02-17T12:11:07.028Z',
    updatedAt: '2026-02-17T12:11:06.243Z',
  ),
];
