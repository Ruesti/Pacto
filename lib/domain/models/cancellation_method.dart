enum CancellationMethod {
  brief,
  online,
  telefon,
  email,
  automatisch;

  String get label => switch (this) {
        brief => 'Brief',
        online => 'Online',
        telefon => 'Telefon',
        email => 'E-Mail',
        automatisch => 'Automatisch (kein Handlungsbedarf)',
      };
}
