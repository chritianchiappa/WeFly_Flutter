import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'FilterDialog.dart';

class ViaggiScreen extends StatefulWidget {
  const ViaggiScreen({super.key});
  @override
  State<ViaggiScreen> createState() => _ViaggiScreenState();
}

class _ViaggiScreenState extends State<ViaggiScreen> {
  late FirebaseDatabase database;
  late Query viaggiRef;
  late DatabaseReference userRef;
  DateTimeRange? _selectedDateRange;
  double _selectedBudget = 10000.0;
  double _selectedCompatibility = 0.0;
  List<String> stiliViaggioUtente=[];
  String userId = FirebaseAuth.instance.currentUser!.uid;


  @override
  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  void _initializeFirebase() async {
    database = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: "https://weflyflutter-default-rtdb.europe-west1.firebasedatabase.app",
    );
    viaggiRef = database.ref().child('Viaggi');
    userRef = database.ref().child('users').child(userId);
    final snapshot = await userRef.child('passions').get();

    if (snapshot.exists) {
      List<dynamic> values = snapshot.value as List<dynamic>;
      stiliViaggioUtente = values.cast<String>().toList();
    }
    print(stiliViaggioUtente);
  }

  Future<String> _getImageUrl(String viaggioUid) async {
    try {
      final ref = FirebaseStorage.instance.ref().child('travels_images/$viaggioUid.jpg');
      String url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      print('Errore durante il caricamento dell\'immagine: $e');
      return '';
    }
  }

  bool _filterViaggio(Map viaggio) {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    // Filtro per budget
    if (viaggio['Budget'] > _selectedBudget) {
      return false;
    }

    if(List.from(viaggio['Partecipanti']).contains(userId)){
      return false;
    }
    if(List.from(viaggio['Partecipanti']).length>=viaggio['Max partecipanti']){
      return false;
    }

    //Filtro per compatibilità
    double compatibilityScore = _calculateCompatibility(List<String>.from(viaggio['stili']));
    if (compatibilityScore < _selectedCompatibility) {
      return false;
    }

    // Filtro per data
    if (_selectedDateRange != null) {
      DateTime inizioData = DateTime.parse(viaggio['Data inizio']);
      DateTime fineData = DateTime.parse(viaggio['Data fine']);
      if (fineData.isBefore(_selectedDateRange!.start) || inizioData.isAfter(_selectedDateRange!.end)) {
        return false;
      }
    }

    return true;
  }

  double _calculateCompatibility(List<String> stiliViaggio) {
    // Calcola la compatibilità tra gli stili di viaggio dell'utente e quelli del viaggio
    int stiliComuni = 0;
    for (String style in stiliViaggio) {
      if (stiliViaggioUtente.contains(style)) {
        stiliComuni++;
      }
    }
    return (stiliComuni / stiliViaggio.length) * 100;
  }

  Widget listViaggi({required Map viaggio}) {
    String viaggioUid = viaggio['key'];
    return FutureBuilder<String>(
      future: _getImageUrl(viaggioUid),
      builder: (context, snapshot) {
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/dettagliViaggio',
              arguments: {
                'viaggio': viaggio,
                'imageUrl': snapshot.data!,
              }
              );

          },
          child: Card(
            elevation: 4,
            margin: EdgeInsets.all(8),
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: snapshot.hasData && snapshot.data != ''
                    ? DecorationImage(
                  image: NetworkImage(snapshot.data!),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
                )
                    : null,
              ),
              child: snapshot.connectionState == ConnectionState.waiting
                  ? Center(child: CircularProgressIndicator())
                  : Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Compatibilità:${_calculateCompatibility(List<String>.from(viaggio['stili'])).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          viaggio['Titolo'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${viaggio['Città']}, ${viaggio['Nazione']}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(width: 4), // Spazio a sinistra per allineare il contenuto
                        Expanded(
                          child: Container(),
                        ),
                        Row(
                          children: [
                            Icon(Icons.group, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              '${viaggio['Partecipanti'].length} / ${viaggio['Max partecipanti']}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FilterDialog(
          onApply: (DateTimeRange? dateRange, double budget, double compatibility) {
            setState(() {
              _selectedDateRange = dateRange;
              _selectedBudget = budget;
              _selectedCompatibility = compatibility;
            });
          },
          initialDateRange: _selectedDateRange,
          initialBudget: _selectedBudget,
          initialCompatibility: _selectedCompatibility,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        child: FirebaseAnimatedList(
          query: viaggiRef,
          itemBuilder: (BuildContext context, DataSnapshot snapshot, Animation<double> animation, int index) {
            Map viaggio = snapshot.value as Map;
            viaggio['key'] = snapshot.key;
            if (!_filterViaggio(viaggio)) {
              return Container(); // Ritorna un container vuoto se il viaggio non passa i filtri
            }

            return listViaggi(viaggio: viaggio);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showFilterDialog();
        },
        backgroundColor: Color(0xff7480FB),
        child: Image.asset(
          'assets/settings-sliders.png',
          color: Colors.white,
        ),
      ),
    );
  }
}
