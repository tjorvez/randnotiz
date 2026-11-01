// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class NotesFts extends Table
    with TableInfo<NotesFts, NotesFt>, VirtualTableInfo<NotesFts, NotesFt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  NotesFts(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  static const VerificationMeta _placeMeta = const VerificationMeta('place');
  late final GeneratedColumn<String> place = GeneratedColumn<String>(
    'place',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  static const VerificationMeta _countryMeta = const VerificationMeta(
    'country',
  );
  late final GeneratedColumn<String> country = GeneratedColumn<String>(
    'country',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  static const VerificationMeta _songMeta = const VerificationMeta('song');
  late final GeneratedColumn<String> song = GeneratedColumn<String>(
    'song',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    body,
    tags,
    place,
    title,
    country,
    song,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notes_fts';
  @override
  VerificationContext validateIntegrity(
    Insertable<NotesFt> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    } else if (isInserting) {
      context.missing(_tagsMeta);
    }
    if (data.containsKey('place')) {
      context.handle(
        _placeMeta,
        place.isAcceptableOrUnknown(data['place']!, _placeMeta),
      );
    } else if (isInserting) {
      context.missing(_placeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('country')) {
      context.handle(
        _countryMeta,
        country.isAcceptableOrUnknown(data['country']!, _countryMeta),
      );
    } else if (isInserting) {
      context.missing(_countryMeta);
    }
    if (data.containsKey('song')) {
      context.handle(
        _songMeta,
        song.isAcceptableOrUnknown(data['song']!, _songMeta),
      );
    } else if (isInserting) {
      context.missing(_songMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  NotesFt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NotesFt(
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      )!,
      place: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}place'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      country: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country'],
      )!,
      song: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}song'],
      )!,
    );
  }

  @override
  NotesFts createAlias(String alias) {
    return NotesFts(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
  @override
  String get moduleAndArgs =>
      'fts5(body, tags, place, title, country, song, tokenize = \'unicode61 remove_diacritics 2\')';
}

class NotesFt extends DataClass implements Insertable<NotesFt> {
  final String body;
  final String tags;
  final String place;
  final String title;
  final String country;
  final String song;
  const NotesFt({
    required this.body,
    required this.tags,
    required this.place,
    required this.title,
    required this.country,
    required this.song,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['body'] = Variable<String>(body);
    map['tags'] = Variable<String>(tags);
    map['place'] = Variable<String>(place);
    map['title'] = Variable<String>(title);
    map['country'] = Variable<String>(country);
    map['song'] = Variable<String>(song);
    return map;
  }

  NotesFtsCompanion toCompanion(bool nullToAbsent) {
    return NotesFtsCompanion(
      body: Value(body),
      tags: Value(tags),
      place: Value(place),
      title: Value(title),
      country: Value(country),
      song: Value(song),
    );
  }

  factory NotesFt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NotesFt(
      body: serializer.fromJson<String>(json['body']),
      tags: serializer.fromJson<String>(json['tags']),
      place: serializer.fromJson<String>(json['place']),
      title: serializer.fromJson<String>(json['title']),
      country: serializer.fromJson<String>(json['country']),
      song: serializer.fromJson<String>(json['song']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'body': serializer.toJson<String>(body),
      'tags': serializer.toJson<String>(tags),
      'place': serializer.toJson<String>(place),
      'title': serializer.toJson<String>(title),
      'country': serializer.toJson<String>(country),
      'song': serializer.toJson<String>(song),
    };
  }

  NotesFt copyWith({
    String? body,
    String? tags,
    String? place,
    String? title,
    String? country,
    String? song,
  }) => NotesFt(
    body: body ?? this.body,
    tags: tags ?? this.tags,
    place: place ?? this.place,
    title: title ?? this.title,
    country: country ?? this.country,
    song: song ?? this.song,
  );
  NotesFt copyWithCompanion(NotesFtsCompanion data) {
    return NotesFt(
      body: data.body.present ? data.body.value : this.body,
      tags: data.tags.present ? data.tags.value : this.tags,
      place: data.place.present ? data.place.value : this.place,
      title: data.title.present ? data.title.value : this.title,
      country: data.country.present ? data.country.value : this.country,
      song: data.song.present ? data.song.value : this.song,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotesFt(')
          ..write('body: $body, ')
          ..write('tags: $tags, ')
          ..write('place: $place, ')
          ..write('title: $title, ')
          ..write('country: $country, ')
          ..write('song: $song')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(body, tags, place, title, country, song);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotesFt &&
          other.body == this.body &&
          other.tags == this.tags &&
          other.place == this.place &&
          other.title == this.title &&
          other.country == this.country &&
          other.song == this.song);
}

class NotesFtsCompanion extends UpdateCompanion<NotesFt> {
  final Value<String> body;
  final Value<String> tags;
  final Value<String> place;
  final Value<String> title;
  final Value<String> country;
  final Value<String> song;
  final Value<int> rowid;
  const NotesFtsCompanion({
    this.body = const Value.absent(),
    this.tags = const Value.absent(),
    this.place = const Value.absent(),
    this.title = const Value.absent(),
    this.country = const Value.absent(),
    this.song = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotesFtsCompanion.insert({
    required String body,
    required String tags,
    required String place,
    required String title,
    required String country,
    required String song,
    this.rowid = const Value.absent(),
  }) : body = Value(body),
       tags = Value(tags),
       place = Value(place),
       title = Value(title),
       country = Value(country),
       song = Value(song);
  static Insertable<NotesFt> custom({
    Expression<String>? body,
    Expression<String>? tags,
    Expression<String>? place,
    Expression<String>? title,
    Expression<String>? country,
    Expression<String>? song,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (body != null) 'body': body,
      if (tags != null) 'tags': tags,
      if (place != null) 'place': place,
      if (title != null) 'title': title,
      if (country != null) 'country': country,
      if (song != null) 'song': song,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotesFtsCompanion copyWith({
    Value<String>? body,
    Value<String>? tags,
    Value<String>? place,
    Value<String>? title,
    Value<String>? country,
    Value<String>? song,
    Value<int>? rowid,
  }) {
    return NotesFtsCompanion(
      body: body ?? this.body,
      tags: tags ?? this.tags,
      place: place ?? this.place,
      title: title ?? this.title,
      country: country ?? this.country,
      song: song ?? this.song,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (place.present) {
      map['place'] = Variable<String>(place.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (country.present) {
      map['country'] = Variable<String>(country.value);
    }
    if (song.present) {
      map['song'] = Variable<String>(song.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotesFtsCompanion(')
          ..write('body: $body, ')
          ..write('tags: $tags, ')
          ..write('place: $place, ')
          ..write('title: $title, ')
          ..write('country: $country, ')
          ..write('song: $song, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotesTable extends Notes with TableInfo<$NotesTable, NoteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _uidMeta = const VerificationMeta('uid');
  @override
  late final GeneratedColumn<String> uid = GeneratedColumn<String>(
    'uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
    clientDefault: newUid,
  );
  static const VerificationMeta _assetIdMeta = const VerificationMeta(
    'assetId',
  );
  @override
  late final GeneratedColumn<String> assetId = GeneratedColumn<String>(
    'asset_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoAspectMeta = const VerificationMeta(
    'photoAspect',
  );
  @override
  late final GeneratedColumn<double> photoAspect = GeneratedColumn<double>(
    'photo_aspect',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteDateMeta = const VerificationMeta(
    'noteDate',
  );
  @override
  late final GeneratedColumn<DateTime> noteDate = GeneratedColumn<DateTime>(
    'note_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weatherKindMeta = const VerificationMeta(
    'weatherKind',
  );
  @override
  late final GeneratedColumn<String> weatherKind = GeneratedColumn<String>(
    'weather_kind',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _temperatureCMeta = const VerificationMeta(
    'temperatureC',
  );
  @override
  late final GeneratedColumn<double> temperatureC = GeneratedColumn<double>(
    'temperature_c',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _placeNameMeta = const VerificationMeta(
    'placeName',
  );
  @override
  late final GeneratedColumn<String> placeName = GeneratedColumn<String>(
    'place_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _placeNameAltMeta = const VerificationMeta(
    'placeNameAlt',
  );
  @override
  late final GeneratedColumn<String> placeNameAlt = GeneratedColumn<String>(
    'place_name_alt',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _countryCodeMeta = const VerificationMeta(
    'countryCode',
  );
  @override
  late final GeneratedColumn<String> countryCode = GeneratedColumn<String>(
    'country_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _geoCheckedMeta = const VerificationMeta(
    'geoChecked',
  );
  @override
  late final GeneratedColumn<bool> geoChecked = GeneratedColumn<bool>(
    'geo_checked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("geo_checked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _thumbnailFileMeta = const VerificationMeta(
    'thumbnailFile',
  );
  @override
  late final GeneratedColumn<String> thumbnailFile = GeneratedColumn<String>(
    'thumbnail_file',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _songUriMeta = const VerificationMeta(
    'songUri',
  );
  @override
  late final GeneratedColumn<String> songUri = GeneratedColumn<String>(
    'song_uri',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _songTitleMeta = const VerificationMeta(
    'songTitle',
  );
  @override
  late final GeneratedColumn<String> songTitle = GeneratedColumn<String>(
    'song_title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _songArtistMeta = const VerificationMeta(
    'songArtist',
  );
  @override
  late final GeneratedColumn<String> songArtist = GeneratedColumn<String>(
    'song_artist',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _songCoverFileMeta = const VerificationMeta(
    'songCoverFile',
  );
  @override
  late final GeneratedColumn<String> songCoverFile = GeneratedColumn<String>(
    'song_cover_file',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    uid,
    assetId,
    body,
    title,
    photoAspect,
    noteDate,
    weatherKind,
    temperatureC,
    placeName,
    placeNameAlt,
    countryCode,
    geoChecked,
    thumbnailFile,
    songUri,
    songTitle,
    songArtist,
    songCoverFile,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<NoteRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uid')) {
      context.handle(
        _uidMeta,
        uid.isAcceptableOrUnknown(data['uid']!, _uidMeta),
      );
    }
    if (data.containsKey('asset_id')) {
      context.handle(
        _assetIdMeta,
        assetId.isAcceptableOrUnknown(data['asset_id']!, _assetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_assetIdMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('photo_aspect')) {
      context.handle(
        _photoAspectMeta,
        photoAspect.isAcceptableOrUnknown(
          data['photo_aspect']!,
          _photoAspectMeta,
        ),
      );
    }
    if (data.containsKey('note_date')) {
      context.handle(
        _noteDateMeta,
        noteDate.isAcceptableOrUnknown(data['note_date']!, _noteDateMeta),
      );
    } else if (isInserting) {
      context.missing(_noteDateMeta);
    }
    if (data.containsKey('weather_kind')) {
      context.handle(
        _weatherKindMeta,
        weatherKind.isAcceptableOrUnknown(
          data['weather_kind']!,
          _weatherKindMeta,
        ),
      );
    }
    if (data.containsKey('temperature_c')) {
      context.handle(
        _temperatureCMeta,
        temperatureC.isAcceptableOrUnknown(
          data['temperature_c']!,
          _temperatureCMeta,
        ),
      );
    }
    if (data.containsKey('place_name')) {
      context.handle(
        _placeNameMeta,
        placeName.isAcceptableOrUnknown(data['place_name']!, _placeNameMeta),
      );
    }
    if (data.containsKey('place_name_alt')) {
      context.handle(
        _placeNameAltMeta,
        placeNameAlt.isAcceptableOrUnknown(
          data['place_name_alt']!,
          _placeNameAltMeta,
        ),
      );
    }
    if (data.containsKey('country_code')) {
      context.handle(
        _countryCodeMeta,
        countryCode.isAcceptableOrUnknown(
          data['country_code']!,
          _countryCodeMeta,
        ),
      );
    }
    if (data.containsKey('geo_checked')) {
      context.handle(
        _geoCheckedMeta,
        geoChecked.isAcceptableOrUnknown(data['geo_checked']!, _geoCheckedMeta),
      );
    }
    if (data.containsKey('thumbnail_file')) {
      context.handle(
        _thumbnailFileMeta,
        thumbnailFile.isAcceptableOrUnknown(
          data['thumbnail_file']!,
          _thumbnailFileMeta,
        ),
      );
    }
    if (data.containsKey('song_uri')) {
      context.handle(
        _songUriMeta,
        songUri.isAcceptableOrUnknown(data['song_uri']!, _songUriMeta),
      );
    }
    if (data.containsKey('song_title')) {
      context.handle(
        _songTitleMeta,
        songTitle.isAcceptableOrUnknown(data['song_title']!, _songTitleMeta),
      );
    }
    if (data.containsKey('song_artist')) {
      context.handle(
        _songArtistMeta,
        songArtist.isAcceptableOrUnknown(data['song_artist']!, _songArtistMeta),
      );
    }
    if (data.containsKey('song_cover_file')) {
      context.handle(
        _songCoverFileMeta,
        songCoverFile.isAcceptableOrUnknown(
          data['song_cover_file']!,
          _songCoverFileMeta,
        ),
      );
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NoteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NoteRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      uid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uid'],
      )!,
      assetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}asset_id'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      photoAspect: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}photo_aspect'],
      ),
      noteDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}note_date'],
      )!,
      weatherKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}weather_kind'],
      ),
      temperatureC: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}temperature_c'],
      ),
      placeName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}place_name'],
      ),
      placeNameAlt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}place_name_alt'],
      ),
      countryCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country_code'],
      ),
      geoChecked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}geo_checked'],
      )!,
      thumbnailFile: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_file'],
      ),
      songUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}song_uri'],
      ),
      songTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}song_title'],
      ),
      songArtist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}song_artist'],
      ),
      songCoverFile: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}song_cover_file'],
      ),
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
  $NotesTable createAlias(String alias) {
    return $NotesTable(attachedDatabase, alias);
  }
}

