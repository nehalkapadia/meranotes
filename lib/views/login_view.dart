import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meranotes/constants/routes.dart';
import 'package:meranotes/constants/messages.dart';
import 'package:meranotes/services/auth/bloc/auth_bloc.dart';
import 'package:meranotes/services/auth/auth_exceptions.dart';
import 'package:meranotes/services/auth/bloc/auth_event.dart';
import 'package:meranotes/services/auth/bloc/auth_state.dart';
import 'package:meranotes/utilities/dialog/error_dialog.dart';
import 'package:meranotes/utilities/dialog/loading_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  CloseDialog? _closeDialog;

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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateLogout) {
          final closeDialog = _closeDialog;

          if (!state.isLoading && closeDialog != null) {
            closeDialog();
            _closeDialog = null;
          } else if (state.isLoading && closeDialog == null) {
            _closeDialog = showLoadingDialog(
              context: context,
              text: 'Loading...',
            );
          }

          if (state.exception is UserNotFoundAuthException) {
            showErrorDialog(context, 'User not found!');
          } else if (state.exception is WrongPasswordAuthException) {
            showErrorDialog(context, 'Wrong Credentials!');
          } else if (state.exception is GenericAuthException) {
            showErrorDialog(context, 'Authentication Error!');
          }
        }
      },
      child: Scaffold(
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
                context.read<AuthBloc>().add(
                      AuthEventLogin(
                        email,
                        password,
                      ),
                    );
              },
              child: const Text(loginButtonTitle),
            ),
            TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(
                        const AuthEventShouldRegister(),
                      );
                },
                child: const Text(notRegisteredButtonText))
          ],
        ),
      ),
    );
  }
}
