import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  static const String _serverClientId =
      '872870500181-49ofmjm2m0rmmt38iodsnb54rgblbgvv.apps.googleusercontent.com';

  Future<void> _handleGoogleSignIn() async {
    final auth = context.read<AuthProvider>();

    await auth.signInWithGoogle(
      serverClientId: _serverClientId,
    );

    if (!mounted) return;

    if (auth.status == AuthStatus.error && auth.errorMessage != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(auth.errorMessage!),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isLoading = auth.status == AuthStatus.loading;

    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [
            Colors.blueGrey,
            Colors.blue// Light Green
          ])
          // image: DecorationImage(
          //   fit: BoxFit.cover,
          //   image: AssetImage('assets/background.png'),
          // ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Sign in to continue',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Class Central',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        BoxShadow(
                          blurRadius: 5,
                          color: Colors.green.shade900.withOpacity(0.8),
                          offset: const Offset(3, 3),
                        ),
                        BoxShadow(
                          blurRadius: 5,
                          color: Colors.green.shade900.withOpacity(0.8),
                          offset: const Offset(-3, 3),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Column(
                    children: [
                      SignInButton(
                        Buttons.Apple,
                        text: 'Sign in with Apple',
                        onPressed: () {
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              const SnackBar(
                                content: Text('Apple sign-in is not implemented yet.'),
                              ),
                            );
                        },
                      ),
                      const SizedBox(height: 12),
                      isLoading
                          ? const CircularProgressIndicator()
                          : SignInButton(
                        Buttons.Google,
                        text: 'Sign in with Google',
                        onPressed: _handleGoogleSignIn,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'By signing in you are agreeing to our',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Terms and Privacy Policy',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade300,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}