import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:monopoly_tracker/pages/games_screen.dart';
import 'package:monopoly_tracker/pages/selfie_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String errorMessage = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: EdgeInsets.all(50),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            SizedBox(height: 16),
            if (errorMessage.isNotEmpty)
              Text(errorMessage, style: TextStyle(color: Colors.red)),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                try {
                  final FirebaseAuth auth = FirebaseAuth.instance;
                  final UserCredential userCredential = await auth
                      .createUserWithEmailAndPassword(
                        email: _emailController.text.trim(),
                        password: _passwordController.text.trim(),
                      );
                  if (mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GamesScreen(),
                      ),
                    );
                  }
                } on FirebaseAuthException catch (signUpError) {
                  //errors
                  setState(() {
                    errorMessage = "An error occured";
                  });
                  if (signUpError.code == 'email-already-in-use') {
                    setState(() {
                      errorMessage = 'User found, signing in..';
                    });
                    try {
                      final FirebaseAuth auth = FirebaseAuth.instance;
                      final UserCredential userCredential = await auth
                          .signInWithEmailAndPassword(
                            email: _emailController.text.trim(),
                            password: _passwordController.text.trim(),
                          );
                      if (mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GamesScreen(),
                          ),
                        );
                      }
                    } on FirebaseAuthException catch (signInError) {
                      setState(() {
                        errorMessage = 'Sign in failed.';
                      });
                      if (signInError.code == 'user-not-found') {
                        setState(() {
                          errorMessage = 'No user found for that email.';
                        });
                      } else if (signInError.code == 'wrong-password') {
                        setState(() {
                          errorMessage =
                              'Wrong password provided for that user.';
                        });
                      }
                    } catch (e) {
                      setState(() {
                        errorMessage = 'Unexpected error';
                      });
                    }
                  } else {
                    setState(() {
                      errorMessage = 'Sign up failed.';
                    });
                    if (signUpError.code == 'weak-password') {
                      setState(() {
                        errorMessage = 'The password provided is too weak.';
                      });
                    } else {
                      setState(() {
                        errorMessage =
                            signUpError.message ??
                            'An error occurred during sign up.';
                      });
                    }
                  }
                } catch (e) {
                  setState(() {
                    errorMessage = 'Unexpected error';
                  });
                }
              },
              child: Text('Sign in'),
            ),
          ],
        ),
      ),
    );
  }
}
