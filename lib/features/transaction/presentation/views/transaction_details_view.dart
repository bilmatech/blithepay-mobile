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
import 'package:blithepay/shared/widgets/buttons/arrow_button_icon.dart';
import 'package:blithepay/shared/widgets/buttons/secondary_outlined_button.dart';
import 'package:blithepay/features/wallet/data/repositories/wallet_repository.dart';
import 'package:blithepay/features/wallet/data/models/wallet_transaction_model.dart';
import 'package:blithepay/core/storage/auth_local_storage.dart';
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
  Future<TransactionDetailResponseModel>? _detailsFuture;
  String _loggedInUserName = '';

  @override
  void initState() {
    super.initState();
    _detailsFuture = context.read<WalletRepositoryInterface>().getTransactionDetails(
      widget.transaction.id,
    );
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

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        leading: const BackArrowButtonIcon(),
        title: const HeadingLg('Transaction'),
        centerTitle: true,
      ),
      body: FutureBuilder<TransactionDetailResponseModel>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ShimmerTransactionDetailsLoader();
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                      snapshot.error.toString(),
                      style: AppTextStyles.caption,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _detailsFuture = context
                              .read<WalletRepositoryInterface>()
                              .getTransactionDetails(widget.transaction.id);
                        });
                      },
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
            );
          }

          final response = snapshot.data!;
          final detail = response.data;
          final tx = detail.details;
          final vas = detail.vas;

          final isSuccess =
              tx.status.toLowerCase() == 'success' || tx.status.toLowerCase() == 'successful';

          final isCredit = widget.transaction.flow.toLowerCase() == 'inflow';
          final displayAmount =
              (isCredit ? '+' : '-') +
              Helpers.formattedAmount(tx.amount.toString()).replaceAll('₦', 'N');

          return SingleChildScrollView(
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
                          color: isSuccess ? Colors.green.shade50 : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSuccess ? Colors.green.shade200 : Colors.red.shade200,
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
                                color: isSuccess ? AppColors.success : AppColors.error,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: (isSuccess ? AppColors.success : AppColors.error)
                                        .withValues(alpha: 0.4),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isSuccess ? 'Successful' : 'Failed',
                              style: TextStyle(
                                color: isSuccess ? Colors.green.shade800 : Colors.red.shade800,
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
                          color: isSuccess ? AppColors.success : AppColors.error,
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
          );
        },
      ),
    );
  }

  Widget _buildDetailsCard(AppTransactionDetailData detail) {
    final tx = detail.details;
    final vas = detail.vas;

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
          details.add({'label': 'Till To', 'value': _loggedInUserName});
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

      final isSuccess = tx.status.toLowerCase() == 'success' || tx.status.toLowerCase() == 'successful';
      final parsedDate = DateTime.tryParse(tx.createdAt)?.toLocal() ?? DateTime.now();
      final dateStr = DateFormat('MMM d, yyyy HH:mm:ss').format(parsedDate);
      final displayAmount = Helpers.formattedAmount(tx.amount.toString()).replaceAll('₦', 'N');

      // Extract metadata values
      final Map<String, dynamic> rawMeta = vas?.metadata ?? {};
      final nestedMeta = rawMeta['metaData'] is Map ? rawMeta['metaData'] as Map : null;

      final unitsVal = rawMeta['units'] ?? nestedMeta?['units'] ?? rawMeta['tokenUnits'] ?? nestedMeta?['tokenUnits'];
      final debtVal = rawMeta['debt'] ?? nestedMeta?['debt'] ?? rawMeta['debtAmount'] ?? nestedMeta?['debtAmount'];
      final tokenVal = vas?.token ?? rawMeta['token'] ?? nestedMeta?['token'];
      final unitsAmountVal = rawMeta['unitsAmount'] ?? nestedMeta?['unitsAmount'];
      
      final addressVal = vas?.utility?.customerAddress ??
          rawMeta['address'] ??
          nestedMeta?['address'] ??
          (rawMeta['receiver'] is Map ? rawMeta['receiver']['address'] : null);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _pdfTicketPerforation(),
                pw.SizedBox(height: 12),

                // Header Row
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Image(appIcon, width: 100),
                    pw.Text(
                      'Transaction Receipt',
                      style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey600),
                    ),
                  ],
                ),

                pw.SizedBox(height: 24),

                // Centered Amount & Status
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text(
                        displayAmount,
                        style: pw.TextStyle(
                          color: isSuccess ? PdfColor.fromHex('#10B981') : PdfColors.red700,
                          fontSize: 32,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: pw.BoxDecoration(
                          color: isSuccess ? PdfColor.fromHex('#EAF2FF') : PdfColors.red50,
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
                          border: pw.Border.all(
                            color: isSuccess ? PdfColor.fromHex('#1E3A8A') : PdfColors.red200,
                            width: 0.5,
                          ),
                        ),
                        child: pw.Text(
                          isSuccess ? 'SUCCESSFUL' : 'FAILED',
                          style: pw.TextStyle(
                            color: isSuccess ? PdfColor.fromHex('#1E3A8A') : PdfColors.red700,
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text(
                        dateStr,
                        style: const pw.TextStyle(
                          fontSize: 9,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 24),
                pw.Divider(color: PdfColors.grey300, thickness: 0.5),
                pw.SizedBox(height: 12),

                // Dynamic Rows
                if (vas != null) ...[
                  if (vas.phone != null) ...[
                    _pdfRow('Provider', vas.phone!.provider),
                    if (vas.phone!.contactName != null && vas.phone!.contactName!.isNotEmpty)
                      _pdfRow('Customer Name', vas.phone!.contactName!),
                    _pdfRow('Recipient Number', vas.phone!.phone),
                  ] else if (vas.utility != null) ...[
                    _pdfRow('Provider', vas.utility!.providerName),
                    _pdfRow('Customer Name', vas.utility!.customerName),
                    if (addressVal != null && addressVal.toString().isNotEmpty)
                      _pdfRow('Service Address', addressVal.toString()),
                    if (userName.isNotEmpty)
                      _pdfRow('Till To', userName),
                    _pdfRow('Purchase Type', vas.utility!.meterType),
                    _pdfRow('Meter Number', vas.utility!.meterNumber),
                    if (unitsVal != null)
                      _pdfRow('Units Purchased', '${unitsVal.toString()} kWh')
                    else if (vas.tokenUnits != null && vas.tokenUnits!.isNotEmpty)
                      _pdfRow('Units Purchased', '${vas.tokenUnits} kWh'),
                    if (tokenVal != null && tokenVal.toString().isNotEmpty)
                      _pdfRow('Token', tokenVal.toString()),
                    if (unitsAmountVal != null)
                      _pdfRow('Units Amount', Helpers.formattedAmount(unitsAmountVal.toString()).replaceAll('₦', 'N'))
                    else
                      _pdfRow('Units Amount', Helpers.formattedAmount((tx.amount).toString()).replaceAll('₦', 'N')),
                    if (debtVal != null && double.tryParse(debtVal.toString()) != null && double.parse(debtVal.toString()) > 0)
                      _pdfRow('Debt Amount', Helpers.formattedAmount(debtVal.toString()).replaceAll('₦', 'N')),
                  ] else if (vas.cabletv != null) ...[
                    _pdfRow('Provider', rawMeta['receiver']?['distribution']?.toString() ?? 'Cable TV'),
                    _pdfRow('Customer Name', vas.cabletv!.customerName),
                    _pdfRow('Smartcard/Account Number', vas.cabletv!.smartcardNumber),
                    if (vas.cabletv!.bundleCode != null)
                      _pdfRow('Bundle Package', vas.cabletv!.bundleCode!),
                  ] else ...[
                    // Fallback generic metadata if vas has receiver info but none of the models matched
                    if (rawMeta['receiver'] != null) ...[
                      if (rawMeta['receiver']['distribution'] != null)
                        _pdfRow('Provider', rawMeta['receiver']['distribution'].toString()),
                      if (rawMeta['receiver']['name'] != null && rawMeta['receiver']['name'].toString().isNotEmpty)
                        _pdfRow('Customer Name', rawMeta['receiver']['name'].toString()),
                      if (addressVal != null && addressVal.toString().isNotEmpty)
                        _pdfRow('Service Address', addressVal.toString()),
                      if (userName.isNotEmpty && (rawMeta['disco'] != null || rawMeta['receiver']['vendType'] != null))
                        _pdfRow('Till To', userName),
                      if (rawMeta['receiver']['number'] != null)
                        _pdfRow('Recipient Number', rawMeta['receiver']['number'].toString()),
                      if (tokenVal != null && tokenVal.toString().isNotEmpty)
                        _pdfRow('Token', tokenVal.toString()),
                    ],
                  ],
                ] else ...[
                  // Normal wallet transfer
                  _pdfRow('Transaction Type', tx.type),
                  if (tx.description.isNotEmpty)
                    _pdfRow('Description', tx.description),
                ],

                _pdfRow('Hotline Number', '+234 901 740 2116'),
                _pdfRow('Transaction No.', tx.reference),

                pw.SizedBox(height: 24),
                pw.Divider(color: PdfColors.grey300, thickness: 0.5),
                pw.SizedBox(height: 12),

                pw.Center(
                  child: pw.Text(
                    'Enjoy a better life with BlithePay. Get free transfers, withdrawals, bill payments, instant loans, and good annual interest on your savings. BlithePay is licensed by the Central Bank of Nigeria and insured by the NDIC.',
                    textAlign: pw.TextAlign.center,
                    style: const pw.TextStyle(
                      fontSize: 8,
                      color: PdfColors.grey500,
                    ),
                  ),
                ),

                pw.SizedBox(height: 20),
                _pdfTicketPerforation(),
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

  pw.Widget _pdfTicketPerforation() {
    return pw.Container(
      alignment: pw.Alignment.center,
      child: pw.Text(
        '•  •  •  •  •  •  •  •  •  •  •  •  •  •  •  •  •  •  •  •  •  •  •  •  •  •  •  •  •  •  •  •  •  •  •  •  •  •',
        style: pw.TextStyle(
          color: PdfColors.grey300,
          fontSize: 10,
          letterSpacing: 2,
        ),
      ),
    );
  }

  pw.Widget _pdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 11),
          ),
          pw.SizedBox(width: 24),
          pw.Expanded(
            child: pw.Text(
              value,
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                color: PdfColors.black,
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
