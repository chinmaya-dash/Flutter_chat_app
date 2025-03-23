// ignore_for_file: avoid_print
import 'dart:convert';

import 'package:chatshare/features/profile/page/profile_page.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chatshare/core/theme.dart';
import 'package:chatshare/features/chat/presentation/pages/chat_page.dart';
import 'package:chatshare/features/contacts/presentation/bloc/contacts_bloc.dart';
import 'package:chatshare/features/contacts/presentation/bloc/contacts_event.dart';
import 'package:chatshare/features/contacts/presentation/bloc/contacts_state.dart';
import 'package:chatshare/features/contacts/presentation/pages/contacts_page.dart';
import 'package:chatshare/features/conversation/presentation/bloc/conversations_bloc.dart';
import 'package:chatshare/features/conversation/presentation/bloc/conversations_event.dart';
import 'package:chatshare/features/conversation/presentation/bloc/conversations_state.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io'; // Import this for exiting the app

final _storage = FlutterSecureStorage(); // Secure storage instance

class ConversationsPage extends StatefulWidget {
  const ConversationsPage({super.key});

  @override
  State<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
  @override
  void initState() {
    super.initState();
    fetchLoggedInUser(); // Fetch user data when opening the app
    BlocProvider.of<ConversationsBloc>(context).add(FetchConversations());
    BlocProvider.of<ContactsBloc>(context).add(LoadRecentContacts());
  }

  String formatLastMessageTime(String timestamp) {
    DateTime dateTime = DateTime.parse(timestamp).toLocal();
    String formattedTime = DateFormat('EEEE hh:mm a').format(dateTime);
    return formattedTime;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ChatShare', style: Theme.of(context).textTheme.titleLarge),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 70,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
            icon: Icon(Icons.person, color: Colors.white),
          ),

          PopupMenuButton<String>(
            icon: Icon(Icons.menu, color: Colors.white),
            color: Color(0xFF31372d), // Dark theme background
            onSelected: (value) {
              if (value == 'logout') {
                _showLogoutDialog(context); // Show logout popup
              } else if (value == 'quit') {
                exit(0); // Quit the app
              }
            },
            itemBuilder:
                (BuildContext context) => [
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.white),
                        SizedBox(width: 10),
                        Text('Logout', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'quit',
                    child: Row(
                      children: [
                        Icon(Icons.exit_to_app, color: Colors.white),
                        SizedBox(width: 10),
                        Text('Quit App', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Text('Recent', style: Theme.of(context).textTheme.bodySmall),
          ),

          BlocBuilder<ContactsBloc, ContactsState>(
            builder: (context, state) {
              if (state is RecentContactsLoaded) {
                return Container(
                  height: 100,
                  padding: EdgeInsets.all(5),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemCount: state.recentContacts.length,
                    itemBuilder: (context, index) {
                      final contact = state.recentContacts[index];
                      return _buildRecentContact(
                        contact.username,
                        contact.profileImage,
                        context,
                      );
                    },
                  ),
                );
              } else if (state is ConversationsLoading) {
                return Center(child: CircularProgressIndicator());
              }
              return Center(child: Text('No recent contacts found'));
            },
          ),

          SizedBox(height: 10),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: DefaultColors.messageListPage,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),

              child: BlocBuilder<ConversationsBloc, ConversationsState>(
                builder: (context, state) {
                  if (state is ConversationsLoading) {
                    return Center(child: CircularProgressIndicator());
                  } else if (state is ConversationsLoaded) {
                    return ListView.builder(
                      itemCount: state.conversations.length,
                      itemBuilder: (context, index) {
                        final conversation = state.conversations[index];
                        print(
                          'conversation.participantImage : ${conversation.participantImage}',
                        );
                        return GestureDetector(
                          onTap: () async {
                            final storage = FlutterSecureStorage();
                            String? userId =
                                await storage.read(key: 'userId') ??
                                ''; // ✅ Ensure `userId` is fetched first

                            if (userId.isNotEmpty) {
                              // ✅ Ensure userId is available
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ChatPage(
                                        conversationId: conversation.id,
                                        mate: conversation.participantName,
                                        profileImage:
                                            conversation.participantImage,
                                        currentUserId:
                                            userId, // ✅ Pass `currentUserId`
                                      ),
                                ),
                              );
                            } else {
                              print("User ID not found!");
                            }
                          },

                          child: _buildMessageTile(
                            conversation.participantName,
                            conversation.participantImage,
                            conversation.lastMessage,
                            formatLastMessageTime(
                              conversation.lastMessageTime.toString(),
                            ),
                          ),
                        );
                      },
                    );
                  } else if (state is ConversationsError) {
                    return Center(child: Text(state.message));
                  }
                  return Center(child: Text('No conversations found'));
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final contactsBloc = BlocProvider.of<ContactsBloc>(context);

          var res = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ContactsPage()),
          );
          if (res == null) {
            contactsBloc.add(LoadRecentContacts());
          }
        },
        backgroundColor: DefaultColors.buttonColor,
        child: Icon(Icons.contacts, color: Colors.white),
      ),
    );
  }

  Widget _buildMessageTile(
    String name,
    String image,
    String message,
    String time,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      leading: CircleAvatar(radius: 30, backgroundImage: NetworkImage(image)),
      title: Text(
        name,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        message,
        style: TextStyle(color: Colors.grey),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(time, style: TextStyle(color: Colors.grey)),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF31372d), // Set background color
          title: Text(
            "Logout",
            style: TextStyle(color: Colors.white), // White text for title
          ),
          content: Text(
            "Do you really want to logout?",
            style: TextStyle(color: Colors.white70), // Greyish text for content
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey, // Cancel button color
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel", style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: DefaultColors.buttonColor, // Yes button color
              ),
              onPressed: () async {
                await _storage.delete(
                  key: 'token',
                ); // Remove authentication token
                // ignore: use_build_context_synchronously
                Navigator.pushReplacementNamed(
                  // ignore: use_build_context_synchronously
                  context,
                  '/login',
                ); // Redirect to login page
              },
              child: Text("Yes", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> fetchLoggedInUser() async {
    String? token = await _storage.read(
      key: 'token',
    ); // Retrieve authentication token

    // ✅ Debug: Print the token
    print('Retrieved Token: $token');

    if (token != null) {
      try {
        final response = await http.get(
          Uri.parse('http://192.168.33.126:4000/profile'),
          headers: {'Authorization': 'Bearer $token'},
        );

        // ✅ Debug: Print the response status code and body
        print('Response Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          await _storage.write(key: 'username', value: data['username']);
          await _storage.write(key: 'email', value: data['email']);
          await _storage.write(
            key: 'profileImage',
            value: data['profile_image'],
          ); // ✅ Fix: Use correct key
          await _storage.write(key: 'password', value: data['password']);
        } else {
          print('Failed to fetch user data: ${response.reasonPhrase}');
        }
      } catch (e) {
        print('Error fetching user data: $e');
      }
    } else {
      print('No token found in storage');
    }
  }

  Widget _buildRecentContact(
    String name,
    String profileImage,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          CircleAvatar(radius: 30, backgroundImage: NetworkImage(profileImage)),
          SizedBox(height: 5),
          Text(name, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
