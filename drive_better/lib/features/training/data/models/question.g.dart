// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetQuestionCollection on Isar {
  IsarCollection<Question> get questions => this.collection();
}

const QuestionSchema = CollectionSchema(
  name: r'Question',
  id: -6819722535046815095,
  properties: {
    r'correctIndex': PropertySchema(
      id: 0,
      name: r'correctIndex',
      type: IsarType.long,
    ),
    r'dueAt': PropertySchema(
      id: 1,
      name: r'dueAt',
      type: IsarType.dateTime,
    ),
    r'easeFactor': PropertySchema(
      id: 2,
      name: r'easeFactor',
      type: IsarType.double,
    ),
    r'explanation': PropertySchema(
      id: 3,
      name: r'explanation',
      type: IsarType.string,
    ),
    r'externalId': PropertySchema(
      id: 4,
      name: r'externalId',
      type: IsarType.string,
    ),
    r'imageAsset': PropertySchema(
      id: 5,
      name: r'imageAsset',
      type: IsarType.string,
    ),
    r'isBookmarked': PropertySchema(
      id: 6,
      name: r'isBookmarked',
      type: IsarType.bool,
    ),
    r'isSerious': PropertySchema(
      id: 7,
      name: r'isSerious',
      type: IsarType.bool,
    ),
    r'lastSeenAt': PropertySchema(
      id: 8,
      name: r'lastSeenAt',
      type: IsarType.dateTime,
    ),
    r'options': PropertySchema(
      id: 9,
      name: r'options',
      type: IsarType.objectList,
      target: r'AnswerOption',
    ),
    r'searchTokens': PropertySchema(
      id: 10,
      name: r'searchTokens',
      type: IsarType.stringList,
    ),
    r'sourcePage': PropertySchema(
      id: 11,
      name: r'sourcePage',
      type: IsarType.long,
    ),
    r'text': PropertySchema(
      id: 12,
      name: r'text',
      type: IsarType.string,
    ),
    r'timesCorrect': PropertySchema(
      id: 13,
      name: r'timesCorrect',
      type: IsarType.long,
    ),
    r'timesSeen': PropertySchema(
      id: 14,
      name: r'timesSeen',
      type: IsarType.long,
    ),
    r'topicId': PropertySchema(
      id: 15,
      name: r'topicId',
      type: IsarType.string,
    )
  },
  estimateSize: _questionEstimateSize,
  serialize: _questionSerialize,
  deserialize: _questionDeserialize,
  deserializeProp: _questionDeserializeProp,
  idName: r'id',
  indexes: {
    r'externalId': IndexSchema(
      id: 8629824136592255998,
      name: r'externalId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'externalId',
          type: IndexType.value,
          caseSensitive: true,
        )
      ],
    ),
    r'topicId': IndexSchema(
      id: 3718206658163357569,
      name: r'topicId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'topicId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'searchTokens': IndexSchema(
      id: 2062148741461982474,
      name: r'searchTokens',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'searchTokens',
          type: IndexType.hashElements,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {r'AnswerOption': AnswerOptionSchema},
  getId: _questionGetId,
  getLinks: _questionGetLinks,
  attach: _questionAttach,
  version: '3.1.0+1',
);

int _questionEstimateSize(
  Question object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.explanation;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.externalId.length * 3;
  {
    final value = object.imageAsset;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.options.length * 3;
  {
    final offsets = allOffsets[AnswerOption]!;
    for (var i = 0; i < object.options.length; i++) {
      final value = object.options[i];
      bytesCount += AnswerOptionSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  bytesCount += 3 + object.searchTokens.length * 3;
  {
    for (var i = 0; i < object.searchTokens.length; i++) {
      final value = object.searchTokens[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.text.length * 3;
  bytesCount += 3 + object.topicId.length * 3;
  return bytesCount;
}

void _questionSerialize(
  Question object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.correctIndex);
  writer.writeDateTime(offsets[1], object.dueAt);
  writer.writeDouble(offsets[2], object.easeFactor);
  writer.writeString(offsets[3], object.explanation);
  writer.writeString(offsets[4], object.externalId);
  writer.writeString(offsets[5], object.imageAsset);
  writer.writeBool(offsets[6], object.isBookmarked);
  writer.writeBool(offsets[7], object.isSerious);
  writer.writeDateTime(offsets[8], object.lastSeenAt);
  writer.writeObjectList<AnswerOption>(
    offsets[9],
    allOffsets,
    AnswerOptionSchema.serialize,
    object.options,
  );
  writer.writeStringList(offsets[10], object.searchTokens);
  writer.writeLong(offsets[11], object.sourcePage);
  writer.writeString(offsets[12], object.text);
  writer.writeLong(offsets[13], object.timesCorrect);
  writer.writeLong(offsets[14], object.timesSeen);
  writer.writeString(offsets[15], object.topicId);
}

Question _questionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Question();
  object.correctIndex = reader.readLong(offsets[0]);
  object.dueAt = reader.readDateTimeOrNull(offsets[1]);
  object.easeFactor = reader.readDouble(offsets[2]);
  object.explanation = reader.readStringOrNull(offsets[3]);
  object.externalId = reader.readString(offsets[4]);
  object.id = id;
  object.imageAsset = reader.readStringOrNull(offsets[5]);
  object.isBookmarked = reader.readBool(offsets[6]);
  object.isSerious = reader.readBool(offsets[7]);
  object.lastSeenAt = reader.readDateTimeOrNull(offsets[8]);
  object.options = reader.readObjectList<AnswerOption>(
        offsets[9],
        AnswerOptionSchema.deserialize,
        allOffsets,
        AnswerOption(),
      ) ??
      [];
  object.searchTokens = reader.readStringList(offsets[10]) ?? [];
  object.sourcePage = reader.readLong(offsets[11]);
  object.text = reader.readString(offsets[12]);
  object.timesCorrect = reader.readLong(offsets[13]);
  object.timesSeen = reader.readLong(offsets[14]);
  object.topicId = reader.readString(offsets[15]);
  return object;
}

P _questionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 9:
      return (reader.readObjectList<AnswerOption>(
            offset,
            AnswerOptionSchema.deserialize,
            allOffsets,
            AnswerOption(),
          ) ??
          []) as P;
    case 10:
      return (reader.readStringList(offset) ?? []) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readLong(offset)) as P;
    case 14:
      return (reader.readLong(offset)) as P;
    case 15:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _questionGetId(Question object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _questionGetLinks(Question object) {
  return [];
}

void _questionAttach(IsarCollection<dynamic> col, Id id, Question object) {
  object.id = id;
}

extension QuestionQueryWhereSort on QueryBuilder<Question, Question, QWhere> {
  QueryBuilder<Question, Question, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<Question, Question, QAfterWhere> anyExternalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'externalId'),
      );
    });
  }

  QueryBuilder<Question, Question, QAfterWhere> anyTopicId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'topicId'),
      );
    });
  }
}

