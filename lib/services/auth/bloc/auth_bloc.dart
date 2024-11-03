import 'package:bloc/bloc.dart';
import 'package:notesapp/services/auth/auth_provider.dart';
import 'package:notesapp/services/auth/bloc/auth_event.dart';
import 'package:notesapp/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider)
      : super(const AuthStateUninitialized(isLoading: true)) {
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
        emit(const AuthStateNeedsVerification(isLoading: false));
      } on Exception catch (e) {
        emit(AuthStateRegistering(exception: e, isLoading: false));
      }
    });

    on<AuthEventShouldRegister>((event, emit) {
      emit(const AuthStateRegistering(exception: null, isLoading: false));
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
        emit(const AuthStateNeedsVerification(isLoading: false));
      } else {
        emit(AuthStateLogin(user: user, isLoading: false));
      }
    });

    //Logging in
    on<AuthEventLogin>((event, emit) async {
      emit(const AuthStateLogout(
          exception: null, isLoading: true, loadingText: 'Please wait..'));
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
          emit(const AuthStateNeedsVerification(isLoading: false));
        } else {
          emit(
            const AuthStateLogout(
              exception: null,
              isLoading: false,
            ),
          );
          emit(AuthStateLogin(user: user, isLoading: false));
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
