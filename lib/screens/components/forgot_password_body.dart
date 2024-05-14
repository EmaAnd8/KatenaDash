import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:katena_dashboard/screens/login/login_screen.dart';
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



class AuthExceptionHandler {
  static handleAuthException(FirebaseAuthException e) {
    AuthStatus status;
    switch (e.code) {
      case "invalid-email":
        status = AuthStatus.invalidEmail;
        break;
      case "wrong-password":
        status = AuthStatus.wrongPassword;
        break;
      case "weak-password":
        status = AuthStatus.weakPassword;
        break;
      case "email-already-in-use":
        status = AuthStatus.emailAlreadyExists;
        break;
      default:
        status = AuthStatus.unknown;
    }
    return status;
  }
  static String generateErrorMessage(error) {
    String errorMessage;
    switch (error) {
      case AuthStatus.invalidEmail:
        errorMessage = "Your email address appears to be malformed.";
        break;
      case AuthStatus.weakPassword:
        errorMessage = "Your password should be at least 6 characters.";
        break;
      case AuthStatus.wrongPassword:
        errorMessage = "Your email or password is wrong.";
        break;
      case AuthStatus.emailAlreadyExists:
        errorMessage =
        "The email address is already in use by another account.";
        break;
      default:
        errorMessage = "An error occured. Please try again later.";
    }
    return errorMessage;
  }
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


  Future<AuthStatus>  PasswordReset() async
  {
    AuthStatus _status=AuthStatus.unknown;


        WidgetsFlutterBinding.ensureInitialized();
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        //authentication provided from firebase
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email)
        .then((value) => _status = AuthStatus.successful).catchError((e) => _status = AuthExceptionHandler.handleAuthException(e));

        return _status;
    }








  @override
  Widget build(BuildContext context) {
    Size size=MediaQuery.of(context).size; //with this query I get (w,h) of the screen
    return SizedBox(
      width: size.width,
      height: size.height,
      child:Form(
        key: _formKey,
        child:Container(
          width: size.width,
          height: size.height,
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
                    AuthStatus auth = PasswordReset() as AuthStatus;
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

            const Text(
              'Go Back',
              style: TextStyle(color: Colors.black),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context){return LoginScreen();},),);
              },

            ),


          ],
        ),
      ),
      ),
    );
  }
}