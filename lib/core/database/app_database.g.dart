// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $JobsTable extends Jobs with TableInfo<$JobsTable, JobRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JobsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<JobRunStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<JobRunStatus>($JobsTable.$converterstatus);
  @override
  late final GeneratedColumnWithTypeConverter<JobSourceType, String>
  sourceType = GeneratedColumn<String>(
    'source_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<JobSourceType>($JobsTable.$convertersourceType);
  @override
  late final GeneratedColumnWithTypeConverter<ContentLanguage, String>
  sourceLanguage = GeneratedColumn<String>(
    'language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<ContentLanguage>($JobsTable.$convertersourceLanguage);
  @override
  late final GeneratedColumnWithTypeConverter<ContentLanguage, String>
  summaryLanguage = GeneratedColumn<String>(
    'summary_language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('ar'),
  ).withConverter<ContentLanguage>($JobsTable.$convertersummaryLanguage);
  @override
  late final GeneratedColumnWithTypeConverter<SummaryLength, String>
  requestedLength = GeneratedColumn<String>(
    'requested_length',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<SummaryLength>($JobsTable.$converterrequestedLength);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
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
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<JobFailureKind?, String>
  failureKind = GeneratedColumn<String>(
    'failure_kind',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<JobFailureKind?>($JobsTable.$converterfailureKindn);
  static const VerificationMeta _previewMeta = const VerificationMeta(
    'preview',
  );
  @override
  late final GeneratedColumn<String> preview = GeneratedColumn<String>(
    'preview',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceUrlMeta = const VerificationMeta(
    'sourceUrl',
  );
  @override
  late final GeneratedColumn<String> sourceUrl = GeneratedColumn<String>(
    'source_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceFilePathMeta = const VerificationMeta(
    'sourceFilePath',
  );
  @override
  late final GeneratedColumn<String> sourceFilePath = GeneratedColumn<String>(
    'source_file_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMimeTypeMeta = const VerificationMeta(
    'sourceMimeType',
  );
  @override
  late final GeneratedColumn<String> sourceMimeType = GeneratedColumn<String>(
    'source_mime_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceTitleMeta = const VerificationMeta(
    'sourceTitle',
  );
  @override
  late final GeneratedColumn<String> sourceTitle = GeneratedColumn<String>(
    'source_title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<double> durationSeconds = GeneratedColumn<double>(
    'duration_seconds',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    status,
    sourceType,
    sourceLanguage,
    summaryLanguage,
    requestedLength,
    createdAt,
    updatedAt,
    failureKind,
    preview,
    sourceUrl,
    sourceFilePath,
    sourceMimeType,
    sourceTitle,
    durationSeconds,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'jobs';
  @override
  VerificationContext validateIntegrity(
    Insertable<JobRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('preview')) {
      context.handle(
        _previewMeta,
        preview.isAcceptableOrUnknown(data['preview']!, _previewMeta),
      );
    }
    if (data.containsKey('source_url')) {
      context.handle(
        _sourceUrlMeta,
        sourceUrl.isAcceptableOrUnknown(data['source_url']!, _sourceUrlMeta),
      );
    }
    if (data.containsKey('source_file_path')) {
      context.handle(
        _sourceFilePathMeta,
        sourceFilePath.isAcceptableOrUnknown(
          data['source_file_path']!,
          _sourceFilePathMeta,
        ),
      );
    }
    if (data.containsKey('source_mime_type')) {
      context.handle(
        _sourceMimeTypeMeta,
        sourceMimeType.isAcceptableOrUnknown(
          data['source_mime_type']!,
          _sourceMimeTypeMeta,
        ),
      );
    }
    if (data.containsKey('source_title')) {
      context.handle(
        _sourceTitleMeta,
        sourceTitle.isAcceptableOrUnknown(
          data['source_title']!,
          _sourceTitleMeta,
        ),
      );
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  JobRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JobRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      status: $JobsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      sourceType: $JobsTable.$convertersourceType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}source_type'],
        )!,
      ),
      sourceLanguage: $JobsTable.$convertersourceLanguage.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}language'],
        )!,
      ),
      summaryLanguage: $JobsTable.$convertersummaryLanguage.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}summary_language'],
        )!,
      ),
      requestedLength: $JobsTable.$converterrequestedLength.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}requested_length'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      failureKind: $JobsTable.$converterfailureKindn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}failure_kind'],
        ),
      ),
      preview: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preview'],
      ),
      sourceUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_url'],
      ),
      sourceFilePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_file_path'],
      ),
      sourceMimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_mime_type'],
      ),
      sourceTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_title'],
      ),
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}duration_seconds'],
      ),
    );
  }

  @override
  $JobsTable createAlias(String alias) {
    return $JobsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<JobRunStatus, String, String> $converterstatus =
      const EnumNameConverter<JobRunStatus>(JobRunStatus.values);
  static JsonTypeConverter2<JobSourceType, String, String>
  $convertersourceType = const EnumNameConverter<JobSourceType>(
    JobSourceType.values,
  );
  static JsonTypeConverter2<ContentLanguage, String, String>
  $convertersourceLanguage = const EnumNameConverter<ContentLanguage>(
    ContentLanguage.values,
  );
  static JsonTypeConverter2<ContentLanguage, String, String>
  $convertersummaryLanguage = const EnumNameConverter<ContentLanguage>(
    ContentLanguage.values,
  );
  static JsonTypeConverter2<SummaryLength, String, String>
  $converterrequestedLength = const EnumNameConverter<SummaryLength>(
    SummaryLength.values,
  );
  static JsonTypeConverter2<JobFailureKind, String, String>
  $converterfailureKind = const EnumNameConverter<JobFailureKind>(
    JobFailureKind.values,
  );
  static JsonTypeConverter2<JobFailureKind?, String?, String?>
  $converterfailureKindn = JsonTypeConverter2.asNullable($converterfailureKind);
}

class JobRow extends DataClass implements Insertable<JobRow> {
  final String id;
  final JobRunStatus status;
  final JobSourceType sourceType;

  /// Language of the source. The SQL column keeps its original name.
  final ContentLanguage sourceLanguage;

  /// Language the summary is written in (added in schema v2).
  final ContentLanguage summaryLanguage;
  final SummaryLength requestedLength;
  final DateTime createdAt;
  final DateTime updatedAt;
  final JobFailureKind? failureKind;

  /// First words of the transcript, denormalized for the list row.
  final String? preview;

  /// Web address of the source (YouTube). Never deleted.
  final String? sourceUrl;

