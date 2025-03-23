import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chatshare/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chatshare/features/auth/presentation/bloc/auth_event.dart';
import 'package:chatshare/features/auth/presentation/bloc/auth_state.dart';
import 'package:chatshare/features/auth/presentation/widgets/auth_button.dart';
import 'package:chatshare/features/auth/presentation/widgets/auth_input_field.dart';
import 'package:chatshare/features/auth/presentation/widgets/login_prompt.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    BlocProvider.of<AuthBloc>(context).add(
      LoginEvent(
        email: _emailController.text,
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true, 
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (ModalRoute.of(context)?.settings.name == '/login') {
            SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: SvgPicture.asset(
                    'lib/assets/images/chatshare_logo.svg',
                    height: 160,
                    width: 160,
                  ),
                ),
                const SizedBox(height: 20),
                AuthInputField(
                  hint: 'Email',
                  icon: Icons.email,
                  controller: _emailController,
                ),
                const SizedBox(height: 20),
                AuthInputField(
                  hint: 'Password',
                  icon: Icons.lock,
                  controller: _passwordController,
                  isPassword: true,
                ),
                const SizedBox(height: 20),
                BlocConsumer<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is AuthLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return AuthButton(text: 'Login', onPressed: _onLogin);
                  },
                  listener: (context, state) {
                    if (state is AuthSuccess) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/conversationPage',
                        (route) => false,
                      );
                    } else if (state is AuthFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.error)),
                      );
                    }
                  },
                ),
                const SizedBox(height: 20),
                LoginPrompt(
                  title: "Don't have an account? ",
                  subtitle: 'Click here to register',
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/register');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
