import 'package:bloc/bloc.dart';
import 'package:meranotes/services/auth/auth_provider.dart';
import 'package:meranotes/services/auth/bloc/auth_event.dart';
import 'package:meranotes/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider)
      : super(const AuthStateUninitialized(isLoading: true)) {
    // send email verification
    on<AuthEventSendEmailVerification>(
      ((event, emit) async {
        await provider.sendEmailVerification();
        emit(state);
      }),
    );

    // register user
    on<AuthEventRegister>(
      ((event, emit) async {
        try {
          final email = event.email;
          final password = event.password;

          await provider.createUser(
            email: email,
            password: password,
          );

          await provider.sendEmailVerification();

          emit(const AuthStateNeedsVerification(isLoading: false));
        } on Exception catch (e) {
          emit(AuthStateRegistering(
            exception: e,
            isLoading: false,
          ));
        }
      }),
    );

    // initialize
    on<AuthEventInitialize>((event, emit) async {
      await provider.initialize();
      final user = provider.currentUser;
      if (user == null) {
        emit(
          const AuthStateLogout(
            exception: null,
            isLoading: false,
          ),
        );
      } else if (!user.isEmailVerified) {
        emit(const AuthStateNeedsVerification(isLoading: false));
      } else {
        emit(AuthStateLogin(
          user: user,
          isLoading: false,
        ));
      }
    });

    // login
    on<AuthEventLogin>(
      ((event, emit) async {
        emit(
          const AuthStateLogout(
            exception: null,
            isLoading: true,
            loadingText: 'Please wait while I log you in!',
          ),
        );

        try {
          final email = event.email;
          final password = event.password;
          final user = await provider.logIn(
            email: email,
            password: password,
          );

          if (!user.isEmailVerified) {
            emit(
              const AuthStateLogout(
                exception: null,
                isLoading: false,
              ),
            );

            emit(const AuthStateNeedsVerification(isLoading: false));
          } else {
            emit(
              const AuthStateLogout(
                exception: null,
                isLoading: false,
              ),
            );

            emit(AuthStateLogin(
              user: user,
              isLoading: false,
            ));
          }

          emit(AuthStateLogin(
            user: user,
            isLoading: false,
          ));
        } on Exception catch (e) {
          emit(
            AuthStateLogout(
              exception: e,
              isLoading: false,
            ),
          );
        }
      }),
    );

    // logout
    on<AuthEventLogout>(
      ((event, emit) async {
        try {
          await provider.logOut();
          emit(
            const AuthStateLogout(
              exception: null,
              isLoading: false,
            ),
          );
        } on Exception catch (e) {
          emit(
            AuthStateLogout(
              exception: e,
              isLoading: false,
            ),
          );
        }
      }),
    );
  }
}