extension QuestionQueryWhere on QueryBuilder<Question, Question, QWhereClause> {
  QueryBuilder<Question, Question, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Question, Question, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Question, Question, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Question, Question, QAfterWhereClause> idBetween(
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

  QueryBuilder<Question, Question, QAfterWhereClause> externalIdEqualTo(
      String externalId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'externalId',
        value: [externalId],
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterWhereClause> externalIdNotEqualTo(
      String externalId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'externalId',
              lower: [],
              upper: [externalId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'externalId',
              lower: [externalId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'externalId',
              lower: [externalId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'externalId',
              lower: [],
              upper: [externalId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Question, Question, QAfterWhereClause> externalIdGreaterThan(
    String externalId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'externalId',
        lower: [externalId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterWhereClause> externalIdLessThan(
    String externalId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'externalId',
        lower: [],
        upper: [externalId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterWhereClause> externalIdBetween(
    String lowerExternalId,
    String upperExternalId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'externalId',
        lower: [lowerExternalId],
        includeLower: includeLower,
        upper: [upperExternalId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterWhereClause> externalIdStartsWith(
      String ExternalIdPrefix) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'externalId',
        lower: [ExternalIdPrefix],
        upper: ['$ExternalIdPrefix\u{FFFFF}'],
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterWhereClause> externalIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'externalId',
        value: [''],
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterWhereClause> externalIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'externalId',
              upper: [''],
            ))
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'externalId',
              lower: [''],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'externalId',
              lower: [''],
            ))
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'externalId',
              upper: [''],
            ));
      }
    });
  }

  QueryBuilder<Question, Question, QAfterWhereClause> topicIdEqualTo(
      String topicId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'topicId',
        value: [topicId],
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterWhereClause> topicIdNotEqualTo(
      String topicId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'topicId',
              lower: [],
              upper: [topicId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'topicId',
              lower: [topicId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'topicId',
              lower: [topicId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'topicId',
              lower: [],
              upper: [topicId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Question, Question, QAfterWhereClause> topicIdGreaterThan(
    String topicId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'topicId',
        lower: [topicId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterWhereClause> topicIdLessThan(
    String topicId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'topicId',
        lower: [],
        upper: [topicId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterWhereClause> topicIdBetween(
    String lowerTopicId,
    String upperTopicId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'topicId',
        lower: [lowerTopicId],
        includeLower: includeLower,
        upper: [upperTopicId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterWhereClause> topicIdStartsWith(
      String TopicIdPrefix) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'topicId',
        lower: [TopicIdPrefix],
        upper: ['$TopicIdPrefix\u{FFFFF}'],
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterWhereClause> topicIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'topicId',
        value: [''],
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterWhereClause> topicIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'topicId',
              upper: [''],
            ))
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'topicId',
              lower: [''],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'topicId',
              lower: [''],
            ))
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'topicId',
              upper: [''],
            ));
      }
    });
  }

  QueryBuilder<Question, Question, QAfterWhereClause>
      searchTokensElementEqualTo(String searchTokensElement) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'searchTokens',
        value: [searchTokensElement],
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterWhereClause>
      searchTokensElementNotEqualTo(String searchTokensElement) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'searchTokens',
              lower: [],
              upper: [searchTokensElement],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'searchTokens',
              lower: [searchTokensElement],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'searchTokens',
              lower: [searchTokensElement],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'searchTokens',
              lower: [],
              upper: [searchTokensElement],
              includeUpper: false,
            ));
      }
    });
  }
}

