// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Result _$ResultFromJson(Map<String, dynamic> json) {
  return Result(
    sentence: json['sentence'] as String,
    similarity: (json['similarity'] as num)?.toDouble(),
    correct: (json['correct'] as num)?.toDouble(),
    contents: (json['contents'] as List)?.map((e) => e as String)?.toList(),
    count: json['count'] as int,
    spell: (json['spell'] as List)?.map((e) => e as String)?.toList(),
    isChanged: json['isChanged'] as bool,
    chapter: json['chapter'] as String,
  );
}

Map<String, dynamic> _$ResultToJson(Result instance) => <String, dynamic>{
      'sentence': instance.sentence,
      'similarity': instance.similarity,
      'correct': instance.correct,
      'contents': instance.contents,
      'count': instance.count,
      'isChanged': instance.isChanged,
      'spell': instance.spell,
      'chapter': instance.chapter,
    };
