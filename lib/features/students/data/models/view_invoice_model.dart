import 'package:blithepay/features/students/data/models/verify_student_model.dart';
import 'package:intl/intl.dart';

class ViewInvoiceModel {
  final String invoiceNo;
  final String schoolName;
  final String schoolAddress;
  final String schoolLogo;

  final String billToName;
  final String billToAddress;

  final String childName;
  final String className;
  final String term;
  final String session;

  final DateTime deadline;
  final String latePaymentFineRaw;
  final DateTime createdOn;

  final String paymentStatus;
  final String paymentLink;

  final List<InvoiceItemModel> items;

  final String subtotalRaw;
  final String vatPercent;
  final String vatRaw;
  final String totalRaw;

  final DateTime? paidOn;

  const ViewInvoiceModel({
    required this.invoiceNo,
    required this.schoolName,
    required this.schoolAddress,
    required this.schoolLogo,
    required this.billToName,
    required this.billToAddress,
    required this.childName,
    required this.className,
    required this.term,
    required this.session,
    required this.deadline,
    required this.latePaymentFineRaw,
    required this.createdOn,
    required this.paymentStatus,
    required this.paymentLink,
    required this.items,
    required this.subtotalRaw,
    required this.vatPercent,
    required this.vatRaw,
    required this.totalRaw,
    this.paidOn,
  });

  factory ViewInvoiceModel.fromJson(Map<String, dynamic> json) {
    return ViewInvoiceModel(
      invoiceNo: json['invoiceNo'] as String,
      schoolName: json['schoolName'] as String,
      schoolAddress: json['schoolAddress'] as String,
      schoolLogo: json['schoolLogo'] as String,

      billToName: json['billToName'] as String,
      billToAddress: json['billToAddress'] as String,

      childName: json['childName'] as String,
      className: json['className'] as String,
      term: json['term'] as String,
      session: json['session'] as String,

      deadline: parseBackendDate(json['deadline']),
      createdOn: parseBackendDate(json['createdOn']),
      latePaymentFineRaw: json['latePaymentFine'] as String,

      paymentStatus: json['paymentStatus'] as String,
      paymentLink: json['paymentLink'] as String,

      items: (json['items'] as List<dynamic>)
          .map((e) => InvoiceItemModel.fromJson(e))
          .toList(),

      subtotalRaw: json['subtotal'] as String,
      vatPercent: json['vatPercent'] as String,
      vatRaw: json['vat'] as String,
      totalRaw: json['total'] as String,

      paidOn: json['paidOn'] != null ? DateTime.parse(json['paidOn']) : null,
    );
  }

  /// Business helpers (VERY useful)

  bool get isPaid => paymentStatus.toLowerCase() == 'paid';

  bool get isOverdue {
    if (isPaid) return false; // paid invoices are never overdue

    final endOfDeadlineDay = DateTime(
      deadline.year,
      deadline.month,
      deadline.day,
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
      regNumber: invoiceNo,
      className: className,
      schoolName: schoolName,
      status: _mapStatus(),
    );
  }

  StudentCardStatus _mapStatus() {
    if (isPaid) return StudentCardStatus.paid;

    if (paymentStatus.toLowerCase() == 'unpaid') {
      return isOverdue ? StudentCardStatus.overdue : StudentCardStatus.unpaid;
    }

    // default for anything else
    return StudentCardStatus.pending;
  }
}

class InvoiceItemModel {
  final String name;
  final bool required;
  final int quantity;
  final String amountRaw;

  const InvoiceItemModel({
    required this.name,
    required this.required,
    required this.quantity,
    required this.amountRaw,
  });

  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) {
    return InvoiceItemModel(
      name: json['name'] as String,
      required: (json['required'] as String).toLowerCase() == 'yes',
      quantity: json['quantity'] as int,
      amountRaw: json['amount'] as String,
    );
  }

  double get amount => parseCurrency(amountRaw);
  String get amountFormatted => amountRaw;
}

double parseCurrency(String value) {
  return double.tryParse(value.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
}

DateTime parseBackendDate(String value) {
  // Example: "Tue Apr 28 2026"
  final formatter = DateFormat('EEE MMM dd yyyy', 'en_US');
  return formatter.parse(value);
}
