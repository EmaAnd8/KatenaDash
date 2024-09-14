import 'dart:collection';
import 'dart:io';
import 'dart:js_interop';
import 'dart:math';
import 'dart:html' as html;
import 'dart:convert'; // For utf8.encode
import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:math' as math ;
import 'dart:convert';
import 'package:path/path.dart' as path;
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
      final imageFile = await ImagePicker().pickImage(
          source: ImageSource.gallery);
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
      final storageRef = FirebaseStorage.instance.ref().child(
          'Profile/$profileImagePath');
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


  Map<String, dynamic> mergeYamlMaps(Map<String, dynamic> map1, Map<String, dynamic> map2) {
    // Create a new map to store the merged result
    Map<String, dynamic> result = {};

    // Add all keys from map1
    map1.forEach((key, value) {
      if (map2.containsKey(key)) {
        // If both maps contain the same key, handle the merge based on value type
        if (value is Map && map2[key] is Map) {
          // If both values are maps, merge them recursively
          result[key] = mergeYamlMaps(Map<String, dynamic>.from(value), Map<String, dynamic>.from(map2[key]));
        } else if (key == 'requirements' && value is List && map2[key] is List) {
          // If the key is 'requirements' and both values are lists, merge them
          result[key] = List.from(value)..addAll(map2[key]);
        } else {
          // Otherwise, take the value from map2
          result[key] = map2[key];
        }
      } else {
        // If only map1 has the key, add it to the result
        result[key] = value;
      }
    });

    // Add all keys from map2 that are not in map1
    map2.forEach((key, value) {
      if (!result.containsKey(key)) {
        result[key] = value;
      }
    });

    return result;
  }




  Future<Map<String, dynamic>?> ImportYaml() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: true,
      allowedExtensions: ['yaml'],
    );

    Map<String, dynamic>? mergedMap;

    if (result != null) {
      try {
        List<PlatformFile> files = result.files;

        for (var file in files) {
          final yamlString = utf8.decode(file.bytes!);
          final yamlMap = loadYaml(yamlString) as YamlMap;
          final Map<String, dynamic> yamlMapAsMap = convertYamlMapToMap(yamlMap);
          print(yamlMapAsMap);
          print("%%%%%%%%%%%%%%%%%%%%%%%%%%%");


          if (mergedMap == null) {
            mergedMap = yamlMapAsMap;
          } else {
            mergedMap = mergeYamlMaps(mergedMap, yamlMapAsMap);
          }


        }
        print(mergedMap);
        return mergedMap;

      } catch (e) {
        print("Error during YAML import: $e");
        return null;
      }
    } else {
      print("No file selected");
      return null;
    }
  }



