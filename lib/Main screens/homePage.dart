import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Profilo.dart';
import 'Viaggi.dart';
import 'CreaViaggio.dart';

class homePage extends StatefulWidget {
  const homePage({super.key});

  @override
  State<homePage> createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    ViaggiScreen(),
    CreateViaggioScreen(),
    ProfileScreen(),
  ];

  final List<String> _titles = ['Viaggi', 'Crea', 'Profilo'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xffd651f4),
        title:
          Text(
            _titles[_currentIndex],
            style: GoogleFonts.dmSerifText(
              textStyle: TextStyle(color: Colors.white),
              fontSize: 30,
            ),
            ),
        leading: Image.asset(
          'assets/logo_bianco.png',
          height: 30,
        ),

      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: GNav(
        selectedIndex: _currentIndex,
        onTabChange: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Color(0xffd651f4),
        color: Colors.white,
        activeColor: Colors.white,
        gap: 8,
        padding: EdgeInsets.all(20),
        tabs: [
          GButton(
            icon: LineIcons.planeDeparture,
            text: 'Viaggi',
            textStyle: GoogleFonts.dmSerifText(
              textStyle: TextStyle(color: Colors.white),
              fontSize: 20,
            ),
          ),
          GButton(
            icon: LineIcons.plus,
            text: 'Crea',
            textStyle:GoogleFonts.dmSerifText(
              textStyle: TextStyle(color: Colors.white),
              fontSize: 20,
            ),
          ),
          GButton(
            icon: LineIcons.user,
            text: 'Profilo',
            textStyle: GoogleFonts.dmSerifText(
              textStyle: TextStyle(color: Colors.white),
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}