extension QuestionQueryFilter
    on QueryBuilder<Question, Question, QFilterCondition> {
  QueryBuilder<Question, Question, QAfterFilterCondition> correctIndexEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'correctIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition>
      correctIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'correctIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> correctIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'correctIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> correctIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'correctIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> dueAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dueAt',
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> dueAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dueAt',
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> dueAtEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dueAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> dueAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dueAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> dueAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dueAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> dueAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dueAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> easeFactorEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'easeFactor',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> easeFactorGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'easeFactor',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> easeFactorLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'easeFactor',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> easeFactorBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'easeFactor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> explanationIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'explanation',
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition>
      explanationIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'explanation',
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> explanationEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'explanation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition>
      explanationGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'explanation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> explanationLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'explanation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> explanationBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'explanation',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> explanationStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'explanation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> explanationEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'explanation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> explanationContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'explanation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> explanationMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'explanation',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> explanationIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'explanation',
        value: '',
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition>
      explanationIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'explanation',
        value: '',
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> externalIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'externalId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> externalIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'externalId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> externalIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'externalId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> externalIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'externalId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> externalIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'externalId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> externalIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'externalId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> externalIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'externalId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> externalIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'externalId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> externalIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'externalId',
        value: '',
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition>
      externalIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'externalId',
        value: '',
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Question, Question, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Question, Question, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Question, Question, QAfterFilterCondition> imageAssetIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'imageAsset',
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition>
      imageAssetIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'imageAsset',
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> imageAssetEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imageAsset',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> imageAssetGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'imageAsset',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> imageAssetLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'imageAsset',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> imageAssetBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'imageAsset',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> imageAssetStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'imageAsset',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> imageAssetEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'imageAsset',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> imageAssetContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'imageAsset',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> imageAssetMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'imageAsset',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> imageAssetIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imageAsset',
        value: '',
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition>
      imageAssetIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'imageAsset',
        value: '',
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> isBookmarkedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isBookmarked',
        value: value,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> isSeriousEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSerious',
        value: value,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> lastSeenAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastSeenAt',
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition>
      lastSeenAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastSeenAt',
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> lastSeenAtEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSeenAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> lastSeenAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastSeenAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> lastSeenAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastSeenAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> lastSeenAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastSeenAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> optionsLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'options',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> optionsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'options',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> optionsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'options',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> optionsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'options',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition>
      optionsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'options',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> optionsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'options',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition>
      searchTokensElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'searchTokens',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition>
      searchTokensElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'searchTokens',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition>
      searchTokensElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'searchTokens',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition>
      searchTokensElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'searchTokens',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition>
      searchTokensElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'searchTokens',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition>
      searchTokensElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'searchTokens',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition>
      searchTokensElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'searchTokens',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition>
      searchTokensElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'searchTokens',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition>
      searchTokensElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'searchTokens',
        value: '',
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition>
      searchTokensElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'searchTokens',
        value: '',
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition>
      searchTokensLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'searchTokens',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition>
      searchTokensIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'searchTokens',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition>
      searchTokensIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'searchTokens',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition>
      searchTokensLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'searchTokens',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition>
      searchTokensLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'searchTokens',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition>
      searchTokensLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'searchTokens',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> sourcePageEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourcePage',
        value: value,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> sourcePageGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sourcePage',
        value: value,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> sourcePageLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sourcePage',
        value: value,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> sourcePageBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sourcePage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> textEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> textGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> textLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> textBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'text',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> textStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> textEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> textContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> textMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'text',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> textIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'text',
        value: '',
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> textIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'text',
        value: '',
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> timesCorrectEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timesCorrect',
        value: value,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition>
      timesCorrectGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timesCorrect',
        value: value,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> timesCorrectLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timesCorrect',
        value: value,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> timesCorrectBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timesCorrect',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> timesSeenEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timesSeen',
        value: value,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> timesSeenGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timesSeen',
        value: value,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> timesSeenLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timesSeen',
        value: value,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> timesSeenBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timesSeen',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> topicIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'topicId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> topicIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'topicId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> topicIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'topicId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> topicIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'topicId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> topicIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'topicId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> topicIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'topicId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> topicIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'topicId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> topicIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'topicId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> topicIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'topicId',
        value: '',
      ));
    });
  }

  QueryBuilder<Question, Question, QAfterFilterCondition> topicIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'topicId',
        value: '',
      ));
    });
  }
}

