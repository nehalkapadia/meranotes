import 'package:flutter/material.dart';
import 'package:meranotes/constants/routes.dart';
import 'package:meranotes/services/auth/auth_service.dart';
import 'package:meranotes/views/notes/add_note_view.dart';
import 'package:meranotes/views/notes/notes_view.dart';
import 'package:meranotes/views/verify_email.dart';
import 'package:meranotes/views/login_view.dart';
import 'package:meranotes/views/register_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        notesRoute: (context) => const NotesView(),
        verifyEmailRoute: (context) => const VerifyEmailView(),
        addNewNoteRoute: (context) => const AddNewNoteView(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.firebase().initialize(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final currentUser = AuthService.firebase().currentUser;
            if (currentUser != null) {
              if (currentUser.isEmailVerified) {
                return const NotesView();
              }

              return const VerifyEmailView();
            }

            return const LoginView();
          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}
