import 'package:flutter/material.dart';

import 'package:katena_dashboard/screens/services/services_provider.dart';

import '../settings/settings_screen.dart';

//constants

String email = "";







String  pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
RegExp regExp = new RegExp(pattern);
class ChangeEmailBody extends StatefulWidget{
  const ChangeEmailBody({super.key});

  @override
  _ChangeEmailState createState() =>  _ChangeEmailState();


}

class  _ChangeEmailState extends State<ChangeEmailBody> {
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
                      Provider serviceProvider=Provider.instance;
                       serviceProvider.ChangeEmail(context,email);
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