extension QuestionQueryObject
    on QueryBuilder<Question, Question, QFilterCondition> {
  QueryBuilder<Question, Question, QAfterFilterCondition> optionsElement(
      FilterQuery<AnswerOption> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'options');
    });
  }
}

extension QuestionQueryLinks
    on QueryBuilder<Question, Question, QFilterCondition> {}

extension QuestionQuerySortBy on QueryBuilder<Question, Question, QSortBy> {
  QueryBuilder<Question, Question, QAfterSortBy> sortByCorrectIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctIndex', Sort.asc);
    });
  }

  QueryBuilder<Question, Question, QAfterSortBy> sortByCorrectIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctIndex', Sort.desc);
    });
  }

  QueryBuilder<Question, Question, QAfterSortBy> sortByDueAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueAt', Sort.asc);
    });
  }

  QueryBuilder<Question, Question, QAfterSortBy> sortByDueAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueAt', Sort.desc);
    });
  }

  QueryBuilder<Question, Question, QAfterSortBy> sortByEaseFactor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'easeFactor', Sort.asc);
    });
  }

  QueryBuilder<Question, Question, QAfterSortBy> sortByEaseFactorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'easeFactor', Sort.desc);
    });
  }

  QueryBuilder<Question, Question, QAfterSortBy> sortByExplanation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'explanation', Sort.asc);
    });
  }

  QueryBuilder<Question, Question, QAfterSortBy> sortByExplanationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'explanation', Sort.desc);
    });
  }

  QueryBuilder<Question, Question, QAfterSortBy> sortByExternalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'externalId', Sort.asc);
    });
  }

  QueryBuilder<Question, Question, QAfterSortBy> sortByExternalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'externalId', Sort.desc);
    });
  }

  QueryBuilder<Question, Question, QAfterSortBy> sortByImageAsset() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageAsset', Sort.asc);
    });
  }

  QueryBuilder<Question, Question, QAfterSortBy> sortByImageAssetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageAsset', Sort.desc);
    });
  }

  QueryBuilder<Question, Question, QAfterSortBy> sortByIsBookmarked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBookmarked', Sort.asc);
    });
  }

  QueryBuilder<Question, Question, QAfterSortBy> sortByIsBookmarkedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBookmarked', Sort.desc);
    });
  }

  QueryBuilder<Question, Question, QAfterSortBy> sortByIsSerious() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSerious', Sort.asc);
    });
  }

  QueryBuilder<Question, Question, QAfterSortBy> sortByIsSeriousDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSerious', Sort.desc);
    });
  }

  QueryBuilder<Question, Question, QAfterSortBy> sortByLastSeenAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSeenAt', Sort.asc);
    });
  }

  QueryBuilder<Question, Question, QAfterSortBy> sortByLastSeenAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSeenAt', Sort.desc);
    });
  }

  QueryBuilder<Question, Question, QAfterSortBy> sortBySourcePage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourcePage', Sort.asc);
    });
  }

  QueryBuilder<Question, Question, QAfterSortBy> sortBySourcePageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourcePage', Sort.desc);
    });
  }

  QueryBuilder<Question, Question, QAfterSortBy> sortByText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.asc);
    });
  }

  QueryBuilder<Question, Question, QAfterSortBy> sortByTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.desc);
    });
  }

  QueryBuilder<Question, Question, QAfterSortBy> sortByTimesCorrect() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timesCorrect', Sort.asc);
    });
  }

  QueryBuilder<Question, Question, QAfterSortBy> sortByTimesCorrectDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timesCorrect', Sort.desc);
    });
  }

  QueryBuilder<Question, Question, QAfterSortBy> sortByTimesSeen() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timesSeen', Sort.asc);
    });
  }

  QueryBuilder<Question, Question, QAfterSortBy> sortByTimesSeenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timesSeen', Sort.desc);
    });
  }

  QueryBuilder<Question, Question, QAfterSortBy> sortByTopicId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topicId', Sort.asc);
    });
  }

  QueryBuilder<Question, Question, QAfterSortBy> sortByTopicIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topicId', Sort.desc);
    });
  }
}

