import 'package:blithepay/features/vas/core/presentation/bloc/service_bloc/service_bloc.dart';

class ServiceModel {
  final String id;
  final String name;
  final String slug;

  ServiceModel({required this.id, required this.name, required this.slug});

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
    );
  }
}

class ServiceProviderModel {
  final String id;
  final String name;
  final String? slug;
  final String? logo;

  ServiceProviderModel({
    required this.id,
    required this.name,
    this.slug,
    this.logo,
  });

  factory ServiceProviderModel.fromJson(Map<String, dynamic> json) {
    return ServiceProviderModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString(),
      logo: json['logo']?.toString(),
    );
  }
}

class ServiceProductModel {
  final String name;
  final double amount;
  final String duration;
  final String bundleCode;
  final bool isAmountFixed;
  final String? formattedAmount;
  final String validity;

  ServiceProductModel({
    required this.name,
    required this.amount,
    required this.duration,
    required this.bundleCode,
    required this.isAmountFixed,
    required this.formattedAmount,
    required this.validity,
  });

  factory ServiceProductModel.fromJson(Map<String, dynamic> json) {
    final amountRaw = json['amount'];
    double amount = 0;
    if (amountRaw is num) {
      amount = amountRaw.toDouble();
    } else if (amountRaw is String) {
      amount = double.tryParse(amountRaw) ?? 0;
    }

    return ServiceProductModel(
      name: json['name']?.toString() ?? '',
      amount: amount,
      duration: json['duration']?.toString() ?? '',
      bundleCode: json['bundleCode']?.toString() ?? '',
      isAmountFixed: json['isAmountFixed'] == true,
      formattedAmount: json['formattedAmont']?.toString(),
      validity: json['validity']?.toString() ?? '',
    );
  }

  int get amountKobo => (amount * 100).round();

  // Maps backend strings like "1 Day", "30 Days", "monthly" to your UI Categories
  ServicePlanCategory get category {
    // Standardize the string to lowercase and remove white spaces
    final text = duration.toLowerCase().trim();

    switch (text) {
      case 'daily':
      case 'day':
        return ServicePlanCategory.daily;
      case 'weekly':
      case 'week':
        return ServicePlanCategory.weekly;
      case 'monthly':
      case 'month':
        return ServicePlanCategory.monthly;
      case 'yearly':
      case 'year':
        return ServicePlanCategory.yearly;
      case 'unlimited':
        return ServicePlanCategory.unlimited;
      default:
        // Fallback option if duration is empty or something weird like "2-Day"
        // using the validity property fallback string matching logic
        final valText = validity.toLowerCase();
        if (valText.contains('day')) {
          if (valText.contains('7')) return ServicePlanCategory.weekly;
          if (valText.contains('30')) return ServicePlanCategory.monthly;
          return ServicePlanCategory.daily;
        }
        return ServicePlanCategory.monthly; // Final fallback safe state
    }
  }

  // Handy getter to format pricing consistently
  String get priceLabel => formattedAmount ?? '₦${amount.toStringAsFixed(0)}';
}
