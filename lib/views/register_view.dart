import 'package:flutter/material.dart';
import 'package:meranotes/constants/messages.dart';
import 'package:meranotes/constants/routes.dart';
import 'package:meranotes/services/auth/auth_exceptions.dart';
import 'package:meranotes/services/auth/bloc/auth_bloc.dart';
import 'package:meranotes/services/auth/bloc/auth_event.dart';
import 'package:meranotes/services/auth/bloc/auth_state.dart';
import 'package:meranotes/utilities/dialog/error_dialog.dart';
// import 'package:meranotes/utilities/dialog/loading_dialog.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  // CloseDialog? _closeDialog;

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
        if (state is AuthStateRegistering) {
          if (state.exception is WeakPasswordAuthException) {
            await showErrorDialog(context, weakPasswordMessage);
          } else if (state.exception is EmailAlreadyInUseAuthException) {
            await showErrorDialog(context, emailIdAlreadyExistsMessage);
          } else if (state.exception is InvalidEmailAuthException) {
            await showErrorDialog(context, invalidEmailIdMessage);
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(context, genericRegistrationMessage);
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text(registerButtonTitle)),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _email,
                  enableSuggestions: false,
                  autocorrect: false,
                  autofocus: true,
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
                Center(
                  child: Column(
                    children: [
                      TextButton(
                        onPressed: () async {
                          final email = _email.text;
                          final password = _password.text;

                          context.read<AuthBloc>().add(
                                AuthEventRegister(
                                  email,
                                  password,
                                ),
                              );
                        },
                        child: const Text(registerButtonTitle),
                      ),
                      TextButton(
                        onPressed: () {
                          context.read<AuthBloc>().add(
                                const AuthEventLogout(),
                              );
                        },
                        child: const Text(alreadyUserButtonText),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
