import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meranotes/constants/routes.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({Key? key}) : super(key: key);

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email Address')),
      body: Column(
        children: [
          const Text(
              "We've already sent you an email for verification. Please open it & click the verification link to verify your account."),
          const Text(
              "If you haven't received the verification email yet, press the button below!"),
          TextButton(
            onPressed: () async {
              final currentUser = FirebaseAuth.instance.currentUser;
              await currentUser?.sendEmailVerification();
            },
            child: const Text('Send email for verification.'),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushNamedAndRemoveUntil(
                registerRoute,
                (route) => false,
              );
            },
            child: const Text('Restart'),
          ),
        ],
      ),
    );
  }
}
