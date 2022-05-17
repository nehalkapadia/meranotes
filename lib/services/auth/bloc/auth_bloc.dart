import 'package:bloc/bloc.dart';
import 'package:meranotes/services/auth/auth_provider.dart';
import 'package:meranotes/services/auth/bloc/auth_event.dart';
import 'package:meranotes/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider) : super(const AuthStateLoading()) {
    // initialize
    on<AuthEventInitialize>((event, emit) async {
      await provider.initialize();
      final user = provider.currentUser;
      if (user == null) {
        emit(const AuthStateLogout());
      } else if (!user.isEmailVerified) {
        emit(const AuthStateNeedsVerification());
      } else {
        emit(AuthStateLogin(user));
      }
    });

    // login
    on<AuthEventLogin>(
      ((event, emit) async {
        try {
          emit(const AuthStateLoading());

          final email = event.email;
          final password = event.password;
          final user = await provider.logIn(
            email: email,
            password: password,
          );

          emit(AuthStateLogin(user));
        } on Exception catch (e) {
          emit(AuthStateLoginFailure(e));
        }
      }),
    );

    // logout
    on<AuthEventLogout>(
      ((event, emit) async {
        try {
          emit(const AuthStateLoading());

          await provider.logOut();
          emit(const AuthStateLogout());
        } on Exception catch (e) {
          emit(AuthStateLogoutFailure(e));
        }
      }),
    );
  }
}
