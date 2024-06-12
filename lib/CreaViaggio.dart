import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

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

class CreateViaggioScreen extends StatefulWidget {
  const CreateViaggioScreen({super.key});

  @override
  _CreateViaggioScreenState createState() => _CreateViaggioScreenState();
}

class _CreateViaggioScreenState extends State<CreateViaggioScreen> {
  final _nomeController = TextEditingController();
  final _budgetController = TextEditingController();
  final _maxPartecipantiController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedCountry;
  String? _selectedCity;
  DateTimeRange? _selectedDateRange;
  List<String> _countries = [];
  List<String> _filteredCountries = [];
  Map<String, List<String>> _dataMap = {};
  List<String> _stiliViaggio= [
    'Relax',
    'Divertimento',
    'Cultura',
    'Avventura',
    'Gastronomico',
    'Esplorazione naturale',
    'Viaggi di lusso',
  ];

  List<String> _selectedStiliViaggio = [];

  int _activeStepIndex = 0;
  bool get isFirstStep => _activeStepIndex == 0;
  bool get isLastStep => _activeStepIndex == stepList().length - 1;

  UploadTask? uploadTask;
  bool _isLoading = false;
  Uint8List? _image;
  File? selectedIMage;

  Widget build(BuildContext context) {
    return _isLoading ? LoadingScreen() : buildMainScreen(); // Mostra la schermata di caricamento se isLoading è true
  }

  @override
  void initState() {
    super.initState();
    _loadCSV();
  }

  List<Step> stepList() => [ //lista degli step per il form
    Step(
      isActive: _activeStepIndex >= 0,
      title: const Text(""),
      content: _metaStepContent(),
    ),
    Step(
      isActive: _activeStepIndex >= 1,
      title: const Text(""),
      content: _preferenzeStepContent(),
    ),
    Step(
      isActive: _activeStepIndex >= 2,
      title: const Text(""),
      content: _stiliStepContent(),
    ),
  ];