class NoteRow extends DataClass implements Insertable<NoteRow> {
  final int id;

  /// Stable id across devices (schema v10), see [newUid].
  final String uid;

  /// MediaStore asset id of the photo (photo_manager `AssetEntity.id`).
  final String assetId;
  final String body;

  /// Optional title (schema v6), handwritten on the polaroid's rim.
  final String? title;

  /// Width / height of the photo as shown (EXIF orientation applied),
  /// schema v6. Lets every polaroid of the note have exactly the same
  /// proportions, so the photo can fly between them without distortion.
  /// Null if unknown (treated as square).
  final double? photoAspect;

  /// The date shown in the note header. Initialised with the capture date of
  /// the photo, editable by the user. Used for grouping and memories.
  final DateTime noteDate;

  /// Name of a `WeatherKind` value, or null if no weather is known.
  final String? weatherKind;
  final double? temperatureC;

  /// Optional place (schema v4), e.g. "Hamburg": typed in, or the nearest
  /// town of the photo's GPS position (offline, schema v7). Only the name is
  /// stored, never coordinates.
  final String? placeName;

  /// The English/international name of [placeName] if it differs
  /// ("Munich" for "München", schema v7) – searchable as well.
  final String? placeNameAlt;

  /// ISO 3166-1 alpha-2 code of the country (schema v7), e.g. "NO".
  final String? countryCode;

  /// Country/place were looked up (or set by hand) – the one-time
  /// back-fill skips this note (schema v7).
  final bool geoChecked;

  /// File name (not path) of the downscaled JPEG copy inside the app's
  /// thumbnail directory. Keeps the entry alive if the original is deleted.
  final String? thumbnailFile;

