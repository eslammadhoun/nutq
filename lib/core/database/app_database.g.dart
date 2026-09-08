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
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceTypeMeta = const VerificationMeta(
    'sourceType',
  );
  @override
  late final GeneratedColumn<String> sourceType = GeneratedColumn<String>(
    'source_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _errorCodeMeta = const VerificationMeta(
    'errorCode',
  );
  @override
  late final GeneratedColumn<String> errorCode = GeneratedColumn<String>(
    'error_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _errorDetailMeta = const VerificationMeta(
    'errorDetail',
  );
  @override
  late final GeneratedColumn<String> errorDetail = GeneratedColumn<String>(
    'error_detail',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentTypeMeta = const VerificationMeta(
    'contentType',
  );
  @override
  late final GeneratedColumn<String> contentType = GeneratedColumn<String>(
    'content_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _previewTextMeta = const VerificationMeta(
    'previewText',
  );
  @override
  late final GeneratedColumn<String> previewText = GeneratedColumn<String>(
    'preview_text',
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
  static const VerificationMeta _inlineTextMeta = const VerificationMeta(
    'inlineText',
  );
  @override
  late final GeneratedColumn<String> inlineText = GeneratedColumn<String>(
    'inline_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    status,
    sourceType,
    language,
    createdAt,
    updatedAt,
    errorCode,
    errorDetail,
    contentType,
    previewText,
    sourceFilePath,
    sourceUrl,
    inlineText,
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
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('source_type')) {
      context.handle(
        _sourceTypeMeta,
        sourceType.isAcceptableOrUnknown(data['source_type']!, _sourceTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceTypeMeta);
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    } else if (isInserting) {
      context.missing(_languageMeta);
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
    if (data.containsKey('error_code')) {
      context.handle(
        _errorCodeMeta,
        errorCode.isAcceptableOrUnknown(data['error_code']!, _errorCodeMeta),
      );
    }
    if (data.containsKey('error_detail')) {
      context.handle(
        _errorDetailMeta,
        errorDetail.isAcceptableOrUnknown(
          data['error_detail']!,
          _errorDetailMeta,
        ),
      );
    }
    if (data.containsKey('content_type')) {
      context.handle(
        _contentTypeMeta,
        contentType.isAcceptableOrUnknown(
          data['content_type']!,
          _contentTypeMeta,
        ),
      );
    }
    if (data.containsKey('preview_text')) {
      context.handle(
        _previewTextMeta,
        previewText.isAcceptableOrUnknown(
          data['preview_text']!,
          _previewTextMeta,
        ),
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
    if (data.containsKey('source_url')) {
      context.handle(
        _sourceUrlMeta,
        sourceUrl.isAcceptableOrUnknown(data['source_url']!, _sourceUrlMeta),
      );
    }
    if (data.containsKey('inline_text')) {
      context.handle(
        _inlineTextMeta,
        inlineText.isAcceptableOrUnknown(data['inline_text']!, _inlineTextMeta),
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
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      sourceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_type'],
      )!,
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      errorCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_code'],
      ),
      errorDetail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_detail'],
      ),
      contentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_type'],
      ),
      previewText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preview_text'],
      ),
      sourceFilePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_file_path'],
      ),
      sourceUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_url'],
      ),
      inlineText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}inline_text'],
      ),
    );
  }

  @override
  $JobsTable createAlias(String alias) {
    return $JobsTable(attachedDatabase, alias);
  }
}

class JobRow extends DataClass implements Insertable<JobRow> {
  final String id;
  final String status;
  final String sourceType;
  final String language;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? errorCode;
  final String? errorDetail;
  final String? contentType;
  final String? previewText;
  final String? sourceFilePath;
  final String? sourceUrl;
  final String? inlineText;
  const JobRow({
    required this.id,
    required this.status,
    required this.sourceType,
    required this.language,
    required this.createdAt,
    required this.updatedAt,
    this.errorCode,
    this.errorDetail,
    this.contentType,
    this.previewText,
    this.sourceFilePath,
    this.sourceUrl,
    this.inlineText,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['status'] = Variable<String>(status);
    map['source_type'] = Variable<String>(sourceType);
    map['language'] = Variable<String>(language);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || errorCode != null) {
      map['error_code'] = Variable<String>(errorCode);
    }
    if (!nullToAbsent || errorDetail != null) {
      map['error_detail'] = Variable<String>(errorDetail);
    }
    if (!nullToAbsent || contentType != null) {
      map['content_type'] = Variable<String>(contentType);
    }
    if (!nullToAbsent || previewText != null) {
      map['preview_text'] = Variable<String>(previewText);
    }
    if (!nullToAbsent || sourceFilePath != null) {
      map['source_file_path'] = Variable<String>(sourceFilePath);
    }
    if (!nullToAbsent || sourceUrl != null) {
      map['source_url'] = Variable<String>(sourceUrl);
    }
    if (!nullToAbsent || inlineText != null) {
      map['inline_text'] = Variable<String>(inlineText);
    }
    return map;
  }

