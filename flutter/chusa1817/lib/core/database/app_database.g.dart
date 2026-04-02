// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $HanjaTableTable extends HanjaTable
    with TableInfo<$HanjaTableTable, HanjaTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HanjaTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _characterMeta = const VerificationMeta(
    'character',
  );
  @override
  late final GeneratedColumn<String> character = GeneratedColumn<String>(
    'character',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _readingMeta = const VerificationMeta(
    'reading',
  );
  @override
  late final GeneratedColumn<String> reading = GeneratedColumn<String>(
    'reading',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _meaningMeta = const VerificationMeta(
    'meaning',
  );
  @override
  late final GeneratedColumn<String> meaning = GeneratedColumn<String>(
    'meaning',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _radicalMeta = const VerificationMeta(
    'radical',
  );
  @override
  late final GeneratedColumn<String> radical = GeneratedColumn<String>(
    'radical',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _radicalNameMeta = const VerificationMeta(
    'radicalName',
  );
  @override
  late final GeneratedColumn<String> radicalName = GeneratedColumn<String>(
    'radical_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalStrokesMeta = const VerificationMeta(
    'totalStrokes',
  );
  @override
  late final GeneratedColumn<int> totalStrokes = GeneratedColumn<int>(
    'total_strokes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _schoolLevelMeta = const VerificationMeta(
    'schoolLevel',
  );
  @override
  late final GeneratedColumn<String> schoolLevel = GeneratedColumn<String>(
    'school_level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gradeMeta = const VerificationMeta('grade');
  @override
  late final GeneratedColumn<int> grade = GeneratedColumn<int>(
    'grade',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
    'origin',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _usageNoteMeta = const VerificationMeta(
    'usageNote',
  );
  @override
  late final GeneratedColumn<String> usageNote = GeneratedColumn<String>(
    'usage_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local_only'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _syncRevisionMeta = const VerificationMeta(
    'syncRevision',
  );
  @override
  late final GeneratedColumn<int> syncRevision = GeneratedColumn<int>(
    'sync_revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    serverId,
    character,
    reading,
    meaning,
    radical,
    radicalName,
    totalStrokes,
    schoolLevel,
    grade,
    origin,
    usageNote,
    syncStatus,
    createdAt,
    updatedAt,
    syncRevision,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hanja_basis';
  @override
  VerificationContext validateIntegrity(
    Insertable<HanjaTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('character')) {
      context.handle(
        _characterMeta,
        character.isAcceptableOrUnknown(data['character']!, _characterMeta),
      );
    } else if (isInserting) {
      context.missing(_characterMeta);
    }
    if (data.containsKey('reading')) {
      context.handle(
        _readingMeta,
        reading.isAcceptableOrUnknown(data['reading']!, _readingMeta),
      );
    } else if (isInserting) {
      context.missing(_readingMeta);
    }
    if (data.containsKey('meaning')) {
      context.handle(
        _meaningMeta,
        meaning.isAcceptableOrUnknown(data['meaning']!, _meaningMeta),
      );
    } else if (isInserting) {
      context.missing(_meaningMeta);
    }
    if (data.containsKey('radical')) {
      context.handle(
        _radicalMeta,
        radical.isAcceptableOrUnknown(data['radical']!, _radicalMeta),
      );
    } else if (isInserting) {
      context.missing(_radicalMeta);
    }
    if (data.containsKey('radical_name')) {
      context.handle(
        _radicalNameMeta,
        radicalName.isAcceptableOrUnknown(
          data['radical_name']!,
          _radicalNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_radicalNameMeta);
    }
    if (data.containsKey('total_strokes')) {
      context.handle(
        _totalStrokesMeta,
        totalStrokes.isAcceptableOrUnknown(
          data['total_strokes']!,
          _totalStrokesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalStrokesMeta);
    }
    if (data.containsKey('school_level')) {
      context.handle(
        _schoolLevelMeta,
        schoolLevel.isAcceptableOrUnknown(
          data['school_level']!,
          _schoolLevelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_schoolLevelMeta);
    }
    if (data.containsKey('grade')) {
      context.handle(
        _gradeMeta,
        grade.isAcceptableOrUnknown(data['grade']!, _gradeMeta),
      );
    }
    if (data.containsKey('origin')) {
      context.handle(
        _originMeta,
        origin.isAcceptableOrUnknown(data['origin']!, _originMeta),
      );
    }
    if (data.containsKey('usage_note')) {
      context.handle(
        _usageNoteMeta,
        usageNote.isAcceptableOrUnknown(data['usage_note']!, _usageNoteMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('sync_revision')) {
      context.handle(
        _syncRevisionMeta,
        syncRevision.isAcceptableOrUnknown(
          data['sync_revision']!,
          _syncRevisionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HanjaTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HanjaTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
      character: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}character'],
      )!,
      reading: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reading'],
      )!,
      meaning: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meaning'],
      )!,
      radical: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}radical'],
      )!,
      radicalName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}radical_name'],
      )!,
      totalStrokes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_strokes'],
      )!,
      schoolLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_level'],
      )!,
      grade: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}grade'],
      ),
      origin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin'],
      ),
      usageNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}usage_note'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_revision'],
      )!,
    );
  }

  @override
  $HanjaTableTable createAlias(String alias) {
    return $HanjaTableTable(attachedDatabase, alias);
  }
}

