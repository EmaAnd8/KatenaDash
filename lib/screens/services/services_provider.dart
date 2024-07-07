


import 'dart:io';
import 'dart:js_interop';
import 'package:file_picker/file_picker.dart';
import 'dart:math' as math ;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:katena_dashboard/screens/components/change_name_body.dart';
import 'package:katena_dashboard/screens/components/graphiccomponents/simple_arrow.dart';
import 'package:katena_dashboard/screens/components/topology_management_body.dart';
import 'package:yaml/yaml.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:katena_dashboard/firebase_options.dart';
import 'package:katena_dashboard/screens/dashboard/dashboard_screen.dart';
import 'package:katena_dashboard/screens/login/login_screen.dart';
import 'package:katena_dashboard/screens/services/services_provider.dart';
import 'package:katena_dashboard/screens/settings/settings_screen.dart';
import 'package:katena_dashboard/screens/components/graphiccomponents/simple_node.dart';
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

class Provider {

  final storage = FirebaseStorage.instance;
  final db = FirebaseFirestore.instance;


  Provider._privateConstructor(); // Private empty constructor

  static Provider _instance = Provider._privateConstructor();


  // Factory constructor that can return an instance
  static Provider get instance {
    return _instance;
  }

  /*
  void Begin()
  async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }




*/

