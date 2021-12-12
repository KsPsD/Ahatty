import 'package:json_annotation/json_annotation.dart';
part 'chat_message.g.dart';

enum ChatMessageType { sent, received }

@JsonSerializable(explicitToJson: true)
class ChatMessage {
  final String name;
  final String text;
  final ChatMessageType type;

  ChatMessage({
    this.name,
    this.text,
    this.type = ChatMessageType.sent,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>_$ChatMessageFromJson(json);

  Map<String,dynamic>toJson()=>_$ChatMessageToJson(this);
}



