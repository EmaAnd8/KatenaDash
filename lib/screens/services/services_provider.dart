


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:katena_dashboard/firebase_options.dart';
import 'package:katena_dashboard/screens/dashboard/dashboard_screen.dart';
import 'package:katena_dashboard/screens/login/login_screen.dart';
import 'package:katena_dashboard/screens/services/services_provider.dart';
import 'package:katena_dashboard/screens/settings/settings_screen.dart';

enum AuthStatus {
  successful,
  wrongPassword,
  emailAlreadyExists,
  invalidEmail,
  weakPassword,
  unknown,
}



class AuthExceptionHandler {
  static handleAuthException(FirebaseAuthException e) {
    AuthStatus status;
    switch (e.code) {
      case "invalid-email":
        status = AuthStatus.invalidEmail;
        break;
      case "wrong-password":
        status = AuthStatus.wrongPassword;
        break;
      case "weak-password":
        status = AuthStatus.weakPassword;
        break;
      case "email-already-in-use":
        status = AuthStatus.emailAlreadyExists;
        break;
      default:
        status = AuthStatus.unknown;
    }
    return status;
  }
  static String generateErrorMessage(error) {
    String errorMessage;
    switch (error) {
      case AuthStatus.invalidEmail:
        errorMessage = "Your email address appears to be malformed.";
        break;
      case AuthStatus.weakPassword:
        errorMessage = "Your password should be at least 6 characters.";
        break;
      case AuthStatus.wrongPassword:
        errorMessage = "Your email or password is wrong.";
        break;
      case AuthStatus.emailAlreadyExists:
        errorMessage =
        "The email address is already in use by another account.";
        break;
      default:
        errorMessage = "An error occured. Please try again later.";
    }
    return errorMessage;
  }
}

class Provider {

  final storage = FirebaseStorage.instance;
  final db = FirebaseFirestore.instance;


  Provider._privateConstructor(); // Private empty constructor

  static Provider _instance = Provider._privateConstructor();


  // Factory constructor that can return an instance
  static Provider get instance {

    return _instance;
  }
  /*
  void Begin()
  async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }


*/


  void ParadoxSignout(context)
  {
    Provider serviceProvider=Provider.instance;
    serviceProvider.Signout();
    Navigator.push(context, MaterialPageRoute(builder: (context){return LoginScreen();},),);
  }


  void  ChangeEmail(context,email) async
  {
    String previousEmail="";
    if (FirebaseAuth.instance.currentUser?.email != null) {
      previousEmail =FirebaseAuth.instance.currentUser!.email! ;
    } else {
      previousEmail ="";
    }
    if (FirebaseAuth.instance.currentUser?.email?.compareTo(email) != 0){
      FirebaseAuth.instance.currentUser?.verifyBeforeUpdateEmail(email);
      FirebaseAuth.instance.currentUser?.reload();
      if (FirebaseAuth.instance.currentUser!.emailVerified) {

        User? user= FirebaseAuth.instance.currentUser;
        CollectionReference users = FirebaseFirestore.instance.collection('Users');
        //print(user?.email);

        // Update the population of a city
        final query = users.where("email", isEqualTo: previousEmail).get()
            .then((querySnapshot) {
          print("Successfully completed");
          for (var docSnapshot in querySnapshot.docs) {
            final usersRef = users.doc(docSnapshot.id);
            usersRef.update({"email": email}).then(

                    (value) =>ParadoxSignout(context),
                onError: (e) => print("Error updating document $e"));

          }
        },
          onError: (e) => print("Error completing: $e"),
        );

      }
    }else
    {
      Navigator.push(context, MaterialPageRoute(builder: (context){return SettingsScreen();},),);
    }
  }
  void CName(context,name) async
  {



    //authentication provided from firebase

    try {
      // if my email is verified then I signin otherwise error



      User? user= FirebaseAuth.instance.currentUser;
      CollectionReference users = FirebaseFirestore.instance.collection('Users');
      print(user?.email);
      print(name);
      // Update the population of a city
      final query = users.where("email", isEqualTo: FirebaseAuth.instance.currentUser?.email).get()
          .then((querySnapshot) {
        print("Successfully completed");
        for (var docSnapshot in querySnapshot.docs) {
          final usersRef = users.doc(docSnapshot.id);
          usersRef.update({"Name": name}).then(
                  (value) => print("DocumentSnapshot successfully updated!"),
              onError: (e) => print("Error updating document $e"));

        }
      },
        onError: (e) => print("Error completing: $e"),
      );


      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){return SettingsScreen();},),);
    }on  FirebaseAuthException catch(e)
    {
      print(e);
    }
  }

  void Login(context,email,password) async
  {





    try {
      // if my email is verified then I signin otherwise error
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email, password: password);

      if(FirebaseAuth.instance.currentUser!.emailVerified) {

        Navigator.push(context, MaterialPageRoute(builder: (context){return HomeScreen();},),);

      }
    }on  FirebaseAuthException catch(e)
    {
      print(e);
    }
  }

  void Register(user,email,password) async
  {







    // I create a User

    await  FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);


    // I send and email for saying if the provided email is fine
    FirebaseAuth.instance.currentUser?.sendEmailVerification();
    //if the user is verified I can add him to the database
    db.collection("Users").add(user).then((DocumentReference doc) =>
        print('DocumentSnapshot added with ID: ${doc.id}'));

  }

   void Signout() async
  {




    //authentication provided from firebase

    try {
      // if my email is verified then I signin otherwise error



      await FirebaseAuth.instance.signOut();

    }on  FirebaseAuthException catch(e)
    {
      print(e);
    }
  }


  Future<AuthStatus>  PasswordReset(email) async
  {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    AuthStatus _status=AuthStatus.unknown;

    Provider serviceProvider=Provider.instance;

    //authentication provided from firebase
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email)
        .then((value) => _status = AuthStatus.successful).catchError((e) => _status = AuthExceptionHandler.handleAuthException(e));

    return _status;
  }

}