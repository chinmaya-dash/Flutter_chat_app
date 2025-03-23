import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:chatshare/core/splash_screen.dart';
import 'package:chatshare/core/socket_service.dart';
import 'package:chatshare/di_container.dart';
import 'package:chatshare/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:chatshare/core/theme.dart';
import 'package:chatshare/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chatshare/features/auth/presentation/pages/login_page.dart';
import 'package:chatshare/features/auth/presentation/pages/register_page.dart';
import 'package:chatshare/features/conversation/presentation/pages/conversations_page.dart';
import 'package:chatshare/features/contacts/presentation/bloc/contacts_bloc.dart';
import 'package:chatshare/features/conversation/presentation/bloc/conversations_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final socketService = SocketService();
  await socketService.initSocket();

  // Setting up dependencies
  setupDependencies();

  // Check if user is logged in
  final storage = FlutterSecureStorage();
  String? token = await storage.read(key: "auth_token");

  runApp(MyApp(isLoggedIn: token != null)); // Pass login state
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(
            registerUseCase: sl(),
            loginUseCase: sl(),
          ),
        ),
        BlocProvider(
          create: (_) => ConversationsBloc(
            fetchConversationsUseCase: sl(),
          ),
        ),
        BlocProvider(
          create: (_) => ChatBloc(
            fetchMessagesUseCase: sl(),
            fetchDailyQuestionUseCase: sl(),
          ),
        ),
        BlocProvider(
          create: (_) => ContactsBloc(
            fetchContactsUseCase: sl(),
            addContactUseCase: sl(),
            checkOrCreateConversationUseCase: sl(),
            fetchRecentContactUseCase: sl(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Chat Share',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: isLoggedIn ? '/conversationPage' : '/', // Redirect based on login status
        routes: {
          '/': (context) => SplashScreen(),
          '/login': (context) => LoginPage(),
          '/register': (context) => RegisterPage(),
          '/conversationPage': (context) => ConversationsPage(),
        },
      ),
    );
  }
}
