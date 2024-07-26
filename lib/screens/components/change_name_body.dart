import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:katena_dashboard/screens/services/services_provider.dart';
import 'package:katena_dashboard/screens/settings/settings_screen.dart';
import '../../firebase_options.dart';

// Constants
String name = '';

class ChangeNameBody extends StatefulWidget {
  const ChangeNameBody({Key? key}) : super(key: key);

  @override
  _ChangeNameState createState() => _ChangeNameState();
}

class _ChangeNameState extends State<ChangeNameBody> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size; // Get the width and height of the screen

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: size.height * 0.1),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset("assets/icons/icons8-chains-emoji-96.png"),
                  const SizedBox(height: 20),
                  const Text(
                    "Change the Name",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,color: Colors.blue),
                  ),
                  const SizedBox(height: 30),
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
                        prefixIcon: Icon(Icons.person, color: Colors.blue),
                        filled: true,
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter your name";
                        }
                        if (!RegExp(r'^[a-zA-Z\s]{3,15}$').hasMatch(value)) {
                          return "Enter a valid name.";
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
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          WidgetsFlutterBinding.ensureInitialized();
                          await Firebase.initializeApp(
                            options: DefaultFirebaseOptions.currentPlatform,
                          );
                          Provider serviceProvider = Provider.instance;
                          serviceProvider.CName(context, name);
                          const snackBar = SnackBar(
                            content: Text('Name changed successfully.'),
                            backgroundColor: Colors.green,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
                        'Change Name',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return SettingsScreen();
                          },
                        ),
                      );
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