class HanjaTableData extends DataClass implements Insertable<HanjaTableData> {
  final String id;
  final String? serverId;
  final String character;
  final String reading;
  final String meaning;
  final String radical;
  final String radicalName;
  final int totalStrokes;
  final String schoolLevel;
  final int? grade;
  final String? origin;
  final String? usageNote;
  final String syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int syncRevision;
  const HanjaTableData({
    required this.id,
    this.serverId,
    required this.character,
    required this.reading,
    required this.meaning,
    required this.radical,
    required this.radicalName,
    required this.totalStrokes,
    required this.schoolLevel,
    this.grade,
    this.origin,
    this.usageNote,
    required this.syncStatus,
    required this.createdAt,
    required this.updatedAt,
    required this.syncRevision,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['character'] = Variable<String>(character);
    map['reading'] = Variable<String>(reading);
    map['meaning'] = Variable<String>(meaning);
    map['radical'] = Variable<String>(radical);
    map['radical_name'] = Variable<String>(radicalName);
    map['total_strokes'] = Variable<int>(totalStrokes);
    map['school_level'] = Variable<String>(schoolLevel);
    if (!nullToAbsent || grade != null) {
      map['grade'] = Variable<int>(grade);
    }
    if (!nullToAbsent || origin != null) {
      map['origin'] = Variable<String>(origin);
    }
    if (!nullToAbsent || usageNote != null) {
      map['usage_note'] = Variable<String>(usageNote);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_revision'] = Variable<int>(syncRevision);
    return map;
  }

  HanjaTableCompanion toCompanion(bool nullToAbsent) {
    return HanjaTableCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      character: Value(character),
      reading: Value(reading),
      meaning: Value(meaning),
      radical: Value(radical),
      radicalName: Value(radicalName),
      totalStrokes: Value(totalStrokes),
      schoolLevel: Value(schoolLevel),
      grade: grade == null && nullToAbsent
          ? const Value.absent()
          : Value(grade),
      origin: origin == null && nullToAbsent
          ? const Value.absent()
          : Value(origin),
      usageNote: usageNote == null && nullToAbsent
          ? const Value.absent()
          : Value(usageNote),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncRevision: Value(syncRevision),
    );
  }

  factory HanjaTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HanjaTableData(
      id: serializer.fromJson<String>(json['id']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      character: serializer.fromJson<String>(json['character']),
      reading: serializer.fromJson<String>(json['reading']),
      meaning: serializer.fromJson<String>(json['meaning']),
      radical: serializer.fromJson<String>(json['radical']),
      radicalName: serializer.fromJson<String>(json['radicalName']),
      totalStrokes: serializer.fromJson<int>(json['totalStrokes']),
      schoolLevel: serializer.fromJson<String>(json['schoolLevel']),
      grade: serializer.fromJson<int?>(json['grade']),
      origin: serializer.fromJson<String?>(json['origin']),
      usageNote: serializer.fromJson<String?>(json['usageNote']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncRevision: serializer.fromJson<int>(json['syncRevision']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'serverId': serializer.toJson<String?>(serverId),
      'character': serializer.toJson<String>(character),
      'reading': serializer.toJson<String>(reading),
      'meaning': serializer.toJson<String>(meaning),
      'radical': serializer.toJson<String>(radical),
      'radicalName': serializer.toJson<String>(radicalName),
      'totalStrokes': serializer.toJson<int>(totalStrokes),
      'schoolLevel': serializer.toJson<String>(schoolLevel),
      'grade': serializer.toJson<int?>(grade),
      'origin': serializer.toJson<String?>(origin),
      'usageNote': serializer.toJson<String?>(usageNote),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncRevision': serializer.toJson<int>(syncRevision),
    };
  }

  HanjaTableData copyWith({
    String? id,
    Value<String?> serverId = const Value.absent(),
    String? character,
    String? reading,
    String? meaning,
    String? radical,
    String? radicalName,
    int? totalStrokes,
    String? schoolLevel,
    Value<int?> grade = const Value.absent(),
    Value<String?> origin = const Value.absent(),
    Value<String?> usageNote = const Value.absent(),
    String? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? syncRevision,
  }) => HanjaTableData(
    id: id ?? this.id,
    serverId: serverId.present ? serverId.value : this.serverId,
    character: character ?? this.character,
    reading: reading ?? this.reading,
    meaning: meaning ?? this.meaning,
    radical: radical ?? this.radical,
    radicalName: radicalName ?? this.radicalName,
    totalStrokes: totalStrokes ?? this.totalStrokes,
    schoolLevel: schoolLevel ?? this.schoolLevel,
    grade: grade.present ? grade.value : this.grade,
    origin: origin.present ? origin.value : this.origin,
    usageNote: usageNote.present ? usageNote.value : this.usageNote,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncRevision: syncRevision ?? this.syncRevision,
  );
  HanjaTableData copyWithCompanion(HanjaTableCompanion data) {
    return HanjaTableData(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      character: data.character.present ? data.character.value : this.character,
      reading: data.reading.present ? data.reading.value : this.reading,
      meaning: data.meaning.present ? data.meaning.value : this.meaning,
      radical: data.radical.present ? data.radical.value : this.radical,
      radicalName: data.radicalName.present
          ? data.radicalName.value
          : this.radicalName,
      totalStrokes: data.totalStrokes.present
          ? data.totalStrokes.value
          : this.totalStrokes,
      schoolLevel: data.schoolLevel.present
          ? data.schoolLevel.value
          : this.schoolLevel,
      grade: data.grade.present ? data.grade.value : this.grade,
      origin: data.origin.present ? data.origin.value : this.origin,
      usageNote: data.usageNote.present ? data.usageNote.value : this.usageNote,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncRevision: data.syncRevision.present
          ? data.syncRevision.value
          : this.syncRevision,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HanjaTableData(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('character: $character, ')
          ..write('reading: $reading, ')
          ..write('meaning: $meaning, ')
          ..write('radical: $radical, ')
          ..write('radicalName: $radicalName, ')
          ..write('totalStrokes: $totalStrokes, ')
          ..write('schoolLevel: $schoolLevel, ')
          ..write('grade: $grade, ')
          ..write('origin: $origin, ')
          ..write('usageNote: $usageNote, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncRevision: $syncRevision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    serverId,
    character,
    reading,
    meaning,
    radical,
    radicalName,
    totalStrokes,
    schoolLevel,
    grade,
    origin,
    usageNote,
    syncStatus,
    createdAt,
    updatedAt,
    syncRevision,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HanjaTableData &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.character == this.character &&
          other.reading == this.reading &&
          other.meaning == this.meaning &&
          other.radical == this.radical &&
          other.radicalName == this.radicalName &&
          other.totalStrokes == this.totalStrokes &&
          other.schoolLevel == this.schoolLevel &&
          other.grade == this.grade &&
          other.origin == this.origin &&
          other.usageNote == this.usageNote &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncRevision == this.syncRevision);
}

class HanjaTableCompanion extends UpdateCompanion<HanjaTableData> {
  final Value<String> id;
  final Value<String?> serverId;
  final Value<String> character;
  final Value<String> reading;
  final Value<String> meaning;
  final Value<String> radical;
  final Value<String> radicalName;
  final Value<int> totalStrokes;
  final Value<String> schoolLevel;
  final Value<int?> grade;
  final Value<String?> origin;
  final Value<String?> usageNote;
  final Value<String> syncStatus;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> syncRevision;
  final Value<int> rowid;
  const HanjaTableCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.character = const Value.absent(),
    this.reading = const Value.absent(),
    this.meaning = const Value.absent(),
    this.radical = const Value.absent(),
    this.radicalName = const Value.absent(),
    this.totalStrokes = const Value.absent(),
    this.schoolLevel = const Value.absent(),
    this.grade = const Value.absent(),
    this.origin = const Value.absent(),
    this.usageNote = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncRevision = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HanjaTableCompanion.insert({
    required String id,
    this.serverId = const Value.absent(),
    required String character,
    required String reading,
    required String meaning,
    required String radical,
    required String radicalName,
    required int totalStrokes,
    required String schoolLevel,
    this.grade = const Value.absent(),
    this.origin = const Value.absent(),
    this.usageNote = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncRevision = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       character = Value(character),
       reading = Value(reading),
       meaning = Value(meaning),
       radical = Value(radical),
       radicalName = Value(radicalName),
       totalStrokes = Value(totalStrokes),
       schoolLevel = Value(schoolLevel);
  static Insertable<HanjaTableData> custom({
    Expression<String>? id,
    Expression<String>? serverId,
    Expression<String>? character,
    Expression<String>? reading,
    Expression<String>? meaning,
    Expression<String>? radical,
    Expression<String>? radicalName,
    Expression<int>? totalStrokes,
    Expression<String>? schoolLevel,
    Expression<int>? grade,
    Expression<String>? origin,
    Expression<String>? usageNote,
    Expression<String>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? syncRevision,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (character != null) 'character': character,
      if (reading != null) 'reading': reading,
      if (meaning != null) 'meaning': meaning,
      if (radical != null) 'radical': radical,
      if (radicalName != null) 'radical_name': radicalName,
      if (totalStrokes != null) 'total_strokes': totalStrokes,
      if (schoolLevel != null) 'school_level': schoolLevel,
      if (grade != null) 'grade': grade,
      if (origin != null) 'origin': origin,
      if (usageNote != null) 'usage_note': usageNote,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncRevision != null) 'sync_revision': syncRevision,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HanjaTableCompanion copyWith({
    Value<String>? id,
    Value<String?>? serverId,
    Value<String>? character,
    Value<String>? reading,
    Value<String>? meaning,
    Value<String>? radical,
    Value<String>? radicalName,
    Value<int>? totalStrokes,
    Value<String>? schoolLevel,
    Value<int?>? grade,
    Value<String?>? origin,
    Value<String?>? usageNote,
    Value<String>? syncStatus,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? syncRevision,
    Value<int>? rowid,
  }) {
    return HanjaTableCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      character: character ?? this.character,
      reading: reading ?? this.reading,
      meaning: meaning ?? this.meaning,
      radical: radical ?? this.radical,
      radicalName: radicalName ?? this.radicalName,
      totalStrokes: totalStrokes ?? this.totalStrokes,
      schoolLevel: schoolLevel ?? this.schoolLevel,
      grade: grade ?? this.grade,
      origin: origin ?? this.origin,
      usageNote: usageNote ?? this.usageNote,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncRevision: syncRevision ?? this.syncRevision,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (character.present) {
      map['character'] = Variable<String>(character.value);
    }
    if (reading.present) {
      map['reading'] = Variable<String>(reading.value);
    }
    if (meaning.present) {
      map['meaning'] = Variable<String>(meaning.value);
    }
    if (radical.present) {
      map['radical'] = Variable<String>(radical.value);
    }
    if (radicalName.present) {
      map['radical_name'] = Variable<String>(radicalName.value);
    }
    if (totalStrokes.present) {
      map['total_strokes'] = Variable<int>(totalStrokes.value);
    }
    if (schoolLevel.present) {
      map['school_level'] = Variable<String>(schoolLevel.value);
    }
    if (grade.present) {
      map['grade'] = Variable<int>(grade.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (usageNote.present) {
      map['usage_note'] = Variable<String>(usageNote.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncRevision.present) {
      map['sync_revision'] = Variable<int>(syncRevision.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HanjaTableCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('character: $character, ')
          ..write('reading: $reading, ')
          ..write('meaning: $meaning, ')
          ..write('radical: $radical, ')
          ..write('radicalName: $radicalName, ')
          ..write('totalStrokes: $totalStrokes, ')
          ..write('schoolLevel: $schoolLevel, ')
          ..write('grade: $grade, ')
          ..write('origin: $origin, ')
          ..write('usageNote: $usageNote, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncRevision: $syncRevision, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HanjaExtendTableTable extends HanjaExtendTable
    with TableInfo<$HanjaExtendTableTable, HanjaExtendTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HanjaExtendTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, payloadJson, syncedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hanja_extend';
  @override
  VerificationContext validateIntegrity(
    Insertable<HanjaExtendTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HanjaExtendTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HanjaExtendTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      )!,
    );
  }

  @override
  $HanjaExtendTableTable createAlias(String alias) {
    return $HanjaExtendTableTable(attachedDatabase, alias);
  }
}

class HanjaExtendTableData extends DataClass
    implements Insertable<HanjaExtendTableData> {
  final String id;
  final String payloadJson;
  final DateTime syncedAt;
  const HanjaExtendTableData({
    required this.id,
    required this.payloadJson,
    required this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['payload_json'] = Variable<String>(payloadJson);
    map['synced_at'] = Variable<DateTime>(syncedAt);
    return map;
  }

  HanjaExtendTableCompanion toCompanion(bool nullToAbsent) {
    return HanjaExtendTableCompanion(
      id: Value(id),
      payloadJson: Value(payloadJson),
      syncedAt: Value(syncedAt),
    );
  }

  factory HanjaExtendTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HanjaExtendTableData(
      id: serializer.fromJson<String>(json['id']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      syncedAt: serializer.fromJson<DateTime>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'syncedAt': serializer.toJson<DateTime>(syncedAt),
    };
  }

  HanjaExtendTableData copyWith({
    String? id,
    String? payloadJson,
    DateTime? syncedAt,
  }) => HanjaExtendTableData(
    id: id ?? this.id,
    payloadJson: payloadJson ?? this.payloadJson,
    syncedAt: syncedAt ?? this.syncedAt,
  );
  HanjaExtendTableData copyWithCompanion(HanjaExtendTableCompanion data) {
    return HanjaExtendTableData(
      id: data.id.present ? data.id.value : this.id,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HanjaExtendTableData(')
          ..write('id: $id, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, payloadJson, syncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HanjaExtendTableData &&
          other.id == this.id &&
          other.payloadJson == this.payloadJson &&
          other.syncedAt == this.syncedAt);
}

class HanjaExtendTableCompanion extends UpdateCompanion<HanjaExtendTableData> {
  final Value<String> id;
  final Value<String> payloadJson;
  final Value<DateTime> syncedAt;
  final Value<int> rowid;
  const HanjaExtendTableCompanion({
    this.id = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HanjaExtendTableCompanion.insert({
    required String id,
    required String payloadJson,
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       payloadJson = Value(payloadJson);
  static Insertable<HanjaExtendTableData> custom({
    Expression<String>? id,
    Expression<String>? payloadJson,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HanjaExtendTableCompanion copyWith({
    Value<String>? id,
    Value<String>? payloadJson,
    Value<DateTime>? syncedAt,
    Value<int>? rowid,
  }) {
    return HanjaExtendTableCompanion(
      id: id ?? this.id,
      payloadJson: payloadJson ?? this.payloadJson,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HanjaExtendTableCompanion(')
          ..write('id: $id, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ContentConfigTableTable extends ContentConfigTable
    with TableInfo<$ContentConfigTableTable, ContentConfigTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContentConfigTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentVersionMeta = const VerificationMeta(
    'contentVersion',
  );
  @override
  late final GeneratedColumn<int> contentVersion = GeneratedColumn<int>(
    'content_version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, contentVersion, syncedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'content_config';
  @override
  VerificationContext validateIntegrity(
    Insertable<ContentConfigTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('content_version')) {
      context.handle(
        _contentVersionMeta,
        contentVersion.isAcceptableOrUnknown(
          data['content_version']!,
          _contentVersionMeta,
        ),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ContentConfigTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContentConfigTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      contentVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}content_version'],
      ),
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      )!,
    );
  }

  @override
  $ContentConfigTableTable createAlias(String alias) {
    return $ContentConfigTableTable(attachedDatabase, alias);
  }
}

class ContentConfigTableData extends DataClass
    implements Insertable<ContentConfigTableData> {
  /// 고정 키 `content` (Firestore 경로 `config/content` 와 대응).
  final String id;
  final int? contentVersion;
  final DateTime syncedAt;
  const ContentConfigTableData({
    required this.id,
    this.contentVersion,
    required this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || contentVersion != null) {
      map['content_version'] = Variable<int>(contentVersion);
    }
    map['synced_at'] = Variable<DateTime>(syncedAt);
    return map;
  }

  ContentConfigTableCompanion toCompanion(bool nullToAbsent) {
    return ContentConfigTableCompanion(
      id: Value(id),
      contentVersion: contentVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(contentVersion),
      syncedAt: Value(syncedAt),
    );
  }

  factory ContentConfigTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContentConfigTableData(
      id: serializer.fromJson<String>(json['id']),
      contentVersion: serializer.fromJson<int?>(json['contentVersion']),
      syncedAt: serializer.fromJson<DateTime>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'contentVersion': serializer.toJson<int?>(contentVersion),
      'syncedAt': serializer.toJson<DateTime>(syncedAt),
    };
  }

  ContentConfigTableData copyWith({
    String? id,
    Value<int?> contentVersion = const Value.absent(),
    DateTime? syncedAt,
  }) => ContentConfigTableData(
    id: id ?? this.id,
    contentVersion: contentVersion.present
        ? contentVersion.value
        : this.contentVersion,
    syncedAt: syncedAt ?? this.syncedAt,
  );
  ContentConfigTableData copyWithCompanion(ContentConfigTableCompanion data) {
    return ContentConfigTableData(
      id: data.id.present ? data.id.value : this.id,
      contentVersion: data.contentVersion.present
          ? data.contentVersion.value
          : this.contentVersion,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContentConfigTableData(')
          ..write('id: $id, ')
          ..write('contentVersion: $contentVersion, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, contentVersion, syncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContentConfigTableData &&
          other.id == this.id &&
          other.contentVersion == this.contentVersion &&
          other.syncedAt == this.syncedAt);
}

class ContentConfigTableCompanion
    extends UpdateCompanion<ContentConfigTableData> {
  final Value<String> id;
  final Value<int?> contentVersion;
  final Value<DateTime> syncedAt;
  final Value<int> rowid;
  const ContentConfigTableCompanion({
    this.id = const Value.absent(),
    this.contentVersion = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContentConfigTableCompanion.insert({
    required String id,
    this.contentVersion = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<ContentConfigTableData> custom({
    Expression<String>? id,
    Expression<int>? contentVersion,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (contentVersion != null) 'content_version': contentVersion,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContentConfigTableCompanion copyWith({
    Value<String>? id,
    Value<int?>? contentVersion,
    Value<DateTime>? syncedAt,
    Value<int>? rowid,
  }) {
    return ContentConfigTableCompanion(
      id: id ?? this.id,
      contentVersion: contentVersion ?? this.contentVersion,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (contentVersion.present) {
      map['content_version'] = Variable<int>(contentVersion.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContentConfigTableCompanion(')
          ..write('id: $id, ')
          ..write('contentVersion: $contentVersion, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HanjaStrokeTableTable extends HanjaStrokeTable
    with TableInfo<$HanjaStrokeTableTable, HanjaStrokeTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HanjaStrokeTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hanjaIdMeta = const VerificationMeta(
    'hanjaId',
  );
  @override
  late final GeneratedColumn<String> hanjaId = GeneratedColumn<String>(
    'hanja_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _strokeIndexMeta = const VerificationMeta(
    'strokeIndex',
  );
  @override
  late final GeneratedColumn<int> strokeIndex = GeneratedColumn<int>(
    'stroke_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _normalizedPointsMeta = const VerificationMeta(
    'normalizedPoints',
  );
  @override
  late final GeneratedColumn<String> normalizedPoints = GeneratedColumn<String>(
    'normalized_points',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _directionMeta = const VerificationMeta(
    'direction',
  );
  @override
  late final GeneratedColumn<String> direction = GeneratedColumn<String>(
    'direction',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    hanjaId,
    strokeIndex,
    normalizedPoints,
    direction,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hanja_stroke';
  @override
  VerificationContext validateIntegrity(
    Insertable<HanjaStrokeTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('hanja_id')) {
      context.handle(
        _hanjaIdMeta,
        hanjaId.isAcceptableOrUnknown(data['hanja_id']!, _hanjaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_hanjaIdMeta);
    }
    if (data.containsKey('stroke_index')) {
      context.handle(
        _strokeIndexMeta,
        strokeIndex.isAcceptableOrUnknown(
          data['stroke_index']!,
          _strokeIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_strokeIndexMeta);
    }
    if (data.containsKey('normalized_points')) {
      context.handle(
        _normalizedPointsMeta,
        normalizedPoints.isAcceptableOrUnknown(
          data['normalized_points']!,
          _normalizedPointsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedPointsMeta);
    }
    if (data.containsKey('direction')) {
      context.handle(
        _directionMeta,
        direction.isAcceptableOrUnknown(data['direction']!, _directionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HanjaStrokeTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HanjaStrokeTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      hanjaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hanja_id'],
      )!,
      strokeIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stroke_index'],
      )!,
      normalizedPoints: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_points'],
      )!,
      direction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direction'],
      ),
    );
  }

  @override
  $HanjaStrokeTableTable createAlias(String alias) {
    return $HanjaStrokeTableTable(attachedDatabase, alias);
  }
}

class HanjaStrokeTableData extends DataClass
    implements Insertable<HanjaStrokeTableData> {
  final String id;
  final String hanjaId;
  final int strokeIndex;
  final String normalizedPoints;
  final String? direction;
  const HanjaStrokeTableData({
    required this.id,
    required this.hanjaId,
    required this.strokeIndex,
    required this.normalizedPoints,
    this.direction,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['hanja_id'] = Variable<String>(hanjaId);
    map['stroke_index'] = Variable<int>(strokeIndex);
    map['normalized_points'] = Variable<String>(normalizedPoints);
    if (!nullToAbsent || direction != null) {
      map['direction'] = Variable<String>(direction);
    }
    return map;
  }

  HanjaStrokeTableCompanion toCompanion(bool nullToAbsent) {
    return HanjaStrokeTableCompanion(
      id: Value(id),
      hanjaId: Value(hanjaId),
      strokeIndex: Value(strokeIndex),
      normalizedPoints: Value(normalizedPoints),
      direction: direction == null && nullToAbsent
          ? const Value.absent()
          : Value(direction),
    );
  }

  factory HanjaStrokeTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HanjaStrokeTableData(
      id: serializer.fromJson<String>(json['id']),
      hanjaId: serializer.fromJson<String>(json['hanjaId']),
      strokeIndex: serializer.fromJson<int>(json['strokeIndex']),
      normalizedPoints: serializer.fromJson<String>(json['normalizedPoints']),
      direction: serializer.fromJson<String?>(json['direction']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'hanjaId': serializer.toJson<String>(hanjaId),
      'strokeIndex': serializer.toJson<int>(strokeIndex),
      'normalizedPoints': serializer.toJson<String>(normalizedPoints),
      'direction': serializer.toJson<String?>(direction),
    };
  }

  HanjaStrokeTableData copyWith({
    String? id,
    String? hanjaId,
    int? strokeIndex,
    String? normalizedPoints,
    Value<String?> direction = const Value.absent(),
  }) => HanjaStrokeTableData(
    id: id ?? this.id,
    hanjaId: hanjaId ?? this.hanjaId,
    strokeIndex: strokeIndex ?? this.strokeIndex,
    normalizedPoints: normalizedPoints ?? this.normalizedPoints,
    direction: direction.present ? direction.value : this.direction,
  );
  HanjaStrokeTableData copyWithCompanion(HanjaStrokeTableCompanion data) {
    return HanjaStrokeTableData(
      id: data.id.present ? data.id.value : this.id,
      hanjaId: data.hanjaId.present ? data.hanjaId.value : this.hanjaId,
      strokeIndex: data.strokeIndex.present
          ? data.strokeIndex.value
          : this.strokeIndex,
      normalizedPoints: data.normalizedPoints.present
          ? data.normalizedPoints.value
          : this.normalizedPoints,
      direction: data.direction.present ? data.direction.value : this.direction,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HanjaStrokeTableData(')
          ..write('id: $id, ')
          ..write('hanjaId: $hanjaId, ')
          ..write('strokeIndex: $strokeIndex, ')
          ..write('normalizedPoints: $normalizedPoints, ')
          ..write('direction: $direction')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, hanjaId, strokeIndex, normalizedPoints, direction);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HanjaStrokeTableData &&
          other.id == this.id &&
          other.hanjaId == this.hanjaId &&
          other.strokeIndex == this.strokeIndex &&
          other.normalizedPoints == this.normalizedPoints &&
          other.direction == this.direction);
}

class HanjaStrokeTableCompanion extends UpdateCompanion<HanjaStrokeTableData> {
  final Value<String> id;
  final Value<String> hanjaId;
  final Value<int> strokeIndex;
  final Value<String> normalizedPoints;
  final Value<String?> direction;
  final Value<int> rowid;
  const HanjaStrokeTableCompanion({
    this.id = const Value.absent(),
    this.hanjaId = const Value.absent(),
    this.strokeIndex = const Value.absent(),
    this.normalizedPoints = const Value.absent(),
    this.direction = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HanjaStrokeTableCompanion.insert({
    required String id,
    required String hanjaId,
    required int strokeIndex,
    required String normalizedPoints,
    this.direction = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       hanjaId = Value(hanjaId),
       strokeIndex = Value(strokeIndex),
       normalizedPoints = Value(normalizedPoints);
  static Insertable<HanjaStrokeTableData> custom({
    Expression<String>? id,
    Expression<String>? hanjaId,
    Expression<int>? strokeIndex,
    Expression<String>? normalizedPoints,
    Expression<String>? direction,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (hanjaId != null) 'hanja_id': hanjaId,
      if (strokeIndex != null) 'stroke_index': strokeIndex,
      if (normalizedPoints != null) 'normalized_points': normalizedPoints,
      if (direction != null) 'direction': direction,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HanjaStrokeTableCompanion copyWith({
    Value<String>? id,
    Value<String>? hanjaId,
    Value<int>? strokeIndex,
    Value<String>? normalizedPoints,
    Value<String?>? direction,
    Value<int>? rowid,
  }) {
    return HanjaStrokeTableCompanion(
      id: id ?? this.id,
      hanjaId: hanjaId ?? this.hanjaId,
      strokeIndex: strokeIndex ?? this.strokeIndex,
      normalizedPoints: normalizedPoints ?? this.normalizedPoints,
      direction: direction ?? this.direction,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (hanjaId.present) {
      map['hanja_id'] = Variable<String>(hanjaId.value);
    }
    if (strokeIndex.present) {
      map['stroke_index'] = Variable<int>(strokeIndex.value);
    }
    if (normalizedPoints.present) {
      map['normalized_points'] = Variable<String>(normalizedPoints.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(direction.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HanjaStrokeTableCompanion(')
          ..write('id: $id, ')
          ..write('hanjaId: $hanjaId, ')
          ..write('strokeIndex: $strokeIndex, ')
          ..write('normalizedPoints: $normalizedPoints, ')
          ..write('direction: $direction, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HanjaStrokeSvgPathsTableTable extends HanjaStrokeSvgPathsTable
    with
        TableInfo<
          $HanjaStrokeSvgPathsTableTable,
          HanjaStrokeSvgPathsTableData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HanjaStrokeSvgPathsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _hanjaIdMeta = const VerificationMeta(
    'hanjaId',
  );
  @override
  late final GeneratedColumn<String> hanjaId = GeneratedColumn<String>(
    'hanja_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pathsJsonMeta = const VerificationMeta(
    'pathsJson',
  );
  @override
  late final GeneratedColumn<String> pathsJson = GeneratedColumn<String>(
    'paths_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [hanjaId, pathsJson];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hanja_stroke_svg_paths';
  @override
  VerificationContext validateIntegrity(
    Insertable<HanjaStrokeSvgPathsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('hanja_id')) {
      context.handle(
        _hanjaIdMeta,
        hanjaId.isAcceptableOrUnknown(data['hanja_id']!, _hanjaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_hanjaIdMeta);
    }
    if (data.containsKey('paths_json')) {
      context.handle(
        _pathsJsonMeta,
        pathsJson.isAcceptableOrUnknown(data['paths_json']!, _pathsJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_pathsJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {hanjaId};
  @override
  HanjaStrokeSvgPathsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HanjaStrokeSvgPathsTableData(
      hanjaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hanja_id'],
      )!,
      pathsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}paths_json'],
      )!,
    );
  }

  @override
  $HanjaStrokeSvgPathsTableTable createAlias(String alias) {
    return $HanjaStrokeSvgPathsTableTable(attachedDatabase, alias);
  }
}

class HanjaStrokeSvgPathsTableData extends DataClass
    implements Insertable<HanjaStrokeSvgPathsTableData> {
  final String hanjaId;
  final String pathsJson;
  const HanjaStrokeSvgPathsTableData({
    required this.hanjaId,
    required this.pathsJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['hanja_id'] = Variable<String>(hanjaId);
    map['paths_json'] = Variable<String>(pathsJson);
    return map;
  }

  HanjaStrokeSvgPathsTableCompanion toCompanion(bool nullToAbsent) {
    return HanjaStrokeSvgPathsTableCompanion(
      hanjaId: Value(hanjaId),
      pathsJson: Value(pathsJson),
    );
  }

  factory HanjaStrokeSvgPathsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HanjaStrokeSvgPathsTableData(
      hanjaId: serializer.fromJson<String>(json['hanjaId']),
      pathsJson: serializer.fromJson<String>(json['pathsJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'hanjaId': serializer.toJson<String>(hanjaId),
      'pathsJson': serializer.toJson<String>(pathsJson),
    };
  }

  HanjaStrokeSvgPathsTableData copyWith({String? hanjaId, String? pathsJson}) =>
      HanjaStrokeSvgPathsTableData(
        hanjaId: hanjaId ?? this.hanjaId,
        pathsJson: pathsJson ?? this.pathsJson,
      );
  HanjaStrokeSvgPathsTableData copyWithCompanion(
    HanjaStrokeSvgPathsTableCompanion data,
  ) {
    return HanjaStrokeSvgPathsTableData(
      hanjaId: data.hanjaId.present ? data.hanjaId.value : this.hanjaId,
      pathsJson: data.pathsJson.present ? data.pathsJson.value : this.pathsJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HanjaStrokeSvgPathsTableData(')
          ..write('hanjaId: $hanjaId, ')
          ..write('pathsJson: $pathsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(hanjaId, pathsJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HanjaStrokeSvgPathsTableData &&
          other.hanjaId == this.hanjaId &&
          other.pathsJson == this.pathsJson);
}

class HanjaStrokeSvgPathsTableCompanion
    extends UpdateCompanion<HanjaStrokeSvgPathsTableData> {
  final Value<String> hanjaId;
  final Value<String> pathsJson;
  final Value<int> rowid;
  const HanjaStrokeSvgPathsTableCompanion({
    this.hanjaId = const Value.absent(),
    this.pathsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HanjaStrokeSvgPathsTableCompanion.insert({
    required String hanjaId,
    required String pathsJson,
    this.rowid = const Value.absent(),
  }) : hanjaId = Value(hanjaId),
       pathsJson = Value(pathsJson);
  static Insertable<HanjaStrokeSvgPathsTableData> custom({
    Expression<String>? hanjaId,
    Expression<String>? pathsJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (hanjaId != null) 'hanja_id': hanjaId,
      if (pathsJson != null) 'paths_json': pathsJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HanjaStrokeSvgPathsTableCompanion copyWith({
    Value<String>? hanjaId,
    Value<String>? pathsJson,
    Value<int>? rowid,
  }) {
    return HanjaStrokeSvgPathsTableCompanion(
      hanjaId: hanjaId ?? this.hanjaId,
      pathsJson: pathsJson ?? this.pathsJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (hanjaId.present) {
      map['hanja_id'] = Variable<String>(hanjaId.value);
    }
    if (pathsJson.present) {
      map['paths_json'] = Variable<String>(pathsJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HanjaStrokeSvgPathsTableCompanion(')
          ..write('hanjaId: $hanjaId, ')
          ..write('pathsJson: $pathsJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HanjaWordTableTable extends HanjaWordTable
    with TableInfo<$HanjaWordTableTable, HanjaWordTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HanjaWordTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hanjaIdMeta = const VerificationMeta(
    'hanjaId',
  );
  @override
  late final GeneratedColumn<String> hanjaId = GeneratedColumn<String>(
    'hanja_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wordMeta = const VerificationMeta('word');
  @override
  late final GeneratedColumn<String> word = GeneratedColumn<String>(
    'word',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _readingMeta = const VerificationMeta(
    'reading',
  );
  @override
  late final GeneratedColumn<String> reading = GeneratedColumn<String>(
    'reading',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _meaningMeta = const VerificationMeta(
    'meaning',
  );
  @override
  late final GeneratedColumn<String> meaning = GeneratedColumn<String>(
    'meaning',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exampleMeta = const VerificationMeta(
    'example',
  );
  @override
  late final GeneratedColumn<String> example = GeneratedColumn<String>(
    'example',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    hanjaId,
    word,
    reading,
    meaning,
    example,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hanja_word';
  @override
  VerificationContext validateIntegrity(
    Insertable<HanjaWordTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('hanja_id')) {
      context.handle(
        _hanjaIdMeta,
        hanjaId.isAcceptableOrUnknown(data['hanja_id']!, _hanjaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_hanjaIdMeta);
    }
    if (data.containsKey('word')) {
      context.handle(
        _wordMeta,
        word.isAcceptableOrUnknown(data['word']!, _wordMeta),
      );
    } else if (isInserting) {
      context.missing(_wordMeta);
    }
    if (data.containsKey('reading')) {
      context.handle(
        _readingMeta,
        reading.isAcceptableOrUnknown(data['reading']!, _readingMeta),
      );
    } else if (isInserting) {
      context.missing(_readingMeta);
    }
    if (data.containsKey('meaning')) {
      context.handle(
        _meaningMeta,
        meaning.isAcceptableOrUnknown(data['meaning']!, _meaningMeta),
      );
    } else if (isInserting) {
      context.missing(_meaningMeta);
    }
    if (data.containsKey('example')) {
      context.handle(
        _exampleMeta,
        example.isAcceptableOrUnknown(data['example']!, _exampleMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HanjaWordTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HanjaWordTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      hanjaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hanja_id'],
      )!,
      word: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}word'],
      )!,
      reading: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reading'],
      )!,
      meaning: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meaning'],
      )!,
      example: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}example'],
      ),
    );
  }

  @override
  $HanjaWordTableTable createAlias(String alias) {
    return $HanjaWordTableTable(attachedDatabase, alias);
  }
}

class HanjaWordTableData extends DataClass
    implements Insertable<HanjaWordTableData> {
  final String id;
  final String hanjaId;
  final String word;
  final String reading;
  final String meaning;
  final String? example;
  const HanjaWordTableData({
    required this.id,
    required this.hanjaId,
    required this.word,
    required this.reading,
    required this.meaning,
    this.example,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['hanja_id'] = Variable<String>(hanjaId);
    map['word'] = Variable<String>(word);
    map['reading'] = Variable<String>(reading);
    map['meaning'] = Variable<String>(meaning);
    if (!nullToAbsent || example != null) {
      map['example'] = Variable<String>(example);
    }
    return map;
  }

  HanjaWordTableCompanion toCompanion(bool nullToAbsent) {
    return HanjaWordTableCompanion(
      id: Value(id),
      hanjaId: Value(hanjaId),
      word: Value(word),
      reading: Value(reading),
      meaning: Value(meaning),
      example: example == null && nullToAbsent
          ? const Value.absent()
          : Value(example),
    );
  }

  factory HanjaWordTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HanjaWordTableData(
      id: serializer.fromJson<String>(json['id']),
      hanjaId: serializer.fromJson<String>(json['hanjaId']),
      word: serializer.fromJson<String>(json['word']),
      reading: serializer.fromJson<String>(json['reading']),
      meaning: serializer.fromJson<String>(json['meaning']),
      example: serializer.fromJson<String?>(json['example']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'hanjaId': serializer.toJson<String>(hanjaId),
      'word': serializer.toJson<String>(word),
      'reading': serializer.toJson<String>(reading),
      'meaning': serializer.toJson<String>(meaning),
      'example': serializer.toJson<String?>(example),
    };
  }

  HanjaWordTableData copyWith({
    String? id,
    String? hanjaId,
    String? word,
    String? reading,
    String? meaning,
    Value<String?> example = const Value.absent(),
  }) => HanjaWordTableData(
    id: id ?? this.id,
    hanjaId: hanjaId ?? this.hanjaId,
    word: word ?? this.word,
    reading: reading ?? this.reading,
    meaning: meaning ?? this.meaning,
    example: example.present ? example.value : this.example,
  );
  HanjaWordTableData copyWithCompanion(HanjaWordTableCompanion data) {
    return HanjaWordTableData(
      id: data.id.present ? data.id.value : this.id,
      hanjaId: data.hanjaId.present ? data.hanjaId.value : this.hanjaId,
      word: data.word.present ? data.word.value : this.word,
      reading: data.reading.present ? data.reading.value : this.reading,
      meaning: data.meaning.present ? data.meaning.value : this.meaning,
      example: data.example.present ? data.example.value : this.example,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HanjaWordTableData(')
          ..write('id: $id, ')
          ..write('hanjaId: $hanjaId, ')
          ..write('word: $word, ')
          ..write('reading: $reading, ')
          ..write('meaning: $meaning, ')
          ..write('example: $example')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, hanjaId, word, reading, meaning, example);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HanjaWordTableData &&
          other.id == this.id &&
          other.hanjaId == this.hanjaId &&
          other.word == this.word &&
          other.reading == this.reading &&
          other.meaning == this.meaning &&
          other.example == this.example);
}

class HanjaWordTableCompanion extends UpdateCompanion<HanjaWordTableData> {
  final Value<String> id;
  final Value<String> hanjaId;
  final Value<String> word;
  final Value<String> reading;
  final Value<String> meaning;
  final Value<String?> example;
  final Value<int> rowid;
  const HanjaWordTableCompanion({
    this.id = const Value.absent(),
    this.hanjaId = const Value.absent(),
    this.word = const Value.absent(),
    this.reading = const Value.absent(),
    this.meaning = const Value.absent(),
    this.example = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HanjaWordTableCompanion.insert({
    required String id,
    required String hanjaId,
    required String word,
    required String reading,
    required String meaning,
    this.example = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       hanjaId = Value(hanjaId),
       word = Value(word),
       reading = Value(reading),
       meaning = Value(meaning);
  static Insertable<HanjaWordTableData> custom({
    Expression<String>? id,
    Expression<String>? hanjaId,
    Expression<String>? word,
    Expression<String>? reading,
    Expression<String>? meaning,
    Expression<String>? example,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (hanjaId != null) 'hanja_id': hanjaId,
      if (word != null) 'word': word,
      if (reading != null) 'reading': reading,
      if (meaning != null) 'meaning': meaning,
      if (example != null) 'example': example,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HanjaWordTableCompanion copyWith({
    Value<String>? id,
    Value<String>? hanjaId,
    Value<String>? word,
    Value<String>? reading,
    Value<String>? meaning,
    Value<String?>? example,
    Value<int>? rowid,
  }) {
    return HanjaWordTableCompanion(
      id: id ?? this.id,
      hanjaId: hanjaId ?? this.hanjaId,
      word: word ?? this.word,
      reading: reading ?? this.reading,
      meaning: meaning ?? this.meaning,
      example: example ?? this.example,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (hanjaId.present) {
      map['hanja_id'] = Variable<String>(hanjaId.value);
    }
    if (word.present) {
      map['word'] = Variable<String>(word.value);
    }
    if (reading.present) {
      map['reading'] = Variable<String>(reading.value);
    }
    if (meaning.present) {
      map['meaning'] = Variable<String>(meaning.value);
    }
    if (example.present) {
      map['example'] = Variable<String>(example.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HanjaWordTableCompanion(')
          ..write('id: $id, ')
          ..write('hanjaId: $hanjaId, ')
          ..write('word: $word, ')
          ..write('reading: $reading, ')
          ..write('meaning: $meaning, ')
          ..write('example: $example, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HanjaIdiomTableTable extends HanjaIdiomTable
    with TableInfo<$HanjaIdiomTableTable, HanjaIdiomTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HanjaIdiomTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hanjaIdMeta = const VerificationMeta(
    'hanjaId',
  );
  @override
  late final GeneratedColumn<String> hanjaId = GeneratedColumn<String>(
    'hanja_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idiomMeta = const VerificationMeta('idiom');
  @override
  late final GeneratedColumn<String> idiom = GeneratedColumn<String>(
    'idiom',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _readingMeta = const VerificationMeta(
    'reading',
  );
  @override
  late final GeneratedColumn<String> reading = GeneratedColumn<String>(
    'reading',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _meaningMeta = const VerificationMeta(
    'meaning',
  );
  @override
  late final GeneratedColumn<String> meaning = GeneratedColumn<String>(
    'meaning',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
    'origin',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    hanjaId,
    idiom,
    reading,
    meaning,
    origin,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hanja_idiom';
  @override
  VerificationContext validateIntegrity(
    Insertable<HanjaIdiomTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('hanja_id')) {
      context.handle(
        _hanjaIdMeta,
        hanjaId.isAcceptableOrUnknown(data['hanja_id']!, _hanjaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_hanjaIdMeta);
    }
    if (data.containsKey('idiom')) {
      context.handle(
        _idiomMeta,
        idiom.isAcceptableOrUnknown(data['idiom']!, _idiomMeta),
      );
    } else if (isInserting) {
      context.missing(_idiomMeta);
    }
    if (data.containsKey('reading')) {
      context.handle(
        _readingMeta,
        reading.isAcceptableOrUnknown(data['reading']!, _readingMeta),
      );
    } else if (isInserting) {
      context.missing(_readingMeta);
    }
    if (data.containsKey('meaning')) {
      context.handle(
        _meaningMeta,
        meaning.isAcceptableOrUnknown(data['meaning']!, _meaningMeta),
      );
    } else if (isInserting) {
      context.missing(_meaningMeta);
    }
    if (data.containsKey('origin')) {
      context.handle(
        _originMeta,
        origin.isAcceptableOrUnknown(data['origin']!, _originMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HanjaIdiomTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HanjaIdiomTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      hanjaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hanja_id'],
      )!,
      idiom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}idiom'],
      )!,
      reading: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reading'],
      )!,
      meaning: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meaning'],
      )!,
      origin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin'],
      ),
    );
  }

  @override
  $HanjaIdiomTableTable createAlias(String alias) {
    return $HanjaIdiomTableTable(attachedDatabase, alias);
  }
}

class HanjaIdiomTableData extends DataClass
    implements Insertable<HanjaIdiomTableData> {
  final String id;
  final String hanjaId;
  final String idiom;
  final String reading;
  final String meaning;
  final String? origin;
  const HanjaIdiomTableData({
    required this.id,
    required this.hanjaId,
    required this.idiom,
    required this.reading,
    required this.meaning,
    this.origin,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['hanja_id'] = Variable<String>(hanjaId);
    map['idiom'] = Variable<String>(idiom);
    map['reading'] = Variable<String>(reading);
    map['meaning'] = Variable<String>(meaning);
    if (!nullToAbsent || origin != null) {
      map['origin'] = Variable<String>(origin);
    }
    return map;
  }

  HanjaIdiomTableCompanion toCompanion(bool nullToAbsent) {
    return HanjaIdiomTableCompanion(
      id: Value(id),
      hanjaId: Value(hanjaId),
      idiom: Value(idiom),
      reading: Value(reading),
      meaning: Value(meaning),
      origin: origin == null && nullToAbsent
          ? const Value.absent()
          : Value(origin),
    );
  }

  factory HanjaIdiomTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HanjaIdiomTableData(
      id: serializer.fromJson<String>(json['id']),
      hanjaId: serializer.fromJson<String>(json['hanjaId']),
      idiom: serializer.fromJson<String>(json['idiom']),
      reading: serializer.fromJson<String>(json['reading']),
      meaning: serializer.fromJson<String>(json['meaning']),
      origin: serializer.fromJson<String?>(json['origin']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'hanjaId': serializer.toJson<String>(hanjaId),
      'idiom': serializer.toJson<String>(idiom),
      'reading': serializer.toJson<String>(reading),
      'meaning': serializer.toJson<String>(meaning),
      'origin': serializer.toJson<String?>(origin),
    };
  }

  HanjaIdiomTableData copyWith({
    String? id,
    String? hanjaId,
    String? idiom,
    String? reading,
    String? meaning,
    Value<String?> origin = const Value.absent(),
  }) => HanjaIdiomTableData(
    id: id ?? this.id,
    hanjaId: hanjaId ?? this.hanjaId,
    idiom: idiom ?? this.idiom,
    reading: reading ?? this.reading,
    meaning: meaning ?? this.meaning,
    origin: origin.present ? origin.value : this.origin,
  );
  HanjaIdiomTableData copyWithCompanion(HanjaIdiomTableCompanion data) {
    return HanjaIdiomTableData(
      id: data.id.present ? data.id.value : this.id,
      hanjaId: data.hanjaId.present ? data.hanjaId.value : this.hanjaId,
      idiom: data.idiom.present ? data.idiom.value : this.idiom,
      reading: data.reading.present ? data.reading.value : this.reading,
      meaning: data.meaning.present ? data.meaning.value : this.meaning,
      origin: data.origin.present ? data.origin.value : this.origin,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HanjaIdiomTableData(')
          ..write('id: $id, ')
          ..write('hanjaId: $hanjaId, ')
          ..write('idiom: $idiom, ')
          ..write('reading: $reading, ')
          ..write('meaning: $meaning, ')
          ..write('origin: $origin')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, hanjaId, idiom, reading, meaning, origin);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HanjaIdiomTableData &&
          other.id == this.id &&
          other.hanjaId == this.hanjaId &&
          other.idiom == this.idiom &&
          other.reading == this.reading &&
          other.meaning == this.meaning &&
          other.origin == this.origin);
}

class HanjaIdiomTableCompanion extends UpdateCompanion<HanjaIdiomTableData> {
  final Value<String> id;
  final Value<String> hanjaId;
  final Value<String> idiom;
  final Value<String> reading;
  final Value<String> meaning;
  final Value<String?> origin;
  final Value<int> rowid;
  const HanjaIdiomTableCompanion({
    this.id = const Value.absent(),
    this.hanjaId = const Value.absent(),
    this.idiom = const Value.absent(),
    this.reading = const Value.absent(),
    this.meaning = const Value.absent(),
    this.origin = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HanjaIdiomTableCompanion.insert({
    required String id,
    required String hanjaId,
    required String idiom,
    required String reading,
    required String meaning,
    this.origin = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       hanjaId = Value(hanjaId),
       idiom = Value(idiom),
       reading = Value(reading),
       meaning = Value(meaning);
  static Insertable<HanjaIdiomTableData> custom({
    Expression<String>? id,
    Expression<String>? hanjaId,
    Expression<String>? idiom,
    Expression<String>? reading,
    Expression<String>? meaning,
    Expression<String>? origin,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (hanjaId != null) 'hanja_id': hanjaId,
      if (idiom != null) 'idiom': idiom,
      if (reading != null) 'reading': reading,
      if (meaning != null) 'meaning': meaning,
      if (origin != null) 'origin': origin,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HanjaIdiomTableCompanion copyWith({
    Value<String>? id,
    Value<String>? hanjaId,
    Value<String>? idiom,
    Value<String>? reading,
    Value<String>? meaning,
    Value<String?>? origin,
    Value<int>? rowid,
  }) {
    return HanjaIdiomTableCompanion(
      id: id ?? this.id,
      hanjaId: hanjaId ?? this.hanjaId,
      idiom: idiom ?? this.idiom,
      reading: reading ?? this.reading,
      meaning: meaning ?? this.meaning,
      origin: origin ?? this.origin,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (hanjaId.present) {
      map['hanja_id'] = Variable<String>(hanjaId.value);
    }
    if (idiom.present) {
      map['idiom'] = Variable<String>(idiom.value);
    }
    if (reading.present) {
      map['reading'] = Variable<String>(reading.value);
    }
    if (meaning.present) {
      map['meaning'] = Variable<String>(meaning.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HanjaIdiomTableCompanion(')
          ..write('id: $id, ')
          ..write('hanjaId: $hanjaId, ')
          ..write('idiom: $idiom, ')
          ..write('reading: $reading, ')
          ..write('meaning: $meaning, ')
          ..write('origin: $origin, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserProgressTableTable extends UserProgressTable
    with TableInfo<$UserProgressTableTable, UserProgressTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProgressTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _hanjaIdMeta = const VerificationMeta(
    'hanjaId',
  );
  @override
  late final GeneratedColumn<String> hanjaId = GeneratedColumn<String>(
    'hanja_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('unseen'),
  );
  static const VerificationMeta _totalAttemptsMeta = const VerificationMeta(
    'totalAttempts',
  );
  @override
  late final GeneratedColumn<int> totalAttempts = GeneratedColumn<int>(
    'total_attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _correctAttemptsMeta = const VerificationMeta(
    'correctAttempts',
  );
  @override
  late final GeneratedColumn<int> correctAttempts = GeneratedColumn<int>(
    'correct_attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _accuracyRateMeta = const VerificationMeta(
    'accuracyRate',
  );
  @override
  late final GeneratedColumn<double> accuracyRate = GeneratedColumn<double>(
    'accuracy_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _lastStudiedAtMeta = const VerificationMeta(
    'lastStudiedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastStudiedAt =
      GeneratedColumn<DateTime>(
        'last_studied_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _isBookmarkedMeta = const VerificationMeta(
    'isBookmarked',
  );
  @override
  late final GeneratedColumn<bool> isBookmarked = GeneratedColumn<bool>(
    'is_bookmarked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_bookmarked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _nextReviewAtMeta = const VerificationMeta(
    'nextReviewAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextReviewAt = GeneratedColumn<DateTime>(
    'next_review_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reviewCountMeta = const VerificationMeta(
    'reviewCount',
  );
  @override
  late final GeneratedColumn<int> reviewCount = GeneratedColumn<int>(
    'review_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _intervalDaysMeta = const VerificationMeta(
    'intervalDays',
  );
  @override
  late final GeneratedColumn<int> intervalDays = GeneratedColumn<int>(
    'interval_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _easeFactorMeta = const VerificationMeta(
    'easeFactor',
  );
  @override
  late final GeneratedColumn<double> easeFactor = GeneratedColumn<double>(
    'ease_factor',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(2.5),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local_only'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _syncRevisionMeta = const VerificationMeta(
    'syncRevision',
  );
  @override
  late final GeneratedColumn<int> syncRevision = GeneratedColumn<int>(
    'sync_revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    hanjaId,
    status,
    totalAttempts,
    correctAttempts,
    accuracyRate,
    lastStudiedAt,
    isBookmarked,
    nextReviewAt,
    reviewCount,
    intervalDays,
    easeFactor,
    syncStatus,
    createdAt,
    updatedAt,
    syncRevision,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProgressTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('hanja_id')) {
      context.handle(
        _hanjaIdMeta,
        hanjaId.isAcceptableOrUnknown(data['hanja_id']!, _hanjaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_hanjaIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('total_attempts')) {
      context.handle(
        _totalAttemptsMeta,
        totalAttempts.isAcceptableOrUnknown(
          data['total_attempts']!,
          _totalAttemptsMeta,
        ),
      );
    }
    if (data.containsKey('correct_attempts')) {
      context.handle(
        _correctAttemptsMeta,
        correctAttempts.isAcceptableOrUnknown(
          data['correct_attempts']!,
          _correctAttemptsMeta,
        ),
      );
    }
    if (data.containsKey('accuracy_rate')) {
      context.handle(
        _accuracyRateMeta,
        accuracyRate.isAcceptableOrUnknown(
          data['accuracy_rate']!,
          _accuracyRateMeta,
        ),
      );
    }
    if (data.containsKey('last_studied_at')) {
      context.handle(
        _lastStudiedAtMeta,
        lastStudiedAt.isAcceptableOrUnknown(
          data['last_studied_at']!,
          _lastStudiedAtMeta,
        ),
      );
    }
    if (data.containsKey('is_bookmarked')) {
      context.handle(
        _isBookmarkedMeta,
        isBookmarked.isAcceptableOrUnknown(
          data['is_bookmarked']!,
          _isBookmarkedMeta,
        ),
      );
    }
    if (data.containsKey('next_review_at')) {
      context.handle(
        _nextReviewAtMeta,
        nextReviewAt.isAcceptableOrUnknown(
          data['next_review_at']!,
          _nextReviewAtMeta,
        ),
      );
    }
    if (data.containsKey('review_count')) {
      context.handle(
        _reviewCountMeta,
        reviewCount.isAcceptableOrUnknown(
          data['review_count']!,
          _reviewCountMeta,
        ),
      );
    }
    if (data.containsKey('interval_days')) {
      context.handle(
        _intervalDaysMeta,
        intervalDays.isAcceptableOrUnknown(
          data['interval_days']!,
          _intervalDaysMeta,
        ),
      );
    }
    if (data.containsKey('ease_factor')) {
      context.handle(
        _easeFactorMeta,
        easeFactor.isAcceptableOrUnknown(data['ease_factor']!, _easeFactorMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('sync_revision')) {
      context.handle(
        _syncRevisionMeta,
        syncRevision.isAcceptableOrUnknown(
          data['sync_revision']!,
          _syncRevisionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {hanjaId},
  ];
  @override
  UserProgressTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProgressTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      hanjaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hanja_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      totalAttempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_attempts'],
      )!,
      correctAttempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}correct_attempts'],
      )!,
      accuracyRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}accuracy_rate'],
      )!,
      lastStudiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_studied_at'],
      ),
      isBookmarked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_bookmarked'],
      )!,
      nextReviewAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_review_at'],
      ),
      reviewCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}review_count'],
      )!,
      intervalDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval_days'],
      )!,
      easeFactor: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ease_factor'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_revision'],
      )!,
    );
  }

  @override
  $UserProgressTableTable createAlias(String alias) {
    return $UserProgressTableTable(attachedDatabase, alias);
  }
}

class UserProgressTableData extends DataClass
    implements Insertable<UserProgressTableData> {
  final String id;
  final String userId;
  final String hanjaId;
  final String status;
  final int totalAttempts;
  final int correctAttempts;
  final double accuracyRate;
  final DateTime? lastStudiedAt;
  final bool isBookmarked;

  /// 다음 복습 예정일. null이면 아직 미학습.
  final DateTime? nextReviewAt;

  /// SM-2 반복 횟수 (n).
  final int reviewCount;

  /// SM-2 간격 (일 단위).
  final int intervalDays;

  /// SM-2 난이도 계수 (2.5 기본).
  final double easeFactor;
  final String syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int syncRevision;
  const UserProgressTableData({
    required this.id,
    required this.userId,
    required this.hanjaId,
    required this.status,
    required this.totalAttempts,
    required this.correctAttempts,
    required this.accuracyRate,
    this.lastStudiedAt,
    required this.isBookmarked,
    this.nextReviewAt,
    required this.reviewCount,
    required this.intervalDays,
    required this.easeFactor,
    required this.syncStatus,
    required this.createdAt,
    required this.updatedAt,
    required this.syncRevision,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['hanja_id'] = Variable<String>(hanjaId);
    map['status'] = Variable<String>(status);
    map['total_attempts'] = Variable<int>(totalAttempts);
    map['correct_attempts'] = Variable<int>(correctAttempts);
    map['accuracy_rate'] = Variable<double>(accuracyRate);
    if (!nullToAbsent || lastStudiedAt != null) {
      map['last_studied_at'] = Variable<DateTime>(lastStudiedAt);
    }
    map['is_bookmarked'] = Variable<bool>(isBookmarked);
    if (!nullToAbsent || nextReviewAt != null) {
      map['next_review_at'] = Variable<DateTime>(nextReviewAt);
    }
    map['review_count'] = Variable<int>(reviewCount);
    map['interval_days'] = Variable<int>(intervalDays);
    map['ease_factor'] = Variable<double>(easeFactor);
    map['sync_status'] = Variable<String>(syncStatus);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_revision'] = Variable<int>(syncRevision);
    return map;
  }

  UserProgressTableCompanion toCompanion(bool nullToAbsent) {
    return UserProgressTableCompanion(
      id: Value(id),
      userId: Value(userId),
      hanjaId: Value(hanjaId),
      status: Value(status),
      totalAttempts: Value(totalAttempts),
      correctAttempts: Value(correctAttempts),
      accuracyRate: Value(accuracyRate),
      lastStudiedAt: lastStudiedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastStudiedAt),
      isBookmarked: Value(isBookmarked),
      nextReviewAt: nextReviewAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextReviewAt),
      reviewCount: Value(reviewCount),
      intervalDays: Value(intervalDays),
      easeFactor: Value(easeFactor),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncRevision: Value(syncRevision),
    );
  }

  factory UserProgressTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProgressTableData(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      hanjaId: serializer.fromJson<String>(json['hanjaId']),
      status: serializer.fromJson<String>(json['status']),
      totalAttempts: serializer.fromJson<int>(json['totalAttempts']),
      correctAttempts: serializer.fromJson<int>(json['correctAttempts']),
      accuracyRate: serializer.fromJson<double>(json['accuracyRate']),
      lastStudiedAt: serializer.fromJson<DateTime?>(json['lastStudiedAt']),
      isBookmarked: serializer.fromJson<bool>(json['isBookmarked']),
      nextReviewAt: serializer.fromJson<DateTime?>(json['nextReviewAt']),
      reviewCount: serializer.fromJson<int>(json['reviewCount']),
      intervalDays: serializer.fromJson<int>(json['intervalDays']),
      easeFactor: serializer.fromJson<double>(json['easeFactor']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncRevision: serializer.fromJson<int>(json['syncRevision']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'hanjaId': serializer.toJson<String>(hanjaId),
      'status': serializer.toJson<String>(status),
      'totalAttempts': serializer.toJson<int>(totalAttempts),
      'correctAttempts': serializer.toJson<int>(correctAttempts),
      'accuracyRate': serializer.toJson<double>(accuracyRate),
      'lastStudiedAt': serializer.toJson<DateTime?>(lastStudiedAt),
      'isBookmarked': serializer.toJson<bool>(isBookmarked),
      'nextReviewAt': serializer.toJson<DateTime?>(nextReviewAt),
      'reviewCount': serializer.toJson<int>(reviewCount),
      'intervalDays': serializer.toJson<int>(intervalDays),
      'easeFactor': serializer.toJson<double>(easeFactor),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncRevision': serializer.toJson<int>(syncRevision),
    };
  }

  UserProgressTableData copyWith({
    String? id,
    String? userId,
    String? hanjaId,
    String? status,
    int? totalAttempts,
    int? correctAttempts,
    double? accuracyRate,
    Value<DateTime?> lastStudiedAt = const Value.absent(),
    bool? isBookmarked,
    Value<DateTime?> nextReviewAt = const Value.absent(),
    int? reviewCount,
    int? intervalDays,
    double? easeFactor,
    String? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? syncRevision,
  }) => UserProgressTableData(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    hanjaId: hanjaId ?? this.hanjaId,
    status: status ?? this.status,
    totalAttempts: totalAttempts ?? this.totalAttempts,
    correctAttempts: correctAttempts ?? this.correctAttempts,
    accuracyRate: accuracyRate ?? this.accuracyRate,
    lastStudiedAt: lastStudiedAt.present
        ? lastStudiedAt.value
        : this.lastStudiedAt,
    isBookmarked: isBookmarked ?? this.isBookmarked,
    nextReviewAt: nextReviewAt.present ? nextReviewAt.value : this.nextReviewAt,
    reviewCount: reviewCount ?? this.reviewCount,
    intervalDays: intervalDays ?? this.intervalDays,
    easeFactor: easeFactor ?? this.easeFactor,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncRevision: syncRevision ?? this.syncRevision,
  );
  UserProgressTableData copyWithCompanion(UserProgressTableCompanion data) {
    return UserProgressTableData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      hanjaId: data.hanjaId.present ? data.hanjaId.value : this.hanjaId,
      status: data.status.present ? data.status.value : this.status,
      totalAttempts: data.totalAttempts.present
          ? data.totalAttempts.value
          : this.totalAttempts,
      correctAttempts: data.correctAttempts.present
          ? data.correctAttempts.value
          : this.correctAttempts,
      accuracyRate: data.accuracyRate.present
          ? data.accuracyRate.value
          : this.accuracyRate,
      lastStudiedAt: data.lastStudiedAt.present
          ? data.lastStudiedAt.value
          : this.lastStudiedAt,
      isBookmarked: data.isBookmarked.present
          ? data.isBookmarked.value
          : this.isBookmarked,
      nextReviewAt: data.nextReviewAt.present
          ? data.nextReviewAt.value
          : this.nextReviewAt,
      reviewCount: data.reviewCount.present
          ? data.reviewCount.value
          : this.reviewCount,
      intervalDays: data.intervalDays.present
          ? data.intervalDays.value
          : this.intervalDays,
      easeFactor: data.easeFactor.present
          ? data.easeFactor.value
          : this.easeFactor,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncRevision: data.syncRevision.present
          ? data.syncRevision.value
          : this.syncRevision,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProgressTableData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('hanjaId: $hanjaId, ')
          ..write('status: $status, ')
          ..write('totalAttempts: $totalAttempts, ')
          ..write('correctAttempts: $correctAttempts, ')
          ..write('accuracyRate: $accuracyRate, ')
          ..write('lastStudiedAt: $lastStudiedAt, ')
          ..write('isBookmarked: $isBookmarked, ')
          ..write('nextReviewAt: $nextReviewAt, ')
          ..write('reviewCount: $reviewCount, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('easeFactor: $easeFactor, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncRevision: $syncRevision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    hanjaId,
    status,
    totalAttempts,
    correctAttempts,
    accuracyRate,
    lastStudiedAt,
    isBookmarked,
    nextReviewAt,
    reviewCount,
    intervalDays,
    easeFactor,
    syncStatus,
    createdAt,
    updatedAt,
    syncRevision,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProgressTableData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.hanjaId == this.hanjaId &&
          other.status == this.status &&
          other.totalAttempts == this.totalAttempts &&
          other.correctAttempts == this.correctAttempts &&
          other.accuracyRate == this.accuracyRate &&
          other.lastStudiedAt == this.lastStudiedAt &&
          other.isBookmarked == this.isBookmarked &&
          other.nextReviewAt == this.nextReviewAt &&
          other.reviewCount == this.reviewCount &&
          other.intervalDays == this.intervalDays &&
          other.easeFactor == this.easeFactor &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncRevision == this.syncRevision);
}

class UserProgressTableCompanion
    extends UpdateCompanion<UserProgressTableData> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> hanjaId;
  final Value<String> status;
  final Value<int> totalAttempts;
  final Value<int> correctAttempts;
  final Value<double> accuracyRate;
  final Value<DateTime?> lastStudiedAt;
  final Value<bool> isBookmarked;
  final Value<DateTime?> nextReviewAt;
  final Value<int> reviewCount;
  final Value<int> intervalDays;
  final Value<double> easeFactor;
  final Value<String> syncStatus;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> syncRevision;
  final Value<int> rowid;
  const UserProgressTableCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.hanjaId = const Value.absent(),
    this.status = const Value.absent(),
    this.totalAttempts = const Value.absent(),
    this.correctAttempts = const Value.absent(),
    this.accuracyRate = const Value.absent(),
    this.lastStudiedAt = const Value.absent(),
    this.isBookmarked = const Value.absent(),
    this.nextReviewAt = const Value.absent(),
    this.reviewCount = const Value.absent(),
    this.intervalDays = const Value.absent(),
    this.easeFactor = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncRevision = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserProgressTableCompanion.insert({
    required String id,
    this.userId = const Value.absent(),
    required String hanjaId,
    this.status = const Value.absent(),
    this.totalAttempts = const Value.absent(),
    this.correctAttempts = const Value.absent(),
    this.accuracyRate = const Value.absent(),
    this.lastStudiedAt = const Value.absent(),
    this.isBookmarked = const Value.absent(),
    this.nextReviewAt = const Value.absent(),
    this.reviewCount = const Value.absent(),
    this.intervalDays = const Value.absent(),
    this.easeFactor = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncRevision = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       hanjaId = Value(hanjaId);
  static Insertable<UserProgressTableData> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? hanjaId,
    Expression<String>? status,
    Expression<int>? totalAttempts,
    Expression<int>? correctAttempts,
    Expression<double>? accuracyRate,
    Expression<DateTime>? lastStudiedAt,
    Expression<bool>? isBookmarked,
    Expression<DateTime>? nextReviewAt,
    Expression<int>? reviewCount,
    Expression<int>? intervalDays,
    Expression<double>? easeFactor,
    Expression<String>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? syncRevision,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (hanjaId != null) 'hanja_id': hanjaId,
      if (status != null) 'status': status,
      if (totalAttempts != null) 'total_attempts': totalAttempts,
      if (correctAttempts != null) 'correct_attempts': correctAttempts,
      if (accuracyRate != null) 'accuracy_rate': accuracyRate,
      if (lastStudiedAt != null) 'last_studied_at': lastStudiedAt,
      if (isBookmarked != null) 'is_bookmarked': isBookmarked,
      if (nextReviewAt != null) 'next_review_at': nextReviewAt,
      if (reviewCount != null) 'review_count': reviewCount,
      if (intervalDays != null) 'interval_days': intervalDays,
      if (easeFactor != null) 'ease_factor': easeFactor,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncRevision != null) 'sync_revision': syncRevision,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserProgressTableCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? hanjaId,
    Value<String>? status,
    Value<int>? totalAttempts,
    Value<int>? correctAttempts,
    Value<double>? accuracyRate,
    Value<DateTime?>? lastStudiedAt,
    Value<bool>? isBookmarked,
    Value<DateTime?>? nextReviewAt,
    Value<int>? reviewCount,
    Value<int>? intervalDays,
    Value<double>? easeFactor,
    Value<String>? syncStatus,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? syncRevision,
    Value<int>? rowid,
  }) {
    return UserProgressTableCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      hanjaId: hanjaId ?? this.hanjaId,
      status: status ?? this.status,
      totalAttempts: totalAttempts ?? this.totalAttempts,
      correctAttempts: correctAttempts ?? this.correctAttempts,
      accuracyRate: accuracyRate ?? this.accuracyRate,
      lastStudiedAt: lastStudiedAt ?? this.lastStudiedAt,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
      reviewCount: reviewCount ?? this.reviewCount,
      intervalDays: intervalDays ?? this.intervalDays,
      easeFactor: easeFactor ?? this.easeFactor,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncRevision: syncRevision ?? this.syncRevision,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (hanjaId.present) {
      map['hanja_id'] = Variable<String>(hanjaId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (totalAttempts.present) {
      map['total_attempts'] = Variable<int>(totalAttempts.value);
    }
    if (correctAttempts.present) {
      map['correct_attempts'] = Variable<int>(correctAttempts.value);
    }
    if (accuracyRate.present) {
      map['accuracy_rate'] = Variable<double>(accuracyRate.value);
    }
    if (lastStudiedAt.present) {
      map['last_studied_at'] = Variable<DateTime>(lastStudiedAt.value);
    }
    if (isBookmarked.present) {
      map['is_bookmarked'] = Variable<bool>(isBookmarked.value);
    }
    if (nextReviewAt.present) {
      map['next_review_at'] = Variable<DateTime>(nextReviewAt.value);
    }
    if (reviewCount.present) {
      map['review_count'] = Variable<int>(reviewCount.value);
    }
    if (intervalDays.present) {
      map['interval_days'] = Variable<int>(intervalDays.value);
    }
    if (easeFactor.present) {
      map['ease_factor'] = Variable<double>(easeFactor.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncRevision.present) {
      map['sync_revision'] = Variable<int>(syncRevision.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProgressTableCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('hanjaId: $hanjaId, ')
          ..write('status: $status, ')
          ..write('totalAttempts: $totalAttempts, ')
          ..write('correctAttempts: $correctAttempts, ')
          ..write('accuracyRate: $accuracyRate, ')
          ..write('lastStudiedAt: $lastStudiedAt, ')
          ..write('isBookmarked: $isBookmarked, ')
          ..write('nextReviewAt: $nextReviewAt, ')
          ..write('reviewCount: $reviewCount, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('easeFactor: $easeFactor, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncRevision: $syncRevision, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StudySessionTableTable extends StudySessionTable
    with TableInfo<$StudySessionTableTable, StudySessionTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudySessionTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalHanjaMeta = const VerificationMeta(
    'totalHanja',
  );
  @override
  late final GeneratedColumn<int> totalHanja = GeneratedColumn<int>(
    'total_hanja',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _correctCountMeta = const VerificationMeta(
    'correctCount',
  );
  @override
  late final GeneratedColumn<int> correctCount = GeneratedColumn<int>(
    'correct_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sessionTypeMeta = const VerificationMeta(
    'sessionType',
  );
  @override
  late final GeneratedColumn<String> sessionType = GeneratedColumn<String>(
    'session_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local_only'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    startedAt,
    endedAt,
    totalHanja,
    correctCount,
    sessionType,
    syncStatus,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'study_session';
  @override
  VerificationContext validateIntegrity(
    Insertable<StudySessionTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('total_hanja')) {
      context.handle(
        _totalHanjaMeta,
        totalHanja.isAcceptableOrUnknown(data['total_hanja']!, _totalHanjaMeta),
      );
    }
    if (data.containsKey('correct_count')) {
      context.handle(
        _correctCountMeta,
        correctCount.isAcceptableOrUnknown(
          data['correct_count']!,
          _correctCountMeta,
        ),
      );
    }
    if (data.containsKey('session_type')) {
      context.handle(
        _sessionTypeMeta,
        sessionType.isAcceptableOrUnknown(
          data['session_type']!,
          _sessionTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sessionTypeMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StudySessionTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StudySessionTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      totalHanja: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_hanja'],
      )!,
      correctCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}correct_count'],
      )!,
      sessionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_type'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $StudySessionTableTable createAlias(String alias) {
    return $StudySessionTableTable(attachedDatabase, alias);
  }
}

class StudySessionTableData extends DataClass
    implements Insertable<StudySessionTableData> {
  final String id;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int totalHanja;
  final int correctCount;
  final String sessionType;
  final String syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  const StudySessionTableData({
    required this.id,
    required this.startedAt,
    this.endedAt,
    required this.totalHanja,
    required this.correctCount,
    required this.sessionType,
    required this.syncStatus,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    map['total_hanja'] = Variable<int>(totalHanja);
    map['correct_count'] = Variable<int>(correctCount);
    map['session_type'] = Variable<String>(sessionType);
    map['sync_status'] = Variable<String>(syncStatus);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  StudySessionTableCompanion toCompanion(bool nullToAbsent) {
    return StudySessionTableCompanion(
      id: Value(id),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      totalHanja: Value(totalHanja),
      correctCount: Value(correctCount),
      sessionType: Value(sessionType),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory StudySessionTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StudySessionTableData(
      id: serializer.fromJson<String>(json['id']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      totalHanja: serializer.fromJson<int>(json['totalHanja']),
      correctCount: serializer.fromJson<int>(json['correctCount']),
      sessionType: serializer.fromJson<String>(json['sessionType']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'totalHanja': serializer.toJson<int>(totalHanja),
      'correctCount': serializer.toJson<int>(correctCount),
      'sessionType': serializer.toJson<String>(sessionType),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  StudySessionTableData copyWith({
    String? id,
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    int? totalHanja,
    int? correctCount,
    String? sessionType,
    String? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => StudySessionTableData(
    id: id ?? this.id,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    totalHanja: totalHanja ?? this.totalHanja,
    correctCount: correctCount ?? this.correctCount,
    sessionType: sessionType ?? this.sessionType,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  StudySessionTableData copyWithCompanion(StudySessionTableCompanion data) {
    return StudySessionTableData(
      id: data.id.present ? data.id.value : this.id,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      totalHanja: data.totalHanja.present
          ? data.totalHanja.value
          : this.totalHanja,
      correctCount: data.correctCount.present
          ? data.correctCount.value
          : this.correctCount,
      sessionType: data.sessionType.present
          ? data.sessionType.value
          : this.sessionType,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StudySessionTableData(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('totalHanja: $totalHanja, ')
          ..write('correctCount: $correctCount, ')
          ..write('sessionType: $sessionType, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    startedAt,
    endedAt,
    totalHanja,
    correctCount,
    sessionType,
    syncStatus,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StudySessionTableData &&
          other.id == this.id &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.totalHanja == this.totalHanja &&
          other.correctCount == this.correctCount &&
          other.sessionType == this.sessionType &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class StudySessionTableCompanion
    extends UpdateCompanion<StudySessionTableData> {
  final Value<String> id;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<int> totalHanja;
  final Value<int> correctCount;
  final Value<String> sessionType;
  final Value<String> syncStatus;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const StudySessionTableCompanion({
    this.id = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.totalHanja = const Value.absent(),
    this.correctCount = const Value.absent(),
    this.sessionType = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StudySessionTableCompanion.insert({
    required String id,
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    this.totalHanja = const Value.absent(),
    this.correctCount = const Value.absent(),
    required String sessionType,
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       startedAt = Value(startedAt),
       sessionType = Value(sessionType);
  static Insertable<StudySessionTableData> custom({
    Expression<String>? id,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<int>? totalHanja,
    Expression<int>? correctCount,
    Expression<String>? sessionType,
    Expression<String>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (totalHanja != null) 'total_hanja': totalHanja,
      if (correctCount != null) 'correct_count': correctCount,
      if (sessionType != null) 'session_type': sessionType,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StudySessionTableCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<int>? totalHanja,
    Value<int>? correctCount,
    Value<String>? sessionType,
    Value<String>? syncStatus,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return StudySessionTableCompanion(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      totalHanja: totalHanja ?? this.totalHanja,
      correctCount: correctCount ?? this.correctCount,
      sessionType: sessionType ?? this.sessionType,
      syncStatus: syncStatus ?? this.syncStatus,
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
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (totalHanja.present) {
      map['total_hanja'] = Variable<int>(totalHanja.value);
    }
    if (correctCount.present) {
      map['correct_count'] = Variable<int>(correctCount.value);
    }
    if (sessionType.present) {
      map['session_type'] = Variable<String>(sessionType.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
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
    return (StringBuffer('StudySessionTableCompanion(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('totalHanja: $totalHanja, ')
          ..write('correctCount: $correctCount, ')
          ..write('sessionType: $sessionType, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AnswerHistoryTableTable extends AnswerHistoryTable
    with TableInfo<$AnswerHistoryTableTable, AnswerHistoryTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnswerHistoryTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES study_session (id)',
    ),
  );
  static const VerificationMeta _hanjaIdMeta = const VerificationMeta(
    'hanjaId',
  );
  @override
  late final GeneratedColumn<String> hanjaId = GeneratedColumn<String>(
    'hanja_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _answeredAtMeta = const VerificationMeta(
    'answeredAt',
  );
  @override
  late final GeneratedColumn<DateTime> answeredAt = GeneratedColumn<DateTime>(
    'answered_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCorrectMeta = const VerificationMeta(
    'isCorrect',
  );
  @override
  late final GeneratedColumn<bool> isCorrect = GeneratedColumn<bool>(
    'is_correct',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_correct" IN (0, 1))',
    ),
  );
  static const VerificationMeta _accuracyScoreMeta = const VerificationMeta(
    'accuracyScore',
  );
  @override
  late final GeneratedColumn<double> accuracyScore = GeneratedColumn<double>(
    'accuracy_score',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _strokesJsonMeta = const VerificationMeta(
    'strokesJson',
  );
  @override
  late final GeneratedColumn<String> strokesJson = GeneratedColumn<String>(
    'strokes_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local_only'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    hanjaId,
    answeredAt,
    isCorrect,
    accuracyScore,
    strokesJson,
    syncStatus,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'answer_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<AnswerHistoryTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('hanja_id')) {
      context.handle(
        _hanjaIdMeta,
        hanjaId.isAcceptableOrUnknown(data['hanja_id']!, _hanjaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_hanjaIdMeta);
    }
    if (data.containsKey('answered_at')) {
      context.handle(
        _answeredAtMeta,
        answeredAt.isAcceptableOrUnknown(data['answered_at']!, _answeredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_answeredAtMeta);
    }
    if (data.containsKey('is_correct')) {
      context.handle(
        _isCorrectMeta,
        isCorrect.isAcceptableOrUnknown(data['is_correct']!, _isCorrectMeta),
      );
    } else if (isInserting) {
      context.missing(_isCorrectMeta);
    }
    if (data.containsKey('accuracy_score')) {
      context.handle(
        _accuracyScoreMeta,
        accuracyScore.isAcceptableOrUnknown(
          data['accuracy_score']!,
          _accuracyScoreMeta,
        ),
      );
    }
    if (data.containsKey('strokes_json')) {
      context.handle(
        _strokesJsonMeta,
        strokesJson.isAcceptableOrUnknown(
          data['strokes_json']!,
          _strokesJsonMeta,
        ),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AnswerHistoryTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AnswerHistoryTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      hanjaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hanja_id'],
      )!,
      answeredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}answered_at'],
      )!,
      isCorrect: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_correct'],
      )!,
      accuracyScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}accuracy_score'],
      )!,
      strokesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}strokes_json'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AnswerHistoryTableTable createAlias(String alias) {
    return $AnswerHistoryTableTable(attachedDatabase, alias);
  }
}

class AnswerHistoryTableData extends DataClass
    implements Insertable<AnswerHistoryTableData> {
  final String id;
  final String sessionId;
  final String hanjaId;
  final DateTime answeredAt;
  final bool isCorrect;
  final double accuracyScore;
  final String? strokesJson;
  final String syncStatus;
  final DateTime createdAt;
  const AnswerHistoryTableData({
    required this.id,
    required this.sessionId,
    required this.hanjaId,
    required this.answeredAt,
    required this.isCorrect,
    required this.accuracyScore,
    this.strokesJson,
    required this.syncStatus,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['hanja_id'] = Variable<String>(hanjaId);
    map['answered_at'] = Variable<DateTime>(answeredAt);
    map['is_correct'] = Variable<bool>(isCorrect);
    map['accuracy_score'] = Variable<double>(accuracyScore);
    if (!nullToAbsent || strokesJson != null) {
      map['strokes_json'] = Variable<String>(strokesJson);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AnswerHistoryTableCompanion toCompanion(bool nullToAbsent) {
    return AnswerHistoryTableCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      hanjaId: Value(hanjaId),
      answeredAt: Value(answeredAt),
      isCorrect: Value(isCorrect),
      accuracyScore: Value(accuracyScore),
      strokesJson: strokesJson == null && nullToAbsent
          ? const Value.absent()
          : Value(strokesJson),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
    );
  }

  factory AnswerHistoryTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AnswerHistoryTableData(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      hanjaId: serializer.fromJson<String>(json['hanjaId']),
      answeredAt: serializer.fromJson<DateTime>(json['answeredAt']),
      isCorrect: serializer.fromJson<bool>(json['isCorrect']),
      accuracyScore: serializer.fromJson<double>(json['accuracyScore']),
      strokesJson: serializer.fromJson<String?>(json['strokesJson']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'hanjaId': serializer.toJson<String>(hanjaId),
      'answeredAt': serializer.toJson<DateTime>(answeredAt),
      'isCorrect': serializer.toJson<bool>(isCorrect),
      'accuracyScore': serializer.toJson<double>(accuracyScore),
      'strokesJson': serializer.toJson<String?>(strokesJson),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AnswerHistoryTableData copyWith({
    String? id,
    String? sessionId,
    String? hanjaId,
    DateTime? answeredAt,
    bool? isCorrect,
    double? accuracyScore,
    Value<String?> strokesJson = const Value.absent(),
    String? syncStatus,
    DateTime? createdAt,
  }) => AnswerHistoryTableData(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    hanjaId: hanjaId ?? this.hanjaId,
    answeredAt: answeredAt ?? this.answeredAt,
    isCorrect: isCorrect ?? this.isCorrect,
    accuracyScore: accuracyScore ?? this.accuracyScore,
    strokesJson: strokesJson.present ? strokesJson.value : this.strokesJson,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
  );
  AnswerHistoryTableData copyWithCompanion(AnswerHistoryTableCompanion data) {
    return AnswerHistoryTableData(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      hanjaId: data.hanjaId.present ? data.hanjaId.value : this.hanjaId,
      answeredAt: data.answeredAt.present
          ? data.answeredAt.value
          : this.answeredAt,
      isCorrect: data.isCorrect.present ? data.isCorrect.value : this.isCorrect,
      accuracyScore: data.accuracyScore.present
          ? data.accuracyScore.value
          : this.accuracyScore,
      strokesJson: data.strokesJson.present
          ? data.strokesJson.value
          : this.strokesJson,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AnswerHistoryTableData(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('hanjaId: $hanjaId, ')
          ..write('answeredAt: $answeredAt, ')
          ..write('isCorrect: $isCorrect, ')
          ..write('accuracyScore: $accuracyScore, ')
          ..write('strokesJson: $strokesJson, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    hanjaId,
    answeredAt,
    isCorrect,
    accuracyScore,
    strokesJson,
    syncStatus,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AnswerHistoryTableData &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.hanjaId == this.hanjaId &&
          other.answeredAt == this.answeredAt &&
          other.isCorrect == this.isCorrect &&
          other.accuracyScore == this.accuracyScore &&
          other.strokesJson == this.strokesJson &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt);
}

class AnswerHistoryTableCompanion
    extends UpdateCompanion<AnswerHistoryTableData> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> hanjaId;
  final Value<DateTime> answeredAt;
  final Value<bool> isCorrect;
  final Value<double> accuracyScore;
  final Value<String?> strokesJson;
  final Value<String> syncStatus;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const AnswerHistoryTableCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.hanjaId = const Value.absent(),
    this.answeredAt = const Value.absent(),
    this.isCorrect = const Value.absent(),
    this.accuracyScore = const Value.absent(),
    this.strokesJson = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AnswerHistoryTableCompanion.insert({
    required String id,
    required String sessionId,
    required String hanjaId,
    required DateTime answeredAt,
    required bool isCorrect,
    this.accuracyScore = const Value.absent(),
    this.strokesJson = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       hanjaId = Value(hanjaId),
       answeredAt = Value(answeredAt),
       isCorrect = Value(isCorrect);
  static Insertable<AnswerHistoryTableData> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? hanjaId,
    Expression<DateTime>? answeredAt,
    Expression<bool>? isCorrect,
    Expression<double>? accuracyScore,
    Expression<String>? strokesJson,
    Expression<String>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (hanjaId != null) 'hanja_id': hanjaId,
      if (answeredAt != null) 'answered_at': answeredAt,
      if (isCorrect != null) 'is_correct': isCorrect,
      if (accuracyScore != null) 'accuracy_score': accuracyScore,
      if (strokesJson != null) 'strokes_json': strokesJson,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AnswerHistoryTableCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<String>? hanjaId,
    Value<DateTime>? answeredAt,
    Value<bool>? isCorrect,
    Value<double>? accuracyScore,
    Value<String?>? strokesJson,
    Value<String>? syncStatus,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return AnswerHistoryTableCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      hanjaId: hanjaId ?? this.hanjaId,
      answeredAt: answeredAt ?? this.answeredAt,
      isCorrect: isCorrect ?? this.isCorrect,
      accuracyScore: accuracyScore ?? this.accuracyScore,
      strokesJson: strokesJson ?? this.strokesJson,
      syncStatus: syncStatus ?? this.syncStatus,
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
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (hanjaId.present) {
      map['hanja_id'] = Variable<String>(hanjaId.value);
    }
    if (answeredAt.present) {
      map['answered_at'] = Variable<DateTime>(answeredAt.value);
    }
    if (isCorrect.present) {
      map['is_correct'] = Variable<bool>(isCorrect.value);
    }
    if (accuracyScore.present) {
      map['accuracy_score'] = Variable<double>(accuracyScore.value);
    }
    if (strokesJson.present) {
      map['strokes_json'] = Variable<String>(strokesJson.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
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
    return (StringBuffer('AnswerHistoryTableCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('hanjaId: $hanjaId, ')
          ..write('answeredAt: $answeredAt, ')
          ..write('isCorrect: $isCorrect, ')
          ..write('accuracyScore: $accuracyScore, ')
          ..write('strokesJson: $strokesJson, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTableTable extends AppSettingsTable
    with TableInfo<$AppSettingsTableTable, AppSettingsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSettingsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSettingsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingsTableData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AppSettingsTableTable createAlias(String alias) {
    return $AppSettingsTableTable(attachedDatabase, alias);
  }
}

class AppSettingsTableData extends DataClass
    implements Insertable<AppSettingsTableData> {
  final String key;
  final String value;
  final DateTime updatedAt;
  const AppSettingsTableData({
    required this.key,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AppSettingsTableCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsTableCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppSettingsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingsTableData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AppSettingsTableData copyWith({
    String? key,
    String? value,
    DateTime? updatedAt,
  }) => AppSettingsTableData(
    key: key ?? this.key,
    value: value ?? this.value,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AppSettingsTableData copyWithCompanion(AppSettingsTableCompanion data) {
    return AppSettingsTableData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsTableData(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingsTableData &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class AppSettingsTableCompanion extends UpdateCompanion<AppSettingsTableData> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AppSettingsTableCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsTableCompanion.insert({
    required String key,
    required String value,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSettingsTableData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsTableCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AppSettingsTableCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
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
    return (StringBuffer('AppSettingsTableCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTableTable extends SyncQueueTable
    with TableInfo<$SyncQueueTableTable, SyncQueueTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tableName_Meta = const VerificationMeta(
    'tableName_',
  );
  @override
  late final GeneratedColumn<String> tableName_ = GeneratedColumn<String>(
    'table_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rowIdMeta = const VerificationMeta('rowId');
  @override
  late final GeneratedColumn<String> rowId = GeneratedColumn<String>(
    'row_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _processedAtMeta = const VerificationMeta(
    'processedAt',
  );
  @override
  late final GeneratedColumn<DateTime> processedAt = GeneratedColumn<DateTime>(
    'processed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tableName_,
    rowId,
    operation,
    payload,
    retryCount,
    status,
    createdAt,
    processedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('table_name')) {
      context.handle(
        _tableName_Meta,
        tableName_.isAcceptableOrUnknown(data['table_name']!, _tableName_Meta),
      );
    } else if (isInserting) {
      context.missing(_tableName_Meta);
    }
    if (data.containsKey('row_id')) {
      context.handle(
        _rowIdMeta,
        rowId.isAcceptableOrUnknown(data['row_id']!, _rowIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rowIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('processed_at')) {
      context.handle(
        _processedAtMeta,
        processedAt.isAcceptableOrUnknown(
          data['processed_at']!,
          _processedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tableName_: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}table_name'],
      )!,
      rowId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}row_id'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      processedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}processed_at'],
      ),
    );
  }

  @override
  $SyncQueueTableTable createAlias(String alias) {
    return $SyncQueueTableTable(attachedDatabase, alias);
  }
}

class SyncQueueTableData extends DataClass
    implements Insertable<SyncQueueTableData> {
  final String id;
  final String tableName_;
  final String rowId;
  final String operation;
  final String payload;
  final int retryCount;
  final String status;
  final DateTime createdAt;
  final DateTime? processedAt;
  const SyncQueueTableData({
    required this.id,
    required this.tableName_,
    required this.rowId,
    required this.operation,
    required this.payload,
    required this.retryCount,
    required this.status,
    required this.createdAt,
    this.processedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['table_name'] = Variable<String>(tableName_);
    map['row_id'] = Variable<String>(rowId);
    map['operation'] = Variable<String>(operation);
    map['payload'] = Variable<String>(payload);
    map['retry_count'] = Variable<int>(retryCount);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || processedAt != null) {
      map['processed_at'] = Variable<DateTime>(processedAt);
    }
    return map;
  }

  SyncQueueTableCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueTableCompanion(
      id: Value(id),
      tableName_: Value(tableName_),
      rowId: Value(rowId),
      operation: Value(operation),
      payload: Value(payload),
      retryCount: Value(retryCount),
      status: Value(status),
      createdAt: Value(createdAt),
      processedAt: processedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(processedAt),
    );
  }

  factory SyncQueueTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueTableData(
      id: serializer.fromJson<String>(json['id']),
      tableName_: serializer.fromJson<String>(json['tableName_']),
      rowId: serializer.fromJson<String>(json['rowId']),
      operation: serializer.fromJson<String>(json['operation']),
      payload: serializer.fromJson<String>(json['payload']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      processedAt: serializer.fromJson<DateTime?>(json['processedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tableName_': serializer.toJson<String>(tableName_),
      'rowId': serializer.toJson<String>(rowId),
      'operation': serializer.toJson<String>(operation),
      'payload': serializer.toJson<String>(payload),
      'retryCount': serializer.toJson<int>(retryCount),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'processedAt': serializer.toJson<DateTime?>(processedAt),
    };
  }

  SyncQueueTableData copyWith({
    String? id,
    String? tableName_,
    String? rowId,
    String? operation,
    String? payload,
    int? retryCount,
    String? status,
    DateTime? createdAt,
    Value<DateTime?> processedAt = const Value.absent(),
  }) => SyncQueueTableData(
    id: id ?? this.id,
    tableName_: tableName_ ?? this.tableName_,
    rowId: rowId ?? this.rowId,
    operation: operation ?? this.operation,
    payload: payload ?? this.payload,
    retryCount: retryCount ?? this.retryCount,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    processedAt: processedAt.present ? processedAt.value : this.processedAt,
  );
  SyncQueueTableData copyWithCompanion(SyncQueueTableCompanion data) {
    return SyncQueueTableData(
      id: data.id.present ? data.id.value : this.id,
      tableName_: data.tableName_.present
          ? data.tableName_.value
          : this.tableName_,
      rowId: data.rowId.present ? data.rowId.value : this.rowId,
      operation: data.operation.present ? data.operation.value : this.operation,
      payload: data.payload.present ? data.payload.value : this.payload,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      processedAt: data.processedAt.present
          ? data.processedAt.value
          : this.processedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueTableData(')
          ..write('id: $id, ')
          ..write('tableName_: $tableName_, ')
          ..write('rowId: $rowId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('retryCount: $retryCount, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('processedAt: $processedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tableName_,
    rowId,
    operation,
    payload,
    retryCount,
    status,
    createdAt,
    processedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueTableData &&
          other.id == this.id &&
          other.tableName_ == this.tableName_ &&
          other.rowId == this.rowId &&
          other.operation == this.operation &&
          other.payload == this.payload &&
          other.retryCount == this.retryCount &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.processedAt == this.processedAt);
}

class SyncQueueTableCompanion extends UpdateCompanion<SyncQueueTableData> {
  final Value<String> id;
  final Value<String> tableName_;
  final Value<String> rowId;
  final Value<String> operation;
  final Value<String> payload;
  final Value<int> retryCount;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime?> processedAt;
  final Value<int> rowid;
  const SyncQueueTableCompanion({
    this.id = const Value.absent(),
    this.tableName_ = const Value.absent(),
    this.rowId = const Value.absent(),
    this.operation = const Value.absent(),
    this.payload = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.processedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncQueueTableCompanion.insert({
    required String id,
    required String tableName_,
    required String rowId,
    required String operation,
    required String payload,
    this.retryCount = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.processedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tableName_ = Value(tableName_),
       rowId = Value(rowId),
       operation = Value(operation),
       payload = Value(payload);
  static Insertable<SyncQueueTableData> custom({
    Expression<String>? id,
    Expression<String>? tableName_,
    Expression<String>? rowId,
    Expression<String>? operation,
    Expression<String>? payload,
    Expression<int>? retryCount,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? processedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tableName_ != null) 'table_name': tableName_,
      if (rowId != null) 'row_id': rowId,
      if (operation != null) 'operation': operation,
      if (payload != null) 'payload': payload,
      if (retryCount != null) 'retry_count': retryCount,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (processedAt != null) 'processed_at': processedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncQueueTableCompanion copyWith({
    Value<String>? id,
    Value<String>? tableName_,
    Value<String>? rowId,
    Value<String>? operation,
    Value<String>? payload,
    Value<int>? retryCount,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<DateTime?>? processedAt,
    Value<int>? rowid,
  }) {
    return SyncQueueTableCompanion(
      id: id ?? this.id,
      tableName_: tableName_ ?? this.tableName_,
      rowId: rowId ?? this.rowId,
      operation: operation ?? this.operation,
      payload: payload ?? this.payload,
      retryCount: retryCount ?? this.retryCount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      processedAt: processedAt ?? this.processedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tableName_.present) {
      map['table_name'] = Variable<String>(tableName_.value);
    }
    if (rowId.present) {
      map['row_id'] = Variable<String>(rowId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (processedAt.present) {
      map['processed_at'] = Variable<DateTime>(processedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueTableCompanion(')
          ..write('id: $id, ')
          ..write('tableName_: $tableName_, ')
          ..write('rowId: $rowId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('retryCount: $retryCount, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('processedAt: $processedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $HanjaTableTable hanjaTable = $HanjaTableTable(this);
  late final $HanjaExtendTableTable hanjaExtendTable = $HanjaExtendTableTable(
    this,
  );
  late final $ContentConfigTableTable contentConfigTable =
      $ContentConfigTableTable(this);
  late final $HanjaStrokeTableTable hanjaStrokeTable = $HanjaStrokeTableTable(
    this,
  );
  late final $HanjaStrokeSvgPathsTableTable hanjaStrokeSvgPathsTable =
      $HanjaStrokeSvgPathsTableTable(this);
  late final $HanjaWordTableTable hanjaWordTable = $HanjaWordTableTable(this);
  late final $HanjaIdiomTableTable hanjaIdiomTable = $HanjaIdiomTableTable(
    this,
  );
  late final $UserProgressTableTable userProgressTable =
      $UserProgressTableTable(this);
  late final $StudySessionTableTable studySessionTable =
      $StudySessionTableTable(this);
  late final $AnswerHistoryTableTable answerHistoryTable =
      $AnswerHistoryTableTable(this);
  late final $AppSettingsTableTable appSettingsTable = $AppSettingsTableTable(
    this,
  );
  late final $SyncQueueTableTable syncQueueTable = $SyncQueueTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    hanjaTable,
    hanjaExtendTable,
    contentConfigTable,
    hanjaStrokeTable,
    hanjaStrokeSvgPathsTable,
    hanjaWordTable,
    hanjaIdiomTable,
    userProgressTable,
    studySessionTable,
    answerHistoryTable,
    appSettingsTable,
    syncQueueTable,
  ];
}

typedef $$HanjaTableTableCreateCompanionBuilder =
    HanjaTableCompanion Function({
      required String id,
      Value<String?> serverId,
      required String character,
      required String reading,
      required String meaning,
      required String radical,
      required String radicalName,
      required int totalStrokes,
      required String schoolLevel,
      Value<int?> grade,
      Value<String?> origin,
      Value<String?> usageNote,
      Value<String> syncStatus,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> syncRevision,
      Value<int> rowid,
    });
typedef $$HanjaTableTableUpdateCompanionBuilder =
    HanjaTableCompanion Function({
      Value<String> id,
      Value<String?> serverId,
      Value<String> character,
      Value<String> reading,
      Value<String> meaning,
      Value<String> radical,
      Value<String> radicalName,
      Value<int> totalStrokes,
      Value<String> schoolLevel,
      Value<int?> grade,
      Value<String?> origin,
      Value<String?> usageNote,
      Value<String> syncStatus,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> syncRevision,
      Value<int> rowid,
    });

class $$HanjaTableTableFilterComposer
    extends Composer<_$AppDatabase, $HanjaTableTable> {
  $$HanjaTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get character => $composableBuilder(
    column: $table.character,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reading => $composableBuilder(
    column: $table.reading,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meaning => $composableBuilder(
    column: $table.meaning,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get radical => $composableBuilder(
    column: $table.radical,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get radicalName => $composableBuilder(
    column: $table.radicalName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalStrokes => $composableBuilder(
    column: $table.totalStrokes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolLevel => $composableBuilder(
    column: $table.schoolLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get usageNote => $composableBuilder(
    column: $table.usageNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncRevision => $composableBuilder(
    column: $table.syncRevision,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HanjaTableTableOrderingComposer
    extends Composer<_$AppDatabase, $HanjaTableTable> {
  $$HanjaTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get character => $composableBuilder(
    column: $table.character,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reading => $composableBuilder(
    column: $table.reading,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meaning => $composableBuilder(
    column: $table.meaning,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get radical => $composableBuilder(
    column: $table.radical,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get radicalName => $composableBuilder(
    column: $table.radicalName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalStrokes => $composableBuilder(
    column: $table.totalStrokes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolLevel => $composableBuilder(
    column: $table.schoolLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get usageNote => $composableBuilder(
    column: $table.usageNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncRevision => $composableBuilder(
    column: $table.syncRevision,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HanjaTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $HanjaTableTable> {
  $$HanjaTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get character =>
      $composableBuilder(column: $table.character, builder: (column) => column);

  GeneratedColumn<String> get reading =>
      $composableBuilder(column: $table.reading, builder: (column) => column);

  GeneratedColumn<String> get meaning =>
      $composableBuilder(column: $table.meaning, builder: (column) => column);

  GeneratedColumn<String> get radical =>
      $composableBuilder(column: $table.radical, builder: (column) => column);

  GeneratedColumn<String> get radicalName => $composableBuilder(
    column: $table.radicalName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalStrokes => $composableBuilder(
    column: $table.totalStrokes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get schoolLevel => $composableBuilder(
    column: $table.schoolLevel,
    builder: (column) => column,
  );

  GeneratedColumn<int> get grade =>
      $composableBuilder(column: $table.grade, builder: (column) => column);

  GeneratedColumn<String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumn<String> get usageNote =>
      $composableBuilder(column: $table.usageNote, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get syncRevision => $composableBuilder(
    column: $table.syncRevision,
    builder: (column) => column,
  );
}

class $$HanjaTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HanjaTableTable,
          HanjaTableData,
          $$HanjaTableTableFilterComposer,
          $$HanjaTableTableOrderingComposer,
          $$HanjaTableTableAnnotationComposer,
          $$HanjaTableTableCreateCompanionBuilder,
          $$HanjaTableTableUpdateCompanionBuilder,
          (
            HanjaTableData,
            BaseReferences<_$AppDatabase, $HanjaTableTable, HanjaTableData>,
          ),
          HanjaTableData,
          PrefetchHooks Function()
        > {
  $$HanjaTableTableTableManager(_$AppDatabase db, $HanjaTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HanjaTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HanjaTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HanjaTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<String> character = const Value.absent(),
                Value<String> reading = const Value.absent(),
                Value<String> meaning = const Value.absent(),
                Value<String> radical = const Value.absent(),
                Value<String> radicalName = const Value.absent(),
                Value<int> totalStrokes = const Value.absent(),
                Value<String> schoolLevel = const Value.absent(),
                Value<int?> grade = const Value.absent(),
                Value<String?> origin = const Value.absent(),
                Value<String?> usageNote = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> syncRevision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HanjaTableCompanion(
                id: id,
                serverId: serverId,
                character: character,
                reading: reading,
                meaning: meaning,
                radical: radical,
                radicalName: radicalName,
                totalStrokes: totalStrokes,
                schoolLevel: schoolLevel,
                grade: grade,
                origin: origin,
                usageNote: usageNote,
                syncStatus: syncStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncRevision: syncRevision,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> serverId = const Value.absent(),
                required String character,
                required String reading,
                required String meaning,
                required String radical,
                required String radicalName,
                required int totalStrokes,
                required String schoolLevel,
                Value<int?> grade = const Value.absent(),
                Value<String?> origin = const Value.absent(),
                Value<String?> usageNote = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> syncRevision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HanjaTableCompanion.insert(
                id: id,
                serverId: serverId,
                character: character,
                reading: reading,
                meaning: meaning,
                radical: radical,
                radicalName: radicalName,
                totalStrokes: totalStrokes,
                schoolLevel: schoolLevel,
                grade: grade,
                origin: origin,
                usageNote: usageNote,
                syncStatus: syncStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncRevision: syncRevision,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HanjaTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HanjaTableTable,
      HanjaTableData,
      $$HanjaTableTableFilterComposer,
      $$HanjaTableTableOrderingComposer,
      $$HanjaTableTableAnnotationComposer,
      $$HanjaTableTableCreateCompanionBuilder,
      $$HanjaTableTableUpdateCompanionBuilder,
      (
        HanjaTableData,
        BaseReferences<_$AppDatabase, $HanjaTableTable, HanjaTableData>,
      ),
      HanjaTableData,
      PrefetchHooks Function()
    >;
typedef $$HanjaExtendTableTableCreateCompanionBuilder =
    HanjaExtendTableCompanion Function({
      required String id,
      required String payloadJson,
      Value<DateTime> syncedAt,
      Value<int> rowid,
    });
typedef $$HanjaExtendTableTableUpdateCompanionBuilder =
    HanjaExtendTableCompanion Function({
      Value<String> id,
      Value<String> payloadJson,
      Value<DateTime> syncedAt,
      Value<int> rowid,
    });

class $$HanjaExtendTableTableFilterComposer
    extends Composer<_$AppDatabase, $HanjaExtendTableTable> {
  $$HanjaExtendTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HanjaExtendTableTableOrderingComposer
    extends Composer<_$AppDatabase, $HanjaExtendTableTable> {
  $$HanjaExtendTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HanjaExtendTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $HanjaExtendTableTable> {
  $$HanjaExtendTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$HanjaExtendTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HanjaExtendTableTable,
          HanjaExtendTableData,
          $$HanjaExtendTableTableFilterComposer,
          $$HanjaExtendTableTableOrderingComposer,
          $$HanjaExtendTableTableAnnotationComposer,
          $$HanjaExtendTableTableCreateCompanionBuilder,
          $$HanjaExtendTableTableUpdateCompanionBuilder,
          (
            HanjaExtendTableData,
            BaseReferences<
              _$AppDatabase,
              $HanjaExtendTableTable,
              HanjaExtendTableData
            >,
          ),
          HanjaExtendTableData,
          PrefetchHooks Function()
        > {
  $$HanjaExtendTableTableTableManager(
    _$AppDatabase db,
    $HanjaExtendTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HanjaExtendTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HanjaExtendTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HanjaExtendTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HanjaExtendTableCompanion(
                id: id,
                payloadJson: payloadJson,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String payloadJson,
                Value<DateTime> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HanjaExtendTableCompanion.insert(
                id: id,
                payloadJson: payloadJson,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HanjaExtendTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HanjaExtendTableTable,
      HanjaExtendTableData,
      $$HanjaExtendTableTableFilterComposer,
      $$HanjaExtendTableTableOrderingComposer,
      $$HanjaExtendTableTableAnnotationComposer,
      $$HanjaExtendTableTableCreateCompanionBuilder,
      $$HanjaExtendTableTableUpdateCompanionBuilder,
      (
        HanjaExtendTableData,
        BaseReferences<
          _$AppDatabase,
          $HanjaExtendTableTable,
          HanjaExtendTableData
        >,
      ),
      HanjaExtendTableData,
      PrefetchHooks Function()
    >;
typedef $$ContentConfigTableTableCreateCompanionBuilder =
    ContentConfigTableCompanion Function({
      required String id,
      Value<int?> contentVersion,
      Value<DateTime> syncedAt,
      Value<int> rowid,
    });
typedef $$ContentConfigTableTableUpdateCompanionBuilder =
    ContentConfigTableCompanion Function({
      Value<String> id,
      Value<int?> contentVersion,
      Value<DateTime> syncedAt,
      Value<int> rowid,
    });

class $$ContentConfigTableTableFilterComposer
    extends Composer<_$AppDatabase, $ContentConfigTableTable> {
  $$ContentConfigTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get contentVersion => $composableBuilder(
    column: $table.contentVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ContentConfigTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ContentConfigTableTable> {
  $$ContentConfigTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get contentVersion => $composableBuilder(
    column: $table.contentVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ContentConfigTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContentConfigTableTable> {
  $$ContentConfigTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get contentVersion => $composableBuilder(
    column: $table.contentVersion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$ContentConfigTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ContentConfigTableTable,
          ContentConfigTableData,
          $$ContentConfigTableTableFilterComposer,
          $$ContentConfigTableTableOrderingComposer,
          $$ContentConfigTableTableAnnotationComposer,
          $$ContentConfigTableTableCreateCompanionBuilder,
          $$ContentConfigTableTableUpdateCompanionBuilder,
          (
            ContentConfigTableData,
            BaseReferences<
              _$AppDatabase,
              $ContentConfigTableTable,
              ContentConfigTableData
            >,
          ),
          ContentConfigTableData,
          PrefetchHooks Function()
        > {
  $$ContentConfigTableTableTableManager(
    _$AppDatabase db,
    $ContentConfigTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContentConfigTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContentConfigTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContentConfigTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int?> contentVersion = const Value.absent(),
                Value<DateTime> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContentConfigTableCompanion(
                id: id,
                contentVersion: contentVersion,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<int?> contentVersion = const Value.absent(),
                Value<DateTime> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContentConfigTableCompanion.insert(
                id: id,
                contentVersion: contentVersion,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ContentConfigTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ContentConfigTableTable,
      ContentConfigTableData,
      $$ContentConfigTableTableFilterComposer,
      $$ContentConfigTableTableOrderingComposer,
      $$ContentConfigTableTableAnnotationComposer,
      $$ContentConfigTableTableCreateCompanionBuilder,
      $$ContentConfigTableTableUpdateCompanionBuilder,
      (
        ContentConfigTableData,
        BaseReferences<
          _$AppDatabase,
          $ContentConfigTableTable,
          ContentConfigTableData
        >,
      ),
      ContentConfigTableData,
      PrefetchHooks Function()
    >;
typedef $$HanjaStrokeTableTableCreateCompanionBuilder =
    HanjaStrokeTableCompanion Function({
      required String id,
      required String hanjaId,
      required int strokeIndex,
      required String normalizedPoints,
      Value<String?> direction,
      Value<int> rowid,
    });
typedef $$HanjaStrokeTableTableUpdateCompanionBuilder =
    HanjaStrokeTableCompanion Function({
      Value<String> id,
      Value<String> hanjaId,
      Value<int> strokeIndex,
      Value<String> normalizedPoints,
      Value<String?> direction,
      Value<int> rowid,
    });

class $$HanjaStrokeTableTableFilterComposer
    extends Composer<_$AppDatabase, $HanjaStrokeTableTable> {
  $$HanjaStrokeTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hanjaId => $composableBuilder(
    column: $table.hanjaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get strokeIndex => $composableBuilder(
    column: $table.strokeIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedPoints => $composableBuilder(
    column: $table.normalizedPoints,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HanjaStrokeTableTableOrderingComposer
    extends Composer<_$AppDatabase, $HanjaStrokeTableTable> {
  $$HanjaStrokeTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hanjaId => $composableBuilder(
    column: $table.hanjaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get strokeIndex => $composableBuilder(
    column: $table.strokeIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedPoints => $composableBuilder(
    column: $table.normalizedPoints,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HanjaStrokeTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $HanjaStrokeTableTable> {
  $$HanjaStrokeTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get hanjaId =>
      $composableBuilder(column: $table.hanjaId, builder: (column) => column);

  GeneratedColumn<int> get strokeIndex => $composableBuilder(
    column: $table.strokeIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get normalizedPoints => $composableBuilder(
    column: $table.normalizedPoints,
    builder: (column) => column,
  );

  GeneratedColumn<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);
}

class $$HanjaStrokeTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HanjaStrokeTableTable,
          HanjaStrokeTableData,
          $$HanjaStrokeTableTableFilterComposer,
          $$HanjaStrokeTableTableOrderingComposer,
          $$HanjaStrokeTableTableAnnotationComposer,
          $$HanjaStrokeTableTableCreateCompanionBuilder,
          $$HanjaStrokeTableTableUpdateCompanionBuilder,
          (
            HanjaStrokeTableData,
            BaseReferences<
              _$AppDatabase,
              $HanjaStrokeTableTable,
              HanjaStrokeTableData
            >,
          ),
          HanjaStrokeTableData,
          PrefetchHooks Function()
        > {
  $$HanjaStrokeTableTableTableManager(
    _$AppDatabase db,
    $HanjaStrokeTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HanjaStrokeTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HanjaStrokeTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HanjaStrokeTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> hanjaId = const Value.absent(),
                Value<int> strokeIndex = const Value.absent(),
                Value<String> normalizedPoints = const Value.absent(),
                Value<String?> direction = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HanjaStrokeTableCompanion(
                id: id,
                hanjaId: hanjaId,
                strokeIndex: strokeIndex,
                normalizedPoints: normalizedPoints,
                direction: direction,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String hanjaId,
                required int strokeIndex,
                required String normalizedPoints,
                Value<String?> direction = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HanjaStrokeTableCompanion.insert(
                id: id,
                hanjaId: hanjaId,
                strokeIndex: strokeIndex,
                normalizedPoints: normalizedPoints,
                direction: direction,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HanjaStrokeTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HanjaStrokeTableTable,
      HanjaStrokeTableData,
      $$HanjaStrokeTableTableFilterComposer,
      $$HanjaStrokeTableTableOrderingComposer,
      $$HanjaStrokeTableTableAnnotationComposer,
      $$HanjaStrokeTableTableCreateCompanionBuilder,
      $$HanjaStrokeTableTableUpdateCompanionBuilder,
      (
        HanjaStrokeTableData,
        BaseReferences<
          _$AppDatabase,
          $HanjaStrokeTableTable,
          HanjaStrokeTableData
        >,
      ),
      HanjaStrokeTableData,
      PrefetchHooks Function()
    >;
typedef $$HanjaStrokeSvgPathsTableTableCreateCompanionBuilder =
    HanjaStrokeSvgPathsTableCompanion Function({
      required String hanjaId,
      required String pathsJson,
      Value<int> rowid,
    });
typedef $$HanjaStrokeSvgPathsTableTableUpdateCompanionBuilder =
    HanjaStrokeSvgPathsTableCompanion Function({
      Value<String> hanjaId,
      Value<String> pathsJson,
      Value<int> rowid,
    });

class $$HanjaStrokeSvgPathsTableTableFilterComposer
    extends Composer<_$AppDatabase, $HanjaStrokeSvgPathsTableTable> {
  $$HanjaStrokeSvgPathsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get hanjaId => $composableBuilder(
    column: $table.hanjaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pathsJson => $composableBuilder(
    column: $table.pathsJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HanjaStrokeSvgPathsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $HanjaStrokeSvgPathsTableTable> {
  $$HanjaStrokeSvgPathsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get hanjaId => $composableBuilder(
    column: $table.hanjaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pathsJson => $composableBuilder(
    column: $table.pathsJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HanjaStrokeSvgPathsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $HanjaStrokeSvgPathsTableTable> {
  $$HanjaStrokeSvgPathsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get hanjaId =>
      $composableBuilder(column: $table.hanjaId, builder: (column) => column);

  GeneratedColumn<String> get pathsJson =>
      $composableBuilder(column: $table.pathsJson, builder: (column) => column);
}

class $$HanjaStrokeSvgPathsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HanjaStrokeSvgPathsTableTable,
          HanjaStrokeSvgPathsTableData,
          $$HanjaStrokeSvgPathsTableTableFilterComposer,
          $$HanjaStrokeSvgPathsTableTableOrderingComposer,
          $$HanjaStrokeSvgPathsTableTableAnnotationComposer,
          $$HanjaStrokeSvgPathsTableTableCreateCompanionBuilder,
          $$HanjaStrokeSvgPathsTableTableUpdateCompanionBuilder,
          (
            HanjaStrokeSvgPathsTableData,
            BaseReferences<
              _$AppDatabase,
              $HanjaStrokeSvgPathsTableTable,
              HanjaStrokeSvgPathsTableData
            >,
          ),
          HanjaStrokeSvgPathsTableData,
          PrefetchHooks Function()
        > {
  $$HanjaStrokeSvgPathsTableTableTableManager(
    _$AppDatabase db,
    $HanjaStrokeSvgPathsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HanjaStrokeSvgPathsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$HanjaStrokeSvgPathsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$HanjaStrokeSvgPathsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> hanjaId = const Value.absent(),
                Value<String> pathsJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HanjaStrokeSvgPathsTableCompanion(
                hanjaId: hanjaId,
                pathsJson: pathsJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String hanjaId,
                required String pathsJson,
                Value<int> rowid = const Value.absent(),
              }) => HanjaStrokeSvgPathsTableCompanion.insert(
                hanjaId: hanjaId,
                pathsJson: pathsJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HanjaStrokeSvgPathsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HanjaStrokeSvgPathsTableTable,
      HanjaStrokeSvgPathsTableData,
      $$HanjaStrokeSvgPathsTableTableFilterComposer,
      $$HanjaStrokeSvgPathsTableTableOrderingComposer,
      $$HanjaStrokeSvgPathsTableTableAnnotationComposer,
      $$HanjaStrokeSvgPathsTableTableCreateCompanionBuilder,
      $$HanjaStrokeSvgPathsTableTableUpdateCompanionBuilder,
      (
        HanjaStrokeSvgPathsTableData,
        BaseReferences<
          _$AppDatabase,
          $HanjaStrokeSvgPathsTableTable,
          HanjaStrokeSvgPathsTableData
        >,
      ),
      HanjaStrokeSvgPathsTableData,
      PrefetchHooks Function()
    >;
typedef $$HanjaWordTableTableCreateCompanionBuilder =
    HanjaWordTableCompanion Function({
      required String id,
      required String hanjaId,
      required String word,
      required String reading,
      required String meaning,
      Value<String?> example,
      Value<int> rowid,
    });
typedef $$HanjaWordTableTableUpdateCompanionBuilder =
    HanjaWordTableCompanion Function({
      Value<String> id,
      Value<String> hanjaId,
      Value<String> word,
      Value<String> reading,
      Value<String> meaning,
      Value<String?> example,
      Value<int> rowid,
    });

class $$HanjaWordTableTableFilterComposer
    extends Composer<_$AppDatabase, $HanjaWordTableTable> {
  $$HanjaWordTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hanjaId => $composableBuilder(
    column: $table.hanjaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get word => $composableBuilder(
    column: $table.word,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reading => $composableBuilder(
    column: $table.reading,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meaning => $composableBuilder(
    column: $table.meaning,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get example => $composableBuilder(
    column: $table.example,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HanjaWordTableTableOrderingComposer
    extends Composer<_$AppDatabase, $HanjaWordTableTable> {
  $$HanjaWordTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hanjaId => $composableBuilder(
    column: $table.hanjaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get word => $composableBuilder(
    column: $table.word,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reading => $composableBuilder(
    column: $table.reading,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meaning => $composableBuilder(
    column: $table.meaning,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get example => $composableBuilder(
    column: $table.example,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HanjaWordTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $HanjaWordTableTable> {
  $$HanjaWordTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get hanjaId =>
      $composableBuilder(column: $table.hanjaId, builder: (column) => column);

  GeneratedColumn<String> get word =>
      $composableBuilder(column: $table.word, builder: (column) => column);

  GeneratedColumn<String> get reading =>
      $composableBuilder(column: $table.reading, builder: (column) => column);

  GeneratedColumn<String> get meaning =>
      $composableBuilder(column: $table.meaning, builder: (column) => column);

  GeneratedColumn<String> get example =>
      $composableBuilder(column: $table.example, builder: (column) => column);
}

class $$HanjaWordTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HanjaWordTableTable,
          HanjaWordTableData,
          $$HanjaWordTableTableFilterComposer,
          $$HanjaWordTableTableOrderingComposer,
          $$HanjaWordTableTableAnnotationComposer,
          $$HanjaWordTableTableCreateCompanionBuilder,
          $$HanjaWordTableTableUpdateCompanionBuilder,
          (
            HanjaWordTableData,
            BaseReferences<
              _$AppDatabase,
              $HanjaWordTableTable,
              HanjaWordTableData
            >,
          ),
          HanjaWordTableData,
          PrefetchHooks Function()
        > {
  $$HanjaWordTableTableTableManager(
    _$AppDatabase db,
    $HanjaWordTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HanjaWordTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HanjaWordTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HanjaWordTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> hanjaId = const Value.absent(),
                Value<String> word = const Value.absent(),
                Value<String> reading = const Value.absent(),
                Value<String> meaning = const Value.absent(),
                Value<String?> example = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HanjaWordTableCompanion(
                id: id,
                hanjaId: hanjaId,
                word: word,
                reading: reading,
                meaning: meaning,
                example: example,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String hanjaId,
                required String word,
                required String reading,
                required String meaning,
                Value<String?> example = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HanjaWordTableCompanion.insert(
                id: id,
                hanjaId: hanjaId,
                word: word,
                reading: reading,
                meaning: meaning,
                example: example,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HanjaWordTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HanjaWordTableTable,
      HanjaWordTableData,
      $$HanjaWordTableTableFilterComposer,
      $$HanjaWordTableTableOrderingComposer,
      $$HanjaWordTableTableAnnotationComposer,
      $$HanjaWordTableTableCreateCompanionBuilder,
      $$HanjaWordTableTableUpdateCompanionBuilder,
      (
        HanjaWordTableData,
        BaseReferences<_$AppDatabase, $HanjaWordTableTable, HanjaWordTableData>,
      ),
      HanjaWordTableData,
      PrefetchHooks Function()
    >;
typedef $$HanjaIdiomTableTableCreateCompanionBuilder =
    HanjaIdiomTableCompanion Function({
      required String id,
      required String hanjaId,
      required String idiom,
      required String reading,
      required String meaning,
      Value<String?> origin,
      Value<int> rowid,
    });
typedef $$HanjaIdiomTableTableUpdateCompanionBuilder =
    HanjaIdiomTableCompanion Function({
      Value<String> id,
      Value<String> hanjaId,
      Value<String> idiom,
      Value<String> reading,
      Value<String> meaning,
      Value<String?> origin,
      Value<int> rowid,
    });

class $$HanjaIdiomTableTableFilterComposer
    extends Composer<_$AppDatabase, $HanjaIdiomTableTable> {
  $$HanjaIdiomTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hanjaId => $composableBuilder(
    column: $table.hanjaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get idiom => $composableBuilder(
    column: $table.idiom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reading => $composableBuilder(
    column: $table.reading,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meaning => $composableBuilder(
    column: $table.meaning,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HanjaIdiomTableTableOrderingComposer
    extends Composer<_$AppDatabase, $HanjaIdiomTableTable> {
  $$HanjaIdiomTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hanjaId => $composableBuilder(
    column: $table.hanjaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get idiom => $composableBuilder(
    column: $table.idiom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reading => $composableBuilder(
    column: $table.reading,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meaning => $composableBuilder(
    column: $table.meaning,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HanjaIdiomTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $HanjaIdiomTableTable> {
  $$HanjaIdiomTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get hanjaId =>
      $composableBuilder(column: $table.hanjaId, builder: (column) => column);

  GeneratedColumn<String> get idiom =>
      $composableBuilder(column: $table.idiom, builder: (column) => column);

  GeneratedColumn<String> get reading =>
      $composableBuilder(column: $table.reading, builder: (column) => column);

  GeneratedColumn<String> get meaning =>
      $composableBuilder(column: $table.meaning, builder: (column) => column);

  GeneratedColumn<String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);
}

class $$HanjaIdiomTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HanjaIdiomTableTable,
          HanjaIdiomTableData,
          $$HanjaIdiomTableTableFilterComposer,
          $$HanjaIdiomTableTableOrderingComposer,
          $$HanjaIdiomTableTableAnnotationComposer,
          $$HanjaIdiomTableTableCreateCompanionBuilder,
          $$HanjaIdiomTableTableUpdateCompanionBuilder,
          (
            HanjaIdiomTableData,
            BaseReferences<
              _$AppDatabase,
              $HanjaIdiomTableTable,
              HanjaIdiomTableData
            >,
          ),
          HanjaIdiomTableData,
          PrefetchHooks Function()
        > {
  $$HanjaIdiomTableTableTableManager(
    _$AppDatabase db,
    $HanjaIdiomTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HanjaIdiomTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HanjaIdiomTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HanjaIdiomTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> hanjaId = const Value.absent(),
                Value<String> idiom = const Value.absent(),
                Value<String> reading = const Value.absent(),
                Value<String> meaning = const Value.absent(),
                Value<String?> origin = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HanjaIdiomTableCompanion(
                id: id,
                hanjaId: hanjaId,
                idiom: idiom,
                reading: reading,
                meaning: meaning,
                origin: origin,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String hanjaId,
                required String idiom,
                required String reading,
                required String meaning,
                Value<String?> origin = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HanjaIdiomTableCompanion.insert(
                id: id,
                hanjaId: hanjaId,
                idiom: idiom,
                reading: reading,
                meaning: meaning,
                origin: origin,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HanjaIdiomTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HanjaIdiomTableTable,
      HanjaIdiomTableData,
      $$HanjaIdiomTableTableFilterComposer,
      $$HanjaIdiomTableTableOrderingComposer,
      $$HanjaIdiomTableTableAnnotationComposer,
      $$HanjaIdiomTableTableCreateCompanionBuilder,
      $$HanjaIdiomTableTableUpdateCompanionBuilder,
      (
        HanjaIdiomTableData,
        BaseReferences<
          _$AppDatabase,
          $HanjaIdiomTableTable,
          HanjaIdiomTableData
        >,
      ),
      HanjaIdiomTableData,
      PrefetchHooks Function()
    >;
typedef $$UserProgressTableTableCreateCompanionBuilder =
    UserProgressTableCompanion Function({
      required String id,
      Value<String> userId,
      required String hanjaId,
      Value<String> status,
      Value<int> totalAttempts,
      Value<int> correctAttempts,
      Value<double> accuracyRate,
      Value<DateTime?> lastStudiedAt,
      Value<bool> isBookmarked,
      Value<DateTime?> nextReviewAt,
      Value<int> reviewCount,
      Value<int> intervalDays,
      Value<double> easeFactor,
      Value<String> syncStatus,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> syncRevision,
      Value<int> rowid,
    });
typedef $$UserProgressTableTableUpdateCompanionBuilder =
    UserProgressTableCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> hanjaId,
      Value<String> status,
      Value<int> totalAttempts,
      Value<int> correctAttempts,
      Value<double> accuracyRate,
      Value<DateTime?> lastStudiedAt,
      Value<bool> isBookmarked,
      Value<DateTime?> nextReviewAt,
      Value<int> reviewCount,
      Value<int> intervalDays,
      Value<double> easeFactor,
      Value<String> syncStatus,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> syncRevision,
      Value<int> rowid,
    });

class $$UserProgressTableTableFilterComposer
    extends Composer<_$AppDatabase, $UserProgressTableTable> {
  $$UserProgressTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hanjaId => $composableBuilder(
    column: $table.hanjaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalAttempts => $composableBuilder(
    column: $table.totalAttempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get correctAttempts => $composableBuilder(
    column: $table.correctAttempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accuracyRate => $composableBuilder(
    column: $table.accuracyRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastStudiedAt => $composableBuilder(
    column: $table.lastStudiedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBookmarked => $composableBuilder(
    column: $table.isBookmarked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextReviewAt => $composableBuilder(
    column: $table.nextReviewAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reviewCount => $composableBuilder(
    column: $table.reviewCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get easeFactor => $composableBuilder(
    column: $table.easeFactor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncRevision => $composableBuilder(
    column: $table.syncRevision,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserProgressTableTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProgressTableTable> {
  $$UserProgressTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hanjaId => $composableBuilder(
    column: $table.hanjaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalAttempts => $composableBuilder(
    column: $table.totalAttempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get correctAttempts => $composableBuilder(
    column: $table.correctAttempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accuracyRate => $composableBuilder(
    column: $table.accuracyRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastStudiedAt => $composableBuilder(
    column: $table.lastStudiedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBookmarked => $composableBuilder(
    column: $table.isBookmarked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextReviewAt => $composableBuilder(
    column: $table.nextReviewAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reviewCount => $composableBuilder(
    column: $table.reviewCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get easeFactor => $composableBuilder(
    column: $table.easeFactor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncRevision => $composableBuilder(
    column: $table.syncRevision,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserProgressTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProgressTableTable> {
  $$UserProgressTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get hanjaId =>
      $composableBuilder(column: $table.hanjaId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get totalAttempts => $composableBuilder(
    column: $table.totalAttempts,
    builder: (column) => column,
  );

  GeneratedColumn<int> get correctAttempts => $composableBuilder(
    column: $table.correctAttempts,
    builder: (column) => column,
  );

  GeneratedColumn<double> get accuracyRate => $composableBuilder(
    column: $table.accuracyRate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastStudiedAt => $composableBuilder(
    column: $table.lastStudiedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isBookmarked => $composableBuilder(
    column: $table.isBookmarked,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get nextReviewAt => $composableBuilder(
    column: $table.nextReviewAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reviewCount => $composableBuilder(
    column: $table.reviewCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => column,
  );

  GeneratedColumn<double> get easeFactor => $composableBuilder(
    column: $table.easeFactor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get syncRevision => $composableBuilder(
    column: $table.syncRevision,
    builder: (column) => column,
  );
}

class $$UserProgressTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProgressTableTable,
          UserProgressTableData,
          $$UserProgressTableTableFilterComposer,
          $$UserProgressTableTableOrderingComposer,
          $$UserProgressTableTableAnnotationComposer,
          $$UserProgressTableTableCreateCompanionBuilder,
          $$UserProgressTableTableUpdateCompanionBuilder,
          (
            UserProgressTableData,
            BaseReferences<
              _$AppDatabase,
              $UserProgressTableTable,
              UserProgressTableData
            >,
          ),
          UserProgressTableData,
          PrefetchHooks Function()
        > {
  $$UserProgressTableTableTableManager(
    _$AppDatabase db,
    $UserProgressTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProgressTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProgressTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProgressTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> hanjaId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> totalAttempts = const Value.absent(),
                Value<int> correctAttempts = const Value.absent(),
                Value<double> accuracyRate = const Value.absent(),
                Value<DateTime?> lastStudiedAt = const Value.absent(),
                Value<bool> isBookmarked = const Value.absent(),
                Value<DateTime?> nextReviewAt = const Value.absent(),
                Value<int> reviewCount = const Value.absent(),
                Value<int> intervalDays = const Value.absent(),
                Value<double> easeFactor = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> syncRevision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserProgressTableCompanion(
                id: id,
                userId: userId,
                hanjaId: hanjaId,
                status: status,
                totalAttempts: totalAttempts,
                correctAttempts: correctAttempts,
                accuracyRate: accuracyRate,
                lastStudiedAt: lastStudiedAt,
                isBookmarked: isBookmarked,
                nextReviewAt: nextReviewAt,
                reviewCount: reviewCount,
                intervalDays: intervalDays,
                easeFactor: easeFactor,
                syncStatus: syncStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncRevision: syncRevision,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> userId = const Value.absent(),
                required String hanjaId,
                Value<String> status = const Value.absent(),
                Value<int> totalAttempts = const Value.absent(),
                Value<int> correctAttempts = const Value.absent(),
                Value<double> accuracyRate = const Value.absent(),
                Value<DateTime?> lastStudiedAt = const Value.absent(),
                Value<bool> isBookmarked = const Value.absent(),
                Value<DateTime?> nextReviewAt = const Value.absent(),
                Value<int> reviewCount = const Value.absent(),
                Value<int> intervalDays = const Value.absent(),
                Value<double> easeFactor = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> syncRevision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserProgressTableCompanion.insert(
                id: id,
                userId: userId,
                hanjaId: hanjaId,
                status: status,
                totalAttempts: totalAttempts,
                correctAttempts: correctAttempts,
                accuracyRate: accuracyRate,
                lastStudiedAt: lastStudiedAt,
                isBookmarked: isBookmarked,
                nextReviewAt: nextReviewAt,
                reviewCount: reviewCount,
                intervalDays: intervalDays,
                easeFactor: easeFactor,
                syncStatus: syncStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncRevision: syncRevision,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserProgressTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProgressTableTable,
      UserProgressTableData,
      $$UserProgressTableTableFilterComposer,
      $$UserProgressTableTableOrderingComposer,
      $$UserProgressTableTableAnnotationComposer,
      $$UserProgressTableTableCreateCompanionBuilder,
      $$UserProgressTableTableUpdateCompanionBuilder,
      (
        UserProgressTableData,
        BaseReferences<
          _$AppDatabase,
          $UserProgressTableTable,
          UserProgressTableData
        >,
      ),
      UserProgressTableData,
      PrefetchHooks Function()
    >;
typedef $$StudySessionTableTableCreateCompanionBuilder =
    StudySessionTableCompanion Function({
      required String id,
      required DateTime startedAt,
      Value<DateTime?> endedAt,
      Value<int> totalHanja,
      Value<int> correctCount,
      required String sessionType,
      Value<String> syncStatus,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$StudySessionTableTableUpdateCompanionBuilder =
    StudySessionTableCompanion Function({
      Value<String> id,
      Value<DateTime> startedAt,
      Value<DateTime?> endedAt,
      Value<int> totalHanja,
      Value<int> correctCount,
      Value<String> sessionType,
      Value<String> syncStatus,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$StudySessionTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $StudySessionTableTable,
          StudySessionTableData
        > {
  $$StudySessionTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $AnswerHistoryTableTable,
    List<AnswerHistoryTableData>
  >
  _answerHistoryTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.answerHistoryTable,
        aliasName: $_aliasNameGenerator(
          db.studySessionTable.id,
          db.answerHistoryTable.sessionId,
        ),
      );

  $$AnswerHistoryTableTableProcessedTableManager get answerHistoryTableRefs {
    final manager = $$AnswerHistoryTableTableTableManager(
      $_db,
      $_db.answerHistoryTable,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _answerHistoryTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$StudySessionTableTableFilterComposer
    extends Composer<_$AppDatabase, $StudySessionTableTable> {
  $$StudySessionTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalHanja => $composableBuilder(
    column: $table.totalHanja,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get correctCount => $composableBuilder(
    column: $table.correctCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionType => $composableBuilder(
    column: $table.sessionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> answerHistoryTableRefs(
    Expression<bool> Function($$AnswerHistoryTableTableFilterComposer f) f,
  ) {
    final $$AnswerHistoryTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.answerHistoryTable,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AnswerHistoryTableTableFilterComposer(
            $db: $db,
            $table: $db.answerHistoryTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StudySessionTableTableOrderingComposer
    extends Composer<_$AppDatabase, $StudySessionTableTable> {
  $$StudySessionTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalHanja => $composableBuilder(
    column: $table.totalHanja,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get correctCount => $composableBuilder(
    column: $table.correctCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionType => $composableBuilder(
    column: $table.sessionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StudySessionTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $StudySessionTableTable> {
  $$StudySessionTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<int> get totalHanja => $composableBuilder(
    column: $table.totalHanja,
    builder: (column) => column,
  );

  GeneratedColumn<int> get correctCount => $composableBuilder(
    column: $table.correctCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sessionType => $composableBuilder(
    column: $table.sessionType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> answerHistoryTableRefs<T extends Object>(
    Expression<T> Function($$AnswerHistoryTableTableAnnotationComposer a) f,
  ) {
    final $$AnswerHistoryTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.answerHistoryTable,
          getReferencedColumn: (t) => t.sessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AnswerHistoryTableTableAnnotationComposer(
                $db: $db,
                $table: $db.answerHistoryTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$StudySessionTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StudySessionTableTable,
          StudySessionTableData,
          $$StudySessionTableTableFilterComposer,
          $$StudySessionTableTableOrderingComposer,
          $$StudySessionTableTableAnnotationComposer,
          $$StudySessionTableTableCreateCompanionBuilder,
          $$StudySessionTableTableUpdateCompanionBuilder,
          (StudySessionTableData, $$StudySessionTableTableReferences),
          StudySessionTableData,
          PrefetchHooks Function({bool answerHistoryTableRefs})
        > {
  $$StudySessionTableTableTableManager(
    _$AppDatabase db,
    $StudySessionTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudySessionTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudySessionTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StudySessionTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int> totalHanja = const Value.absent(),
                Value<int> correctCount = const Value.absent(),
                Value<String> sessionType = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StudySessionTableCompanion(
                id: id,
                startedAt: startedAt,
                endedAt: endedAt,
                totalHanja: totalHanja,
                correctCount: correctCount,
                sessionType: sessionType,
                syncStatus: syncStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int> totalHanja = const Value.absent(),
                Value<int> correctCount = const Value.absent(),
                required String sessionType,
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StudySessionTableCompanion.insert(
                id: id,
                startedAt: startedAt,
                endedAt: endedAt,
                totalHanja: totalHanja,
                correctCount: correctCount,
                sessionType: sessionType,
                syncStatus: syncStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StudySessionTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({answerHistoryTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (answerHistoryTableRefs) db.answerHistoryTable,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (answerHistoryTableRefs)
                    await $_getPrefetchedData<
                      StudySessionTableData,
                      $StudySessionTableTable,
                      AnswerHistoryTableData
                    >(
                      currentTable: table,
                      referencedTable: $$StudySessionTableTableReferences
                          ._answerHistoryTableRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$StudySessionTableTableReferences(
                            db,
                            table,
                            p0,
                          ).answerHistoryTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.sessionId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$StudySessionTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StudySessionTableTable,
      StudySessionTableData,
      $$StudySessionTableTableFilterComposer,
      $$StudySessionTableTableOrderingComposer,
      $$StudySessionTableTableAnnotationComposer,
      $$StudySessionTableTableCreateCompanionBuilder,
      $$StudySessionTableTableUpdateCompanionBuilder,
      (StudySessionTableData, $$StudySessionTableTableReferences),
      StudySessionTableData,
      PrefetchHooks Function({bool answerHistoryTableRefs})
    >;
typedef $$AnswerHistoryTableTableCreateCompanionBuilder =
    AnswerHistoryTableCompanion Function({
      required String id,
      required String sessionId,
      required String hanjaId,
      required DateTime answeredAt,
      required bool isCorrect,
      Value<double> accuracyScore,
      Value<String?> strokesJson,
      Value<String> syncStatus,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$AnswerHistoryTableTableUpdateCompanionBuilder =
    AnswerHistoryTableCompanion Function({
      Value<String> id,
      Value<String> sessionId,
      Value<String> hanjaId,
      Value<DateTime> answeredAt,
      Value<bool> isCorrect,
      Value<double> accuracyScore,
      Value<String?> strokesJson,
      Value<String> syncStatus,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$AnswerHistoryTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $AnswerHistoryTableTable,
          AnswerHistoryTableData
        > {
  $$AnswerHistoryTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $StudySessionTableTable _sessionIdTable(_$AppDatabase db) =>
      db.studySessionTable.createAlias(
        $_aliasNameGenerator(
          db.answerHistoryTable.sessionId,
          db.studySessionTable.id,
        ),
      );

  $$StudySessionTableTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$StudySessionTableTableTableManager(
      $_db,
      $_db.studySessionTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AnswerHistoryTableTableFilterComposer
    extends Composer<_$AppDatabase, $AnswerHistoryTableTable> {
  $$AnswerHistoryTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hanjaId => $composableBuilder(
    column: $table.hanjaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCorrect => $composableBuilder(
    column: $table.isCorrect,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accuracyScore => $composableBuilder(
    column: $table.accuracyScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get strokesJson => $composableBuilder(
    column: $table.strokesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$StudySessionTableTableFilterComposer get sessionId {
    final $$StudySessionTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.studySessionTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudySessionTableTableFilterComposer(
            $db: $db,
            $table: $db.studySessionTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AnswerHistoryTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AnswerHistoryTableTable> {
  $$AnswerHistoryTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hanjaId => $composableBuilder(
    column: $table.hanjaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCorrect => $composableBuilder(
    column: $table.isCorrect,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accuracyScore => $composableBuilder(
    column: $table.accuracyScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get strokesJson => $composableBuilder(
    column: $table.strokesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$StudySessionTableTableOrderingComposer get sessionId {
    final $$StudySessionTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.studySessionTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudySessionTableTableOrderingComposer(
            $db: $db,
            $table: $db.studySessionTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AnswerHistoryTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AnswerHistoryTableTable> {
  $$AnswerHistoryTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get hanjaId =>
      $composableBuilder(column: $table.hanjaId, builder: (column) => column);

  GeneratedColumn<DateTime> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCorrect =>
      $composableBuilder(column: $table.isCorrect, builder: (column) => column);

  GeneratedColumn<double> get accuracyScore => $composableBuilder(
    column: $table.accuracyScore,
    builder: (column) => column,
  );

  GeneratedColumn<String> get strokesJson => $composableBuilder(
    column: $table.strokesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$StudySessionTableTableAnnotationComposer get sessionId {
    final $$StudySessionTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sessionId,
          referencedTable: $db.studySessionTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StudySessionTableTableAnnotationComposer(
                $db: $db,
                $table: $db.studySessionTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$AnswerHistoryTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AnswerHistoryTableTable,
          AnswerHistoryTableData,
          $$AnswerHistoryTableTableFilterComposer,
          $$AnswerHistoryTableTableOrderingComposer,
          $$AnswerHistoryTableTableAnnotationComposer,
          $$AnswerHistoryTableTableCreateCompanionBuilder,
          $$AnswerHistoryTableTableUpdateCompanionBuilder,
          (AnswerHistoryTableData, $$AnswerHistoryTableTableReferences),
          AnswerHistoryTableData,
          PrefetchHooks Function({bool sessionId})
        > {
  $$AnswerHistoryTableTableTableManager(
    _$AppDatabase db,
    $AnswerHistoryTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AnswerHistoryTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AnswerHistoryTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AnswerHistoryTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> hanjaId = const Value.absent(),
                Value<DateTime> answeredAt = const Value.absent(),
                Value<bool> isCorrect = const Value.absent(),
                Value<double> accuracyScore = const Value.absent(),
                Value<String?> strokesJson = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AnswerHistoryTableCompanion(
                id: id,
                sessionId: sessionId,
                hanjaId: hanjaId,
                answeredAt: answeredAt,
                isCorrect: isCorrect,
                accuracyScore: accuracyScore,
                strokesJson: strokesJson,
                syncStatus: syncStatus,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                required String hanjaId,
                required DateTime answeredAt,
                required bool isCorrect,
                Value<double> accuracyScore = const Value.absent(),
                Value<String?> strokesJson = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AnswerHistoryTableCompanion.insert(
                id: id,
                sessionId: sessionId,
                hanjaId: hanjaId,
                answeredAt: answeredAt,
                isCorrect: isCorrect,
                accuracyScore: accuracyScore,
                strokesJson: strokesJson,
                syncStatus: syncStatus,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AnswerHistoryTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable:
                                    $$AnswerHistoryTableTableReferences
                                        ._sessionIdTable(db),
                                referencedColumn:
                                    $$AnswerHistoryTableTableReferences
                                        ._sessionIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AnswerHistoryTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AnswerHistoryTableTable,
      AnswerHistoryTableData,
      $$AnswerHistoryTableTableFilterComposer,
      $$AnswerHistoryTableTableOrderingComposer,
      $$AnswerHistoryTableTableAnnotationComposer,
      $$AnswerHistoryTableTableCreateCompanionBuilder,
      $$AnswerHistoryTableTableUpdateCompanionBuilder,
      (AnswerHistoryTableData, $$AnswerHistoryTableTableReferences),
      AnswerHistoryTableData,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$AppSettingsTableTableCreateCompanionBuilder =
    AppSettingsTableCompanion Function({
      required String key,
      required String value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$AppSettingsTableTableUpdateCompanionBuilder =
    AppSettingsTableCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$AppSettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppSettingsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTableTable,
          AppSettingsTableData,
          $$AppSettingsTableTableFilterComposer,
          $$AppSettingsTableTableOrderingComposer,
          $$AppSettingsTableTableAnnotationComposer,
          $$AppSettingsTableTableCreateCompanionBuilder,
          $$AppSettingsTableTableUpdateCompanionBuilder,
          (
            AppSettingsTableData,
            BaseReferences<
              _$AppDatabase,
              $AppSettingsTableTable,
              AppSettingsTableData
            >,
          ),
          AppSettingsTableData,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableTableManager(
    _$AppDatabase db,
    $AppSettingsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsTableCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsTableCompanion.insert(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTableTable,
      AppSettingsTableData,
      $$AppSettingsTableTableFilterComposer,
      $$AppSettingsTableTableOrderingComposer,
      $$AppSettingsTableTableAnnotationComposer,
      $$AppSettingsTableTableCreateCompanionBuilder,
      $$AppSettingsTableTableUpdateCompanionBuilder,
      (
        AppSettingsTableData,
        BaseReferences<
          _$AppDatabase,
          $AppSettingsTableTable,
          AppSettingsTableData
        >,
      ),
      AppSettingsTableData,
      PrefetchHooks Function()
    >;
typedef $$SyncQueueTableTableCreateCompanionBuilder =
    SyncQueueTableCompanion Function({
      required String id,
      required String tableName_,
      required String rowId,
      required String operation,
      required String payload,
      Value<int> retryCount,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<DateTime?> processedAt,
      Value<int> rowid,
    });
typedef $$SyncQueueTableTableUpdateCompanionBuilder =
    SyncQueueTableCompanion Function({
      Value<String> id,
      Value<String> tableName_,
      Value<String> rowId,
      Value<String> operation,
      Value<String> payload,
      Value<int> retryCount,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<DateTime?> processedAt,
      Value<int> rowid,
    });

class $$SyncQueueTableTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTableTable> {
  $$SyncQueueTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tableName_ => $composableBuilder(
    column: $table.tableName_,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rowId => $composableBuilder(
    column: $table.rowId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get processedAt => $composableBuilder(
    column: $table.processedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncQueueTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTableTable> {
  $$SyncQueueTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tableName_ => $composableBuilder(
    column: $table.tableName_,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rowId => $composableBuilder(
    column: $table.rowId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get processedAt => $composableBuilder(
    column: $table.processedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncQueueTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTableTable> {
  $$SyncQueueTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tableName_ => $composableBuilder(
    column: $table.tableName_,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rowId =>
      $composableBuilder(column: $table.rowId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get processedAt => $composableBuilder(
    column: $table.processedAt,
    builder: (column) => column,
  );
}

class $$SyncQueueTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQueueTableTable,
          SyncQueueTableData,
          $$SyncQueueTableTableFilterComposer,
          $$SyncQueueTableTableOrderingComposer,
          $$SyncQueueTableTableAnnotationComposer,
          $$SyncQueueTableTableCreateCompanionBuilder,
          $$SyncQueueTableTableUpdateCompanionBuilder,
          (
            SyncQueueTableData,
            BaseReferences<
              _$AppDatabase,
              $SyncQueueTableTable,
              SyncQueueTableData
            >,
          ),
          SyncQueueTableData,
          PrefetchHooks Function()
        > {
  $$SyncQueueTableTableTableManager(
    _$AppDatabase db,
    $SyncQueueTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tableName_ = const Value.absent(),
                Value<String> rowId = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> processedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncQueueTableCompanion(
                id: id,
                tableName_: tableName_,
                rowId: rowId,
                operation: operation,
                payload: payload,
                retryCount: retryCount,
                status: status,
                createdAt: createdAt,
                processedAt: processedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tableName_,
                required String rowId,
                required String operation,
                required String payload,
                Value<int> retryCount = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> processedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncQueueTableCompanion.insert(
                id: id,
                tableName_: tableName_,
                rowId: rowId,
                operation: operation,
                payload: payload,
                retryCount: retryCount,
                status: status,
                createdAt: createdAt,
                processedAt: processedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncQueueTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncQueueTableTable,
      SyncQueueTableData,
      $$SyncQueueTableTableFilterComposer,
      $$SyncQueueTableTableOrderingComposer,
      $$SyncQueueTableTableAnnotationComposer,
      $$SyncQueueTableTableCreateCompanionBuilder,
      $$SyncQueueTableTableUpdateCompanionBuilder,
      (
        SyncQueueTableData,
        BaseReferences<_$AppDatabase, $SyncQueueTableTable, SyncQueueTableData>,
      ),
      SyncQueueTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$HanjaTableTableTableManager get hanjaTable =>
      $$HanjaTableTableTableManager(_db, _db.hanjaTable);
  $$HanjaExtendTableTableTableManager get hanjaExtendTable =>
      $$HanjaExtendTableTableTableManager(_db, _db.hanjaExtendTable);
  $$ContentConfigTableTableTableManager get contentConfigTable =>
      $$ContentConfigTableTableTableManager(_db, _db.contentConfigTable);
  $$HanjaStrokeTableTableTableManager get hanjaStrokeTable =>
      $$HanjaStrokeTableTableTableManager(_db, _db.hanjaStrokeTable);
  $$HanjaStrokeSvgPathsTableTableTableManager get hanjaStrokeSvgPathsTable =>
      $$HanjaStrokeSvgPathsTableTableTableManager(
        _db,
        _db.hanjaStrokeSvgPathsTable,
      );
  $$HanjaWordTableTableTableManager get hanjaWordTable =>
      $$HanjaWordTableTableTableManager(_db, _db.hanjaWordTable);
  $$HanjaIdiomTableTableTableManager get hanjaIdiomTable =>
      $$HanjaIdiomTableTableTableManager(_db, _db.hanjaIdiomTable);
  $$UserProgressTableTableTableManager get userProgressTable =>
      $$UserProgressTableTableTableManager(_db, _db.userProgressTable);
  $$StudySessionTableTableTableManager get studySessionTable =>
      $$StudySessionTableTableTableManager(_db, _db.studySessionTable);
  $$AnswerHistoryTableTableTableManager get answerHistoryTable =>
      $$AnswerHistoryTableTableTableManager(_db, _db.answerHistoryTable);
  $$AppSettingsTableTableTableManager get appSettingsTable =>
      $$AppSettingsTableTableTableManager(_db, _db.appSettingsTable);
  $$SyncQueueTableTableTableManager get syncQueueTable =>
      $$SyncQueueTableTableTableManager(_db, _db.syncQueueTable);
}
