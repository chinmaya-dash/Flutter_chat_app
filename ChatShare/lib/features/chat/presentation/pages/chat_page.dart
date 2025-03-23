import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:chatshare/core/theme.dart';
import 'package:chatshare/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:chatshare/features/chat/presentation/bloc/chat_event.dart';
import 'package:chatshare/features/chat/presentation/bloc/chat_state.dart';

class ChatPage extends StatefulWidget {
  final String conversationId;
  final String mate;
  final String profileImage;
  final String currentUserId; // ✅ Add this

  const ChatPage({
    super.key,
    required this.conversationId,
    required this.mate,
    required this.profileImage,
    required this.currentUserId, // ✅ Add this
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

bool _isFetching = false;

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final _storage = FlutterSecureStorage();
  bool _showEmojiPicker = false;
  String userId = '';
  String botId = '00000000-0000-0000-0000-000000000000';

  @override
  void initState() {
    super.initState();
    BlocProvider.of<ChatBloc>(
      context,
    ).add(LoadMessagesEvent(widget.conversationId));
    // BlocProvider.of<ChatBloc>(context,).add(LoadDailyQuestionEvent(widget.conversationId));
    fetchUserId();
    markMessagesAsRead(widget.conversationId, widget.currentUserId);
  }

  fetchUserId() async {
    userId = await _storage.read(key: 'userId') ?? '';
    setState(() {
      userId = userId;
    });
  }

  Future<void> _openCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
    ); // or ImageSource.gallery

    if (pickedFile != null) {
      // ignore: use_build_context_synchronously
      BlocProvider.of<ChatBloc>(context).add(
        SendMessageEvent(widget.conversationId, pickedFile.path, isImage: true),
      );
    }
  }