  /// App-owned copy of an uploaded/downloaded file. The repository deletes the
  /// file when the job is deleted.
  final String? sourceFilePath;
  final String? sourceMimeType;
  final String? sourceTitle;
  final double? durationSeconds;
  const JobRow({
    required this.id,
    required this.status,
    required this.sourceType,
    required this.sourceLanguage,
    required this.summaryLanguage,
    required this.requestedLength,
    required this.createdAt,
    required this.updatedAt,
    this.failureKind,
    this.preview,
    this.sourceUrl,
    this.sourceFilePath,
    this.sourceMimeType,
    this.sourceTitle,
    this.durationSeconds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['status'] = Variable<String>(
        $JobsTable.$converterstatus.toSql(status),
      );
    }
    {
      map['source_type'] = Variable<String>(
        $JobsTable.$convertersourceType.toSql(sourceType),
      );
    }
    {
      map['language'] = Variable<String>(
        $JobsTable.$convertersourceLanguage.toSql(sourceLanguage),
      );
    }
    {
      map['summary_language'] = Variable<String>(
        $JobsTable.$convertersummaryLanguage.toSql(summaryLanguage),
      );
    }
    {
      map['requested_length'] = Variable<String>(
        $JobsTable.$converterrequestedLength.toSql(requestedLength),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || failureKind != null) {
      map['failure_kind'] = Variable<String>(
        $JobsTable.$converterfailureKindn.toSql(failureKind),
      );
    }
    if (!nullToAbsent || preview != null) {
      map['preview'] = Variable<String>(preview);
    }
    if (!nullToAbsent || sourceUrl != null) {
      map['source_url'] = Variable<String>(sourceUrl);
    }
    if (!nullToAbsent || sourceFilePath != null) {
      map['source_file_path'] = Variable<String>(sourceFilePath);
    }
    if (!nullToAbsent || sourceMimeType != null) {
      map['source_mime_type'] = Variable<String>(sourceMimeType);
    }
    if (!nullToAbsent || sourceTitle != null) {
      map['source_title'] = Variable<String>(sourceTitle);
    }
    if (!nullToAbsent || durationSeconds != null) {
      map['duration_seconds'] = Variable<double>(durationSeconds);
    }
    return map;
  }

  JobsCompanion toCompanion(bool nullToAbsent) {
    return JobsCompanion(
      id: Value(id),
      status: Value(status),
      sourceType: Value(sourceType),
      sourceLanguage: Value(sourceLanguage),
      summaryLanguage: Value(summaryLanguage),
      requestedLength: Value(requestedLength),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      failureKind: failureKind == null && nullToAbsent
          ? const Value.absent()
          : Value(failureKind),
      preview: preview == null && nullToAbsent
          ? const Value.absent()
          : Value(preview),
      sourceUrl: sourceUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceUrl),
      sourceFilePath: sourceFilePath == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceFilePath),
      sourceMimeType: sourceMimeType == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceMimeType),
      sourceTitle: sourceTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceTitle),
      durationSeconds: durationSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(durationSeconds),
    );
  }

  factory JobRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JobRow(
      id: serializer.fromJson<String>(json['id']),
      status: $JobsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      sourceType: $JobsTable.$convertersourceType.fromJson(
        serializer.fromJson<String>(json['sourceType']),
      ),
      sourceLanguage: $JobsTable.$convertersourceLanguage.fromJson(
        serializer.fromJson<String>(json['sourceLanguage']),
      ),
      summaryLanguage: $JobsTable.$convertersummaryLanguage.fromJson(
        serializer.fromJson<String>(json['summaryLanguage']),
      ),
      requestedLength: $JobsTable.$converterrequestedLength.fromJson(
        serializer.fromJson<String>(json['requestedLength']),
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      failureKind: $JobsTable.$converterfailureKindn.fromJson(
        serializer.fromJson<String?>(json['failureKind']),
      ),
      preview: serializer.fromJson<String?>(json['preview']),
      sourceUrl: serializer.fromJson<String?>(json['sourceUrl']),
      sourceFilePath: serializer.fromJson<String?>(json['sourceFilePath']),
      sourceMimeType: serializer.fromJson<String?>(json['sourceMimeType']),
      sourceTitle: serializer.fromJson<String?>(json['sourceTitle']),
      durationSeconds: serializer.fromJson<double?>(json['durationSeconds']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'status': serializer.toJson<String>(
        $JobsTable.$converterstatus.toJson(status),
      ),
      'sourceType': serializer.toJson<String>(
        $JobsTable.$convertersourceType.toJson(sourceType),
      ),
      'sourceLanguage': serializer.toJson<String>(
        $JobsTable.$convertersourceLanguage.toJson(sourceLanguage),
      ),
      'summaryLanguage': serializer.toJson<String>(
        $JobsTable.$convertersummaryLanguage.toJson(summaryLanguage),
      ),
      'requestedLength': serializer.toJson<String>(
        $JobsTable.$converterrequestedLength.toJson(requestedLength),
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'failureKind': serializer.toJson<String?>(
        $JobsTable.$converterfailureKindn.toJson(failureKind),
      ),
      'preview': serializer.toJson<String?>(preview),
      'sourceUrl': serializer.toJson<String?>(sourceUrl),
      'sourceFilePath': serializer.toJson<String?>(sourceFilePath),
      'sourceMimeType': serializer.toJson<String?>(sourceMimeType),
      'sourceTitle': serializer.toJson<String?>(sourceTitle),
      'durationSeconds': serializer.toJson<double?>(durationSeconds),
    };
  }

  JobRow copyWith({
    String? id,
    JobRunStatus? status,
    JobSourceType? sourceType,
    ContentLanguage? sourceLanguage,
    ContentLanguage? summaryLanguage,
    SummaryLength? requestedLength,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<JobFailureKind?> failureKind = const Value.absent(),
    Value<String?> preview = const Value.absent(),
    Value<String?> sourceUrl = const Value.absent(),
    Value<String?> sourceFilePath = const Value.absent(),
    Value<String?> sourceMimeType = const Value.absent(),
    Value<String?> sourceTitle = const Value.absent(),
    Value<double?> durationSeconds = const Value.absent(),
  }) => JobRow(
    id: id ?? this.id,
    status: status ?? this.status,
    sourceType: sourceType ?? this.sourceType,
    sourceLanguage: sourceLanguage ?? this.sourceLanguage,
    summaryLanguage: summaryLanguage ?? this.summaryLanguage,
    requestedLength: requestedLength ?? this.requestedLength,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    failureKind: failureKind.present ? failureKind.value : this.failureKind,
    preview: preview.present ? preview.value : this.preview,
    sourceUrl: sourceUrl.present ? sourceUrl.value : this.sourceUrl,
    sourceFilePath: sourceFilePath.present
        ? sourceFilePath.value
        : this.sourceFilePath,
    sourceMimeType: sourceMimeType.present
        ? sourceMimeType.value
        : this.sourceMimeType,
    sourceTitle: sourceTitle.present ? sourceTitle.value : this.sourceTitle,
    durationSeconds: durationSeconds.present
        ? durationSeconds.value
        : this.durationSeconds,
  );
  JobRow copyWithCompanion(JobsCompanion data) {
    return JobRow(
      id: data.id.present ? data.id.value : this.id,
      status: data.status.present ? data.status.value : this.status,
      sourceType: data.sourceType.present
          ? data.sourceType.value
          : this.sourceType,
      sourceLanguage: data.sourceLanguage.present
          ? data.sourceLanguage.value
          : this.sourceLanguage,
      summaryLanguage: data.summaryLanguage.present
          ? data.summaryLanguage.value
          : this.summaryLanguage,
      requestedLength: data.requestedLength.present
          ? data.requestedLength.value
          : this.requestedLength,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      failureKind: data.failureKind.present
          ? data.failureKind.value
          : this.failureKind,
      preview: data.preview.present ? data.preview.value : this.preview,
      sourceUrl: data.sourceUrl.present ? data.sourceUrl.value : this.sourceUrl,
      sourceFilePath: data.sourceFilePath.present
          ? data.sourceFilePath.value
          : this.sourceFilePath,
      sourceMimeType: data.sourceMimeType.present
          ? data.sourceMimeType.value
          : this.sourceMimeType,
      sourceTitle: data.sourceTitle.present
          ? data.sourceTitle.value
          : this.sourceTitle,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JobRow(')
          ..write('id: $id, ')
          ..write('status: $status, ')
          ..write('sourceType: $sourceType, ')
          ..write('sourceLanguage: $sourceLanguage, ')
          ..write('summaryLanguage: $summaryLanguage, ')
          ..write('requestedLength: $requestedLength, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('failureKind: $failureKind, ')
          ..write('preview: $preview, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('sourceFilePath: $sourceFilePath, ')
          ..write('sourceMimeType: $sourceMimeType, ')
          ..write('sourceTitle: $sourceTitle, ')
          ..write('durationSeconds: $durationSeconds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    status,
    sourceType,
    sourceLanguage,
    summaryLanguage,
    requestedLength,
    createdAt,
    updatedAt,
    failureKind,
    preview,
    sourceUrl,
    sourceFilePath,
    sourceMimeType,
    sourceTitle,
    durationSeconds,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JobRow &&
          other.id == this.id &&
          other.status == this.status &&
          other.sourceType == this.sourceType &&
          other.sourceLanguage == this.sourceLanguage &&
          other.summaryLanguage == this.summaryLanguage &&
          other.requestedLength == this.requestedLength &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.failureKind == this.failureKind &&
          other.preview == this.preview &&
          other.sourceUrl == this.sourceUrl &&
          other.sourceFilePath == this.sourceFilePath &&
          other.sourceMimeType == this.sourceMimeType &&
          other.sourceTitle == this.sourceTitle &&
          other.durationSeconds == this.durationSeconds);
}

class JobsCompanion extends UpdateCompanion<JobRow> {
  final Value<String> id;
  final Value<JobRunStatus> status;
  final Value<JobSourceType> sourceType;
  final Value<ContentLanguage> sourceLanguage;
  final Value<ContentLanguage> summaryLanguage;
  final Value<SummaryLength> requestedLength;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<JobFailureKind?> failureKind;
  final Value<String?> preview;
  final Value<String?> sourceUrl;
  final Value<String?> sourceFilePath;
  final Value<String?> sourceMimeType;
  final Value<String?> sourceTitle;
  final Value<double?> durationSeconds;
  final Value<int> rowid;
  const JobsCompanion({
    this.id = const Value.absent(),
    this.status = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.sourceLanguage = const Value.absent(),
    this.summaryLanguage = const Value.absent(),
    this.requestedLength = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.failureKind = const Value.absent(),
    this.preview = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.sourceFilePath = const Value.absent(),
    this.sourceMimeType = const Value.absent(),
    this.sourceTitle = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  JobsCompanion.insert({
    required String id,
    required JobRunStatus status,
    required JobSourceType sourceType,
    required ContentLanguage sourceLanguage,
    this.summaryLanguage = const Value.absent(),
    required SummaryLength requestedLength,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.failureKind = const Value.absent(),
    this.preview = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.sourceFilePath = const Value.absent(),
    this.sourceMimeType = const Value.absent(),
    this.sourceTitle = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       status = Value(status),
       sourceType = Value(sourceType),
       sourceLanguage = Value(sourceLanguage),
       requestedLength = Value(requestedLength),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<JobRow> custom({
    Expression<String>? id,
    Expression<String>? status,
    Expression<String>? sourceType,
    Expression<String>? sourceLanguage,
    Expression<String>? summaryLanguage,
    Expression<String>? requestedLength,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? failureKind,
    Expression<String>? preview,
    Expression<String>? sourceUrl,
    Expression<String>? sourceFilePath,
    Expression<String>? sourceMimeType,
    Expression<String>? sourceTitle,
    Expression<double>? durationSeconds,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (status != null) 'status': status,
      if (sourceType != null) 'source_type': sourceType,
      if (sourceLanguage != null) 'language': sourceLanguage,
      if (summaryLanguage != null) 'summary_language': summaryLanguage,
      if (requestedLength != null) 'requested_length': requestedLength,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (failureKind != null) 'failure_kind': failureKind,
      if (preview != null) 'preview': preview,
      if (sourceUrl != null) 'source_url': sourceUrl,
      if (sourceFilePath != null) 'source_file_path': sourceFilePath,
      if (sourceMimeType != null) 'source_mime_type': sourceMimeType,
      if (sourceTitle != null) 'source_title': sourceTitle,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (rowid != null) 'rowid': rowid,
    });
  }

  JobsCompanion copyWith({
    Value<String>? id,
    Value<JobRunStatus>? status,
    Value<JobSourceType>? sourceType,
    Value<ContentLanguage>? sourceLanguage,
    Value<ContentLanguage>? summaryLanguage,
    Value<SummaryLength>? requestedLength,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<JobFailureKind?>? failureKind,
    Value<String?>? preview,
    Value<String?>? sourceUrl,
    Value<String?>? sourceFilePath,
    Value<String?>? sourceMimeType,
    Value<String?>? sourceTitle,
    Value<double?>? durationSeconds,
    Value<int>? rowid,
  }) {
    return JobsCompanion(
      id: id ?? this.id,
      status: status ?? this.status,
      sourceType: sourceType ?? this.sourceType,
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      summaryLanguage: summaryLanguage ?? this.summaryLanguage,
      requestedLength: requestedLength ?? this.requestedLength,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      failureKind: failureKind ?? this.failureKind,
      preview: preview ?? this.preview,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      sourceFilePath: sourceFilePath ?? this.sourceFilePath,
      sourceMimeType: sourceMimeType ?? this.sourceMimeType,
      sourceTitle: sourceTitle ?? this.sourceTitle,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $JobsTable.$converterstatus.toSql(status.value),
      );
    }
    if (sourceType.present) {
      map['source_type'] = Variable<String>(
        $JobsTable.$convertersourceType.toSql(sourceType.value),
      );
    }
    if (sourceLanguage.present) {
      map['language'] = Variable<String>(
        $JobsTable.$convertersourceLanguage.toSql(sourceLanguage.value),
      );
    }
    if (summaryLanguage.present) {
      map['summary_language'] = Variable<String>(
        $JobsTable.$convertersummaryLanguage.toSql(summaryLanguage.value),
      );
    }
    if (requestedLength.present) {
      map['requested_length'] = Variable<String>(
        $JobsTable.$converterrequestedLength.toSql(requestedLength.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (failureKind.present) {
      map['failure_kind'] = Variable<String>(
        $JobsTable.$converterfailureKindn.toSql(failureKind.value),
      );
    }
    if (preview.present) {
      map['preview'] = Variable<String>(preview.value);
    }
    if (sourceUrl.present) {
      map['source_url'] = Variable<String>(sourceUrl.value);
    }
    if (sourceFilePath.present) {
      map['source_file_path'] = Variable<String>(sourceFilePath.value);
    }
    if (sourceMimeType.present) {
      map['source_mime_type'] = Variable<String>(sourceMimeType.value);
    }
    if (sourceTitle.present) {
      map['source_title'] = Variable<String>(sourceTitle.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<double>(durationSeconds.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JobsCompanion(')
          ..write('id: $id, ')
          ..write('status: $status, ')
          ..write('sourceType: $sourceType, ')
          ..write('sourceLanguage: $sourceLanguage, ')
          ..write('summaryLanguage: $summaryLanguage, ')
          ..write('requestedLength: $requestedLength, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('failureKind: $failureKind, ')
          ..write('preview: $preview, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('sourceFilePath: $sourceFilePath, ')
          ..write('sourceMimeType: $sourceMimeType, ')
          ..write('sourceTitle: $sourceTitle, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $JobTranscriptsTable extends JobTranscripts
    with TableInfo<$JobTranscriptsTable, TranscriptRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JobTranscriptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _jobIdMeta = const VerificationMeta('jobId');
  @override
  late final GeneratedColumn<String> jobId = GeneratedColumn<String>(
    'job_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES jobs (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wordCountMeta = const VerificationMeta(
    'wordCount',
  );
  @override
  late final GeneratedColumn<int> wordCount = GeneratedColumn<int>(
    'word_count',
    aliasedName,
    false,
    check: () => ComparableExpr(wordCount).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelNameMeta = const VerificationMeta(
    'modelName',
  );
  @override
  late final GeneratedColumn<String> modelName = GeneratedColumn<String>(
    'model_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modelVersionMeta = const VerificationMeta(
    'modelVersion',
  );
  @override
  late final GeneratedColumn<String> modelVersion = GeneratedColumn<String>(
    'model_version',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    jobId,
    content,
    wordCount,
    modelName,
    modelVersion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'job_transcripts';
  @override
  VerificationContext validateIntegrity(
    Insertable<TranscriptRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('job_id')) {
      context.handle(
        _jobIdMeta,
        jobId.isAcceptableOrUnknown(data['job_id']!, _jobIdMeta),
      );
    } else if (isInserting) {
      context.missing(_jobIdMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('word_count')) {
      context.handle(
        _wordCountMeta,
        wordCount.isAcceptableOrUnknown(data['word_count']!, _wordCountMeta),
      );
    } else if (isInserting) {
      context.missing(_wordCountMeta);
    }
    if (data.containsKey('model_name')) {
      context.handle(
        _modelNameMeta,
        modelName.isAcceptableOrUnknown(data['model_name']!, _modelNameMeta),
      );
    }
    if (data.containsKey('model_version')) {
      context.handle(
        _modelVersionMeta,
        modelVersion.isAcceptableOrUnknown(
          data['model_version']!,
          _modelVersionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {jobId};
  @override
  TranscriptRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TranscriptRow(
      jobId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}job_id'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      wordCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}word_count'],
      )!,
      modelName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_name'],
      ),
      modelVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_version'],
      ),
    );
  }

  @override
  $JobTranscriptsTable createAlias(String alias) {
    return $JobTranscriptsTable(attachedDatabase, alias);
  }
}

class TranscriptRow extends DataClass implements Insertable<TranscriptRow> {
  final String jobId;
  final String content;
  final int wordCount;

  /// Speech-recognition model that produced [content] (added in schema v2).
  final String? modelName;
  final String? modelVersion;
  const TranscriptRow({
    required this.jobId,
    required this.content,
    required this.wordCount,
    this.modelName,
    this.modelVersion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['job_id'] = Variable<String>(jobId);
    map['content'] = Variable<String>(content);
    map['word_count'] = Variable<int>(wordCount);
    if (!nullToAbsent || modelName != null) {
      map['model_name'] = Variable<String>(modelName);
    }
    if (!nullToAbsent || modelVersion != null) {
      map['model_version'] = Variable<String>(modelVersion);
    }
    return map;
  }

  JobTranscriptsCompanion toCompanion(bool nullToAbsent) {
    return JobTranscriptsCompanion(
      jobId: Value(jobId),
      content: Value(content),
      wordCount: Value(wordCount),
      modelName: modelName == null && nullToAbsent
          ? const Value.absent()
          : Value(modelName),
      modelVersion: modelVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(modelVersion),
    );
  }

  factory TranscriptRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TranscriptRow(
      jobId: serializer.fromJson<String>(json['jobId']),
      content: serializer.fromJson<String>(json['content']),
      wordCount: serializer.fromJson<int>(json['wordCount']),
      modelName: serializer.fromJson<String?>(json['modelName']),
      modelVersion: serializer.fromJson<String?>(json['modelVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'jobId': serializer.toJson<String>(jobId),
      'content': serializer.toJson<String>(content),
      'wordCount': serializer.toJson<int>(wordCount),
      'modelName': serializer.toJson<String?>(modelName),
      'modelVersion': serializer.toJson<String?>(modelVersion),
    };
  }

  TranscriptRow copyWith({
    String? jobId,
    String? content,
    int? wordCount,
    Value<String?> modelName = const Value.absent(),
    Value<String?> modelVersion = const Value.absent(),
  }) => TranscriptRow(
    jobId: jobId ?? this.jobId,
    content: content ?? this.content,
    wordCount: wordCount ?? this.wordCount,
    modelName: modelName.present ? modelName.value : this.modelName,
    modelVersion: modelVersion.present ? modelVersion.value : this.modelVersion,
  );
  TranscriptRow copyWithCompanion(JobTranscriptsCompanion data) {
    return TranscriptRow(
      jobId: data.jobId.present ? data.jobId.value : this.jobId,
      content: data.content.present ? data.content.value : this.content,
      wordCount: data.wordCount.present ? data.wordCount.value : this.wordCount,
      modelName: data.modelName.present ? data.modelName.value : this.modelName,
      modelVersion: data.modelVersion.present
          ? data.modelVersion.value
          : this.modelVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TranscriptRow(')
          ..write('jobId: $jobId, ')
          ..write('content: $content, ')
          ..write('wordCount: $wordCount, ')
          ..write('modelName: $modelName, ')
          ..write('modelVersion: $modelVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(jobId, content, wordCount, modelName, modelVersion);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TranscriptRow &&
          other.jobId == this.jobId &&
          other.content == this.content &&
          other.wordCount == this.wordCount &&
          other.modelName == this.modelName &&
          other.modelVersion == this.modelVersion);
}

class JobTranscriptsCompanion extends UpdateCompanion<TranscriptRow> {
  final Value<String> jobId;
  final Value<String> content;
  final Value<int> wordCount;
  final Value<String?> modelName;
  final Value<String?> modelVersion;
  final Value<int> rowid;
  const JobTranscriptsCompanion({
    this.jobId = const Value.absent(),
    this.content = const Value.absent(),
    this.wordCount = const Value.absent(),
    this.modelName = const Value.absent(),
    this.modelVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  JobTranscriptsCompanion.insert({
    required String jobId,
    required String content,
    required int wordCount,
    this.modelName = const Value.absent(),
    this.modelVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : jobId = Value(jobId),
       content = Value(content),
       wordCount = Value(wordCount);
  static Insertable<TranscriptRow> custom({
    Expression<String>? jobId,
    Expression<String>? content,
    Expression<int>? wordCount,
    Expression<String>? modelName,
    Expression<String>? modelVersion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (jobId != null) 'job_id': jobId,
      if (content != null) 'content': content,
      if (wordCount != null) 'word_count': wordCount,
      if (modelName != null) 'model_name': modelName,
      if (modelVersion != null) 'model_version': modelVersion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  JobTranscriptsCompanion copyWith({
    Value<String>? jobId,
    Value<String>? content,
    Value<int>? wordCount,
    Value<String?>? modelName,
    Value<String?>? modelVersion,
    Value<int>? rowid,
  }) {
    return JobTranscriptsCompanion(
      jobId: jobId ?? this.jobId,
      content: content ?? this.content,
      wordCount: wordCount ?? this.wordCount,
      modelName: modelName ?? this.modelName,
      modelVersion: modelVersion ?? this.modelVersion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (jobId.present) {
      map['job_id'] = Variable<String>(jobId.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (wordCount.present) {
      map['word_count'] = Variable<int>(wordCount.value);
    }
    if (modelName.present) {
      map['model_name'] = Variable<String>(modelName.value);
    }
    if (modelVersion.present) {
      map['model_version'] = Variable<String>(modelVersion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JobTranscriptsCompanion(')
          ..write('jobId: $jobId, ')
          ..write('content: $content, ')
          ..write('wordCount: $wordCount, ')
          ..write('modelName: $modelName, ')
          ..write('modelVersion: $modelVersion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $JobSummariesTable extends JobSummaries
    with TableInfo<$JobSummariesTable, SummaryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JobSummariesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _jobIdMeta = const VerificationMeta('jobId');
  @override
  late final GeneratedColumn<String> jobId = GeneratedColumn<String>(
    'job_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES jobs (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _summaryTextMeta = const VerificationMeta(
    'summaryText',
  );
  @override
  late final GeneratedColumn<String> summaryText = GeneratedColumn<String>(
    'summary_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> takeaways =
      GeneratedColumn<String>(
        'takeaways',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<List<String>>($JobSummariesTable.$convertertakeaways);
  static const VerificationMeta _modelNameMeta = const VerificationMeta(
    'modelName',
  );
  @override
  late final GeneratedColumn<String> modelName = GeneratedColumn<String>(
    'model_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _promptVersionMeta = const VerificationMeta(
    'promptVersion',
  );
  @override
  late final GeneratedColumn<String> promptVersion = GeneratedColumn<String>(
    'prompt_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _needsReviewMeta = const VerificationMeta(
    'needsReview',
  );
  @override
  late final GeneratedColumn<bool> needsReview = GeneratedColumn<bool>(
    'needs_review',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("needs_review" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _tokensInMeta = const VerificationMeta(
    'tokensIn',
  );
  @override
  late final GeneratedColumn<int> tokensIn = GeneratedColumn<int>(
    'tokens_in',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tokensOutMeta = const VerificationMeta(
    'tokensOut',
  );
  @override
  late final GeneratedColumn<int> tokensOut = GeneratedColumn<int>(
    'tokens_out',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _processingTimeMsMeta = const VerificationMeta(
    'processingTimeMs',
  );
  @override
  late final GeneratedColumn<int> processingTimeMs = GeneratedColumn<int>(
    'processing_time_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    jobId,
    summaryText,
    takeaways,
    modelName,
    promptVersion,
    needsReview,
    tokensIn,
    tokensOut,
    processingTimeMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'job_summaries';
  @override
  VerificationContext validateIntegrity(
    Insertable<SummaryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('job_id')) {
      context.handle(
        _jobIdMeta,
        jobId.isAcceptableOrUnknown(data['job_id']!, _jobIdMeta),
      );
    } else if (isInserting) {
      context.missing(_jobIdMeta);
    }
    if (data.containsKey('summary_text')) {
      context.handle(
        _summaryTextMeta,
        summaryText.isAcceptableOrUnknown(
          data['summary_text']!,
          _summaryTextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_summaryTextMeta);
    }
    if (data.containsKey('model_name')) {
      context.handle(
        _modelNameMeta,
        modelName.isAcceptableOrUnknown(data['model_name']!, _modelNameMeta),
      );
    } else if (isInserting) {
      context.missing(_modelNameMeta);
    }
    if (data.containsKey('prompt_version')) {
      context.handle(
        _promptVersionMeta,
        promptVersion.isAcceptableOrUnknown(
          data['prompt_version']!,
          _promptVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_promptVersionMeta);
    }
    if (data.containsKey('needs_review')) {
      context.handle(
        _needsReviewMeta,
        needsReview.isAcceptableOrUnknown(
          data['needs_review']!,
          _needsReviewMeta,
        ),
      );
    }
    if (data.containsKey('tokens_in')) {
      context.handle(
        _tokensInMeta,
        tokensIn.isAcceptableOrUnknown(data['tokens_in']!, _tokensInMeta),
      );
    }
    if (data.containsKey('tokens_out')) {
      context.handle(
        _tokensOutMeta,
        tokensOut.isAcceptableOrUnknown(data['tokens_out']!, _tokensOutMeta),
      );
    }
    if (data.containsKey('processing_time_ms')) {
      context.handle(
        _processingTimeMsMeta,
        processingTimeMs.isAcceptableOrUnknown(
          data['processing_time_ms']!,
          _processingTimeMsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {jobId};
  @override
  SummaryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SummaryRow(
      jobId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}job_id'],
      )!,
      summaryText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary_text'],
      )!,
      takeaways: $JobSummariesTable.$convertertakeaways.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}takeaways'],
        )!,
      ),
      modelName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_name'],
      )!,
      promptVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prompt_version'],
      )!,
      needsReview: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}needs_review'],
      )!,
      tokensIn: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tokens_in'],
      ),
      tokensOut: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tokens_out'],
      ),
      processingTimeMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}processing_time_ms'],
      ),
    );
  }

  @override
  $JobSummariesTable createAlias(String alias) {
    return $JobSummariesTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $convertertakeaways =
      const StringListConverter();
}

class SummaryRow extends DataClass implements Insertable<SummaryRow> {
  final String jobId;
  final String summaryText;
  final List<String> takeaways;
  final String modelName;
  final String promptVersion;
  final bool needsReview;
  final int? tokensIn;
  final int? tokensOut;
  final int? processingTimeMs;
  const SummaryRow({
    required this.jobId,
    required this.summaryText,
    required this.takeaways,
    required this.modelName,
    required this.promptVersion,
    required this.needsReview,
    this.tokensIn,
    this.tokensOut,
    this.processingTimeMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['job_id'] = Variable<String>(jobId);
    map['summary_text'] = Variable<String>(summaryText);
    {
      map['takeaways'] = Variable<String>(
        $JobSummariesTable.$convertertakeaways.toSql(takeaways),
      );
    }
    map['model_name'] = Variable<String>(modelName);
    map['prompt_version'] = Variable<String>(promptVersion);
    map['needs_review'] = Variable<bool>(needsReview);
    if (!nullToAbsent || tokensIn != null) {
      map['tokens_in'] = Variable<int>(tokensIn);
    }
    if (!nullToAbsent || tokensOut != null) {
      map['tokens_out'] = Variable<int>(tokensOut);
    }
    if (!nullToAbsent || processingTimeMs != null) {
      map['processing_time_ms'] = Variable<int>(processingTimeMs);
    }
    return map;
  }

  JobSummariesCompanion toCompanion(bool nullToAbsent) {
    return JobSummariesCompanion(
      jobId: Value(jobId),
      summaryText: Value(summaryText),
      takeaways: Value(takeaways),
      modelName: Value(modelName),
      promptVersion: Value(promptVersion),
      needsReview: Value(needsReview),
      tokensIn: tokensIn == null && nullToAbsent
          ? const Value.absent()
          : Value(tokensIn),
      tokensOut: tokensOut == null && nullToAbsent
          ? const Value.absent()
          : Value(tokensOut),
      processingTimeMs: processingTimeMs == null && nullToAbsent
          ? const Value.absent()
          : Value(processingTimeMs),
    );
  }

  factory SummaryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SummaryRow(
      jobId: serializer.fromJson<String>(json['jobId']),
      summaryText: serializer.fromJson<String>(json['summaryText']),
      takeaways: serializer.fromJson<List<String>>(json['takeaways']),
      modelName: serializer.fromJson<String>(json['modelName']),
      promptVersion: serializer.fromJson<String>(json['promptVersion']),
      needsReview: serializer.fromJson<bool>(json['needsReview']),
      tokensIn: serializer.fromJson<int?>(json['tokensIn']),
      tokensOut: serializer.fromJson<int?>(json['tokensOut']),
      processingTimeMs: serializer.fromJson<int?>(json['processingTimeMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'jobId': serializer.toJson<String>(jobId),
      'summaryText': serializer.toJson<String>(summaryText),
      'takeaways': serializer.toJson<List<String>>(takeaways),
      'modelName': serializer.toJson<String>(modelName),
      'promptVersion': serializer.toJson<String>(promptVersion),
      'needsReview': serializer.toJson<bool>(needsReview),
      'tokensIn': serializer.toJson<int?>(tokensIn),
      'tokensOut': serializer.toJson<int?>(tokensOut),
      'processingTimeMs': serializer.toJson<int?>(processingTimeMs),
    };
  }

  SummaryRow copyWith({
    String? jobId,
    String? summaryText,
    List<String>? takeaways,
    String? modelName,
    String? promptVersion,
    bool? needsReview,
    Value<int?> tokensIn = const Value.absent(),
    Value<int?> tokensOut = const Value.absent(),
    Value<int?> processingTimeMs = const Value.absent(),
  }) => SummaryRow(
    jobId: jobId ?? this.jobId,
    summaryText: summaryText ?? this.summaryText,
    takeaways: takeaways ?? this.takeaways,
    modelName: modelName ?? this.modelName,
    promptVersion: promptVersion ?? this.promptVersion,
    needsReview: needsReview ?? this.needsReview,
    tokensIn: tokensIn.present ? tokensIn.value : this.tokensIn,
    tokensOut: tokensOut.present ? tokensOut.value : this.tokensOut,
    processingTimeMs: processingTimeMs.present
        ? processingTimeMs.value
        : this.processingTimeMs,
  );
  SummaryRow copyWithCompanion(JobSummariesCompanion data) {
    return SummaryRow(
      jobId: data.jobId.present ? data.jobId.value : this.jobId,
      summaryText: data.summaryText.present
          ? data.summaryText.value
          : this.summaryText,
      takeaways: data.takeaways.present ? data.takeaways.value : this.takeaways,
      modelName: data.modelName.present ? data.modelName.value : this.modelName,
      promptVersion: data.promptVersion.present
          ? data.promptVersion.value
          : this.promptVersion,
      needsReview: data.needsReview.present
          ? data.needsReview.value
          : this.needsReview,
      tokensIn: data.tokensIn.present ? data.tokensIn.value : this.tokensIn,
      tokensOut: data.tokensOut.present ? data.tokensOut.value : this.tokensOut,
      processingTimeMs: data.processingTimeMs.present
          ? data.processingTimeMs.value
          : this.processingTimeMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SummaryRow(')
          ..write('jobId: $jobId, ')
          ..write('summaryText: $summaryText, ')
          ..write('takeaways: $takeaways, ')
          ..write('modelName: $modelName, ')
          ..write('promptVersion: $promptVersion, ')
          ..write('needsReview: $needsReview, ')
          ..write('tokensIn: $tokensIn, ')
          ..write('tokensOut: $tokensOut, ')
          ..write('processingTimeMs: $processingTimeMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    jobId,
    summaryText,
    takeaways,
    modelName,
    promptVersion,
    needsReview,
    tokensIn,
    tokensOut,
    processingTimeMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SummaryRow &&
          other.jobId == this.jobId &&
          other.summaryText == this.summaryText &&
          other.takeaways == this.takeaways &&
          other.modelName == this.modelName &&
          other.promptVersion == this.promptVersion &&
          other.needsReview == this.needsReview &&
          other.tokensIn == this.tokensIn &&
          other.tokensOut == this.tokensOut &&
          other.processingTimeMs == this.processingTimeMs);
}

class JobSummariesCompanion extends UpdateCompanion<SummaryRow> {
  final Value<String> jobId;
  final Value<String> summaryText;
  final Value<List<String>> takeaways;
  final Value<String> modelName;
  final Value<String> promptVersion;
  final Value<bool> needsReview;
  final Value<int?> tokensIn;
  final Value<int?> tokensOut;
  final Value<int?> processingTimeMs;
  final Value<int> rowid;
  const JobSummariesCompanion({
    this.jobId = const Value.absent(),
    this.summaryText = const Value.absent(),
    this.takeaways = const Value.absent(),
    this.modelName = const Value.absent(),
    this.promptVersion = const Value.absent(),
    this.needsReview = const Value.absent(),
    this.tokensIn = const Value.absent(),
    this.tokensOut = const Value.absent(),
    this.processingTimeMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  JobSummariesCompanion.insert({
    required String jobId,
    required String summaryText,
    required List<String> takeaways,
    required String modelName,
    required String promptVersion,
    this.needsReview = const Value.absent(),
    this.tokensIn = const Value.absent(),
    this.tokensOut = const Value.absent(),
    this.processingTimeMs = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : jobId = Value(jobId),
       summaryText = Value(summaryText),
       takeaways = Value(takeaways),
       modelName = Value(modelName),
       promptVersion = Value(promptVersion);
  static Insertable<SummaryRow> custom({
    Expression<String>? jobId,
    Expression<String>? summaryText,
    Expression<String>? takeaways,
    Expression<String>? modelName,
    Expression<String>? promptVersion,
    Expression<bool>? needsReview,
    Expression<int>? tokensIn,
    Expression<int>? tokensOut,
    Expression<int>? processingTimeMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (jobId != null) 'job_id': jobId,
      if (summaryText != null) 'summary_text': summaryText,
      if (takeaways != null) 'takeaways': takeaways,
      if (modelName != null) 'model_name': modelName,
      if (promptVersion != null) 'prompt_version': promptVersion,
      if (needsReview != null) 'needs_review': needsReview,
      if (tokensIn != null) 'tokens_in': tokensIn,
      if (tokensOut != null) 'tokens_out': tokensOut,
      if (processingTimeMs != null) 'processing_time_ms': processingTimeMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  JobSummariesCompanion copyWith({
    Value<String>? jobId,
    Value<String>? summaryText,
    Value<List<String>>? takeaways,
    Value<String>? modelName,
    Value<String>? promptVersion,
    Value<bool>? needsReview,
    Value<int?>? tokensIn,
    Value<int?>? tokensOut,
    Value<int?>? processingTimeMs,
    Value<int>? rowid,
  }) {
    return JobSummariesCompanion(
      jobId: jobId ?? this.jobId,
      summaryText: summaryText ?? this.summaryText,
      takeaways: takeaways ?? this.takeaways,
      modelName: modelName ?? this.modelName,
      promptVersion: promptVersion ?? this.promptVersion,
      needsReview: needsReview ?? this.needsReview,
      tokensIn: tokensIn ?? this.tokensIn,
      tokensOut: tokensOut ?? this.tokensOut,
      processingTimeMs: processingTimeMs ?? this.processingTimeMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (jobId.present) {
      map['job_id'] = Variable<String>(jobId.value);
    }
    if (summaryText.present) {
      map['summary_text'] = Variable<String>(summaryText.value);
    }
    if (takeaways.present) {
      map['takeaways'] = Variable<String>(
        $JobSummariesTable.$convertertakeaways.toSql(takeaways.value),
      );
    }
    if (modelName.present) {
      map['model_name'] = Variable<String>(modelName.value);
    }
    if (promptVersion.present) {
      map['prompt_version'] = Variable<String>(promptVersion.value);
    }
    if (needsReview.present) {
      map['needs_review'] = Variable<bool>(needsReview.value);
    }
    if (tokensIn.present) {
      map['tokens_in'] = Variable<int>(tokensIn.value);
    }
    if (tokensOut.present) {
      map['tokens_out'] = Variable<int>(tokensOut.value);
    }
    if (processingTimeMs.present) {
      map['processing_time_ms'] = Variable<int>(processingTimeMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JobSummariesCompanion(')
          ..write('jobId: $jobId, ')
          ..write('summaryText: $summaryText, ')
          ..write('takeaways: $takeaways, ')
          ..write('modelName: $modelName, ')
          ..write('promptVersion: $promptVersion, ')
          ..write('needsReview: $needsReview, ')
          ..write('tokensIn: $tokensIn, ')
          ..write('tokensOut: $tokensOut, ')
          ..write('processingTimeMs: $processingTimeMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $JobsTable jobs = $JobsTable(this);
  late final $JobTranscriptsTable jobTranscripts = $JobTranscriptsTable(this);
  late final $JobSummariesTable jobSummaries = $JobSummariesTable(this);
  late final Index jobsCreatedAtIdx = Index(
    'jobs_created_at_idx',
    'CREATE INDEX jobs_created_at_idx ON jobs (created_at)',
  );
  late final Index jobsStatusCreatedAtIdx = Index(
    'jobs_status_created_at_idx',
    'CREATE INDEX jobs_status_created_at_idx ON jobs (status, created_at)',
  );
  late final JobsDao jobsDao = JobsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    jobs,
    jobTranscripts,
    jobSummaries,
    jobsCreatedAtIdx,
    jobsStatusCreatedAtIdx,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'jobs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('job_transcripts', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'jobs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('job_summaries', kind: UpdateKind.delete)],
    ),
  ]);
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$JobsTableCreateCompanionBuilder =
    JobsCompanion Function({
      required String id,
      required JobRunStatus status,
      required JobSourceType sourceType,
      required ContentLanguage sourceLanguage,
      Value<ContentLanguage> summaryLanguage,
      required SummaryLength requestedLength,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<JobFailureKind?> failureKind,
      Value<String?> preview,
      Value<String?> sourceUrl,
      Value<String?> sourceFilePath,
      Value<String?> sourceMimeType,
      Value<String?> sourceTitle,
      Value<double?> durationSeconds,
      Value<int> rowid,
    });
typedef $$JobsTableUpdateCompanionBuilder =
    JobsCompanion Function({
      Value<String> id,
      Value<JobRunStatus> status,
      Value<JobSourceType> sourceType,
      Value<ContentLanguage> sourceLanguage,
      Value<ContentLanguage> summaryLanguage,
      Value<SummaryLength> requestedLength,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<JobFailureKind?> failureKind,
      Value<String?> preview,
      Value<String?> sourceUrl,
      Value<String?> sourceFilePath,
      Value<String?> sourceMimeType,
      Value<String?> sourceTitle,
      Value<double?> durationSeconds,
      Value<int> rowid,
    });

final class $$JobsTableReferences
    extends BaseReferences<_$AppDatabase, $JobsTable, JobRow> {
  $$JobsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$JobTranscriptsTable, List<TranscriptRow>>
  _jobTranscriptsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.jobTranscripts,
    aliasName: 'jobs__id__job_transcripts__job_id',
  );

  $$JobTranscriptsTableProcessedTableManager get jobTranscriptsRefs {
    final manager = $$JobTranscriptsTableTableManager(
      $_db,
      $_db.jobTranscripts,
    ).filter((f) => f.jobId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_jobTranscriptsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$JobSummariesTable, List<SummaryRow>>
  _jobSummariesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.jobSummaries,
    aliasName: 'jobs__id__job_summaries__job_id',
  );

  $$JobSummariesTableProcessedTableManager get jobSummariesRefs {
    final manager = $$JobSummariesTableTableManager(
      $_db,
      $_db.jobSummaries,
    ).filter((f) => f.jobId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_jobSummariesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$JobsTableFilterComposer extends Composer<_$AppDatabase, $JobsTable> {
  $$JobsTableFilterComposer({
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

  ColumnWithTypeConverterFilters<JobRunStatus, JobRunStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<JobSourceType, JobSourceType, String>
  get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<ContentLanguage, ContentLanguage, String>
  get sourceLanguage => $composableBuilder(
    column: $table.sourceLanguage,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<ContentLanguage, ContentLanguage, String>
  get summaryLanguage => $composableBuilder(
    column: $table.summaryLanguage,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<SummaryLength, SummaryLength, String>
  get requestedLength => $composableBuilder(
    column: $table.requestedLength,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<JobFailureKind?, JobFailureKind, String>
  get failureKind => $composableBuilder(
    column: $table.failureKind,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get preview => $composableBuilder(
    column: $table.preview,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceFilePath => $composableBuilder(
    column: $table.sourceFilePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceMimeType => $composableBuilder(
    column: $table.sourceMimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceTitle => $composableBuilder(
    column: $table.sourceTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> jobTranscriptsRefs(
    Expression<bool> Function($$JobTranscriptsTableFilterComposer f) f,
  ) {
    final $$JobTranscriptsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.jobTranscripts,
      getReferencedColumn: (t) => t.jobId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobTranscriptsTableFilterComposer(
            $db: $db,
            $table: $db.jobTranscripts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> jobSummariesRefs(
    Expression<bool> Function($$JobSummariesTableFilterComposer f) f,
  ) {
    final $$JobSummariesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.jobSummaries,
      getReferencedColumn: (t) => t.jobId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobSummariesTableFilterComposer(
            $db: $db,
            $table: $db.jobSummaries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$JobsTableOrderingComposer extends Composer<_$AppDatabase, $JobsTable> {
  $$JobsTableOrderingComposer({
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

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceLanguage => $composableBuilder(
    column: $table.sourceLanguage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summaryLanguage => $composableBuilder(
    column: $table.summaryLanguage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requestedLength => $composableBuilder(
    column: $table.requestedLength,
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

  ColumnOrderings<String> get failureKind => $composableBuilder(
    column: $table.failureKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get preview => $composableBuilder(
    column: $table.preview,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceFilePath => $composableBuilder(
    column: $table.sourceFilePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceMimeType => $composableBuilder(
    column: $table.sourceMimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceTitle => $composableBuilder(
    column: $table.sourceTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$JobsTableAnnotationComposer
    extends Composer<_$AppDatabase, $JobsTable> {
  $$JobsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<JobRunStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumnWithTypeConverter<JobSourceType, String> get sourceType =>
      $composableBuilder(
        column: $table.sourceType,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<ContentLanguage, String>
  get sourceLanguage => $composableBuilder(
    column: $table.sourceLanguage,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<ContentLanguage, String>
  get summaryLanguage => $composableBuilder(
    column: $table.summaryLanguage,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<SummaryLength, String> get requestedLength =>
      $composableBuilder(
        column: $table.requestedLength,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<JobFailureKind?, String> get failureKind =>
      $composableBuilder(
        column: $table.failureKind,
        builder: (column) => column,
      );

  GeneratedColumn<String> get preview =>
      $composableBuilder(column: $table.preview, builder: (column) => column);

  GeneratedColumn<String> get sourceUrl =>
      $composableBuilder(column: $table.sourceUrl, builder: (column) => column);

  GeneratedColumn<String> get sourceFilePath => $composableBuilder(
    column: $table.sourceFilePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceMimeType => $composableBuilder(
    column: $table.sourceMimeType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceTitle => $composableBuilder(
    column: $table.sourceTitle,
    builder: (column) => column,
  );

  GeneratedColumn<double> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  Expression<T> jobTranscriptsRefs<T extends Object>(
    Expression<T> Function($$JobTranscriptsTableAnnotationComposer a) f,
  ) {
    final $$JobTranscriptsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.jobTranscripts,
      getReferencedColumn: (t) => t.jobId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobTranscriptsTableAnnotationComposer(
            $db: $db,
            $table: $db.jobTranscripts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> jobSummariesRefs<T extends Object>(
    Expression<T> Function($$JobSummariesTableAnnotationComposer a) f,
  ) {
    final $$JobSummariesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.jobSummaries,
      getReferencedColumn: (t) => t.jobId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobSummariesTableAnnotationComposer(
            $db: $db,
            $table: $db.jobSummaries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$JobsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $JobsTable,
          JobRow,
          $$JobsTableFilterComposer,
          $$JobsTableOrderingComposer,
          $$JobsTableAnnotationComposer,
          $$JobsTableCreateCompanionBuilder,
          $$JobsTableUpdateCompanionBuilder,
          (JobRow, $$JobsTableReferences),
          JobRow,
          PrefetchHooks Function({
            bool jobTranscriptsRefs,
            bool jobSummariesRefs,
          })
        > {
  $$JobsTableTableManager(_$AppDatabase db, $JobsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JobsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JobsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JobsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<JobRunStatus> status = const Value.absent(),
                Value<JobSourceType> sourceType = const Value.absent(),
                Value<ContentLanguage> sourceLanguage = const Value.absent(),
                Value<ContentLanguage> summaryLanguage = const Value.absent(),
                Value<SummaryLength> requestedLength = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<JobFailureKind?> failureKind = const Value.absent(),
                Value<String?> preview = const Value.absent(),
                Value<String?> sourceUrl = const Value.absent(),
                Value<String?> sourceFilePath = const Value.absent(),
                Value<String?> sourceMimeType = const Value.absent(),
                Value<String?> sourceTitle = const Value.absent(),
                Value<double?> durationSeconds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JobsCompanion(
                id: id,
                status: status,
                sourceType: sourceType,
                sourceLanguage: sourceLanguage,
                summaryLanguage: summaryLanguage,
                requestedLength: requestedLength,
                createdAt: createdAt,
                updatedAt: updatedAt,
                failureKind: failureKind,
                preview: preview,
                sourceUrl: sourceUrl,
                sourceFilePath: sourceFilePath,
                sourceMimeType: sourceMimeType,
                sourceTitle: sourceTitle,
                durationSeconds: durationSeconds,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required JobRunStatus status,
                required JobSourceType sourceType,
                required ContentLanguage sourceLanguage,
                Value<ContentLanguage> summaryLanguage = const Value.absent(),
                required SummaryLength requestedLength,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<JobFailureKind?> failureKind = const Value.absent(),
                Value<String?> preview = const Value.absent(),
                Value<String?> sourceUrl = const Value.absent(),
                Value<String?> sourceFilePath = const Value.absent(),
                Value<String?> sourceMimeType = const Value.absent(),
                Value<String?> sourceTitle = const Value.absent(),
                Value<double?> durationSeconds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JobsCompanion.insert(
                id: id,
                status: status,
                sourceType: sourceType,
                sourceLanguage: sourceLanguage,
                summaryLanguage: summaryLanguage,
                requestedLength: requestedLength,
                createdAt: createdAt,
                updatedAt: updatedAt,
                failureKind: failureKind,
                preview: preview,
                sourceUrl: sourceUrl,
                sourceFilePath: sourceFilePath,
                sourceMimeType: sourceMimeType,
                sourceTitle: sourceTitle,
                durationSeconds: durationSeconds,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$JobsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({jobTranscriptsRefs = false, jobSummariesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (jobTranscriptsRefs) db.jobTranscripts,
                    if (jobSummariesRefs) db.jobSummaries,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (jobTranscriptsRefs)
                        await $_getPrefetchedData<
                          JobRow,
                          $JobsTable,
                          TranscriptRow
                        >(
                          currentTable: table,
                          referencedTable: $$JobsTableReferences
                              ._jobTranscriptsRefsTable(db),
                          managerFromTypedResult: (p0) => $$JobsTableReferences(
                            db,
                            table,
                            p0,
                          ).jobTranscriptsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.jobId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (jobSummariesRefs)
                        await $_getPrefetchedData<
                          JobRow,
                          $JobsTable,
                          SummaryRow
                        >(
                          currentTable: table,
                          referencedTable: $$JobsTableReferences
                              ._jobSummariesRefsTable(db),
                          managerFromTypedResult: (p0) => $$JobsTableReferences(
                            db,
                            table,
                            p0,
                          ).jobSummariesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.jobId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$JobsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $JobsTable,
      JobRow,
      $$JobsTableFilterComposer,
      $$JobsTableOrderingComposer,
      $$JobsTableAnnotationComposer,
      $$JobsTableCreateCompanionBuilder,
      $$JobsTableUpdateCompanionBuilder,
      (JobRow, $$JobsTableReferences),
      JobRow,
      PrefetchHooks Function({bool jobTranscriptsRefs, bool jobSummariesRefs})
    >;
typedef $$JobTranscriptsTableCreateCompanionBuilder =
    JobTranscriptsCompanion Function({
      required String jobId,
      required String content,
      required int wordCount,
      Value<String?> modelName,
      Value<String?> modelVersion,
      Value<int> rowid,
    });
typedef $$JobTranscriptsTableUpdateCompanionBuilder =
    JobTranscriptsCompanion Function({
      Value<String> jobId,
      Value<String> content,
      Value<int> wordCount,
      Value<String?> modelName,
      Value<String?> modelVersion,
      Value<int> rowid,
    });

final class $$JobTranscriptsTableReferences
    extends BaseReferences<_$AppDatabase, $JobTranscriptsTable, TranscriptRow> {
  $$JobTranscriptsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $JobsTable _jobIdTable(_$AppDatabase db) =>
      db.jobs.createAlias('job_transcripts__job_id__jobs__id');

  $$JobsTableProcessedTableManager get jobId {
    final $_column = $_itemColumn<String>('job_id')!;

    final manager = $$JobsTableTableManager(
      $_db,
      $_db.jobs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_jobIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$JobTranscriptsTableFilterComposer
    extends Composer<_$AppDatabase, $JobTranscriptsTable> {
  $$JobTranscriptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wordCount => $composableBuilder(
    column: $table.wordCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelName => $composableBuilder(
    column: $table.modelName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => ColumnFilters(column),
  );

  $$JobsTableFilterComposer get jobId {
    final $$JobsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.jobId,
      referencedTable: $db.jobs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobsTableFilterComposer(
            $db: $db,
            $table: $db.jobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$JobTranscriptsTableOrderingComposer
    extends Composer<_$AppDatabase, $JobTranscriptsTable> {
  $$JobTranscriptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wordCount => $composableBuilder(
    column: $table.wordCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelName => $composableBuilder(
    column: $table.modelName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => ColumnOrderings(column),
  );

  $$JobsTableOrderingComposer get jobId {
    final $$JobsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.jobId,
      referencedTable: $db.jobs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobsTableOrderingComposer(
            $db: $db,
            $table: $db.jobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$JobTranscriptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $JobTranscriptsTable> {
  $$JobTranscriptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<int> get wordCount =>
      $composableBuilder(column: $table.wordCount, builder: (column) => column);

  GeneratedColumn<String> get modelName =>
      $composableBuilder(column: $table.modelName, builder: (column) => column);

  GeneratedColumn<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => column,
  );

  $$JobsTableAnnotationComposer get jobId {
    final $$JobsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.jobId,
      referencedTable: $db.jobs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobsTableAnnotationComposer(
            $db: $db,
            $table: $db.jobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$JobTranscriptsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $JobTranscriptsTable,
          TranscriptRow,
          $$JobTranscriptsTableFilterComposer,
          $$JobTranscriptsTableOrderingComposer,
          $$JobTranscriptsTableAnnotationComposer,
          $$JobTranscriptsTableCreateCompanionBuilder,
          $$JobTranscriptsTableUpdateCompanionBuilder,
          (TranscriptRow, $$JobTranscriptsTableReferences),
          TranscriptRow,
          PrefetchHooks Function({bool jobId})
        > {
  $$JobTranscriptsTableTableManager(
    _$AppDatabase db,
    $JobTranscriptsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JobTranscriptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JobTranscriptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JobTranscriptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> jobId = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<int> wordCount = const Value.absent(),
                Value<String?> modelName = const Value.absent(),
                Value<String?> modelVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JobTranscriptsCompanion(
                jobId: jobId,
                content: content,
                wordCount: wordCount,
                modelName: modelName,
                modelVersion: modelVersion,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String jobId,
                required String content,
                required int wordCount,
                Value<String?> modelName = const Value.absent(),
                Value<String?> modelVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JobTranscriptsCompanion.insert(
                jobId: jobId,
                content: content,
                wordCount: wordCount,
                modelName: modelName,
                modelVersion: modelVersion,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$JobTranscriptsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({jobId = false}) {
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
                    if (jobId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.jobId,
                                referencedTable: $$JobTranscriptsTableReferences
                                    ._jobIdTable(db),
                                referencedColumn:
                                    $$JobTranscriptsTableReferences
                                        ._jobIdTable(db)
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

typedef $$JobTranscriptsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $JobTranscriptsTable,
      TranscriptRow,
      $$JobTranscriptsTableFilterComposer,
      $$JobTranscriptsTableOrderingComposer,
      $$JobTranscriptsTableAnnotationComposer,
      $$JobTranscriptsTableCreateCompanionBuilder,
      $$JobTranscriptsTableUpdateCompanionBuilder,
      (TranscriptRow, $$JobTranscriptsTableReferences),
      TranscriptRow,
      PrefetchHooks Function({bool jobId})
    >;
typedef $$JobSummariesTableCreateCompanionBuilder =
    JobSummariesCompanion Function({
      required String jobId,
      required String summaryText,
      required List<String> takeaways,
      required String modelName,
      required String promptVersion,
      Value<bool> needsReview,
      Value<int?> tokensIn,
      Value<int?> tokensOut,
      Value<int?> processingTimeMs,
      Value<int> rowid,
    });
typedef $$JobSummariesTableUpdateCompanionBuilder =
    JobSummariesCompanion Function({
      Value<String> jobId,
      Value<String> summaryText,
      Value<List<String>> takeaways,
      Value<String> modelName,
      Value<String> promptVersion,
      Value<bool> needsReview,
      Value<int?> tokensIn,
      Value<int?> tokensOut,
      Value<int?> processingTimeMs,
      Value<int> rowid,
    });

final class $$JobSummariesTableReferences
    extends BaseReferences<_$AppDatabase, $JobSummariesTable, SummaryRow> {
  $$JobSummariesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $JobsTable _jobIdTable(_$AppDatabase db) =>
      db.jobs.createAlias('job_summaries__job_id__jobs__id');

  $$JobsTableProcessedTableManager get jobId {
    final $_column = $_itemColumn<String>('job_id')!;

    final manager = $$JobsTableTableManager(
      $_db,
      $_db.jobs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_jobIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$JobSummariesTableFilterComposer
    extends Composer<_$AppDatabase, $JobSummariesTable> {
  $$JobSummariesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get summaryText => $composableBuilder(
    column: $table.summaryText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get takeaways => $composableBuilder(
    column: $table.takeaways,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get modelName => $composableBuilder(
    column: $table.modelName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get promptVersion => $composableBuilder(
    column: $table.promptVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get needsReview => $composableBuilder(
    column: $table.needsReview,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tokensIn => $composableBuilder(
    column: $table.tokensIn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tokensOut => $composableBuilder(
    column: $table.tokensOut,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get processingTimeMs => $composableBuilder(
    column: $table.processingTimeMs,
    builder: (column) => ColumnFilters(column),
  );

  $$JobsTableFilterComposer get jobId {
    final $$JobsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.jobId,
      referencedTable: $db.jobs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobsTableFilterComposer(
            $db: $db,
            $table: $db.jobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$JobSummariesTableOrderingComposer
    extends Composer<_$AppDatabase, $JobSummariesTable> {
  $$JobSummariesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get summaryText => $composableBuilder(
    column: $table.summaryText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get takeaways => $composableBuilder(
    column: $table.takeaways,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelName => $composableBuilder(
    column: $table.modelName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get promptVersion => $composableBuilder(
    column: $table.promptVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get needsReview => $composableBuilder(
    column: $table.needsReview,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tokensIn => $composableBuilder(
    column: $table.tokensIn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tokensOut => $composableBuilder(
    column: $table.tokensOut,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get processingTimeMs => $composableBuilder(
    column: $table.processingTimeMs,
    builder: (column) => ColumnOrderings(column),
  );

  $$JobsTableOrderingComposer get jobId {
    final $$JobsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.jobId,
      referencedTable: $db.jobs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobsTableOrderingComposer(
            $db: $db,
            $table: $db.jobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$JobSummariesTableAnnotationComposer
    extends Composer<_$AppDatabase, $JobSummariesTable> {
  $$JobSummariesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get summaryText => $composableBuilder(
    column: $table.summaryText,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<List<String>, String> get takeaways =>
      $composableBuilder(column: $table.takeaways, builder: (column) => column);

  GeneratedColumn<String> get modelName =>
      $composableBuilder(column: $table.modelName, builder: (column) => column);

  GeneratedColumn<String> get promptVersion => $composableBuilder(
    column: $table.promptVersion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get needsReview => $composableBuilder(
    column: $table.needsReview,
    builder: (column) => column,
  );

  GeneratedColumn<int> get tokensIn =>
      $composableBuilder(column: $table.tokensIn, builder: (column) => column);

  GeneratedColumn<int> get tokensOut =>
      $composableBuilder(column: $table.tokensOut, builder: (column) => column);

  GeneratedColumn<int> get processingTimeMs => $composableBuilder(
    column: $table.processingTimeMs,
    builder: (column) => column,
  );

  $$JobsTableAnnotationComposer get jobId {
    final $$JobsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.jobId,
      referencedTable: $db.jobs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobsTableAnnotationComposer(
            $db: $db,
            $table: $db.jobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$JobSummariesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $JobSummariesTable,
          SummaryRow,
          $$JobSummariesTableFilterComposer,
          $$JobSummariesTableOrderingComposer,
          $$JobSummariesTableAnnotationComposer,
          $$JobSummariesTableCreateCompanionBuilder,
          $$JobSummariesTableUpdateCompanionBuilder,
          (SummaryRow, $$JobSummariesTableReferences),
          SummaryRow,
          PrefetchHooks Function({bool jobId})
        > {
  $$JobSummariesTableTableManager(_$AppDatabase db, $JobSummariesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JobSummariesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JobSummariesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JobSummariesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> jobId = const Value.absent(),
                Value<String> summaryText = const Value.absent(),
                Value<List<String>> takeaways = const Value.absent(),
                Value<String> modelName = const Value.absent(),
                Value<String> promptVersion = const Value.absent(),
                Value<bool> needsReview = const Value.absent(),
                Value<int?> tokensIn = const Value.absent(),
                Value<int?> tokensOut = const Value.absent(),
                Value<int?> processingTimeMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JobSummariesCompanion(
                jobId: jobId,
                summaryText: summaryText,
                takeaways: takeaways,
                modelName: modelName,
                promptVersion: promptVersion,
                needsReview: needsReview,
                tokensIn: tokensIn,
                tokensOut: tokensOut,
                processingTimeMs: processingTimeMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String jobId,
                required String summaryText,
                required List<String> takeaways,
                required String modelName,
                required String promptVersion,
                Value<bool> needsReview = const Value.absent(),
                Value<int?> tokensIn = const Value.absent(),
                Value<int?> tokensOut = const Value.absent(),
                Value<int?> processingTimeMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JobSummariesCompanion.insert(
                jobId: jobId,
                summaryText: summaryText,
                takeaways: takeaways,
                modelName: modelName,
                promptVersion: promptVersion,
                needsReview: needsReview,
                tokensIn: tokensIn,
                tokensOut: tokensOut,
                processingTimeMs: processingTimeMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$JobSummariesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({jobId = false}) {
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
                    if (jobId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.jobId,
                                referencedTable: $$JobSummariesTableReferences
                                    ._jobIdTable(db),
                                referencedColumn: $$JobSummariesTableReferences
                                    ._jobIdTable(db)
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

typedef $$JobSummariesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $JobSummariesTable,
      SummaryRow,
      $$JobSummariesTableFilterComposer,
      $$JobSummariesTableOrderingComposer,
      $$JobSummariesTableAnnotationComposer,
      $$JobSummariesTableCreateCompanionBuilder,
      $$JobSummariesTableUpdateCompanionBuilder,
      (SummaryRow, $$JobSummariesTableReferences),
      SummaryRow,
      PrefetchHooks Function({bool jobId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$JobsTableTableManager get jobs => $$JobsTableTableManager(_db, _db.jobs);
  $$JobTranscriptsTableTableManager get jobTranscripts =>
      $$JobTranscriptsTableTableManager(_db, _db.jobTranscripts);
  $$JobSummariesTableTableManager get jobSummaries =>
      $$JobSummariesTableTableManager(_db, _db.jobSummaries);
}
