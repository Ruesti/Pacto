// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ContractsTable extends Contracts
    with TableInfo<$ContractsTable, Contract> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContractsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => Uuid().v4());
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<ContractCategory, String>
      category = GeneratedColumn<String>('category', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('sonstiges'))
          .withConverter<ContractCategory>($ContractsTable.$convertercategory);
  static const VerificationMeta _providerMeta =
      const VerificationMeta('provider');
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
      'provider', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contactPhoneMeta =
      const VerificationMeta('contactPhone');
  @override
  late final GeneratedColumn<String> contactPhone = GeneratedColumn<String>(
      'contact_phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _contactEmailMeta =
      const VerificationMeta('contactEmail');
  @override
  late final GeneratedColumn<String> contactEmail = GeneratedColumn<String>(
      'contact_email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _contactUrlMeta =
      const VerificationMeta('contactUrl');
  @override
  late final GeneratedColumn<String> contactUrl = GeneratedColumn<String>(
      'contact_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<CancellationMethod, String>
      cancellationMethod = GeneratedColumn<String>(
              'cancellation_method', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('online'))
          .withConverter<CancellationMethod>(
              $ContractsTable.$convertercancellationMethod);
  static const VerificationMeta _cancellationInstructionsMeta =
      const VerificationMeta('cancellationInstructions');
  @override
  late final GeneratedColumn<String> cancellationInstructions =
      GeneratedColumn<String>('cancellation_instructions', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant(''));
  static const VerificationMeta _noticePeriodMeta =
      const VerificationMeta('noticePeriod');
  @override
  late final GeneratedColumn<String> noticePeriod = GeneratedColumn<String>(
      'notice_period', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _monthlyCostMeta =
      const VerificationMeta('monthlyCost');
  @override
  late final GeneratedColumn<double> monthlyCost = GeneratedColumn<double>(
      'monthly_cost', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  @override
  late final GeneratedColumnWithTypeConverter<BillingCycle, String>
      billingCycle = GeneratedColumn<String>(
              'billing_cycle', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('monthly'))
          .withConverter<BillingCycle>($ContractsTable.$converterbillingCycle);
  static const VerificationMeta _documentPathMeta =
      const VerificationMeta('documentPath');
  @override
  late final GeneratedColumn<String> documentPath = GeneratedColumn<String>(
      'document_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _contractStartMeta =
      const VerificationMeta('contractStart');
  @override
  late final GeneratedColumn<DateTime> contractStart =
      GeneratedColumn<DateTime>('contract_start', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _nextRenewalMeta =
      const VerificationMeta('nextRenewal');
  @override
  late final GeneratedColumn<DateTime> nextRenewal = GeneratedColumn<DateTime>(
      'next_renewal', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      clientDefault: DateTime.now);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      clientDefault: DateTime.now);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        category,
        provider,
        contactPhone,
        contactEmail,
        contactUrl,
        cancellationMethod,
        cancellationInstructions,
        noticePeriod,
        monthlyCost,
        billingCycle,
        documentPath,
        notes,
        contractStart,
        nextRenewal,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contracts';
  @override
  VerificationContext validateIntegrity(Insertable<Contract> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('provider')) {
      context.handle(_providerMeta,
          provider.isAcceptableOrUnknown(data['provider']!, _providerMeta));
    } else if (isInserting) {
      context.missing(_providerMeta);
    }
    if (data.containsKey('contact_phone')) {
      context.handle(
          _contactPhoneMeta,
          contactPhone.isAcceptableOrUnknown(
              data['contact_phone']!, _contactPhoneMeta));
    }
    if (data.containsKey('contact_email')) {
      context.handle(
          _contactEmailMeta,
          contactEmail.isAcceptableOrUnknown(
              data['contact_email']!, _contactEmailMeta));
    }
    if (data.containsKey('contact_url')) {
      context.handle(
          _contactUrlMeta,
          contactUrl.isAcceptableOrUnknown(
              data['contact_url']!, _contactUrlMeta));
    }
    if (data.containsKey('cancellation_instructions')) {
      context.handle(
          _cancellationInstructionsMeta,
          cancellationInstructions.isAcceptableOrUnknown(
              data['cancellation_instructions']!,
              _cancellationInstructionsMeta));
    }
    if (data.containsKey('notice_period')) {
      context.handle(
          _noticePeriodMeta,
          noticePeriod.isAcceptableOrUnknown(
              data['notice_period']!, _noticePeriodMeta));
    }
    if (data.containsKey('monthly_cost')) {
      context.handle(
          _monthlyCostMeta,
          monthlyCost.isAcceptableOrUnknown(
              data['monthly_cost']!, _monthlyCostMeta));
    }
    if (data.containsKey('document_path')) {
      context.handle(
          _documentPathMeta,
          documentPath.isAcceptableOrUnknown(
              data['document_path']!, _documentPathMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('contract_start')) {
      context.handle(
          _contractStartMeta,
          contractStart.isAcceptableOrUnknown(
              data['contract_start']!, _contractStartMeta));
    }
    if (data.containsKey('next_renewal')) {
      context.handle(
          _nextRenewalMeta,
          nextRenewal.isAcceptableOrUnknown(
              data['next_renewal']!, _nextRenewalMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Contract map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Contract(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      category: $ContractsTable.$convertercategory.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!),
      provider: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}provider'])!,
      contactPhone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}contact_phone']),
      contactEmail: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}contact_email']),
      contactUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}contact_url']),
      cancellationMethod: $ContractsTable.$convertercancellationMethod.fromSql(
          attachedDatabase.typeMapping.read(DriftSqlType.string,
              data['${effectivePrefix}cancellation_method'])!),
      cancellationInstructions: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}cancellation_instructions'])!,
      noticePeriod: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notice_period'])!,
      monthlyCost: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}monthly_cost'])!,
      billingCycle: $ContractsTable.$converterbillingCycle.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}billing_cycle'])!),
      documentPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}document_path']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes'])!,
      contractStart: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}contract_start']),
      nextRenewal: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}next_renewal']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ContractsTable createAlias(String alias) {
    return $ContractsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ContractCategory, String, String>
      $convertercategory =
      const EnumNameConverter<ContractCategory>(ContractCategory.values);
  static JsonTypeConverter2<CancellationMethod, String, String>
      $convertercancellationMethod =
      const EnumNameConverter<CancellationMethod>(CancellationMethod.values);
  static JsonTypeConverter2<BillingCycle, String, String>
      $converterbillingCycle =
      const EnumNameConverter<BillingCycle>(BillingCycle.values);
}

