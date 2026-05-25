import '../../domain/models/billing_cycle.dart';
import '../../domain/models/cancellation_method.dart';
import '../../domain/models/contract_category.dart';
import '../../domain/models/heir_access.dart';
import '../../l10n/app_localizations.dart';

extension ContractCategoryL10n on ContractCategory {
  String localizedLabel(AppLocalizations l) => switch (this) {
        ContractCategory.streaming => l.catStreaming,
        ContractCategory.versicherung => l.catVersicherung,
        ContractCategory.handy => l.catHandy,
        ContractCategory.internet => l.catInternet,
        ContractCategory.software => l.catSoftware,
        ContractCategory.fitness => l.catFitness,
        ContractCategory.zeitung => l.catZeitung,
        ContractCategory.sonstiges => l.catSonstiges,
      };
}

extension BillingCycleL10n on BillingCycle {
  String localizedLabel(AppLocalizations l) => switch (this) {
        BillingCycle.monthly => l.billingMonthly,
        BillingCycle.quarterly => l.billingQuarterly,
        BillingCycle.yearly => l.billingYearly,
        BillingCycle.weekly => l.billingWeekly,
      };
}

extension CancellationMethodL10n on CancellationMethod {
  String localizedLabel(AppLocalizations l) => switch (this) {
        CancellationMethod.brief => l.cancBrief,
        CancellationMethod.online => l.cancOnline,
        CancellationMethod.telefon => l.cancTelefon,
        CancellationMethod.email => l.cancEmail,
        CancellationMethod.automatisch => l.cancAutomatisch,
      };
}

extension HeirAccessL10n on HeirAccess {
  String localizedLabel(AppLocalizations l) => switch (this) {
        HeirAccess.vollzugang => l.accessVollzugang,
        HeirAccess.nurListe => l.accessNurListe,
      };
}
