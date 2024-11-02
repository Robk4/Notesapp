import 'package:flutter/material.dart';
//import 'dart:developer' as dartlog;

import 'package:notesapp/constants/routes.dart';
import 'package:notesapp/services/auth/auth_service.dart';

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
      body: Column(children: [
        const Text(
            "We've sent you an email verification. Please open your email to verify the account."),
        const Text(
            "If you haven't recieved an email verification email yet press the button below."),
        TextButton(
          onPressed: () async {
            await AuthService.firebase().sendEmailVerification();
          },
          child: const Text("Send email verification"),
        ),
        TextButton(
          onPressed: () async {
            await AuthService.firebase().logOut();
            Navigator.of(context).pushNamedAndRemoveUntil(
              registerRoute,
              (route) => false,
            );
          },
          child: const Text("Restart?"),
        )
      ]),
    );
  }
}
