import 'package:flutter/material.dart';


class registerScreen extends StatelessWidget {
  const registerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     body: Container(
       height: double.infinity,
       width: double.infinity,
       decoration: const BoxDecoration(
         gradient: LinearGradient(
           colors: [
             Color(0xffd651f4),
             Color(0xff1c29e0),
           ]
         )
       ),
       child: Column(
         children: [
           const Padding(
             padding: EdgeInsets.only(top: 100.0),
             child: Image(
               image: AssetImage('assets/logo_bianco.png'),
               height: 200, // Imposta l'altezza desiderata
               width: 200,  // Imposta la larghezza desiderata
             ),

           ),
           const SizedBox(
             height: 60,
           ),

          GestureDetector(
            onTap: (){
              Navigator.pushNamed(
                context,
                '/signIn',
              );
            },
            child: Container(
              height: 53,
              width: 320,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white),
              ),
              child: const Center(child: Text('ACCEDI',style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white
              ),),),
            ),
          ),
           const SizedBox(height: 30,),
           GestureDetector(
             onTap: (){
               Navigator.pushNamed(
                   context,
                   '/signUp',
               );
             },
             child: Container(
               height: 53,
               width: 320,
               decoration: BoxDecoration(
                 color: Colors.white,
                 borderRadius: BorderRadius.circular(30),
                 border: Border.all(color: Colors.white),
               ),
               child: const Center(child: Text('REGISTRATI',style: TextStyle(
                   fontSize: 20,
                   fontWeight: FontWeight.bold,
                   color: Colors.black
               ),),),
             ),
           ),
          ]
       ),
     ),

    );
  }
}
