


import 'dart:io';
import 'dart:js_interop';
import 'dart:math';
import 'dart:html' as html;
import 'dart:convert'; // For utf8.encode
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
import 'package:yaml_writer/yaml_writer.dart';

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
  Future<Graph?> TopologyGraphFromYaml() async {
    var yamlFile = await ServiceProvider.ImportYaml();
    var nodeProperties = yamlFile?['topology_template']['node_templates'];
    if (nodeProperties == null) {
      print("No node templates found in YAML.");
      return null;
    }

    Graph graph = Graph()..isTree = false;
    List<String> imports = [];

    // Load imports
    if (yamlFile?["imports"] != null && yamlFile!["imports"].isNotEmpty) {
      for (var importPath in yamlFile["imports"]) {
        try {
          YamlMap? yamlMap = await loadYamlFromAssets("katena-main/$importPath");
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

    // Create nodes and add to graph
    Map<String, Node> nodes = {};
    for (var key in nodeProperties.keys) {
      if (imports.contains(nodeProperties[key]["type"])) {
        Node node = Node.Id("name:$key\ntype:${nodeProperties[key]["type"]}");
        graph.addNode(node);
        nodes[key] = node;
        print("Node added: ${node.key?.value}"); // Debug print
      } else {
        print("Node type not in imports: ${nodeProperties[key]["type"]}"); // Debug print
      }
    }

    // Add edges based on requirements
    for (var key in nodeProperties.keys) {
      var requirements = nodeProperties[key]["requirements"];
      if (requirements != null) {
        Node? node = nodes[key];
        if (node != null) {
          for (var requirement in requirements) {
            var targetNodeName = requirement.values.first;
            print("Node $key requires: $targetNodeName"); // Debug print
            Node? targetNode;
            if (targetNodeName is YamlMap) {
              print("Target node name (YamlMap): ${targetNodeName.values.first}");
              targetNode = nodes[targetNodeName.values.first.toString()];
            } else {
              print("Target node name: $targetNodeName");
              targetNode = nodes[targetNodeName];
            }

            if (targetNode != null) {
              graph.addEdge(node, targetNode);
              print("Edge added from ${node.key?.value} to ${targetNode.key?.value}"); // Debug print
            } else {
              print("Target node not found: $targetNodeName"); // Debug print
            }
          }
        }
      }
    }

    print("Graph nodes: ${graph.nodes.length}, ${graph.edges.length} edges created."); // Debug print
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
  Future<String> _getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/topology.yaml';
  }


  Future<YamlMap?> graphToYamlParser(Graph graph) async{
    final yamlWriter = YAMLWriter();
    final Map<String, dynamic> yamlMap = {
      'tosca_definitions_version': 'tosca_simple_yaml_1_3',
      'topology_template': {
        'node_templates': {}
      }
    };
/*
    for (var node in graph.nodes) {
      yamlMap['topology_template']['node_templates'][node.key?.value] = {
        'type': node.type,
        'properties': node.properties,
        'requirements': node.requirements.entries.map((entry) => {entry.key: entry.value}).toList(),
      };
    }

 */



    final yamlString = yamlWriter.write(yamlMap);
    return loadYaml(yamlString) as YamlMap;


  }



  String getCurrentTimestampString() {
    final DateTime now = DateTime.now();
    return now.toString();
  }

  Future<void> saveFile(Graph graph) async {
    Provider serviceProvider= Provider.instance;
    YamlMap? grahToYamlData= await serviceProvider.graphToYamlParser(graph);
    final text = grahToYamlData;

    // Convert the text to bytes and create a Blob
    final bytes = utf8.encode(text.toString());
    final blob = html.Blob([bytes]);

    // Create a URL for the Blob and an anchor element
    //Timestamp added to each topology name to avoid confusion
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'topology${serviceProvider.getCurrentTimestampString()}.yaml')
      ..click();

    // Revoke the object URL
    html.Url.revokeObjectUrl(url);
  }


  Future<YamlMap?> GetDescriptionByTypeforManagement(String? type) async {

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
              // print('Key: ${entry.key}, Value: ${entry.value}');
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
               // print('Key: ${entry.key}, Value: ${entry.value}');
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



  String? getType(String yamlContent) {
    // Parse the YAML content
    final parsedYaml = loadYaml(yamlContent);

    // Traverse the parsed structure to find the type
    if (parsedYaml['host'] != null && parsedYaml['host']['type'] != null) {
      return parsedYaml['host']['type'];
    } else {
      return null;
    }
  }

  Future<String?> GetCapabilitiesByType(String type) async {

    try {
      // Load the AssetManifest.json which contains a list of all assets
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);
      var yamlContentToBeFound;
      var yamlMapToBeFound;
      var nodeTypeToBeFound;
      String? capability;
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
              // print('Key: ${entry.key}, Value: ${entry.value}');
               yamlContentToBeFound = await rootBundle.loadString(file);
               yamlMapToBeFound= loadYaml(yamlContent) as YamlMap;
               nodeTypeToBeFound=yamlMapToBeFound["node_types"];
              break;

            }
          }
        }




      }


      for (var nodeTypeEntry in nodeTypeToBeFound.entries) {
        String nodeTypeName = nodeTypeEntry.key;
        YamlMap nodeType = nodeTypeEntry.value;

        if (nodeType.containsKey('capabilities')) {
          var capabilities = nodeType['capabilities'];
          print(capabilities);
          /*
          for (var capability in capabilities) {
            print('Capability in $nodeTypeName: ${capability['name']}');
            print(capability);
          }

           */
          capability=getType(capabilities.toString());
          return capability;

        }else{
            print("It could be a child or capabilities are not defined for that node");
        }
      }

    } catch(e) {
      print('Error loading descriptions: $e');
    }
    return null;
  }



  Future<Graph?> TopologyCreatorNodes(String type,Graph graph,Node? root) async {
    Provider serviceProvider=Provider.instance;


    if(graph.hasNodes())
      {
        print("graph is not empty");
        graph.removeNode(root);
      }
    else{
          print("graph is empty a new one is created");
          graph = Graph()
            ..isTree = false;
    }
    Node node;
    final yamlMap = await serviceProvider.GetDescriptionByType(type)  as YamlMap;



    if(yamlMap!=null) {
      node = Node.Id(type);
      print(node);
      graph.addNode(node);


    }





    print(yamlMap);
    return graph;


  }

  Future<Graph?> TopologyGraphFromYamlWithTypes() async {
    var yamlFile = await ServiceProvider.ImportYaml();
    var nodeProperties = yamlFile?['topology_template']['node_templates'];
    if (nodeProperties == null) {
      print("No node templates found in YAML.");
      return null;
    }

    Graph graph = Graph()..isTree = false;
    List<String> imports = [];

    // Load imports
    if (yamlFile?["imports"] != null && yamlFile!["imports"].isNotEmpty) {
      for (var importPath in yamlFile["imports"]) {
        try {
          YamlMap? yamlMap = await loadYamlFromAssets("katena-main/$importPath");
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

    // Create nodes and add to graph
    Map<String, Node> nodes = {};
    for (var key in nodeProperties.keys) {
      if (imports.contains(nodeProperties[key]["type"])) {
        Node node = Node.Id(nodeProperties[key]["type"]);
        graph.addNode(node);
        nodes[key] = node;
        print("Node added: ${node.key?.value}"); // Debug print
      } else {
        print("Node type not in imports: ${nodeProperties[key]["type"]}"); // Debug print
      }
    }

    // Add edges based on requirements
    for (var key in nodeProperties.keys) {
      var requirements = nodeProperties[key]["requirements"];
      if (requirements != null) {
        Node? node = nodes[key];
        if (node != null) {
          for (var requirement in requirements) {
            var targetNodeName = requirement.values.first;
            print("Node $key requires: $targetNodeName"); // Debug print
            Node? targetNode;
            if (targetNodeName is YamlMap) {
              print("Target node name (YamlMap): ${targetNodeName.values.first}");
              targetNode = nodes[targetNodeName.values.first.toString()];
            } else {
              print("Target node name: $targetNodeName");
              targetNode = nodes[targetNodeName];
            }

            if (targetNode != null) {
              graph.addEdge(node, targetNode);
              print("Edge added from ${node.key?.value} to ${targetNode.key?.value}"); // Debug print
            } else {
              print("Target node not found: $targetNodeName"); // Debug print
            }
          }
        }
      }
    }

    print("Graph nodes: ${graph.nodes.length}, ${graph.edges.length} edges created."); // Debug print
    return graph;
  }

  Future<Graph?> TopologyCreatorEdges(String type,Graph graph,Node sourceNode,Node destinationNode) async {
    Provider serviceProvider= Provider.instance;


    if(graph.nodes.length==1 && type=="Add edge")
    {

            Node node1 = Node.Id("Root Node");
            graph.addNode(node1);

            return graph;
    }else if(type=="Add edge" && graph.nodes.length>1)
    {

         YamlMap? source = await serviceProvider.GetDescriptionByTypeforManagement(sourceNode.key?.value);
         YamlMap? destination = await serviceProvider.GetDescriptionByTypeforManagement(destinationNode.key?.value);

         if(source?["requirements"]!=null) {
           var sourceReq=source?["requirements"];

           for(var req in sourceReq)
             {
               var sreq = req.values.first;

                    if(sreq["capability"]!=null)
                      {
                        //print(await serviceProvider.GetCapabilitiesByType(destinationNode.key?.value));
                        String? capacity_fatality=await serviceProvider.GetCapabilitiesByType(destinationNode.key?.value);
                        if(sreq["capability"]==capacity_fatality) {
                          graph.addEdge(sourceNode, destinationNode);
                        }else
                          {
                            print("the two nodes are not compatible");
                          }
                      }else{

                        print("if requirement is null the node is not connectable");

                    }

             }


         }else
           {
             print("up to now do nothing");
           }


      return graph;
    }
      return null;
  }



  }



