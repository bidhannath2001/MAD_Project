
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/utils/validators.dart';
import '../core/widgets/app_primary_button.dart';
import '../core/widgets/app_text_field.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/auth/screens/signup_screen.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true; // Controls password visibility

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    Future<void> _submit() async {
      if (!_formKey.currentState!.validate()) return;
      await context
          .read<AuthProvider>()
          .signInWithEmailPassword(_emailController.text.trim(), _passwordController.text);
      if (auth.status == AuthStatus.error && auth.errorMessage != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(auth.errorMessage!)),
        );
      }
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/R.jpeg'), 
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 400,
              width: double.infinity,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Text(
                      'Class Central',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: [
                          AppTextField(
                            controller: _emailController,
                            label: 'Email',
                            hint: 'Enter your email',
                            keyboardType: TextInputType.emailAddress,
                            validator: Validators.email,
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            controller: _passwordController,
                            label: 'Password',
                            hint: 'Enter your password',
                            obscureText: _obscurePassword,
                            validator: Validators.password,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          AppPrimaryButton(
                            label: 'Login',
                            isLoading: auth.status == AuthStatus.loading,
                            onPressed: _submit,
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const ForgotPasswordScreen(),
                                  ),
                                );
                              },
                              child: const Text('Forgot password?'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignupScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'You don\'t have an account? Register here',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
