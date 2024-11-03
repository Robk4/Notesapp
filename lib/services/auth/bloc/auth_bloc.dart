import 'package:bloc/bloc.dart';
import 'package:notesapp/services/auth/auth_provider.dart';
import 'package:notesapp/services/auth/bloc/auth_event.dart';
import 'package:notesapp/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider) : super(const AuthStateUninitialized()) {
    //To send email verification
    on<AuthEventEmailVerification>((event, emit) async {
      await provider.sendEmailVerification();
      emit(state);
    });
    //To register
    on<AuthEventRegister>((event, emit) async {
      final email = event.email;
      final password = event.password;
      try {
        await provider.createUser(
          email: email,
          password: password,
        );
        await provider.sendEmailVerification();
      } on Exception catch (e) {
        emit(AuthStateRegistering(e));
      }
    });

    //Initialization
    on<AuthEventInitialize>((event, emit) async {
      await provider.initialize();
      final user = provider.currentUser;
      if (user == null) {
        emit(const AuthStateLogout(
          exception: null,
          isLoading: false,
        ));
      } else if (!user.isEmailVerified) {
        emit(const AuthStateNeedsVerification());
      } else {
        emit(AuthStateLogin(user));
      }
    });

    //Logging in
    on<AuthEventLogin>((event, emit) async {
      emit(const AuthStateLogout(
        exception: null,
        isLoading: true,
      ));
      final email = event.email;
      final password = event.password;

      try {
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
          emit(const AuthStateNeedsVerification());
        } else {
          emit(
            const AuthStateLogout(
              exception: null,
              isLoading: false,
            ),
          );
          emit(AuthStateLogin(user));
        }
      } on Exception catch (e) {
        emit(AuthStateLogout(
          exception: e,
          isLoading: false,
        ));
      }
    });

    //Logging out
    on<AuthEventLogout>((event, emit) async {
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
    });
  }
}
