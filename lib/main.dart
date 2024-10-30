import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notesapp/constants/routes.dart';
import 'package:notesapp/firebase_options.dart';
import 'package:notesapp/views/login_view.dart';
import 'package:notesapp/views/register_view.dart';
import 'package:notesapp/views/verify_email_view.dart';
import 'dart:developer' as dartlog;

void main() {
  WidgetsFlutterBinding
      .ensureInitialized(); // Enabling widget binding before initialize
  runApp(MaterialApp(
    title: 'Flutter Demo',
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
    return
        // Scaffold( //Structure of the page
        // appBar: AppBar(title:  const Text("Home page"),
        // backgroundColor:const Color.fromARGB(255, 66, 123, 228),),
        // backgroundColor: const Color(0xFFDCCCBB),
        // body:
        FutureBuilder(
      // FutureBuilder makes sure column isnt built before future is finished
      future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform),
      builder: (context, snapshot) {
        //Switch that on done proceeds and on everything else(default:) pump out Loading..
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) { // Checking for users existence
              if (user.emailVerified) { // Checking for users email verification
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
    // );
  }
}
// Menu action button
enum MenuAction { logout }

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text("Notes?"),
            backgroundColor: const Color.fromARGB(255, 66, 123, 228),
            actions: [
              PopupMenuButton<MenuAction>(
                onSelected: (value) async {
                  switch(value){
                    case MenuAction.logout:
                    final shouldLogout = await showLogOutDialog(context);
                    if (shouldLogout)
                    {
                      await FirebaseAuth.instance.signOut();
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        loginRoute,
                        (_) => false,
                        );
                    }
                    else{return;}
                  }
                },
                itemBuilder: (context) {
                  return const [
                    PopupMenuItem<MenuAction>(
                      value: MenuAction.logout,
                      child: Text("Log out"),
                    )
                  ];
                },
              )
            ]),
        body: const Text("Text?"));
  }
}

// Method for log out dialog
Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Log out"),
          content: const Text("You sure about logging out?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text("Log out"),
            )
          ],
        );
      }).then((value) => value ?? false);
}
