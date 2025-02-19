import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
//import 'dart:developer' as dartlog;
import 'package:notesapp/services/auth/bloc/auth_bloc.dart';
import 'package:notesapp/services/auth/bloc/auth_event.dart';

//Verifying the email by checking it with a Firebase backend check
class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Email verification happens here"),
      ),
      backgroundColor: const Color(0xFFDCCCBB),
      body: Column(children: [
        const Text(
            "We've sent you an email verification. Please open your email to verify the account."),
        const Text(
            "If you haven't recieved an email verification email yet press the button below."),
        TextButton(
          onPressed: () {
            context.read<AuthBloc>().add(const AuthEventEmailVerification());
          },
          child: const Text("Send email verification"),
        ),
        TextButton(
          onPressed: () {
            context.read<AuthBloc>().add(const AuthEventLogout());
          },
          child: const Text("Restart?"),
        )
      ]),
    );
  }
}
