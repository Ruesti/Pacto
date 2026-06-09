enum BillingCycle {
  monthly,
  quarterly,
  yearly,
  weekly;

  String get label => switch (this) {
        monthly => 'Monatlich',
        quarterly => 'Vierteljährlich',
        yearly => 'Jährlich',
        weekly => 'Wöchentlich',
      };

  /// Rechnet einen gespeicherten Monatsbetrag zurueck auf den Betrag pro
  /// Abrechnungsintervall — also den Betrag "wie gezahlt"/wie auf dem Beleg.
  /// Exakt invers zur Eingabe-Normalisierung in [setMonthlyCostFromInput]:
  ///   yearly  monthly*12,  quarterly  monthly*3,  weekly  monthly/4.33.
  double billedFrom(double monthlyCost) => switch (this) {
        yearly => monthlyCost * 12,
        quarterly => monthlyCost * 3,
        weekly => monthlyCost / 4.33,
        monthly => monthlyCost,
      };
}
