import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:katena_dashboard/firebase_options.dart';
import 'package:katena_dashboard/screens/components/login_body.dart';
import 'package:katena_dashboard/screens/login/login_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:katena_dashboard/screens/services/services_provider.dart';


//constants and variables

String username = "";
String email = "";
String password = "";
String birthdate = "";
String name = "";
String surname = "";
String  pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
RegExp regExp = new RegExp(pattern);
class SignupBody extends StatefulWidget{
  const SignupBody({super.key});

  @override
  _SignUpFormState createState() => _SignUpFormState();


}

class _SignUpFormState extends State<SignupBody> {
  final _formKey = GlobalKey<FormState>();









  @override
  Widget build(BuildContext context) {
    Size size=MediaQuery.of(context).size; //with this query I get (w,h) of the screen
        return Scaffold(

    body: Container(

      width: size.width,
    child:Container(
      color: Colors.white, // Set the background color to white
     child: Form(

      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: <Widget>[

          Image.asset("assets/icons/icons8-chains-emoji-96.png"),
          const Text("Welcome to BlockVerse"),
         Container(
           margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
         child:SizedBox(
           width: 400,
          child:TextFormField(
            decoration:  InputDecoration(
              labelText: "Username",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              hintText: "",
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return "Please enter your username";
              }

              //Logic to validate the username
              // Add name validation logic here (e.g., check for @ and .)
              if(!RegExp(r'^[a-z0-9_-]{3,15}$').hasMatch(value!))
              {
                return "Please enter a valid username.";
              }
              return null;
            },
            onSaved: (value) {
              username = value!;
            },
          ),
         ),
         ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child:SizedBox(
            width: 400,
          child:TextFormField(
            decoration:  InputDecoration(
              labelText: "Name",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              hintText: "",
              ),
                validator: (value) {
                if (value!.isEmpty) {
                return "Please enter your Name";
                }
                // Add name validation logic here (e.g., check for @ and .)
                    if(!RegExp(r'^[a-z0-9_-]{3,15}$').hasMatch(value!))
                    {
                      return "Please enter a valid name.";
                    }

                return null;
                },
                onSaved: (value) {
                name = value!;
                },

          ),
          ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child:SizedBox(
            width: 400,
          child:TextFormField(
            decoration:  InputDecoration(
              labelText: "Birthdate",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              hintText: "",
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return "Please enter your Birthdate";
              }
              // Add birthdate validation logic here (e.g., check for @ and .)
              if(!RegExp(r'^(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])-\d{4}$').hasMatch(value!))
              {
                return "Please enter a valid Birthdate.";
              }
              return null;
            },
            onSaved: (value) {
              birthdate = value!;
            },

          ),
          ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child:SizedBox(
            width: 400,
          child:TextFormField(
            decoration: InputDecoration(
              labelText: "Email",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              hintText: "",
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return "Please enter your email";
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
          Container(
          margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child:SizedBox(
            width: 400,
          child:TextFormField(
            decoration: InputDecoration(
              labelText: "Password",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),

              hintText: "",
            ),
            obscureText: true,
            validator: (value) {
              if (value!.isEmpty) {
                return "Please enter your password";
              }
              // Add password strength validation logic here (e.g., min length)
                if(!regExp.hasMatch(value!))
                  {
                    return "Please enter a valid password";
                  }
              return null;
            },
            onSaved: (value) {
              password = value!;
              print(password);
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

                  // Create a new user with a first and last name
                  final user = <String, dynamic>{
                    "Name": name,
                    "email": email,
                    "Birthdate": birthdate,
                    "Username": username,

                  };
                  WidgetsFlutterBinding.ensureInitialized();
                  await Firebase.initializeApp(
                    options: DefaultFirebaseOptions.currentPlatform,
                  );
                  Provider serviceProvider=Provider.instance;
                  serviceProvider.Register(user,email,password);

                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){return LoginScreen();},),);

                }

              },

              style: ElevatedButton.styleFrom(
                    textStyle: const TextStyle(color: Colors.white)
              ),

              child: const Text('Sign Up'),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){return LoginScreen();},),);
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
    ),
    );
  }
}