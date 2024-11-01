import 'package:flutter/material.dart';
import 'dart:developer' as dartlog;
import 'package:notesapp/constants/routes.dart';
import 'package:notesapp/services/auth/auth_exceptions.dart';
import 'package:notesapp/services/auth/auth_service.dart';
import 'package:notesapp/utilities/dialogs/error_dialog.dart';

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
    return Scaffold(
        //Structure of the page
        appBar: AppBar(
          title: const Text("Already registered? Login then!"),
          backgroundColor: const Color.fromARGB(255, 66, 123, 228),
        ),
        backgroundColor: const Color(0xFFDCCCBB),
        //   body: FutureBuilder( // FutureBuilder makes sure column isnt built before future is finished
        //     future: Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
        //     builder: (context, snapshot)
        //     {
        //       //Switch that on done proceeds and on everything else(default:) pump out Loading..
        //       switch (snapshot.connectionState){
        //         case ConnectionState.done:
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
                  try {
                    final email = _email.text;
                    final password = _password.text;
                    //await so it doesnt begin as soon as the page is loaded
                    //Signing in to the user for in the FireBase backend based on inputs
                    final userCredential = AuthService.firebase().currentUser;
                    await AuthService.firebase()
                        .logIn(email: email, password: password);
                    //Checks if the user is verified
                    if (userCredential?.isEmailVerified ?? false) {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          notesRoute, (route) => false);
                    } else {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          verifyEmailRoute, (route) => false);
                    }
                    dartlog.log(userCredential.toString());

                    Navigator.of(context)
                        .pushNamedAndRemoveUntil(notesRoute, (route) => false);

                    //Catching the ERRORS HERE
                  } on InvalidCredentialsdAuthException {
                    await showErrorDialog(
                      context,
                      'User Not Found',
                    );
                  } on GenericAuthException {
                    await showErrorDialog(context, 'Authentication error');
                  }
                },
                child: const Text("Login")),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    registerRoute,
                    (route) => false,
                  );
                },
                child: const Text("Not registered yet? Register here!"))
          ],
        ));
  }
}
