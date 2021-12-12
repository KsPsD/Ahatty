
import 'package:json_annotation/json_annotation.dart';
part 'result.g.dart';

@JsonSerializable(explicitToJson: true)
class Result {
  final String sentence;
  final double similarity;
  final double correct;
  final List<String> contents;
  final int count;
  final bool isChanged;
  final List<String> spell;
  final String chapter;

  Result({this.sentence, this.similarity, this.correct, this.contents, this.count,this.spell ,this.isChanged,this.chapter});

  factory Result.fromJson(Map<String, dynamic> json) =>_$ResultFromJson(json);
  Map<String,dynamic>toJson()=>_$ResultToJson(this);

}