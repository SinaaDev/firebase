import 'package:email_validator/email_validator.dart';
import 'package:fire/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FlutterLogo(
                    size: 120,
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
                  Gap(32),
                  ElevatedButton(
                    onPressed: signIn,
                    child: Text('SIGNIN'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  )
                ],
              ),
            )),
      ),
    );
  }

  Future signIn() async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    print('----------------------------------------------------------------');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );
    print('----------------------------------------------------------------');

    try {
    print('----------------------------------------------------------------');
   await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.text.trim(), password: password.text.trim());
      // print(response.user!.email);
    print('----------------------------------------------------------------');
    } on FirebaseAuthException catch (e) {
      print(e.toString());
    }

    navigatorKey.currentState!.popUntil(
      (route) => route.isFirst,
    );
  }
}
