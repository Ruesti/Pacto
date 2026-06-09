/// Nutzer-gewaehlte Einordnung eines Vertrags-Eintrags: laufender Vertrag
/// (z.B. Versicherung, Handy) oder Abo (z.B. Streaming). Bewusst getrennt vom
/// Abrechnungszyklus — eine monatlich gezahlte Krankenversicherung ist ein
/// Vertrag, kein Abo. Nur relevant wenn entryType == vertrag.
enum ContractKind {
  vertrag,
  abo;

  bool get isVertrag => this == ContractKind.vertrag;
  bool get isAbo => this == ContractKind.abo;

  String get label => switch (this) {
        vertrag => 'Vertrag',
        abo => 'Abo',
      };
}
