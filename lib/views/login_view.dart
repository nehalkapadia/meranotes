import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meranotes/constants/routes.dart';
import 'package:meranotes/constants/messages.dart';
import 'package:meranotes/services/auth/bloc/auth_bloc.dart';
import 'package:meranotes/services/auth/auth_exceptions.dart';
import 'package:meranotes/services/auth/bloc/auth_event.dart';
import 'package:meranotes/utilities/dialog/error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(loginButtonTitle)),
      body: Column(
        children: [
          TextField(
            controller: _email,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(hintText: hintEmailText),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(hintText: hintPasswordText),
          ),
          TextButton(
            onPressed: () async {
              final email = _email.text;
              final password = _password.text;

              try {
                context.read<AuthBloc>().add(AuthEventLogin(
                      email,
                      password,
                    ));
              } on UserNotFoundAuthException {
                await showErrorDialog(
                  context,
                  userNotFoundMessage,
                );
              } on WrongPasswordAuthException {
                await showErrorDialog(
                  context,
                  wrongCredentialsMessage,
                );
              } on GenericAuthException {
                await showErrorDialog(
                  context,
                  generalLoginMessage,
                );
              }
            },
            child: const Text(loginButtonTitle),
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  registerRoute,
                  (route) => false,
                );
              },
              child: const Text(notRegisteredButtonText))
        ],
      ),
    );
  }
}
