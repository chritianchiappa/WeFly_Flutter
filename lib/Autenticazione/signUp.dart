import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wefly/model/User.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _nome = TextEditingController();
  final _cognome = TextEditingController();
  final _email = TextEditingController();
  final _confPassword = TextEditingController();
  final _password = TextEditingController();
  final _telefono = TextEditingController();
  bool _obscurePassword = true; // Stato per controllare la visibilità della password

  @override
  void dispose() {
    _nome.dispose();
    _cognome.dispose();
    _email.dispose();
    _confPassword.dispose(); // Libera le risorse dei controller
    _password.dispose();
    _telefono.dispose();
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
              gradient: LinearGradient(colors: [
                Color(0xffd651f4),
                Color(0xff1c29e0),
              ]),
            ),
            child: Padding(
              padding: EdgeInsets.only(top: 60.0, left: 22),
              child: Text(
                'CREA IL TUO\nACCOUNT',
                style: GoogleFonts.bebasNeue(
                  textStyle: TextStyle(color: Colors.white),
                  fontSize: 35,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 180.0),
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                color: Colors.white,
              ),
              height: double.infinity,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18.0, 20.0, 18.0, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTextField(_nome, 'NOME'),
                    SizedBox(height: 20),
                    _buildTextField(_cognome, 'COGNOME'),
                    SizedBox(height: 20),
                    _buildTextField(_telefono, 'TELEFONO'),
                    SizedBox(height: 20),
                    _buildTextField(_email, 'EMAIL'),
                    SizedBox(height: 20),
                    _buildPasswordField(_password, 'PASSWORD'),
                    SizedBox(height: 20),
                    _buildPasswordField(_confPassword, 'CONFERMA PASSWORD'),
                    SizedBox(height: 30),
                    GestureDetector(
                      onTap: () {
                        _checkField();
                      },
                      child: Container(
                        height: 55,
                        width: 300,
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
    );
  }
  Widget _buildPasswordField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      obscureText: _obscurePassword,
      style: TextStyle(color: Color(0xffd651f4)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xffd651f4),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xffd651f4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xffd651f4)),
        ),
      ),
    );
  }
  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      style: TextStyle(color: Color(0xffd651f4)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xffd651f4),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xffd651f4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xffd651f4)),
        ),
      ),
    );
  }
  
  void showToastMessage(String message) => Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_LONG,
    backgroundColor: Color(0xff1c29e0),
    textColor: Colors.white,
    fontSize: 16.0,
  );
  void _checkField() {
    String nome = _nome.text.trim();
    String cognome = _cognome.text.trim();
    String telefono = _telefono.text.trim();
    String email = _email.text.trim();
    String password = _password.text.trim();
    String confPassword = _confPassword.text.trim();

    if (nome.isEmpty || cognome.isEmpty || telefono.isEmpty|| email.isEmpty || password.isEmpty || confPassword.isEmpty) {
      showToastMessage("Tutti i campi sono obbligatori.");
      return;
    }
    if (!RegExp(r'^(\+?\d{10,15})$').hasMatch(telefono)) {
      showToastMessage("Il formato del numero di telefono non è corretto.");
      return;
    }

    if (password != confPassword) {
      showToastMessage("Le password non coincidono.");
      return;
    }
    if (password.length < 6) {
      showToastMessage("La password deve essere lunga almeno 6 caratteri.");
      return;
    }

    // Se tutti i controlli passano, continuo con la registrazione
    Navigator.pushNamed(
      context,
      '/completeRegister',
      arguments: UserData(nome: nome, cognome: cognome, email: email, password: password,telefono:telefono)
    );
  }
}
