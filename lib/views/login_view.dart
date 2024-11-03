import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
//import 'dart:developer' as dartlog;
import 'package:notesapp/constants/routes.dart';
import 'package:notesapp/services/auth/auth_exceptions.dart';
import 'package:notesapp/services/auth/bloc/auth_bloc.dart';
import 'package:notesapp/services/auth/bloc/auth_event.dart';
import 'package:notesapp/services/auth/bloc/auth_state.dart';
import 'package:notesapp/utilities/dialogs/error_dialog.dart';
import 'package:notesapp/utilities/dialogs/loading_dialog.dart';

class LoginView extends StatefulWidget {
  //Stateful because we need to manage things inside
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  //Creation of the variables for controller
//We need controller to act as a proxy
  late final TextEditingController _email;
  late final TextEditingController _password;
  CloseDialog? _closeDialogHandle;

//Creating the state for the variables in HP
  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

//Disposing of the variables after exiting DONT FORGET AFTER INIT
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  //Main program builder
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      //Catching the ERRORS HERE
      listener: (context, state) async {
        if (state is AuthStateLogout) {
          final closeDialog = _closeDialogHandle;
          if (!state.isLoading && closeDialog != null) {
            closeDialog();
            _closeDialogHandle = null;
          } else if (state.isLoading && closeDialog != null) {
            _closeDialogHandle = showLoadingDialog(
              context: context,
              text: 'Loading..?',
            );
          }

          if (state.exception is InvalidCredentialsdAuthException) {
            await showErrorDialog(context, 'User Not Found');
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(context, 'Authentication error');
          }
        }
      },
      child: Scaffold(
        //Structure of the page
        appBar: AppBar(
          title: const Text("Already registered? Login then!"),
          backgroundColor: const Color.fromARGB(255, 66, 123, 228),
        ),
        backgroundColor: const Color(0xFFDCCCBB),
        body: Column(
          children: [
            TextField(
              //The basics of making a email field
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              decoration:
                  const InputDecoration(hintText: "Enter your email here lol"),
            ),
            TextField(
              controller: _password,
              decoration:
                  const InputDecoration(hintText: "Enter your password here"),
              //The basics of making a password field
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
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
                child: const Text("Login")),
            TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthEventShouldRegister());
                },
                child: const Text("Not registered yet? Register here!"))
          ],
        ),
      ),
    );
  }
}
