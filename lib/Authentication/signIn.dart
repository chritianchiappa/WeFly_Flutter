import 'package:flutter/material.dart';
import 'package:wefly/model/firebase_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wefly/Main screens/homePage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final FirebaseAuthService _auth = FirebaseAuthService();

  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscureText = true; // Stato per controllare la visibilità della password

  @override
  void dispose() {
    _email.dispose(); // Libera le risorse dei controller
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xffd651f4),
                  Color(0xff1c29e0),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 45.0),
              child: Column(
                children: [
                  Text(
                    'BENVENUTO\nACCEDI!',
                    style: GoogleFonts.bebasNeue(
                      textStyle: TextStyle(color: Colors.white),
                      fontSize: 40,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.9, // Larghezza del container
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20), // Bordi smussati
                          color: Colors.white,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top:30.0,bottom: 30,left: 18.0,right: 18.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextFormField(
                                controller: _email,
                                decoration: InputDecoration(
                                  labelText: "EMAIL",
                                  labelStyle: GoogleFonts.bebasNeue(
                                    textStyle: TextStyle(color: Color(0xffd651f4)),
                                  ),
                                  border: OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Color(0xffd651f4)),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              TextFormField(
                                controller: _password,
                                decoration: InputDecoration(
                                  labelText: "PASSWORD",
                                  labelStyle: GoogleFonts.bebasNeue(
                                    textStyle: TextStyle(color: Color(0xffd651f4)),
                                  ),
                                  border: OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Color(0xffd651f4)),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureText
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureText = !_obscureText;
                                      });
                                    },
                                  ),
                                ),
                                obscureText: _obscureText,
                              ),
                              SizedBox(height: 20),
                              GestureDetector(
                                onTap: () {
                                  _signIn();
                                },
                                child: Container(
                                  height: 55,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    gradient: const LinearGradient(colors: [
                                      Color(0xffd651f4),
                                      Color(0xff1c29e0),
                                    ]),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'CONTINUA',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _signIn() async {
    String email = _email.text;
    String password = _password.text;
    User? user = await _auth.loginUser(email, password);

    if (user != null) {
      Navigator.pushAndRemoveUntil(
        //navigo verso la homePage eliminando dallo
        // stack tutti i widget in modo che se torno indietro dalla home page
        // non ritorno alla schermata di accesso
        context,
        MaterialPageRoute(builder: (context) => const homePage()),
            (route) => false,
      );
    } else {
      showToastMessage("Email o password non validi");
    }
  }

  void showToastMessage(String message) => Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_LONG,
    backgroundColor: Color(0xffd651f4),
    textColor: Colors.white,
    fontSize: 16.0,
  );
}
