import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'Autenticazione/registerScreen.dart';
import 'Autenticazione/completeRegister.dart';
import 'Autenticazione/signIn.dart';
import 'Autenticazione/signUp.dart';
import 'homePage.dart';
import 'DettagliViaggio.dart';

Future main() async{

  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, //app orientata in verticale
  ]);
  try {
    await Firebase.initializeApp();
    runApp(const MyApp());
  } catch (e) {
    print('Errore durante l\'inizializzazione di Firebase: $e');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}
class _MyAppState extends State<MyApp> {
  User? user;
  @override
  void initState(){
    super.initState();
    user=FirebaseAuth.instance.currentUser;
  }


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WeFly',
      initialRoute: user != null ? '/home' : '/registerScreen', //se un untente gia autenticato vado sulla home altrimenti sulla registrazione
      routes: { //definisco le rotte per navigare tra le schermate
        '/home': (context) => const homePage(),
        '/signUp': (context) => const SignUp(),
        '/signIn': (context) => const SignIn(),
        '/registerScreen': (context) => const registerScreen(),
        '/completeRegister': (context) => const completeRegister(),
        '/dettagliViaggio': (context) => const DettagliViaggio(),
      },
    );
  }
}

