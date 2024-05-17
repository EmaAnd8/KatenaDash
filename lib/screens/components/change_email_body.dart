import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:katena_dashboard/screens/login/login_screen.dart';
import '../../firebase_options.dart';
import '../settings/settings_screen.dart';

//constants

String email = "";
String previousEmail="";






String  pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
RegExp regExp = new RegExp(pattern);
class ChangeEmailBody extends StatefulWidget{
  const ChangeEmailBody({super.key});

  @override
  _ChangeEmailState createState() =>  _ChangeEmailState();


}

class  _ChangeEmailState extends State<ChangeEmailBody> {
  final _formKey = GlobalKey<FormState>();


  void  ChangeEmail() async
  {
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
          print(user?.email);

          // Update the population of a city
          final query = users.where("email", isEqualTo: previousEmail).get()
              .then((querySnapshot) {
            print("Successfully completed");
            for (var docSnapshot in querySnapshot.docs) {
              final usersRef = users.doc(docSnapshot.id);
              usersRef.update({"email": email}).then(

                      (value) =>ParadoxSignout(),
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




void ParadoxSignout()
{
  FirebaseAuth.instance.signOut();
  Navigator.push(context, MaterialPageRoute(builder: (context){return LoginScreen();},),);
}



  @override
  Widget build(BuildContext context) {
    Size size=MediaQuery.of(context).size; //with this query I get (w,h) of the screen
    return Container(
      width: size.width,


      child:Form(
        key: _formKey,
        child:Container(
          width: size.width,

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset("assets/icons/icons8-chains-emoji-96.png"),
              const Text("Change The Email"),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                child: SizedBox(
                  width: 400,


                  child:TextFormField(
                    decoration:  InputDecoration(
                      fillColor: Colors.black,
                      labelText: "Email",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),

                      hintText: "",
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please enter the new email";
                      }
                      // Add email validation logic here (e.g., check for @ and .)
                      if(!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!))
                      {
                        return "enter a valid Email address.";

                      }
                      return null;
                    },
                    onSaved: (value) {
                      email = value!;
                    },
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: ()async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                        //Invoke the method to change the password
                       ChangeEmail();
                    }
                  },


                  child:const Text('Change Email'),


                ),

              ),

              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context){return SettingsScreen();},),);
                },
                child:const Text(
                  'Go back',
                  style: TextStyle(color: Colors.black),
                ),
              ),




            ],
          ),
        ),
      ),
    );
  }
}