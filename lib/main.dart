import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notesapp/firebase_options.dart';
import 'package:notesapp/views/login_view.dart';
import 'package:notesapp/views/register_view.dart';
import 'package:notesapp/views/verify_email_view.dart';

void main() 
{
  WidgetsFlutterBinding.ensureInitialized(); // Enabling widget binding before initialize
  runApp( MaterialApp
  (
      title: 'Flutter Demo',
      theme: ThemeData
      (
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      
      home: const HomePage(),
      routes: {
        '/login/': (context) => const LoginView(),
        '/register/': (context) => const RegisterView(),
      },
  )
  );
}

class HomePage extends StatelessWidget {
  const HomePage ({super.key});

   //Main program builder
  @override
  Widget build(BuildContext context) {
    return 
      // Scaffold( //Structure of the page
      // appBar: AppBar(title:  const Text("Home page"),
      // backgroundColor:const Color.fromARGB(255, 66, 123, 228),),
      // backgroundColor: const Color(0xFFDCCCBB),
      // body:
       FutureBuilder( // FutureBuilder makes sure column isnt built before future is finished
        future: Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
        builder: (context, snapshot) 
        {
          //Switch that on done proceeds and on everything else(default:) pump out Loading..
          switch (snapshot.connectionState){
            case ConnectionState.done:
             final user = FirebaseAuth.instance.currentUser;
             if(user!= null){
              if(user.emailVerified)
              {
                print("Email is verified");
              }
              else{
                return const VerifyEmailView();
              }
             }
             else{
              return const LoginView();
             }
             return const Text("Done");
         default:
          return const CircularProgressIndicator();
          }     
        },
      );
    // );
  }
}