class Contract extends DataClass implements Insertable<Contract> {
  final String id;
  final String name;
  final ContractCategory category;
  final String provider;
  final String? contactPhone;
  final String? contactEmail;
  final String? contactUrl;
  final CancellationMethod cancellationMethod;
  final String cancellationInstructions;
  final String noticePeriod;
  final double monthlyCost;
  final BillingCycle billingCycle;
  final String? documentPath;
  final String notes;
  final DateTime? contractStart;
  final DateTime? nextRenewal;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Contract(
      {required this.id,
      required this.name,
      required this.category,
      required this.provider,
      this.contactPhone,
      this.contactEmail,
      this.contactUrl,
      required this.cancellationMethod,
      required this.cancellationInstructions,
      required this.noticePeriod,
      required this.monthlyCost,
      required this.billingCycle,
      this.documentPath,
      required this.notes,
      this.contractStart,
      this.nextRenewal,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    {
      map['category'] =
          Variable<String>($ContractsTable.$convertercategory.toSql(category));
    }
    map['provider'] = Variable<String>(provider);
    if (!nullToAbsent || contactPhone != null) {
      map['contact_phone'] = Variable<String>(contactPhone);
    }
    if (!nullToAbsent || contactEmail != null) {
      map['contact_email'] = Variable<String>(contactEmail);
    }
    if (!nullToAbsent || contactUrl != null) {
      map['contact_url'] = Variable<String>(contactUrl);
    }
    {
      map['cancellation_method'] = Variable<String>($ContractsTable
          .$convertercancellationMethod
          .toSql(cancellationMethod));
    }
    map['cancellation_instructions'] =
        Variable<String>(cancellationInstructions);
    map['notice_period'] = Variable<String>(noticePeriod);
    map['monthly_cost'] = Variable<double>(monthlyCost);
    {
      map['billing_cycle'] = Variable<String>(
          $ContractsTable.$converterbillingCycle.toSql(billingCycle));
    }
    if (!nullToAbsent || documentPath != null) {
      map['document_path'] = Variable<String>(documentPath);
    }
    map['notes'] = Variable<String>(notes);
    if (!nullToAbsent || contractStart != null) {
      map['contract_start'] = Variable<DateTime>(contractStart);
    }
    if (!nullToAbsent || nextRenewal != null) {
      map['next_renewal'] = Variable<DateTime>(nextRenewal);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ContractsCompanion toCompanion(bool nullToAbsent) {
    return ContractsCompanion(
      id: Value(id),
      name: Value(name),
      category: Value(category),
      provider: Value(provider),
      contactPhone: contactPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(contactPhone),
      contactEmail: contactEmail == null && nullToAbsent
          ? const Value.absent()
          : Value(contactEmail),
      contactUrl: contactUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(contactUrl),
      cancellationMethod: Value(cancellationMethod),
      cancellationInstructions: Value(cancellationInstructions),
      noticePeriod: Value(noticePeriod),
      monthlyCost: Value(monthlyCost),
      billingCycle: Value(billingCycle),
      documentPath: documentPath == null && nullToAbsent
          ? const Value.absent()
          : Value(documentPath),
      notes: Value(notes),
      contractStart: contractStart == null && nullToAbsent
          ? const Value.absent()
          : Value(contractStart),
      nextRenewal: nextRenewal == null && nullToAbsent
          ? const Value.absent()
          : Value(nextRenewal),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Contract.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Contract(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      category: $ContractsTable.$convertercategory
          .fromJson(serializer.fromJson<String>(json['category'])),
      provider: serializer.fromJson<String>(json['provider']),
      contactPhone: serializer.fromJson<String?>(json['contactPhone']),
      contactEmail: serializer.fromJson<String?>(json['contactEmail']),
      contactUrl: serializer.fromJson<String?>(json['contactUrl']),
      cancellationMethod: $ContractsTable.$convertercancellationMethod
          .fromJson(serializer.fromJson<String>(json['cancellationMethod'])),
      cancellationInstructions:
          serializer.fromJson<String>(json['cancellationInstructions']),
      noticePeriod: serializer.fromJson<String>(json['noticePeriod']),
      monthlyCost: serializer.fromJson<double>(json['monthlyCost']),
      billingCycle: $ContractsTable.$converterbillingCycle
          .fromJson(serializer.fromJson<String>(json['billingCycle'])),
      documentPath: serializer.fromJson<String?>(json['documentPath']),
      notes: serializer.fromJson<String>(json['notes']),
      contractStart: serializer.fromJson<DateTime?>(json['contractStart']),
      nextRenewal: serializer.fromJson<DateTime?>(json['nextRenewal']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'category': serializer
          .toJson<String>($ContractsTable.$convertercategory.toJson(category)),
      'provider': serializer.toJson<String>(provider),
      'contactPhone': serializer.toJson<String?>(contactPhone),
      'contactEmail': serializer.toJson<String?>(contactEmail),
      'contactUrl': serializer.toJson<String?>(contactUrl),
      'cancellationMethod': serializer.toJson<String>($ContractsTable
          .$convertercancellationMethod
          .toJson(cancellationMethod)),
      'cancellationInstructions':
          serializer.toJson<String>(cancellationInstructions),
      'noticePeriod': serializer.toJson<String>(noticePeriod),
      'monthlyCost': serializer.toJson<double>(monthlyCost),
      'billingCycle': serializer.toJson<String>(
          $ContractsTable.$converterbillingCycle.toJson(billingCycle)),
      'documentPath': serializer.toJson<String?>(documentPath),
      'notes': serializer.toJson<String>(notes),
      'contractStart': serializer.toJson<DateTime?>(contractStart),
      'nextRenewal': serializer.toJson<DateTime?>(nextRenewal),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Contract copyWith(
          {String? id,
          String? name,
          ContractCategory? category,
          String? provider,
          Value<String?> contactPhone = const Value.absent(),
          Value<String?> contactEmail = const Value.absent(),
          Value<String?> contactUrl = const Value.absent(),
          CancellationMethod? cancellationMethod,
          String? cancellationInstructions,
          String? noticePeriod,
          double? monthlyCost,
          BillingCycle? billingCycle,
          Value<String?> documentPath = const Value.absent(),
          String? notes,
          Value<DateTime?> contractStart = const Value.absent(),
          Value<DateTime?> nextRenewal = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Contract(
        id: id ?? this.id,
        name: name ?? this.name,
        category: category ?? this.category,
        provider: provider ?? this.provider,
        contactPhone:
            contactPhone.present ? contactPhone.value : this.contactPhone,
        contactEmail:
            contactEmail.present ? contactEmail.value : this.contactEmail,
        contactUrl: contactUrl.present ? contactUrl.value : this.contactUrl,
        cancellationMethod: cancellationMethod ?? this.cancellationMethod,
        cancellationInstructions:
            cancellationInstructions ?? this.cancellationInstructions,
        noticePeriod: noticePeriod ?? this.noticePeriod,
        monthlyCost: monthlyCost ?? this.monthlyCost,
        billingCycle: billingCycle ?? this.billingCycle,
        documentPath:
            documentPath.present ? documentPath.value : this.documentPath,
        notes: notes ?? this.notes,
        contractStart:
            contractStart.present ? contractStart.value : this.contractStart,
        nextRenewal: nextRenewal.present ? nextRenewal.value : this.nextRenewal,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Contract copyWithCompanion(ContractsCompanion data) {
    return Contract(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      provider: data.provider.present ? data.provider.value : this.provider,
      contactPhone: data.contactPhone.present
          ? data.contactPhone.value
          : this.contactPhone,
      contactEmail: data.contactEmail.present
          ? data.contactEmail.value
          : this.contactEmail,
      contactUrl:
          data.contactUrl.present ? data.contactUrl.value : this.contactUrl,
      cancellationMethod: data.cancellationMethod.present
          ? data.cancellationMethod.value
          : this.cancellationMethod,
      cancellationInstructions: data.cancellationInstructions.present
          ? data.cancellationInstructions.value
          : this.cancellationInstructions,
      noticePeriod: data.noticePeriod.present
          ? data.noticePeriod.value
          : this.noticePeriod,
      monthlyCost:
          data.monthlyCost.present ? data.monthlyCost.value : this.monthlyCost,
      billingCycle: data.billingCycle.present
          ? data.billingCycle.value
          : this.billingCycle,
      documentPath: data.documentPath.present
          ? data.documentPath.value
          : this.documentPath,
      notes: data.notes.present ? data.notes.value : this.notes,
      contractStart: data.contractStart.present
          ? data.contractStart.value
          : this.contractStart,
      nextRenewal:
          data.nextRenewal.present ? data.nextRenewal.value : this.nextRenewal,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Contract(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('provider: $provider, ')
          ..write('contactPhone: $contactPhone, ')
          ..write('contactEmail: $contactEmail, ')
          ..write('contactUrl: $contactUrl, ')
          ..write('cancellationMethod: $cancellationMethod, ')
          ..write('cancellationInstructions: $cancellationInstructions, ')
          ..write('noticePeriod: $noticePeriod, ')
          ..write('monthlyCost: $monthlyCost, ')
          ..write('billingCycle: $billingCycle, ')
          ..write('documentPath: $documentPath, ')
          ..write('notes: $notes, ')
          ..write('contractStart: $contractStart, ')
          ..write('nextRenewal: $nextRenewal, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      category,
      provider,
      contactPhone,
      contactEmail,
      contactUrl,
      cancellationMethod,
      cancellationInstructions,
      noticePeriod,
      monthlyCost,
      billingCycle,
      documentPath,
      notes,
      contractStart,
      nextRenewal,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Contract &&
          other.id == this.id &&
          other.name == this.name &&
          other.category == this.category &&
          other.provider == this.provider &&
          other.contactPhone == this.contactPhone &&
          other.contactEmail == this.contactEmail &&
          other.contactUrl == this.contactUrl &&
          other.cancellationMethod == this.cancellationMethod &&
          other.cancellationInstructions == this.cancellationInstructions &&
          other.noticePeriod == this.noticePeriod &&
          other.monthlyCost == this.monthlyCost &&
          other.billingCycle == this.billingCycle &&
          other.documentPath == this.documentPath &&
          other.notes == this.notes &&
          other.contractStart == this.contractStart &&
          other.nextRenewal == this.nextRenewal &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ContractsCompanion extends UpdateCompanion<Contract> {
  final Value<String> id;
  final Value<String> name;
  final Value<ContractCategory> category;
  final Value<String> provider;
  final Value<String?> contactPhone;
  final Value<String?> contactEmail;
  final Value<String?> contactUrl;
  final Value<CancellationMethod> cancellationMethod;
  final Value<String> cancellationInstructions;
  final Value<String> noticePeriod;
  final Value<double> monthlyCost;
  final Value<BillingCycle> billingCycle;
  final Value<String?> documentPath;
  final Value<String> notes;
  final Value<DateTime?> contractStart;
  final Value<DateTime?> nextRenewal;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ContractsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.provider = const Value.absent(),
    this.contactPhone = const Value.absent(),
    this.contactEmail = const Value.absent(),
    this.contactUrl = const Value.absent(),
    this.cancellationMethod = const Value.absent(),
    this.cancellationInstructions = const Value.absent(),
    this.noticePeriod = const Value.absent(),
    this.monthlyCost = const Value.absent(),
    this.billingCycle = const Value.absent(),
    this.documentPath = const Value.absent(),
    this.notes = const Value.absent(),
    this.contractStart = const Value.absent(),
    this.nextRenewal = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContractsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.category = const Value.absent(),
    required String provider,
    this.contactPhone = const Value.absent(),
    this.contactEmail = const Value.absent(),
    this.contactUrl = const Value.absent(),
    this.cancellationMethod = const Value.absent(),
    this.cancellationInstructions = const Value.absent(),
    this.noticePeriod = const Value.absent(),
    this.monthlyCost = const Value.absent(),
    this.billingCycle = const Value.absent(),
    this.documentPath = const Value.absent(),
    this.notes = const Value.absent(),
    this.contractStart = const Value.absent(),
    this.nextRenewal = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : name = Value(name),
        provider = Value(provider);
  static Insertable<Contract> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? category,
    Expression<String>? provider,
    Expression<String>? contactPhone,
    Expression<String>? contactEmail,
    Expression<String>? contactUrl,
    Expression<String>? cancellationMethod,
    Expression<String>? cancellationInstructions,
    Expression<String>? noticePeriod,
    Expression<double>? monthlyCost,
    Expression<String>? billingCycle,
    Expression<String>? documentPath,
    Expression<String>? notes,
    Expression<DateTime>? contractStart,
    Expression<DateTime>? nextRenewal,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (provider != null) 'provider': provider,
      if (contactPhone != null) 'contact_phone': contactPhone,
      if (contactEmail != null) 'contact_email': contactEmail,
      if (contactUrl != null) 'contact_url': contactUrl,
      if (cancellationMethod != null) 'cancellation_method': cancellationMethod,
      if (cancellationInstructions != null)
        'cancellation_instructions': cancellationInstructions,
      if (noticePeriod != null) 'notice_period': noticePeriod,
      if (monthlyCost != null) 'monthly_cost': monthlyCost,
      if (billingCycle != null) 'billing_cycle': billingCycle,
      if (documentPath != null) 'document_path': documentPath,
      if (notes != null) 'notes': notes,
      if (contractStart != null) 'contract_start': contractStart,
      if (nextRenewal != null) 'next_renewal': nextRenewal,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContractsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<ContractCategory>? category,
      Value<String>? provider,
      Value<String?>? contactPhone,
      Value<String?>? contactEmail,
      Value<String?>? contactUrl,
      Value<CancellationMethod>? cancellationMethod,
      Value<String>? cancellationInstructions,
      Value<String>? noticePeriod,
      Value<double>? monthlyCost,
      Value<BillingCycle>? billingCycle,
      Value<String?>? documentPath,
      Value<String>? notes,
      Value<DateTime?>? contractStart,
      Value<DateTime?>? nextRenewal,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return ContractsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      provider: provider ?? this.provider,
      contactPhone: contactPhone ?? this.contactPhone,
      contactEmail: contactEmail ?? this.contactEmail,
      contactUrl: contactUrl ?? this.contactUrl,
      cancellationMethod: cancellationMethod ?? this.cancellationMethod,
      cancellationInstructions:
          cancellationInstructions ?? this.cancellationInstructions,
      noticePeriod: noticePeriod ?? this.noticePeriod,
      monthlyCost: monthlyCost ?? this.monthlyCost,
      billingCycle: billingCycle ?? this.billingCycle,
      documentPath: documentPath ?? this.documentPath,
      notes: notes ?? this.notes,
      contractStart: contractStart ?? this.contractStart,
      nextRenewal: nextRenewal ?? this.nextRenewal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(
          $ContractsTable.$convertercategory.toSql(category.value));
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (contactPhone.present) {
      map['contact_phone'] = Variable<String>(contactPhone.value);
    }
    if (contactEmail.present) {
      map['contact_email'] = Variable<String>(contactEmail.value);
    }
    if (contactUrl.present) {
      map['contact_url'] = Variable<String>(contactUrl.value);
    }
    if (cancellationMethod.present) {
      map['cancellation_method'] = Variable<String>($ContractsTable
          .$convertercancellationMethod
          .toSql(cancellationMethod.value));
    }
    if (cancellationInstructions.present) {
      map['cancellation_instructions'] =
          Variable<String>(cancellationInstructions.value);
    }
    if (noticePeriod.present) {
      map['notice_period'] = Variable<String>(noticePeriod.value);
    }
    if (monthlyCost.present) {
      map['monthly_cost'] = Variable<double>(monthlyCost.value);
    }
    if (billingCycle.present) {
      map['billing_cycle'] = Variable<String>(
          $ContractsTable.$converterbillingCycle.toSql(billingCycle.value));
    }
    if (documentPath.present) {
      map['document_path'] = Variable<String>(documentPath.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (contractStart.present) {
      map['contract_start'] = Variable<DateTime>(contractStart.value);
    }
    if (nextRenewal.present) {
      map['next_renewal'] = Variable<DateTime>(nextRenewal.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContractsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('provider: $provider, ')
          ..write('contactPhone: $contactPhone, ')
          ..write('contactEmail: $contactEmail, ')
          ..write('contactUrl: $contactUrl, ')
          ..write('cancellationMethod: $cancellationMethod, ')
          ..write('cancellationInstructions: $cancellationInstructions, ')
          ..write('noticePeriod: $noticePeriod, ')
          ..write('monthlyCost: $monthlyCost, ')
          ..write('billingCycle: $billingCycle, ')
          ..write('documentPath: $documentPath, ')
          ..write('notes: $notes, ')
          ..write('contractStart: $contractStart, ')
          ..write('nextRenewal: $nextRenewal, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HeirsTable extends Heirs with TableInfo<$HeirsTable, Heir> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HeirsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => Uuid().v4());
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _pinHashMeta =
      const VerificationMeta('pinHash');
  @override
  late final GeneratedColumn<String> pinHash = GeneratedColumn<String>(
      'pin_hash', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<HeirAccess, String> accessLevel =
      GeneratedColumn<String>('access_level', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('nurListe'))
          .withConverter<HeirAccess>($HeirsTable.$converteraccessLevel);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      clientDefault: DateTime.now);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, email, pinHash, accessLevel, isActive, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'heirs';
  @override
  VerificationContext validateIntegrity(Insertable<Heir> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('pin_hash')) {
      context.handle(_pinHashMeta,
          pinHash.isAcceptableOrUnknown(data['pin_hash']!, _pinHashMeta));
    } else if (isInserting) {
      context.missing(_pinHashMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Heir map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Heir(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email'])!,
      pinHash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pin_hash'])!,
      accessLevel: $HeirsTable.$converteraccessLevel.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}access_level'])!),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $HeirsTable createAlias(String alias) {
    return $HeirsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<HeirAccess, String, String> $converteraccessLevel =
      const EnumNameConverter<HeirAccess>(HeirAccess.values);
}

class Heir extends DataClass implements Insertable<Heir> {
  final String id;
  final String name;
  final String email;
  final String pinHash;
  final HeirAccess accessLevel;
  final bool isActive;
  final DateTime createdAt;
  const Heir(
      {required this.id,
      required this.name,
      required this.email,
      required this.pinHash,
      required this.accessLevel,
      required this.isActive,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['email'] = Variable<String>(email);
    map['pin_hash'] = Variable<String>(pinHash);
    {
      map['access_level'] = Variable<String>(
          $HeirsTable.$converteraccessLevel.toSql(accessLevel));
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  HeirsCompanion toCompanion(bool nullToAbsent) {
    return HeirsCompanion(
      id: Value(id),
      name: Value(name),
      email: Value(email),
      pinHash: Value(pinHash),
      accessLevel: Value(accessLevel),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory Heir.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Heir(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      email: serializer.fromJson<String>(json['email']),
      pinHash: serializer.fromJson<String>(json['pinHash']),
      accessLevel: $HeirsTable.$converteraccessLevel
          .fromJson(serializer.fromJson<String>(json['accessLevel'])),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'email': serializer.toJson<String>(email),
      'pinHash': serializer.toJson<String>(pinHash),
      'accessLevel': serializer.toJson<String>(
          $HeirsTable.$converteraccessLevel.toJson(accessLevel)),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Heir copyWith(
          {String? id,
          String? name,
          String? email,
          String? pinHash,
          HeirAccess? accessLevel,
          bool? isActive,
          DateTime? createdAt}) =>
      Heir(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        pinHash: pinHash ?? this.pinHash,
        accessLevel: accessLevel ?? this.accessLevel,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
      );
  Heir copyWithCompanion(HeirsCompanion data) {
    return Heir(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      email: data.email.present ? data.email.value : this.email,
      pinHash: data.pinHash.present ? data.pinHash.value : this.pinHash,
      accessLevel:
          data.accessLevel.present ? data.accessLevel.value : this.accessLevel,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Heir(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('pinHash: $pinHash, ')
          ..write('accessLevel: $accessLevel, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, email, pinHash, accessLevel, isActive, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Heir &&
          other.id == this.id &&
          other.name == this.name &&
          other.email == this.email &&
          other.pinHash == this.pinHash &&
          other.accessLevel == this.accessLevel &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class HeirsCompanion extends UpdateCompanion<Heir> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> email;
  final Value<String> pinHash;
  final Value<HeirAccess> accessLevel;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const HeirsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.pinHash = const Value.absent(),
    this.accessLevel = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HeirsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String email,
    required String pinHash,
    this.accessLevel = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : name = Value(name),
        email = Value(email),
        pinHash = Value(pinHash);
  static Insertable<Heir> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? email,
    Expression<String>? pinHash,
    Expression<String>? accessLevel,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (pinHash != null) 'pin_hash': pinHash,
      if (accessLevel != null) 'access_level': accessLevel,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HeirsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? email,
      Value<String>? pinHash,
      Value<HeirAccess>? accessLevel,
      Value<bool>? isActive,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return HeirsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      pinHash: pinHash ?? this.pinHash,
      accessLevel: accessLevel ?? this.accessLevel,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (pinHash.present) {
      map['pin_hash'] = Variable<String>(pinHash.value);
    }
    if (accessLevel.present) {
      map['access_level'] = Variable<String>(
          $HeirsTable.$converteraccessLevel.toSql(accessLevel.value));
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HeirsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('pinHash: $pinHash, ')
          ..write('accessLevel: $accessLevel, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProviderLibraryTable extends ProviderLibrary
    with TableInfo<$ProviderLibraryTable, ProviderLibraryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProviderLibraryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => Uuid().v4());
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<ContractCategory, String>
      category = GeneratedColumn<String>('category', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('sonstiges'))
          .withConverter<ContractCategory>(
              $ProviderLibraryTable.$convertercategory);
  static const VerificationMeta _providerMeta =
      const VerificationMeta('provider');
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
      'provider', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contactPhoneMeta =
      const VerificationMeta('contactPhone');
  @override
  late final GeneratedColumn<String> contactPhone = GeneratedColumn<String>(
      'contact_phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _contactEmailMeta =
      const VerificationMeta('contactEmail');
  @override
  late final GeneratedColumn<String> contactEmail = GeneratedColumn<String>(
      'contact_email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _contactUrlMeta =
      const VerificationMeta('contactUrl');
  @override
  late final GeneratedColumn<String> contactUrl = GeneratedColumn<String>(
      'contact_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<CancellationMethod, String>
      cancellationMethod = GeneratedColumn<String>(
              'cancellation_method', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('online'))
          .withConverter<CancellationMethod>(
              $ProviderLibraryTable.$convertercancellationMethod);
  static const VerificationMeta _cancellationInstructionsMeta =
      const VerificationMeta('cancellationInstructions');
  @override
  late final GeneratedColumn<String> cancellationInstructions =
      GeneratedColumn<String>('cancellation_instructions', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant(''));
  static const VerificationMeta _noticePeriodMeta =
      const VerificationMeta('noticePeriod');
  @override
  late final GeneratedColumn<String> noticePeriod = GeneratedColumn<String>(
      'notice_period', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        category,
        provider,
        contactPhone,
        contactEmail,
        contactUrl,
        cancellationMethod,
        cancellationInstructions,
        noticePeriod
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'provider_library';
  @override
  VerificationContext validateIntegrity(
      Insertable<ProviderLibraryData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('provider')) {
      context.handle(_providerMeta,
          provider.isAcceptableOrUnknown(data['provider']!, _providerMeta));
    } else if (isInserting) {
      context.missing(_providerMeta);
    }
    if (data.containsKey('contact_phone')) {
      context.handle(
          _contactPhoneMeta,
          contactPhone.isAcceptableOrUnknown(
              data['contact_phone']!, _contactPhoneMeta));
    }
    if (data.containsKey('contact_email')) {
      context.handle(
          _contactEmailMeta,
          contactEmail.isAcceptableOrUnknown(
              data['contact_email']!, _contactEmailMeta));
    }
    if (data.containsKey('contact_url')) {
      context.handle(
          _contactUrlMeta,
          contactUrl.isAcceptableOrUnknown(
              data['contact_url']!, _contactUrlMeta));
    }
    if (data.containsKey('cancellation_instructions')) {
      context.handle(
          _cancellationInstructionsMeta,
          cancellationInstructions.isAcceptableOrUnknown(
              data['cancellation_instructions']!,
              _cancellationInstructionsMeta));
    }
    if (data.containsKey('notice_period')) {
      context.handle(
          _noticePeriodMeta,
          noticePeriod.isAcceptableOrUnknown(
              data['notice_period']!, _noticePeriodMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProviderLibraryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProviderLibraryData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      category: $ProviderLibraryTable.$convertercategory.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.string, data['${effectivePrefix}category'])!),
      provider: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}provider'])!,
      contactPhone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}contact_phone']),
      contactEmail: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}contact_email']),
      contactUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}contact_url']),
      cancellationMethod: $ProviderLibraryTable.$convertercancellationMethod
          .fromSql(attachedDatabase.typeMapping.read(DriftSqlType.string,
              data['${effectivePrefix}cancellation_method'])!),
      cancellationInstructions: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}cancellation_instructions'])!,
      noticePeriod: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notice_period'])!,
    );
  }

  @override
  $ProviderLibraryTable createAlias(String alias) {
    return $ProviderLibraryTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ContractCategory, String, String>
      $convertercategory =
      const EnumNameConverter<ContractCategory>(ContractCategory.values);
  static JsonTypeConverter2<CancellationMethod, String, String>
      $convertercancellationMethod =
      const EnumNameConverter<CancellationMethod>(CancellationMethod.values);
}

class ProviderLibraryData extends DataClass
    implements Insertable<ProviderLibraryData> {
  final String id;
  final String name;
  final ContractCategory category;
  final String provider;
  final String? contactPhone;
  final String? contactEmail;
  final String? contactUrl;
  final CancellationMethod cancellationMethod;
  final String cancellationInstructions;
  final String noticePeriod;
  const ProviderLibraryData(
      {required this.id,
      required this.name,
      required this.category,
      required this.provider,
      this.contactPhone,
      this.contactEmail,
      this.contactUrl,
      required this.cancellationMethod,
      required this.cancellationInstructions,
      required this.noticePeriod});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    {
      map['category'] = Variable<String>(
          $ProviderLibraryTable.$convertercategory.toSql(category));
    }
    map['provider'] = Variable<String>(provider);
    if (!nullToAbsent || contactPhone != null) {
      map['contact_phone'] = Variable<String>(contactPhone);
    }
    if (!nullToAbsent || contactEmail != null) {
      map['contact_email'] = Variable<String>(contactEmail);
    }
    if (!nullToAbsent || contactUrl != null) {
      map['contact_url'] = Variable<String>(contactUrl);
    }
    {
      map['cancellation_method'] = Variable<String>($ProviderLibraryTable
          .$convertercancellationMethod
          .toSql(cancellationMethod));
    }
    map['cancellation_instructions'] =
        Variable<String>(cancellationInstructions);
    map['notice_period'] = Variable<String>(noticePeriod);
    return map;
  }

  ProviderLibraryCompanion toCompanion(bool nullToAbsent) {
    return ProviderLibraryCompanion(
      id: Value(id),
      name: Value(name),
      category: Value(category),
      provider: Value(provider),
      contactPhone: contactPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(contactPhone),
      contactEmail: contactEmail == null && nullToAbsent
          ? const Value.absent()
          : Value(contactEmail),
      contactUrl: contactUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(contactUrl),
      cancellationMethod: Value(cancellationMethod),
      cancellationInstructions: Value(cancellationInstructions),
      noticePeriod: Value(noticePeriod),
    );
  }

  factory ProviderLibraryData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProviderLibraryData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      category: $ProviderLibraryTable.$convertercategory
          .fromJson(serializer.fromJson<String>(json['category'])),
      provider: serializer.fromJson<String>(json['provider']),
      contactPhone: serializer.fromJson<String?>(json['contactPhone']),
      contactEmail: serializer.fromJson<String?>(json['contactEmail']),
      contactUrl: serializer.fromJson<String?>(json['contactUrl']),
      cancellationMethod: $ProviderLibraryTable.$convertercancellationMethod
          .fromJson(serializer.fromJson<String>(json['cancellationMethod'])),
      cancellationInstructions:
          serializer.fromJson<String>(json['cancellationInstructions']),
      noticePeriod: serializer.fromJson<String>(json['noticePeriod']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String>(
          $ProviderLibraryTable.$convertercategory.toJson(category)),
      'provider': serializer.toJson<String>(provider),
      'contactPhone': serializer.toJson<String?>(contactPhone),
      'contactEmail': serializer.toJson<String?>(contactEmail),
      'contactUrl': serializer.toJson<String?>(contactUrl),
      'cancellationMethod': serializer.toJson<String>($ProviderLibraryTable
          .$convertercancellationMethod
          .toJson(cancellationMethod)),
      'cancellationInstructions':
          serializer.toJson<String>(cancellationInstructions),
      'noticePeriod': serializer.toJson<String>(noticePeriod),
    };
  }

  ProviderLibraryData copyWith(
          {String? id,
          String? name,
          ContractCategory? category,
          String? provider,
          Value<String?> contactPhone = const Value.absent(),
          Value<String?> contactEmail = const Value.absent(),
          Value<String?> contactUrl = const Value.absent(),
          CancellationMethod? cancellationMethod,
          String? cancellationInstructions,
          String? noticePeriod}) =>
      ProviderLibraryData(
        id: id ?? this.id,
        name: name ?? this.name,
        category: category ?? this.category,
        provider: provider ?? this.provider,
        contactPhone:
            contactPhone.present ? contactPhone.value : this.contactPhone,
        contactEmail:
            contactEmail.present ? contactEmail.value : this.contactEmail,
        contactUrl: contactUrl.present ? contactUrl.value : this.contactUrl,
        cancellationMethod: cancellationMethod ?? this.cancellationMethod,
        cancellationInstructions:
            cancellationInstructions ?? this.cancellationInstructions,
        noticePeriod: noticePeriod ?? this.noticePeriod,
      );
  ProviderLibraryData copyWithCompanion(ProviderLibraryCompanion data) {
    return ProviderLibraryData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      provider: data.provider.present ? data.provider.value : this.provider,
      contactPhone: data.contactPhone.present
          ? data.contactPhone.value
          : this.contactPhone,
      contactEmail: data.contactEmail.present
          ? data.contactEmail.value
          : this.contactEmail,
      contactUrl:
          data.contactUrl.present ? data.contactUrl.value : this.contactUrl,
      cancellationMethod: data.cancellationMethod.present
          ? data.cancellationMethod.value
          : this.cancellationMethod,
      cancellationInstructions: data.cancellationInstructions.present
          ? data.cancellationInstructions.value
          : this.cancellationInstructions,
      noticePeriod: data.noticePeriod.present
          ? data.noticePeriod.value
          : this.noticePeriod,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProviderLibraryData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('provider: $provider, ')
          ..write('contactPhone: $contactPhone, ')
          ..write('contactEmail: $contactEmail, ')
          ..write('contactUrl: $contactUrl, ')
          ..write('cancellationMethod: $cancellationMethod, ')
          ..write('cancellationInstructions: $cancellationInstructions, ')
          ..write('noticePeriod: $noticePeriod')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      category,
      provider,
      contactPhone,
      contactEmail,
      contactUrl,
      cancellationMethod,
      cancellationInstructions,
      noticePeriod);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProviderLibraryData &&
          other.id == this.id &&
          other.name == this.name &&
          other.category == this.category &&
          other.provider == this.provider &&
          other.contactPhone == this.contactPhone &&
          other.contactEmail == this.contactEmail &&
          other.contactUrl == this.contactUrl &&
          other.cancellationMethod == this.cancellationMethod &&
          other.cancellationInstructions == this.cancellationInstructions &&
          other.noticePeriod == this.noticePeriod);
}

class ProviderLibraryCompanion extends UpdateCompanion<ProviderLibraryData> {
  final Value<String> id;
  final Value<String> name;
  final Value<ContractCategory> category;
  final Value<String> provider;
  final Value<String?> contactPhone;
  final Value<String?> contactEmail;
  final Value<String?> contactUrl;
  final Value<CancellationMethod> cancellationMethod;
  final Value<String> cancellationInstructions;
  final Value<String> noticePeriod;
  final Value<int> rowid;
  const ProviderLibraryCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.provider = const Value.absent(),
    this.contactPhone = const Value.absent(),
    this.contactEmail = const Value.absent(),
    this.contactUrl = const Value.absent(),
    this.cancellationMethod = const Value.absent(),
    this.cancellationInstructions = const Value.absent(),
    this.noticePeriod = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProviderLibraryCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.category = const Value.absent(),
    required String provider,
    this.contactPhone = const Value.absent(),
    this.contactEmail = const Value.absent(),
    this.contactUrl = const Value.absent(),
    this.cancellationMethod = const Value.absent(),
    this.cancellationInstructions = const Value.absent(),
    this.noticePeriod = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : name = Value(name),
        provider = Value(provider);
  static Insertable<ProviderLibraryData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? category,
    Expression<String>? provider,
    Expression<String>? contactPhone,
    Expression<String>? contactEmail,
    Expression<String>? contactUrl,
    Expression<String>? cancellationMethod,
    Expression<String>? cancellationInstructions,
    Expression<String>? noticePeriod,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (provider != null) 'provider': provider,
      if (contactPhone != null) 'contact_phone': contactPhone,
      if (contactEmail != null) 'contact_email': contactEmail,
      if (contactUrl != null) 'contact_url': contactUrl,
      if (cancellationMethod != null) 'cancellation_method': cancellationMethod,
      if (cancellationInstructions != null)
        'cancellation_instructions': cancellationInstructions,
      if (noticePeriod != null) 'notice_period': noticePeriod,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProviderLibraryCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<ContractCategory>? category,
      Value<String>? provider,
      Value<String?>? contactPhone,
      Value<String?>? contactEmail,
      Value<String?>? contactUrl,
      Value<CancellationMethod>? cancellationMethod,
      Value<String>? cancellationInstructions,
      Value<String>? noticePeriod,
      Value<int>? rowid}) {
    return ProviderLibraryCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      provider: provider ?? this.provider,
      contactPhone: contactPhone ?? this.contactPhone,
      contactEmail: contactEmail ?? this.contactEmail,
      contactUrl: contactUrl ?? this.contactUrl,
      cancellationMethod: cancellationMethod ?? this.cancellationMethod,
      cancellationInstructions:
          cancellationInstructions ?? this.cancellationInstructions,
      noticePeriod: noticePeriod ?? this.noticePeriod,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(
          $ProviderLibraryTable.$convertercategory.toSql(category.value));
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (contactPhone.present) {
      map['contact_phone'] = Variable<String>(contactPhone.value);
    }
    if (contactEmail.present) {
      map['contact_email'] = Variable<String>(contactEmail.value);
    }
    if (contactUrl.present) {
      map['contact_url'] = Variable<String>(contactUrl.value);
    }
    if (cancellationMethod.present) {
      map['cancellation_method'] = Variable<String>($ProviderLibraryTable
          .$convertercancellationMethod
          .toSql(cancellationMethod.value));
    }
    if (cancellationInstructions.present) {
      map['cancellation_instructions'] =
          Variable<String>(cancellationInstructions.value);
    }
    if (noticePeriod.present) {
      map['notice_period'] = Variable<String>(noticePeriod.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProviderLibraryCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('provider: $provider, ')
          ..write('contactPhone: $contactPhone, ')
          ..write('contactEmail: $contactEmail, ')
          ..write('contactUrl: $contactUrl, ')
          ..write('cancellationMethod: $cancellationMethod, ')
          ..write('cancellationInstructions: $cancellationInstructions, ')
          ..write('noticePeriod: $noticePeriod, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ContractsTable contracts = $ContractsTable(this);
  late final $HeirsTable heirs = $HeirsTable(this);
  late final $ProviderLibraryTable providerLibrary =
      $ProviderLibraryTable(this);
  late final ContractsDao contractsDao = ContractsDao(this as AppDatabase);
  late final HeirsDao heirsDao = HeirsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [contracts, heirs, providerLibrary];
}

typedef $$ContractsTableCreateCompanionBuilder = ContractsCompanion Function({
  Value<String> id,
  required String name,
  Value<ContractCategory> category,
  required String provider,
  Value<String?> contactPhone,
  Value<String?> contactEmail,
  Value<String?> contactUrl,
  Value<CancellationMethod> cancellationMethod,
  Value<String> cancellationInstructions,
  Value<String> noticePeriod,
  Value<double> monthlyCost,
  Value<BillingCycle> billingCycle,
  Value<String?> documentPath,
  Value<String> notes,
  Value<DateTime?> contractStart,
  Value<DateTime?> nextRenewal,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$ContractsTableUpdateCompanionBuilder = ContractsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<ContractCategory> category,
  Value<String> provider,
  Value<String?> contactPhone,
  Value<String?> contactEmail,
  Value<String?> contactUrl,
  Value<CancellationMethod> cancellationMethod,
  Value<String> cancellationInstructions,
  Value<String> noticePeriod,
  Value<double> monthlyCost,
  Value<BillingCycle> billingCycle,
  Value<String?> documentPath,
  Value<String> notes,
  Value<DateTime?> contractStart,
  Value<DateTime?> nextRenewal,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$ContractsTableFilterComposer
    extends Composer<_$AppDatabase, $ContractsTable> {
  $$ContractsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<ContractCategory, ContractCategory, String>
      get category => $composableBuilder(
          column: $table.category,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get provider => $composableBuilder(
      column: $table.provider, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contactPhone => $composableBuilder(
      column: $table.contactPhone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contactEmail => $composableBuilder(
      column: $table.contactEmail, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contactUrl => $composableBuilder(
      column: $table.contactUrl, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<CancellationMethod, CancellationMethod, String>
      get cancellationMethod => $composableBuilder(
          column: $table.cancellationMethod,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get cancellationInstructions => $composableBuilder(
      column: $table.cancellationInstructions,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get noticePeriod => $composableBuilder(
      column: $table.noticePeriod, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get monthlyCost => $composableBuilder(
      column: $table.monthlyCost, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<BillingCycle, BillingCycle, String>
      get billingCycle => $composableBuilder(
          column: $table.billingCycle,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get documentPath => $composableBuilder(
      column: $table.documentPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get contractStart => $composableBuilder(
      column: $table.contractStart, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get nextRenewal => $composableBuilder(
      column: $table.nextRenewal, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$ContractsTableOrderingComposer
    extends Composer<_$AppDatabase, $ContractsTable> {
  $$ContractsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get provider => $composableBuilder(
      column: $table.provider, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contactPhone => $composableBuilder(
      column: $table.contactPhone,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contactEmail => $composableBuilder(
      column: $table.contactEmail,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contactUrl => $composableBuilder(
      column: $table.contactUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cancellationMethod => $composableBuilder(
      column: $table.cancellationMethod,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cancellationInstructions => $composableBuilder(
      column: $table.cancellationInstructions,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get noticePeriod => $composableBuilder(
      column: $table.noticePeriod,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get monthlyCost => $composableBuilder(
      column: $table.monthlyCost, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get billingCycle => $composableBuilder(
      column: $table.billingCycle,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get documentPath => $composableBuilder(
      column: $table.documentPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get contractStart => $composableBuilder(
      column: $table.contractStart,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get nextRenewal => $composableBuilder(
      column: $table.nextRenewal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$ContractsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContractsTable> {
  $$ContractsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ContractCategory, String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<String> get contactPhone => $composableBuilder(
      column: $table.contactPhone, builder: (column) => column);

  GeneratedColumn<String> get contactEmail => $composableBuilder(
      column: $table.contactEmail, builder: (column) => column);

  GeneratedColumn<String> get contactUrl => $composableBuilder(
      column: $table.contactUrl, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CancellationMethod, String>
      get cancellationMethod => $composableBuilder(
          column: $table.cancellationMethod, builder: (column) => column);

  GeneratedColumn<String> get cancellationInstructions => $composableBuilder(
      column: $table.cancellationInstructions, builder: (column) => column);

  GeneratedColumn<String> get noticePeriod => $composableBuilder(
      column: $table.noticePeriod, builder: (column) => column);

  GeneratedColumn<double> get monthlyCost => $composableBuilder(
      column: $table.monthlyCost, builder: (column) => column);

  GeneratedColumnWithTypeConverter<BillingCycle, String> get billingCycle =>
      $composableBuilder(
          column: $table.billingCycle, builder: (column) => column);

  GeneratedColumn<String> get documentPath => $composableBuilder(
      column: $table.documentPath, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get contractStart => $composableBuilder(
      column: $table.contractStart, builder: (column) => column);

  GeneratedColumn<DateTime> get nextRenewal => $composableBuilder(
      column: $table.nextRenewal, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ContractsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ContractsTable,
    Contract,
    $$ContractsTableFilterComposer,
    $$ContractsTableOrderingComposer,
    $$ContractsTableAnnotationComposer,
    $$ContractsTableCreateCompanionBuilder,
    $$ContractsTableUpdateCompanionBuilder,
    (Contract, BaseReferences<_$AppDatabase, $ContractsTable, Contract>),
    Contract,
    PrefetchHooks Function()> {
  $$ContractsTableTableManager(_$AppDatabase db, $ContractsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContractsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContractsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContractsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<ContractCategory> category = const Value.absent(),
            Value<String> provider = const Value.absent(),
            Value<String?> contactPhone = const Value.absent(),
            Value<String?> contactEmail = const Value.absent(),
            Value<String?> contactUrl = const Value.absent(),
            Value<CancellationMethod> cancellationMethod = const Value.absent(),
            Value<String> cancellationInstructions = const Value.absent(),
            Value<String> noticePeriod = const Value.absent(),
            Value<double> monthlyCost = const Value.absent(),
            Value<BillingCycle> billingCycle = const Value.absent(),
            Value<String?> documentPath = const Value.absent(),
            Value<String> notes = const Value.absent(),
            Value<DateTime?> contractStart = const Value.absent(),
            Value<DateTime?> nextRenewal = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ContractsCompanion(
            id: id,
            name: name,
            category: category,
            provider: provider,
            contactPhone: contactPhone,
            contactEmail: contactEmail,
            contactUrl: contactUrl,
            cancellationMethod: cancellationMethod,
            cancellationInstructions: cancellationInstructions,
            noticePeriod: noticePeriod,
            monthlyCost: monthlyCost,
            billingCycle: billingCycle,
            documentPath: documentPath,
            notes: notes,
            contractStart: contractStart,
            nextRenewal: nextRenewal,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String> id = const Value.absent(),
            required String name,
            Value<ContractCategory> category = const Value.absent(),
            required String provider,
            Value<String?> contactPhone = const Value.absent(),
            Value<String?> contactEmail = const Value.absent(),
            Value<String?> contactUrl = const Value.absent(),
            Value<CancellationMethod> cancellationMethod = const Value.absent(),
            Value<String> cancellationInstructions = const Value.absent(),
            Value<String> noticePeriod = const Value.absent(),
            Value<double> monthlyCost = const Value.absent(),
            Value<BillingCycle> billingCycle = const Value.absent(),
            Value<String?> documentPath = const Value.absent(),
            Value<String> notes = const Value.absent(),
            Value<DateTime?> contractStart = const Value.absent(),
            Value<DateTime?> nextRenewal = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ContractsCompanion.insert(
            id: id,
            name: name,
            category: category,
            provider: provider,
            contactPhone: contactPhone,
            contactEmail: contactEmail,
            contactUrl: contactUrl,
            cancellationMethod: cancellationMethod,
            cancellationInstructions: cancellationInstructions,
            noticePeriod: noticePeriod,
            monthlyCost: monthlyCost,
            billingCycle: billingCycle,
            documentPath: documentPath,
            notes: notes,
            contractStart: contractStart,
            nextRenewal: nextRenewal,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ContractsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ContractsTable,
    Contract,
    $$ContractsTableFilterComposer,
    $$ContractsTableOrderingComposer,
    $$ContractsTableAnnotationComposer,
    $$ContractsTableCreateCompanionBuilder,
    $$ContractsTableUpdateCompanionBuilder,
    (Contract, BaseReferences<_$AppDatabase, $ContractsTable, Contract>),
    Contract,
    PrefetchHooks Function()>;
typedef $$HeirsTableCreateCompanionBuilder = HeirsCompanion Function({
  Value<String> id,
  required String name,
  required String email,
  required String pinHash,
  Value<HeirAccess> accessLevel,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$HeirsTableUpdateCompanionBuilder = HeirsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> email,
  Value<String> pinHash,
  Value<HeirAccess> accessLevel,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$HeirsTableFilterComposer extends Composer<_$AppDatabase, $HeirsTable> {
  $$HeirsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pinHash => $composableBuilder(
      column: $table.pinHash, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<HeirAccess, HeirAccess, String>
      get accessLevel => $composableBuilder(
          column: $table.accessLevel,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$HeirsTableOrderingComposer
    extends Composer<_$AppDatabase, $HeirsTable> {
  $$HeirsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pinHash => $composableBuilder(
      column: $table.pinHash, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get accessLevel => $composableBuilder(
      column: $table.accessLevel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$HeirsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HeirsTable> {
  $$HeirsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get pinHash =>
      $composableBuilder(column: $table.pinHash, builder: (column) => column);

  GeneratedColumnWithTypeConverter<HeirAccess, String> get accessLevel =>
      $composableBuilder(
          column: $table.accessLevel, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$HeirsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $HeirsTable,
    Heir,
    $$HeirsTableFilterComposer,
    $$HeirsTableOrderingComposer,
    $$HeirsTableAnnotationComposer,
    $$HeirsTableCreateCompanionBuilder,
    $$HeirsTableUpdateCompanionBuilder,
    (Heir, BaseReferences<_$AppDatabase, $HeirsTable, Heir>),
    Heir,
    PrefetchHooks Function()> {
  $$HeirsTableTableManager(_$AppDatabase db, $HeirsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HeirsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HeirsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HeirsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> email = const Value.absent(),
            Value<String> pinHash = const Value.absent(),
            Value<HeirAccess> accessLevel = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              HeirsCompanion(
            id: id,
            name: name,
            email: email,
            pinHash: pinHash,
            accessLevel: accessLevel,
            isActive: isActive,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String> id = const Value.absent(),
            required String name,
            required String email,
            required String pinHash,
            Value<HeirAccess> accessLevel = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              HeirsCompanion.insert(
            id: id,
            name: name,
            email: email,
            pinHash: pinHash,
            accessLevel: accessLevel,
            isActive: isActive,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$HeirsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $HeirsTable,
    Heir,
    $$HeirsTableFilterComposer,
    $$HeirsTableOrderingComposer,
    $$HeirsTableAnnotationComposer,
    $$HeirsTableCreateCompanionBuilder,
    $$HeirsTableUpdateCompanionBuilder,
    (Heir, BaseReferences<_$AppDatabase, $HeirsTable, Heir>),
    Heir,
    PrefetchHooks Function()>;
typedef $$ProviderLibraryTableCreateCompanionBuilder = ProviderLibraryCompanion
    Function({
  Value<String> id,
  required String name,
  Value<ContractCategory> category,
  required String provider,
  Value<String?> contactPhone,
  Value<String?> contactEmail,
  Value<String?> contactUrl,
  Value<CancellationMethod> cancellationMethod,
  Value<String> cancellationInstructions,
  Value<String> noticePeriod,
  Value<int> rowid,
});
typedef $$ProviderLibraryTableUpdateCompanionBuilder = ProviderLibraryCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<ContractCategory> category,
  Value<String> provider,
  Value<String?> contactPhone,
  Value<String?> contactEmail,
  Value<String?> contactUrl,
  Value<CancellationMethod> cancellationMethod,
  Value<String> cancellationInstructions,
  Value<String> noticePeriod,
  Value<int> rowid,
});

class $$ProviderLibraryTableFilterComposer
    extends Composer<_$AppDatabase, $ProviderLibraryTable> {
  $$ProviderLibraryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<ContractCategory, ContractCategory, String>
      get category => $composableBuilder(
          column: $table.category,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get provider => $composableBuilder(
      column: $table.provider, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contactPhone => $composableBuilder(
      column: $table.contactPhone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contactEmail => $composableBuilder(
      column: $table.contactEmail, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contactUrl => $composableBuilder(
      column: $table.contactUrl, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<CancellationMethod, CancellationMethod, String>
      get cancellationMethod => $composableBuilder(
          column: $table.cancellationMethod,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get cancellationInstructions => $composableBuilder(
      column: $table.cancellationInstructions,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get noticePeriod => $composableBuilder(
      column: $table.noticePeriod, builder: (column) => ColumnFilters(column));
}

class $$ProviderLibraryTableOrderingComposer
    extends Composer<_$AppDatabase, $ProviderLibraryTable> {
  $$ProviderLibraryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get provider => $composableBuilder(
      column: $table.provider, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contactPhone => $composableBuilder(
      column: $table.contactPhone,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contactEmail => $composableBuilder(
      column: $table.contactEmail,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contactUrl => $composableBuilder(
      column: $table.contactUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cancellationMethod => $composableBuilder(
      column: $table.cancellationMethod,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cancellationInstructions => $composableBuilder(
      column: $table.cancellationInstructions,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get noticePeriod => $composableBuilder(
      column: $table.noticePeriod,
      builder: (column) => ColumnOrderings(column));
}

class $$ProviderLibraryTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProviderLibraryTable> {
  $$ProviderLibraryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ContractCategory, String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<String> get contactPhone => $composableBuilder(
      column: $table.contactPhone, builder: (column) => column);

  GeneratedColumn<String> get contactEmail => $composableBuilder(
      column: $table.contactEmail, builder: (column) => column);

  GeneratedColumn<String> get contactUrl => $composableBuilder(
      column: $table.contactUrl, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CancellationMethod, String>
      get cancellationMethod => $composableBuilder(
          column: $table.cancellationMethod, builder: (column) => column);

  GeneratedColumn<String> get cancellationInstructions => $composableBuilder(
      column: $table.cancellationInstructions, builder: (column) => column);

  GeneratedColumn<String> get noticePeriod => $composableBuilder(
      column: $table.noticePeriod, builder: (column) => column);
}

class $$ProviderLibraryTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProviderLibraryTable,
    ProviderLibraryData,
    $$ProviderLibraryTableFilterComposer,
    $$ProviderLibraryTableOrderingComposer,
    $$ProviderLibraryTableAnnotationComposer,
    $$ProviderLibraryTableCreateCompanionBuilder,
    $$ProviderLibraryTableUpdateCompanionBuilder,
    (
      ProviderLibraryData,
      BaseReferences<_$AppDatabase, $ProviderLibraryTable, ProviderLibraryData>
    ),
    ProviderLibraryData,
    PrefetchHooks Function()> {
  $$ProviderLibraryTableTableManager(
      _$AppDatabase db, $ProviderLibraryTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProviderLibraryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProviderLibraryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProviderLibraryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<ContractCategory> category = const Value.absent(),
            Value<String> provider = const Value.absent(),
            Value<String?> contactPhone = const Value.absent(),
            Value<String?> contactEmail = const Value.absent(),
            Value<String?> contactUrl = const Value.absent(),
            Value<CancellationMethod> cancellationMethod = const Value.absent(),
            Value<String> cancellationInstructions = const Value.absent(),
            Value<String> noticePeriod = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProviderLibraryCompanion(
            id: id,
            name: name,
            category: category,
            provider: provider,
            contactPhone: contactPhone,
            contactEmail: contactEmail,
            contactUrl: contactUrl,
            cancellationMethod: cancellationMethod,
            cancellationInstructions: cancellationInstructions,
            noticePeriod: noticePeriod,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String> id = const Value.absent(),
            required String name,
            Value<ContractCategory> category = const Value.absent(),
            required String provider,
            Value<String?> contactPhone = const Value.absent(),
            Value<String?> contactEmail = const Value.absent(),
            Value<String?> contactUrl = const Value.absent(),
            Value<CancellationMethod> cancellationMethod = const Value.absent(),
            Value<String> cancellationInstructions = const Value.absent(),
            Value<String> noticePeriod = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProviderLibraryCompanion.insert(
            id: id,
            name: name,
            category: category,
            provider: provider,
            contactPhone: contactPhone,
            contactEmail: contactEmail,
            contactUrl: contactUrl,
            cancellationMethod: cancellationMethod,
            cancellationInstructions: cancellationInstructions,
            noticePeriod: noticePeriod,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ProviderLibraryTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProviderLibraryTable,
    ProviderLibraryData,
    $$ProviderLibraryTableFilterComposer,
    $$ProviderLibraryTableOrderingComposer,
    $$ProviderLibraryTableAnnotationComposer,
    $$ProviderLibraryTableCreateCompanionBuilder,
    $$ProviderLibraryTableUpdateCompanionBuilder,
    (
      ProviderLibraryData,
      BaseReferences<_$AppDatabase, $ProviderLibraryTable, ProviderLibraryData>
    ),
    ProviderLibraryData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ContractsTableTableManager get contracts =>
      $$ContractsTableTableManager(_db, _db.contracts);
  $$HeirsTableTableManager get heirs =>
      $$HeirsTableTableManager(_db, _db.heirs);
  $$ProviderLibraryTableTableManager get providerLibrary =>
      $$ProviderLibraryTableTableManager(_db, _db.providerLibrary);
}
