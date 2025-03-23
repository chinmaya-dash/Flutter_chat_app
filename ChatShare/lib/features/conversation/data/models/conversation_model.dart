// ignore_for_file: use_super_parameters

import 'package:chatshare/features/conversation/domain/entities/conversation_entity.dart';

class ConversationModel extends ConversationEntity {
  ConversationModel({
    required id,
    required participantName,
    required participantImage,
    required lastMessage,
    required lastMessageTime,
  }) : super(
         id: id,
         participantName: participantName,
         participantImage: participantImage,
         lastMessage: lastMessage,
         lastMessageTime: lastMessageTime,
       );

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['conversation_id'],
      participantName: json['participant_name'],
      participantImage: json['profile_image'] ?? 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      lastMessage: json['last_message'] ?? '',
      lastMessageTime:
          json['last_message_time'] != null
              ? DateTime.parse(json['last_message_time'])
              : DateTime.now(),
    );
  }
}
