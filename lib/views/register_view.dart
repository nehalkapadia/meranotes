import 'package:flutter/material.dart';
import 'package:meranotes/constants/messages.dart';
import 'package:meranotes/constants/routes.dart';
import 'package:meranotes/services/auth/auth_exceptions.dart';
import 'package:meranotes/services/auth/auth_service.dart';
import 'package:meranotes/utilities/dialog/error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
      appBar: AppBar(title: const Text(registerButtonTitle)),
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
                await AuthService.firebase().createUser(
                  email: email,
                  password: password,
                );

                await AuthService.firebase().sendEmailVerification();

                Navigator.of(context).pushNamed(verifyEmailRoute);
              } on WeakPasswordAuthException {
                await showErrorDialog(
                  context,
                  weakPasswordMessage,
                );
              } on EmailAlreadyInUseAuthException {
                await showErrorDialog(
                  context,
                  emailIdAlreadyExistsMessage,
                );
              } on InvalidEmailAuthException {
                await showErrorDialog(
                  context,
                  invalidEmailIdMessage,
                );
              } on GenericAuthException {
                await showErrorDialog(
                  context,
                  genericRegistrationMessage,
                );
              }
            },
            child: const Text(registerButtonTitle),
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  loginRoute,
                  (route) => false,
                );
              },
              child: const Text(alreadyUserButtonText))
        ],
      ),
    );
  }
}
