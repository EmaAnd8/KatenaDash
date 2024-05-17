import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:katena_dashboard/screens/login/login_screen.dart';
import 'package:katena_dashboard/screens/settings/settings_screen.dart';
import '../../firebase_options.dart';

//constants

String name='';
class ChangeNameBody extends StatefulWidget{
  const ChangeNameBody({super.key});

  @override
  _ChangeNameState createState() =>  _ChangeNameState();


}

class  _ChangeNameState extends State<ChangeNameBody> {
  final _formKey = GlobalKey<FormState>();

  void CName() async
  {



    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
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
              const Text("Change the name"),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                child: SizedBox(
                  width: 400,


                  child:TextFormField(
                    decoration:  InputDecoration(
                      fillColor: Colors.black,
                      labelText: "name",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),

                      hintText: "",
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please enter your name";
                      }
                      // Add email validation logic here (e.g., check for @ and .)
                      if(!RegExp(r'^[a-z0-9_-]{3,15}$').hasMatch(value!))
                      {
                        return "enter a valid name.";

                      }
                      return null;
                    },
                    onSaved: (value) {
                      name = value!;
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

                        CName();

                    }
                  },


                  child:const Text('change name'),


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