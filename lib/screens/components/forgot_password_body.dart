import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:katena_dashboard/screens/login/login_screen.dart';
import 'package:katena_dashboard/screens/services/services_provider.dart';
import '../../firebase_options.dart';

//constants

String email = "";
enum AuthStatus {
  successful,
  wrongPassword,
  emailAlreadyExists,
  invalidEmail,
  weakPassword,
  unknown,
}

String  pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
RegExp regExp = new RegExp(pattern);
class ResetPasswordBody extends StatefulWidget{
  const ResetPasswordBody({super.key});

  @override
  _ForgotPasswordFormState createState() =>  _ForgotPasswordFormState();


}

class  _ForgotPasswordFormState extends State<ResetPasswordBody> {
  final _formKey = GlobalKey<FormState>();










  @override
  Widget build(BuildContext context) {
    Size size=MediaQuery.of(context).size; //with this query I get (w,h) of the screen
    return Container(
      width: size.width,


      child:Form(
        key: _formKey,
        child:Container(
          width: size.width,

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset("assets/icons/icons8-chains-emoji-96.png"),
            const Text("Reset The password"),
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

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: ()async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    //Invoke the method for the reset of the password
                    Provider serviceProvider=Provider.instance;
                    AuthStatus auth = serviceProvider.PasswordReset(email) as AuthStatus;
                    print(auth);
                    if (auth == AuthStatus.successful) {
                      Navigator.push(
                        context, MaterialPageRoute(builder: (context) {
                        return LoginScreen();
                      },),);
                    }else
                    {
                      const Text(
                        'your password cannot be restored',
                        style: TextStyle(color: Colors.red),
                      );
                    }
                  }
                },


                child:const Text('Reset Password'),


              ),

            ),

            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context){return LoginScreen();},),);
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
    );
  }
}