  //message seen
  Future<void> markMessagesAsRead(String conversationId, String userId) async {
    final url = Uri.parse(
      'http://localhost:4000/conversations/messages/mark-as-read',
    );

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"conversationId": conversationId, "userId": userId}),
    );

    if (response.statusCode == 200) {
      print("Messages marked as read");
    } else {
      print("Failed to update message status");
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage({bool isImage = false, String? imageUrl}) {
    final content = isImage ? imageUrl! : _messageController.text.trim();

    if (content.isNotEmpty) {
      BlocProvider.of<ChatBloc>(
        context,
      ).add(SendMessageEvent(widget.conversationId, content, isImage: isImage));
      _messageController.clear();
      setState(
        () => _showEmojiPicker = false,
      ); // Hide emoji picker after sending
    }
  }

  // Future<void> _openCamera() async {
  //   final picker = ImagePicker();
  //   final pickedFile = await picker.pickImage(source: ImageSource.camera);

  //   if (pickedFile != null) {
  //     BlocProvider.of<ChatBloc>(context).add(
  //       SendMessageEvent(widget.conversationId, pickedFile.path, isImage: true),
  //     );
  //   }
  // }

  void _toggleEmojiPicker() {
    setState(() {
      _showEmojiPicker = !_showEmojiPicker;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ), // Change back button color to white
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            CircleAvatar(backgroundImage: NetworkImage(widget.profileImage)),
            SizedBox(width: 10),
            Text(widget.mate, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: BlocBuilder<ChatBloc, ChatState>(
                  builder: (context, state) {
                    if (state is ChatLoadingState) {
                      return Center(child: CircularProgressIndicator());
                    } else if (state is ChatLoadedState) {
                      return ListView.builder(
                        padding: EdgeInsets.all(20),
                        itemCount: state.messages.length,
                        itemBuilder: (context, index) {
                          final message = state.messages[index];
                          final isSentMessage = message.senderId == userId;
                          final isDailyQuestion = message.senderId == botId;

                          if (isSentMessage) {
                            return _buildSentMessage(
                              context,
                              message.content,
                              message.isImage,
                              message.status,
                            );
                          } else if (isDailyQuestion) {
                            return _buildDailyQuestionMessage(
                              context,
                              message.content,
                            );
                          } else {
                            return _buildReceivedMessage(
                              context,
                              message.content,
                              message.isImage,
                              message.status,
                            );
                          }
                        },
                      );
                    } else if (state is ChatErrorState) {
                      return Center(child: Text(state.message));
                    }
                    return Center(child: Text('No messages found.'));
                  },
                ),
              ),

              // Message Input Section
              _buildMessageInput(),

              // Emoji Picker
              if (_showEmojiPicker)
                SizedBox(
                  height: 250,
                  child: EmojiPicker(
                    onEmojiSelected: (category, emoji) {
                      _messageController.text += emoji.emoji;
                    },
                  ),
                ),
            ],
          ),

          // Floating Action Button Positioned at Top-Right
          Positioned(
            top: 15, // Adjust for padding
            right: 15, // Adjust for padding
            child: FloatingActionButton(
              onPressed: () async {
                if (_isFetching) {
                  print("Already fetching AI message, skipping request.");
                  return; // ✅ Prevent multiple requests
                }

                setState(
                  () => _isFetching = true,
                ); // ✅ Disable button during fetch
                print("Fetching AI daily question...");

                try {
                  final response = await http.get(
                    Uri.parse(
                      'http://192.168.33.126:4000/conversations/${widget.conversationId}/daily-question',
                    ),
                  );

                  if (response.statusCode == 200) {
                    final data = json.decode(response.body);
                    String aiMessage = data['question'];
                    print("AI Response: $aiMessage");

                    if (aiMessage.isNotEmpty) {
                      // ✅ Ensure no duplicate AI message is added
                      final chatState =
                          BlocProvider.of<ChatBloc>(context).state;
                      if (chatState is ChatLoadedState &&
                          chatState.messages.any(
                            (msg) => msg.content == aiMessage,
                          )) {
                        print("Duplicate AI message detected, skipping...");
                      } else {
                        BlocProvider.of<ChatBloc>(context).add(
                          SendMessageEvent(widget.conversationId, aiMessage),
                        );
                      }
                    }
                  } else {
                    print(
                      "Failed to fetch AI message, Status: ${response.statusCode}",
                    );
                  }
                } catch (e) {
                  print("Error fetching AI message: $e");
                } finally {
                  setState(() => _isFetching = false); // ✅ Re-enable button
                }
              },

              backgroundColor: DefaultColors.buttonColor,
              child: Icon(
                Icons.smart_toy,
                color: Colors.white70,
              ), // ✅ AI Bot Icon
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceivedMessage(
    BuildContext context,
    String message,
    bool isImage,
    String status,
  ) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(right: 30, top: 5, bottom: 5),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 69, 128, 21),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isImage
                ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    File(message),
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                )
                : Text(message, style: Theme.of(context).textTheme.bodyMedium),
            SizedBox(height: 3),
            if (status == 'read')
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.visibility,
                    size: 14,
                    color: Colors.blue,
                  ), // "Seen" icon
                  SizedBox(width: 3),
                  Text(
                    "Seen",
                    style: TextStyle(color: Colors.blue, fontSize: 12),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSentMessage(
    BuildContext context,
    String message,
    bool isImage,
    String status,
  ) {
    Color tickColor = Theme.of(context).primaryColor; // ✅ Use Theme color

    // ✅ Determine which tick to show with theme color
    Icon tickIcon;
    if (status == 'sent') {
      tickIcon = Icon(Icons.check, color: tickColor); // Single tick
    } else if (status == 'delivered') {
      tickIcon = Icon(Icons.done_all, color: tickColor); // Double tick
    } else if (status == 'read') {
      tickIcon = Icon(
        Icons.done_all,
        color: const Color.fromARGB(255, 0, 0, 0),
      ); // Blue tick remains blue
    } else {
      tickIcon = Icon(Icons.access_time, color: AppTheme.darkTheme.scaffoldBackgroundColor); // Pending
    }

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.only(right: 10, top: 5, bottom: 5, left: 50),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 114, 140, 212),
          borderRadius: BorderRadius.circular(15),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child:
                  isImage
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          File(message),
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      )
                      : Text(
                        message,
                        style: Theme.of(context).textTheme.bodyMedium,
                        softWrap: true,
                      ),
            ),
            SizedBox(width: 5),
            tickIcon, // ✅ Show tick with theme color
          ],
        ),
      ),
    );
  }

  Widget _buildDailyQuestionMessage(BuildContext context, String message) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: DefaultColors.dailyQuestionColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          "🧠 Daily Question: $message",
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
        ),
      ),
    );
  }

  bool _isEmojiPickerVisible = false; // Add this to your _ChatPageState class

  Widget _buildMessageInput() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: DefaultColors.sentMessageInput,
            borderRadius: BorderRadius.circular(25),
          ),
          margin: EdgeInsets.all(10),
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            children: [
              GestureDetector(
                onTap: _openCamera,
                child: Icon(
                  Icons.camera_alt,
                  color: Colors.grey,
                ), // ✅ Open camera
              ),
              SizedBox(width: 10),
              GestureDetector(
                onTap: _toggleEmojiPicker,
                child: Icon(
                  Icons.emoji_emotions,
                  color: Colors.grey,
                ), // ✅ Toggle emoji picker
              ),
              SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: "Message",
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                  ),
                  style: TextStyle(color: Colors.white),
                  onTap: () {
                    if (_isEmojiPickerVisible) {
                      setState(() {
                        _isEmojiPickerVisible = false;
                      });
                    }
                  },
                ),
              ),
              SizedBox(width: 10),
              GestureDetector(
                onTap: () => _sendMessage(),
                child: Icon(Icons.send, color: Colors.grey),
              ),
            ],
          ),
        ),
        _isEmojiPickerVisible
            ? SizedBox(
              height: 250,
              child: EmojiPicker(
                onEmojiSelected: (category, emoji) {
                  _messageController.text += emoji.emoji;
                },
              ),
            )
            : SizedBox.shrink(), // Hide emoji picker when not needed
      ],
    );
  }
}
