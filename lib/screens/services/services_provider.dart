


import 'dart:io';
import 'dart:js_interop';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'dart:math' as math ;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:graphview/GraphView.dart';
import 'package:katena_dashboard/screens/components/change_name_body.dart';
import 'package:katena_dashboard/screens/components/graphiccomponents/simple_arrow.dart';
import 'package:katena_dashboard/screens/components/graphiccomponents/simple_rectangle.dart';
import 'package:katena_dashboard/screens/components/topology_management_body.dart';
import 'package:path_provider/path_provider.dart';

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

import 'package:katena_dashboard/screens/settings/settings_screen.dart';

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
//method to add a new profile image



  Future<String> ProfileImage() async {
    try {
      // Pick an image from the gallery
      final imageFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (imageFile == null) {
        print("No image selected.");
        return "";
      }

      // Get the current user's UID
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("No user logged in.");
        return "";
      }

      final uid = user.uid;
      final profileImagePath = '$uid/profile_picture.png';

      // For web platform, read image as bytes
      final bytes = await imageFile.readAsBytes();

      // Print debug information
      print('Profile image path: $profileImagePath');

      // Upload the file to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child('Profile/$profileImagePath');
      final uploadTask = storageRef.putData(bytes);

      // Wait for the upload to complete and get the download URL
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Print the download URL
      print('Download URL: $downloadUrl');

      // Create a NetworkImage object from the URL (if needed)
      late ImageProvider downloadedImage = NetworkImage(downloadUrl);
      return downloadUrl;
    } catch (e) {
      print('Error: $e');
    }
    return "";
  }



  void ParadoxSignout(context) {
    Provider serviceProvider = Provider.instance;
    serviceProvider.Signout();
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return LoginScreen();
    },),);
  }


  void ChangeEmail(context, email) async
  {
    String previousEmail = "";
    if (FirebaseAuth.instance.currentUser?.email != null) {
      previousEmail = FirebaseAuth.instance.currentUser!.email!;
    } else {
      previousEmail = "";
    }
    if (FirebaseAuth.instance.currentUser?.email?.compareTo(email) != 0) {
      FirebaseAuth.instance.currentUser?.verifyBeforeUpdateEmail(email);
      FirebaseAuth.instance.currentUser?.reload();
      if (FirebaseAuth.instance.currentUser!.emailVerified) {
        User? user = FirebaseAuth.instance.currentUser;
        CollectionReference users = FirebaseFirestore.instance.collection(
            'Users');
        //print(user?.email);

        // Update the population of a city
        final query = users.where("email", isEqualTo: previousEmail).get()
            .then((querySnapshot) {
          print("Successfully completed");
          for (var docSnapshot in querySnapshot.docs) {
            final usersRef = users.doc(docSnapshot.id);
            usersRef.update({"email": email}).then(

                    (value) => ParadoxSignout(context),
                onError: (e) => print("Error updating document $e"));
          }
        },
          onError: (e) => print("Error completing: $e"),
        );
      }
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return SettingsScreen();
      },),);
    }
  }

  void CName(context, name) async
  {
    //authentication provided from firebase

    try {
      // if my email is verified then I signin otherwise error


      User? user = FirebaseAuth.instance.currentUser;
      CollectionReference users = FirebaseFirestore.instance.collection(
          'Users');
      print(user?.email);
      print(name);
      // Update the population of a city
      final query = users.where(
          "email", isEqualTo: FirebaseAuth.instance.currentUser?.email).get()
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


      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return SettingsScreen();
      },),);
    } on FirebaseAuthException catch (e) {
      print(e);
    }
  }

  void Login(context, email, password) async
  {
    try {
      // if my email is verified then I signin otherwise error
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email, password: password);

      if (FirebaseAuth.instance.currentUser!.emailVerified) {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return HomeScreen();
        },),);
      }
    } on FirebaseAuthException catch (e) {
      print(e);
    }
  }

  String? QueryName(email, context) {
    Map<String, String> keyValueMap = {};
    String modifiedString = "";
    String StringParser = "";
    List<String> pairs = [];
    List<String> parts = [];

    CollectionReference users = FirebaseFirestore.instance.collection('Users');
    // Update the population of a city
    final query = users.where("email", isEqualTo: email).get()
        .then((querySnapshot) {
      //print("Successfully completed");
      for (var docSnapshot in querySnapshot.docs) {
        final usersRef = users.doc(docSnapshot.id);
        StringParser = docSnapshot.data().toString();
        modifiedString = StringParser.substring(1, StringParser.length - 1);
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

  void Register(user, email, password) async
  {
    // I create a User

    await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email, password: password);


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
    } on FirebaseAuthException catch (e) {
      print(e);
    }
  }


  Future<AuthStatus> PasswordReset(email) async
  {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    AuthStatus _status = AuthStatus.unknown;

    Provider serviceProvider = Provider.instance;

    //authentication provided from firebase
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email)
        .then((value) => _status = AuthStatus.successful).catchError((e) =>
    _status = AuthExceptionHandler.handleAuthException(e));

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
    } catch (e) {
      print("Error converting YAML to JSON: $e");
      return ""; // Or handle the error
    }
  }


  Future<List<Widget>?> TopologyPrinter() async {
    Provider serviceProvider = Provider.instance;
    String JSONfiles = await serviceProvider.Parser(
        "assets/input/simple-relationship-with-args.yaml");
    Map<String, dynamic> jsonData = jsonDecode(JSONfiles);

    if (jsonData["topology_template"]["node_templates"].toString() != null) {
      print(
          jsonData["topology_template"]["node_templates"].toString()); // Output
      if (jsonData["topology_template"]["node_templates"]["caller"]
          .toString() != null &&
          jsonData["topology_template"]["node_templates"]["callee"]
              .toString() != null) {
        print(jsonData["topology_template"]["node_templates"]["caller"]
            .toString());
        print(jsonData["topology_template"]["node_templates"]["callee"]
            .toString());

        List<Widget> nodes = [
          // In your widget tree:
          Padding(
              padding: EdgeInsets.only(top: 10),

              child: Image.asset("assets/icons/wallet_4121117.png",
                width: 50,
                height: 50,)
          ),
          Padding(padding: EdgeInsets.only(bottom: 40),
            child: CustomPaint(
              painter: ArrowPainter(
                color: Colors.blue,
                angle: 0,
                length: 60,
              ),
              size: const Size(10, 50),
            ),
          ),
          Padding(
              padding: EdgeInsets.only(bottom: 10),

              child: Image.asset("assets/icons/wallet_4121117.png",
                width: 50,
                height: 50,)
          ),
          Padding(padding: EdgeInsets.only(bottom: 40),
            child: CustomPaint(
              painter: ArrowPainter(
                color: Colors.blue,
                angle: 0,
                length: 60,
              ),
              size: const Size(10, 50),
            ),
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
  Future<void> TopologyManager() async {
  }

  Future<List<Widget>> CreateNode() async
  {
    //final yamlString = YamlMap.wrap("" as Map).toString();
    print("oooo");
    final ByteData data = await rootBundle.load(
        'assets/input/simple-node.yaml');
    print("00000");
    final buffer = data.buffer;
    final yamlContent = String.fromCharCodes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
    print(yamlContent);


    // final sourceFile = File("assets/input/simple-node.yaml");
    final destinationFile = File("assets/output/topology.yaml");

    // Read the content of the source file
    try {
      await destinationFile.writeAsString(yamlContent, mode: FileMode.write);
    } catch (e) {
      print(e.toString());
    }
    List<Widget> nodes = [
      // In your widget tree:
      Padding(
          padding: EdgeInsets.only(bottom: 10),

          child: Image.asset("assets/icons/wallet_4121117.png",
            width: 50,
            height: 50,)
      ),
    ];
    // Example usage:

    return nodes;
  }


  //method to import a yaml file
  Future<YamlMap?> ImportYaml() async {
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
      } catch (e) {
        print(e);
      }
    } else {
      //do nothing
      print("no file selected");
    }
  }

/*
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
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
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
            const Text("Hosted by",
                textAlign: TextAlign.center,),
            ],
            ),
            Padding(padding: EdgeInsets.only(left: 40,right: 40),

                child:Image.asset("assets/icons/Ganache Blockchain.png",
                  width: 100,
                  height: 100,)
            ),
          ];

          if(yamlFile?["topology_template"]["node_templates"]["ensRegistry"].toString()!=null) {
            print(
                yamlFile?["topology_template"]["node_templates"]["ensRegistry"]
                    .toString());
            nodes.addAll([
              Row(
                children: <Widget>[
                  Padding(padding: EdgeInsets.only(left: 40, right: 40),
                    child: CustomPaint(
                      painter: ArrowPainter(
                        color: Colors.blue,
                        angle: math.pi,
                        length: 60,
                      ),
                      size: const Size(10, 50),
                    ),
                  ),
                  Column(
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.only(bottom: 10),

                          child: Image.asset("assets/icons/smart_14210186.png",
                            width: 50,
                            height: 50,)
                      ),
                      const Text("EnsRegister"),
                    ],
                  ),
                ],
              ),

            ]);
          }else
            {
              print("No ens Register");
            }

            if(yamlFile?["topology_template"]["node_templates"]["publicResolver"].toString()!=null)
            {
              print(yamlFile?["topology_template"]["node_templates"]["publicResolver"].toString());
              nodes.addAll([
                Column(
                  children: <Widget>[
                    Padding(padding: EdgeInsets.only(left: 40,right: 40),
                      child:  CustomPaint(
                        painter: ArrowPainter(
                          color: Colors.blue,
                          angle: math.pi,
                          length: 60,
                        ),
                        size: const Size(10,50),
                      ),
                    ),
                    Column(
                      children: <Widget>[
                        Padding(
                            padding:EdgeInsets.only(bottom: 10),

                            child:Image.asset("assets/icons/smart_14210186.png",
                              width: 50,
                              height: 50,)
                        ),
                        const Text("PublicResolver"),
                      ],
                    ),
                  ],
                ),

              ]);
          }else{
              print("No public Resolver");
            }


          if(yamlFile?["topology_template"]["node_templates"]["reverseRegistrar"].toString()!=null)
          {
            print(yamlFile?["topology_template"]["node_templates"]["reverseRegistrar"].toString());
            nodes.addAll([
              Column(
                children: <Widget>[
                  Padding(padding: EdgeInsets.only(left: 40,right: 40),
                    child:  CustomPaint(
                      painter: ArrowPainter(
                        color: Colors.blue,
                        angle: math.pi,
                        length: 60,
                      ),
                      size: const Size(10,50),
                    ),
                  ),
                  Column(
                    children: <Widget>[
                      Padding(
                          padding:EdgeInsets.only(bottom: 10),

                          child:Image.asset("assets/icons/smart_14210186.png",
                            width: 50,
                            height: 50,)
                      ),
                      const Text(" reverseRegistrar"),
                    ],
                  ),
                ],
              ),

            ]);
          }else{
            print("No reverseRegistrar");
          }

          if(yamlFile?["topology_template"]["node_templates"]["registrar"].toString()!=null)
          {
            print(yamlFile?["topology_template"]["node_templates"]["registrar"].toString());
            nodes.addAll([
              Column(
                children: <Widget>[
                  Padding(padding: EdgeInsets.only(left: 40,right: 40),
                    child:  CustomPaint(
                      painter: ArrowPainter(
                        color: Colors.blue,
                        angle: math.pi,
                        length: 60,
                      ),
                      size: const Size(10,50),
                    ),
                  ),
                  Column(
                    children: <Widget>[
                      Padding(
                          padding:EdgeInsets.only(bottom: 10),

                          child:Image.asset("assets/icons/smart_14210186.png",
                            width: 50,
                            height: 50,)
                      ),
                      const Text("Registrar"),
                    ],
                  ),
                ],
              ),

            ]);
          }else{
            print("No Registrar");
          }

          return nodes;

        }else{
          print("no network defined");
        }
      }else{
        print("empty topology");
      }
      return null;


    }
*/

  Future<List<Widget>?> TopologyPrinterFromYaml() async {
    var yamlFile = await ServiceProvider.ImportYaml();

    print(yamlFile);
    print(yamlFile?["topology_template"]["node_templates"]["userWallet"]);
    if (yamlFile?["topology_template"]["node_templates"]["ganache"]
        .toString() != null) {
      if (yamlFile?["topology_template"]["node_templates"]["ganache"]
          .toString() != null &&
          yamlFile?["topology_template"]["node_templates"]["userWallet"]
              .toString() != null) {
        List<Widget> nodes = [
          // User Wallet Node
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 40, right: 40, bottom: 20),
                child: Image.asset(
                  "assets/icons/wallet_4121117.png",
                  width: 50,
                  height: 50,
                ),
              ),
              const Text("User wallet"),
            ],
          ),
          // Arrow to Ganache
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: CustomPaint(
              painter: ArrowPainter(
                color: Colors.blue,
                angle: 0,
                length: 120,
              ),
              size: const Size(10, 50),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 75),
            child: const Text("Hosted on", textAlign: TextAlign.center),
          ),
          // Ganache Node
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            child: Image.asset(
              "assets/icons/Ganache Blockchain.png",
              width: 100,
              height: 100,
            ),
          ),
        ];

        // EnsRegistry Node
        if (yamlFile?["topology_template"]["node_templates"]["ensRegistry"]
            .toString() != null) {
          print(yamlFile?["topology_template"]["node_templates"]["ensRegistry"]
              .toString());
          nodes.addAll([
            // Arrow to EnsRegistry
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: CustomPaint(
                painter: ArrowPainter(
                  color: Colors.blue,
                  angle: (3 / 4) * math.pi,
                  length: 60,
                ),
                size: const Size(10, 50),
              ),
            ),
            Padding(padding: const EdgeInsets.only(bottom: 200, left: 100),
              child: Column(

                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Image.asset(
                      "assets/icons/smart_14210186.png",
                      width: 50,
                      height: 50,
                    ),
                  ),
                  const Padding(padding: EdgeInsets.only(bottom: 5),
                    child: Text("EnsRegister"),
                  ),
                  const Text("abi: ENSRegistry")
                ],

              ),
            ),
          ]);
        } else {
          print("No ens Register");
        }

        // PublicResolver Node
        if (yamlFile?["topology_template"]["node_templates"]["publicResolver"]
            .toString() != null) {
          print(
              yamlFile?["topology_template"]["node_templates"]["publicResolver"]
                  .toString());
          nodes.addAll([
            // Arrow to PublicResolver
            Stack(
              fit: StackFit.loose,
              children: <Widget>
              [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 70, vertical: 30),
                  child: CustomPaint(
                    painter: ArrowPainter(
                      color: Colors.blue,
                      angle: (-2 * math.pi) + (math.pi / 2) + (-math.pi / 3),
                      length: 70,
                    ),
                    size: const Size(10, 50),
                  ),
                ),

                const Padding(padding: EdgeInsets.only(right: 25, top: 35),
                  child: Text("Connected to"),
                ),


              ],
            ),
            Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Image.asset(
                    "assets/icons/smart_14210186.png",
                    width: 50,
                    height: 50,
                  ),
                ),
                const Padding(padding: EdgeInsets.only(bottom: 5),
                  child: Text("publicResolver"),
                ),
                const Text("abi: PublicResolver"),
              ],
            ),
          ]);
        } else {
          print("No public Resolver");
        }

        // ReverseRegistrar Node
        if (yamlFile?["topology_template"]["node_templates"]["reverseRegistrar"]
            .toString() != null) {
          print(
              yamlFile?["topology_template"]["node_templates"]["reverseRegistrar"]
                  .toString());

          nodes.addAll([
            // Arrow to ReverseRegistrar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: CustomPaint(
                painter: ArrowPainter(
                  color: Colors.blue,
                  angle: -math.pi,
                  length: 60,
                ),
                size: const Size(10, 50),
              ),
            ),


            Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Image.asset(
                    "assets/icons/smart_14210186.png",
                    width: 50,
                    height: 50,
                  ),
                ),

                const Padding(padding: EdgeInsets.only(bottom: 5),
                  child: Text("ReverseRegistrar"),
                ),
                Text("abi: ReverseRegistrar")


              ],

            ),

          ]);
        } else {
          print("No reverseRegistrar");
        }

        // Registrar Node
        if (yamlFile?["topology_template"]["node_templates"]["registrar"]
            .toString() != null) {
          print(yamlFile?["topology_template"]["node_templates"]["registrar"]
              .toString());
          nodes.addAll([
            // Arrow to Registrar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: CustomPaint(
                painter: ArrowPainter(
                  color: Colors.blue,
                  angle: -math.pi,
                  length: 60,
                ),
                size: const Size(10, 50),
              ),
            ),
            Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Image.asset(
                    "assets/icons/smart_14210186.png",
                    width: 50,
                    height: 50,
                  ),
                ),

                const Padding(padding: EdgeInsets.only(bottom: 5),
                  child: Text("Registrar"),

                ),
                const Text("abi: Registrar")

              ],
            ),
          ]);
        } else {
          print("No Registrar");
        }

        return nodes;
      } else {
        print("no network defined");
      }
    } else {
      print("empty topology");
    }
    return null;
  }


  Future<YamlMap?> loadYamlFromAssets(String assetPath) async {
    try {
      final contents = await rootBundle.loadString(assetPath);
      return loadYaml(contents);
    } catch (e) {
      // Handle error
      print('Could not load YAML from assets: $e');
      return null;
    }
  }