  JobsCompanion toCompanion(bool nullToAbsent) {
    return JobsCompanion(
      id: Value(id),
      status: Value(status),
      sourceType: Value(sourceType),
      language: Value(language),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      errorCode: errorCode == null && nullToAbsent
          ? const Value.absent()
          : Value(errorCode),
      errorDetail: errorDetail == null && nullToAbsent
          ? const Value.absent()
          : Value(errorDetail),
      contentType: contentType == null && nullToAbsent
          ? const Value.absent()
          : Value(contentType),
      previewText: previewText == null && nullToAbsent
          ? const Value.absent()
          : Value(previewText),
      sourceFilePath: sourceFilePath == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceFilePath),
      sourceUrl: sourceUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceUrl),
      inlineText: inlineText == null && nullToAbsent
          ? const Value.absent()
          : Value(inlineText),
    );
  }

  factory JobRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JobRow(
      id: serializer.fromJson<String>(json['id']),
      status: serializer.fromJson<String>(json['status']),
      sourceType: serializer.fromJson<String>(json['sourceType']),
      language: serializer.fromJson<String>(json['language']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      errorCode: serializer.fromJson<String?>(json['errorCode']),
      errorDetail: serializer.fromJson<String?>(json['errorDetail']),
      contentType: serializer.fromJson<String?>(json['contentType']),
      previewText: serializer.fromJson<String?>(json['previewText']),
      sourceFilePath: serializer.fromJson<String?>(json['sourceFilePath']),
      sourceUrl: serializer.fromJson<String?>(json['sourceUrl']),
      inlineText: serializer.fromJson<String?>(json['inlineText']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'status': serializer.toJson<String>(status),
      'sourceType': serializer.toJson<String>(sourceType),
      'language': serializer.toJson<String>(language),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'errorCode': serializer.toJson<String?>(errorCode),
      'errorDetail': serializer.toJson<String?>(errorDetail),
      'contentType': serializer.toJson<String?>(contentType),
      'previewText': serializer.toJson<String?>(previewText),
      'sourceFilePath': serializer.toJson<String?>(sourceFilePath),
      'sourceUrl': serializer.toJson<String?>(sourceUrl),
      'inlineText': serializer.toJson<String?>(inlineText),
    };
  }

  JobRow copyWith({
    String? id,
    String? status,
    String? sourceType,
    String? language,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<String?> errorCode = const Value.absent(),
    Value<String?> errorDetail = const Value.absent(),
    Value<String?> contentType = const Value.absent(),
    Value<String?> previewText = const Value.absent(),
    Value<String?> sourceFilePath = const Value.absent(),
    Value<String?> sourceUrl = const Value.absent(),
    Value<String?> inlineText = const Value.absent(),
  }) => JobRow(
    id: id ?? this.id,
    status: status ?? this.status,
    sourceType: sourceType ?? this.sourceType,
    language: language ?? this.language,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    errorCode: errorCode.present ? errorCode.value : this.errorCode,
    errorDetail: errorDetail.present ? errorDetail.value : this.errorDetail,
    contentType: contentType.present ? contentType.value : this.contentType,
    previewText: previewText.present ? previewText.value : this.previewText,
    sourceFilePath: sourceFilePath.present
        ? sourceFilePath.value
        : this.sourceFilePath,
    sourceUrl: sourceUrl.present ? sourceUrl.value : this.sourceUrl,
    inlineText: inlineText.present ? inlineText.value : this.inlineText,
  );
  JobRow copyWithCompanion(JobsCompanion data) {
    return JobRow(
      id: data.id.present ? data.id.value : this.id,
      status: data.status.present ? data.status.value : this.status,
      sourceType: data.sourceType.present
          ? data.sourceType.value
          : this.sourceType,
      language: data.language.present ? data.language.value : this.language,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      errorCode: data.errorCode.present ? data.errorCode.value : this.errorCode,
      errorDetail: data.errorDetail.present
          ? data.errorDetail.value
          : this.errorDetail,
      contentType: data.contentType.present
          ? data.contentType.value
          : this.contentType,
      previewText: data.previewText.present
          ? data.previewText.value
          : this.previewText,
      sourceFilePath: data.sourceFilePath.present
          ? data.sourceFilePath.value
          : this.sourceFilePath,
      sourceUrl: data.sourceUrl.present ? data.sourceUrl.value : this.sourceUrl,
      inlineText: data.inlineText.present
          ? data.inlineText.value
          : this.inlineText,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JobRow(')
          ..write('id: $id, ')
          ..write('status: $status, ')
          ..write('sourceType: $sourceType, ')
          ..write('language: $language, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('errorCode: $errorCode, ')
          ..write('errorDetail: $errorDetail, ')
          ..write('contentType: $contentType, ')
          ..write('previewText: $previewText, ')
          ..write('sourceFilePath: $sourceFilePath, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('inlineText: $inlineText')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    status,
    sourceType,
    language,
    createdAt,
    updatedAt,
    errorCode,
    errorDetail,
    contentType,
    previewText,
    sourceFilePath,
    sourceUrl,
    inlineText,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JobRow &&
          other.id == this.id &&
          other.status == this.status &&
          other.sourceType == this.sourceType &&
          other.language == this.language &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.errorCode == this.errorCode &&
          other.errorDetail == this.errorDetail &&
          other.contentType == this.contentType &&
          other.previewText == this.previewText &&
          other.sourceFilePath == this.sourceFilePath &&
          other.sourceUrl == this.sourceUrl &&
          other.inlineText == this.inlineText);
}

class JobsCompanion extends UpdateCompanion<JobRow> {
  final Value<String> id;
  final Value<String> status;
  final Value<String> sourceType;
  final Value<String> language;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String?> errorCode;
  final Value<String?> errorDetail;
  final Value<String?> contentType;
  final Value<String?> previewText;
  final Value<String?> sourceFilePath;
  final Value<String?> sourceUrl;
  final Value<String?> inlineText;
  final Value<int> rowid;
  const JobsCompanion({
    this.id = const Value.absent(),
    this.status = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.language = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.errorCode = const Value.absent(),
    this.errorDetail = const Value.absent(),
    this.contentType = const Value.absent(),
    this.previewText = const Value.absent(),
    this.sourceFilePath = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.inlineText = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  JobsCompanion.insert({
    required String id,
    required String status,
    required String sourceType,
    required String language,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.errorCode = const Value.absent(),
    this.errorDetail = const Value.absent(),
    this.contentType = const Value.absent(),
    this.previewText = const Value.absent(),
    this.sourceFilePath = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.inlineText = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       status = Value(status),
       sourceType = Value(sourceType),
       language = Value(language),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<JobRow> custom({
    Expression<String>? id,
    Expression<String>? status,
    Expression<String>? sourceType,
    Expression<String>? language,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? errorCode,
    Expression<String>? errorDetail,
    Expression<String>? contentType,
    Expression<String>? previewText,
    Expression<String>? sourceFilePath,
    Expression<String>? sourceUrl,
    Expression<String>? inlineText,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (status != null) 'status': status,
      if (sourceType != null) 'source_type': sourceType,
      if (language != null) 'language': language,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (errorCode != null) 'error_code': errorCode,
      if (errorDetail != null) 'error_detail': errorDetail,
      if (contentType != null) 'content_type': contentType,
      if (previewText != null) 'preview_text': previewText,
      if (sourceFilePath != null) 'source_file_path': sourceFilePath,
      if (sourceUrl != null) 'source_url': sourceUrl,
      if (inlineText != null) 'inline_text': inlineText,
      if (rowid != null) 'rowid': rowid,
    });
  }

  JobsCompanion copyWith({
    Value<String>? id,
    Value<String>? status,
    Value<String>? sourceType,
    Value<String>? language,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String?>? errorCode,
    Value<String?>? errorDetail,
    Value<String?>? contentType,
    Value<String?>? previewText,
    Value<String?>? sourceFilePath,
    Value<String?>? sourceUrl,
    Value<String?>? inlineText,
    Value<int>? rowid,
  }) {
    return JobsCompanion(
      id: id ?? this.id,
      status: status ?? this.status,
      sourceType: sourceType ?? this.sourceType,
      language: language ?? this.language,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      errorCode: errorCode ?? this.errorCode,
      errorDetail: errorDetail ?? this.errorDetail,
      contentType: contentType ?? this.contentType,
      previewText: previewText ?? this.previewText,
      sourceFilePath: sourceFilePath ?? this.sourceFilePath,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      inlineText: inlineText ?? this.inlineText,
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
      map['status'] = Variable<String>(status.value);
    }
    if (sourceType.present) {
      map['source_type'] = Variable<String>(sourceType.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (errorCode.present) {
      map['error_code'] = Variable<String>(errorCode.value);
    }
    if (errorDetail.present) {
      map['error_detail'] = Variable<String>(errorDetail.value);
    }
    if (contentType.present) {
      map['content_type'] = Variable<String>(contentType.value);
    }
    if (previewText.present) {
      map['preview_text'] = Variable<String>(previewText.value);
    }
    if (sourceFilePath.present) {
      map['source_file_path'] = Variable<String>(sourceFilePath.value);
    }
    if (sourceUrl.present) {
      map['source_url'] = Variable<String>(sourceUrl.value);
    }
    if (inlineText.present) {
      map['inline_text'] = Variable<String>(inlineText.value);
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
          ..write('language: $language, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('errorCode: $errorCode, ')
          ..write('errorDetail: $errorDetail, ')
          ..write('contentType: $contentType, ')
          ..write('previewText: $previewText, ')
          ..write('sourceFilePath: $sourceFilePath, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('inlineText: $inlineText, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TranscriptsTable extends Transcripts
    with TableInfo<$TranscriptsTable, TranscriptRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TranscriptsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
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
    true,
    type: DriftSqlType.int,
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
  static const VerificationMeta _modelVersionMeta = const VerificationMeta(
    'modelVersion',
  );
  @override
  late final GeneratedColumn<String> modelVersion = GeneratedColumn<String>(
    'model_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantizationMeta = const VerificationMeta(
    'quantization',
  );
  @override
  late final GeneratedColumn<String> quantization = GeneratedColumn<String>(
    'quantization',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  @override
  List<GeneratedColumn> get $columns => [
    jobId,
    language,
    wordCount,
    durationSeconds,
    modelName,
    modelVersion,
    quantization,
    content,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transcripts';
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
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    } else if (isInserting) {
      context.missing(_languageMeta);
    }
    if (data.containsKey('word_count')) {
      context.handle(
        _wordCountMeta,
        wordCount.isAcceptableOrUnknown(data['word_count']!, _wordCountMeta),
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
    if (data.containsKey('model_name')) {
      context.handle(
        _modelNameMeta,
        modelName.isAcceptableOrUnknown(data['model_name']!, _modelNameMeta),
      );
    } else if (isInserting) {
      context.missing(_modelNameMeta);
    }
    if (data.containsKey('model_version')) {
      context.handle(
        _modelVersionMeta,
        modelVersion.isAcceptableOrUnknown(
          data['model_version']!,
          _modelVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_modelVersionMeta);
    }
    if (data.containsKey('quantization')) {
      context.handle(
        _quantizationMeta,
        quantization.isAcceptableOrUnknown(
          data['quantization']!,
          _quantizationMeta,
        ),
      );
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
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
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      )!,
      wordCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}word_count'],
      ),
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}duration_seconds'],
      ),
      modelName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_name'],
      )!,
      modelVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_version'],
      )!,
      quantization: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quantization'],
      ),
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
    );
  }

  @override
  $TranscriptsTable createAlias(String alias) {
    return $TranscriptsTable(attachedDatabase, alias);
  }
}

class TranscriptRow extends DataClass implements Insertable<TranscriptRow> {
  final String jobId;
  final String language;
  final int? wordCount;
  final double? durationSeconds;
  final String modelName;
  final String modelVersion;
  final String? quantization;
  final String content;
  const TranscriptRow({
    required this.jobId,
    required this.language,
    this.wordCount,
    this.durationSeconds,
    required this.modelName,
    required this.modelVersion,
    this.quantization,
    required this.content,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['job_id'] = Variable<String>(jobId);
    map['language'] = Variable<String>(language);
    if (!nullToAbsent || wordCount != null) {
      map['word_count'] = Variable<int>(wordCount);
    }
    if (!nullToAbsent || durationSeconds != null) {
      map['duration_seconds'] = Variable<double>(durationSeconds);
    }
    map['model_name'] = Variable<String>(modelName);
    map['model_version'] = Variable<String>(modelVersion);
    if (!nullToAbsent || quantization != null) {
      map['quantization'] = Variable<String>(quantization);
    }
    map['content'] = Variable<String>(content);
    return map;
  }

  TranscriptsCompanion toCompanion(bool nullToAbsent) {
    return TranscriptsCompanion(
      jobId: Value(jobId),
      language: Value(language),
      wordCount: wordCount == null && nullToAbsent
          ? const Value.absent()
          : Value(wordCount),
      durationSeconds: durationSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(durationSeconds),
      modelName: Value(modelName),
      modelVersion: Value(modelVersion),
      quantization: quantization == null && nullToAbsent
          ? const Value.absent()
          : Value(quantization),
      content: Value(content),
    );
  }

  factory TranscriptRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TranscriptRow(
      jobId: serializer.fromJson<String>(json['jobId']),
      language: serializer.fromJson<String>(json['language']),
      wordCount: serializer.fromJson<int?>(json['wordCount']),
      durationSeconds: serializer.fromJson<double?>(json['durationSeconds']),
      modelName: serializer.fromJson<String>(json['modelName']),
      modelVersion: serializer.fromJson<String>(json['modelVersion']),
      quantization: serializer.fromJson<String?>(json['quantization']),
      content: serializer.fromJson<String>(json['content']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'jobId': serializer.toJson<String>(jobId),
      'language': serializer.toJson<String>(language),
      'wordCount': serializer.toJson<int?>(wordCount),
      'durationSeconds': serializer.toJson<double?>(durationSeconds),
      'modelName': serializer.toJson<String>(modelName),
      'modelVersion': serializer.toJson<String>(modelVersion),
      'quantization': serializer.toJson<String?>(quantization),
      'content': serializer.toJson<String>(content),
    };
  }

  TranscriptRow copyWith({
    String? jobId,
    String? language,
    Value<int?> wordCount = const Value.absent(),
    Value<double?> durationSeconds = const Value.absent(),
    String? modelName,
    String? modelVersion,
    Value<String?> quantization = const Value.absent(),
    String? content,
  }) => TranscriptRow(
    jobId: jobId ?? this.jobId,
    language: language ?? this.language,
    wordCount: wordCount.present ? wordCount.value : this.wordCount,
    durationSeconds: durationSeconds.present
        ? durationSeconds.value
        : this.durationSeconds,
    modelName: modelName ?? this.modelName,
    modelVersion: modelVersion ?? this.modelVersion,
    quantization: quantization.present ? quantization.value : this.quantization,
    content: content ?? this.content,
  );
  TranscriptRow copyWithCompanion(TranscriptsCompanion data) {
    return TranscriptRow(
      jobId: data.jobId.present ? data.jobId.value : this.jobId,
      language: data.language.present ? data.language.value : this.language,
      wordCount: data.wordCount.present ? data.wordCount.value : this.wordCount,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      modelName: data.modelName.present ? data.modelName.value : this.modelName,
      modelVersion: data.modelVersion.present
          ? data.modelVersion.value
          : this.modelVersion,
      quantization: data.quantization.present
          ? data.quantization.value
          : this.quantization,
      content: data.content.present ? data.content.value : this.content,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TranscriptRow(')
          ..write('jobId: $jobId, ')
          ..write('language: $language, ')
          ..write('wordCount: $wordCount, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('modelName: $modelName, ')
          ..write('modelVersion: $modelVersion, ')
          ..write('quantization: $quantization, ')
          ..write('content: $content')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    jobId,
    language,
    wordCount,
    durationSeconds,
    modelName,
    modelVersion,
    quantization,
    content,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TranscriptRow &&
          other.jobId == this.jobId &&
          other.language == this.language &&
          other.wordCount == this.wordCount &&
          other.durationSeconds == this.durationSeconds &&
          other.modelName == this.modelName &&
          other.modelVersion == this.modelVersion &&
          other.quantization == this.quantization &&
          other.content == this.content);
}

class TranscriptsCompanion extends UpdateCompanion<TranscriptRow> {
  final Value<String> jobId;
  final Value<String> language;
  final Value<int?> wordCount;
  final Value<double?> durationSeconds;
  final Value<String> modelName;
  final Value<String> modelVersion;
  final Value<String?> quantization;
  final Value<String> content;
  final Value<int> rowid;
  const TranscriptsCompanion({
    this.jobId = const Value.absent(),
    this.language = const Value.absent(),
    this.wordCount = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.modelName = const Value.absent(),
    this.modelVersion = const Value.absent(),
    this.quantization = const Value.absent(),
    this.content = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TranscriptsCompanion.insert({
    required String jobId,
    required String language,
    this.wordCount = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    required String modelName,
    required String modelVersion,
    this.quantization = const Value.absent(),
    required String content,
    this.rowid = const Value.absent(),
  }) : jobId = Value(jobId),
       language = Value(language),
       modelName = Value(modelName),
       modelVersion = Value(modelVersion),
       content = Value(content);
  static Insertable<TranscriptRow> custom({
    Expression<String>? jobId,
    Expression<String>? language,
    Expression<int>? wordCount,
    Expression<double>? durationSeconds,
    Expression<String>? modelName,
    Expression<String>? modelVersion,
    Expression<String>? quantization,
    Expression<String>? content,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (jobId != null) 'job_id': jobId,
      if (language != null) 'language': language,
      if (wordCount != null) 'word_count': wordCount,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (modelName != null) 'model_name': modelName,
      if (modelVersion != null) 'model_version': modelVersion,
      if (quantization != null) 'quantization': quantization,
      if (content != null) 'content': content,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TranscriptsCompanion copyWith({
    Value<String>? jobId,
    Value<String>? language,
    Value<int?>? wordCount,
    Value<double?>? durationSeconds,
    Value<String>? modelName,
    Value<String>? modelVersion,
    Value<String?>? quantization,
    Value<String>? content,
    Value<int>? rowid,
  }) {
    return TranscriptsCompanion(
      jobId: jobId ?? this.jobId,
      language: language ?? this.language,
      wordCount: wordCount ?? this.wordCount,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      modelName: modelName ?? this.modelName,
      modelVersion: modelVersion ?? this.modelVersion,
      quantization: quantization ?? this.quantization,
      content: content ?? this.content,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (jobId.present) {
      map['job_id'] = Variable<String>(jobId.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (wordCount.present) {
      map['word_count'] = Variable<int>(wordCount.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<double>(durationSeconds.value);
    }
    if (modelName.present) {
      map['model_name'] = Variable<String>(modelName.value);
    }
    if (modelVersion.present) {
      map['model_version'] = Variable<String>(modelVersion.value);
    }
    if (quantization.present) {
      map['quantization'] = Variable<String>(quantization.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TranscriptsCompanion(')
          ..write('jobId: $jobId, ')
          ..write('language: $language, ')
          ..write('wordCount: $wordCount, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('modelName: $modelName, ')
          ..write('modelVersion: $modelVersion, ')
          ..write('quantization: $quantization, ')
          ..write('content: $content, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SummariesTable extends Summaries
    with TableInfo<$SummariesTable, SummaryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SummariesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _jobIdMeta = const VerificationMeta('jobId');
  @override
  late final GeneratedColumn<String> jobId = GeneratedColumn<String>(
    'job_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'UNIQUE REFERENCES jobs (id) ON DELETE CASCADE',
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
  static const VerificationMeta _toneAndFormatMeta = const VerificationMeta(
    'toneAndFormat',
  );
  @override
  late final GeneratedColumn<String> toneAndFormat = GeneratedColumn<String>(
    'tone_and_format',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    jobId,
    summaryText,
    toneAndFormat,
    modelName,
    promptVersion,
    tokensIn,
    tokensOut,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'summaries';
  @override
  VerificationContext validateIntegrity(
    Insertable<SummaryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
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
    if (data.containsKey('tone_and_format')) {
      context.handle(
        _toneAndFormatMeta,
        toneAndFormat.isAcceptableOrUnknown(
          data['tone_and_format']!,
          _toneAndFormatMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_toneAndFormatMeta);
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SummaryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SummaryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      jobId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}job_id'],
      )!,
      summaryText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary_text'],
      )!,
      toneAndFormat: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tone_and_format'],
      )!,
      modelName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_name'],
      )!,
      promptVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prompt_version'],
      )!,
      tokensIn: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tokens_in'],
      ),
      tokensOut: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tokens_out'],
      ),
    );
  }

  @override
  $SummariesTable createAlias(String alias) {
    return $SummariesTable(attachedDatabase, alias);
  }
}

class SummaryRow extends DataClass implements Insertable<SummaryRow> {
  final int id;
  final String jobId;
  final String summaryText;
  final String toneAndFormat;
  final String modelName;
  final String promptVersion;
  final int? tokensIn;
  final int? tokensOut;
  const SummaryRow({
    required this.id,
    required this.jobId,
    required this.summaryText,
    required this.toneAndFormat,
    required this.modelName,
    required this.promptVersion,
    this.tokensIn,
    this.tokensOut,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['job_id'] = Variable<String>(jobId);
    map['summary_text'] = Variable<String>(summaryText);
    map['tone_and_format'] = Variable<String>(toneAndFormat);
    map['model_name'] = Variable<String>(modelName);
    map['prompt_version'] = Variable<String>(promptVersion);
    if (!nullToAbsent || tokensIn != null) {
      map['tokens_in'] = Variable<int>(tokensIn);
    }
    if (!nullToAbsent || tokensOut != null) {
      map['tokens_out'] = Variable<int>(tokensOut);
    }
    return map;
  }

  SummariesCompanion toCompanion(bool nullToAbsent) {
    return SummariesCompanion(
      id: Value(id),
      jobId: Value(jobId),
      summaryText: Value(summaryText),
      toneAndFormat: Value(toneAndFormat),
      modelName: Value(modelName),
      promptVersion: Value(promptVersion),
      tokensIn: tokensIn == null && nullToAbsent
          ? const Value.absent()
          : Value(tokensIn),
      tokensOut: tokensOut == null && nullToAbsent
          ? const Value.absent()
          : Value(tokensOut),
    );
  }

  factory SummaryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SummaryRow(
      id: serializer.fromJson<int>(json['id']),
      jobId: serializer.fromJson<String>(json['jobId']),
      summaryText: serializer.fromJson<String>(json['summaryText']),
      toneAndFormat: serializer.fromJson<String>(json['toneAndFormat']),
      modelName: serializer.fromJson<String>(json['modelName']),
      promptVersion: serializer.fromJson<String>(json['promptVersion']),
      tokensIn: serializer.fromJson<int?>(json['tokensIn']),
      tokensOut: serializer.fromJson<int?>(json['tokensOut']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'jobId': serializer.toJson<String>(jobId),
      'summaryText': serializer.toJson<String>(summaryText),
      'toneAndFormat': serializer.toJson<String>(toneAndFormat),
      'modelName': serializer.toJson<String>(modelName),
      'promptVersion': serializer.toJson<String>(promptVersion),
      'tokensIn': serializer.toJson<int?>(tokensIn),
      'tokensOut': serializer.toJson<int?>(tokensOut),
    };
  }

  SummaryRow copyWith({
    int? id,
    String? jobId,
    String? summaryText,
    String? toneAndFormat,
    String? modelName,
    String? promptVersion,
    Value<int?> tokensIn = const Value.absent(),
    Value<int?> tokensOut = const Value.absent(),
  }) => SummaryRow(
    id: id ?? this.id,
    jobId: jobId ?? this.jobId,
    summaryText: summaryText ?? this.summaryText,
    toneAndFormat: toneAndFormat ?? this.toneAndFormat,
    modelName: modelName ?? this.modelName,
    promptVersion: promptVersion ?? this.promptVersion,
    tokensIn: tokensIn.present ? tokensIn.value : this.tokensIn,
    tokensOut: tokensOut.present ? tokensOut.value : this.tokensOut,
  );
  SummaryRow copyWithCompanion(SummariesCompanion data) {
    return SummaryRow(
      id: data.id.present ? data.id.value : this.id,
      jobId: data.jobId.present ? data.jobId.value : this.jobId,
      summaryText: data.summaryText.present
          ? data.summaryText.value
          : this.summaryText,
      toneAndFormat: data.toneAndFormat.present
          ? data.toneAndFormat.value
          : this.toneAndFormat,
      modelName: data.modelName.present ? data.modelName.value : this.modelName,
      promptVersion: data.promptVersion.present
          ? data.promptVersion.value
          : this.promptVersion,
      tokensIn: data.tokensIn.present ? data.tokensIn.value : this.tokensIn,
      tokensOut: data.tokensOut.present ? data.tokensOut.value : this.tokensOut,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SummaryRow(')
          ..write('id: $id, ')
          ..write('jobId: $jobId, ')
          ..write('summaryText: $summaryText, ')
          ..write('toneAndFormat: $toneAndFormat, ')
          ..write('modelName: $modelName, ')
          ..write('promptVersion: $promptVersion, ')
          ..write('tokensIn: $tokensIn, ')
          ..write('tokensOut: $tokensOut')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    jobId,
    summaryText,
    toneAndFormat,
    modelName,
    promptVersion,
    tokensIn,
    tokensOut,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SummaryRow &&
          other.id == this.id &&
          other.jobId == this.jobId &&
          other.summaryText == this.summaryText &&
          other.toneAndFormat == this.toneAndFormat &&
          other.modelName == this.modelName &&
          other.promptVersion == this.promptVersion &&
          other.tokensIn == this.tokensIn &&
          other.tokensOut == this.tokensOut);
}

class SummariesCompanion extends UpdateCompanion<SummaryRow> {
  final Value<int> id;
  final Value<String> jobId;
  final Value<String> summaryText;
  final Value<String> toneAndFormat;
  final Value<String> modelName;
  final Value<String> promptVersion;
  final Value<int?> tokensIn;
  final Value<int?> tokensOut;
  const SummariesCompanion({
    this.id = const Value.absent(),
    this.jobId = const Value.absent(),
    this.summaryText = const Value.absent(),
    this.toneAndFormat = const Value.absent(),
    this.modelName = const Value.absent(),
    this.promptVersion = const Value.absent(),
    this.tokensIn = const Value.absent(),
    this.tokensOut = const Value.absent(),
  });
  SummariesCompanion.insert({
    this.id = const Value.absent(),
    required String jobId,
    required String summaryText,
    required String toneAndFormat,
    required String modelName,
    required String promptVersion,
    this.tokensIn = const Value.absent(),
    this.tokensOut = const Value.absent(),
  }) : jobId = Value(jobId),
       summaryText = Value(summaryText),
       toneAndFormat = Value(toneAndFormat),
       modelName = Value(modelName),
       promptVersion = Value(promptVersion);
  static Insertable<SummaryRow> custom({
    Expression<int>? id,
    Expression<String>? jobId,
    Expression<String>? summaryText,
    Expression<String>? toneAndFormat,
    Expression<String>? modelName,
    Expression<String>? promptVersion,
    Expression<int>? tokensIn,
    Expression<int>? tokensOut,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (jobId != null) 'job_id': jobId,
      if (summaryText != null) 'summary_text': summaryText,
      if (toneAndFormat != null) 'tone_and_format': toneAndFormat,
      if (modelName != null) 'model_name': modelName,
      if (promptVersion != null) 'prompt_version': promptVersion,
      if (tokensIn != null) 'tokens_in': tokensIn,
      if (tokensOut != null) 'tokens_out': tokensOut,
    });
  }

  SummariesCompanion copyWith({
    Value<int>? id,
    Value<String>? jobId,
    Value<String>? summaryText,
    Value<String>? toneAndFormat,
    Value<String>? modelName,
    Value<String>? promptVersion,
    Value<int?>? tokensIn,
    Value<int?>? tokensOut,
  }) {
    return SummariesCompanion(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      summaryText: summaryText ?? this.summaryText,
      toneAndFormat: toneAndFormat ?? this.toneAndFormat,
      modelName: modelName ?? this.modelName,
      promptVersion: promptVersion ?? this.promptVersion,
      tokensIn: tokensIn ?? this.tokensIn,
      tokensOut: tokensOut ?? this.tokensOut,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (jobId.present) {
      map['job_id'] = Variable<String>(jobId.value);
    }
    if (summaryText.present) {
      map['summary_text'] = Variable<String>(summaryText.value);
    }
    if (toneAndFormat.present) {
      map['tone_and_format'] = Variable<String>(toneAndFormat.value);
    }
    if (modelName.present) {
      map['model_name'] = Variable<String>(modelName.value);
    }
    if (promptVersion.present) {
      map['prompt_version'] = Variable<String>(promptVersion.value);
    }
    if (tokensIn.present) {
      map['tokens_in'] = Variable<int>(tokensIn.value);
    }
    if (tokensOut.present) {
      map['tokens_out'] = Variable<int>(tokensOut.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SummariesCompanion(')
          ..write('id: $id, ')
          ..write('jobId: $jobId, ')
          ..write('summaryText: $summaryText, ')
          ..write('toneAndFormat: $toneAndFormat, ')
          ..write('modelName: $modelName, ')
          ..write('promptVersion: $promptVersion, ')
          ..write('tokensIn: $tokensIn, ')
          ..write('tokensOut: $tokensOut')
          ..write(')'))
        .toString();
  }
}

class $TakeawaysTable extends Takeaways
    with TableInfo<$TakeawaysTable, TakeawayRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TakeawaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _summaryIdMeta = const VerificationMeta(
    'summaryId',
  );
  @override
  late final GeneratedColumn<int> summaryId = GeneratedColumn<int>(
    'summary_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES summaries (id) ON DELETE CASCADE',
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
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, summaryId, content, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'takeaways';
  @override
  VerificationContext validateIntegrity(
    Insertable<TakeawayRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('summary_id')) {
      context.handle(
        _summaryIdMeta,
        summaryId.isAcceptableOrUnknown(data['summary_id']!, _summaryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_summaryIdMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TakeawayRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TakeawayRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      summaryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}summary_id'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $TakeawaysTable createAlias(String alias) {
    return $TakeawaysTable(attachedDatabase, alias);
  }
}

class TakeawayRow extends DataClass implements Insertable<TakeawayRow> {
  final int id;
  final int summaryId;
  final String content;
  final int sortOrder;
  const TakeawayRow({
    required this.id,
    required this.summaryId,
    required this.content,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['summary_id'] = Variable<int>(summaryId);
    map['content'] = Variable<String>(content);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  TakeawaysCompanion toCompanion(bool nullToAbsent) {
    return TakeawaysCompanion(
      id: Value(id),
      summaryId: Value(summaryId),
      content: Value(content),
      sortOrder: Value(sortOrder),
    );
  }

  factory TakeawayRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TakeawayRow(
      id: serializer.fromJson<int>(json['id']),
      summaryId: serializer.fromJson<int>(json['summaryId']),
      content: serializer.fromJson<String>(json['content']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'summaryId': serializer.toJson<int>(summaryId),
      'content': serializer.toJson<String>(content),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  TakeawayRow copyWith({
    int? id,
    int? summaryId,
    String? content,
    int? sortOrder,
  }) => TakeawayRow(
    id: id ?? this.id,
    summaryId: summaryId ?? this.summaryId,
    content: content ?? this.content,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  TakeawayRow copyWithCompanion(TakeawaysCompanion data) {
    return TakeawayRow(
      id: data.id.present ? data.id.value : this.id,
      summaryId: data.summaryId.present ? data.summaryId.value : this.summaryId,
      content: data.content.present ? data.content.value : this.content,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TakeawayRow(')
          ..write('id: $id, ')
          ..write('summaryId: $summaryId, ')
          ..write('content: $content, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, summaryId, content, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TakeawayRow &&
          other.id == this.id &&
          other.summaryId == this.summaryId &&
          other.content == this.content &&
          other.sortOrder == this.sortOrder);
}

class TakeawaysCompanion extends UpdateCompanion<TakeawayRow> {
  final Value<int> id;
  final Value<int> summaryId;
  final Value<String> content;
  final Value<int> sortOrder;
  const TakeawaysCompanion({
    this.id = const Value.absent(),
    this.summaryId = const Value.absent(),
    this.content = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  TakeawaysCompanion.insert({
    this.id = const Value.absent(),
    required int summaryId,
    required String content,
    required int sortOrder,
  }) : summaryId = Value(summaryId),
       content = Value(content),
       sortOrder = Value(sortOrder);
  static Insertable<TakeawayRow> custom({
    Expression<int>? id,
    Expression<int>? summaryId,
    Expression<String>? content,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (summaryId != null) 'summary_id': summaryId,
      if (content != null) 'content': content,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  TakeawaysCompanion copyWith({
    Value<int>? id,
    Value<int>? summaryId,
    Value<String>? content,
    Value<int>? sortOrder,
  }) {
    return TakeawaysCompanion(
      id: id ?? this.id,
      summaryId: summaryId ?? this.summaryId,
      content: content ?? this.content,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (summaryId.present) {
      map['summary_id'] = Variable<int>(summaryId.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TakeawaysCompanion(')
          ..write('id: $id, ')
          ..write('summaryId: $summaryId, ')
          ..write('content: $content, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $InstalledModelsTable extends InstalledModels
    with TableInfo<$InstalledModelsTable, InstalledModelRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InstalledModelsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _modelIdMeta = const VerificationMeta(
    'modelId',
  );
  @override
  late final GeneratedColumn<String> modelId = GeneratedColumn<String>(
    'model_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tierMeta = const VerificationMeta('tier');
  @override
  late final GeneratedColumn<String> tier = GeneratedColumn<String>(
    'tier',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _downloadedAtMeta = const VerificationMeta(
    'downloadedAt',
  );
  @override
  late final GeneratedColumn<DateTime> downloadedAt = GeneratedColumn<DateTime>(
    'downloaded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _checksumMeta = const VerificationMeta(
    'checksum',
  );
  @override
  late final GeneratedColumn<String> checksum = GeneratedColumn<String>(
    'checksum',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    modelId,
    kind,
    tier,
    filePath,
    downloadedAt,
    sizeBytes,
    checksum,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'installed_models';
  @override
  VerificationContext validateIntegrity(
    Insertable<InstalledModelRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('model_id')) {
      context.handle(
        _modelIdMeta,
        modelId.isAcceptableOrUnknown(data['model_id']!, _modelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_modelIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('tier')) {
      context.handle(
        _tierMeta,
        tier.isAcceptableOrUnknown(data['tier']!, _tierMeta),
      );
    } else if (isInserting) {
      context.missing(_tierMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('downloaded_at')) {
      context.handle(
        _downloadedAtMeta,
        downloadedAt.isAcceptableOrUnknown(
          data['downloaded_at']!,
          _downloadedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_downloadedAtMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeBytesMeta);
    }
    if (data.containsKey('checksum')) {
      context.handle(
        _checksumMeta,
        checksum.isAcceptableOrUnknown(data['checksum']!, _checksumMeta),
      );
    } else if (isInserting) {
      context.missing(_checksumMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {modelId};
  @override
  InstalledModelRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InstalledModelRow(
      modelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      tier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tier'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      downloadedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}downloaded_at'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
      checksum: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}checksum'],
      )!,
    );
  }

  @override
  $InstalledModelsTable createAlias(String alias) {
    return $InstalledModelsTable(attachedDatabase, alias);
  }
}

class InstalledModelRow extends DataClass
    implements Insertable<InstalledModelRow> {
  final String modelId;
  final String kind;
  final String tier;
  final String filePath;
  final DateTime downloadedAt;
  final int sizeBytes;
  final String checksum;
  const InstalledModelRow({
    required this.modelId,
    required this.kind,
    required this.tier,
    required this.filePath,
    required this.downloadedAt,
    required this.sizeBytes,
    required this.checksum,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['model_id'] = Variable<String>(modelId);
    map['kind'] = Variable<String>(kind);
    map['tier'] = Variable<String>(tier);
    map['file_path'] = Variable<String>(filePath);
    map['downloaded_at'] = Variable<DateTime>(downloadedAt);
    map['size_bytes'] = Variable<int>(sizeBytes);
    map['checksum'] = Variable<String>(checksum);
    return map;
  }

  InstalledModelsCompanion toCompanion(bool nullToAbsent) {
    return InstalledModelsCompanion(
      modelId: Value(modelId),
      kind: Value(kind),
      tier: Value(tier),
      filePath: Value(filePath),
      downloadedAt: Value(downloadedAt),
      sizeBytes: Value(sizeBytes),
      checksum: Value(checksum),
    );
  }

  factory InstalledModelRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InstalledModelRow(
      modelId: serializer.fromJson<String>(json['modelId']),
      kind: serializer.fromJson<String>(json['kind']),
      tier: serializer.fromJson<String>(json['tier']),
      filePath: serializer.fromJson<String>(json['filePath']),
      downloadedAt: serializer.fromJson<DateTime>(json['downloadedAt']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      checksum: serializer.fromJson<String>(json['checksum']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'modelId': serializer.toJson<String>(modelId),
      'kind': serializer.toJson<String>(kind),
      'tier': serializer.toJson<String>(tier),
      'filePath': serializer.toJson<String>(filePath),
      'downloadedAt': serializer.toJson<DateTime>(downloadedAt),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'checksum': serializer.toJson<String>(checksum),
    };
  }

  InstalledModelRow copyWith({
    String? modelId,
    String? kind,
    String? tier,
    String? filePath,
    DateTime? downloadedAt,
    int? sizeBytes,
    String? checksum,
  }) => InstalledModelRow(
    modelId: modelId ?? this.modelId,
    kind: kind ?? this.kind,
    tier: tier ?? this.tier,
    filePath: filePath ?? this.filePath,
    downloadedAt: downloadedAt ?? this.downloadedAt,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    checksum: checksum ?? this.checksum,
  );
  InstalledModelRow copyWithCompanion(InstalledModelsCompanion data) {
    return InstalledModelRow(
      modelId: data.modelId.present ? data.modelId.value : this.modelId,
      kind: data.kind.present ? data.kind.value : this.kind,
      tier: data.tier.present ? data.tier.value : this.tier,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      downloadedAt: data.downloadedAt.present
          ? data.downloadedAt.value
          : this.downloadedAt,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      checksum: data.checksum.present ? data.checksum.value : this.checksum,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InstalledModelRow(')
          ..write('modelId: $modelId, ')
          ..write('kind: $kind, ')
          ..write('tier: $tier, ')
          ..write('filePath: $filePath, ')
          ..write('downloadedAt: $downloadedAt, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('checksum: $checksum')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    modelId,
    kind,
    tier,
    filePath,
    downloadedAt,
    sizeBytes,
    checksum,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InstalledModelRow &&
          other.modelId == this.modelId &&
          other.kind == this.kind &&
          other.tier == this.tier &&
          other.filePath == this.filePath &&
          other.downloadedAt == this.downloadedAt &&
          other.sizeBytes == this.sizeBytes &&
          other.checksum == this.checksum);
}

class InstalledModelsCompanion extends UpdateCompanion<InstalledModelRow> {
  final Value<String> modelId;
  final Value<String> kind;
  final Value<String> tier;
  final Value<String> filePath;
  final Value<DateTime> downloadedAt;
  final Value<int> sizeBytes;
  final Value<String> checksum;
  final Value<int> rowid;
  const InstalledModelsCompanion({
    this.modelId = const Value.absent(),
    this.kind = const Value.absent(),
    this.tier = const Value.absent(),
    this.filePath = const Value.absent(),
    this.downloadedAt = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.checksum = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InstalledModelsCompanion.insert({
    required String modelId,
    required String kind,
    required String tier,
    required String filePath,
    required DateTime downloadedAt,
    required int sizeBytes,
    required String checksum,
    this.rowid = const Value.absent(),
  }) : modelId = Value(modelId),
       kind = Value(kind),
       tier = Value(tier),
       filePath = Value(filePath),
       downloadedAt = Value(downloadedAt),
       sizeBytes = Value(sizeBytes),
       checksum = Value(checksum);
  static Insertable<InstalledModelRow> custom({
    Expression<String>? modelId,
    Expression<String>? kind,
    Expression<String>? tier,
    Expression<String>? filePath,
    Expression<DateTime>? downloadedAt,
    Expression<int>? sizeBytes,
    Expression<String>? checksum,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (modelId != null) 'model_id': modelId,
      if (kind != null) 'kind': kind,
      if (tier != null) 'tier': tier,
      if (filePath != null) 'file_path': filePath,
      if (downloadedAt != null) 'downloaded_at': downloadedAt,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (checksum != null) 'checksum': checksum,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InstalledModelsCompanion copyWith({
    Value<String>? modelId,
    Value<String>? kind,
    Value<String>? tier,
    Value<String>? filePath,
    Value<DateTime>? downloadedAt,
    Value<int>? sizeBytes,
    Value<String>? checksum,
    Value<int>? rowid,
  }) {
    return InstalledModelsCompanion(
      modelId: modelId ?? this.modelId,
      kind: kind ?? this.kind,
      tier: tier ?? this.tier,
      filePath: filePath ?? this.filePath,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      checksum: checksum ?? this.checksum,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (modelId.present) {
      map['model_id'] = Variable<String>(modelId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (tier.present) {
      map['tier'] = Variable<String>(tier.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (downloadedAt.present) {
      map['downloaded_at'] = Variable<DateTime>(downloadedAt.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (checksum.present) {
      map['checksum'] = Variable<String>(checksum.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InstalledModelsCompanion(')
          ..write('modelId: $modelId, ')
          ..write('kind: $kind, ')
          ..write('tier: $tier, ')
          ..write('filePath: $filePath, ')
          ..write('downloadedAt: $downloadedAt, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('checksum: $checksum, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $JobsTable jobs = $JobsTable(this);
  late final $TranscriptsTable transcripts = $TranscriptsTable(this);
  late final $SummariesTable summaries = $SummariesTable(this);
  late final $TakeawaysTable takeaways = $TakeawaysTable(this);
  late final $InstalledModelsTable installedModels = $InstalledModelsTable(
    this,
  );
  late final JobsDao jobsDao = JobsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    jobs,
    transcripts,
    summaries,
    takeaways,
    installedModels,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'jobs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('transcripts', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'jobs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('summaries', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'summaries',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('takeaways', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$JobsTableCreateCompanionBuilder =
    JobsCompanion Function({
      required String id,
      required String status,
      required String sourceType,
      required String language,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<String?> errorCode,
      Value<String?> errorDetail,
      Value<String?> contentType,
      Value<String?> previewText,
      Value<String?> sourceFilePath,
      Value<String?> sourceUrl,
      Value<String?> inlineText,
      Value<int> rowid,
    });
typedef $$JobsTableUpdateCompanionBuilder =
    JobsCompanion Function({
      Value<String> id,
      Value<String> status,
      Value<String> sourceType,
      Value<String> language,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String?> errorCode,
      Value<String?> errorDetail,
      Value<String?> contentType,
      Value<String?> previewText,
      Value<String?> sourceFilePath,
      Value<String?> sourceUrl,
      Value<String?> inlineText,
      Value<int> rowid,
    });

final class $$JobsTableReferences
    extends BaseReferences<_$AppDatabase, $JobsTable, JobRow> {
  $$JobsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TranscriptsTable, List<TranscriptRow>>
  _transcriptsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transcripts,
    aliasName: 'jobs__id__transcripts__job_id',
  );

  $$TranscriptsTableProcessedTableManager get transcriptsRefs {
    final manager = $$TranscriptsTableTableManager(
      $_db,
      $_db.transcripts,
    ).filter((f) => f.jobId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_transcriptsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SummariesTable, List<SummaryRow>>
  _summariesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.summaries,
    aliasName: 'jobs__id__summaries__job_id',
  );

  $$SummariesTableProcessedTableManager get summariesRefs {
    final manager = $$SummariesTableTableManager(
      $_db,
      $_db.summaries,
    ).filter((f) => f.jobId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_summariesRefsTable($_db));
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

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
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

  ColumnFilters<String> get errorCode => $composableBuilder(
    column: $table.errorCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorDetail => $composableBuilder(
    column: $table.errorDetail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get previewText => $composableBuilder(
    column: $table.previewText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceFilePath => $composableBuilder(
    column: $table.sourceFilePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get inlineText => $composableBuilder(
    column: $table.inlineText,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> transcriptsRefs(
    Expression<bool> Function($$TranscriptsTableFilterComposer f) f,
  ) {
    final $$TranscriptsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transcripts,
      getReferencedColumn: (t) => t.jobId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TranscriptsTableFilterComposer(
            $db: $db,
            $table: $db.transcripts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> summariesRefs(
    Expression<bool> Function($$SummariesTableFilterComposer f) f,
  ) {
    final $$SummariesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.summaries,
      getReferencedColumn: (t) => t.jobId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SummariesTableFilterComposer(
            $db: $db,
            $table: $db.summaries,
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

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
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

  ColumnOrderings<String> get errorCode => $composableBuilder(
    column: $table.errorCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorDetail => $composableBuilder(
    column: $table.errorDetail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get previewText => $composableBuilder(
    column: $table.previewText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceFilePath => $composableBuilder(
    column: $table.sourceFilePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get inlineText => $composableBuilder(
    column: $table.inlineText,
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

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get errorCode =>
      $composableBuilder(column: $table.errorCode, builder: (column) => column);

  GeneratedColumn<String> get errorDetail => $composableBuilder(
    column: $table.errorDetail,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get previewText => $composableBuilder(
    column: $table.previewText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceFilePath => $composableBuilder(
    column: $table.sourceFilePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceUrl =>
      $composableBuilder(column: $table.sourceUrl, builder: (column) => column);

  GeneratedColumn<String> get inlineText => $composableBuilder(
    column: $table.inlineText,
    builder: (column) => column,
  );

  Expression<T> transcriptsRefs<T extends Object>(
    Expression<T> Function($$TranscriptsTableAnnotationComposer a) f,
  ) {
    final $$TranscriptsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transcripts,
      getReferencedColumn: (t) => t.jobId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TranscriptsTableAnnotationComposer(
            $db: $db,
            $table: $db.transcripts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> summariesRefs<T extends Object>(
    Expression<T> Function($$SummariesTableAnnotationComposer a) f,
  ) {
    final $$SummariesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.summaries,
      getReferencedColumn: (t) => t.jobId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SummariesTableAnnotationComposer(
            $db: $db,
            $table: $db.summaries,
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
          PrefetchHooks Function({bool transcriptsRefs, bool summariesRefs})
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
                Value<String> status = const Value.absent(),
                Value<String> sourceType = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> errorCode = const Value.absent(),
                Value<String?> errorDetail = const Value.absent(),
                Value<String?> contentType = const Value.absent(),
                Value<String?> previewText = const Value.absent(),
                Value<String?> sourceFilePath = const Value.absent(),
                Value<String?> sourceUrl = const Value.absent(),
                Value<String?> inlineText = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JobsCompanion(
                id: id,
                status: status,
                sourceType: sourceType,
                language: language,
                createdAt: createdAt,
                updatedAt: updatedAt,
                errorCode: errorCode,
                errorDetail: errorDetail,
                contentType: contentType,
                previewText: previewText,
                sourceFilePath: sourceFilePath,
                sourceUrl: sourceUrl,
                inlineText: inlineText,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String status,
                required String sourceType,
                required String language,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<String?> errorCode = const Value.absent(),
                Value<String?> errorDetail = const Value.absent(),
                Value<String?> contentType = const Value.absent(),
                Value<String?> previewText = const Value.absent(),
                Value<String?> sourceFilePath = const Value.absent(),
                Value<String?> sourceUrl = const Value.absent(),
                Value<String?> inlineText = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JobsCompanion.insert(
                id: id,
                status: status,
                sourceType: sourceType,
                language: language,
                createdAt: createdAt,
                updatedAt: updatedAt,
                errorCode: errorCode,
                errorDetail: errorDetail,
                contentType: contentType,
                previewText: previewText,
                sourceFilePath: sourceFilePath,
                sourceUrl: sourceUrl,
                inlineText: inlineText,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$JobsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({transcriptsRefs = false, summariesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (transcriptsRefs) db.transcripts,
                    if (summariesRefs) db.summaries,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (transcriptsRefs)
                        await $_getPrefetchedData<
                          JobRow,
                          $JobsTable,
                          TranscriptRow
                        >(
                          currentTable: table,
                          referencedTable: $$JobsTableReferences
                              ._transcriptsRefsTable(db),
                          managerFromTypedResult: (p0) => $$JobsTableReferences(
                            db,
                            table,
                            p0,
                          ).transcriptsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.jobId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (summariesRefs)
                        await $_getPrefetchedData<
                          JobRow,
                          $JobsTable,
                          SummaryRow
                        >(
                          currentTable: table,
                          referencedTable: $$JobsTableReferences
                              ._summariesRefsTable(db),
                          managerFromTypedResult: (p0) => $$JobsTableReferences(
                            db,
                            table,
                            p0,
                          ).summariesRefs,
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
      PrefetchHooks Function({bool transcriptsRefs, bool summariesRefs})
    >;
typedef $$TranscriptsTableCreateCompanionBuilder =
    TranscriptsCompanion Function({
      required String jobId,
      required String language,
      Value<int?> wordCount,
      Value<double?> durationSeconds,
      required String modelName,
      required String modelVersion,
      Value<String?> quantization,
      required String content,
      Value<int> rowid,
    });
typedef $$TranscriptsTableUpdateCompanionBuilder =
    TranscriptsCompanion Function({
      Value<String> jobId,
      Value<String> language,
      Value<int?> wordCount,
      Value<double?> durationSeconds,
      Value<String> modelName,
      Value<String> modelVersion,
      Value<String?> quantization,
      Value<String> content,
      Value<int> rowid,
    });

final class $$TranscriptsTableReferences
    extends BaseReferences<_$AppDatabase, $TranscriptsTable, TranscriptRow> {
  $$TranscriptsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $JobsTable _jobIdTable(_$AppDatabase db) =>
      db.jobs.createAlias('transcripts__job_id__jobs__id');

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

class $$TranscriptsTableFilterComposer
    extends Composer<_$AppDatabase, $TranscriptsTable> {
  $$TranscriptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wordCount => $composableBuilder(
    column: $table.wordCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
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

  ColumnFilters<String> get quantization => $composableBuilder(
    column: $table.quantization,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
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

class $$TranscriptsTableOrderingComposer
    extends Composer<_$AppDatabase, $TranscriptsTable> {
  $$TranscriptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wordCount => $composableBuilder(
    column: $table.wordCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
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

  ColumnOrderings<String> get quantization => $composableBuilder(
    column: $table.quantization,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
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

class $$TranscriptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TranscriptsTable> {
  $$TranscriptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<int> get wordCount =>
      $composableBuilder(column: $table.wordCount, builder: (column) => column);

  GeneratedColumn<double> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get modelName =>
      $composableBuilder(column: $table.modelName, builder: (column) => column);

  GeneratedColumn<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get quantization => $composableBuilder(
    column: $table.quantization,
    builder: (column) => column,
  );

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

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

class $$TranscriptsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TranscriptsTable,
          TranscriptRow,
          $$TranscriptsTableFilterComposer,
          $$TranscriptsTableOrderingComposer,
          $$TranscriptsTableAnnotationComposer,
          $$TranscriptsTableCreateCompanionBuilder,
          $$TranscriptsTableUpdateCompanionBuilder,
          (TranscriptRow, $$TranscriptsTableReferences),
          TranscriptRow,
          PrefetchHooks Function({bool jobId})
        > {
  $$TranscriptsTableTableManager(_$AppDatabase db, $TranscriptsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TranscriptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TranscriptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TranscriptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> jobId = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<int?> wordCount = const Value.absent(),
                Value<double?> durationSeconds = const Value.absent(),
                Value<String> modelName = const Value.absent(),
                Value<String> modelVersion = const Value.absent(),
                Value<String?> quantization = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TranscriptsCompanion(
                jobId: jobId,
                language: language,
                wordCount: wordCount,
                durationSeconds: durationSeconds,
                modelName: modelName,
                modelVersion: modelVersion,
                quantization: quantization,
                content: content,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String jobId,
                required String language,
                Value<int?> wordCount = const Value.absent(),
                Value<double?> durationSeconds = const Value.absent(),
                required String modelName,
                required String modelVersion,
                Value<String?> quantization = const Value.absent(),
                required String content,
                Value<int> rowid = const Value.absent(),
              }) => TranscriptsCompanion.insert(
                jobId: jobId,
                language: language,
                wordCount: wordCount,
                durationSeconds: durationSeconds,
                modelName: modelName,
                modelVersion: modelVersion,
                quantization: quantization,
                content: content,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TranscriptsTableReferences(db, table, e),
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
                                referencedTable: $$TranscriptsTableReferences
                                    ._jobIdTable(db),
                                referencedColumn: $$TranscriptsTableReferences
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

typedef $$TranscriptsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TranscriptsTable,
      TranscriptRow,
      $$TranscriptsTableFilterComposer,
      $$TranscriptsTableOrderingComposer,
      $$TranscriptsTableAnnotationComposer,
      $$TranscriptsTableCreateCompanionBuilder,
      $$TranscriptsTableUpdateCompanionBuilder,
      (TranscriptRow, $$TranscriptsTableReferences),
      TranscriptRow,
      PrefetchHooks Function({bool jobId})
    >;
typedef $$SummariesTableCreateCompanionBuilder =
    SummariesCompanion Function({
      Value<int> id,
      required String jobId,
      required String summaryText,
      required String toneAndFormat,
      required String modelName,
      required String promptVersion,
      Value<int?> tokensIn,
      Value<int?> tokensOut,
    });
typedef $$SummariesTableUpdateCompanionBuilder =
    SummariesCompanion Function({
      Value<int> id,
      Value<String> jobId,
      Value<String> summaryText,
      Value<String> toneAndFormat,
      Value<String> modelName,
      Value<String> promptVersion,
      Value<int?> tokensIn,
      Value<int?> tokensOut,
    });

final class $$SummariesTableReferences
    extends BaseReferences<_$AppDatabase, $SummariesTable, SummaryRow> {
  $$SummariesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $JobsTable _jobIdTable(_$AppDatabase db) =>
      db.jobs.createAlias('summaries__job_id__jobs__id');

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

  static MultiTypedResultKey<$TakeawaysTable, List<TakeawayRow>>
  _takeawaysRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.takeaways,
    aliasName: 'summaries__id__takeaways__summary_id',
  );

  $$TakeawaysTableProcessedTableManager get takeawaysRefs {
    final manager = $$TakeawaysTableTableManager(
      $_db,
      $_db.takeaways,
    ).filter((f) => f.summaryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_takeawaysRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SummariesTableFilterComposer
    extends Composer<_$AppDatabase, $SummariesTable> {
  $$SummariesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summaryText => $composableBuilder(
    column: $table.summaryText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toneAndFormat => $composableBuilder(
    column: $table.toneAndFormat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelName => $composableBuilder(
    column: $table.modelName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get promptVersion => $composableBuilder(
    column: $table.promptVersion,
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

  Expression<bool> takeawaysRefs(
    Expression<bool> Function($$TakeawaysTableFilterComposer f) f,
  ) {
    final $$TakeawaysTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.takeaways,
      getReferencedColumn: (t) => t.summaryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TakeawaysTableFilterComposer(
            $db: $db,
            $table: $db.takeaways,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SummariesTableOrderingComposer
    extends Composer<_$AppDatabase, $SummariesTable> {
  $$SummariesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summaryText => $composableBuilder(
    column: $table.summaryText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toneAndFormat => $composableBuilder(
    column: $table.toneAndFormat,
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

  ColumnOrderings<int> get tokensIn => $composableBuilder(
    column: $table.tokensIn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tokensOut => $composableBuilder(
    column: $table.tokensOut,
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

class $$SummariesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SummariesTable> {
  $$SummariesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get summaryText => $composableBuilder(
    column: $table.summaryText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get toneAndFormat => $composableBuilder(
    column: $table.toneAndFormat,
    builder: (column) => column,
  );

  GeneratedColumn<String> get modelName =>
      $composableBuilder(column: $table.modelName, builder: (column) => column);

  GeneratedColumn<String> get promptVersion => $composableBuilder(
    column: $table.promptVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get tokensIn =>
      $composableBuilder(column: $table.tokensIn, builder: (column) => column);

  GeneratedColumn<int> get tokensOut =>
      $composableBuilder(column: $table.tokensOut, builder: (column) => column);

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

  Expression<T> takeawaysRefs<T extends Object>(
    Expression<T> Function($$TakeawaysTableAnnotationComposer a) f,
  ) {
    final $$TakeawaysTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.takeaways,
      getReferencedColumn: (t) => t.summaryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TakeawaysTableAnnotationComposer(
            $db: $db,
            $table: $db.takeaways,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SummariesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SummariesTable,
          SummaryRow,
          $$SummariesTableFilterComposer,
          $$SummariesTableOrderingComposer,
          $$SummariesTableAnnotationComposer,
          $$SummariesTableCreateCompanionBuilder,
          $$SummariesTableUpdateCompanionBuilder,
          (SummaryRow, $$SummariesTableReferences),
          SummaryRow,
          PrefetchHooks Function({bool jobId, bool takeawaysRefs})
        > {
  $$SummariesTableTableManager(_$AppDatabase db, $SummariesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SummariesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SummariesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SummariesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> jobId = const Value.absent(),
                Value<String> summaryText = const Value.absent(),
                Value<String> toneAndFormat = const Value.absent(),
                Value<String> modelName = const Value.absent(),
                Value<String> promptVersion = const Value.absent(),
                Value<int?> tokensIn = const Value.absent(),
                Value<int?> tokensOut = const Value.absent(),
              }) => SummariesCompanion(
                id: id,
                jobId: jobId,
                summaryText: summaryText,
                toneAndFormat: toneAndFormat,
                modelName: modelName,
                promptVersion: promptVersion,
                tokensIn: tokensIn,
                tokensOut: tokensOut,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String jobId,
                required String summaryText,
                required String toneAndFormat,
                required String modelName,
                required String promptVersion,
                Value<int?> tokensIn = const Value.absent(),
                Value<int?> tokensOut = const Value.absent(),
              }) => SummariesCompanion.insert(
                id: id,
                jobId: jobId,
                summaryText: summaryText,
                toneAndFormat: toneAndFormat,
                modelName: modelName,
                promptVersion: promptVersion,
                tokensIn: tokensIn,
                tokensOut: tokensOut,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SummariesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({jobId = false, takeawaysRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (takeawaysRefs) db.takeaways],
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
                                referencedTable: $$SummariesTableReferences
                                    ._jobIdTable(db),
                                referencedColumn: $$SummariesTableReferences
                                    ._jobIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (takeawaysRefs)
                    await $_getPrefetchedData<
                      SummaryRow,
                      $SummariesTable,
                      TakeawayRow
                    >(
                      currentTable: table,
                      referencedTable: $$SummariesTableReferences
                          ._takeawaysRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$SummariesTableReferences(
                            db,
                            table,
                            p0,
                          ).takeawaysRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.summaryId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SummariesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SummariesTable,
      SummaryRow,
      $$SummariesTableFilterComposer,
      $$SummariesTableOrderingComposer,
      $$SummariesTableAnnotationComposer,
      $$SummariesTableCreateCompanionBuilder,
      $$SummariesTableUpdateCompanionBuilder,
      (SummaryRow, $$SummariesTableReferences),
      SummaryRow,
      PrefetchHooks Function({bool jobId, bool takeawaysRefs})
    >;
typedef $$TakeawaysTableCreateCompanionBuilder =
    TakeawaysCompanion Function({
      Value<int> id,
      required int summaryId,
      required String content,
      required int sortOrder,
    });
typedef $$TakeawaysTableUpdateCompanionBuilder =
    TakeawaysCompanion Function({
      Value<int> id,
      Value<int> summaryId,
      Value<String> content,
      Value<int> sortOrder,
    });

final class $$TakeawaysTableReferences
    extends BaseReferences<_$AppDatabase, $TakeawaysTable, TakeawayRow> {
  $$TakeawaysTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SummariesTable _summaryIdTable(_$AppDatabase db) =>
      db.summaries.createAlias('takeaways__summary_id__summaries__id');

  $$SummariesTableProcessedTableManager get summaryId {
    final $_column = $_itemColumn<int>('summary_id')!;

    final manager = $$SummariesTableTableManager(
      $_db,
      $_db.summaries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_summaryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TakeawaysTableFilterComposer
    extends Composer<_$AppDatabase, $TakeawaysTable> {
  $$TakeawaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$SummariesTableFilterComposer get summaryId {
    final $$SummariesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.summaryId,
      referencedTable: $db.summaries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SummariesTableFilterComposer(
            $db: $db,
            $table: $db.summaries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TakeawaysTableOrderingComposer
    extends Composer<_$AppDatabase, $TakeawaysTable> {
  $$TakeawaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$SummariesTableOrderingComposer get summaryId {
    final $$SummariesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.summaryId,
      referencedTable: $db.summaries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SummariesTableOrderingComposer(
            $db: $db,
            $table: $db.summaries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TakeawaysTableAnnotationComposer
    extends Composer<_$AppDatabase, $TakeawaysTable> {
  $$TakeawaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$SummariesTableAnnotationComposer get summaryId {
    final $$SummariesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.summaryId,
      referencedTable: $db.summaries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SummariesTableAnnotationComposer(
            $db: $db,
            $table: $db.summaries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TakeawaysTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TakeawaysTable,
          TakeawayRow,
          $$TakeawaysTableFilterComposer,
          $$TakeawaysTableOrderingComposer,
          $$TakeawaysTableAnnotationComposer,
          $$TakeawaysTableCreateCompanionBuilder,
          $$TakeawaysTableUpdateCompanionBuilder,
          (TakeawayRow, $$TakeawaysTableReferences),
          TakeawayRow,
          PrefetchHooks Function({bool summaryId})
        > {
  $$TakeawaysTableTableManager(_$AppDatabase db, $TakeawaysTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TakeawaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TakeawaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TakeawaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> summaryId = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => TakeawaysCompanion(
                id: id,
                summaryId: summaryId,
                content: content,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int summaryId,
                required String content,
                required int sortOrder,
              }) => TakeawaysCompanion.insert(
                id: id,
                summaryId: summaryId,
                content: content,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TakeawaysTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({summaryId = false}) {
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
                    if (summaryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.summaryId,
                                referencedTable: $$TakeawaysTableReferences
                                    ._summaryIdTable(db),
                                referencedColumn: $$TakeawaysTableReferences
                                    ._summaryIdTable(db)
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

typedef $$TakeawaysTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TakeawaysTable,
      TakeawayRow,
      $$TakeawaysTableFilterComposer,
      $$TakeawaysTableOrderingComposer,
      $$TakeawaysTableAnnotationComposer,
      $$TakeawaysTableCreateCompanionBuilder,
      $$TakeawaysTableUpdateCompanionBuilder,
      (TakeawayRow, $$TakeawaysTableReferences),
      TakeawayRow,
      PrefetchHooks Function({bool summaryId})
    >;
typedef $$InstalledModelsTableCreateCompanionBuilder =
    InstalledModelsCompanion Function({
      required String modelId,
      required String kind,
      required String tier,
      required String filePath,
      required DateTime downloadedAt,
      required int sizeBytes,
      required String checksum,
      Value<int> rowid,
    });
typedef $$InstalledModelsTableUpdateCompanionBuilder =
    InstalledModelsCompanion Function({
      Value<String> modelId,
      Value<String> kind,
      Value<String> tier,
      Value<String> filePath,
      Value<DateTime> downloadedAt,
      Value<int> sizeBytes,
      Value<String> checksum,
      Value<int> rowid,
    });

class $$InstalledModelsTableFilterComposer
    extends Composer<_$AppDatabase, $InstalledModelsTable> {
  $$InstalledModelsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get modelId => $composableBuilder(
    column: $table.modelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tier => $composableBuilder(
    column: $table.tier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get checksum => $composableBuilder(
    column: $table.checksum,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InstalledModelsTableOrderingComposer
    extends Composer<_$AppDatabase, $InstalledModelsTable> {
  $$InstalledModelsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get modelId => $composableBuilder(
    column: $table.modelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tier => $composableBuilder(
    column: $table.tier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get checksum => $composableBuilder(
    column: $table.checksum,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InstalledModelsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InstalledModelsTable> {
  $$InstalledModelsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get modelId =>
      $composableBuilder(column: $table.modelId, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get tier =>
      $composableBuilder(column: $table.tier, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<String> get checksum =>
      $composableBuilder(column: $table.checksum, builder: (column) => column);
}

class $$InstalledModelsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InstalledModelsTable,
          InstalledModelRow,
          $$InstalledModelsTableFilterComposer,
          $$InstalledModelsTableOrderingComposer,
          $$InstalledModelsTableAnnotationComposer,
          $$InstalledModelsTableCreateCompanionBuilder,
          $$InstalledModelsTableUpdateCompanionBuilder,
          (
            InstalledModelRow,
            BaseReferences<
              _$AppDatabase,
              $InstalledModelsTable,
              InstalledModelRow
            >,
          ),
          InstalledModelRow,
          PrefetchHooks Function()
        > {
  $$InstalledModelsTableTableManager(
    _$AppDatabase db,
    $InstalledModelsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InstalledModelsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InstalledModelsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InstalledModelsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> modelId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> tier = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<DateTime> downloadedAt = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<String> checksum = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InstalledModelsCompanion(
                modelId: modelId,
                kind: kind,
                tier: tier,
                filePath: filePath,
                downloadedAt: downloadedAt,
                sizeBytes: sizeBytes,
                checksum: checksum,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String modelId,
                required String kind,
                required String tier,
                required String filePath,
                required DateTime downloadedAt,
                required int sizeBytes,
                required String checksum,
                Value<int> rowid = const Value.absent(),
              }) => InstalledModelsCompanion.insert(
                modelId: modelId,
                kind: kind,
                tier: tier,
                filePath: filePath,
                downloadedAt: downloadedAt,
                sizeBytes: sizeBytes,
                checksum: checksum,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InstalledModelsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InstalledModelsTable,
      InstalledModelRow,
      $$InstalledModelsTableFilterComposer,
      $$InstalledModelsTableOrderingComposer,
      $$InstalledModelsTableAnnotationComposer,
      $$InstalledModelsTableCreateCompanionBuilder,
      $$InstalledModelsTableUpdateCompanionBuilder,
      (
        InstalledModelRow,
        BaseReferences<_$AppDatabase, $InstalledModelsTable, InstalledModelRow>,
      ),
      InstalledModelRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$JobsTableTableManager get jobs => $$JobsTableTableManager(_db, _db.jobs);
  $$TranscriptsTableTableManager get transcripts =>
      $$TranscriptsTableTableManager(_db, _db.transcripts);
  $$SummariesTableTableManager get summaries =>
      $$SummariesTableTableManager(_db, _db.summaries);
  $$TakeawaysTableTableManager get takeaways =>
      $$TakeawaysTableTableManager(_db, _db.takeaways);
  $$InstalledModelsTableTableManager get installedModels =>
      $$InstalledModelsTableTableManager(_db, _db.installedModels);
}
