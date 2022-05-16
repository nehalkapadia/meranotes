// import 'package:flutter/material.dart';
// import 'package:meranotes/constants/routes.dart';
// import 'package:meranotes/services/auth/auth_service.dart';
// import 'package:meranotes/views/notes/add_update_note_view.dart';
// import 'package:meranotes/views/notes/notes_view.dart';
// import 'package:meranotes/views/verify_email.dart';
// import 'package:meranotes/views/login_view.dart';
// import 'package:meranotes/views/register_view.dart';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();

//   runApp(
//     MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const HomePage(),
//       routes: {
//         loginRoute: (context) => const LoginView(),
//         registerRoute: (context) => const RegisterView(),
//         notesRoute: (context) => const NotesView(),
//         verifyEmailRoute: (context) => const VerifyEmailView(),
//         addUpdateNoteRoute: (context) => const AddUpdateNoteView(),
//       },
//     ),
//   );
// }

// class HomePage extends StatelessWidget {
//   const HomePage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       future: AuthService.firebase().initialize(),
//       builder: (context, snapshot) {
//         switch (snapshot.connectionState) {
//           case ConnectionState.done:
//             final currentUser = AuthService.firebase().currentUser;
//             if (currentUser != null) {
//               if (currentUser.isEmailVerified) {
//                 return const NotesView();
//               }

//               return const VerifyEmailView();
//             }

//             return const LoginView();
//           default:
//             return const CircularProgressIndicator();
//         }
//       },
//     );
//   }
// }

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CounterBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Testing Bloc'),
        ),
        body: BlocConsumer<CounterBloc, CounterState>(
          listener: (context, state) {
            _controller.clear();
          },
          builder: (context, state) {
            final invalidValue =
                (state is CounterStateInvalid) ? state.invalidValue : '';

            return Column(
              children: [
                Text('Current value => ${state.value}'),
                Visibility(
                  child: Text('Invalid Input: $invalidValue'),
                  visible: state is CounterStateInvalid,
                ),
                TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Enter a number here...',
                  ),
                  keyboardType: TextInputType.number,
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        context
                            .read<CounterBloc>()
                            .add(DecrementValue(_controller.text));
                      },
                      child: const Text('-'),
                    ),
                    TextButton(
                      onPressed: () {
                        context
                            .read<CounterBloc>()
                            .add(IncrementValue(_controller.text));
                      },
                      child: const Text('+'),
                    ),
                  ],
                )
              ],
            );
          },
        ),
      ),
    );
  }
}

@immutable
abstract class CounterState {
  final int value;
  const CounterState(this.value);
}

class CounterStateValid extends CounterState {
  const CounterStateValid(int value) : super(value);
}

class CounterStateInvalid extends CounterState {
  final String invalidValue;

  const CounterStateInvalid({
    required this.invalidValue,
    required int previousValue,
  }) : super(previousValue);
}

@immutable
abstract class CounterEvent {
  final String value;
  const CounterEvent(this.value);
}

class IncrementValue extends CounterEvent {
  const IncrementValue(String value) : super(value);
}

class DecrementValue extends CounterEvent {
  const DecrementValue(String value) : super(value);
}

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(const CounterStateValid(0)) {
    on<IncrementValue>((event, emit) {
      final integer = int.tryParse(event.value);
      if (integer == null) {
        emit(
          CounterStateInvalid(
            invalidValue: event.value,
            previousValue: state.value,
          ),
        );
      } else {
        emit(CounterStateValid(state.value + integer));
      }
    });

    on<DecrementValue>((event, emit) {
      final integer = int.tryParse(event.value);
      if (integer == null) {
        emit(
          CounterStateInvalid(
            invalidValue: event.value,
            previousValue: state.value,
          ),
        );
      } else {
        emit(CounterStateValid(state.value - integer));
      }
    });
  }
}
