import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:katena_dashboard/firebase_options.dart';
import 'package:katena_dashboard/screens/forgotpwd/forgot_password_screen.dart';
import 'package:katena_dashboard/screens/services/services_provider.dart';
import 'package:katena_dashboard/screens/signup/signup_screen.dart';


//constants

String email = "";
String password = "";

String  pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
RegExp regExp = new RegExp(pattern);
class LoginBody extends StatefulWidget{
  const LoginBody({super.key});

  @override
  _LoginFormState createState() => _LoginFormState();


}

class _LoginFormState extends State<LoginBody> {
  final _formKey = GlobalKey<FormState>();










  @override
  Widget build(BuildContext context) {
    Size size=MediaQuery.of(context).size; //with this query I get (w,h) of the screen
    return Container(
      width: size.width,
      child:Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset("assets/icons/icons8-chains-emoji-96.png"),
          const Text("Welcome to BlockVerse"),
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
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child:SizedBox(
            width: 400,
          child:TextFormField(
            decoration:  InputDecoration(
              labelText: "Password",
              fillColor: Colors.black,
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
              if(!regExp.hasMatch(value))
              {
                return "Please enter a valid password";
              }
              return null;
            },
            onSaved: (value) {
              password = value!;
              //print(password);
            },
          ),
          ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: ()async {
                try{


    if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();

                  //Invoke the method for Login
                  WidgetsFlutterBinding.ensureInitialized();
                  await Firebase.initializeApp(
                    options: DefaultFirebaseOptions.currentPlatform,
                  );
                  Provider serviceProvider = Provider.instance;
                  serviceProvider.Login(context, email, password);
                  //if I am logged in I go to the dashboard

                  //FirebaseAuth.instance.signOut();
                  if (FirebaseAuth.instance.currentUser!.emailVerified) {


                  } else {
                    const Text(
                      'you are not logged in',
                      style: TextStyle(color: Colors.red),
                    );
                  }

                }
                }catch(e)
                {
                  print(e);
                }


              },

               child:const Text('Login'),


            ),

          ),
        Container(
        child:GestureDetector(
          onTap: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){return ResetPasswordScreen();},),);
          },
          child: const Text(
            'Forgot password?',
            style: TextStyle(color: Colors.black),
          ),
        ),
        ),
      GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context){return SignupScreen();},),);
        },
         child:const Text(
            'if you do not have an account go to sign up',
           style: TextStyle(color: Colors.black),
          ),
      ),


        ],
      ),
      ),

    );

  }
}