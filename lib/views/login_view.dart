import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
//import 'package:notesapp/firebase_options.dart';
import 'dart:developer' as dartlog;

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
                    final userCredential = await FirebaseAuth.instance
                        .signInWithEmailAndPassword(
                            email: email, password: password);
                    dartlog.log(userCredential.toString());
                    Navigator.of(context).pushNamedAndRemoveUntil('/notes/', (route) =>false);
                  } on FirebaseAuthException catch (e) {
                    dartlog.log(e.code);
                    if (e.code == 'invalid-credential') {
                      dartlog.log("User not found. Invalid credentials");
                    } else {
                      dartlog.log("SOMETHING ELSE HAPPENED");
                      dartlog.log(e.code);
                    }
                  }
                },
                child: const Text("Login")),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/register/',
                    (route) => false,
                  );
                },
                child: const Text("Not registered yet? Register here!"))
          ],
        ));
//          default:
//          return const Text("Loading..");
//           }
//         },
//       ),
//     );
  }
}
