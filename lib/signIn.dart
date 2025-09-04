import 'package:classcentral/homeScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  Future<User?> _googleSignUp() async {
    try {
      final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
      final FirebaseAuth _auth = FirebaseAuth.instance;

      print("Signing out existing Google user...");
      await _googleSignIn.signOut();

      print("Attempting Google sign-in...");
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print("Sign-in aborted by user.");
        return null;
      }

      print("Google user retrieved: ${googleUser.email}");
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      print("Creating Firebase credential...");
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print("Signing in with Firebase...");
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // Log the userCredential object for debugging
      print("UserCredential: $userCredential");

      final User? user = userCredential.user;

      if (user != null) {
        print(
            "Signed in successfully! User: ${user.displayName}, Email: ${user.email}");
      } else {
        print("Error: Firebase User is null!");
      }
      return user;
    } catch (e) {
      print("Error during Google Sign-In: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage('assets/background.png'),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 400,
              width: double.infinity,
              // color: Colors.red,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('Sing in to continue'),
                  Text(
                    'Class Central',
                    style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          BoxShadow(
                            blurRadius: 5,
                            color: Colors.green.shade900.withOpacity(0.8),
                            offset: Offset(3, 3),
                          ),
                          BoxShadow(
                            blurRadius: 5,
                            color: Colors.green.shade900.withOpacity(0.8),
                            offset: Offset(-3, 3),
                          ),
                        ]),
                  ),
                  Column(
                    children: [
                      SignInButton(
                        Buttons.Apple,
                        text: 'Sign in with Apple',
                        onPressed: () {},
                      ),
                      SignInButton(
                        Buttons.Google,
                        text: 'Sign in with Google',
                        onPressed: () {
                          _googleSignUp().then(
                            (value) => Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => homeScreen(),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        'By siging in you are agreeing to our',
                        style: TextStyle(
                          color: Colors.grey.shade800,
                        ),
                      ),
                      Text(
                        'Terms and Privacy Policy',
                        style: TextStyle(color: Colors.grey.shade800),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
