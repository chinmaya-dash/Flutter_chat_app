import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;
  late Animation<double> _scaleAnimation;
  late AnimationController _textController;
  late Animation<Offset> _developedByAnimation;
  late Animation<Offset> _chinmayaDashAnimation;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3, milliseconds: 500), // 2.5 sec bounce
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Text animation duration
    );

    // Bounce Animation (Falls from top and bounces once)
    _bounceAnimation = TweenSequence([
      TweenSequenceItem(
          tween: Tween<double>(begin: -500, end: 0).chain(CurveTween(curve: Curves.easeIn)), weight: 2),
      TweenSequenceItem(
          tween: Tween<double>(begin: 0, end: -200).chain(CurveTween(curve: Curves.easeOut)), weight: 1),
      TweenSequenceItem(
          tween: Tween<double>(begin: -200, end: 80).chain(CurveTween(curve: Curves.bounceOut)), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    // Scale Animation (Logo scales up while bouncing)
    _scaleAnimation = Tween<double>(begin: 0.5, end: 2).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // "Developed By" moves from left
    _developedByAnimation = Tween<Offset>(
      begin: const Offset(-8, 0),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeInOut));

    // "Chinmaya Dash" moves from right
    _chinmayaDashAnimation = Tween<Offset>(
      begin: const Offset(8, 0),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeInOut));

    _controller.forward();

    // Start text animation after 1 second
    Future.delayed(const Duration(seconds: 1), () {
      _textController.forward();
    });

    // Ensure navigation after splash screen
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _checkTokenAndNavigate(); // Navigate based on token
      }
    });
  }

  // Function to check if the user is logged in
  Future<void> _checkTokenAndNavigate() async {
    String? token = await _storage.read(key: 'token');

    if (token != null && token.isNotEmpty) {
      // User is logged in, go to ConversationsPage
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/conversationPage');
      }
    } else {
      // No token found, go to LoginPage
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF31372D), // Dark background
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Bouncing Logo
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Positioned(
                top: MediaQuery.of(context).size.height / 4, // Start in the top center
                child: Transform.translate(
                  offset: Offset(0, _bounceAnimation.value),
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: SvgPicture.asset(
                      'lib/assets/images/chatshare_logo.svg',
                      height: 160,
                      width: 160,
                    ),
                  ),
                ),
              );
            },
          ),

          // "Developed By" text animation
          Positioned(
            bottom: 100,
            child: AnimatedBuilder(
              animation: _textController,
              builder: (context, child) {
                return SlideTransition(
                  position: _developedByAnimation,
                  child: const Text(
                    "Developed By",
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                );
              },
            ),
          ),

          // "Chinmaya Dash" text animation
          Positioned(
            bottom: 70,
            child: AnimatedBuilder(
              animation: _textController,
              builder: (context, child) {
                return SlideTransition(
                  position: _chinmayaDashAnimation,
                  child: const Text(
                    "Chinmaya Dash",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
