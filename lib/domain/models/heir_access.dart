enum HeirAccess {
  vollzugang,
  nurListe;

  String get label => switch (this) {
        vollzugang => 'Vollzugang (alle Felder)',
        nurListe => 'Nur Liste (Name, Kosten, Kündigung)',
      };
}
