import 'package:flutter/material.dart';
import 'package:katena_dashboard/screens/login/login_screen.dart';


class LoginBody extends StatelessWidget{


  @override
  Widget build(BuildContext context) {
    Size size=MediaQuery.of(context).size; //with this query I get (w,h) of the screen
    return Container(
      height: size.height,
      width: double.infinity,
      color:Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children:<Widget>[
          Image.asset("assets/icons/icons8-chains-emoji-96.png"),
          const Text("Login to BlockVerse"),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20,vertical: 5),

          )


        ],
      ),
    );

  }


}