extension QuestionQuerySortThenBy
    on QueryBuilder<Question, Question, QSortThenBy> {
  QueryBuilder<Question, Question, QAfterSortBy> thenByCorrectIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctIndex', Sort.asc);
    });
  }

  QueryBuilder<Question, Question, QAfterSortBy> thenByCorrectIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctIndex', Sort.desc);
    });
  }

  QueryBuilder<Question, Question, QAfterSortBy> thenByDueAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueAt', Sort.asc);
    });
  }

  QueryBuilder<Question, Question, QAfterSortBy> thenByDueAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueAt', Sort.desc);
    });
  }

  QueryBuilder<Question, Question, QAfterSortBy> thenByEaseFactor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'easeFactor', Sort.asc);
    });
  }

  QueryBuilder<Question, Question, QAfterSortBy> thenByEaseFactorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'easeFactor', Sort.desc);
    });
  }

  QueryBuilder<Question, Question, QAfterSortBy> thenByExplanation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'explanation', Sort.asc);
    });
  }

  QueryBuilder<Question, Question, QAfterSortBy> thenByExplanationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'explanation', Sort.desc);
    });
  }

  QueryBuilder<Question, Question, QAfterSortBy> thenByExternalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'externalId', Sort.asc);
    });
  }

  QueryBuilder<Question, Question, QAfterSortBy> thenByExternalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'externalId', Sort.desc);
    });
  }

  QueryBuilder<Question, Question, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Question, Question, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Question, Question, QAfterSortBy> thenByImageAsset() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageAsset', Sort.asc);
    });
  }

  QueryBuilder<Question, Question, QAfterSortBy> thenByImageAssetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageAsset', Sort.desc);
    });
  }

  QueryBuilder<Question, Question, QAfterSortBy> thenByIsBookmarked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBookmarked', Sort.asc);
    });
  }

  QueryBuilder<Question, Question, QAfterSortBy> thenByIsBookmarkedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBookmarked', Sort.desc);
    });
  }

  QueryBuilder<Question, Question, QAfterSortBy> thenByIsSerious() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSerious', Sort.asc);
    });
  }

  QueryBuilder<Question, Question, QAfterSortBy> thenByIsSeriousDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSerious', Sort.desc);
    });
  }

  QueryBuilder<Question, Question, QAfterSortBy> thenByLastSeenAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSeenAt', Sort.asc);
    });
  }

  QueryBuilder<Question, Question, QAfterSortBy> thenByLastSeenAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSeenAt', Sort.desc);
    });
  }

  QueryBuilder<Question, Question, QAfterSortBy> thenBySourcePage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourcePage', Sort.asc);
    });
  }

  QueryBuilder<Question, Question, QAfterSortBy> thenBySourcePageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourcePage', Sort.desc);
    });
  }

  QueryBuilder<Question, Question, QAfterSortBy> thenByText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.asc);
    });
  }

  QueryBuilder<Question, Question, QAfterSortBy> thenByTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.desc);
    });
  }

  QueryBuilder<Question, Question, QAfterSortBy> thenByTimesCorrect() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timesCorrect', Sort.asc);
    });
  }

  QueryBuilder<Question, Question, QAfterSortBy> thenByTimesCorrectDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timesCorrect', Sort.desc);
    });
  }

  QueryBuilder<Question, Question, QAfterSortBy> thenByTimesSeen() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timesSeen', Sort.asc);
    });
  }

  QueryBuilder<Question, Question, QAfterSortBy> thenByTimesSeenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timesSeen', Sort.desc);
    });
  }

  QueryBuilder<Question, Question, QAfterSortBy> thenByTopicId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topicId', Sort.asc);
    });
  }

  QueryBuilder<Question, Question, QAfterSortBy> thenByTopicIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topicId', Sort.desc);
    });
  }
}

