import 'package:email_validator/email_validator.dart';
import 'package:fire/main.dart';
import 'package:fire/screens/forgot_password_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignInScreen extends StatefulWidget {
  final Function() onClickedSignUp;
  const SignInScreen({super.key, required this.onClickedSignUp});

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
      resizeToAvoidBottomInset: false,
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
                  // flutter image
                  const FlutterLogo(
                    size: 120,
                  ),
                  const Gap(24),

                  // email input
                  TextFormField(
                    controller: email,
                    decoration: const InputDecoration(
                      hintText: 'example@gmail.com',
                      border: OutlineInputBorder(),
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (email) =>
                        email != null && !EmailValidator.validate(email)
                            ? 'Enter a valid email'
                            : null,
                  ),
                  const Gap(24),

                  // password input
                  TextFormField(
                    controller: password,
                    decoration: const InputDecoration(
                      hintText: 'password',
                      border: OutlineInputBorder(),
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (passcode) =>
                        passcode != null && passcode.length < 6
                            ? 'Password must be at least 6 character'
                            : null,
                  ),
                  const Gap(32),

                  // sign in button
                  ElevatedButton(
                    onPressed: signIn,
                    child: const Text('SIGNIN'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const Gap(24),

                  // forgot password button
                  Align(
                      child: TextButton(onPressed: (){navigatorKey.currentState!.push(MaterialPageRoute(builder: (context) => ForgotPasswordScreen(),));}, child: const Text('Forgot Password'),style: TextButton.styleFrom(foregroundColor: Colors.blue),)),

                  // no account sign in button
                  Align(
                    child: RichText(text: TextSpan(
                      text: 'No account?  ',
                      style: const TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: 'sign up',
                          style: const TextStyle(decoration: TextDecoration.underline,color: Colors.blue),
                          recognizer: TapGestureRecognizer()..onTap = widget.onClickedSignUp
                        )
                      ]
                    )),
                  ),

                  // google sign in button
                  Gap(12),
                  ElevatedButton.icon(
                    onPressed: signInWithGoogle,
                    icon: Image.network('https://reputationup.com/wp-content/uploads/2021/07/google-web-reputation-2022-1-1024x1024.png',height: 64,width: 64,),
                    label: Text('Sign in with Google'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white70,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                    ),
                  )
                ],
              ),
            )),
      ),
    );
  }

  Future signInWithGoogle()async{
    try{
      final gSignIn = GoogleSignIn();
      final user = await gSignIn.signIn();
      if (user == null) return;
      final gAuth = await user.authentication;
      final credential = GoogleAuthProvider.credential(
          accessToken: gAuth.accessToken, idToken: gAuth.idToken);

      return await FirebaseAuth.instance.signInWithCredential(credential);
    }catch(e){
      print(e.toString());
    }
  }

  Future signIn() async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Container(
        color: const Color(0xFFF0FDF4).withOpacity(0.3),
        child: const Center(
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
        await FirebaseAuth.instance.signInWithEmailAndPassword(
           email: email.text.trim(), password: password.text.trim());
     } on FirebaseAuthException catch (e) {
       print(e.toString());
       final snackBar = SnackBar(content: Text(e.message!));
       ScaffoldMessenger.of(context).showSnackBar(snackBar);
     }

     navigatorKey.currentState!.popUntil(
       (route) => route.isFirst,
     );
  }
}
