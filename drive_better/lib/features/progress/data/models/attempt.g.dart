// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attempt.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAttemptCollection on Isar {
  IsarCollection<Attempt> get attempts => this.collection();
}

const AttemptSchema = CollectionSchema(
  name: r'Attempt',
  id: -2896337679998869422,
  properties: {
    r'answeredAt': PropertySchema(
      id: 0,
      name: r'answeredAt',
      type: IsarType.dateTime,
    ),
    r'chosenIndex': PropertySchema(
      id: 1,
      name: r'chosenIndex',
      type: IsarType.long,
    ),
    r'mode': PropertySchema(
      id: 2,
      name: r'mode',
      type: IsarType.byte,
      enumMap: _AttemptmodeEnumValueMap,
    ),
    r'msToAnswer': PropertySchema(
      id: 3,
      name: r'msToAnswer',
      type: IsarType.long,
    ),
    r'questionExternalId': PropertySchema(
      id: 4,
      name: r'questionExternalId',
      type: IsarType.string,
    ),
    r'wasCorrect': PropertySchema(
      id: 5,
      name: r'wasCorrect',
      type: IsarType.bool,
    )
  },
  estimateSize: _attemptEstimateSize,
  serialize: _attemptSerialize,
  deserialize: _attemptDeserialize,
  deserializeProp: _attemptDeserializeProp,
  idName: r'id',
  indexes: {
    r'questionExternalId': IndexSchema(
      id: 932418755825110140,
      name: r'questionExternalId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'questionExternalId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'answeredAt': IndexSchema(
      id: -6330496074754756919,
      name: r'answeredAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'answeredAt',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _attemptGetId,
  getLinks: _attemptGetLinks,
  attach: _attemptAttach,
  version: '3.1.0+1',
);

int _attemptEstimateSize(
  Attempt object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.questionExternalId.length * 3;
  return bytesCount;
}

void _attemptSerialize(
  Attempt object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.answeredAt);
  writer.writeLong(offsets[1], object.chosenIndex);
  writer.writeByte(offsets[2], object.mode.index);
  writer.writeLong(offsets[3], object.msToAnswer);
  writer.writeString(offsets[4], object.questionExternalId);
  writer.writeBool(offsets[5], object.wasCorrect);
}

Attempt _attemptDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Attempt();
  object.answeredAt = reader.readDateTime(offsets[0]);
  object.chosenIndex = reader.readLong(offsets[1]);
  object.id = id;
  object.mode = _AttemptmodeValueEnumMap[reader.readByteOrNull(offsets[2])] ??
      AttemptMode.practice;
  object.msToAnswer = reader.readLong(offsets[3]);
  object.questionExternalId = reader.readString(offsets[4]);
  object.wasCorrect = reader.readBool(offsets[5]);
  return object;
}

P _attemptDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (_AttemptmodeValueEnumMap[reader.readByteOrNull(offset)] ??
          AttemptMode.practice) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _AttemptmodeEnumValueMap = {
  'practice': 0,
  'mockTest': 1,
  'flashcard': 2,
};
const _AttemptmodeValueEnumMap = {
  0: AttemptMode.practice,
  1: AttemptMode.mockTest,
  2: AttemptMode.flashcard,
};

Id _attemptGetId(Attempt object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _attemptGetLinks(Attempt object) {
  return [];
}

void _attemptAttach(IsarCollection<dynamic> col, Id id, Attempt object) {
  object.id = id;
}

extension AttemptQueryWhereSort on QueryBuilder<Attempt, Attempt, QWhere> {
  QueryBuilder<Attempt, Attempt, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterWhere> anyAnsweredAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'answeredAt'),
      );
    });
  }
}

extension AttemptQueryWhere on QueryBuilder<Attempt, Attempt, QWhereClause> {
  QueryBuilder<Attempt, Attempt, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterWhereClause> questionExternalIdEqualTo(
      String questionExternalId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'questionExternalId',
        value: [questionExternalId],
      ));
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterWhereClause>
      questionExternalIdNotEqualTo(String questionExternalId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'questionExternalId',
              lower: [],
              upper: [questionExternalId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'questionExternalId',
              lower: [questionExternalId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'questionExternalId',
              lower: [questionExternalId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'questionExternalId',
              lower: [],
              upper: [questionExternalId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterWhereClause> answeredAtEqualTo(
      DateTime answeredAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'answeredAt',
        value: [answeredAt],
      ));
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterWhereClause> answeredAtNotEqualTo(
      DateTime answeredAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'answeredAt',
              lower: [],
              upper: [answeredAt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'answeredAt',
              lower: [answeredAt],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'answeredAt',
              lower: [answeredAt],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'answeredAt',
              lower: [],
              upper: [answeredAt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterWhereClause> answeredAtGreaterThan(
    DateTime answeredAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'answeredAt',
        lower: [answeredAt],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterWhereClause> answeredAtLessThan(
    DateTime answeredAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'answeredAt',
        lower: [],
        upper: [answeredAt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterWhereClause> answeredAtBetween(
    DateTime lowerAnsweredAt,
    DateTime upperAnsweredAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'answeredAt',
        lower: [lowerAnsweredAt],
        includeLower: includeLower,
        upper: [upperAnsweredAt],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension AttemptQueryFilter
    on QueryBuilder<Attempt, Attempt, QFilterCondition> {
  QueryBuilder<Attempt, Attempt, QAfterFilterCondition> answeredAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'answeredAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterFilterCondition> answeredAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'answeredAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterFilterCondition> answeredAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'answeredAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterFilterCondition> answeredAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'answeredAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterFilterCondition> chosenIndexEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chosenIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterFilterCondition> chosenIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'chosenIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterFilterCondition> chosenIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'chosenIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterFilterCondition> chosenIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'chosenIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterFilterCondition> modeEqualTo(
      AttemptMode value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mode',
        value: value,
      ));
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterFilterCondition> modeGreaterThan(
    AttemptMode value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mode',
        value: value,
      ));
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterFilterCondition> modeLessThan(
    AttemptMode value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mode',
        value: value,
      ));
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterFilterCondition> modeBetween(
    AttemptMode lower,
    AttemptMode upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterFilterCondition> msToAnswerEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'msToAnswer',
        value: value,
      ));
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterFilterCondition> msToAnswerGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'msToAnswer',
        value: value,
      ));
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterFilterCondition> msToAnswerLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'msToAnswer',
        value: value,
      ));
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterFilterCondition> msToAnswerBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'msToAnswer',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterFilterCondition>
      questionExternalIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'questionExternalId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterFilterCondition>
      questionExternalIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'questionExternalId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterFilterCondition>
      questionExternalIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'questionExternalId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterFilterCondition>
      questionExternalIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'questionExternalId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterFilterCondition>
      questionExternalIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'questionExternalId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterFilterCondition>
      questionExternalIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'questionExternalId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterFilterCondition>
      questionExternalIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'questionExternalId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterFilterCondition>
      questionExternalIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'questionExternalId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterFilterCondition>
      questionExternalIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'questionExternalId',
        value: '',
      ));
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterFilterCondition>
      questionExternalIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'questionExternalId',
        value: '',
      ));
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterFilterCondition> wasCorrectEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'wasCorrect',
        value: value,
      ));
    });
  }
}

