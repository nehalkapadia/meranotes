import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meranotes/constants/routes.dart';
import 'package:meranotes/constants/messages.dart';
import 'package:meranotes/services/auth/auth_service.dart';
import 'package:meranotes/services/auth/bloc/auth_bloc.dart';
import 'package:meranotes/services/auth/bloc/auth_event.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({Key? key}) : super(key: key);

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(verifyEmailAddressTitle)),
      body: Column(
        children: [
          const Text(emailVerificationSentMessage),
          const Text(emailVerificationNotSetMessage),
          TextButton(
            onPressed: () {
              context
                  .read<AuthBloc>()
                  .add(const AuthEventSendEmailVerification());
            },
            child: const Text(sendEmailVerificationButtonText),
          ),
          TextButton(
            onPressed: () async {
              context.read<AuthBloc>().add(const AuthEventLogout());
            },
            child: const Text('Restart'),
          ),
        ],
      ),
    );
  }
}