extension QuestionQueryWhereDistinct
    on QueryBuilder<Question, Question, QDistinct> {
  QueryBuilder<Question, Question, QDistinct> distinctByCorrectIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'correctIndex');
    });
  }

  QueryBuilder<Question, Question, QDistinct> distinctByDueAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dueAt');
    });
  }

  QueryBuilder<Question, Question, QDistinct> distinctByEaseFactor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'easeFactor');
    });
  }

  QueryBuilder<Question, Question, QDistinct> distinctByExplanation(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'explanation', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Question, Question, QDistinct> distinctByExternalId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'externalId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Question, Question, QDistinct> distinctByImageAsset(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'imageAsset', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Question, Question, QDistinct> distinctByIsBookmarked() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isBookmarked');
    });
  }

  QueryBuilder<Question, Question, QDistinct> distinctByIsSerious() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSerious');
    });
  }

  QueryBuilder<Question, Question, QDistinct> distinctByLastSeenAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSeenAt');
    });
  }

  QueryBuilder<Question, Question, QDistinct> distinctBySearchTokens() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'searchTokens');
    });
  }

  QueryBuilder<Question, Question, QDistinct> distinctBySourcePage() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourcePage');
    });
  }

  QueryBuilder<Question, Question, QDistinct> distinctByText(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'text', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Question, Question, QDistinct> distinctByTimesCorrect() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timesCorrect');
    });
  }

  QueryBuilder<Question, Question, QDistinct> distinctByTimesSeen() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timesSeen');
    });
  }

  QueryBuilder<Question, Question, QDistinct> distinctByTopicId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'topicId', caseSensitive: caseSensitive);
    });
  }
}