  void ProfileImage() async {

    final imageFile = await ImagePicker().pickImage(
        source: ImageSource.gallery);
    //SharedPreferences prefs = await SharedPreferences.getInstance();
    if (imageFile != null) {
      final f=File(imageFile.path);


      final profileImagePath = '${FirebaseAuth.instance
          .currentUser?.uid}/profile_picture.jpg';
      print(f.absolute.path);
      final uploadTask = FirebaseStorage.instance.ref()
          .child('Profile/'+profileImagePath)
          .putFile(File(f.absolute.path));

      final downloadUrl = await (await uploadTask).ref
          .getDownloadURL();


      // Create a NetworkImage object from the URL
      print(downloadUrl);

      late ImageProvider downloadedImage =
          NetworkImage(downloadUrl);


    } else {
      print("wrong path");
    }

}



  void ParadoxSignout(context)
  {
    Provider serviceProvider=Provider.instance;
    serviceProvider.Signout();
    Navigator.push(context, MaterialPageRoute(builder: (context){return LoginScreen();},),);
  }


  void  ChangeEmail(context,email) async
  {
    String previousEmail="";
    if (FirebaseAuth.instance.currentUser?.email != null) {
      previousEmail =FirebaseAuth.instance.currentUser!.email! ;
    } else {
      previousEmail ="";
    }
    if (FirebaseAuth.instance.currentUser?.email?.compareTo(email) != 0){
      FirebaseAuth.instance.currentUser?.verifyBeforeUpdateEmail(email);
      FirebaseAuth.instance.currentUser?.reload();
      if (FirebaseAuth.instance.currentUser!.emailVerified) {

        User? user= FirebaseAuth.instance.currentUser;
        CollectionReference users = FirebaseFirestore.instance.collection('Users');
        //print(user?.email);

        // Update the population of a city
        final query = users.where("email", isEqualTo: previousEmail).get()
            .then((querySnapshot) {
          print("Successfully completed");
          for (var docSnapshot in querySnapshot.docs) {
            final usersRef = users.doc(docSnapshot.id);
            usersRef.update({"email": email}).then(

                    (value) =>ParadoxSignout(context),
                onError: (e) => print("Error updating document $e"));

          }
        },
          onError: (e) => print("Error completing: $e"),
        );

      }
    }else
    {
      Navigator.push(context, MaterialPageRoute(builder: (context){return SettingsScreen();},),);
    }
  }
  void CName(context,name) async
  {



    //authentication provided from firebase

    try {
      // if my email is verified then I signin otherwise error



      User? user= FirebaseAuth.instance.currentUser;
      CollectionReference users = FirebaseFirestore.instance.collection('Users');
      print(user?.email);
      print(name);
      // Update the population of a city
      final query = users.where("email", isEqualTo: FirebaseAuth.instance.currentUser?.email).get()
          .then((querySnapshot) {
        print("Successfully completed");
        for (var docSnapshot in querySnapshot.docs) {
          final usersRef = users.doc(docSnapshot.id);
          usersRef.update({"Name": name}).then(
                  (value) => print("DocumentSnapshot successfully updated!"),
              onError: (e) => print("Error updating document $e"));

        }
      },
        onError: (e) => print("Error completing: $e"),
      );


      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){return SettingsScreen();},),);
    }on  FirebaseAuthException catch(e)
    {
      print(e);
    }
  }

  void Login(context,email,password) async
  {





    try {
      // if my email is verified then I signin otherwise error
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email, password: password);

      if(FirebaseAuth.instance.currentUser!.emailVerified) {

        Navigator.push(context, MaterialPageRoute(builder: (context){return HomeScreen();},),);

      }
    }on  FirebaseAuthException catch(e)
    {
      print(e);
    }
  }

  String? QueryName(email,context)  {
    Map<String, String> keyValueMap = {};
    String modifiedString="";
    String StringParser="";
    List<String> pairs=[];
    List<String> parts=[];

    CollectionReference users = FirebaseFirestore.instance.collection('Users');
    // Update the population of a city
    final query = users.where("email", isEqualTo: email).get()
        .then((querySnapshot) {
      //print("Successfully completed");
      for (var docSnapshot in querySnapshot.docs) {
        final usersRef = users.doc(docSnapshot.id);
        StringParser = docSnapshot.data().toString();
        modifiedString = StringParser.substring(1,StringParser.length-1);
        modifiedString = modifiedString.replaceAll(",", "");
        pairs = modifiedString.split(RegExp(r"\s+(?=\w+: )"));
        // Extract keys and values
        for (String pair in pairs) {
          parts = pair.split(": ");
          if (parts.length == 2) {
            keyValueMap[parts[0]] = parts[1];
          }
        }
        //print( keyValueMap["Name"]);
        return keyValueMap["Name"]!;


      }

          });
   // print( keyValueMap["Name"]);

  }

  void Register(user,email,password) async
  {







    // I create a User

    await  FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);


    // I send and email for saying if the provided email is fine
    FirebaseAuth.instance.currentUser?.sendEmailVerification();
    //if the user is verified I can add him to the database
    db.collection("Users").add(user).then((DocumentReference doc) =>
        print('DocumentSnapshot added with ID: ${doc.id}'));

  }

   void Signout() async
  {




    //authentication provided from firebase

    try {
      // if my email is verified then I signin otherwise error



      await FirebaseAuth.instance.signOut();

    }on  FirebaseAuthException catch(e)
    {
      print(e);
    }
  }


  Future<AuthStatus>  PasswordReset(email) async
  {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    AuthStatus _status=AuthStatus.unknown;

    Provider serviceProvider=Provider.instance;

    //authentication provided from firebase
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email)
        .then((value) => _status = AuthStatus.successful).catchError((e) => _status = AuthExceptionHandler.handleAuthException(e));

    return _status;
  }

  //this function parse a TOSCA file in a JSON in order to create then a Topology
  Future<String> Parser(path) async {
    try {
      // String where to find the yaml file
      print(path);
      // Load YAML from assets
      String yamlString = await rootBundle.loadString(path);
      //print(yamlString);
      // Parse YAML
      final yamlMap = await loadYaml(yamlString);
    //  print(yamlMap);

      // Convert to JSON
      final jsonString = json.encode(yamlMap);
      //print(jsonString);
      return jsonString;
    } catch (e){
      print("Error converting YAML to JSON: $e");
      return ""; // Or handle the error
    }
  }



  Future<List<Widget>?> TopologyPrinter()
  async {

    Provider serviceProvider=Provider.instance;
    String JSONfiles=await serviceProvider.Parser("assets/input/simple-relationship-with-args.yaml");
    Map<String, dynamic> jsonData = jsonDecode(JSONfiles);

    if(jsonData["topology_template"]["node_templates"].toString()!=null)
      {
        print(jsonData["topology_template"]["node_templates"].toString()); // Output
        if(jsonData["topology_template"]["node_templates"]["caller"].toString()!=null && jsonData["topology_template"]["node_templates"]["callee"].toString()!=null)
          {
            print(jsonData["topology_template"]["node_templates"]["caller"].toString());
            print(jsonData["topology_template"]["node_templates"]["callee"].toString());

                  List<Widget> nodes=[
                    // In your widget tree:
                    Padding(
                      padding:EdgeInsets.only(top: 10),

                      child:Image.asset("assets/icons/wallet_4121117.png",
                        width: 50,
                        height: 50,)
                    ),
                    Padding(padding: EdgeInsets.only(bottom: 40),
                   child:  CustomPaint(
                        painter: ArrowPainter(
                        color: Colors.blue,
                          angle: 0,
                        length: 60,
                    ),
                      size: const Size(10,50),
                    ),
    ),
                    Padding(
                        padding:EdgeInsets.only(bottom: 10),

                    child:Image.asset("assets/icons/wallet_4121117.png",
                    width: 50,
                    height: 50,)
                    ),
                  ];

            return nodes;

          }
      }
    return null;
  }



  Future<void> createYamlFile(String filePath) async {

  }

  //the topology manager is the module in charge to associate a graphic component to the TOSCA
  Future<void> TopologyManager()
  async {
  }

  Future<List<Widget>> CreateNode() async
  {
    //final yamlString = YamlMap.wrap("" as Map).toString();
    print("oooo");
    final ByteData data = await rootBundle.load('assets/input/simple-node.yaml');
    print("00000");
    final buffer = data.buffer;
    final yamlContent = String.fromCharCodes(buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
    print(yamlContent);


  // final sourceFile = File("assets/input/simple-node.yaml");
    final destinationFile = File("assets/output/topology.yaml");

    // Read the content of the source file
    try {
      await destinationFile.writeAsString(yamlContent, mode: FileMode.write);
    }catch( e){
      print(e.toString());
    }
      List<Widget> nodes=[
    // In your widget tree:
      Padding(
          padding:EdgeInsets.only(bottom: 10),

          child:Image.asset("assets/icons/wallet_4121117.png",
            width: 50,
            height: 50,)
      ),
    ];
    // Example usage:

    return nodes;
  }


    //method to import a yaml file
    Future<YamlMap?> ImportYaml() async{

        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['yaml'],
        );

        if (result != null) {
         // print('xxxxx');
          try {
            PlatformFile file = result.files.single;
            final yamlString = utf8.decode(file.bytes!);
            final yamlMap = loadYaml(yamlString);
           return yamlMap;


            // Access the data in the YAML map
            print(yamlMap);
          } catch(e)
          {
            print(e);
          }

        } else {
           //do nothing
          print("no file selected");
        }

    }

    Future<List<Widget>?> TopologyPrinterFromYaml() async
    {

      var yamlFile=await ServiceProvider.ImportYaml();
      print(yamlFile);
      print(yamlFile?["topology_template"]["node_templates"]["userWallet"]);
      if(yamlFile?["topology_template"]["node_templates"]["ganache"].toString()!=null)
      {

        if(yamlFile?["topology_template"]["node_templates"]["ganache"].toString()!=null && yamlFile?["topology_template"]["node_templates"]["userWallet"].toString()!=null)
        {

         // print(yamlFile?["topology_template"]["node_templates"]["callee"].toString());

          List<Widget> nodes=[
            // In your widget tree:
            Column(

              children:<Widget>[
              Padding(padding: EdgeInsets.only(left: 40,right: 40,bottom: 20),

                  child:Image.asset("assets/icons/wallet_4121117.png",
                    width: 50,
                    height: 50,)
              ),
              const Text("User wallet"),
    ],
            ),
            Column(
            children:<Widget>[
            Padding(padding: EdgeInsets.only(left: 40,right: 40),
              child:  CustomPaint(
                painter: ArrowPainter(
                  color: Colors.blue,
                  angle: 0,
                  length: 60,
                ),
                size: const Size(10,50),
              ),
            ),
            const Text("Hosted by"),
            ],
            ),
            Padding(padding: EdgeInsets.only(left: 40,right: 40),

                child:Image.asset("assets/icons/Ganache Blockchain.png",
                  width: 100,
                  height: 100,)
            ),
          ];

          return nodes;

        }else{
          print("no network defined");
        }
      }else{
        print("empty topology");
      }
      return null;


    }

  }
