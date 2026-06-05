/// Diskriminator: Ist der Eintrag ein Vertrag/Abo oder ein eigenstaendiger
/// Zugang (WLAN-Router, Home-Server, Partner-Zugang ...)?
///
/// Zugaenge laufen ueber dieselbe Contracts-Tabelle, erben dadurch
/// Verschluesselung, Erben-Export, nurListe-Redaktion und Cloud-Sync. Sie
/// tragen monthlyCost == 0 und nutzen accessCategory statt category.
enum EntryType {
  vertrag,
  zugang;

  bool get isVertrag => this == EntryType.vertrag;
  bool get isZugang => this == EntryType.zugang;

  String get label => switch (this) {
        vertrag => 'Vertrag',
        zugang => 'Zugang',
      };
}
