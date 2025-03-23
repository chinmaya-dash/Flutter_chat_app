import 'package:chatshare/features/chat/domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  MessageModel({
    required super.id,
    required super.conversationId,
    required super.senderId,
    required super.content,
    required super.createdAt, // ✅ Ensure correct type (String)
    required super.isImage, // ✅ Ensure it’s passed correctly
  }); // ✅ Explicitly pass to super

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      conversationId: json['conversation_id'],
      senderId: json['sender_id'],
      content: json['content'],
      createdAt: json['created_at'], // ✅ Keep it as String
      isImage: json['is_image'] ?? false, // ✅ Ensure correct key naming
    );
  }
}