extension AttemptQueryObject
    on QueryBuilder<Attempt, Attempt, QFilterCondition> {}

extension AttemptQueryLinks
    on QueryBuilder<Attempt, Attempt, QFilterCondition> {}

extension AttemptQuerySortBy on QueryBuilder<Attempt, Attempt, QSortBy> {
  QueryBuilder<Attempt, Attempt, QAfterSortBy> sortByAnsweredAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'answeredAt', Sort.asc);
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterSortBy> sortByAnsweredAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'answeredAt', Sort.desc);
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterSortBy> sortByChosenIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chosenIndex', Sort.asc);
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterSortBy> sortByChosenIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chosenIndex', Sort.desc);
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterSortBy> sortByMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mode', Sort.asc);
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterSortBy> sortByModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mode', Sort.desc);
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterSortBy> sortByMsToAnswer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'msToAnswer', Sort.asc);
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterSortBy> sortByMsToAnswerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'msToAnswer', Sort.desc);
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterSortBy> sortByQuestionExternalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'questionExternalId', Sort.asc);
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterSortBy> sortByQuestionExternalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'questionExternalId', Sort.desc);
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterSortBy> sortByWasCorrect() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wasCorrect', Sort.asc);
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterSortBy> sortByWasCorrectDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wasCorrect', Sort.desc);
    });
  }
}

extension AttemptQuerySortThenBy
    on QueryBuilder<Attempt, Attempt, QSortThenBy> {
  QueryBuilder<Attempt, Attempt, QAfterSortBy> thenByAnsweredAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'answeredAt', Sort.asc);
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterSortBy> thenByAnsweredAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'answeredAt', Sort.desc);
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterSortBy> thenByChosenIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chosenIndex', Sort.asc);
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterSortBy> thenByChosenIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chosenIndex', Sort.desc);
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterSortBy> thenByMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mode', Sort.asc);
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterSortBy> thenByModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mode', Sort.desc);
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterSortBy> thenByMsToAnswer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'msToAnswer', Sort.asc);
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterSortBy> thenByMsToAnswerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'msToAnswer', Sort.desc);
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterSortBy> thenByQuestionExternalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'questionExternalId', Sort.asc);
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterSortBy> thenByQuestionExternalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'questionExternalId', Sort.desc);
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterSortBy> thenByWasCorrect() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wasCorrect', Sort.asc);
    });
  }

  QueryBuilder<Attempt, Attempt, QAfterSortBy> thenByWasCorrectDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wasCorrect', Sort.desc);
    });
  }
}

extension AttemptQueryWhereDistinct
    on QueryBuilder<Attempt, Attempt, QDistinct> {
  QueryBuilder<Attempt, Attempt, QDistinct> distinctByAnsweredAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'answeredAt');
    });
  }

  QueryBuilder<Attempt, Attempt, QDistinct> distinctByChosenIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'chosenIndex');
    });
  }

  QueryBuilder<Attempt, Attempt, QDistinct> distinctByMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mode');
    });
  }

  QueryBuilder<Attempt, Attempt, QDistinct> distinctByMsToAnswer() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'msToAnswer');
    });
  }

  QueryBuilder<Attempt, Attempt, QDistinct> distinctByQuestionExternalId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'questionExternalId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Attempt, Attempt, QDistinct> distinctByWasCorrect() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'wasCorrect');
    });
  }
}

extension AttemptQueryProperty
    on QueryBuilder<Attempt, Attempt, QQueryProperty> {
  QueryBuilder<Attempt, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Attempt, DateTime, QQueryOperations> answeredAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'answeredAt');
    });
  }

  QueryBuilder<Attempt, int, QQueryOperations> chosenIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'chosenIndex');
    });
  }

  QueryBuilder<Attempt, AttemptMode, QQueryOperations> modeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mode');
    });
  }

  QueryBuilder<Attempt, int, QQueryOperations> msToAnswerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'msToAnswer');
    });
  }

  QueryBuilder<Attempt, String, QQueryOperations> questionExternalIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'questionExternalId');
    });
  }

  QueryBuilder<Attempt, bool, QQueryOperations> wasCorrectProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'wasCorrect');
    });
  }
}
