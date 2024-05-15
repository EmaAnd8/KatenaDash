import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:katena_dashboard/screens/login/login_screen.dart';
import '../../firebase_options.dart';


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
    return Container(
      width: size.width,

    );
  }
}