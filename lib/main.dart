import 'package:flutter/material.dart';
import 'package:notesapp/constants/routes.dart';
import 'package:notesapp/services/auth/auth_service.dart';
import 'package:notesapp/views/login_view.dart';
import 'package:notesapp/views/notes_view.dart';
import 'package:notesapp/views/register_view.dart';
import 'package:notesapp/views/verify_email_view.dart';
import 'dart:developer' as dartlog;

void main() {
  WidgetsFlutterBinding
      .ensureInitialized(); // Enabling widget binding before initialize
  runApp(MaterialApp(
    title: 'NotesAPP',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
      useMaterial3: true,
    ),
    home: const HomePage(),
    routes: {
      loginRoute: (context) => const LoginView(),
      registerRoute: (context) => const RegisterView(),
      notesRoute: (context) => const NotesView(),
      verifyEmailRoute: (context) => const VerifyEmailView(),
    },
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  //Main program builder
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // FutureBuilder makes sure column isnt built before future is finished
      future: AuthService.firebase().initialize(),
      builder: (context, snapshot) {
        //Switch that on done proceeds and on everything else(default:) pump out Loading..
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = AuthService.firebase().currentUser;
            if (user != null) {
              // Checking for users existence
              if (user.isEmailVerified) {
                // Checking for users email verification
                return const NotesView();
              } else {
                return const VerifyEmailView();
              }
            } else {
              return const LoginView();
            }
          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}
