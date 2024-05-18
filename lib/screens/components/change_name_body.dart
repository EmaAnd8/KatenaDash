import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:katena_dashboard/screens/services/services_provider.dart';
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
                      WidgetsFlutterBinding.ensureInitialized();
                      await Firebase.initializeApp(
                        options: DefaultFirebaseOptions.currentPlatform,
                      );
                        Provider serviceProvider= Provider.instance;
                        serviceProvider.CName(context,name);

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