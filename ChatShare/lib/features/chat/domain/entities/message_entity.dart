class MessageEntity {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final String createdAt;
  final bool isImage; // ✅ Add this field
  final String status; // ✅ Add status field

  MessageEntity({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.createdAt,
    required this.isImage, // ✅ Ensure it's required
    required this.status, // ✅ Initialize status
    
  });
}