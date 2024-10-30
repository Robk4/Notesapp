import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
//import 'package:notesapp/firebase_options.dart';
import 'dart:developer' as dartlog;
import 'package:notesapp/constants/routes.dart';
import 'package:notesapp/utilities/show_error_dialog.dart';

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
    return Scaffold(
      //Structure of the page
      appBar: AppBar(
        title: const Text("This is where u register?"),
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
                try {
                  //await so it doesnt begin as soon as the page is loaded
                  //Creating the user for the FireBase backend based on inputs
                   await FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                          email: email, password: password);
                  final user = FirebaseAuth.instance.currentUser;
                  user?.sendEmailVerification(); //Sending a verification email as a user registers
                  Navigator.of(context).pushNamed(verifyEmailRoute);
                } on FirebaseAuthException catch (e) {
                  await showErrorDialog(context, "An unexpected error occurred${e.code}");
                  //TODO Invalid email,email in use, weak password exceptions
                }
                catch(e)
                {
                  await showErrorDialog(
                    context, e.toString(),
                  );
                }
              },
              child: const Text("Register")),
          TextButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  loginRoute,
                  (route) => false,
                );
              },
              child: const Text("Already registered? Login here!"))
        ],
      ),
    );
    //        default:
    //        return const Text("Loading..");
    //         }
    //       },
    //     ),
    //   );
  }
}
