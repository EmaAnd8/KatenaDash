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

// Constants and variables
String username = "";
String email = "";
String password = "";
String birthdate = "";
String name = "";
String surname = "";
String pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
RegExp regExp = RegExp(pattern);

class SignupBody extends StatefulWidget {
  const SignupBody({super.key});

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignupBody> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size; // With this query I get (w,h) of the screen
    return Scaffold(
      backgroundColor: Colors.white, // Set the background color to white
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: size.height * 0.1),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white, // Set the background color to white
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset("assets/icons/icons8-chains-emoji-96.png"),
                  const SizedBox(height: 20),
                  const Text(
                    "Welcome to BlockVerse",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: 400,
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: "Username",
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        prefixIcon: Icon(Icons.person, color: Colors.blue),
                        filled: true,
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter your username";
                        }
                        if (!RegExp(r'^[a-z0-9_-]{3,15}$').hasMatch(value)) {
                          return "Please enter a valid username.";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        username = value!;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 400,
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: "Name",
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        prefixIcon: Icon(Icons.account_circle, color: Colors.blue),
                        filled: true,
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter your Name";
                        }
                        if (!RegExp(r'^[a-zA-Z\s]{3,15}$').hasMatch(value)) {
                          return "Please enter a valid name.";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        name = value!;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 400,
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: "Birthdate",
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        prefixIcon: Icon(Icons.calendar_today, color: Colors.blue),
                        filled: true,
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter your Birthdate";
                        }
                        if (!RegExp(r'^(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])-\d{4}$').hasMatch(value)) {
                          return "Please enter a valid Birthdate.";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        birthdate = value!;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 400,
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: "Email",
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        prefixIcon: Icon(Icons.email, color: Colors.blue),
                        filled: true,
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter your email";
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return "Enter a valid Email address.";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        email = value!;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 400,
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: "Password",
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        prefixIcon: Icon(Icons.lock, color: Colors.blue),
                        filled: true,
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter your password";
                        }
                        if (!regExp.hasMatch(value)) {
                          return "Please enter a valid password";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        password = value!;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 400,
                    child: ElevatedButton(
                      onPressed: () async {
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
                          Provider serviceProvider = Provider.instance;
                          serviceProvider.Register(user, email, password);

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) {
                              return LoginScreen();
                            }),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                    },
                    child: const Text(
                      'Go back',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