  /// Optional song (schema v8): Spotify URI, title, artist (searchable)
  /// and the file name of the stored cover. All null without a song.
  final String? songUri;
  final String? songTitle;
  final String? songArtist;
  final String? songCoverFile;
  final DateTime createdAt;
  final DateTime updatedAt;
  const NoteRow({
    required this.id,
    required this.uid,
    required this.assetId,
    required this.body,
    this.title,
    this.photoAspect,
    required this.noteDate,
    this.weatherKind,
    this.temperatureC,
    this.placeName,
    this.placeNameAlt,
    this.countryCode,
    required this.geoChecked,
    this.thumbnailFile,
    this.songUri,
    this.songTitle,
    this.songArtist,
    this.songCoverFile,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uid'] = Variable<String>(uid);
    map['asset_id'] = Variable<String>(assetId);
    map['body'] = Variable<String>(body);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || photoAspect != null) {
      map['photo_aspect'] = Variable<double>(photoAspect);
    }
    map['note_date'] = Variable<DateTime>(noteDate);
    if (!nullToAbsent || weatherKind != null) {
      map['weather_kind'] = Variable<String>(weatherKind);
    }
    if (!nullToAbsent || temperatureC != null) {
      map['temperature_c'] = Variable<double>(temperatureC);
    }
    if (!nullToAbsent || placeName != null) {
      map['place_name'] = Variable<String>(placeName);
    }
    if (!nullToAbsent || placeNameAlt != null) {
      map['place_name_alt'] = Variable<String>(placeNameAlt);
    }
    if (!nullToAbsent || countryCode != null) {
      map['country_code'] = Variable<String>(countryCode);
    }
    map['geo_checked'] = Variable<bool>(geoChecked);
    if (!nullToAbsent || thumbnailFile != null) {
      map['thumbnail_file'] = Variable<String>(thumbnailFile);
    }
    if (!nullToAbsent || songUri != null) {
      map['song_uri'] = Variable<String>(songUri);
    }
    if (!nullToAbsent || songTitle != null) {
      map['song_title'] = Variable<String>(songTitle);
    }
    if (!nullToAbsent || songArtist != null) {
      map['song_artist'] = Variable<String>(songArtist);
    }
    if (!nullToAbsent || songCoverFile != null) {
      map['song_cover_file'] = Variable<String>(songCoverFile);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  NotesCompanion toCompanion(bool nullToAbsent) {
    return NotesCompanion(
      id: Value(id),
      uid: Value(uid),
      assetId: Value(assetId),
      body: Value(body),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      photoAspect: photoAspect == null && nullToAbsent
          ? const Value.absent()
          : Value(photoAspect),
      noteDate: Value(noteDate),
      weatherKind: weatherKind == null && nullToAbsent
          ? const Value.absent()
          : Value(weatherKind),
      temperatureC: temperatureC == null && nullToAbsent
          ? const Value.absent()
          : Value(temperatureC),
      placeName: placeName == null && nullToAbsent
          ? const Value.absent()
          : Value(placeName),
      placeNameAlt: placeNameAlt == null && nullToAbsent
          ? const Value.absent()
          : Value(placeNameAlt),
      countryCode: countryCode == null && nullToAbsent
          ? const Value.absent()
          : Value(countryCode),
      geoChecked: Value(geoChecked),
      thumbnailFile: thumbnailFile == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailFile),
      songUri: songUri == null && nullToAbsent
          ? const Value.absent()
          : Value(songUri),
      songTitle: songTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(songTitle),
      songArtist: songArtist == null && nullToAbsent
          ? const Value.absent()
          : Value(songArtist),
      songCoverFile: songCoverFile == null && nullToAbsent
          ? const Value.absent()
          : Value(songCoverFile),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory NoteRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NoteRow(
      id: serializer.fromJson<int>(json['id']),
      uid: serializer.fromJson<String>(json['uid']),
      assetId: serializer.fromJson<String>(json['assetId']),
      body: serializer.fromJson<String>(json['body']),
      title: serializer.fromJson<String?>(json['title']),
      photoAspect: serializer.fromJson<double?>(json['photoAspect']),
      noteDate: serializer.fromJson<DateTime>(json['noteDate']),
      weatherKind: serializer.fromJson<String?>(json['weatherKind']),
      temperatureC: serializer.fromJson<double?>(json['temperatureC']),
      placeName: serializer.fromJson<String?>(json['placeName']),
      placeNameAlt: serializer.fromJson<String?>(json['placeNameAlt']),
      countryCode: serializer.fromJson<String?>(json['countryCode']),
      geoChecked: serializer.fromJson<bool>(json['geoChecked']),
      thumbnailFile: serializer.fromJson<String?>(json['thumbnailFile']),
      songUri: serializer.fromJson<String?>(json['songUri']),
      songTitle: serializer.fromJson<String?>(json['songTitle']),
      songArtist: serializer.fromJson<String?>(json['songArtist']),
      songCoverFile: serializer.fromJson<String?>(json['songCoverFile']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uid': serializer.toJson<String>(uid),
      'assetId': serializer.toJson<String>(assetId),
      'body': serializer.toJson<String>(body),
      'title': serializer.toJson<String?>(title),
      'photoAspect': serializer.toJson<double?>(photoAspect),
      'noteDate': serializer.toJson<DateTime>(noteDate),
      'weatherKind': serializer.toJson<String?>(weatherKind),
      'temperatureC': serializer.toJson<double?>(temperatureC),
      'placeName': serializer.toJson<String?>(placeName),
      'placeNameAlt': serializer.toJson<String?>(placeNameAlt),
      'countryCode': serializer.toJson<String?>(countryCode),
      'geoChecked': serializer.toJson<bool>(geoChecked),
      'thumbnailFile': serializer.toJson<String?>(thumbnailFile),
      'songUri': serializer.toJson<String?>(songUri),
      'songTitle': serializer.toJson<String?>(songTitle),
      'songArtist': serializer.toJson<String?>(songArtist),
      'songCoverFile': serializer.toJson<String?>(songCoverFile),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  NoteRow copyWith({
    int? id,
    String? uid,
    String? assetId,
    String? body,
    Value<String?> title = const Value.absent(),
    Value<double?> photoAspect = const Value.absent(),
    DateTime? noteDate,
    Value<String?> weatherKind = const Value.absent(),
    Value<double?> temperatureC = const Value.absent(),
    Value<String?> placeName = const Value.absent(),
    Value<String?> placeNameAlt = const Value.absent(),
    Value<String?> countryCode = const Value.absent(),
    bool? geoChecked,
    Value<String?> thumbnailFile = const Value.absent(),
    Value<String?> songUri = const Value.absent(),
    Value<String?> songTitle = const Value.absent(),
    Value<String?> songArtist = const Value.absent(),
    Value<String?> songCoverFile = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => NoteRow(
    id: id ?? this.id,
    uid: uid ?? this.uid,
    assetId: assetId ?? this.assetId,
    body: body ?? this.body,
    title: title.present ? title.value : this.title,
    photoAspect: photoAspect.present ? photoAspect.value : this.photoAspect,
    noteDate: noteDate ?? this.noteDate,
    weatherKind: weatherKind.present ? weatherKind.value : this.weatherKind,
    temperatureC: temperatureC.present ? temperatureC.value : this.temperatureC,
    placeName: placeName.present ? placeName.value : this.placeName,
    placeNameAlt: placeNameAlt.present ? placeNameAlt.value : this.placeNameAlt,
    countryCode: countryCode.present ? countryCode.value : this.countryCode,
    geoChecked: geoChecked ?? this.geoChecked,
    thumbnailFile: thumbnailFile.present
        ? thumbnailFile.value
        : this.thumbnailFile,
    songUri: songUri.present ? songUri.value : this.songUri,
    songTitle: songTitle.present ? songTitle.value : this.songTitle,
    songArtist: songArtist.present ? songArtist.value : this.songArtist,
    songCoverFile: songCoverFile.present
        ? songCoverFile.value
        : this.songCoverFile,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  NoteRow copyWithCompanion(NotesCompanion data) {
    return NoteRow(
      id: data.id.present ? data.id.value : this.id,
      uid: data.uid.present ? data.uid.value : this.uid,
      assetId: data.assetId.present ? data.assetId.value : this.assetId,
      body: data.body.present ? data.body.value : this.body,
      title: data.title.present ? data.title.value : this.title,
      photoAspect: data.photoAspect.present
          ? data.photoAspect.value
          : this.photoAspect,
      noteDate: data.noteDate.present ? data.noteDate.value : this.noteDate,
      weatherKind: data.weatherKind.present
          ? data.weatherKind.value
          : this.weatherKind,
      temperatureC: data.temperatureC.present
          ? data.temperatureC.value
          : this.temperatureC,
      placeName: data.placeName.present ? data.placeName.value : this.placeName,
      placeNameAlt: data.placeNameAlt.present
          ? data.placeNameAlt.value
          : this.placeNameAlt,
      countryCode: data.countryCode.present
          ? data.countryCode.value
          : this.countryCode,
      geoChecked: data.geoChecked.present
          ? data.geoChecked.value
          : this.geoChecked,
      thumbnailFile: data.thumbnailFile.present
          ? data.thumbnailFile.value
          : this.thumbnailFile,
      songUri: data.songUri.present ? data.songUri.value : this.songUri,
      songTitle: data.songTitle.present ? data.songTitle.value : this.songTitle,
      songArtist: data.songArtist.present
          ? data.songArtist.value
          : this.songArtist,
      songCoverFile: data.songCoverFile.present
          ? data.songCoverFile.value
          : this.songCoverFile,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NoteRow(')
          ..write('id: $id, ')
          ..write('uid: $uid, ')
          ..write('assetId: $assetId, ')
          ..write('body: $body, ')
          ..write('title: $title, ')
          ..write('photoAspect: $photoAspect, ')
          ..write('noteDate: $noteDate, ')
          ..write('weatherKind: $weatherKind, ')
          ..write('temperatureC: $temperatureC, ')
          ..write('placeName: $placeName, ')
          ..write('placeNameAlt: $placeNameAlt, ')
          ..write('countryCode: $countryCode, ')
          ..write('geoChecked: $geoChecked, ')
          ..write('thumbnailFile: $thumbnailFile, ')
          ..write('songUri: $songUri, ')
          ..write('songTitle: $songTitle, ')
          ..write('songArtist: $songArtist, ')
          ..write('songCoverFile: $songCoverFile, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    uid,
    assetId,
    body,
    title,
    photoAspect,
    noteDate,
    weatherKind,
    temperatureC,
    placeName,
    placeNameAlt,
    countryCode,
    geoChecked,
    thumbnailFile,
    songUri,
    songTitle,
    songArtist,
    songCoverFile,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NoteRow &&
          other.id == this.id &&
          other.uid == this.uid &&
          other.assetId == this.assetId &&
          other.body == this.body &&
          other.title == this.title &&
          other.photoAspect == this.photoAspect &&
          other.noteDate == this.noteDate &&
          other.weatherKind == this.weatherKind &&
          other.temperatureC == this.temperatureC &&
          other.placeName == this.placeName &&
          other.placeNameAlt == this.placeNameAlt &&
          other.countryCode == this.countryCode &&
          other.geoChecked == this.geoChecked &&
          other.thumbnailFile == this.thumbnailFile &&
          other.songUri == this.songUri &&
          other.songTitle == this.songTitle &&
          other.songArtist == this.songArtist &&
          other.songCoverFile == this.songCoverFile &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class NotesCompanion extends UpdateCompanion<NoteRow> {
  final Value<int> id;
  final Value<String> uid;
  final Value<String> assetId;
  final Value<String> body;
  final Value<String?> title;
  final Value<double?> photoAspect;
  final Value<DateTime> noteDate;
  final Value<String?> weatherKind;
  final Value<double?> temperatureC;
  final Value<String?> placeName;
  final Value<String?> placeNameAlt;
  final Value<String?> countryCode;
  final Value<bool> geoChecked;
  final Value<String?> thumbnailFile;
  final Value<String?> songUri;
  final Value<String?> songTitle;
  final Value<String?> songArtist;
  final Value<String?> songCoverFile;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const NotesCompanion({
    this.id = const Value.absent(),
    this.uid = const Value.absent(),
    this.assetId = const Value.absent(),
    this.body = const Value.absent(),
    this.title = const Value.absent(),
    this.photoAspect = const Value.absent(),
    this.noteDate = const Value.absent(),
    this.weatherKind = const Value.absent(),
    this.temperatureC = const Value.absent(),
    this.placeName = const Value.absent(),
    this.placeNameAlt = const Value.absent(),
    this.countryCode = const Value.absent(),
    this.geoChecked = const Value.absent(),
    this.thumbnailFile = const Value.absent(),
    this.songUri = const Value.absent(),
    this.songTitle = const Value.absent(),
    this.songArtist = const Value.absent(),
    this.songCoverFile = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  NotesCompanion.insert({
    this.id = const Value.absent(),
    this.uid = const Value.absent(),
    required String assetId,
    this.body = const Value.absent(),
    this.title = const Value.absent(),
    this.photoAspect = const Value.absent(),
    required DateTime noteDate,
    this.weatherKind = const Value.absent(),
    this.temperatureC = const Value.absent(),
    this.placeName = const Value.absent(),
    this.placeNameAlt = const Value.absent(),
    this.countryCode = const Value.absent(),
    this.geoChecked = const Value.absent(),
    this.thumbnailFile = const Value.absent(),
    this.songUri = const Value.absent(),
    this.songTitle = const Value.absent(),
    this.songArtist = const Value.absent(),
    this.songCoverFile = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : assetId = Value(assetId),
       noteDate = Value(noteDate),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<NoteRow> custom({
    Expression<int>? id,
    Expression<String>? uid,
    Expression<String>? assetId,
    Expression<String>? body,
    Expression<String>? title,
    Expression<double>? photoAspect,
    Expression<DateTime>? noteDate,
    Expression<String>? weatherKind,
    Expression<double>? temperatureC,
    Expression<String>? placeName,
    Expression<String>? placeNameAlt,
    Expression<String>? countryCode,
    Expression<bool>? geoChecked,
    Expression<String>? thumbnailFile,
    Expression<String>? songUri,
    Expression<String>? songTitle,
    Expression<String>? songArtist,
    Expression<String>? songCoverFile,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uid != null) 'uid': uid,
      if (assetId != null) 'asset_id': assetId,
      if (body != null) 'body': body,
      if (title != null) 'title': title,
      if (photoAspect != null) 'photo_aspect': photoAspect,
      if (noteDate != null) 'note_date': noteDate,
      if (weatherKind != null) 'weather_kind': weatherKind,
      if (temperatureC != null) 'temperature_c': temperatureC,
      if (placeName != null) 'place_name': placeName,
      if (placeNameAlt != null) 'place_name_alt': placeNameAlt,
      if (countryCode != null) 'country_code': countryCode,
      if (geoChecked != null) 'geo_checked': geoChecked,
      if (thumbnailFile != null) 'thumbnail_file': thumbnailFile,
      if (songUri != null) 'song_uri': songUri,
      if (songTitle != null) 'song_title': songTitle,
      if (songArtist != null) 'song_artist': songArtist,
      if (songCoverFile != null) 'song_cover_file': songCoverFile,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  NotesCompanion copyWith({
    Value<int>? id,
    Value<String>? uid,
    Value<String>? assetId,
    Value<String>? body,
    Value<String?>? title,
    Value<double?>? photoAspect,
    Value<DateTime>? noteDate,
    Value<String?>? weatherKind,
    Value<double?>? temperatureC,
    Value<String?>? placeName,
    Value<String?>? placeNameAlt,
    Value<String?>? countryCode,
    Value<bool>? geoChecked,
    Value<String?>? thumbnailFile,
    Value<String?>? songUri,
    Value<String?>? songTitle,
    Value<String?>? songArtist,
    Value<String?>? songCoverFile,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return NotesCompanion(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      assetId: assetId ?? this.assetId,
      body: body ?? this.body,
      title: title ?? this.title,
      photoAspect: photoAspect ?? this.photoAspect,
      noteDate: noteDate ?? this.noteDate,
      weatherKind: weatherKind ?? this.weatherKind,
      temperatureC: temperatureC ?? this.temperatureC,
      placeName: placeName ?? this.placeName,
      placeNameAlt: placeNameAlt ?? this.placeNameAlt,
      countryCode: countryCode ?? this.countryCode,
      geoChecked: geoChecked ?? this.geoChecked,
      thumbnailFile: thumbnailFile ?? this.thumbnailFile,
      songUri: songUri ?? this.songUri,
      songTitle: songTitle ?? this.songTitle,
      songArtist: songArtist ?? this.songArtist,
      songCoverFile: songCoverFile ?? this.songCoverFile,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
    }
    if (assetId.present) {
      map['asset_id'] = Variable<String>(assetId.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (photoAspect.present) {
      map['photo_aspect'] = Variable<double>(photoAspect.value);
    }
    if (noteDate.present) {
      map['note_date'] = Variable<DateTime>(noteDate.value);
    }
    if (weatherKind.present) {
      map['weather_kind'] = Variable<String>(weatherKind.value);
    }
    if (temperatureC.present) {
      map['temperature_c'] = Variable<double>(temperatureC.value);
    }
    if (placeName.present) {
      map['place_name'] = Variable<String>(placeName.value);
    }
    if (placeNameAlt.present) {
      map['place_name_alt'] = Variable<String>(placeNameAlt.value);
    }
    if (countryCode.present) {
      map['country_code'] = Variable<String>(countryCode.value);
    }
    if (geoChecked.present) {
      map['geo_checked'] = Variable<bool>(geoChecked.value);
    }
    if (thumbnailFile.present) {
      map['thumbnail_file'] = Variable<String>(thumbnailFile.value);
    }
    if (songUri.present) {
      map['song_uri'] = Variable<String>(songUri.value);
    }
    if (songTitle.present) {
      map['song_title'] = Variable<String>(songTitle.value);
    }
    if (songArtist.present) {
      map['song_artist'] = Variable<String>(songArtist.value);
    }
    if (songCoverFile.present) {
      map['song_cover_file'] = Variable<String>(songCoverFile.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotesCompanion(')
          ..write('id: $id, ')
          ..write('uid: $uid, ')
          ..write('assetId: $assetId, ')
          ..write('body: $body, ')
          ..write('title: $title, ')
          ..write('photoAspect: $photoAspect, ')
          ..write('noteDate: $noteDate, ')
          ..write('weatherKind: $weatherKind, ')
          ..write('temperatureC: $temperatureC, ')
          ..write('placeName: $placeName, ')
          ..write('placeNameAlt: $placeNameAlt, ')
          ..write('countryCode: $countryCode, ')
          ..write('geoChecked: $geoChecked, ')
          ..write('thumbnailFile: $thumbnailFile, ')
          ..write('songUri: $songUri, ')
          ..write('songTitle: $songTitle, ')
          ..write('songArtist: $songArtist, ')
          ..write('songCoverFile: $songCoverFile, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, TagRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 40,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
    'emoji',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(defaultTagEmoji),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, emoji];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<TagRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('emoji')) {
      context.handle(
        _emojiMeta,
        emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TagRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TagRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      emoji: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emoji'],
      )!,
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class TagRow extends DataClass implements Insertable<TagRow> {
  final int id;
  final String name;

  /// One emoji (may consist of several code points). Added in schema v3,
  /// replacing the former colour.
  final String emoji;
  const TagRow({required this.id, required this.name, required this.emoji});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['emoji'] = Variable<String>(emoji);
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(id: Value(id), name: Value(name), emoji: Value(emoji));
  }

  factory TagRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TagRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      emoji: serializer.fromJson<String>(json['emoji']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'emoji': serializer.toJson<String>(emoji),
    };
  }

  TagRow copyWith({int? id, String? name, String? emoji}) => TagRow(
    id: id ?? this.id,
    name: name ?? this.name,
    emoji: emoji ?? this.emoji,
  );
  TagRow copyWithCompanion(TagsCompanion data) {
    return TagRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TagRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('emoji: $emoji')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, emoji);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TagRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.emoji == this.emoji);
}

class TagsCompanion extends UpdateCompanion<TagRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> emoji;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.emoji = const Value.absent(),
  });
  TagsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.emoji = const Value.absent(),
  }) : name = Value(name);
  static Insertable<TagRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? emoji,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (emoji != null) 'emoji': emoji,
    });
  }

  TagsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? emoji,
  }) {
    return TagsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('emoji: $emoji')
          ..write(')'))
        .toString();
  }
}

class $NoteTagsTable extends NoteTags
    with TableInfo<$NoteTagsTable, NoteTagRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NoteTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _noteIdMeta = const VerificationMeta('noteId');
  @override
  late final GeneratedColumn<int> noteId = GeneratedColumn<int>(
    'note_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES notes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<int> tagId = GeneratedColumn<int>(
    'tag_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tags (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [noteId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'note_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<NoteTagRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('note_id')) {
      context.handle(
        _noteIdMeta,
        noteId.isAcceptableOrUnknown(data['note_id']!, _noteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_noteIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {noteId, tagId};
  @override
  NoteTagRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NoteTagRow(
      noteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}note_id'],
      )!,
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tag_id'],
      )!,
    );
  }

  @override
  $NoteTagsTable createAlias(String alias) {
    return $NoteTagsTable(attachedDatabase, alias);
  }
}

class NoteTagRow extends DataClass implements Insertable<NoteTagRow> {
  final int noteId;
  final int tagId;
  const NoteTagRow({required this.noteId, required this.tagId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['note_id'] = Variable<int>(noteId);
    map['tag_id'] = Variable<int>(tagId);
    return map;
  }

  NoteTagsCompanion toCompanion(bool nullToAbsent) {
    return NoteTagsCompanion(noteId: Value(noteId), tagId: Value(tagId));
  }

  factory NoteTagRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NoteTagRow(
      noteId: serializer.fromJson<int>(json['noteId']),
      tagId: serializer.fromJson<int>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'noteId': serializer.toJson<int>(noteId),
      'tagId': serializer.toJson<int>(tagId),
    };
  }

  NoteTagRow copyWith({int? noteId, int? tagId}) =>
      NoteTagRow(noteId: noteId ?? this.noteId, tagId: tagId ?? this.tagId);
  NoteTagRow copyWithCompanion(NoteTagsCompanion data) {
    return NoteTagRow(
      noteId: data.noteId.present ? data.noteId.value : this.noteId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NoteTagRow(')
          ..write('noteId: $noteId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(noteId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NoteTagRow &&
          other.noteId == this.noteId &&
          other.tagId == this.tagId);
}

class NoteTagsCompanion extends UpdateCompanion<NoteTagRow> {
  final Value<int> noteId;
  final Value<int> tagId;
  final Value<int> rowid;
  const NoteTagsCompanion({
    this.noteId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NoteTagsCompanion.insert({
    required int noteId,
    required int tagId,
    this.rowid = const Value.absent(),
  }) : noteId = Value(noteId),
       tagId = Value(tagId);
  static Insertable<NoteTagRow> custom({
    Expression<int>? noteId,
    Expression<int>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (noteId != null) 'note_id': noteId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NoteTagsCompanion copyWith({
    Value<int>? noteId,
    Value<int>? tagId,
    Value<int>? rowid,
  }) {
    return NoteTagsCompanion(
      noteId: noteId ?? this.noteId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (noteId.present) {
      map['note_id'] = Variable<int>(noteId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<int>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NoteTagsCompanion(')
          ..write('noteId: $noteId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CollectionsTable extends Collections
    with TableInfo<$CollectionsTable, CollectionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CollectionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _uidMeta = const VerificationMeta('uid');
  @override
  late final GeneratedColumn<String> uid = GeneratedColumn<String>(
    'uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
    clientDefault: newUid,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
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
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, uid, name, createdAt, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'collections';
  @override
  VerificationContext validateIntegrity(
    Insertable<CollectionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uid')) {
      context.handle(
        _uidMeta,
        uid.isAcceptableOrUnknown(data['uid']!, _uidMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CollectionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CollectionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      uid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uid'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $CollectionsTable createAlias(String alias) {
    return $CollectionsTable(attachedDatabase, alias);
  }
}

class CollectionRow extends DataClass implements Insertable<CollectionRow> {
  final int id;

  /// Stable id across devices (schema v10), see [newUid].
  final String uid;
  final String name;
  final DateTime createdAt;

  /// Place in the overview (ascending), set by dragging. A new collection
  /// gets a position before all others, so it appears first.
  final int position;
  const CollectionRow({
    required this.id,
    required this.uid,
    required this.name,
    required this.createdAt,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uid'] = Variable<String>(uid);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['position'] = Variable<int>(position);
    return map;
  }

  CollectionsCompanion toCompanion(bool nullToAbsent) {
    return CollectionsCompanion(
      id: Value(id),
      uid: Value(uid),
      name: Value(name),
      createdAt: Value(createdAt),
      position: Value(position),
    );
  }

  factory CollectionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CollectionRow(
      id: serializer.fromJson<int>(json['id']),
      uid: serializer.fromJson<String>(json['uid']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uid': serializer.toJson<String>(uid),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'position': serializer.toJson<int>(position),
    };
  }

  CollectionRow copyWith({
    int? id,
    String? uid,
    String? name,
    DateTime? createdAt,
    int? position,
  }) => CollectionRow(
    id: id ?? this.id,
    uid: uid ?? this.uid,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
    position: position ?? this.position,
  );
  CollectionRow copyWithCompanion(CollectionsCompanion data) {
    return CollectionRow(
      id: data.id.present ? data.id.value : this.id,
      uid: data.uid.present ? data.uid.value : this.uid,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CollectionRow(')
          ..write('id: $id, ')
          ..write('uid: $uid, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, uid, name, createdAt, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CollectionRow &&
          other.id == this.id &&
          other.uid == this.uid &&
          other.name == this.name &&
          other.createdAt == this.createdAt &&
          other.position == this.position);
}

class CollectionsCompanion extends UpdateCompanion<CollectionRow> {
  final Value<int> id;
  final Value<String> uid;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<int> position;
  const CollectionsCompanion({
    this.id = const Value.absent(),
    this.uid = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.position = const Value.absent(),
  });
  CollectionsCompanion.insert({
    this.id = const Value.absent(),
    this.uid = const Value.absent(),
    required String name,
    required DateTime createdAt,
    this.position = const Value.absent(),
  }) : name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<CollectionRow> custom({
    Expression<int>? id,
    Expression<String>? uid,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<int>? position,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uid != null) 'uid': uid,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (position != null) 'position': position,
    });
  }

  CollectionsCompanion copyWith({
    Value<int>? id,
    Value<String>? uid,
    Value<String>? name,
    Value<DateTime>? createdAt,
    Value<int>? position,
  }) {
    return CollectionsCompanion(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      position: position ?? this.position,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollectionsCompanion(')
          ..write('id: $id, ')
          ..write('uid: $uid, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }
}

class $CollectionNotesTable extends CollectionNotes
    with TableInfo<$CollectionNotesTable, CollectionNoteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CollectionNotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _collectionIdMeta = const VerificationMeta(
    'collectionId',
  );
  @override
  late final GeneratedColumn<int> collectionId = GeneratedColumn<int>(
    'collection_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES collections (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _noteIdMeta = const VerificationMeta('noteId');
  @override
  late final GeneratedColumn<int> noteId = GeneratedColumn<int>(
    'note_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES notes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [collectionId, noteId, addedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'collection_notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<CollectionNoteRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('collection_id')) {
      context.handle(
        _collectionIdMeta,
        collectionId.isAcceptableOrUnknown(
          data['collection_id']!,
          _collectionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_collectionIdMeta);
    }
    if (data.containsKey('note_id')) {
      context.handle(
        _noteIdMeta,
        noteId.isAcceptableOrUnknown(data['note_id']!, _noteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_noteIdMeta);
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {collectionId, noteId};
  @override
  CollectionNoteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CollectionNoteRow(
      collectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}collection_id'],
      )!,
      noteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}note_id'],
      )!,
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
    );
  }

  @override
  $CollectionNotesTable createAlias(String alias) {
    return $CollectionNotesTable(attachedDatabase, alias);
  }
}

class CollectionNoteRow extends DataClass
    implements Insertable<CollectionNoteRow> {
  final int collectionId;
  final int noteId;
  final DateTime addedAt;
  const CollectionNoteRow({
    required this.collectionId,
    required this.noteId,
    required this.addedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['collection_id'] = Variable<int>(collectionId);
    map['note_id'] = Variable<int>(noteId);
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  CollectionNotesCompanion toCompanion(bool nullToAbsent) {
    return CollectionNotesCompanion(
      collectionId: Value(collectionId),
      noteId: Value(noteId),
      addedAt: Value(addedAt),
    );
  }

  factory CollectionNoteRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CollectionNoteRow(
      collectionId: serializer.fromJson<int>(json['collectionId']),
      noteId: serializer.fromJson<int>(json['noteId']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'collectionId': serializer.toJson<int>(collectionId),
      'noteId': serializer.toJson<int>(noteId),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  CollectionNoteRow copyWith({
    int? collectionId,
    int? noteId,
    DateTime? addedAt,
  }) => CollectionNoteRow(
    collectionId: collectionId ?? this.collectionId,
    noteId: noteId ?? this.noteId,
    addedAt: addedAt ?? this.addedAt,
  );
  CollectionNoteRow copyWithCompanion(CollectionNotesCompanion data) {
    return CollectionNoteRow(
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
      noteId: data.noteId.present ? data.noteId.value : this.noteId,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CollectionNoteRow(')
          ..write('collectionId: $collectionId, ')
          ..write('noteId: $noteId, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(collectionId, noteId, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CollectionNoteRow &&
          other.collectionId == this.collectionId &&
          other.noteId == this.noteId &&
          other.addedAt == this.addedAt);
}

class CollectionNotesCompanion extends UpdateCompanion<CollectionNoteRow> {
  final Value<int> collectionId;
  final Value<int> noteId;
  final Value<DateTime> addedAt;
  final Value<int> rowid;
  const CollectionNotesCompanion({
    this.collectionId = const Value.absent(),
    this.noteId = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CollectionNotesCompanion.insert({
    required int collectionId,
    required int noteId,
    required DateTime addedAt,
    this.rowid = const Value.absent(),
  }) : collectionId = Value(collectionId),
       noteId = Value(noteId),
       addedAt = Value(addedAt);
  static Insertable<CollectionNoteRow> custom({
    Expression<int>? collectionId,
    Expression<int>? noteId,
    Expression<DateTime>? addedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (collectionId != null) 'collection_id': collectionId,
      if (noteId != null) 'note_id': noteId,
      if (addedAt != null) 'added_at': addedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CollectionNotesCompanion copyWith({
    Value<int>? collectionId,
    Value<int>? noteId,
    Value<DateTime>? addedAt,
    Value<int>? rowid,
  }) {
    return CollectionNotesCompanion(
      collectionId: collectionId ?? this.collectionId,
      noteId: noteId ?? this.noteId,
      addedAt: addedAt ?? this.addedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (collectionId.present) {
      map['collection_id'] = Variable<int>(collectionId.value);
    }
    if (noteId.present) {
      map['note_id'] = Variable<int>(noteId.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollectionNotesCompanion(')
          ..write('collectionId: $collectionId, ')
          ..write('noteId: $noteId, ')
          ..write('addedAt: $addedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CountriesTable extends Countries
    with TableInfo<$CountriesTable, CountryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CountriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 2,
      maxTextLength: 2,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameDeMeta = const VerificationMeta('nameDe');
  @override
  late final GeneratedColumn<String> nameDe = GeneratedColumn<String>(
    'name_de',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameEnMeta = const VerificationMeta('nameEn');
  @override
  late final GeneratedColumn<String> nameEn = GeneratedColumn<String>(
    'name_en',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [code, nameDe, nameEn];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'countries';
  @override
  VerificationContext validateIntegrity(
    Insertable<CountryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name_de')) {
      context.handle(
        _nameDeMeta,
        nameDe.isAcceptableOrUnknown(data['name_de']!, _nameDeMeta),
      );
    } else if (isInserting) {
      context.missing(_nameDeMeta);
    }
    if (data.containsKey('name_en')) {
      context.handle(
        _nameEnMeta,
        nameEn.isAcceptableOrUnknown(data['name_en']!, _nameEnMeta),
      );
    } else if (isInserting) {
      context.missing(_nameEnMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {code};
  @override
  CountryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CountryRow(
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      nameDe: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_de'],
      )!,
      nameEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_en'],
      )!,
    );
  }

  @override
  $CountriesTable createAlias(String alias) {
    return $CountriesTable(attachedDatabase, alias);
  }
}

class CountryRow extends DataClass implements Insertable<CountryRow> {
  final String code;
  final String nameDe;
  final String nameEn;
  const CountryRow({
    required this.code,
    required this.nameDe,
    required this.nameEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['code'] = Variable<String>(code);
    map['name_de'] = Variable<String>(nameDe);
    map['name_en'] = Variable<String>(nameEn);
    return map;
  }

  CountriesCompanion toCompanion(bool nullToAbsent) {
    return CountriesCompanion(
      code: Value(code),
      nameDe: Value(nameDe),
      nameEn: Value(nameEn),
    );
  }

  factory CountryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CountryRow(
      code: serializer.fromJson<String>(json['code']),
      nameDe: serializer.fromJson<String>(json['nameDe']),
      nameEn: serializer.fromJson<String>(json['nameEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'code': serializer.toJson<String>(code),
      'nameDe': serializer.toJson<String>(nameDe),
      'nameEn': serializer.toJson<String>(nameEn),
    };
  }

  CountryRow copyWith({String? code, String? nameDe, String? nameEn}) =>
      CountryRow(
        code: code ?? this.code,
        nameDe: nameDe ?? this.nameDe,
        nameEn: nameEn ?? this.nameEn,
      );
  CountryRow copyWithCompanion(CountriesCompanion data) {
    return CountryRow(
      code: data.code.present ? data.code.value : this.code,
      nameDe: data.nameDe.present ? data.nameDe.value : this.nameDe,
      nameEn: data.nameEn.present ? data.nameEn.value : this.nameEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CountryRow(')
          ..write('code: $code, ')
          ..write('nameDe: $nameDe, ')
          ..write('nameEn: $nameEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(code, nameDe, nameEn);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CountryRow &&
          other.code == this.code &&
          other.nameDe == this.nameDe &&
          other.nameEn == this.nameEn);
}

class CountriesCompanion extends UpdateCompanion<CountryRow> {
  final Value<String> code;
  final Value<String> nameDe;
  final Value<String> nameEn;
  final Value<int> rowid;
  const CountriesCompanion({
    this.code = const Value.absent(),
    this.nameDe = const Value.absent(),
    this.nameEn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CountriesCompanion.insert({
    required String code,
    required String nameDe,
    required String nameEn,
    this.rowid = const Value.absent(),
  }) : code = Value(code),
       nameDe = Value(nameDe),
       nameEn = Value(nameEn);
  static Insertable<CountryRow> custom({
    Expression<String>? code,
    Expression<String>? nameDe,
    Expression<String>? nameEn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (code != null) 'code': code,
      if (nameDe != null) 'name_de': nameDe,
      if (nameEn != null) 'name_en': nameEn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CountriesCompanion copyWith({
    Value<String>? code,
    Value<String>? nameDe,
    Value<String>? nameEn,
    Value<int>? rowid,
  }) {
    return CountriesCompanion(
      code: code ?? this.code,
      nameDe: nameDe ?? this.nameDe,
      nameEn: nameEn ?? this.nameEn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (nameDe.present) {
      map['name_de'] = Variable<String>(nameDe.value);
    }
    if (nameEn.present) {
      map['name_en'] = Variable<String>(nameEn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CountriesCompanion(')
          ..write('code: $code, ')
          ..write('nameDe: $nameDe, ')
          ..write('nameEn: $nameEn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final NotesFts notesFts = NotesFts(this);
  late final $NotesTable notes = $NotesTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $NoteTagsTable noteTags = $NoteTagsTable(this);
  late final $CollectionsTable collections = $CollectionsTable(this);
  late final $CollectionNotesTable collectionNotes = $CollectionNotesTable(
    this,
  );
  late final $CountriesTable countries = $CountriesTable(this);
  late final Index notesNoteDateIdx = Index(
    'notes_note_date_idx',
    'CREATE INDEX notes_note_date_idx ON notes (note_date)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    notesFts,
    notes,
    tags,
    noteTags,
    collections,
    collectionNotes,
    countries,
    notesNoteDateIdx,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'notes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('note_tags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tags',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('note_tags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'collections',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('collection_notes', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'notes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('collection_notes', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $NotesFtsCreateCompanionBuilder = NotesFtsCompanion Function({
  required String body,
  required String tags,
  required String place,
  required String title,
  required String country,
  required String song,
  Value<int> rowid,
});
typedef $NotesFtsUpdateCompanionBuilder = NotesFtsCompanion Function({
  Value<String> body,
  Value<String> tags,
  Value<String> place,
  Value<String> title,
  Value<String> country,
  Value<String> song,
  Value<int> rowid,
});

class $NotesFtsFilterComposer extends Composer<_$AppDatabase, NotesFts> {
  $NotesFtsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get place => $composableBuilder(
    column: $table.place,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get song => $composableBuilder(
    column: $table.song,
    builder: (column) => ColumnFilters(column),
  );
}

class $NotesFtsOrderingComposer extends Composer<_$AppDatabase, NotesFts> {
  $NotesFtsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get place => $composableBuilder(
    column: $table.place,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get song => $composableBuilder(
    column: $table.song,
    builder: (column) => ColumnOrderings(column),
  );
}

class $NotesFtsAnnotationComposer extends Composer<_$AppDatabase, NotesFts> {
  $NotesFtsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<String> get place =>
      $composableBuilder(column: $table.place, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get country =>
      $composableBuilder(column: $table.country, builder: (column) => column);

  GeneratedColumn<String> get song =>
      $composableBuilder(column: $table.song, builder: (column) => column);
}

class $NotesFtsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          NotesFts,
          NotesFt,
          $NotesFtsFilterComposer,
          $NotesFtsOrderingComposer,
          $NotesFtsAnnotationComposer,
          $NotesFtsCreateCompanionBuilder,
          $NotesFtsUpdateCompanionBuilder,
          (NotesFt, BaseReferences<_$AppDatabase, NotesFts, NotesFt>),
          NotesFt,
          PrefetchHooks Function()
        > {
  $NotesFtsTableManager(_$AppDatabase db, NotesFts table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $NotesFtsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $NotesFtsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $NotesFtsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> body = const Value.absent(),
                Value<String> tags = const Value.absent(),
                Value<String> place = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> country = const Value.absent(),
                Value<String> song = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotesFtsCompanion(
                body: body,
                tags: tags,
                place: place,
                title: title,
                country: country,
                song: song,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String body,
                required String tags,
                required String place,
                required String title,
                required String country,
                required String song,
                Value<int> rowid = const Value.absent(),
              }) => NotesFtsCompanion.insert(
                body: body,
                tags: tags,
                place: place,
                title: title,
                country: country,
                song: song,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<NotesFts, NotesFt>(table),
                  BaseReferences<_$AppDatabase, NotesFts, NotesFt>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $NotesFtsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      NotesFts,
      NotesFt,
      $NotesFtsFilterComposer,
      $NotesFtsOrderingComposer,
      $NotesFtsAnnotationComposer,
      $NotesFtsCreateCompanionBuilder,
      $NotesFtsUpdateCompanionBuilder,
      (NotesFt, BaseReferences<_$AppDatabase, NotesFts, NotesFt>),
      NotesFt,
      PrefetchHooks Function()
    >;
typedef $$NotesTableCreateCompanionBuilder = NotesCompanion Function({
  Value<int> id,
  Value<String> uid,
  required String assetId,
  Value<String> body,
  Value<String?> title,
  Value<double?> photoAspect,
  required DateTime noteDate,
  Value<String?> weatherKind,
  Value<double?> temperatureC,
  Value<String?> placeName,
  Value<String?> placeNameAlt,
  Value<String?> countryCode,
  Value<bool> geoChecked,
  Value<String?> thumbnailFile,
  Value<String?> songUri,
  Value<String?> songTitle,
  Value<String?> songArtist,
  Value<String?> songCoverFile,
  required DateTime createdAt,
  required DateTime updatedAt,
});
typedef $$NotesTableUpdateCompanionBuilder = NotesCompanion Function({
  Value<int> id,
  Value<String> uid,
  Value<String> assetId,
  Value<String> body,
  Value<String?> title,
  Value<double?> photoAspect,
  Value<DateTime> noteDate,
  Value<String?> weatherKind,
  Value<double?> temperatureC,
  Value<String?> placeName,
  Value<String?> placeNameAlt,
  Value<String?> countryCode,
  Value<bool> geoChecked,
  Value<String?> thumbnailFile,
  Value<String?> songUri,
  Value<String?> songTitle,
  Value<String?> songArtist,
  Value<String?> songCoverFile,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

final class $$NotesTableReferences
    extends BaseReferences<_$AppDatabase, $NotesTable, NoteRow> {
  $$NotesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$NoteTagsTable, List<NoteTagRow>>
  _noteTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.noteTags,
    aliasName: 'notes__id__note_tags__note_id',
  );

  $$NoteTagsTableProcessedTableManager get noteTagsRefs {
    final manager = $$NoteTagsTableTableManager(
      $_db,
      $_db.noteTags,
    ).filter((f) => f.noteId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_noteTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CollectionNotesTable, List<CollectionNoteRow>>
  _collectionNotesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.collectionNotes,
    aliasName: 'notes__id__collection_notes__note_id',
  );

  $$CollectionNotesTableProcessedTableManager get collectionNotesRefs {
    final manager = $$CollectionNotesTableTableManager(
      $_db,
      $_db.collectionNotes,
    ).filter((f) => f.noteId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _collectionNotesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$NotesTableFilterComposer extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableFilterComposer({
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

  ColumnFilters<String> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assetId => $composableBuilder(
    column: $table.assetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get photoAspect => $composableBuilder(
    column: $table.photoAspect,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get noteDate => $composableBuilder(
    column: $table.noteDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weatherKind => $composableBuilder(
    column: $table.weatherKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get temperatureC => $composableBuilder(
    column: $table.temperatureC,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get placeName => $composableBuilder(
    column: $table.placeName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get placeNameAlt => $composableBuilder(
    column: $table.placeNameAlt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get countryCode => $composableBuilder(
    column: $table.countryCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get geoChecked => $composableBuilder(
    column: $table.geoChecked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailFile => $composableBuilder(
    column: $table.thumbnailFile,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get songUri => $composableBuilder(
    column: $table.songUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get songTitle => $composableBuilder(
    column: $table.songTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get songArtist => $composableBuilder(
    column: $table.songArtist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get songCoverFile => $composableBuilder(
    column: $table.songCoverFile,
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

  Expression<bool> noteTagsRefs(
    Expression<bool> Function($$NoteTagsTableFilterComposer f) f,
  ) {
    final $$NoteTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.noteTags,
      getReferencedColumn: (t) => t.noteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NoteTagsTableFilterComposer(
            $db: $db,
            $table: $db.noteTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> collectionNotesRefs(
    Expression<bool> Function($$CollectionNotesTableFilterComposer f) f,
  ) {
    final $$CollectionNotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.collectionNotes,
      getReferencedColumn: (t) => t.noteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionNotesTableFilterComposer(
            $db: $db,
            $table: $db.collectionNotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$NotesTableOrderingComposer
    extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableOrderingComposer({
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

  ColumnOrderings<String> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assetId => $composableBuilder(
    column: $table.assetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get photoAspect => $composableBuilder(
    column: $table.photoAspect,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get noteDate => $composableBuilder(
    column: $table.noteDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weatherKind => $composableBuilder(
    column: $table.weatherKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get temperatureC => $composableBuilder(
    column: $table.temperatureC,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get placeName => $composableBuilder(
    column: $table.placeName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get placeNameAlt => $composableBuilder(
    column: $table.placeNameAlt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get countryCode => $composableBuilder(
    column: $table.countryCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get geoChecked => $composableBuilder(
    column: $table.geoChecked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailFile => $composableBuilder(
    column: $table.thumbnailFile,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get songUri => $composableBuilder(
    column: $table.songUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get songTitle => $composableBuilder(
    column: $table.songTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get songArtist => $composableBuilder(
    column: $table.songArtist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get songCoverFile => $composableBuilder(
    column: $table.songCoverFile,
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

class $$NotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uid =>
      $composableBuilder(column: $table.uid, builder: (column) => column);

  GeneratedColumn<String> get assetId =>
      $composableBuilder(column: $table.assetId, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<double> get photoAspect => $composableBuilder(
    column: $table.photoAspect,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get noteDate =>
      $composableBuilder(column: $table.noteDate, builder: (column) => column);

  GeneratedColumn<String> get weatherKind => $composableBuilder(
    column: $table.weatherKind,
    builder: (column) => column,
  );

  GeneratedColumn<double> get temperatureC => $composableBuilder(
    column: $table.temperatureC,
    builder: (column) => column,
  );

  GeneratedColumn<String> get placeName =>
      $composableBuilder(column: $table.placeName, builder: (column) => column);

  GeneratedColumn<String> get placeNameAlt => $composableBuilder(
    column: $table.placeNameAlt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get countryCode => $composableBuilder(
    column: $table.countryCode,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get geoChecked => $composableBuilder(
    column: $table.geoChecked,
    builder: (column) => column,
  );

  GeneratedColumn<String> get thumbnailFile => $composableBuilder(
    column: $table.thumbnailFile,
    builder: (column) => column,
  );

  GeneratedColumn<String> get songUri =>
      $composableBuilder(column: $table.songUri, builder: (column) => column);

  GeneratedColumn<String> get songTitle =>
      $composableBuilder(column: $table.songTitle, builder: (column) => column);

  GeneratedColumn<String> get songArtist => $composableBuilder(
    column: $table.songArtist,
    builder: (column) => column,
  );

  GeneratedColumn<String> get songCoverFile => $composableBuilder(
    column: $table.songCoverFile,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> noteTagsRefs<T extends Object>(
    Expression<T> Function($$NoteTagsTableAnnotationComposer a) f,
  ) {
    final $$NoteTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.noteTags,
      getReferencedColumn: (t) => t.noteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NoteTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.noteTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> collectionNotesRefs<T extends Object>(
    Expression<T> Function($$CollectionNotesTableAnnotationComposer a) f,
  ) {
    final $$CollectionNotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.collectionNotes,
      getReferencedColumn: (t) => t.noteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionNotesTableAnnotationComposer(
            $db: $db,
            $table: $db.collectionNotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$NotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotesTable,
          NoteRow,
          $$NotesTableFilterComposer,
          $$NotesTableOrderingComposer,
          $$NotesTableAnnotationComposer,
          $$NotesTableCreateCompanionBuilder,
          $$NotesTableUpdateCompanionBuilder,
          (NoteRow, $$NotesTableReferences),
          NoteRow,
          PrefetchHooks Function({bool noteTagsRefs, bool collectionNotesRefs})
        > {
  $$NotesTableTableManager(_$AppDatabase db, $NotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uid = const Value.absent(),
                Value<String> assetId = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<double?> photoAspect = const Value.absent(),
                Value<DateTime> noteDate = const Value.absent(),
                Value<String?> weatherKind = const Value.absent(),
                Value<double?> temperatureC = const Value.absent(),
                Value<String?> placeName = const Value.absent(),
                Value<String?> placeNameAlt = const Value.absent(),
                Value<String?> countryCode = const Value.absent(),
                Value<bool> geoChecked = const Value.absent(),
                Value<String?> thumbnailFile = const Value.absent(),
                Value<String?> songUri = const Value.absent(),
                Value<String?> songTitle = const Value.absent(),
                Value<String?> songArtist = const Value.absent(),
                Value<String?> songCoverFile = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => NotesCompanion(
                id: id,
                uid: uid,
                assetId: assetId,
                body: body,
                title: title,
                photoAspect: photoAspect,
                noteDate: noteDate,
                weatherKind: weatherKind,
                temperatureC: temperatureC,
                placeName: placeName,
                placeNameAlt: placeNameAlt,
                countryCode: countryCode,
                geoChecked: geoChecked,
                thumbnailFile: thumbnailFile,
                songUri: songUri,
                songTitle: songTitle,
                songArtist: songArtist,
                songCoverFile: songCoverFile,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uid = const Value.absent(),
                required String assetId,
                Value<String> body = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<double?> photoAspect = const Value.absent(),
                required DateTime noteDate,
                Value<String?> weatherKind = const Value.absent(),
                Value<double?> temperatureC = const Value.absent(),
                Value<String?> placeName = const Value.absent(),
                Value<String?> placeNameAlt = const Value.absent(),
                Value<String?> countryCode = const Value.absent(),
                Value<bool> geoChecked = const Value.absent(),
                Value<String?> thumbnailFile = const Value.absent(),
                Value<String?> songUri = const Value.absent(),
                Value<String?> songTitle = const Value.absent(),
                Value<String?> songArtist = const Value.absent(),
                Value<String?> songCoverFile = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => NotesCompanion.insert(
                id: id,
                uid: uid,
                assetId: assetId,
                body: body,
                title: title,
                photoAspect: photoAspect,
                noteDate: noteDate,
                weatherKind: weatherKind,
                temperatureC: temperatureC,
                placeName: placeName,
                placeNameAlt: placeNameAlt,
                countryCode: countryCode,
                geoChecked: geoChecked,
                thumbnailFile: thumbnailFile,
                songUri: songUri,
                songTitle: songTitle,
                songArtist: songArtist,
                songCoverFile: songCoverFile,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NotesTable, NoteRow>(table),
                  $$NotesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({noteTagsRefs = false, collectionNotesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (noteTagsRefs) db.noteTags,
                    if (collectionNotesRefs) db.collectionNotes,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (noteTagsRefs)
                        await $_getPrefetchedDataByColumns<
                          NoteRow,
                          $NotesTable,
                          NoteTagRow,
                          $NoteTagsTable
                        >(
                          currentTable: table,
                          referencedTable: $$NotesTableReferences
                              ._noteTagsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$NotesTableReferences(
                                db,
                                table,
                                p0,
                              ).noteTagsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'note_id',
                          typedResults: items,
                        ),
                      if (collectionNotesRefs)
                        await $_getPrefetchedDataByColumns<
                          NoteRow,
                          $NotesTable,
                          CollectionNoteRow,
                          $CollectionNotesTable
                        >(
                          currentTable: table,
                          referencedTable: $$NotesTableReferences
                              ._collectionNotesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$NotesTableReferences(
                                db,
                                table,
                                p0,
                              ).collectionNotesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'note_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$NotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotesTable,
      NoteRow,
      $$NotesTableFilterComposer,
      $$NotesTableOrderingComposer,
      $$NotesTableAnnotationComposer,
      $$NotesTableCreateCompanionBuilder,
      $$NotesTableUpdateCompanionBuilder,
      (NoteRow, $$NotesTableReferences),
      NoteRow,
      PrefetchHooks Function({bool noteTagsRefs, bool collectionNotesRefs})
    >;
typedef $$TagsTableCreateCompanionBuilder = TagsCompanion Function({
  Value<int> id,
  required String name,
  Value<String> emoji,
});
typedef $$TagsTableUpdateCompanionBuilder = TagsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> emoji,
});

final class $$TagsTableReferences
    extends BaseReferences<_$AppDatabase, $TagsTable, TagRow> {
  $$TagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$NoteTagsTable, List<NoteTagRow>>
  _noteTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.noteTags,
    aliasName: 'tags__id__note_tags__tag_id',
  );

  $$NoteTagsTableProcessedTableManager get noteTagsRefs {
    final manager = $$NoteTagsTableTableManager(
      $_db,
      $_db.noteTags,
    ).filter((f) => f.tagId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_noteTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TagsTableFilterComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> noteTagsRefs(
    Expression<bool> Function($$NoteTagsTableFilterComposer f) f,
  ) {
    final $$NoteTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.noteTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NoteTagsTableFilterComposer(
            $db: $db,
            $table: $db.noteTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableOrderingComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => column);

  Expression<T> noteTagsRefs<T extends Object>(
    Expression<T> Function($$NoteTagsTableAnnotationComposer a) f,
  ) {
    final $$NoteTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.noteTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NoteTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.noteTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TagsTable,
          TagRow,
          $$TagsTableFilterComposer,
          $$TagsTableOrderingComposer,
          $$TagsTableAnnotationComposer,
          $$TagsTableCreateCompanionBuilder,
          $$TagsTableUpdateCompanionBuilder,
          (TagRow, $$TagsTableReferences),
          TagRow,
          PrefetchHooks Function({bool noteTagsRefs})
        > {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> emoji = const Value.absent(),
          }) => TagsCompanion(id: id, name: name, emoji: emoji),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String> emoji = const Value.absent(),
          }) => TagsCompanion.insert(id: id, name: name, emoji: emoji),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TagsTable, TagRow>(table),
                  $$TagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({noteTagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (noteTagsRefs) db.noteTags],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (noteTagsRefs)
                    await $_getPrefetchedDataByColumns<
                      TagRow,
                      $TagsTable,
                      NoteTagRow,
                      $NoteTagsTable
                    >(
                      currentTable: table,
                      referencedTable: $$TagsTableReferences._noteTagsRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$TagsTableReferences(db, table, p0).noteTagsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'tag_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TagsTable,
      TagRow,
      $$TagsTableFilterComposer,
      $$TagsTableOrderingComposer,
      $$TagsTableAnnotationComposer,
      $$TagsTableCreateCompanionBuilder,
      $$TagsTableUpdateCompanionBuilder,
      (TagRow, $$TagsTableReferences),
      TagRow,
      PrefetchHooks Function({bool noteTagsRefs})
    >;
typedef $$NoteTagsTableCreateCompanionBuilder = NoteTagsCompanion Function({
  required int noteId,
  required int tagId,
  Value<int> rowid,
});
typedef $$NoteTagsTableUpdateCompanionBuilder = NoteTagsCompanion Function({
  Value<int> noteId,
  Value<int> tagId,
  Value<int> rowid,
});

final class $$NoteTagsTableReferences
    extends BaseReferences<_$AppDatabase, $NoteTagsTable, NoteTagRow> {
  $$NoteTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $NotesTable _noteIdTable(_$AppDatabase db) =>
      db.notes.createAlias('note_tags__note_id__notes__id');

  $$NotesTableProcessedTableManager get noteId {
    final $_column = $_itemColumn<int>('note_id')!;

    final manager = $$NotesTableTableManager(
      $_db,
      $_db.notes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_noteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TagsTable _tagIdTable(_$AppDatabase db) =>
      db.tags.createAlias('note_tags__tag_id__tags__id');

  $$TagsTableProcessedTableManager get tagId {
    final $_column = $_itemColumn<int>('tag_id')!;

    final manager = $$TagsTableTableManager(
      $_db,
      $_db.tags,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$NoteTagsTableFilterComposer
    extends Composer<_$AppDatabase, $NoteTagsTable> {
  $$NoteTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$NotesTableFilterComposer get noteId {
    final $$NotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteId,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableFilterComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableFilterComposer get tagId {
    final $$TagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableFilterComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NoteTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $NoteTagsTable> {
  $$NoteTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$NotesTableOrderingComposer get noteId {
    final $$NotesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteId,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableOrderingComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableOrderingComposer get tagId {
    final $$TagsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableOrderingComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NoteTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NoteTagsTable> {
  $$NoteTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$NotesTableAnnotationComposer get noteId {
    final $$NotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteId,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableAnnotationComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableAnnotationComposer get tagId {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableAnnotationComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NoteTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NoteTagsTable,
          NoteTagRow,
          $$NoteTagsTableFilterComposer,
          $$NoteTagsTableOrderingComposer,
          $$NoteTagsTableAnnotationComposer,
          $$NoteTagsTableCreateCompanionBuilder,
          $$NoteTagsTableUpdateCompanionBuilder,
          (NoteTagRow, $$NoteTagsTableReferences),
          NoteTagRow,
          PrefetchHooks Function({bool noteId, bool tagId})
        > {
  $$NoteTagsTableTableManager(_$AppDatabase db, $NoteTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NoteTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NoteTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NoteTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> noteId = const Value.absent(),
            Value<int> tagId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => NoteTagsCompanion(noteId: noteId, tagId: tagId, rowid: rowid),
          createCompanionCallback:
              ({
                required int noteId,
                required int tagId,
                Value<int> rowid = const Value.absent(),
              }) => NoteTagsCompanion.insert(
                noteId: noteId,
                tagId: tagId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NoteTagsTable, NoteTagRow>(table),
                  $$NoteTagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({noteId = false, tagId = false}) {
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
                    if (noteId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.noteId,
                        referencedTable: $$NoteTagsTableReferences._noteIdTable(
                          db,
                        ),
                        referencedColumn: $$NoteTagsTableReferences
                            ._noteIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (tagId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.tagId,
                        referencedTable: $$NoteTagsTableReferences._tagIdTable(
                          db,
                        ),
                        referencedColumn: $$NoteTagsTableReferences
                            ._tagIdTable(db)
                            .id,
                      ) as T;
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

typedef $$NoteTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NoteTagsTable,
      NoteTagRow,
      $$NoteTagsTableFilterComposer,
      $$NoteTagsTableOrderingComposer,
      $$NoteTagsTableAnnotationComposer,
      $$NoteTagsTableCreateCompanionBuilder,
      $$NoteTagsTableUpdateCompanionBuilder,
      (NoteTagRow, $$NoteTagsTableReferences),
      NoteTagRow,
      PrefetchHooks Function({bool noteId, bool tagId})
    >;
typedef $$CollectionsTableCreateCompanionBuilder =
    CollectionsCompanion Function({
      Value<int> id,
      Value<String> uid,
      required String name,
      required DateTime createdAt,
      Value<int> position,
    });
typedef $$CollectionsTableUpdateCompanionBuilder =
    CollectionsCompanion Function({
      Value<int> id,
      Value<String> uid,
      Value<String> name,
      Value<DateTime> createdAt,
      Value<int> position,
    });

final class $$CollectionsTableReferences
    extends BaseReferences<_$AppDatabase, $CollectionsTable, CollectionRow> {
  $$CollectionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CollectionNotesTable, List<CollectionNoteRow>>
  _collectionNotesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.collectionNotes,
    aliasName: 'collections__id__collection_notes__collection_id',
  );

  $$CollectionNotesTableProcessedTableManager get collectionNotesRefs {
    final manager = $$CollectionNotesTableTableManager(
      $_db,
      $_db.collectionNotes,
    ).filter((f) => f.collectionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _collectionNotesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CollectionsTableFilterComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableFilterComposer({
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

  ColumnFilters<String> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> collectionNotesRefs(
    Expression<bool> Function($$CollectionNotesTableFilterComposer f) f,
  ) {
    final $$CollectionNotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.collectionNotes,
      getReferencedColumn: (t) => t.collectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionNotesTableFilterComposer(
            $db: $db,
            $table: $db.collectionNotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CollectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableOrderingComposer({
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

  ColumnOrderings<String> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CollectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uid =>
      $composableBuilder(column: $table.uid, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  Expression<T> collectionNotesRefs<T extends Object>(
    Expression<T> Function($$CollectionNotesTableAnnotationComposer a) f,
  ) {
    final $$CollectionNotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.collectionNotes,
      getReferencedColumn: (t) => t.collectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionNotesTableAnnotationComposer(
            $db: $db,
            $table: $db.collectionNotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CollectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CollectionsTable,
          CollectionRow,
          $$CollectionsTableFilterComposer,
          $$CollectionsTableOrderingComposer,
          $$CollectionsTableAnnotationComposer,
          $$CollectionsTableCreateCompanionBuilder,
          $$CollectionsTableUpdateCompanionBuilder,
          (CollectionRow, $$CollectionsTableReferences),
          CollectionRow,
          PrefetchHooks Function({bool collectionNotesRefs})
        > {
  $$CollectionsTableTableManager(_$AppDatabase db, $CollectionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CollectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CollectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CollectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uid = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> position = const Value.absent(),
              }) => CollectionsCompanion(
                id: id,
                uid: uid,
                name: name,
                createdAt: createdAt,
                position: position,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uid = const Value.absent(),
                required String name,
                required DateTime createdAt,
                Value<int> position = const Value.absent(),
              }) => CollectionsCompanion.insert(
                id: id,
                uid: uid,
                name: name,
                createdAt: createdAt,
                position: position,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CollectionsTable, CollectionRow>(table),
                  $$CollectionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({collectionNotesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (collectionNotesRefs) db.collectionNotes,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (collectionNotesRefs)
                    await $_getPrefetchedDataByColumns<
                      CollectionRow,
                      $CollectionsTable,
                      CollectionNoteRow,
                      $CollectionNotesTable
                    >(
                      currentTable: table,
                      referencedTable: $$CollectionsTableReferences
                          ._collectionNotesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CollectionsTableReferences(
                            db,
                            table,
                            p0,
                          ).collectionNotesRefs,
                      currentColumn: 'id',
                      referencedColumn: 'collection_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CollectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CollectionsTable,
      CollectionRow,
      $$CollectionsTableFilterComposer,
      $$CollectionsTableOrderingComposer,
      $$CollectionsTableAnnotationComposer,
      $$CollectionsTableCreateCompanionBuilder,
      $$CollectionsTableUpdateCompanionBuilder,
      (CollectionRow, $$CollectionsTableReferences),
      CollectionRow,
      PrefetchHooks Function({bool collectionNotesRefs})
    >;
typedef $$CollectionNotesTableCreateCompanionBuilder =
    CollectionNotesCompanion Function({
      required int collectionId,
      required int noteId,
      required DateTime addedAt,
      Value<int> rowid,
    });
typedef $$CollectionNotesTableUpdateCompanionBuilder =
    CollectionNotesCompanion Function({
      Value<int> collectionId,
      Value<int> noteId,
      Value<DateTime> addedAt,
      Value<int> rowid,
    });

final class $$CollectionNotesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CollectionNotesTable,
          CollectionNoteRow
        > {
  $$CollectionNotesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CollectionsTable _collectionIdTable(_$AppDatabase db) => db
      .collections
      .createAlias('collection_notes__collection_id__collections__id');

  $$CollectionsTableProcessedTableManager get collectionId {
    final $_column = $_itemColumn<int>('collection_id')!;

    final manager = $$CollectionsTableTableManager(
      $_db,
      $_db.collections,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_collectionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $NotesTable _noteIdTable(_$AppDatabase db) =>
      db.notes.createAlias('collection_notes__note_id__notes__id');

  $$NotesTableProcessedTableManager get noteId {
    final $_column = $_itemColumn<int>('note_id')!;

    final manager = $$NotesTableTableManager(
      $_db,
      $_db.notes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_noteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CollectionNotesTableFilterComposer
    extends Composer<_$AppDatabase, $CollectionNotesTable> {
  $$CollectionNotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CollectionsTableFilterComposer get collectionId {
    final $$CollectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableFilterComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$NotesTableFilterComposer get noteId {
    final $$NotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteId,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableFilterComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CollectionNotesTableOrderingComposer
    extends Composer<_$AppDatabase, $CollectionNotesTable> {
  $$CollectionNotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CollectionsTableOrderingComposer get collectionId {
    final $$CollectionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableOrderingComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$NotesTableOrderingComposer get noteId {
    final $$NotesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteId,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableOrderingComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CollectionNotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CollectionNotesTable> {
  $$CollectionNotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  $$CollectionsTableAnnotationComposer get collectionId {
    final $$CollectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$NotesTableAnnotationComposer get noteId {
    final $$NotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteId,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableAnnotationComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CollectionNotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CollectionNotesTable,
          CollectionNoteRow,
          $$CollectionNotesTableFilterComposer,
          $$CollectionNotesTableOrderingComposer,
          $$CollectionNotesTableAnnotationComposer,
          $$CollectionNotesTableCreateCompanionBuilder,
          $$CollectionNotesTableUpdateCompanionBuilder,
          (CollectionNoteRow, $$CollectionNotesTableReferences),
          CollectionNoteRow,
          PrefetchHooks Function({bool collectionId, bool noteId})
        > {
  $$CollectionNotesTableTableManager(
    _$AppDatabase db,
    $CollectionNotesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CollectionNotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CollectionNotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CollectionNotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> collectionId = const Value.absent(),
                Value<int> noteId = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CollectionNotesCompanion(
                collectionId: collectionId,
                noteId: noteId,
                addedAt: addedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int collectionId,
                required int noteId,
                required DateTime addedAt,
                Value<int> rowid = const Value.absent(),
              }) => CollectionNotesCompanion.insert(
                collectionId: collectionId,
                noteId: noteId,
                addedAt: addedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CollectionNotesTable, CollectionNoteRow>(table),
                  $$CollectionNotesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({collectionId = false, noteId = false}) {
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
                    if (collectionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.collectionId,
                        referencedTable: $$CollectionNotesTableReferences
                            ._collectionIdTable(db),
                        referencedColumn: $$CollectionNotesTableReferences
                            ._collectionIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (noteId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.noteId,
                        referencedTable: $$CollectionNotesTableReferences
                            ._noteIdTable(db),
                        referencedColumn: $$CollectionNotesTableReferences
                            ._noteIdTable(db)
                            .id,
                      ) as T;
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

typedef $$CollectionNotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CollectionNotesTable,
      CollectionNoteRow,
      $$CollectionNotesTableFilterComposer,
      $$CollectionNotesTableOrderingComposer,
      $$CollectionNotesTableAnnotationComposer,
      $$CollectionNotesTableCreateCompanionBuilder,
      $$CollectionNotesTableUpdateCompanionBuilder,
      (CollectionNoteRow, $$CollectionNotesTableReferences),
      CollectionNoteRow,
      PrefetchHooks Function({bool collectionId, bool noteId})
    >;
typedef $$CountriesTableCreateCompanionBuilder = CountriesCompanion Function({
  required String code,
  required String nameDe,
  required String nameEn,
  Value<int> rowid,
});
typedef $$CountriesTableUpdateCompanionBuilder = CountriesCompanion Function({
  Value<String> code,
  Value<String> nameDe,
  Value<String> nameEn,
  Value<int> rowid,
});

class $$CountriesTableFilterComposer
    extends Composer<_$AppDatabase, $CountriesTable> {
  $$CountriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameDe => $composableBuilder(
    column: $table.nameDe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameEn => $composableBuilder(
    column: $table.nameEn,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CountriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CountriesTable> {
  $$CountriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameDe => $composableBuilder(
    column: $table.nameDe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameEn => $composableBuilder(
    column: $table.nameEn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CountriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CountriesTable> {
  $$CountriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get nameDe =>
      $composableBuilder(column: $table.nameDe, builder: (column) => column);

  GeneratedColumn<String> get nameEn =>
      $composableBuilder(column: $table.nameEn, builder: (column) => column);
}

class $$CountriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CountriesTable,
          CountryRow,
          $$CountriesTableFilterComposer,
          $$CountriesTableOrderingComposer,
          $$CountriesTableAnnotationComposer,
          $$CountriesTableCreateCompanionBuilder,
          $$CountriesTableUpdateCompanionBuilder,
          (
            CountryRow,
            BaseReferences<_$AppDatabase, $CountriesTable, CountryRow>,
          ),
          CountryRow,
          PrefetchHooks Function()
        > {
  $$CountriesTableTableManager(_$AppDatabase db, $CountriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CountriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CountriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CountriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> code = const Value.absent(),
                Value<String> nameDe = const Value.absent(),
                Value<String> nameEn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CountriesCompanion(
                code: code,
                nameDe: nameDe,
                nameEn: nameEn,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String code,
                required String nameDe,
                required String nameEn,
                Value<int> rowid = const Value.absent(),
              }) => CountriesCompanion.insert(
                code: code,
                nameDe: nameDe,
                nameEn: nameEn,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CountriesTable, CountryRow>(table),
                  BaseReferences<_$AppDatabase, $CountriesTable, CountryRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CountriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CountriesTable,
      CountryRow,
      $$CountriesTableFilterComposer,
      $$CountriesTableOrderingComposer,
      $$CountriesTableAnnotationComposer,
      $$CountriesTableCreateCompanionBuilder,
      $$CountriesTableUpdateCompanionBuilder,
      (CountryRow, BaseReferences<_$AppDatabase, $CountriesTable, CountryRow>),
      CountryRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $NotesFtsTableManager get notesFts =>
      $NotesFtsTableManager(_db, _db.notesFts);
  $$NotesTableTableManager get notes =>
      $$NotesTableTableManager(_db, _db.notes);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$NoteTagsTableTableManager get noteTags =>
      $$NoteTagsTableTableManager(_db, _db.noteTags);
  $$CollectionsTableTableManager get collections =>
      $$CollectionsTableTableManager(_db, _db.collections);
  $$CollectionNotesTableTableManager get collectionNotes =>
      $$CollectionNotesTableTableManager(_db, _db.collectionNotes);
  $$CountriesTableTableManager get countries =>
      $$CountriesTableTableManager(_db, _db.countries);
}
