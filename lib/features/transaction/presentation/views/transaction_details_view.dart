import 'package:pdf/pdf.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blithepay/core/utils/helpers.dart';
import 'package:blithepay/core/constants/app_colors.dart';
import 'package:blithepay/shared/layouts/app_scaffold.dart';
import 'package:blithepay/core/constants/app_text_styles.dart';
import 'package:blithepay/shared/widgets/layouts/spacing.dart';
import 'package:blithepay/shared/widgets/layouts/app_text.dart';
import 'package:blithepay/core/storage/auth_local_storage.dart';
import 'package:blithepay/shared/widgets/buttons/arrow_button_icon.dart';
import 'package:blithepay/shared/widgets/buttons/secondary_outlined_button.dart';
import 'package:blithepay/features/wallet/data/repositories/wallet_repository.dart';
import 'package:blithepay/features/wallet/data/models/wallet_transaction_model.dart';
import 'package:blithepay/shared/widgets/loaders/shimmer_transaction_details_loader.dart';
import 'package:blithepay/features/wallet/data/models/transaction_detail_response_model.dart';

class TransactionDetailView extends StatefulWidget {
  final WalletTransactionModel transaction;

  const TransactionDetailView({super.key, required this.transaction});

  @override
  State<TransactionDetailView> createState() => _TransactionDetailViewState();
}

class _TransactionDetailViewState extends State<TransactionDetailView> {
  bool _isDownloading = false;
  bool _isLoading = false;
  TransactionDetailResponseModel? _detailsData;
  dynamic _error;
  String _loggedInUserName = '';

