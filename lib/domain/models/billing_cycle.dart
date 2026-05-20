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
}
