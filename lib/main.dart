import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notesapp/firebase_options.dart';
import 'package:notesapp/views/login_view.dart';
import 'package:notesapp/views/register_view.dart';

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
  )
  );
}

class HomePage extends StatelessWidget {
  const HomePage ({super.key});

   //Main program builder
  @override
  Widget build(BuildContext context) {
    return Scaffold( //Structure of the page
      appBar: AppBar(title:  const Text("Home page"),
      backgroundColor:const Color.fromARGB(255, 60, 255, 0),),
      backgroundColor: const Color(0xFFDCCCBB),
      body: FutureBuilder( // FutureBuilder makes sure column isnt built before future is finished
        future: Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
        builder: (context, snapshot) 
        {
          //Switch that on done proceeds and on everything else(default:) pump out Loading..
          switch (snapshot.connectionState){
            case ConnectionState.done:
            final user = FirebaseAuth.instance.currentUser;
            if(user?.emailVerified ?? false)
            {
              print("You are a verified user");
            }
            else
            {
              print("You need to verify your email first");
            }
            return const Text("Done");
         default:
         return const Text("Loading..");
          }     
        },
      ),
    );
  }
}

