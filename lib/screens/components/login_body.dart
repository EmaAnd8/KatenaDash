import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:katena_dashboard/firebase_options.dart';
import 'package:katena_dashboard/screens/dashboard/dashboard_screen.dart';
import 'package:katena_dashboard/screens/forgotpwd/forgot_password_screen.dart';
import 'package:katena_dashboard/screens/services/services_provider.dart';
import 'package:katena_dashboard/screens/signup/signup_screen.dart';

// Constants
String email = "";
String password = "";
String pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
RegExp regExp = RegExp(pattern);

class LoginBody extends StatefulWidget {
  const LoginBody({super.key});

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginBody> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  double _buttonOffsetX = 0;
  double _buttonOffsetY = 0;
  late AnimationController _controller;
  Color _buttonColor = Colors.blue; // Initial button color

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
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
                    "Welcome to BlockVerse",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: 400,
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: "Email",
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                        prefixIcon: const Icon(Icons.email, color: Colors.blue),
                        filled: true,
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter your email";
                        }
                        /*if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return "Enter a valid Email address.";
                        }*/
                        return null;
                      },
                      onSaved: (value) {
                        email = "biagiomarra.1229@gmail.com";
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
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                        prefixIcon: const Icon(Icons.lock, color: Colors.blue),
                        filled: true,
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter your password";
                        }
                        /*if (!regExp.hasMatch(value)) {
                          return "Please enter a valid password";
                        }*/
                        return null;
                      },
                      onSaved: (value) {
                        password = "Biagiomarra01#";
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(_buttonOffsetX, _buttonOffsetY),
                        child: MouseRegion(
                          onEnter: (event) {
                            if (!_formKey.currentState!.validate()) {
                              _moveButton();
                            } else {
                              _resetButtonPosition();
                            }
                          },
                          child: child,
                        ),
                      );
                    },
                    child: SizedBox(
                      width: 400,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            try {
                              WidgetsFlutterBinding.ensureInitialized();
                              await Firebase.initializeApp(
                                options: DefaultFirebaseOptions.currentPlatform,
                              );
                              Provider serviceProvider = Provider.instance;
                              serviceProvider.Login(context, email, password);
                              if (FirebaseAuth.instance.currentUser!.emailVerified) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HomeScreen(),
                                  ),
                                );
                              } else {
                                const snackBar = SnackBar(
                                  content: Text('Your email is not verified.'),
                                  backgroundColor: Colors.red,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                              }
                            } catch (e) {
                              print(e);
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: _buttonColor, // Use the dynamic button color
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => ResetPasswordScreen()),
                      );
                    },
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => SignupScreen()));
                    },
                    child: const Text(
                      'If you do not have an account, go to sign up',
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

  void _moveButton() {
    setState(() {
      _buttonOffsetX = _generateRandomOffsetX();
      _buttonOffsetY = _generateRandomOffsetY();
      _buttonColor = Colors.red; // Change button color to red when invalid
      _controller.forward(from: 0); // Start the animation
    });
  }

  void _resetButtonPosition() {
    setState(() {
      _buttonOffsetX = 0;
      _buttonOffsetY = 0;
      _buttonColor = Colors.blue; // Reset button color to original when valid
      _controller.reverse(); // Reset the animation
    });
  }

  // Generate a random X offset for the button within safe bounds
  double _generateRandomOffsetX() {
    double maxX = 100; // Set a safe horizontal movement range
    return Random().nextDouble() * maxX - maxX / 2;
  }

  // Generate a random Y offset for the button within safe bounds
  double _generateRandomOffsetY() {
    double maxY = 30; // Set a safe vertical movement range
    return Random().nextDouble() * maxY - maxY / 2;
  }
}