// Helper function to convert YamlMap to Map<String, dynamic>
  Map<String, dynamic> convertYamlMapToMap(YamlMap yamlMap) {
    return yamlMap.map((key, value) {
      if (value is YamlMap) {
        return MapEntry(key.toString(), convertYamlMapToMap(value));
      } else if (value is YamlList) {
        return MapEntry(key.toString(), value.map((item) {
          if (item is YamlMap) {
            return convertYamlMapToMap(item);
          } else {
            return item;
          }
        }).toList());
      } else {
        return MapEntry(key.toString(), value);
      }
    });
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
    print(yamlFile);
    Graph graph = Graph()
      ..isTree = false;
    List<String> imports = [];

    // Load imports
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

    // Load the AssetManifest.json which contains a list of all assets
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    for(var key in  nodeProperties.keys)
    {
      if(!imports.contains(nodeProperties[key]["type"]))
      {
        final yamlFiles = manifestMap.keys
            .where((String key) =>
        key.startsWith('assets/katena-main/nodes/') && key.endsWith('.yaml'))
            .toList();

        for (var file in yamlFiles) {
          // Read the YAML file
          final yamlContent = await rootBundle.loadString(file);
          final yamlMap = loadYaml(yamlContent) as YamlMap;
          var nodeTypes = yamlMap["node_types"];
          if (nodeTypes != null) {
            for (var entry in nodeTypes.entries) {
              if (entry.key == nodeProperties[key]["type"]) {
                imports.addAll(nodeTypes.keys.cast<String>());
                break;
              }
            }
          }
        }
      }else{
        print("requirement already present or nodes not defined");
      }
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
        print(
            "Node type not in imports: ${nodeProperties[key]["type"]}"); // Debug print
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
              print(
                  "Target node name (YamlMap): ${targetNodeName.values.first}");
              targetNode = nodes[targetNodeName.values.first.toString()];
            } else {
              print("Target node name: $targetNodeName");
              targetNode = nodes[targetNodeName];
            }

            if (targetNode != null) {
              if (node != targetNode) {
                graph.addEdge(node, targetNode);
              } else {
                print("the node is connected to itself");
              }
            } else {
              print("Target node not found: $targetNodeName"); // Debug print
            }
          }
        }
      }
    }

    print("Graph nodes: ${graph.nodes.length}, ${graph.edges
        .length} edges created."); // Debug print
    return graph;
  }


  Future<List<String>?> NodesDefinition() async {
    try {
      List<String> TypesToPrint = [];
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
        if (nodeTypes != null) {
          for (var entry in nodeTypes.entries) {
            print('Key: ${entry.key}, Value: ${entry.value}');
            TypesToPrint.add(entry.key);
          }
          print(TypesToPrint);
        }
      }
      return TypesToPrint;
    } catch (e) {
      print('Error loading descriptions: $e');
    }


    return null;
  }

  Map<String, dynamic> addToMap(Map<String, dynamic> typeMap, String name,
      dynamic value, List<Map<String, String>> requirements) {
    // Add the name-value pair to the map
    typeMap[name] = value;

    // Convert the dynamic map to a Map<String, String>
    Map<String, String> stringMap = typeMap.map((key, value) =>
        MapEntry(key, value.toString()));

    // Add the stringMap to the requirements list
    requirements.add(stringMap);

    // Return the updated map
    return typeMap;
  }

  void removeFromMap(Map<String, dynamic> typeMap, String name,
      List<Map<String, String>> requirements) {
    // Remove the key-value pair from the map
    typeMap.remove(name);

    // Convert the updated dynamic map to a Map<String, String>
    Map<String, String> updatedStringMap = typeMap.map((key, value) =>
        MapEntry(key, value.toString()));

    // Remove the corresponding map from the requirements list
    requirements.removeWhere((map) => map.containsKey(name));

    // If the typeMap is now empty, you might want to remove the entire map from requirements
    if (updatedStringMap.isEmpty) {
      requirements.remove(updatedStringMap);
    }
  }
  Future<Map<String, dynamic>?> graphToYamlParserNodes(Graph graph, Map<String, dynamic> nodeProperties, Map<String, dynamic> inputs) async {
    Provider serviceProvider = Provider.instance;

    // Base YAML structure
    final Map<String, dynamic> yamlMap = {
      'tosca_definitions_version': 'tosca_simple_yaml_1_3',
      'imports': [
        'nodes/contract.yaml',
        'nodes/network.yaml',
        'nodes/wallet.yaml'
      ],
      'topology_template': {
        'node_templates': {}
      },
      'inputs': {
        'UserKeyGanache': {
          'type': 'string',
          'required': true
        },
        'UserWallet': {
          'type': 'string'
        }
      }
    };

    // Check if the graph has nodes and add them to the YAML structure
    if (graph.nodes.isNotEmpty) {
      for (var node in graph.nodes) {
        String nodeId = node.key?.value ?? '';

        // Parse the nodeId to get the node name and type
        Map<String, String> typeMap = serviceProvider.parseKeyValuePairs(nodeId);
        print(typeMap);
        print("//////////////////////////////");
        print(nodeProperties);
        String nodeName = typeMap["name"] ?? '';
        String nodeType = typeMap["type"] ?? '';

        // Initialize node-specific properties to an empty map
        Map<String, dynamic> nodeSpecificProperties = {};

        // Find and assign node-specific properties from the nodeProperties map
        print("yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy");
        // Iterate through the map keys and print each key
        for (String key in nodeProperties.keys) {
          print('Key: $key');
        }
        print("name:" + nodeName + "\n" + "type:" + nodeType);
        print(nodeProperties["name:" + nodeName + "\n" + "type:" + nodeType]);
        print("yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy");
        for (String key in nodeProperties.keys) {
          if (key == "name:" + nodeName + "\n" + "type:" + nodeType) {
            nodeSpecificProperties = nodeProperties["name:" + nodeName + "\n" + "type:" + nodeType];
            break;
          }
        }

        // Ensure that the node has both properties and requirements sections
        yamlMap['topology_template']['node_templates'][nodeName] = {
          'type': nodeType,
          'requirements': [],  // Empty requirements, can be updated later
          'properties': nodeSpecificProperties.isNotEmpty ? nodeSpecificProperties : {}  // Use the properties if found, else an empty map
        };

        // Debugging output to verify the correct properties are added
        print("Node: $nodeName, Properties: $nodeSpecificProperties");
      }

      // Debugging output to check the complete YAML map
      print("Generated YAML Map:\n$yamlMap");
      print(yamlMap);
      return yamlMap;
    } else {
      print("Nothing to export, empty graph");
      return yamlMap;
    }
  }

  Future<YamlMap?> graphToYamlParserEdges(Edge edge,Map<String, dynamic> nodeProperties, Map<String, dynamic> inputs) async {
    Provider serviceProvider = Provider.instance;
    Map<String, dynamic>? yamlMap;
    final yamlWriter = YAMLWriter();
    // Reinitialize for each edge
    if (graph.nodes.isEmpty) {
      yamlMap = (await serviceProvider.graphToYamlParserNodes(graph,nodeProperties,inputs))!;
      final yamlString = yamlWriter.write(yamlMap);
      return loadYaml(yamlString) as YamlMap;
    } else {
      yamlMap = (await serviceProvider.graphToYamlParserNodes(graph,nodeProperties,inputs))!;
    }

    String sourceNodeId = edge.source.key?.value;
    String destinationNodeId = edge.destination.key?.value;

    Map<String, String> sourceTypeMap = serviceProvider.parseKeyValuePairs(sourceNodeId);
    Map<String, String> destinationTypeMap = serviceProvider.parseKeyValuePairs(destinationNodeId);

    var descSource = await GetDescriptionByTypeforManagement(sourceTypeMap["type"]);
    if (descSource != null) {
      Map<String, dynamic> typeMap2 = {
      };
      Map<String, dynamic> typeMap3 = {}; // Reinitialize for each edge
      var sourceNodeReqs = descSource["requirements"];
      if(sourceNodeReqs!=null){
        for (var elem in sourceNodeReqs) {
          var firstReq = elem.values.first;
          if (firstReq["capability"] != null) {
            String? destCap = await GetCapabilitiesByType(
                destinationTypeMap["type"]!);
            print(firstReq);
            print("2k2k2k2");
            //  var req_ex=await serviceProvider.GetDescriptionByType(firstReq["node"]);

            //      var reg_ex_req= req_ex?["requirements"];
            //    print(reg_ex_req);
            /*print(firstReq["node"]);
           bool flag=true;

           for(var elex in reg_ex_req)
             {
               var firstReqs = elex.values.first;
               if(firstReqs["capability"]==destCap)
                 {
                   flag=false;
                   break;
                 }
             }

            */
            if ((firstReq["node"] != null &&
                firstReq["node"] == "katena.nodes.library") ||
                (destCap == firstReq["capability"] &&
                    firstReq["node"] == null) ||
                (destCap == firstReq["capability"])) {
              String requirementName = serviceProvider.parseReqName(
                  elem.toString());

              bool isRequirementNameDuplicate = typeMap3.containsKey(
                  requirementName);
              bool isDestinationTypeDuplicate = typeMap3.values.any((value) {
                return value.contains(destinationTypeMap["name"]);
              });
              bool isRequirementNameDuplicate2 = typeMap2.containsKey(
                  requirementName);
              bool isDestinationTypeDuplicate2 = typeMap2.values.any((value) {
                return value.contains(destinationTypeMap["name"]);
              });
              //refactor for the specific case of library node
              if (firstReq["node"] != "katena.nodes.library") {
                if (!isRequirementNameDuplicate &&
                    !isDestinationTypeDuplicate ||
                    (!isRequirementNameDuplicate2 &&
                        !isDestinationTypeDuplicate2)) {
                  typeMap3 = serviceProvider.addToMap(
                      typeMap3, requirementName, destinationTypeMap["name"],
                      []);
                }

                Map<String, dynamic> concatenatedMap = {
                  ...typeMap3,
                  ...typeMap2,
                };
                print(concatenatedMap);
                print("£££££££££££££££££££££££££££££");
                if (concatenatedMap.isNotEmpty) {
                  yamlMap['topology_template']['node_templates'][sourceTypeMap["name"]]['requirements'] =
                  [concatenatedMap];
                }
              } else {
                var descSource2 = await GetDescriptionByTypeforManagement(
                    "katena.nodes.library");
                if (descSource2 != null) {
                  var sourceNodeReqs = descSource2["requirements"];
                  print(sourceNodeReqs);
                  for (var elem in sourceNodeReqs) {
                    var firstReq = elem.values.first;
                    if (firstReq["capability"] != null) {
                      String? destCap = await GetCapabilitiesByType(
                          destinationTypeMap["type"]!);

                      if ((firstReq["node"] != null &&
                          firstReq["node"] == destinationTypeMap["type"]) ||
                          (destCap == firstReq["capability"] &&
                              firstReq["node"] == null)) {
                        String requirementName = serviceProvider.parseReqName(
                            elem.toString());

                        bool isRequirementNameDuplicate = typeMap2.containsKey(
                            requirementName);
                        bool isDestinationTypeDuplicate = typeMap2.values.any((
                            value) {
                          return value.contains(destinationTypeMap["name"]);
                        });
                        print(typeMap2);
                        print("&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&6");
                        //refactor for the specific case of library node
                        // if (firstReq["node"] == "katena.nodes.library") {
                        if (!isRequirementNameDuplicate &&
                            !isDestinationTypeDuplicate) {
                          typeMap2 = serviceProvider.addToMap(
                              typeMap2, requirementName,
                              destinationTypeMap["name"],
                              []);
                        }

                        Map<String, dynamic> concatenatedMap = {
                          ...typeMap3,
                          ...typeMap2,
                        };
                        print(concatenatedMap);
                        print("£££££££££££££££££££££££££££££");
                        if (concatenatedMap.isNotEmpty) {
                          yamlMap['topology_template']['node_templates'][sourceTypeMap["name"]]['requirements'] =
                          [concatenatedMap];
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }


    Map<String, dynamic> typeMap3in = {};
    Map<String, dynamic> typeMap2in = {};
    var some_der_req= await serviceProvider.getInheritedRequirements(sourceTypeMap["type"]!,descSource!);
    //final yamlList = loadYaml(some_der_req as String) as YamlList;
    print(some_der_req);
    print("mnnedodenonfeoeonfeofneofnnofenfoeon");

    for(var lreq in some_der_req)
    {
      print(lreq);
      print("KKKKKKKKKKKKKKKKKKKKKK");
      var sourceReq2 = lreq["requirements"];

      for(var i_req in sourceReq2)
      {

        var inreqsource2 = i_req.values.first;
        print(destinationTypeMap["type"]);

        String? capacity_fatality3= await serviceProvider
            .GetCapabilitiesByType(destinationTypeMap["type"]!);
        //print(capacity_fatality3!+"cccccccc");
        if ((inreqsource2["node"] != null && inreqsource2["node"]=="katena.nodes.library")  || (capacity_fatality3 == inreqsource2["capability"] && inreqsource2["node"] == null)  || (capacity_fatality3 == inreqsource2["capability"] ) || (inreqsource2["node"]==destinationTypeMap["type"] && capacity_fatality3==null)) {
          // graph.addEdge(sourceNode, destinationNode);
          print(inreqsource2);
          String requirementName = serviceProvider.parseReqName(
              i_req.toString());

          bool isRequirementNameDuplicate = typeMap3in.containsKey(
              requirementName);
          bool isDestinationTypeDuplicate = typeMap3in.values.any((value) {
            return value.contains(destinationTypeMap["name"]);
          });
          bool isRequirementNameDuplicate2 = typeMap2in.containsKey(
              requirementName);
          bool isDestinationTypeDuplicate2 = typeMap2in.values.any((value) {
            return value.contains(destinationTypeMap["name"]);
          });
          //refactor for the specific case of library node
          if (inreqsource2["node"] != "katena.nodes.library") {
            if (!isRequirementNameDuplicate &&
                !isDestinationTypeDuplicate || (!isRequirementNameDuplicate2 &&
                !isDestinationTypeDuplicate2)) {
              typeMap3in = serviceProvider.addToMap(
                  typeMap3in, requirementName, destinationTypeMap["name"],
                  []);
            }

            Map<String, dynamic> concatenatedMap = {
              ...typeMap3in,
              ...typeMap2in,
            };
            print(concatenatedMap);
            print("£££££££££££££££££££££££££££££");
            if(concatenatedMap.isNotEmpty) {
              yamlMap['topology_template']['node_templates'][sourceTypeMap["name"]]['requirements'] =
              [concatenatedMap];
            }

          } else {
            var descSource2 = await GetDescriptionByTypeforManagement(
                "katena.nodes.library");
            if (descSource2 != null) {
              var sourceNodeReqs = descSource2["requirements"];
              print(sourceNodeReqs);
              for (var elem in sourceNodeReqs) {
                var firstReq = elem.values.first;
                if (firstReq["capability"] != null) {
                  String? destCap = await GetCapabilitiesByType(
                      destinationTypeMap["type"]!);

                  if ((firstReq["node"] != null &&
                      firstReq["node"] == destinationTypeMap["type"]) ||
                      (destCap == firstReq["capability"] &&
                          firstReq["node"] == null) ||destCap==firstReq["capability"]) {
                    String requirementName = serviceProvider.parseReqName(
                        elem.toString());

                    bool isRequirementNameDuplicate = typeMap2in.containsKey(
                        requirementName);
                    bool isDestinationTypeDuplicate = typeMap2in.values.any((
                        value) {
                      return value.contains(destinationTypeMap["name"]);
                    });
                    print(typeMap2in);
                    print("&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&6");
                    //refactor for the specific case of library node
                    // if (firstReq["node"] == "katena.nodes.library") {
                    if (!isRequirementNameDuplicate &&
                        !isDestinationTypeDuplicate) {
                      typeMap2in = serviceProvider.addToMap(
                          typeMap2in, requirementName,
                          destinationTypeMap["name"],
                          []);
                    }

                    Map<String, dynamic> concatenatedMap = {
                      ...typeMap3in,
                      ...typeMap2in,
                    };
                    print(concatenatedMap);
                    print("£££££££££££££££££££££££££££££");
                    if (concatenatedMap.isNotEmpty) {
                      yamlMap['topology_template']['node_templates'][sourceTypeMap["name"]]['requirements'] =
                      [concatenatedMap];
                    }
                  }
                }
              }
            }
          }


        }
        else {
          print("the two nodes are not compatible");
        }
      }


    }




    final yamlString = yamlWriter.write(yamlMap);
    return loadYaml(yamlString) as YamlMap;
  }
// Helper function to parse key-value pairs from a string
  String parseReqName(String inputString) {
    String reqName='';

    String parsedInputString=inputString.replaceFirst("{", "");
    List<String> lines = parsedInputString.split(':');
    reqName=lines.first;



    return reqName;
  }

  // Helper function to parse key-value pairs from a string
  Map<String, String> parseKeyValuePairs(String input) {
    Map<String, String> keyValueMap = {};
    List<String> lines = input.split('\n');

    for (var line in lines) {
      List<String> parts = line.split(':');
      if (parts.length == 2) {
        String key = parts[0].trim();
        String value = parts[1].trim();
        keyValueMap[key] = value;
      }
    }

    return keyValueMap;
  }


  String getCurrentTimestampString() {
    final DateTime now = DateTime.now();
    return now.toString();
  }



// Recursive function to convert YamlMap to a Dart Map<String, dynamic>
  Map<String, dynamic> yamlMapToMap(YamlMap yamlMap) {
    final map = <String, dynamic>{};
    yamlMap.forEach((key, value) {
      // Special handling for requirements if detected
      if (key == 'requirements' && value is YamlList) {
        map[key.toString()] = _convertRequirements(value); // Process requirements as a list of maps
      } else {
        map[key.toString()] = _convertYamlValue(value);
      }
    });
    return map;
  }

// Helper function to handle various Yaml types (YamlList, YamlMap, etc.)
  dynamic _convertYamlValue(value) {
    if (value is YamlMap) {
      return yamlMapToMap(value); // Recursively convert YamlMap
    } else if (value is YamlList) {
      return value.map((e) => _convertYamlValue(e)).toList(); // Convert YamlList to Dart List
    } else {
      return value; // Return the value as is for non-YamlMap/List types
    }
  }

// Special handling function for requirements
  List<Map> _convertRequirements(YamlList yamlList) {
    // Each requirement in the list is a YamlMap, so convert them to Map<String, dynamic>
    return yamlList.map((requirement) {
      if (requirement is YamlMap) {
        // Convert the YamlMap to a Dart map for each requirement
        return yamlMapToMap(requirement);
      }
      return {}; // Return an empty map if the requirement is not valid
    }).toList();
  }

  Future<void> saveFile(Graph graph, Map<String, dynamic> nodeProperties, Map<String, dynamic> inputs) async {
    Provider serviceProvider = Provider.instance;

    if (graph.hasNodes()) {
      // Initialize a ZipEncoder to collect the files
      final archive = Archive();

      // Loop through each edge in the graph to generate YAML for each edge
      for (Edge edge in graph.edges) {
        // Retrieve the parsed YAML data for the edge
        YamlMap? graphToYamlData = await graphToYamlParserEdges(edge, nodeProperties, inputs);
        print(yamlMap);

        if (graphToYamlData != null) {
          // Convert the YamlMap to a regular Map<String, dynamic>
          Map<String, dynamic> yamlData = yamlMapToMap(graphToYamlData);
          print("okokokokokokkokookoo");
          print(yamlData);
          // Format the YAML data to a string for saving
          String yamlContent = formatYaml(yamlData);

          // Log the content to ensure it's not empty
          print('Generated YAML Content for edge ${edge.key}:\n$yamlContent');

          if (yamlContent.isNotEmpty) {
            // Convert the YAML content to bytes
            final bytes = utf8.encode(yamlContent);

            // Create a unique YAML file for each edge
            final fileName = 'topology_${serviceProvider.getCurrentTimestampString()}_${edge.key}.yaml';
            archive.addFile(ArchiveFile(fileName, bytes.length, bytes));
          }
        } else {
          print('No YAML data found for edge: ${edge.key}');
        }
      }

      if (archive.isNotEmpty) {
        // Encode the archive to a single zip file
        final zipData = ZipEncoder().encode(archive);

        if (zipData != null) {
          // Create a Blob from the zip data
          final blob = html.Blob([zipData]);

          // Create a URL for the Blob and an anchor element to download it
          final url = html.Url.createObjectUrlFromBlob(blob);
          final anchor = html.AnchorElement(href: url)
            ..setAttribute('download', 'topologies.zip')
            ..click();

          // Revoke the object URL to free memory
          html.Url.revokeObjectUrl(url);
        } else {
          print('Error encoding ZIP data.');
        }
      } else {
        print('No files to export.');
      }
    } else {
      print('The graph has no nodes.');
    }
  }
  String formatYaml(Map<String, dynamic> yamlData) {
    final buffer = StringBuffer();

    // Add the 'tosca_definitions_version'
    buffer.write('tosca_definitions_version: ${yamlData['tosca_definitions_version']}\n\n');

    // Add the 'imports'
    buffer.write('imports:\n');
    List<dynamic> imports = yamlData['imports'];
    if (imports != null && imports.isNotEmpty) {
      for (var importFile in imports) {
        buffer.write('- $importFile\n');
      }
    }
    buffer.write('\n');

    // Add the 'topology_template'
    buffer.write('topology_template:\n');

    // Add 'node_templates'
    Map<String, dynamic> nodeTemplates = yamlData['topology_template']['node_templates'];
    buffer.write('  node_templates:\n');
    if (nodeTemplates != null) {
      nodeTemplates.forEach((nodeName, nodeData) {
        buffer.write('    $nodeName:\n');
        buffer.write('      type: ${nodeData['type']}\n');

        // Handle requirements only if they exist and are not empty
        List<dynamic> requirements = nodeData['requirements'];
        if (requirements != null && requirements.isNotEmpty) {
          buffer.write('      requirements:\n');
          for (var requirement in requirements) {
            requirement.forEach((key, value) {
              buffer.write('      - $key: $value\n');
            });
          }
        }

        // Handle properties only if they exist and are not empty
        Map<String, dynamic> properties = nodeData['properties'];
        if (properties != null && properties.isNotEmpty) {
          buffer.write('      properties:\n');
          properties.forEach((key, value) {
            if (value is Map) {
              buffer.write('        $key:\n');
              value.forEach((innerKey, innerValue) {
                buffer.write('          $innerKey: $innerValue\n');
              });
            } else {
              buffer.write('        $key: $value\n');
            }
          });
        }
      });
    }

    // Add 'inputs'
    Map<String, dynamic> inputs = yamlData['inputs'];
    buffer.write('  inputs:\n');
    if (inputs != null && inputs.isNotEmpty) {
      inputs.forEach((inputName, inputData) {
        buffer.write('    $inputName:\n');
        buffer.write('      type: ${inputData['type']}\n');
        buffer.write('      required: ${inputData['required'] ?? false}\n'); // Default to false if null
      });
    }

    return buffer.toString();
  }


// Helper method to export the formatted YAML
  Future<void> exportYamlToFile(String yamlContent) async {
    // Convert the YAML content to bytes
    final bytes = utf8.encode(yamlContent);

    // Create a Blob from the bytes
    final blob = html.Blob([bytes]);

    // Create a URL for the Blob and an anchor element to download it
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'merged_topology.yaml')
      ..click();

    // Revoke the object URL after the download
    html.Url.revokeObjectUrl(url);
  }

// Helper method to merge duplicate requirements
  Map<String, String> _mergeRequirements(List<dynamic> requirements) {
    Map<String, String> mergedRequirements = {};

    for (var requirement in requirements) {
      requirement.forEach((key, value) {
        // Merge duplicates by overwriting the previous value if the key exists
        mergedRequirements[key] = value;
      });
    }

    return mergedRequirements;
  }

  String formatYamlMap2(Map<String, dynamic> yamlData) {
    final buffer = StringBuffer();

    // Add the 'tosca_definitions_version'
    var toscaVersion = yamlData['tosca_definitions_version'];
    if (toscaVersion != null) {
      buffer.write('tosca_definitions_version: $toscaVersion\n\n');
    } else {
      buffer.write('tosca_definitions_version: tosca_simple_yaml_1_3\n\n'); // Fallback if missing
    }

    // Add the 'imports'
    buffer.write('imports:\n');
    List<dynamic>? imports = yamlData['imports'];
    if (imports != null && imports.isNotEmpty) {
      for (var importFile in imports) {
        buffer.write('- $importFile\n');
      }
    }
    buffer.write('\n');

    // Add the 'topology_template'
    buffer.write('topology_template:\n');

    // Add 'node_templates'
    Map<String, dynamic>? nodeTemplates = yamlData['topology_template']?['node_templates'] as Map<String, dynamic>?;
    buffer.write('  node_templates:\n');
    if (nodeTemplates != null && nodeTemplates.isNotEmpty) {
      nodeTemplates.forEach((nodeName, nodeData) {
        buffer.write('    $nodeName:\n');

        var nodeType = nodeData['type'];
        if (nodeType != null) {
          buffer.write('      type: $nodeType\n');
        }

        // Handle requirements and merge duplicates
        List<dynamic>? requirements = nodeData['requirements'];
        if (requirements != null && requirements.isNotEmpty) {
          Map<String, String> mergedRequirements = _mergeRequirements(requirements);
          if (mergedRequirements.isNotEmpty) {
            buffer.write('      requirements:\n');
            mergedRequirements.forEach((key, value) {
              buffer.write('        - $key: $value\n');
            });
          }
        }

        // Handle properties if they exist and are not empty
        Map<String, dynamic>? properties = nodeData['properties'] as Map<String, dynamic>?;
        if (properties != null && properties.isNotEmpty) {
          buffer.write('      properties:\n');
          properties.forEach((key, value) {
            if (value is Map) {
              // TOSCA-compliant properties format
              buffer.write('        $key:\n');
              if (value.containsKey('description')) {
                buffer.write('          description: ${value['description']}\n');
              }
              if (value.containsKey('type')) {
                buffer.write('          type: ${value['type']}\n');
              }
              if (value.containsKey('required')) {
                buffer.write('          required: ${value['required']}\n');
              }
            }
          });
        }
      });
    } else {
      buffer.write('  node_templates: {}\n');
    }

    // Add 'inputs'
    Map<String, dynamic>? inputs = yamlData['topology_template']?['inputs'] as Map<String, dynamic>?;
    buffer.write('\n  inputs:\n');
    if (inputs != null && inputs.isNotEmpty) {
      inputs.forEach((inputName, inputData) {
        buffer.write('    $inputName:\n');
        buffer.write('      type: ${inputData['type'] ?? 'string'}\n');
        buffer.write('      required: ${inputData['required'] ?? 'false'}\n');
      });
    } else {
      buffer.write('  inputs: {}\n');
    }

    return buffer.toString();
  }



// Main function to import and export YAML
  Future<void> importAndExportYaml() async {
    // Step 1: Import and merge the YAML files
    Map<String, dynamic>? mergedYaml = await ImportYaml();

    if (mergedYaml != null) {
      // Step 2: Format the merged YAML into a string
      String formattedYaml = formatYamlMap2(mergedYaml);

      // Step 3: Export the formatted YAML as a single file
      await exportYamlToFile(formattedYaml);
    } else {
      print('No merged YAML data available for export.');
    }
  }





// Helper function to merge duplicate requirements



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
        if (nodeTypes != null) {
          for (var entry in nodeTypes.entries) {
            if (entry.key == type) {
              // print('Key: ${entry.key}, Value: ${entry.value}');
              return entry.value;
            }
          }
        }
      }
    } catch (e) {
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
        if (nodeTypes != null) {
          for (var entry in nodeTypes.entries) {
            if (entry.key == type) {
              // print('Key: ${entry.key}, Value: ${entry.value}');
              return entry.value;
            }
          }
        }
      }
    } catch (e) {
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

  String? getType2(String yamlContent) {
    // Parse the YAML content
    final parsedYaml = loadYaml(yamlContent);

    // Traverse the parsed structure to find the type
    if (parsedYaml!=null) {
      var type=parsedYaml.values.first;
      return type['type'];
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
        if (nodeTypes != null) {
          for (var entry in nodeTypes.entries) {
            if (entry.key == type) {
              // print('Key: ${entry.key}, Value: ${entry.value}');
              yamlContentToBeFound = await rootBundle.loadString(file);
              yamlMapToBeFound = loadYaml(yamlContent) as YamlMap;
              nodeTypeToBeFound = yamlMapToBeFound["node_types"];
              break;
            }
          }
        }
      }


      for (var nodeTypeEntry in nodeTypeToBeFound.entries) {
        String nodeTypeName = nodeTypeEntry.key;
        YamlMap nodeType = nodeTypeEntry.value;


        if ((nodeType.containsKey('capabilities') && nodeTypeName==type )) {
          var capabilities = nodeType['capabilities'];

          //print(capabilities);
          /*
          for (var capability in capabilities) {
            print('Capability in $nodeTypeName: ${capability['name']}');
            print(capability);
          }

           */
          capability = getType2(capabilities.toString());
          print(capability);
          return capability;

        }else if((!nodeType.containsKey('capabilities') && nodeTypeName==type)) {
          for (var nodeTypeEntry in nodeTypeToBeFound.entries) {
            String nodeTypeName = nodeTypeEntry.key;
            YamlMap nodeType = nodeTypeEntry.value;
            if (nodeType.containsKey("capabilities")) {
              var capabilities = nodeType['capabilities'];

              //print(capabilities);
              /*
          for (var capability in capabilities) {
            print('Capability in $nodeTypeName: ${capability['name']}');
            print(capability);
          }

           */
              capability = getType2(capabilities.toString());
              print(capability);
              return capability;
            }
          }
        }
        else
        {
          print("here the two nodes are not compatible");
        }


      }
    } catch (e) {
      print('Error loading descriptions: $e');
    }
    return null;
  }


  Future<Graph?> TopologyCreatorNodes(String name, String type, Graph graph,
      Node? root) async {
    Provider serviceProvider = Provider.instance;


    if (graph.hasNodes()) {
      print("graph is not empty");
      graph.removeNode(root);
    }
    else {
      print("graph is empty a new one is created");
      graph = Graph()
        ..isTree = false;
    }
    Node node;
    final yamlMap = await serviceProvider.GetDescriptionByType(type) as YamlMap;


    if (yamlMap != null) {
      node = Node.Id("name:$name\ntype:$type");
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
    // Load the AssetManifest.json which contains a list of all assets
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    Graph graph = Graph()
      ..isTree = false;
    List<String> imports = [];

    // Load imports
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

    for(var key in  nodeProperties.keys)
    {
      if(!imports.contains(nodeProperties[key]["type"]))
      {
        final yamlFiles = manifestMap.keys
            .where((String key) =>
        key.startsWith('assets/katena-main/nodes/') && key.endsWith('.yaml'))
            .toList();

        for (var file in yamlFiles) {
          // Read the YAML file
          final yamlContent = await rootBundle.loadString(file);
          final yamlMap = loadYaml(yamlContent) as YamlMap;
          var nodeTypes = yamlMap["node_types"];
          if (nodeTypes != null) {
            for (var entry in nodeTypes.entries) {
              if (entry.key == nodeProperties[key]["type"]) {
                imports.addAll(nodeTypes.keys.cast<String>());
                break;
              }
            }
          }
        }
      }else{
        print("requirement already present or nodes not defined");
      }
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
        print(
            "Node type not in imports: ${nodeProperties[key]["type"]}"); // Debug print
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
              print(
                  "Target node name (YamlMap): ${targetNodeName.values.first}");
              targetNode = nodes[targetNodeName.values.first.toString()];
            } else {
              print("Target node name: $targetNodeName");
              targetNode = nodes[targetNodeName];
            }

            if (targetNode != null) {
              graph.addEdge(node, targetNode);
              print("Edge added from ${node.key?.value} to ${targetNode.key
                  ?.value}"); // Debug print
            } else {
              print("Target node not found: $targetNodeName"); // Debug print
            }
          }
        }
      }
    }

    print("Graph nodes: ${graph.nodes.length}, ${graph.edges
        .length} edges created."); // Debug print
    return graph;
  }

  Future<Graph?> TopologyCreatorEdges(String type, Graph graph, Node sourceNode,
      Node destinationNode) async {
    Provider serviceProvider = Provider.instance;


    if (graph.nodes.length == 1 && type == "Add edge") {
      Node node1 = Node.Id("Root Node");
      graph.addNode(node1);

      return graph;
    } else if (type == "Add edge" && graph.nodes.length > 1) {
      String? key1;
      String? value;
      String nodeId = sourceNode.key?.value;
      List<String> lines = nodeId.split('\n');
      Map<String, String> typeMap = {};
      for (var line in lines) {
        List<String> parts = line.split(':');
        if (parts.length == 2) {
          key1 = parts[0].trim();
          value = parts[1].trim();
          typeMap[key1] = value;
        }
      }
      print(value! + 'c');
      String? key2;
      String? value2;
      String nodeId2 = destinationNode.key?.value;
      List<String> lines2 = nodeId2.split('\n');
      Map<String, String> typeMap2 = {};
      for (var line2 in lines2) {
        List<String> parts2 = line2.split(':');
        if (parts2.length == 2) {
          key2 = parts2[0].trim();
          value2 = parts2[1].trim();
          typeMap2[key2] = value2;
        }
      }

      YamlMap? source = await serviceProvider.GetDescriptionByTypeforManagement(
          value!);
      YamlMap? destination = await serviceProvider
          .GetDescriptionByTypeforManagement(value2!);


      if (source?["requirements"] != null) {
        var sourceReq = source?["requirements"];

        for (var req in sourceReq) {
          var sreq = req.values.first;
          print(sreq["capability"]);
          print("2222222222222222222222222222222");
          if (sreq["capability"] != null) {
            //print(await serviceProvider.GetCapabilitiesByType(destinationNode.key?.value));

            String? capacity_fatality = await serviceProvider
                .GetCapabilitiesByType(value2!);
            if(value2 =="katena.nodes.contractReference")
              {
                capacity_fatality=null;
              }
            //print(value2+"\n"+capacity_fatality!);
            if(capacity_fatality!=null) {
              if (sreq["capability"] == capacity_fatality ||
                  sreq["node"] == value2) {
                graph.addEdge(sourceNode, destinationNode);
              } else {
                print("es");
                if (sreq["node"] != null) {
                  YamlMap? inheritedRequirements = await serviceProvider
                      .GetDescriptionByTypeforManagement(sreq["node"]);
                  // print(inheritedRequirements);

                  if (inheritedRequirements != null) {
                    var inReqs = inheritedRequirements["requirements"];

                    for (var inreq in inReqs) {
                      var inreqsource = inreq.values.first;
                      print(inreqsource);
                      String? capacity_fatality2 = await serviceProvider
                          .GetCapabilitiesByType(value2);

                      if (inreqsource["capability"] ==
                          capacity_fatality2 || inreqsource["node"] == value2) {
                        graph.addEdge(sourceNode, destinationNode);
                      }
                      else {
                        print("the two nodes are not compatible");
                      }
                    }
                  }
                }
              }
            }else
              {
                print("es");
                print("hhhhhhhhhh");
                print(value);

                if(value2=="katena.nodes.contractReference")
                  {
                    value2="katena.nodes.contract";
                  }
                if (sreq["node"] != null) {


                      if ( sreq["node"] == value2) {
                        graph.addEdge(sourceNode, destinationNode);
                      }
                      else {
                        print("the two nodes are not compatible");
                      }
                    }


              }
          } else {
            print("if requirement is null the node is not connectable");
          }
        }
      } else {
        print("up to now do nothing");
      }
     // print(source);

      var some_der_req= await serviceProvider.getInheritedRequirements(value,source!);
      //final yamlList = loadYaml(some_der_req as String) as YamlList;
     print(some_der_req);
    print("mnnedodenonfeoeonfeofneofnnofenfoeon");

      for(var lreq in some_der_req)
       {
       print(lreq);
      print("KKKKKKKKKKKKKKKKKKKKKK");
      var sourceReq2 = lreq["requirements"];

      for(var i_req in sourceReq2)
      {

        var inreqsource2 = i_req.values.first;
        print(inreqsource2);
        String? capacity_fatality3= await serviceProvider
            .GetCapabilitiesByType(value2!);

        if (inreqsource2["capability"] ==
            capacity_fatality3|| inreqsource2["node"] == value2) {
          graph.addEdge(sourceNode, destinationNode);
        }
        else {
          print("the two nodes are not compatible");
        }
      }


      }


      return graph;
    }
    return null;
  }


  Future<Graph?> TopologyGraphFromYamlGivenName(String nametop) async {
    try{
      var yamlFile = await ServiceProvider.loadYamlFromAssets(
          "katena-main/benchmark/$nametop");

      var nodeProperties = yamlFile?['topology_template']['node_templates'];

      if (nodeProperties == null) {
        print("No node templates found in YAML.");
        return null;
      } else {
        print(yamlFile);
        print("///////////////////////");
      }
      Graph graph = Graph()
        ..isTree = false;
      List<String> imports = [];

      // Load imports
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

      for(var key in  nodeProperties.keys)
      {
        if(!(imports.contains(nodeProperties[key]["type"])))
        {
          YamlMap? yamlMap = await loadYamlFromAssets(
              "katena-main/nodes/"+nodeProperties[key]["type"]);
          var nodeTypes = yamlMap?['node_types'];
          if (nodeTypes != null) {
            imports.addAll(nodeTypes.keys.cast<String>());
          }
        }else{
          print("requirement already present or nodes not defined");
        }
      }

      // Load the AssetManifest.json which contains a list of all assets
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      for(var key in  nodeProperties.keys)
      {
        if(!imports.contains(nodeProperties[key]["type"]))
        {
          final yamlFiles = manifestMap.keys
              .where((String key) =>
          key.startsWith('assets/katena-main/nodes/') && key.endsWith('.yaml'))
              .toList();

          for (var file in yamlFiles) {
            // Read the YAML file
            final yamlContent = await rootBundle.loadString(file);
            final yamlMap = loadYaml(yamlContent) as YamlMap;
            var nodeTypes = yamlMap["node_types"];
            if (nodeTypes != null) {
              for (var entry in nodeTypes.entries) {
                if (entry.key == nodeProperties[key]["type"]) {
                  imports.addAll(nodeTypes.keys.cast<String>());
                  break;
                }
              }
            }
          }
        }else{
          print("requirement already present or nodes not defined");
        }
      }


      // Create nodes and add to graph
      Map<String, Node> nodes = {};
      for (var key in nodeProperties.keys) {
        if (nodeProperties[key]["type"]
            .toString()
            .isNotEmpty) {
          if (imports.contains(nodeProperties[key]["type"])) {
            Node node = Node.Id("name:$key\ntype:${nodeProperties[key]["type"]}");
            graph.addNode(node);
            nodes[key] = node;
            // print("Node added: ${node.key?.value}"); // Debug print
          } else {
            print(
                "Node type not in imports: ${nodeProperties[key]["type"]}"); // Debug print
          }
        } else {
          print("type is empty");
        }
      }
      // Add edges based on requirements
      for (var key in nodeProperties.keys) {
        //print(key+'me');
        if (nodeProperties[key]["requirements"] != null) {
          var requirements = nodeProperties[key]["requirements"];

          Node? node = nodes[key];
          if (node != null) {
            for (var requirement in requirements) {
              var targetNodeName = requirement.values.first;
              //print("Node $key requires: $targetNodeName"); // Debug print

              Node? targetNode;
              if (targetNodeName is YamlMap) {
                print(
                    "Target node name (YamlMap): ${targetNodeName.values.first}");
                targetNode = nodes[targetNodeName.values.first.toString()];
              } else {
                print("Target node name: $targetNodeName");
                targetNode = nodes[targetNodeName];
              }

              if (targetNode != null) {
                if(node!=targetNode) {
                  graph.addEdge(node, targetNode);
                }else{
                  print("the node is connected to itself");
                }
              } else {
                print("Target node not found: $targetNodeName"); // Debug print
              }
            }
          }
        } else {
          print("exit");
        }
      }


      print("Graph nodes: ${graph.nodes.length}, ${graph.edges
          .length} edges created."); // Debug print
      return graph;
    }catch(e){
      print(e);
    }

  }
  Future<Graph?> TopologyGraphFromYamlGivenName2(String nametop) async {
    try{
      var yamlFile = await ServiceProvider.loadYamlFromAssets(
          "katena-main/examples/$nametop");

      var nodeProperties = yamlFile?['topology_template']['node_templates'];

      if (nodeProperties == null) {
        print("No node templates found in YAML.");
        return null;
      } else {
        print(yamlFile);
        print("///////////////////////");
      }
      Graph graph = Graph()
        ..isTree = false;
      List<String> imports = [];

      // Load imports
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

      // Load the AssetManifest.json which contains a list of all assets
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      for(var key in  nodeProperties.keys)
      {
        if(!imports.contains(nodeProperties[key]["type"]))
        {
          final yamlFiles = manifestMap.keys
              .where((String key) =>
          key.startsWith('assets/katena-main/nodes/') && key.endsWith('.yaml'))
              .toList();

          for (var file in yamlFiles) {
            // Read the YAML file
            final yamlContent = await rootBundle.loadString(file);
            final yamlMap = loadYaml(yamlContent) as YamlMap;
            var nodeTypes = yamlMap["node_types"];
            if (nodeTypes != null) {
              for (var entry in nodeTypes.entries) {
                if (entry.key == nodeProperties[key]["type"]) {
                  imports.addAll(nodeTypes.keys.cast<String>());
                  break;
                }
              }
            }
          }
        }else{
          print("requirement already present or nodes not defined");
        }
      }


      // Create nodes and add to graph
      Map<String, Node> nodes = {};
      for (var key in nodeProperties.keys) {
        if (nodeProperties[key]["type"]
            .toString()
            .isNotEmpty) {
          if (imports.contains(nodeProperties[key]["type"])) {
            Node node = Node.Id("name:$key\ntype:${nodeProperties[key]["type"]}");
            graph.addNode(node);
            nodes[key] = node;
            // print("Node added: ${node.key?.value}"); // Debug print
          } else {
            print(
                "Node type not in imports: ${nodeProperties[key]["type"]}"); // Debug print
          }
        } else {
          print("type is empty");
        }
      }
      // Add edges based on requirements
      for (var key in nodeProperties.keys) {
        //print(key+'me');
        if (nodeProperties[key]["requirements"] != null) {
          var requirements = nodeProperties[key]["requirements"];

          Node? node = nodes[key];
          if (node != null) {
            for (var requirement in requirements) {
              var targetNodeName = requirement.values.first;
              //print("Node $key requires: $targetNodeName"); // Debug print

              Node? targetNode;
              if (targetNodeName is YamlMap) {
                print(
                    "Target node name (YamlMap): ${targetNodeName.values.first}");
                targetNode = nodes[targetNodeName.values.first.toString()];
              } else {
                print("Target node name: $targetNodeName");
                targetNode = nodes[targetNodeName];
              }

              if (targetNode != null) {
                if(node!=targetNode) {
                  graph.addEdge(node, targetNode);
                }else{
                  print("the node is connected to itself");
                }

              } else {
                print("Target node not found: $targetNodeName"); // Debug print
              }
            }
          }
        } else {
          print("exit");
        }
      }


      print("Graph nodes: ${graph.nodes.length}, ${graph.edges
          .length} edges created."); // Debug print
      return graph;
    }catch(e){
      print(e);
    }

  }

  Future<List<String>?> getInheritedType(String derivationType, YamlMap? yamlContent) async {

    if (yamlContent!.containsKey('node_types')) {
      var nodeTypes = yamlContent['node_types'];
      if (nodeTypes.containsKey(derivationType)) {
        var nodeType = nodeTypes[derivationType];
        if (nodeType.containsKey('derived_from')) {
          return nodeType['derived_from'];
        }
      }
    }
    return null;
  }
  Future<List<YamlMap>> getInheritedRequirements(String inType, YamlMap yamlContent) async {
    Provider serviceProvider = Provider.instance;
    List<YamlMap> yamlMaps = [];

    // Retrieve the type this is derived from
    var source = await serviceProvider.GetDescriptionByType(yamlContent["derived_from"]);

    // Check if the source is valid
    if (source != null) {
      // Handle the case where source is a YamlMap
      if (source is YamlMap) {
        // Add the current source map to the list
        yamlMaps.add(source);

        // Check if the derived_from type is not Tosca.Root
        if (source["derived_from"] != "tosca.nodes.Root") {
          // Recursively get inherited requirements from parent types
          var inheritedMaps = await getInheritedRequirements(source["derived_from"], source);

          // Combine the results from the recursive call
          yamlMaps.addAll(inheritedMaps);
        }
      }
    } else {
      print("No source found for derived_from type: ${yamlContent["derived_from"]}");
    }

    return yamlMaps;
  }


  Future<Graph?> TopologyRemoveEdges( Graph graph, Node sourceNode,
      Node destinationNode) async {
    graph.removeEdgeFromPredecessor(sourceNode, destinationNode);
    return graph;
  }
  Future<Graph?> TopologyRemoveNode( Graph graph, Node sourceNode) async {
    if(graph.getInEdges(sourceNode).isEmpty && graph.getOutEdges(sourceNode).isEmpty) {
      graph.removeNode(sourceNode);
    }
    return graph;
  }



  Future<List<String>?> TopologyExamples() async {
    try {
      List<String> TypesToPrint = [];
      // Load the AssetManifest.json which contains a list of all assets
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      // Filter the list to get only the YAML files in the katena-main/nodes directory
      final yamlFiles = manifestMap.keys
          .where((String key) =>
      key.startsWith('assets/katena-main/examples/') && key.endsWith('.yaml'))
          .toList();

      for (var file in yamlFiles) {
        String fileName = path.basename(file);
        print("File name: $fileName");
        TypesToPrint.add(fileName);
      }
      return TypesToPrint;
    } catch (e) {
      print('Error loading Topologies Examples: $e');

    }


    return null;
  }
  Future<bool> checkPropertiesCompatibility(String nodeType, Map<String, dynamic> providedProperties, BuildContext context) async {
    try {
      // Load the AssetManifest.json which contains a list of all assets
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);
      YamlMap? yamlMapToBeFound;
      YamlMap? nodeTypeToBeFound;
      List<String> warnings = []; // Store warnings to show in dialog

      // Filter the list to get only the YAML files in the katena-main/nodes directory
      final yamlFiles = manifestMap.keys
          .where((String key) =>
      key.startsWith('assets/katena-main/nodes/') && key.endsWith('.yaml'))
          .toList();

      // Iterate over each YAML file to find the node type
      for (var file in yamlFiles) {
        // Read the YAML file
        final yamlContent = await rootBundle.loadString(file);
        final yamlMap = loadYaml(yamlContent) as YamlMap;

        var nodeTypes = yamlMap["node_types"];
        if (nodeTypes != null) {
          for (var entry in nodeTypes.entries) {
            if (entry.key == nodeType) {
              // NodeType found, load the full YAML for further processing
              yamlMapToBeFound = loadYaml(yamlContent) as YamlMap;
              nodeTypeToBeFound = yamlMapToBeFound["node_types"];
              break;
            }
          }
        }
        if (yamlMapToBeFound != null) break; // Exit if we found the node type
      }

      // If node type not found, return false
      if (nodeTypeToBeFound == null) {
        print("NodeType $nodeType not found in the directory.");
        return false;
      }

      // Now get the properties, including inherited ones
      var inheritedProperties = await _getInheritedProperties(nodeType, nodeTypeToBeFound, yamlFiles);

      // Now check compatibility with provided properties
      bool isCompatible = _checkCompatibility(YamlMap.wrap(inheritedProperties), providedProperties, warnings);

      if (!isCompatible) {
        // If there are warnings, show a dialog to the user
        if (warnings.isNotEmpty) {
          await _showWarningsDialog(context, warnings);
        }
      } else {
        print('The provided properties are compatible with the node type: $nodeType');
      }

      return isCompatible;
    } catch (e) {
      print('Error loading or parsing YAML: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> _getInheritedProperties(String nodeType, YamlMap nodeTypeToBeFound, List<String> yamlFiles) async {
    // Get current node's properties
    Map<String, dynamic> currentNodeMap = Map<String, dynamic>.from(nodeTypeToBeFound[nodeType] ?? {});
    Map<String, dynamic> currentProperties = Map<String, dynamic>.from(currentNodeMap['properties'] ?? {});

    // Check if this node type derives from another node type
    if (currentNodeMap.containsKey('derived_from')) {
      String parentNodeType = currentNodeMap['derived_from'];

      // Find the parent node in the YAML files
      for (var file in yamlFiles) {
        final yamlContent = await rootBundle.loadString(file);
        final yamlMap = loadYaml(yamlContent) as YamlMap;
        var nodeTypes = yamlMap["node_types"];
        if (nodeTypes != null && nodeTypes.containsKey(parentNodeType)) {
          // Recursively get the properties of the parent node
          Map<String, dynamic> parentProperties = await _getInheritedProperties(parentNodeType, nodeTypes, yamlFiles);

          // Merge parent properties with current node properties
          currentProperties = {...parentProperties, ...currentProperties}; // Child node overrides parent
          break;
        }
      }
    }

    return currentProperties;
  }

  bool _checkCompatibility(YamlMap definedProperties, Map<String, dynamic> providedProperties, List<String> warnings) {
    // Iterate through the defined properties from the YAML
    for (var entry in definedProperties.entries) {
      String propertyName = entry.key;
      var propertyDefinition = entry.value;

      // Check if the 'required' field exists and is set to true in the YAML
      bool isRequired = propertyDefinition['required'] == true;

      // If the property is required but missing in the provided properties, issue a warning
      if (isRequired && !providedProperties.containsKey(propertyName)) {
        warnings.add('Missing required property: $propertyName');
      }

      // If the property is not required and not provided, no warning is needed
      if (!isRequired && !providedProperties.containsKey(propertyName)) {
        // Property is not required and not provided, so we skip further checks
        continue;
      }

      // Additional compatibility checks can be added here (e.g., type matching)
      if (providedProperties.containsKey(propertyName)) {
        var providedValue = providedProperties[propertyName];
        print(providedValue);
        // Assuming the type is specified in the YAML property definition
        var expectedType = propertyDefinition['type'];
        print(expectedType);
        // Check if the provided value matches the expected base type (e.g., string, int)
        if (expectedType != null && !_isBaseTypeMatching(expectedType, providedValue["type"])) {
          warnings.add('Property $propertyName is of incorrect type. Expected base type $expectedType, but got ${providedValue.runtimeType}.');
        }
      }
    }

    // Allow custom properties by not returning false, just issuing warnings
    return warnings.isEmpty;
  }

  bool _isBaseTypeMatching(String expectedType, dynamic providedValue) {
    // Check if the provided value matches the expected base type (ignoring specific custom types)
    switch (expectedType.toLowerCase()) {
      case 'string':
        return providedValue is String;
      case 'int':
        return providedValue is int;
      case 'float':
        return providedValue is double;
    // Add other base types as necessary (e.g., boolean, list, etc.)
      default:
        return true; // Assume true if no strict base type is enforced
    }
  }

// Show a dialog with the warnings
  Future<void> _showWarningsDialog(BuildContext context, List<String> warnings) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must acknowledge the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Warning: Property Compatibility'),
          content: SingleChildScrollView(
            child: ListBody(
              children: warnings.map((warning) => Text(warning)).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


}