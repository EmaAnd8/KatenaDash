import 'package:flutter/material.dart';
import 'package:katena_dashboard/screens/login/login_screen.dart';



class Body extends StatelessWidget{


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
          const Text("Welcome to BlockVerse"),
           ElevatedButton(
          onPressed: () {
          //here I handle the event on pressed
            Navigator.push(context, MaterialPageRoute(builder: (context){return LoginScreen();},),);
      },
      style: ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),


      ),
      child:  const Text('Tap here to start',
              style:TextStyle(color: Colors.black)),
           ),

      ],
      ),
    );

  }
  
  
}