extension QuestionQueryProperty
    on QueryBuilder<Question, Question, QQueryProperty> {
  QueryBuilder<Question, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Question, int, QQueryOperations> correctIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'correctIndex');
    });
  }

  QueryBuilder<Question, DateTime?, QQueryOperations> dueAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dueAt');
    });
  }

  QueryBuilder<Question, double, QQueryOperations> easeFactorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'easeFactor');
    });
  }

  QueryBuilder<Question, String?, QQueryOperations> explanationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'explanation');
    });
  }

  QueryBuilder<Question, String, QQueryOperations> externalIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'externalId');
    });
  }

  QueryBuilder<Question, String?, QQueryOperations> imageAssetProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'imageAsset');
    });
  }

  QueryBuilder<Question, bool, QQueryOperations> isBookmarkedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isBookmarked');
    });
  }

  QueryBuilder<Question, bool, QQueryOperations> isSeriousProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSerious');
    });
  }

  QueryBuilder<Question, DateTime?, QQueryOperations> lastSeenAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSeenAt');
    });
  }

  QueryBuilder<Question, List<AnswerOption>, QQueryOperations>
      optionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'options');
    });
  }

  QueryBuilder<Question, List<String>, QQueryOperations>
      searchTokensProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'searchTokens');
    });
  }

  QueryBuilder<Question, int, QQueryOperations> sourcePageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourcePage');
    });
  }

  QueryBuilder<Question, String, QQueryOperations> textProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'text');
    });
  }

  QueryBuilder<Question, int, QQueryOperations> timesCorrectProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timesCorrect');
    });
  }

  QueryBuilder<Question, int, QQueryOperations> timesSeenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timesSeen');
    });
  }

  QueryBuilder<Question, String, QQueryOperations> topicIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'topicId');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const AnswerOptionSchema = Schema(
  name: r'AnswerOption',
  id: 7863280254967055842,
  properties: {
    r'imageAsset': PropertySchema(
      id: 0,
      name: r'imageAsset',
      type: IsarType.string,
    ),
    r'text': PropertySchema(
      id: 1,
      name: r'text',
      type: IsarType.string,
    )
  },
  estimateSize: _answerOptionEstimateSize,
  serialize: _answerOptionSerialize,
  deserialize: _answerOptionDeserialize,
  deserializeProp: _answerOptionDeserializeProp,
);

int _answerOptionEstimateSize(
  AnswerOption object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.imageAsset;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.text.length * 3;
  return bytesCount;
}

void _answerOptionSerialize(
  AnswerOption object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.imageAsset);
  writer.writeString(offsets[1], object.text);
}

AnswerOption _answerOptionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AnswerOption();
  object.imageAsset = reader.readStringOrNull(offsets[0]);
  object.text = reader.readString(offsets[1]);
  return object;
}

P _answerOptionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension AnswerOptionQueryFilter
    on QueryBuilder<AnswerOption, AnswerOption, QFilterCondition> {
  QueryBuilder<AnswerOption, AnswerOption, QAfterFilterCondition>
      imageAssetIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'imageAsset',
      ));
    });
  }

  QueryBuilder<AnswerOption, AnswerOption, QAfterFilterCondition>
      imageAssetIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'imageAsset',
      ));
    });
  }

  QueryBuilder<AnswerOption, AnswerOption, QAfterFilterCondition>
      imageAssetEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imageAsset',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnswerOption, AnswerOption, QAfterFilterCondition>
      imageAssetGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'imageAsset',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnswerOption, AnswerOption, QAfterFilterCondition>
      imageAssetLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'imageAsset',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnswerOption, AnswerOption, QAfterFilterCondition>
      imageAssetBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'imageAsset',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnswerOption, AnswerOption, QAfterFilterCondition>
      imageAssetStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'imageAsset',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnswerOption, AnswerOption, QAfterFilterCondition>
      imageAssetEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'imageAsset',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnswerOption, AnswerOption, QAfterFilterCondition>
      imageAssetContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'imageAsset',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnswerOption, AnswerOption, QAfterFilterCondition>
      imageAssetMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'imageAsset',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnswerOption, AnswerOption, QAfterFilterCondition>
      imageAssetIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imageAsset',
        value: '',
      ));
    });
  }

  QueryBuilder<AnswerOption, AnswerOption, QAfterFilterCondition>
      imageAssetIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'imageAsset',
        value: '',
      ));
    });
  }

  QueryBuilder<AnswerOption, AnswerOption, QAfterFilterCondition> textEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnswerOption, AnswerOption, QAfterFilterCondition>
      textGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnswerOption, AnswerOption, QAfterFilterCondition> textLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnswerOption, AnswerOption, QAfterFilterCondition> textBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'text',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnswerOption, AnswerOption, QAfterFilterCondition>
      textStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnswerOption, AnswerOption, QAfterFilterCondition> textEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnswerOption, AnswerOption, QAfterFilterCondition> textContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnswerOption, AnswerOption, QAfterFilterCondition> textMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'text',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnswerOption, AnswerOption, QAfterFilterCondition>
      textIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'text',
        value: '',
      ));
    });
  }

  QueryBuilder<AnswerOption, AnswerOption, QAfterFilterCondition>
      textIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'text',
        value: '',
      ));
    });
  }
}

extension AnswerOptionQueryObject
    on QueryBuilder<AnswerOption, AnswerOption, QFilterCondition> {}
