import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wefly/Autenticazione/firebase_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';

class ProfileScreen extends StatefulWidget {

  ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  late DatabaseReference _userRef;
  late final database;
  String _nome = '';
  String _cognome = '';
  List<String> _interessi = [];
  List<Map> _viaggi = [];
  bool isWhatsAppInstalled = false;
  bool isWhatsAppDefault = false;
  String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    database = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: "https://weflyflutter-default-rtdb.europe-west1.firebasedatabase.app",
    );

    _userRef = database.ref().child('users').child(userId);
    _userRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        Map<Object?, Object?>? userData = event.snapshot.value as Map<Object?, Object?>?;
        if (userData != null) {
          setState(() {
            _nome = userData['nome']?.toString() ?? '';
            _cognome = userData['cognome']?.toString() ?? '';
            _interessi = List<String>.from(userData['passions'] as List<dynamic>? ?? []);
          });

          if (userData['viaggi'] != null) {
            List<String> viaggiIds = List<String>.from(userData['viaggi'] as List<dynamic>? ?? []);
            _loadViaggiDetails(viaggiIds);
          }
        }
      }
    });
  }

  Future<void> _loadViaggiDetails(List<String> viaggiIds) async {
    List<Map> viaggiList = [];

    for (String viaggioId in viaggiIds) {
      DataSnapshot snapshot = await database.ref().child('Viaggi').child(viaggioId).get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> viaggioData = snapshot.value as Map<dynamic, dynamic>;
        // Recupera l'UID del creatore del viaggio
        String creatorUID = viaggioData['Partecipanti'][0];

        // Ottieni il numero di telefono del creatore del viaggio
        DataSnapshot userSnapshot = await database.ref().child('users').child(creatorUID).child('telefono').get();
        if(userSnapshot.exists)
          {
            String numeroTelefonoCreatore = userSnapshot.value.toString();

            // Aggiungi il numero di telefono alla mappa dei dati del viaggio
            viaggioData['numeroTelefonoCreatore'] = numeroTelefonoCreatore;
            viaggiList.add(viaggioData);
          }
      }
    }

    setState(() {
      _viaggi = viaggiList;
    });
  }

  Future<String> _getProfileImageUrl(String userId) async {
    try {
      final ref = FirebaseStorage.instance.ref().child('profile_images/$userId.jpg');
      String url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      print('Errore durante il caricamento dell\'immagine del profilo: $e');
      return ''; // Nel caso in cui si verifichi un errore, restituisci una stringa vuota
    }
  }
  Widget _buildViaggioTile(Map<String, dynamic> viaggio) {
    // Ensure all required fields are available and provide default values if necessary
    String nome = viaggio['Titolo'] ?? 'ND';
    String citta = viaggio['Città'] ?? 'ND';
    String nazione = viaggio['Nazione'] ?? 'ND';
    String dataInizio = viaggio['Data inizio'] != null
        ? DateFormat('dd/MM/yyyy').format(DateTime.parse(viaggio['Data inizio']))
        : 'ND';
    String dataFine = viaggio['Data fine'] != null
        ? DateFormat('dd/MM/yyyy').format(DateTime.parse(viaggio['Data fine']))
        : 'ND';
    String numeroTelefono = viaggio['numeroTelefonoCreatore'] ?? '';

    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xff7480FB)), // Definisci il bordo
        borderRadius: BorderRadius.circular(10), // Definisci i bordi arrotondati
      ),
      child: ListTile(
        title: Text(nome),
        subtitle: Text('$citta, $nazione - Da: $dataInizio a: $dataFine'),
        trailing: IconButton(
          onPressed: () {
            _sendWhatsapp(numeroTelefono);
          },
          icon: Icon(LineIcons.whatSApp),
        ),
      ),
    );
  }
  void _sendWhatsapp(String phoneNumber) async {
    print(phoneNumber);
    try {
      // Formatto il numero di telefono
      String formattedPhoneNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
      print(formattedPhoneNumber);
      // URL di deep linking di WhatsApp
      var url='https://wa.me/$formattedPhoneNumber?text=Ciao';

      // Provo ad aprire WhatsApp con l'URL di deep linking
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Errore';
      }
    } catch (e) {
      print('Errore durante l\'invio di WhatsApp: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 45,
                  // Carica l'immagine del profilo con l'indicatore di caricamento
                  child: FutureBuilder<String>(
                    future: _getProfileImageUrl(userId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Icon(Icons.error);
                      } else {
                        return snapshot.hasData
                            ? CircleAvatar(
                          radius: 45,
                          backgroundImage: NetworkImage(snapshot.data!),
                        )
                            : CircleAvatar(
                          radius: 45,
                          backgroundImage: AssetImage("assets/user.png"),
                        );
                      }
                    },
                  ),
                ),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_nome $_cognome',
                      style: GoogleFonts.dmSerifText(
                        textStyle: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff7480FB),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        _auth.signOut();
                        Navigator.pushReplacementNamed(context, '/registerScreen');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff7480FB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      ),
                      icon: Icon(Icons.logout, color: Colors.white,),
                      label: Text(
                        'ESCI',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Interessi:',
              style: GoogleFonts.dmSerifText(
                textStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff7480FB),
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color(0xff7480FB),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _interessi.map((interesse) {
                  return Text(
                    interesse,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 20,),
            Text(
              'Viaggi:',
              style: GoogleFonts.dmSerifText(
                textStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff7480FB),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _viaggi.length,
                itemBuilder: (context, index) {
                  return _buildViaggioTile(Map<String, dynamic>.from(_viaggi[index]));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