/*
  Future<Graph?> TopologyGraphFromYaml() async {
    var yamlFile = await ServiceProvider.ImportYaml();
    //print(yamlFile);
    var node_properties = yamlFile?['topology_template']['node_templates'];
    var node_topology_key = node_properties.keys.toList();
    List<String> imports = [];
    Graph graph = Graph()..isTree = false;
    Graph copygraph = Graph()..isTree = false;

    for (int i = 0; i < node_topology_key.length; i++) {
      var key1 = node_topology_key[i];
      var value2 = node_properties[key1];

     // print('Node Type ($i): $key1');
     // print('Node Type ($i): $value2');
      //print(value2["type"]);
    }
    YamlMap? yamlMap;
    if (yamlFile!["imports"]
        .toString()
        .isEmpty) {
      print("you cannot print a toplogy");
    } else {
     // print(yamlFile!["imports"].toString());

      if (yamlFile["topology_template"]
          .toString()
          .isEmpty) {
        print("Topology is empty");
      } else {
        if (yamlFile["node_templates"]
            .toString()
            .isEmpty) {
          print("no node present in the topology");
        } else {
          // for each element in the topology I have to verify if the type is one of the known one
          for (int j = 0; j < yamlFile["imports"].length; j++) {

            yamlMap =
            await loadYamlFromAssets("katena-main/" + yamlFile["imports"][j]);
            // I have to Itereate the type of the import and the type of the node
            //print(yamlFile["imports"][j]);

            for (int h = 0; h < yamlMap?["node_types"].length; h++) {
            /*
              for (int i = 0; i < yamlFile["node_templates"].length; i++) {
                if (yamlMap?["node_types"][h] ==
                    yamlFile["node_templates"][i]) {
                  print("1");
                }
              }
             */
            // print(yamlMap?["node_types"]["katena.nodes.wallet"]);
              var nodeTypes = yamlMap?['node_types'];
              var nodeTypeKeys = nodeTypes.keys.toList();
              for (int i = 0; i < nodeTypeKeys.length; i++) {
                String importItem = nodeTypeKeys[i]; // No explicit casting needed
                imports.add(importItem);
                //print("Import item at index $i: $importItem");
              }





            }
          }
        }


        for(int y=0;y<node_topology_key.length;y++) {



          //print(node_properties[node_topology_key[y]]["type"]);

          for (int x = 0; x < imports.length; x++) {



            if (node_properties[node_topology_key[y]]["type"] ==
                imports[x]) {

             // Node node1 = Node.Id(node_properties[node_topology_key[y]]["type"]);
           //   Node node2 = Node.Id(node_properties[node_topology_key[y+1]]["type"]);
            Node node1=Node.Id(node_topology_key[y]);
            Node node2=Node.Id(node_topology_key[y+1]);
              graph.addEdge(node1, node2);
              copygraph=graph;
              //print(copygraph.nodes);
              //print(copygraph.nodes);


            }



          }
        }


      }
      return copygraph;
    }

  }

 */

  Future<Graph?> TopologyGraphFromYaml() async {
    var yamlFile = await ServiceProvider.ImportYaml();
    var nodeProperties = yamlFile?['topology_template']['node_templates'];
    Node node1 = Node.Id("");
    List<String>? bElements;
    if (nodeProperties == null) {
      print("No node templates found in YAML.");
      return null;
    }
    String? requirementsList1;
    var nodeTopologyKeys = nodeProperties.keys.toList();
    List<String> imports = [];
    Graph graph = Graph()
      ..isTree = false;

    if (yamlFile?["imports"] != null && yamlFile!["imports"].isNotEmpty) {
      for (var importPath in yamlFile["imports"]) {
        try {
          YamlMap? yamlMap = await loadYamlFromAssets(
              "katena-main/$importPath");
          var nodeTypes = yamlMap?['node_types'];
          if (nodeTypes != null) {
            imports.addAll(nodeTypes.keys.cast<String>());
          }
        } catch (e) {
          print("Error loading import: $importPath - $e");
        }
      }
    } else {
      print("No imports found in YAML.");
    }

    // print("Imports: $imports"); // Print the list of imports


    for (int y = 0; y < nodeTopologyKeys.length; y++) {
      for (var importItem in imports) {
        if (nodeProperties[nodeTopologyKeys[y]]["type"] == importItem) {
          node1 = Node.Id("name:" + nodeTopologyKeys[y] + "\n" + "type:" +
              nodeProperties[nodeTopologyKeys[y]]["type"]);
          //node2 = Node.Id(nodeTopologyKeys[y+1]);
          graph.addNode(node1);
          // graph.addNode(node2);
          // print(graph.nodes);


        }
      }
      /*
    for(Node ele in graph.nodes)
      {
        print(ele.key);
*/
      Node node = Node.Id("");

      for (Node ele in graph.nodes) {
        //print(ele);
        List<String> lines = ele.key?.value.split('\n');
        Map<String, String> typeMap = {};
        for (var line in lines) {
          List<String> parts = line.split(':');
          if (parts.length == 2) {
            String key = parts[0].trim();
            String value = parts[1].trim();
            typeMap[key] = value;
          }
        }

        if (typeMap['name'] == nodeTopologyKeys[y]) {
          node = ele;
          //print(node);
          //  print(ele.key?.value);
        }
      }
      // print(yamlFile?['topology_template']['node_templates'][nodeTopologyKeys[y]]["requirements"]
      // .toString());
      requirementsList1 =
          yamlFile?['topology_template']['node_templates'][nodeTopologyKeys[y]]["requirements"]
              .toString();
      //print(requirementsList1);
      bElements = requirementsList1?.split(',').map((item) {
        var parts = item.trim().split(':');
        return parts.length > 1 ? parts[1] : ''; // Extract 'b' if it exists
      }).toList();
      for (int l = 0; l < bElements!.length; l++) {
        bElements[l] = bElements[l].replaceFirst("}", "");
        bElements[l] = bElements[l].replaceFirst(" ", "");
      }
      bElements.last = bElements.last.replaceFirst("]", "");

      // print(requirementsList);

      // Check if requirements is a List
      // Check if next node is in requirements and create edge if it is
      for (var ul in bElements) {
        // Assuming you have a way to create a Node from an I
        for (Node elem in graph.nodes) {
          //print(elem.key?.value);
          //print(ul+'ee');
          //print(ele);
          List<String> lines = elem.key?.value.split('\n');
          Map<String, String> typeMap = {};
          for (var line in lines) {
            List<String> parts = line.split(':');
            if (parts.length == 2) {
              String key = parts[0].trim();
              String value = parts[1].trim();
              typeMap[key] = value;
            }
          }



          if (ul.compareTo(typeMap['name']!) == 0) {
            graph.addEdge(node, elem);
          }
        }
        //print("Added edge between ${node1.id} and ${node2.id}"); // Assuming Node has an 'id' property
      }
    }

    print("Graph nodes: ${graph.nodes}"); // Print the nodes in the graph

    return graph;
  }

  Future<List<String>?> NodesDefinition() async {
    try {
      List<String> TypesToPrint= [];
      // Load the AssetManifest.json which contains a list of all assets
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      // Filter the list to get only the YAML files in the katena-main/nodes directory
      final yamlFiles = manifestMap.keys
          .where((String key) =>
      key.startsWith('assets/katena-main/nodes/') && key.endsWith('.yaml'))
          .toList();

      for (var file in yamlFiles) {
        // Read the YAML file
        final yamlContent = await rootBundle.loadString(file);
        final yamlMap = loadYaml(yamlContent) as YamlMap;
        var nodeTypes = yamlMap["node_types"];
        //print(yamlMap);
        if(nodeTypes!=null) {
          for (var entry in nodeTypes.entries) {
            print('Key: ${entry.key}, Value: ${entry.value}');
            TypesToPrint.add(entry.key);
          }
           print(TypesToPrint);


        }




      }
      return TypesToPrint;
      }catch(e){
      print('Error loading descriptions: $e');
    }



    return null;

  }

  Future<YamlMap?> GetDescriptionByType(String type) async {

    try {
      // Load the AssetManifest.json which contains a list of all assets
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      // Filter the list to get only the YAML files in the katena-main/nodes directory
      final yamlFiles = manifestMap.keys
          .where((String key) =>
      key.startsWith('assets/katena-main/nodes/') && key.endsWith('.yaml'))
          .toList();

      for (var file in yamlFiles) {
        // Read the YAML file
        final yamlContent = await rootBundle.loadString(file);
        final yamlMap = loadYaml(yamlContent) as YamlMap;
        var nodeTypes = yamlMap["node_types"];
       // print(yamlMap);

        // print(nodeTypes);
        if(nodeTypes!=null)
          {
            for (var entry in nodeTypes.entries) {
              if(entry.key==type) {
                print('Key: ${entry.key}, Value: ${entry.value}');
                return entry.value;
              }
            }
        }




      }
    } catch(e) {
      print('Error loading descriptions: $e');
    }
    return null;
  }


  Future<Graph?> TopologyCreator() async {
    //TODO method for creating a new Topology
    return null;
  }
}
