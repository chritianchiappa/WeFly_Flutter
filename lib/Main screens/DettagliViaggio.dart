import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class DettagliViaggio extends StatelessWidget {
  const DettagliViaggio({super.key});

  String _formatDate(String date) {
    DateTime parsedDate = DateTime.parse(date);
    return DateFormat('dd/MM/yyyy').format(parsedDate);
  }

  Future<void> _partecipaAlViaggio(BuildContext context, String viaggioUid, List partecipanti) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;


    try {

      final database = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: "https://weflyflutter-default-rtdb.europe-west1.firebasedatabase.app",
      );
      //prendo un riferimento al particolare viaggio selezionato
      DatabaseReference viaggioRef = database.ref().child('Viaggi').child(viaggioUid);
      //prendo un riferimento all'utente
      DatabaseReference userRef = database.ref().child('users').child(userId);

      //ottengo la lista dei viaggi a cui l'utente ha partecipato
      final snapshot = await userRef.child('viaggi').get();
      List<String> viaggiList = [];
      if (snapshot.exists) {
        List<dynamic> values = snapshot.value as List<dynamic>;
        viaggiList = values.cast<String>().toList();
      }

      // Aggiungo l'UID del viaggio alla lista dei viaggi dell'utente
      if (!viaggiList.contains(viaggioUid)) {
        viaggiList.add(viaggioUid);
      }
      await userRef.update({'viaggi': viaggiList});


      // Aggiungo l'ID dell'utente al campo "Partecipanti" del viaggio
      partecipanti.add(userId);
      await viaggioRef.update({'Partecipanti': partecipanti});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hai partecipato al viaggio!')),
      );
      Navigator.pop(context); //una volta che l'utente ha partecipato al viaggio
      //ritorno alla lista dei viaggi

    } catch (e) {
      print("errore: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map args = ModalRoute.of(context)!.settings.arguments as Map;
    final Map viaggio = args['viaggio'];
    final String imageUrl = args['imageUrl'];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xffd651f4),
        title: Text(
          "Dettagli viaggio",
          style: GoogleFonts.dmSerifText(
            textStyle: TextStyle(color: Colors.white),
            fontSize: 30,
          ),
        ),
        leading: Image.asset(
          'assets/logo_bianco.png', // Path to your logo
          height: 30,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: imageUrl.isNotEmpty
                      ? NetworkImage(imageUrl)
                      : AssetImage("assets/no_image.png") as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center( // Aggiungi Center qui
                    child: Text(
                      viaggio['Titolo'],
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Luogo: ${viaggio['Città']}, ${viaggio['Nazione']}',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Date: ${_formatDate(viaggio['Data inizio'])} - ${_formatDate(viaggio['Data fine'])}',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Partecipanti: ${viaggio['Partecipanti'].length} / ${viaggio['Max partecipanti']}',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Budget: ${viaggio['Budget']} €',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Aggiungi qui la logica per partecipare al viaggio
                  _partecipaAlViaggio(context, viaggio['key'],List.from(viaggio['Partecipanti']));
                  // Per esempio, potresti aggiornare il database per aggiungere il partecipante

                },
                child: Text('Partecipa'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
            ),
            SizedBox(height: 16), // Padding extra per fare spazio al bottone
          ],
        ),
      ),
    );
  }
}
