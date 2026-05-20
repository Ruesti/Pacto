import '../../domain/models/contract_category.dart';
import '../../domain/models/cancellation_method.dart';
import '../../domain/models/billing_cycle.dart';

enum ExtractionConfidence { high, medium, low }

class ExtractionResult {
  final String name;
  final String provider;
  final ContractCategory category;
  final double monthlyCost;
  final BillingCycle billingCycle;
  final String? contactPhone;
  final String? contactEmail;
  final String? contactUrl;
  final String noticePeriod;
  final CancellationMethod cancellationMethod;
  final String cancellationInstructions;
  final DateTime? nextRenewal;
  final String notes;
  final ExtractionConfidence confidence;

  const ExtractionResult({
    required this.name,
    required this.provider,
    required this.category,
    required this.monthlyCost,
    required this.billingCycle,
    this.contactPhone,
    this.contactEmail,
    this.contactUrl,
    required this.noticePeriod,
    required this.cancellationMethod,
    required this.cancellationInstructions,
    this.nextRenewal,
    required this.notes,
    required this.confidence,
  });

  factory ExtractionResult.fromJson(Map<String, dynamic> json) {
    final filled = ['name', 'provider', 'monthlyCost', 'cancellationMethod']
        .where((f) => json[f] != null)
        .length;
    final confidence = switch (filled) {
      4 => ExtractionConfidence.high,
      2 || 3 => ExtractionConfidence.medium,
      _ => ExtractionConfidence.low,
    };

    final rawCost = (json['monthlyCost'] as num?)?.toDouble() ?? 0.0;
    final billingStr = json['billingCycle'] as String? ?? 'monthly';
    final cycle = BillingCycle.values
        .where((e) => e.name == billingStr)
        .firstOrNull ?? BillingCycle.monthly;
    final monthly = cycle == BillingCycle.yearly
        ? rawCost / 12
        : cycle == BillingCycle.quarterly
            ? rawCost / 3
            : rawCost;

    return ExtractionResult(
      name: json['name'] as String? ?? '',
      provider: json['provider'] as String? ?? '',
      category: ContractCategory.values
              .where((e) => e.name == (json['category'] as String?))
              .firstOrNull ??
          ContractCategory.sonstiges,
      monthlyCost: monthly,
      billingCycle: cycle,
      contactPhone: json['contactPhone'] as String?,
      contactEmail: json['contactEmail'] as String?,
      contactUrl: json['contactUrl'] as String?,
      noticePeriod: json['noticePeriod'] as String? ?? '',
      cancellationMethod: CancellationMethod.values
              .where((e) => e.name == (json['cancellationMethod'] as String?))
              .firstOrNull ??
          CancellationMethod.online,
      cancellationInstructions:
          json['cancellationInstructions'] as String? ?? '',
      nextRenewal: json['nextRenewal'] != null
          ? DateTime.tryParse(json['nextRenewal'] as String)
          : null,
      notes: json['notes'] as String? ?? '',
      confidence: confidence,
    );
  }
}
