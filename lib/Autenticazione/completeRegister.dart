import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'firebase_auth_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:wefly/model/User.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:wefly/homePage.dart';

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // Indicatore di caricamento
      ),
    );
  }
}

class completeRegister extends StatefulWidget {
  const completeRegister({Key? key}) : super(key: key);

  @override
  _completeRegisterState createState() => _completeRegisterState();
}

class _completeRegisterState extends State<completeRegister> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  late UserData args;
  Uint8List? _image;
  File? selectedIMage;
  UploadTask? uploadTask;
  bool _isLoading = false;
  List<String> _passions = [
    'Relax',
    'Divertimento',
    'Cultura',
    'Avventura',
    'Gastronomico',
    'Esplorazione naturale',
    'Viaggi di lusso',
  ];

  List<String> _selectedPassions = [];

  @override
  Widget build(BuildContext context) {
    return _isLoading ? LoadingScreen() : buildMainScreen(); // Mostra la schermata di caricamento se isLoading è true
  }

  Widget buildMainScreen()  {
    args = ModalRoute.of(context)!.settings.arguments as UserData; //prendo gli argomenti passati

    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(top: 30),
        child: Padding(
          padding: const EdgeInsets.only(right: 25, left: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
            Text(
              'Aggiungi un\'immagine del profilo',
              style: GoogleFonts.dmSerifText(
                textStyle: TextStyle(color: Colors.black),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 30),
            Stack(
              children: [
                _image != null
                    ? CircleAvatar(
                    radius: 70,
                    backgroundImage: MemoryImage(_image!))
                    : CircleAvatar(
                  radius: 70,
                  backgroundImage:AssetImage("assets/user.png"),
                  backgroundColor:Colors.grey,
                ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    showImagePickerOption(context);
                  },
                  child: CircleAvatar(
                    radius: 25,
                    backgroundColor:Color(0xff7480FB),
                    child: Icon(Icons.add_a_photo, size: 30,color: Colors.white,),
                  ),
                ),
              ),
            ],
            ),

            SizedBox(height: 30),
            Text(
              'Seleziona le tue passioni',
              style: GoogleFonts.dmSerifText(
                  textStyle: TextStyle(color: Colors.black),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
              ),
            ),
            SizedBox(height: 10),
            Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Color(0xff7480FB),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white),
              ),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: _passions.map((passion) {
                return Row(
                  children: [
                    Checkbox(
                      value: _selectedPassions.contains(passion),
                      side: BorderSide(
                        color: Colors.white, // Modifica il colore del bordino qui
                        width: 2.0, // Opzionale: puoi regolare anche la larghezza del bordino
                      ),
                      activeColor: Color(0xffd651f4),
                      onChanged: (isChecked) {
                        setState(() {
                          if (isChecked != null && isChecked) {
                            _selectedPassions.add(passion);
                          } else {
                            _selectedPassions.remove(passion);
                          }
                        });
                      },
                    ),
                    Text(
                        passion,
                      style: GoogleFonts.dmSerifText(
                        textStyle: TextStyle(color: Colors.white),
                        fontWeight: FontWeight.bold,

                      ),),
                  ],
                );
              }).toList(),
            ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                _check();
              },
              child: Container(
                height: 53,
                width: 220,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [
                        Color(0xffd651f4),
                        Color(0xff1c29e0),
                      ]
                  ),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white),
                ),
                child: Center(child: Text("REGISTRATI",
                  style:
                  GoogleFonts.bebasNeue(
                    textStyle: TextStyle(color: Colors.white),
                    fontSize: 20,
                  ),),),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
  void showImagePickerOption(BuildContext context) {
    showModalBottomSheet(
        backgroundColor: Color(0xff7480FB),
        context: context,
        builder: (builder) {
          return Padding(
            padding: const EdgeInsets.all(30.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 100,
              child: Row(

                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        _pickImage(ImageSource.gallery);
                      },
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_outlined,
                              size: 60,
                            ),
                            Text(
                                "Galleria",
                                style: GoogleFonts.dmSerifText(
                            textStyle: TextStyle(color: Colors.black),
                        fontWeight: FontWeight.bold,

                      ))
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        _pickImage(ImageSource.camera);
                      },
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt_outlined,
                              size: 60,
                            ),
                            Text(
                            "Camera",
                            style: GoogleFonts.dmSerifText(
          textStyle: TextStyle(color: Colors.black),
          fontWeight: FontWeight.bold,

          ))
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
  void showToastMessage(String message) =>
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Color(0xffd651f4),
        textColor: Colors.white,
        fontSize: 16.0,
      );

//Prende l'immagine dalla galleria
  Future _pickImage(ImageSource source) async {
    final returnImage = await ImagePicker().pickImage(
        source: source);
    if (returnImage == null) return;
    setState(() {
      selectedIMage = File(returnImage.path);
      _image = File(returnImage.path).readAsBytesSync();
    });
    Navigator.of(context).pop();
  }


  void _check(){
    if (_image == null) {
      showToastMessage("Aggiungi un'immagine di profilo");
      return;
    }
    if (_selectedPassions.length < 2) {
      showToastMessage("Seleziona almeno due passioni");
      return;
    }
    // Se entrambe le condizioni sono soddisfatte, procedi con la registrazione
    _signUp(args.email, args.password);
  }

  void _signUp(String email, String password) async {
    setState(() {
      _isLoading = true; // attiva lo stato di caricamento
    });
    User? user = await _auth.createUser(email, password);
    if (user != null) {
      bool success = await _saveUserData(user);

      if (success) {
        showToastMessage("Registrato con successo!");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const homePage()),
              (route) => false,
        );
      } else {
        showToastMessage("Errore durante il salvataggio dei dati utente.");
      }
    } else {
      showToastMessage("Errore durante la registrazione.");
    }
    setState(() {
      _isLoading = false; // Disattiva lo stato di caricamento quando il caricamento è completato
    });
  }

  Future<bool> _saveUserData(User user) async {
    try {
      String uid = user.uid;
      String imagePath = 'profile_images/$uid.jpg';
      final ref=FirebaseStorage.instance.ref().child(imagePath);
      uploadTask = ref.putFile(selectedIMage!);

      final snapshot = await uploadTask!.whenComplete((){});

      final database = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: "https://weflyflutter-default-rtdb.europe-west1.firebasedatabase.app",
      );

      DatabaseReference userRef = database.ref().child('users/$uid');

      await userRef.set({
        'nome': args.nome,
        'cognome': args.cognome,
        'email': args.email,
        'password': args.password,
        'passions': _selectedPassions,
        'telefono': args.telefono,
      });
      return true;
    } catch (e) {
      showToastMessage("Errore durante il salvataggio dei dati");
      return false;
    }
  }
}
