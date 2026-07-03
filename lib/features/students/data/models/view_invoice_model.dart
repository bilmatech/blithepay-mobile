import 'package:blithepay/features/students/data/models/verify_student_model.dart';
import 'package:intl/intl.dart';

class ViewInvoiceModel {
  final String id;
  final String invoiceNo;

  final String? schoolName;
  final String? schoolAddress;
  final String? schoolLogo;

  final String? billToName;
  final String? billToAddress;

  final String childName;
  final String? childId;
  final String childRegNo;

  final String? className;
  final String? term;
  final String? session;

  final DateTime? deadline;

  final String? latePaymentFineRaw;
  final double? latePaymentFineValue;

  final DateTime? createdOn;

  final String paymentStatus;
  final String? status;
  final String? paymentLink;

  final List<InvoiceItemModel> items;

  final String? subtotalRaw;
  final String? vatPercent;
  final String? vatRaw;
  final double? vatValue;
  final String? totalRaw;

  final DateTime? paidOn;

  const ViewInvoiceModel({
    required this.id,
    required this.invoiceNo,
    this.schoolName,
    this.schoolAddress,
    this.schoolLogo,
    this.billToName,
    this.billToAddress,
    required this.childName,
    this.childId,
    required this.childRegNo,
    this.className,
    this.term,
    this.session,
    this.deadline,
    this.latePaymentFineRaw,
    this.latePaymentFineValue,
    this.createdOn,
    required this.paymentStatus,
    this.status,
    this.paymentLink,
    required this.items,
    this.subtotalRaw,
    this.vatPercent,
    this.vatRaw,
    this.vatValue,
    this.totalRaw,
    this.paidOn,
  });

  factory ViewInvoiceModel.fromJson(Map<String, dynamic> json) {
    return ViewInvoiceModel(
      id: json['id'] ?? '',
      invoiceNo: json['invoiceNo'] ?? '',

      schoolName: json['schoolName'],
      schoolAddress: json['schoolAddress'],
      schoolLogo: json['schoolLogo'],

      billToName: json['billToName'],
      billToAddress: json['billToAddress'],

      childName: json['childName'] ?? '',
      childId: json['childId'],
      childRegNo: json['childRegNo'],

      className: json['className'],
      term: json['term'],
      session: json['session'],

      deadline: json['deadline'] != null
          ? parseBackendDate(json['deadline'])
          : null,

      latePaymentFineRaw: json['latePaymentFine'],
      latePaymentFineValue: (json['latePaymentFineValue'] as num?)?.toDouble(),

      createdOn: json['createdOn'] != null
          ? parseBackendDate(json['createdOn'])
          : null,

      paymentStatus: json['paymentStatus'] ?? '',
      status: json['status'],
      paymentLink: json['paymentLink'],

      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => InvoiceItemModel.fromJson(e))
          .toList(),

      subtotalRaw: json['subtotal'],
      vatPercent: json['vatPercent'],
      vatRaw: json['vat'],
      vatValue: (json['vatValue'] as num?)?.toDouble(),
      totalRaw: json['total'],

      paidOn: json['paidOn'] != null ? parseBackendDate(json['paidOn']) : null,
    );
  }

  bool get isPaid => paymentStatus.toLowerCase() == 'paid';

  bool get isOverdue {
    if (isPaid || deadline == null) return false;

    final endOfDeadlineDay = DateTime(
      deadline!.year,
      deadline!.month,
      deadline!.day,
      23,
      59,
      59,
    );

    return DateTime.now().isAfter(endOfDeadlineDay);
  }

  double get lateFeeAmount => isOverdue ? parseCurrency(latePaymentFineRaw) : 0;

  double get subtotalAmount => parseCurrency(subtotalRaw);

  double get vatAmount => parseCurrency(vatRaw);

  double get totalAmount => parseCurrency(totalRaw);
}

extension InvoiceStudentCardAdapter on ViewInvoiceModel {
  StudentCardData toStudentCardData() {
    return StudentCardData(
      id: invoiceNo,
      fullName: childName,
      regNumber: childRegNo,
      className: className ?? '',
      schoolName: schoolName ?? '',
      status: _mapStatus(),
    );
  }

  StudentCardStatus _mapStatus() {
    if (isPaid) return StudentCardStatus.paid;

    if (paymentStatus.toLowerCase() == 'unpaid') {
      return isOverdue ? StudentCardStatus.overdue : StudentCardStatus.unpaid;
    }

    return StudentCardStatus.pending;
  }
}

class InvoiceItemModel {
  final String? id;
  final String? name;

  final bool? required;
  final bool? isRequired;

  final int? quantity;

  final String? amountRaw;
  final double? amountValue;

  const InvoiceItemModel({
    this.id,
    this.name,
    this.required,
    this.isRequired,
    this.quantity,
    this.amountRaw,
    this.amountValue,
  });

  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) {
    return InvoiceItemModel(
      id: json['id'],
      name: json['name'],
      required: json['required']?.toString().toLowerCase() == 'yes',
      isRequired: json['isRequired'],
      quantity: json['quantity'],
      amountRaw: json['amount'],
      amountValue: (json['amountValue'] as num?)?.toDouble(),
    );
  }

  double get amount => amountValue ?? parseCurrency(amountRaw);

  String get amountFormatted => amountRaw ?? '';
}

double parseCurrency(String? value) {
  if (value == null) return 0;
  return double.tryParse(value.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
}

DateTime parseBackendDate(String value) {
  final formatter = DateFormat('EEE MMM dd yyyy', 'en_US');
  return formatter.parse(value);
}
