import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService{
  FirebaseAuth _auth=FirebaseAuth.instance;
  Future<User?> createUser(String email,String password) async{
    try{
      UserCredential credential=await _auth.createUserWithEmailAndPassword(email: email, password: password); //crea un utente
      return credential.user;
    }catch(e){
      print("Qualcosa è andato storto${e}");
    }
    return null;

  }
  Future<User?> loginUser(String email,String password) async{
    try{
      UserCredential credential=await _auth.signInWithEmailAndPassword(email: email, password: password); //fa il log di un utente
      return credential.user;
    }catch(e){
      print("Qualcosa è andato storto");
    }
    return null;

  }
  Future<void> signOut() async{
    try{
      await _auth.signOut();
    }catch(e){
      print("Qualcosa è andato storto");
    }
    return null;

  }

}