  @override
  void initState() {
    super.initState();
    _fetchDetails(isRefresh: false);
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    try {
      final session = await context.read<AppLocalDataSource>().getSession();
      if (session?.user != null) {
        final name = '${session!.user!.firstName ?? ''} ${session.user!.lastName ?? ''}'.trim();
        if (name.isNotEmpty && mounted) {
          setState(() {
            _loggedInUserName = name;
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _fetchDetails({required bool isRefresh}) async {
    if (!isRefresh) {
      setState(() {
        _isLoading = true;
        _error = null;
        _detailsData = null;
      });
    }
    try {
      final response = await context.read<WalletRepositoryInterface>().getTransactionDetails(
            widget.transaction.id,
          );
      if (mounted) {
        setState(() {
          _detailsData = response;
          _error = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e;
          _isLoading = false;
        });
        if (isRefresh && _detailsData != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to refresh: ${e.toString()}'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleRefresh() async {
    await _fetchDetails(isRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        leading: const BackArrowButtonIcon(),
        title: const HeadingLg('Transaction'),
        centerTitle: true,
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const ShimmerTransactionDetailsLoader();
    }

    if (_error != null && _detailsData == null) {
      return RefreshIndicator(
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
                const SizedBox(height: 12),
                Text(
                  'Could not load transaction details.',
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  _error.toString(),
                  style: AppTextStyles.caption,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => _fetchDetails(isRefresh: false),
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_detailsData == null) {
      return RefreshIndicator(
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: const Center(
              child: Text(
                'No transaction details found.',
                style: AppTextStyles.bodyMedium,
              ),
            ),
          ),
        ),
      );
    }

    final response = _detailsData!;
    final detail = response.data;
    final tx = detail.details;
    final vas = detail.vas;

    final upperStatus = tx.status.toUpperCase();
    final statusColor = () {
      if (upperStatus == 'SUCCESS' || upperStatus == 'SUCCESSFUL') {
        return Colors.green.shade700;
      } else if (upperStatus == 'FAILED') {
        return Colors.red.shade700;
      } else if (upperStatus == 'REVERSED') {
        return Colors.orange.shade700;
      } else {
        return Colors.amber.shade800;
      }
    }();
    final statusBg = () {
      if (upperStatus == 'SUCCESS' || upperStatus == 'SUCCESSFUL') {
        return Colors.green.shade50;
      } else if (upperStatus == 'FAILED') {
        return Colors.red.shade50;
      } else if (upperStatus == 'REVERSED') {
        return Colors.orange.shade50;
      } else {
        return Colors.amber.shade50;
      }
    }();
    final statusBorder = () {
      if (upperStatus == 'SUCCESS' || upperStatus == 'SUCCESSFUL') {
        return Colors.green.shade200;
      } else if (upperStatus == 'FAILED') {
        return Colors.red.shade200;
      } else if (upperStatus == 'REVERSED') {
        return Colors.orange.shade200;
      } else {
        return Colors.amber.shade200;
      }
    }();
    final statusDotColor = () {
      if (upperStatus == 'SUCCESS' || upperStatus == 'SUCCESSFUL') {
        return AppColors.success;
      } else if (upperStatus == 'FAILED') {
        return AppColors.error;
      } else if (upperStatus == 'REVERSED') {
        return AppColors.warning;
      } else {
        return AppColors.warning;
      }
    }();

    final isCredit = widget.transaction.flow.toLowerCase() == 'inflow';
    final displayAmount =
        (isCredit ? '+' : '-') +
        Helpers.formattedAmount(tx.amount.toString()).replaceAll('₦', 'N');

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HeadingLg('Receipt', color: AppColors.textPrimary),
            const VSpaceBase(),
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: statusBorder,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: statusDotColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: statusDotColor.withValues(alpha: 0.4),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          upperStatus,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    displayAmount,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: statusDotColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),

            // Prepaid Electricity Token Pin if available (TECH VOUCHER DESIGN)
            if (vas?.token != null && vas!.token!.isNotEmpty) ...[
              const SizedBox(height: 28),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    Positioned(
                      right: -15,
                      top: -15,
                      child: Icon(
                        Icons.bolt_rounded,
                        size: 110,
                        color: Colors.amber.withValues(alpha: 0.04),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.bolt_rounded,
                                  color: Colors.amber,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'PREPAID ELECTRICITY TOKEN PIN',
                                style: TextStyle(
                                  color: Colors.amber.shade300,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SelectableText(
                            vas.token!,
                            style: const TextStyle(
                              fontSize: 22,
                              fontFamily: 'Courier',
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.8,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: List.generate(
                              30,
                              (index) => Expanded(
                                child: Container(
                                  color: index.isEven
                                      ? Colors.white.withValues(alpha: 0.15)
                                      : Colors.transparent,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (vas.tokenUnits != null && vas.tokenUnits!.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Units: ${vas.tokenUnits}',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )
                              else
                                const SizedBox.shrink(),
                              InkWell(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(text: vas.token!));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Token PIN copied to clipboard!'),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      backgroundColor: AppColors.primary,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade400,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(
                                        Icons.copy_rounded,
                                        size: 13,
                                        color: Color(0xFF0F172A),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Copy Code',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 28),
            _buildDetailsCard(detail),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: SecondaryOutlinedButton(
                    height: 44,
                    onPressed: _isDownloading ? null : () => _downloadReceipt(context, detail),
                    label: _isDownloading ? 'Preparing...' : 'Download Receipt',
                    leading: _isDownloading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(AppTransactionDetailData detail) {
    final tx = detail.details;
    final vas = detail.vas;

    final Map<String, dynamic> rawMeta = vas?.metadata ?? tx.metadata ?? {};
    final nestedMeta = rawMeta['metaData'] is Map ? rawMeta['metaData'] as Map : null;

    final isFeePayment = tx.type.toLowerCase().contains('fee') ||
        tx.type.toLowerCase().contains('student') ||
        tx.description.toLowerCase().contains('fee') ||
        rawMeta.containsKey('studentName') ||
        rawMeta.containsKey('student') ||
        rawMeta.containsKey('invoiceNo');

    final details = [
      {
        'label': 'Date & Time',
        'value': DateFormat(
          'dd MMM yyyy, hh:mm a',
        ).format(DateTime.tryParse(tx.createdAt)?.toLocal() ?? DateTime.now()),
      },
      {'label': 'Reference', 'value': tx.reference},
      {
        'label': 'Amount',
        'value': Helpers.formattedAmount(tx.amount.toString()).replaceAll('₦', 'N'),
      },
    ];

    if (isFeePayment) {
      final schoolName = rawMeta['schoolName'] ?? nestedMeta?['schoolName'] ?? rawMeta['school'] ?? tx.metadata?['schoolName'];
      if (schoolName != null && schoolName.toString().isNotEmpty) {
        details.add({'label': 'School Name', 'value': schoolName.toString()});
      }
      final studentName = rawMeta['studentName'] ?? nestedMeta?['studentName'] ?? rawMeta['childName'] ?? tx.metadata?['childName'] ?? rawMeta['student'];
      if (studentName != null && studentName.toString().isNotEmpty) {
        details.add({'label': 'Student Name', 'value': studentName.toString()});
      }
      final className = rawMeta['className'] ?? nestedMeta?['className'] ?? rawMeta['class'];
      if (className != null && className.toString().isNotEmpty) {
        details.add({'label': 'Class', 'value': className.toString()});
      }
      final invoiceNo = rawMeta['invoiceNo'] ?? nestedMeta?['invoiceNo'] ?? rawMeta['invoiceNumber'];
      if (invoiceNo != null && invoiceNo.toString().isNotEmpty) {
        details.add({'label': 'Invoice Number', 'value': invoiceNo.toString()});
      }
      final term = rawMeta['term'] ?? nestedMeta?['term'];
      final session = rawMeta['session'] ?? nestedMeta?['session'];
      if (term != null || session != null) {
        details.add({
          'label': 'Term/Session',
          'value': '${term ?? ''} ${session ?? ''}'.trim(),
        });
      }
    }

    if (vas != null) {
      if (vas.phone != null) {
        if (vas.phone!.contactName != null) {
          details.add({'label': 'Contact Name', 'value': vas.phone!.contactName!});
        }
        details.add({'label': 'Phone Number', 'value': vas.phone!.phone});
        details.add({'label': 'Network', 'value': vas.phone!.provider});
      } else if (vas.utility != null) {
        details.add({'label': 'Customer Name', 'value': vas.utility!.customerName});
        if (vas.utility!.customerAddress != null && vas.utility!.customerAddress!.isNotEmpty) {
          details.add({'label': 'Service Address', 'value': vas.utility!.customerAddress!});
        }
        if (_loggedInUserName.isNotEmpty) {
          details.add({'label': 'Bill To', 'value': _loggedInUserName});
        }
        details.add({'label': 'Meter Number', 'value': vas.utility!.meterNumber});
        details.add({'label': 'Distributor', 'value': vas.utility!.providerName});
        details.add({'label': 'Meter Type', 'value': vas.utility!.meterType});
      } else if (vas.cabletv != null) {
        details.add({'label': 'Customer Name', 'value': vas.cabletv!.customerName});
        details.add({'label': 'Smartcard Number', 'value': vas.cabletv!.smartcardNumber});
        if (vas.cabletv!.bundleCode != null) {
          details.add({'label': 'Bundle Package', 'value': vas.cabletv!.bundleCode!});
        }
      } else {
        // Fallback receiver info from metadata
        final receiver = vas.metadata?['receiver'] as Map<String, dynamic>?;
        if (receiver != null) {
          final rName = receiver['name'];
          final rNum = receiver['number'];
          final dist = receiver['distribution'];
          if (rName != null && rName.toString().isNotEmpty) {
            details.add({'label': 'Recipient Name', 'value': rName.toString()});
          }
          if (rNum != null && rNum.toString().isNotEmpty) {
            details.add({'label': 'Account/Number', 'value': rNum.toString()});
          }
          if (dist != null && dist.toString().isNotEmpty) {
            details.add({'label': 'Provider', 'value': dist.toString()});
          }
        }
      }
    }

    final channel = vas?.paymentMethod ?? tx.metadata?['paymentSource'] ?? tx.metadata?['paymentMethod'];
    if (channel != null && channel.toString().isNotEmpty) {
      details.add({'label': 'Paid With', 'value': channel.toString().toUpperCase()});
    }

    if (tx.description.isNotEmpty) {
      details.add({'label': 'Description', 'value': tx.description});
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: List.generate(details.length * 2 - 1, (index) {
          if (index.isOdd) {
            return Divider(
              height: 1,
              color: AppColors.border.withValues(alpha: 0.3),
              indent: 16,
              endIndent: 16,
            );
          }

          final item = details[index ~/ 2];
          final isEvenRow = (index ~/ 2).isEven;

          return Container(
            color: isEvenRow ? AppColors.lightBack.withValues(alpha: 0.02) : Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item['label']!,
                  style: AppTextStyles.bodyRegular.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    item['value']!,
                    textAlign: TextAlign.right,
                    style: AppTextStyles.bodyRegular.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Future<void> _downloadReceipt(BuildContext context, AppTransactionDetailData detail) async {
    setState(() => _isDownloading = true);
    try {
      final pdf = pw.Document();
      final tx = detail.details;
      final vas = detail.vas;

      final session = await context.read<AppLocalDataSource>().getSession();
      final userName = '${session?.user?.firstName ?? ''} ${session?.user?.lastName ?? ''}'.trim();

      // Load App Icon from assets
      final ByteData iconBytes = await rootBundle.load('assets/images/app_icon.png');
      final pw.MemoryImage appIcon = pw.MemoryImage(iconBytes.buffer.asUint8List());

      final upperStatus = tx.status.toUpperCase();
      final statusColor = () {
        if (upperStatus == 'SUCCESS' || upperStatus == 'SUCCESSFUL') {
          return PdfColors.green700;
        } else if (upperStatus == 'FAILED') {
          return PdfColors.red700;
        } else if (upperStatus == 'REVERSED') {
          return PdfColor.fromHex('#C2410C');
        } else {
          return PdfColor.fromHex('#B45309');
        }
      }();
      final parsedDate = DateTime.tryParse(tx.createdAt)?.toLocal() ?? DateTime.now();
      final dateStr = DateFormat('MMM d, yyyy HH:mm:ss').format(parsedDate);
      final cleanAmount = Helpers.formattedAmount(tx.amount.toString()).replaceAll('₦', '').trim();

      // Extract metadata values
      final Map<String, dynamic> rawMeta = vas?.metadata ?? tx.metadata ?? {};
      final nestedMeta = rawMeta['metaData'] is Map ? rawMeta['metaData'] as Map : null;

      final receiverMap = rawMeta['receiver'] is Map ? rawMeta['receiver'] as Map : null;
      final vendTypeUpper = (vas?.utility != null)
          ? 'ELECTRICITY'
          : (vas?.phone != null)
              ? 'AIRTIME'
              : (receiverMap?['vendType']?.toString().toUpperCase() ?? '');
      final distUpper = (vas?.phone?.provider ??
              vas?.utility?.providerName ??
              receiverMap?['distribution']?.toString() ??
              '')
          .toUpperCase();

      final isAirtime = vas?.phone != null || vendTypeUpper == 'AIRTIME';
      final isData = vendTypeUpper == 'DATA' || vendTypeUpper == 'INTERNET';
      final isUtility = vas?.utility != null ||
          rawMeta['disco'] != null ||
          nestedMeta?['disco'] != null ||
          vendTypeUpper == 'ELECTRICITY' ||
          vendTypeUpper == 'PREPAID' ||
          vendTypeUpper == 'POSTPAID';
      final isCable = vas?.cabletv != null ||
          distUpper.contains('DSTV') ||
          distUpper.contains('GOTV') ||
          distUpper.contains('STARTIMES') ||
          distUpper.contains('SHOWMAX') ||
          distUpper.contains('CABLE') ||
          distUpper.contains('TV');

      final isFeePayment = tx.type.toLowerCase().contains('fee') ||
          tx.type.toLowerCase().contains('student') ||
          tx.description.toLowerCase().contains('fee') ||
          rawMeta.containsKey('studentName') ||
          rawMeta.containsKey('student') ||
          rawMeta.containsKey('invoiceNo');

      final List<dynamic> feeItems = rawMeta['items'] is List
          ? rawMeta['items'] as List
          : nestedMeta?['items'] is List
              ? nestedMeta!['items'] as List
              : rawMeta['feeBreakdown'] is List
                  ? rawMeta['feeBreakdown'] as List
                  : nestedMeta?['feeBreakdown'] is List
                      ? nestedMeta!['feeBreakdown'] as List
                      : [];

      final subtotalVal = rawMeta['subtotal'] ?? nestedMeta?['subtotal'];
      final vatVal = rawMeta['vat'] ?? nestedMeta?['vat'];
      final lateFeeVal = rawMeta['lateFee'] ?? nestedMeta?['lateFee'] ?? rawMeta['latePaymentFee'] ?? nestedMeta?['latePaymentFee'];

      final unitsVal =
          rawMeta['units'] ??
          nestedMeta?['units'] ??
          rawMeta['tokenUnits'] ??
          nestedMeta?['tokenUnits'];
      final tokenVal = vas?.token ?? rawMeta['token'] ?? nestedMeta?['token'];
      final String? paymentMethod = vas?.paymentMethod ?? tx.metadata?['paymentSource'] ?? tx.metadata?['paymentMethod']?.toString();

      final addressVal =
          vas?.utility?.customerAddress ??
          rawMeta['address'] ??
          nestedMeta?['address'] ??
          (receiverMap is Map ? receiverMap['address'] : null);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return pw.Stack(
              children: [
                // Watermark
                pw.Opacity(
                   opacity: 0.02,
                  child: pw.Center(
                    child: pw.Image(appIcon, width: 350),
                  ),
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Header Row
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Transaction Receipt',
                          style: pw.TextStyle(
                            fontSize: 22,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.black,
                          ),
                        ),
                        pw.Image(appIcon, width: 100),
                      ],
                    ),
                    pw.SizedBox(height: 12),
                    pw.Divider(color: PdfColors.grey400, thickness: 1),
                    pw.SizedBox(height: 20),

                    // Transaction Status & Amount Box
                    pw.Container(
                      padding: const pw.EdgeInsets.all(16),
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.grey100,
                        borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
                      ),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'Status',
                                style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 10),
                              ),
                              pw.SizedBox(height: 4),
                              pw.Text(
                                upperStatus,
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: statusColor,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            children: [
                              pw.Text(
                                'Amount',
                                style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 10),
                              ),
                              pw.SizedBox(height: 4),
                              pw.Text(
                                'NGN $cleanAmount',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 16,
                                  color: PdfColors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 24),

                    // Section: Transaction Details
                    pw.Text(
                      'Transaction Details',
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 8),

                    _pdfRow(
                      'Transaction Type',
                      isAirtime
                          ? 'Airtime Purchase'
                          : isData
                              ? 'Internet Data'
                              : isUtility
                                  ? 'Utility Payment'
                                  : isCable
                                      ? 'Cable TV Subscription'
                                      : isFeePayment
                                          ? 'School Fees Payment'
                                          : tx.type,
                    ),
                    _pdfRow('Reference', tx.reference),
                    _pdfRow('Date & Time', dateStr),
                    if (paymentMethod != null && paymentMethod.isNotEmpty)
                      _pdfRow('Paid With', paymentMethod.toUpperCase()),

                    // Section: Service Details
                    if (vas != null || receiverMap != null || isFeePayment) ...[
                      pw.SizedBox(height: 16),
                      pw.Text(
                        isFeePayment ? 'Payment Details' : 'Service Details',
                        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 8),

                      if (isAirtime) ...[
                        _pdfRow(
                          'Provider',
                          vas?.phone?.provider ??
                              receiverMap?['distribution']?.toString() ??
                              'Airtime',
                        ),
                        if (vas?.phone?.contactName?.isNotEmpty == true ||
                            receiverMap?['name']?.toString().isNotEmpty == true)
                          _pdfRow(
                              'Recipient Name',
                              vas?.phone?.contactName ??
                                  receiverMap!['name'].toString()),
                        _pdfRow(
                            'Mobile Number',
                            vas?.phone?.phone ??
                                receiverMap?['number']?.toString() ??
                                ''),
                        _pdfRow('Service Type', 'AIRTIME'),
                      ] else if (isData) ...[
                        _pdfRow(
                          'Provider',
                          vas?.phone?.provider ??
                              receiverMap?['distribution']?.toString() ??
                              'Data Bundle',
                        ),
                        if (vas?.phone?.contactName?.isNotEmpty == true ||
                            receiverMap?['name']?.toString().isNotEmpty == true)
                          _pdfRow(
                              'Recipient Name',
                              vas?.phone?.contactName ??
                                  receiverMap!['name'].toString()),
                        _pdfRow(
                            'Mobile Number',
                            vas?.phone?.phone ??
                                receiverMap?['number']?.toString() ??
                                ''),
                        _pdfRow('Service Type', 'DATA BUNDLE'),
                      ] else if (isUtility) ...[
                        _pdfRow(
                          'Provider',
                          rawMeta['disco']?.toString() ??
                              nestedMeta?['disco']?.toString() ??
                              vas?.utility?.providerName ??
                              receiverMap?['distribution']?.toString() ??
                              'Utility Payment',
                        ),
                        if (vas?.utility?.customerName.isNotEmpty == true ||
                            receiverMap?['name']?.toString().isNotEmpty == true)
                          _pdfRow(
                              'Customer Name',
                              vas?.utility?.customerName ??
                                  (receiverMap?['name']?.toString() ?? '')),
                        if (addressVal != null && addressVal.toString().isNotEmpty)
                          _pdfRow('Service Address', addressVal.toString()),
                        if (userName.isNotEmpty) _pdfRow('Bill To', userName),
                        _pdfRow(
                            'Meter Number',
                            vas?.utility?.meterNumber ??
                                receiverMap?['number']?.toString() ??
                                ''),
                        _pdfRow(
                            'Meter Type',
                            vas?.utility?.meterType ??
                                receiverMap?['vendType']?.toString() ??
                                'Prepaid'),
                      ] else if (isCable) ...[
                        _pdfRow(
                          'Provider',
                          receiverMap?['distribution']?.toString() ??
                              'Cable TV',
                        ),
                        if (vas?.cabletv?.customerName.isNotEmpty == true ||
                            receiverMap?['name']?.toString().isNotEmpty == true)
                          _pdfRow(
                              'Customer Name',
                              vas?.cabletv?.customerName ??
                                  (receiverMap?['name']?.toString() ?? '')),
                        _pdfRow(
                            'Smartcard/Account Number',
                            vas?.cabletv?.smartcardNumber ??
                                receiverMap?['number']?.toString() ??
                                ''),
                        if (vas?.cabletv?.bundleCode?.isNotEmpty == true ||
                            receiverMap?['vendType']?.toString().isNotEmpty == true)
                          _pdfRow(
                              'Package',
                              vas?.cabletv?.bundleCode ??
                                  (receiverMap?['vendType']?.toString() ?? '')),
                      ] else if (isFeePayment) ...[
                        if (rawMeta['schoolName'] != null ||
                            nestedMeta?['schoolName'] != null ||
                            rawMeta['school'] != null ||
                            tx.metadata?['schoolName'] != null)
                          _pdfRow(
                            'School Name',
                            (rawMeta['schoolName'] ??
                                    nestedMeta?['schoolName'] ??
                                    rawMeta['school'] ??
                                    tx.metadata?['schoolName'])
                                .toString(),
                          ),
                        if (rawMeta['studentName'] != null ||
                            nestedMeta?['studentName'] != null ||
                            rawMeta['childName'] != null ||
                            tx.metadata?['childName'] != null ||
                            rawMeta['student'] != null)
                          _pdfRow(
                            'Student Name',
                            (rawMeta['studentName'] ??
                                    nestedMeta?['studentName'] ??
                                    rawMeta['childName'] ??
                                    tx.metadata?['childName'] ??
                                    rawMeta['student'])
                                .toString(),
                          ),
                        if (rawMeta['className'] != null ||
                            nestedMeta?['className'] != null ||
                            rawMeta['class'] != null)
                          _pdfRow(
                            'Class',
                            (rawMeta['className'] ??
                                    nestedMeta?['className'] ??
                                    rawMeta['class'])
                                .toString(),
                          ),
                        if (rawMeta['invoiceNo'] != null ||
                            nestedMeta?['invoiceNo'] != null ||
                            rawMeta['invoiceNumber'] != null)
                          _pdfRow(
                            'Invoice Number',
                            (rawMeta['invoiceNo'] ??
                                    nestedMeta?['invoiceNo'] ??
                                    rawMeta['invoiceNumber'])
                                .toString(),
                          ),
                        if (rawMeta['term'] != null ||
                            nestedMeta?['term'] != null ||
                            rawMeta['session'] != null ||
                            nestedMeta?['session'] != null)
                          _pdfRow(
                            'Term/Session',
                            '${rawMeta['term'] ?? nestedMeta?['term'] ?? ''} ${rawMeta['session'] ?? nestedMeta?['session'] ?? ''}'
                                .trim(),
                          ),
                        _pdfRow('Service Type', 'SCHOOL FEES PAYMENT'),
                      ] else ...[
                        // Fallback
                        if (vas?.utility?.providerName != null ||
                            receiverMap?['distribution'] != null)
                          _pdfRow(
                              'Provider',
                              vas?.utility?.providerName ??
                                  (receiverMap?['distribution']?.toString() ?? '')),
                        if (vas?.utility?.customerName != null ||
                            receiverMap?['name'] != null)
                          _pdfRow(
                              'Customer Name',
                              vas?.utility?.customerName ??
                                  (receiverMap?['name']?.toString() ?? '')),
                        _pdfRow(
                            'Recipient Number',
                            vas?.utility?.meterNumber ??
                                receiverMap?['number']?.toString() ??
                                ''),
                        if (receiverMap?['vendType'] != null)
                          _pdfRow('Service Type', receiverMap?['vendType']?.toString() ?? ''),
                      ],
                    ],

                    // Token Pin Box (If available)
                    if (tokenVal != null && tokenVal.toString().isNotEmpty) ...[
                      pw.SizedBox(height: 20),
                      pw.Container(
                        width: double.infinity,
                        padding: const pw.EdgeInsets.all(12),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.grey300),
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            pw.Text(
                              'PREPAID ELECTRICITY TOKEN PIN',
                              style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColor.fromHex('#1E3A8A'),
                              ),
                            ),
                            pw.SizedBox(height: 8),
                            pw.Text(
                              tokenVal.toString(),
                              style: pw.TextStyle(
                                fontSize: 22,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.black,
                                letterSpacing: 1.2,
                              ),
                            ),
                            if (unitsVal != null) ...[
                              pw.SizedBox(height: 6),
                              pw.Text(
                                'Units: ${unitsVal.toString()}',
                                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                              ),
                            ] else if (vas?.tokenUnits != null && vas!.tokenUnits!.isNotEmpty) ...[
                              pw.SizedBox(height: 6),
                              pw.Text(
                                'Units: ${vas.tokenUnits}',
                                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],

                    // Fee Breakdown table for fee payment (If available)
                    if (isFeePayment && feeItems.isNotEmpty) ...[
                      pw.SizedBox(height: 20),
                      pw.Text(
                        'Fee Breakdown',
                        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Container(
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.grey300),
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                        ),
                        child: pw.Column(
                          children: [
                            ...feeItems.map((item) {
                              final itemName = item['name']?.toString() ?? 'Fee Item';
                              final itemAmount = item['amount']?.toString() ?? '0';
                              final formattedItemAmount = itemAmount.startsWith('₦') || itemAmount.startsWith('N')
                                  ? itemAmount
                                  : Helpers.formattedAmount(itemAmount);
                              return pw.Container(
                                padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                child: pw.Row(
                                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    pw.Text(itemName, style: const pw.TextStyle(fontSize: 9)),
                                    pw.Text(formattedItemAmount, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],

                    if (isFeePayment && (subtotalVal != null || vatVal != null || lateFeeVal != null)) ...[
                      pw.SizedBox(height: 12),
                      if (subtotalVal != null)
                        _pdfRow('Subtotal', subtotalVal.toString()),
                      if (vatVal != null)
                        _pdfRow('VAT', vatVal.toString()),
                      if (lateFeeVal != null)
                        _pdfRow('Late Payment Fee', lateFeeVal.toString()),
                    ],

                    pw.Spacer(),
                    pw.Divider(color: PdfColors.grey300, thickness: 0.5),
                    pw.SizedBox(height: 10),
                    pw.Center(
                      child: pw.Text(
                        'Thank you for choosing BlithePay | © ${DateTime.now().year} BlithePay. All rights reserved.',
                        style: pw.TextStyle(
                          fontSize: 8,
                          color: PdfColors.grey600,
                          fontStyle: pw.FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );

      final Uint8List pdfBytes = await pdf.save();
      final filename = 'blithepay_receipt_${tx.reference}.pdf';
      await Printing.sharePdf(bytes: pdfBytes, filename: filename);
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  pw.Widget _pdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 10)),
          pw.SizedBox(width: 24),
          pw.Expanded(
            child: pw.Text(
              value,
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                color: PdfColors.black,
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
