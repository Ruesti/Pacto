enum ContractCategory {
  streaming,
  versicherung,
  handy,
  internet,
  software,
  fitness,
  zeitung,
  sonstiges;

  String get label => switch (this) {
        streaming => 'Streaming',
        versicherung => 'Versicherung',
        handy => 'Handy',
        internet => 'Internet',
        software => 'Software',
        fitness => 'Fitness',
        zeitung => 'Zeitung / Medien',
        sonstiges => 'Sonstiges',
      };
}