  Widget _metaStepContent() {
    return Column(
      children: [
        TextFormField(
          controller: _nomeController,
          decoration: InputDecoration(
            labelText: 'Nome',
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xff7480FB)),
            ) ,
            contentPadding: EdgeInsets.all(10),
          ),
        ),
        SizedBox(height: 10),
        TextFormField(
          controller: _budgetController,
          decoration: InputDecoration(
            labelText: 'Budget per persona(€)',
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xff7480FB)),
            ) ,
            contentPadding: EdgeInsets.all(10),
          ),
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 10),
        TextFormField(
          controller: _maxPartecipantiController,
          decoration: InputDecoration(
            labelText: 'Max Partecipanti',
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xff7480FB)),
            ) ,
            contentPadding: EdgeInsets.all(10),
          ),
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 10),
        ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: BorderSide(color: Colors.grey),
          ),
          title: Text(
            _selectedDateRange == null
                ? 'Seleziona il range di date'
                : '${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.end)}',
          ),
          leading: Icon(Icons.date_range_outlined),
          onTap: () async {
            final pickedDateRange = await showDateRangePicker(
              context: context,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(Duration(days: 700)),
            );

            if (pickedDateRange != null) {
              setState(() {
                _selectedDateRange = pickedDateRange;
              });
            }
          },
        ),
        SizedBox(height: 10),
        DropdownSearch<String>(
          items: _filteredCountries,
          dropdownDecoratorProps: DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Cerca Nazione',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          onChanged: onCountryChanged,
          selectedItem: _selectedCountry,
          popupProps: PopupProps.menu(
            showSearchBox: true,
          ),
        ),
        SizedBox(height: 10),
        DropdownSearch<String>(
          items: _dataMap[_selectedCountry] ?? [],
          dropdownDecoratorProps: DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Cerca Città',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          onChanged: onCityChanged,
          selectedItem: _selectedCity,
          popupProps: PopupProps.menu(
            showSearchBox: true,
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(
                hintText: 'Cerca...',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _preferenzeStepContent() {
    return Column(
      children: [
        Stack(
          children: [
            _image != null
                ? Container(
                width: MediaQuery.of(context).size.width,
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: MemoryImage(_image!),
                    fit: BoxFit.cover, // Per adattare l'immagine al contenitore
                  ),
                  ),
                )
                : Container(
                width: MediaQuery.of(context).size.width,
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: AssetImage("assets/no_image.png"),
                    fit: BoxFit.cover, // Per adattare l'immagine al contenitore
                    ),
                ),
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
        SizedBox(height: 20),
        TextFormField(
          controller: _descriptionController,
          decoration: InputDecoration(
            labelText: 'Dettagli viaggio',
            hintText: 'Specifica alcuni dettagli del viaggio(Itinerario,alloggi,mezzi di trasporto...)',
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xff7480FB)),
            ) ,
            contentPadding: EdgeInsets.all(10),
          ),
          maxLines: 6,
        ),

      ],
    );
  }

  Widget _stiliStepContent() {
    return Column(
     children:[
       Text('Stili di viaggio(almeno 2)',
          style: GoogleFonts.dmSerifText(
          fontWeight: FontWeight.bold,
          fontSize: 20,

    ),),
       SizedBox(height: 20,),
       Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Color(0xff7480FB),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: _stiliViaggio.map((passion) {
          return Row(
            children: [
              Checkbox(
                value: _selectedStiliViaggio.contains(passion),
                side: BorderSide(
                  color: Colors.white, // Modifica il colore del bordino qui
                  width: 2.0, // Opzionale: puoi regolare anche la larghezza del bordino
                ),
                activeColor: Color(0xffd651f4),
                onChanged: (isChecked) {
                  setState(() {
                    if (isChecked != null && isChecked) {
                      _selectedStiliViaggio.add(passion);
                    } else {
                      _selectedStiliViaggio.remove(passion);
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
    )
    ],
    );
  }
  // Mostra le opzioni di selezione dell'immagine
  void showImagePickerOption(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 150,
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.image_outlined),
                title: Text('Galleria'),
                onTap: () {
                  _pickImage(ImageSource.gallery); // Scegli un'immagine dalla galleria
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt_outlined),
                title: Text('Fotocamera'),
                onTap: () {
                  _pickImage(ImageSource.camera); // Scatta una foto dalla fotocamera
                },
              ),
            ],
          ),
        );
      },
    );
  }
  // Scegli un'immagine dalla galleria o dalla fotocamera
  Future _pickImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(source: source);
    if (pickedImage != null) {
      // Visualizza l'immagine selezionata
      setState(() {
        selectedIMage = File(pickedImage.path);
        _image = File(pickedImage.path).readAsBytesSync();
      });
    }
    Navigator.of(context).pop();
  }
  // Carica l'immagine selezionata sullo storage di Firebase
  Future<bool> _creaViaggio() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      final database = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: "https://weflyflutter-default-rtdb.europe-west1.firebasedatabase.app",
      );

      DatabaseReference viaggioRef = database.ref().child('Viaggi');
      DatabaseReference nuovoViaggioRef = viaggioRef.push();
      String viaggioUid = nuovoViaggioRef.key!;

      String imagePath = 'travels_images/$viaggioUid.jpg';
      final ref = FirebaseStorage.instance.ref().child(imagePath);

      await nuovoViaggioRef.set({
        'Titolo': _nomeController.text,
        'Budget': int.parse(_budgetController.text),
        'Descrizione': _descriptionController.text,
        'Max partecipanti': int.parse(_maxPartecipantiController.text),
        'Città': _selectedCity,
        'Nazione': _selectedCountry,
        'Data inizio': _selectedDateRange?.start.toIso8601String(),
        'Data fine': _selectedDateRange?.end.toIso8601String(),
        'stili':_selectedStiliViaggio,
        'Partecipanti': [userId],
      });
      print("caricati dati viaggio");
      uploadTask = ref.putFile(selectedIMage!);
      final snapshot = await uploadTask!.whenComplete(() {});
      return true;
    } catch (e) {
      print("Errore durante la creazione del viaggio: $e");
      showToastMessage("Errore durante il salvataggio dei dati");
      return false;
    }
  }


  void _check() async{
      //controlla se tutti i campi sono compleatati
      if (_nomeController.text.isEmpty ||
          _budgetController.text.isEmpty ||
          _maxPartecipantiController.text.isEmpty ||
          _descriptionController.text.isEmpty ||
          _selectedCountry == null ||
          _selectedCity == null ||
          _selectedDateRange ==null ||
          _selectedStiliViaggio.length < 2) {
        showToastMessage("Completa tutti i campi");
        return;
      }
      if(_image == null){
        showToastMessage("Scegli un immagine per il viaggio");
        return;
      }
      //se sono completati:
      setState(() {
        _isLoading = true; // Attiva lo stato di caricamento quando il caricamento è completato
      });
      bool success = await _creaViaggio();

      if (success) {
        showToastMessage("Viaggio creato");
        //ripulisco i campi
        _nomeController.clear();
        _budgetController.clear();
        _maxPartecipantiController.clear();
        _descriptionController.clear();
        setState(() {
          _selectedCity = null;
          _selectedCountry = null;
          _image = null;
          _selectedDateRange = null;
        });

      } else {
        showToastMessage("Errore nella creazione del viaggio");
      }
      setState(() {
        _isLoading = false; // Disattiva lo stato di caricamento quando il caricamento è completato
      });
    }



  Future<void> _loadCSV() async {
    try {
      final _rawData = await rootBundle.loadString("assets/citiesNations.csv");
      // Usa `compute` per eseguire il parsing del CSV in un isolato separato
      Map<String, List<String>> dataMap = await compute(_parseCSV, _rawData);

      // Estrai le nazioni univoche
      List<String> uniqueCountries = dataMap.keys.toList();

      setState(() {
        _dataMap = dataMap;
        _countries = uniqueCountries;
        _filteredCountries = uniqueCountries;
      });
    } catch (e) {
      print("Error loading CSV file: $e");
    }
  }

  static Map<String, List<String>> _parseCSV(String rawData) {
    List<List<dynamic>> _listData = const CsvToListConverter().convert(rawData);
    Map<String, List<String>> dataMap = {};
    for (var row in _listData) {
      if (row.length >= 2) {
        String cityName = row[0].toString();
        String countryName = row[1].toString();
        if (!dataMap.containsKey(countryName)) {
          dataMap[countryName] = [];
        }
        dataMap[countryName]!.add(cityName);
      }
    }
    return dataMap;
  }

  void _filterCountries(String keyword) {
    setState(() {
      _filteredCountries = _countries
          .where((country) => country.toLowerCase().contains(keyword.toLowerCase()))
          .toList();
    });
  }

  void onCountryChanged(String? value) {
    setState(() {
      _selectedCountry = value;
      _selectedCity = null;
    });
  }

  void onCityChanged(String? value) {
    setState(() {
      _selectedCity = value;
    });
  }


  Widget buildMainScreen() {
    return Scaffold(
      body: Stepper(
        steps: stepList(),
        type: StepperType.horizontal,
        currentStep: _activeStepIndex,
        onStepTapped: (step) => setState(() => _activeStepIndex = step),
        onStepContinue: () {
          if (isLastStep) {
            _check();
            setState(() => _activeStepIndex = 0);
          } else {
            setState(() => _activeStepIndex += 1);
          }
        },
        onStepCancel: isFirstStep ? null : () => setState(() => _activeStepIndex -= 1),
        controlsBuilder: (context, details) => Padding(
          padding: const EdgeInsets.only(top: 32),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: details.onStepContinue,
                  child: Text(isLastStep ? 'Crea' : 'Continua'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: isFirstStep ? null : details.onStepCancel,
                  child: const Text("Indietro"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void showToastMessage(String message) =>
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Color(0xff7480FB),
        textColor: Colors.white,
        fontSize: 16.0,
      );
}
