import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meranotes/constants/routes.dart';
import 'package:meranotes/helpers/loading/loading_screen.dart';
import 'package:meranotes/views/forgot_password_view.dart';
import 'package:meranotes/views/login_view.dart';
import 'package:meranotes/views/verify_email.dart';
import 'package:meranotes/views/register_view.dart';
import 'package:meranotes/views/notes/notes_view.dart';
import 'package:meranotes/services/auth/bloc/auth_bloc.dart';
import 'package:meranotes/services/auth/bloc/auth_event.dart';
import 'package:meranotes/services/auth/bloc/auth_state.dart';
import 'package:meranotes/views/notes/add_update_note_view.dart';
import 'package:meranotes/services/auth/firebase_auth_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(FirebaseAuthProvider()),
        child: HomePage(),
      ),
      routes: {
        addUpdateNoteRoute: (context) => const AddUpdateNoteView(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.isLoading) {
          LoadingScreenClass().show(
            context: context,
            text: state.loadingText ?? "Please wait a moment..",
          );
        } else {
          LoadingScreenClass().hide();
        }
      },
      builder: (context, state) {
        if (state is AuthStateLogin) {
          return const NotesView();
        } else if (state is AuthStateNeedsVerification) {
          return const VerifyEmailView();
        } else if (state is AuthStateLogout) {
          return const LoginView();
        } else if (state is AuthStateForgotPassword) {
          return const ForgotPasswordView();
        } else if (state is AuthStateRegistering) {
          return const RegisterView();
        } else {
          return const Scaffold(
            body: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
