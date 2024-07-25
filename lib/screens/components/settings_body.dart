import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:katena_dashboard/screens/dashboard/dashboard_screen.dart';
import 'package:katena_dashboard/screens/forgotpwd/forgot_password_screen.dart';
import 'package:katena_dashboard/screens/settings/change_name_screen.dart';
import '../settings/change_email_screen.dart';

class SettingsBody extends StatefulWidget {
  const SettingsBody({super.key});

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<SettingsBody> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size; // With this query I get (w,h) of the screen
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        width: size.width,
        height: size.height,
        color: Colors.white, // Set the entire background to white
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return ChangeNameScreen();
                }));
              },

                child: const Text(
                  'Change your name',
                  style: TextStyle(color: Colors.black, fontSize: 20),
                ),
              ),
            Padding(padding: EdgeInsets.all(16.0)),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return ChangeEmailScreen();
                }));
              },
              child: Container(

                child: const Text(
                  'Change your email',
                  style: TextStyle(color: Colors.black, fontSize: 20),
                ),
              ),
            ),
            const Padding(padding: EdgeInsets.all(16.0)),
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                  return ResetPasswordScreen();
                }));
              },

                child: const Text(
                  'Change your password',
                  style: TextStyle(color: Colors.black, fontSize: 20),
                ),
              ),
            const Padding(padding: EdgeInsets.all(16.0)),
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                  return HomeScreen();
                }));
              },

                child: const Text(
                  'Go back',
                  style: TextStyle(color: Colors.black, fontSize: 20),
                ),
              ),

          ],
        ),
      ),
    );
  }
}
