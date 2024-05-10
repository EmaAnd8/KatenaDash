import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../../firebase_options.dart';

//constants

String username = "";
String email = "";
String password = "";

class SignupBody extends StatefulWidget{
  const SignupBody({super.key});

  @override
  _SignUpFormState createState() => _SignUpFormState();


}

class _SignUpFormState extends State<SignupBody> {
  final _formKey = GlobalKey<FormState>();


  void Register() async
  {



    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
      await  FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
  }






  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset("assets/icons/icons8-chains-emoji-96.png"),
          const Text("Welcome to BlockVerse"),
          TextFormField(
            decoration: const InputDecoration(
              labelText: "Username",
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return "Please enter your username";
              }
              return null;
            },
            onSaved: (value) {
              username = value!;
            },
          ),
          TextFormField(
            decoration: const InputDecoration(
              labelText: "Name",
              ),
                validator: (value) {
                if (value!.isEmpty) {
                return "Please enter your Name";
                }
                // Add email validation logic here (e.g., check for @ and .)
                return null;
                },
                onSaved: (value) {
                email = value!;
                },

          ),

          TextFormField(
            decoration: const InputDecoration(
              labelText: "Birthdate",
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return "Please enter your Birthdate";
              }
              // Add email validation logic here (e.g., check for @ and .)
              return null;
            },
            onSaved: (value) {
              email = value!;
            },

          ),
          TextFormField(
            decoration: const InputDecoration(
              labelText: "Email",
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return "Please enter your email";
              }
              // Add email validation logic here (e.g., check for @ and .)
              return null;
            },
            onSaved: (value) {
              email = value!;
            },
          ),
          TextFormField(
            decoration: const InputDecoration(
              labelText: "Password",
            ),
            obscureText: true,
            validator: (value) {
              if (value!.isEmpty) {
                return "Please enter your password";
              }
              // Add password strength validation logic here (e.g., min length)
              return null;
            },
            onSaved: (value) {
              password = value!;
              print(password);
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: ()async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  Register();
                }

              },
              child: const Text('Sign Up'),
            ),
          ),
        ],
      ),
    );
  }
}