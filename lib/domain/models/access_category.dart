/// Kategorie fuer eigenstaendige Zugaenge (EntryType.zugang). Bewusst parallel
/// zu ContractCategory gehalten — Router/Server passen nicht zu
/// Streaming/Versicherung. Bei zugang zaehlt accessCategory, category bleibt
/// ungenutzt.
enum AccessCategory {
  router,
  smarthome,
  email,
  banking,
  server,
  partnerAccount,
  geraet,
  sonstiges;

  String get label => switch (this) {
        router => 'Router / WLAN',
        smarthome => 'Smart Home',
        email => 'E-Mail / Konto',
        banking => 'Banking',
        server => 'Server / NAS',
        partnerAccount => 'Partner-Zugang',
        geraet => 'Geraet',
        sonstiges => 'Sonstiges',
      };
}
