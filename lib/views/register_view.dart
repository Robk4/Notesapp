import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
//import 'dart:developer' as dartlog;
import 'package:notesapp/services/auth/auth_exceptions.dart';
import 'package:notesapp/services/auth/bloc/auth_bloc.dart';
import 'package:notesapp/services/auth/bloc/auth_event.dart';
import 'package:notesapp/services/auth/bloc/auth_state.dart';
import 'package:notesapp/utilities/dialogs/error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
//Creation of the variables for controller
//We need controller to act as a proxy
  late final TextEditingController _email;
  late final TextEditingController _password;

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
      listener: (context, state) async {
        if (state is AuthStateRegistering) {
          if (state.exception is GenericAuthException) {
            await showErrorDialog(context, 'Authentication error');
          }
        }
      },
      child: Scaffold(
        //Structure of the page
        appBar: AppBar(
          title: const Text("This is where u register?"),
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
                  const InputDecoration(hintText: "Enter your email here"),
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
                  //await so it doesnt begin as soon as the page is loaded
                  context.read<AuthBloc>().add(AuthEventRegister(
                        email,
                        password,
                      ));
                },
                child: const Text("Register")),
            TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(
                        const AuthEventLogout(),
                      );
                },
                child: const Text("Already registered? Login here!"))
          ],
        ),
      ),
    );
  }
}
