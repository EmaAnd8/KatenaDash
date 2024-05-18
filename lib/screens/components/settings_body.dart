import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:katena_dashboard/screens/dashboard/dashboard_screen.dart';
import 'package:katena_dashboard/screens/forgotpwd/forgot_password_screen.dart';
import 'package:katena_dashboard/screens/settings/change_name_screen.dart';
import '../settings/change_email_screen.dart';


class SettingsBody extends StatefulWidget{
  const SettingsBody({super.key});

  @override
  _SettingsState createState() =>  _SettingsState();


}

class  _SettingsState extends State<SettingsBody> {
  final _formKey = GlobalKey<FormState>();








  @override
  Widget build(BuildContext context) {
    Size size=MediaQuery.of(context).size; //with this query I get (w,h) of the screen
    return Scaffold(

        appBar: AppBar(
        title: const Text('Settings'),
    backgroundColor: CupertinoColors.white,
    leading: IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () {
    Navigator.pop(context);
    },
    ),
        ),


       body: Container(
         width:size.width,
       child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context){return ChangeNameScreen();},),);
              },
              child:const Text(
                'change your name',
                style: TextStyle(color: Colors.black, fontSize:20),
              ),
            ),

          ),

          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),

            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context){return ChangeEmailScreen();},),);
              },
              child:const Text(
                'change your email',
                style: TextStyle(color: Colors.black, fontSize:20),
              ),
            ),

          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){return ResetPasswordScreen();},),);
              },
              child:const Text(
                'change your password',
                style: TextStyle(color: Colors.black, fontSize:20),
              ),
            ),


          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){return HomeScreen();},),);
              },
              child:const Text(
                'Go Back',
                style: TextStyle(color: Colors.black, fontSize:20),
              ),
            ),


          )
             ]
       ),
       ),


    );
  }
}