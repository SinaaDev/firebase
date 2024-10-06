import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../main.dart';

class SignupScreen extends StatefulWidget {
  final Function() onClickedSignIn;

  const SignupScreen({super.key, required this.onClickedSignIn});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    email.dispose();
    password.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Flexible(
                  child: FlutterLogo(
                    size: 120,
                  ),
                ),
                Gap(24),
                TextFormField(
                  controller: email,
                  decoration: InputDecoration(
                    hintText: 'example@gmail.com',
                    border: OutlineInputBorder(),
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (email) =>
                      email != null && !EmailValidator.validate(email)
                          ? 'Enter a valid email'
                          : null,
                ),
                Gap(24),
                TextFormField(
                  controller: password,
                  decoration: InputDecoration(
                    hintText: 'password',
                    border: OutlineInputBorder(),
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (passcode) =>
                      passcode != null && passcode.length < 6
                          ? 'Password must be at least 6 character'
                          : null,
                ),
                Gap(24),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Confirm password',
                    border: OutlineInputBorder(),
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (passcode) => passcode != password.text
                      ? 'Password does not match'
                      : null,
                ),
                Gap(32),
                ElevatedButton(
                  onPressed: signUp,
                  child: Text('SIGNIN'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                Gap(24),
                Align(
                  child: RichText(
                      text: TextSpan(
                          text: 'Already have an account?  ',
                          style: TextStyle(color: Colors.black),
                          children: [
                        TextSpan(
                            text: 'sign up',
                            style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: Colors.blue),
                            recognizer: TapGestureRecognizer()
                              ..onTap = widget.onClickedSignIn)
                      ])),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future signUp() async {
    final valid = formKey.currentState!.validate();
    if (!valid) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Container(
        color: Color(0xFFF0FDF4).withOpacity(0.3).withOpacity(0.2),
        child: Center(
          child: SizedBox(
            height: 50,
            width: 50,
            child: CircularProgressIndicator(
              color: Colors.blue,
              backgroundColor: Colors.white,
            ),
          ),
        ),
      ),
    );

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.text, password: password.text);
    } on FirebaseAuthException catch (e) {
      print(e.toString());
    }

    navigatorKey.currentState!.popUntil(
          (route) => route.isFirst,
    );
  }
}
