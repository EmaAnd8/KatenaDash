import 'dart:io';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:katena_dashboard/screens/components/graphiccomponents/simple_graph.dart';
import 'package:katena_dashboard/screens/dashboard/dashboard_screen.dart';
import 'package:katena_dashboard/screens/deploy/deploy_screen.dart';
import 'package:katena_dashboard/screens/services/services_provider.dart';
import 'package:katena_dashboard/screens/topology/topologyview/topology_view_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yaml/yaml.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

Provider ServiceProvider = Provider.instance;
String topologyYaml = "";
List<Map<String, dynamic>> sidebarItems = [];
Graph graph = Graph()..isTree = false;
String nodeDescription = "";
String name = '';
final BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();
Node? rootNode;
Map<String, String> nodeDescriptions = {};
Map<String, Map<String, dynamic>> nodeProperties = {}; // Store properties per node

Map<String, Map<String, dynamic>> yamlMap = {}; //store inputs

List<Map<String, String>> messages = [
  {
    "role": "system",
    "content":
    "Hi Chat, I am going to create a TOSCA topology assessment tool. Please provide a score from 0 to 100 to each parameter for each set of TOSCA topology I give to you. Here are the parameters: - Topology fault tolerance overall, - Nodes fault tolerance, - Percentage of successful deploy."
  }
];
final String apiKey = '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';

class TopologyManagementBody extends StatefulWidget {
  const TopologyManagementBody({super.key});

  @override
  _TopologyManagementState createState() => _TopologyManagementState();
}

class _TopologyManagementState extends State<TopologyManagementBody> {
  bool _isDrawerOpen = false;


  @override
  void initState() {
    super.initState();
    _initializeGraph();
    _loadNodeDescriptions();
  }

  void _initializeGraph() {
    graph = Graph()..isTree = false;
    rootNode = Node.Id('Root Node');
    graph.addNode(rootNode!);
  }

  Future<void> _loadNodeDescriptions() async {
    try {
      List<String> keyTypes = await ServiceProvider.NodesDefinition() as List<String>;
      for (var type in keyTypes) {
        var yamlDescription = await ServiceProvider.GetDescriptionByType(type);
        YamlMap? descriptionMap = yamlDescription;
        if (descriptionMap != null) {
          nodeDescriptions[type] = _formatYamlMap(descriptionMap, 0);
        }
      }
      setState(() {});
    } catch (e) {
      print('Error loading node descriptions: $e');
    }
  }

  String _formatYamlMap(YamlMap map, int indentLevel) {
    final buffer = StringBuffer();
    map.forEach((key, value) {
      buffer.write('${' ' * indentLevel * 2}$key:');
      if (value is YamlMap) {
        buffer.write('\n');
        buffer.write(_formatYamlMap(value, indentLevel + 1));
      } else {
        buffer.write(' $value\n');
      }
    });
    return buffer.toString();
  }

  Widget fetchNodeIcon(String type) {
    if (type.contains("network")) {
      return Image.asset('assets/icons/worldwide_10969702.png', width: 24, height: 24);
    } else if (type.contains("wallet")) {
      return Image.asset('assets/icons/wallet_4121117.png', width: 24, height: 24);
    } else if (type.contains('contract')) {
      return Image.asset('assets/icons/smart_14210186.png', width: 24, height: 24);
    } else if (type.contains("diamond")) {
      return Image.asset('assets/icons/diamond.png', width: 24, height: 24);
    }
    return Image.asset('assets/icons/icons8-topology-53.png', width: 24, height: 24);
  }

  void _showSnackBar(String message) {
    final snackBar = SnackBar(
      backgroundColor: Colors.red,
      content: Text(message, style: const TextStyle(color: CupertinoColors.white)),
      duration: const Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _loadNodeDefinitions() async {
    setState(() {
      sidebarItems = [];
    });

    try {
      List<String> keyTypes = await ServiceProvider.NodesDefinition() as List<String>;

      for (var key in keyTypes) {
        sidebarItems.add({
          'title': key,
          'onTap': () async {
            String? nodeName = await _showNameInputDialog(context);
            if (nodeName != null && nodeName.isNotEmpty) {
              setState(() {
                graph = ServiceProvider.TopologyCreatorNodes(nodeName, key, graph, rootNode) as Graph;
              });
            }
          },
        });
      }

      String key_ens = "Add ens topology";
      sidebarItems.add({
        'title': key_ens,
        'onTap': () async {
          final generated_graph = await ServiceProvider.TopologyGraphFromYamlGivenName("ens.yaml") as Graph;
          setState(() {
            graph = generated_graph;
          });
        },
      });

      String key_dxdy = "Add dxdy topology";
      sidebarItems.add({
        'title': key_dxdy,
        'onTap': () async {
          final generated_graph = await ServiceProvider.TopologyGraphFromYamlGivenName("dydx.yaml") as Graph;
          setState(() {
            graph = generated_graph;
          });
        },
      });

      String key_darkforest = "Add dark forest topology";
      sidebarItems.add({
        'title': key_darkforest,
        'onTap': () async {
          final generated_graph = await ServiceProvider.TopologyGraphFromYamlGivenName("dark-forest.yaml") as Graph;
          setState(() {
            graph = generated_graph;
          });
        },
      });

      String key1 = "Add edge";
      sidebarItems.add({
        'title': key1,
        'onTap': () {
          _promptForEdgeCreation();
        },
      });

      String keyx = "Remove edge";
      sidebarItems.add({
        'title': keyx,
        'onTap': () {
          _promptForEdgeRemoval();
        },
      });

      String key_node = "Remove Node";
      sidebarItems.add({
        'title': key_node,
        'onTap': () {
          _promptForNodeRemoval();
        },
      });

      String key_properties = "Add properties";
      sidebarItems.add({
        'title': key_properties,
        'onTap': () {
          _addProperties();
        },
      });
/*
      String key_inputs = "Add Inputs";
      sidebarItems.add({
        'title': key_inputs,
        'onTap': () {
          _addInputs();
        },
      });

 */

      setState(() {});
    } catch (e) {
      print('Error loading node definitions: $e');
    }
  }
  Map<String, dynamic> inputs = {};  // Global inputs map

  Future<void> _addInputs() async {
    // Store the inputs
    Map<String, dynamic>? result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        String key = '';
        String valueType = '';  // This will store the type (like string, boolean, etc.)
        String requiredValue = ''; // This will store whether the input is required

        return AlertDialog(
          title: Text('Add Inputs'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(hintText: "Input Key"),
                onChanged: (text) {
                  key = text;
                },
              ),
              TextField(
                decoration: InputDecoration(hintText: "Input Type (e.g., string, integer)"),
                onChanged: (text) {
                  valueType = text;
                },
              ),
              TextField(
                decoration: InputDecoration(hintText: "Is Required? (true/false)"),
                onChanged: (text) {
                  requiredValue = text;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop({
                  'key': key,
                  'type': valueType,
                  'required': requiredValue.toLowerCase() == 'true'
                });
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );

    // If valid inputs were provided
    if (result != null && result['key'] != '' && result['type'] != '') {
      setState(() {
        // Add the inputs to the global inputs map
        inputs[result['key']] = {
          'type': result['type'],
          'required': result['required']
        };
      });

      _saveInputsToYaml();
    }
  }

  void _saveInputsToYaml() {
    final buffer = StringBuffer();

    buffer.write('inputs:\n');
    inputs.forEach((key, value) {
      buffer.write('  $key:\n');
      buffer.write('    type: ${value['type']}\n');
      buffer.write('    required: ${value['required']}\n');
    });

    print(buffer.toString()); // Print for debugging, or replace with actual save logic
  }


  Future<void> _exportResponseAsTextFile(String content) async {
    if (kIsWeb) {
      // Web platform: Create a Blob and trigger a download using universal_html
      final bytes = utf8.encode(content);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", "response.txt")
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      // Mobile/desktop: Write the response to a .txt file
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/response.txt';
      final file = File(filePath);

      await file.writeAsString(content);
      print('Response saved at: $filePath');
    }
  }


  Future<String> sendMessageWithFilesOption(String userMessage) async {
    // Step 1: Pick multiple files (optional)
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);

    List<String> fileContents = [];

    if (result != null && result.files.isNotEmpty) {
      for (var file in result.files) {
        if (kIsWeb) {
          // Web platform, access file content via bytes
          Uint8List? fileBytes = file.bytes;
          if (fileBytes != null) {
            String fileContent = utf8.decode(fileBytes);
            fileContents.add(fileContent);
          }
        } else {
          // Mobile/desktop platform, access file content via path
          String? filePath = file.path;
          if (filePath != null) {
            File file = File(filePath);
            String fileContent = await file.readAsString();
            fileContents.add(fileContent);
          }
        }
      }
    }

    // Step 2: Append the user message to the conversation
    messages.add({"role": "user", "content": userMessage});

    // Step 3: Append each file content as part of the message
    for (var i = 0; i < fileContents.length; i++) {
      messages.add({
        "role": "user",
        "content": "File ${i + 1} content:\n${fileContents[i]}"
      });
    }

    // Step 4: Prepare the request body
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');
    Map<String, dynamic> body = {
      "model": "gpt-3.5-turbo",
      "messages": messages
    };

    // Step 5: Set the headers
    final headers = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    };

    try {
      // Step 6: Send the request to OpenAI
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      // Step 7: Handle the response
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = jsonDecode(response.body);
        String assistantReply = responseBody['choices'][0]['message']['content'];

        // Append the assistant's reply to the conversation
        messages.add({"role": "assistant", "content": assistantReply});

        return assistantReply;
      } else {
        throw Exception('Failed to connect to OpenAI: ${response.statusCode}');
      }
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<void> _promptForEdgeCreation() async {
    if (graph.nodes.isEmpty) {
      _showSnackBar("Cannot add an edge because the graph has no nodes.");
      return;
    }

    Node? sourceNode = await _selectNode("Select source node");
    if (sourceNode == null) return;

    Node? destinationNode = await _selectNode("Select destination node");
    if (destinationNode == null) return;

    setState(() async {
      graph = await ServiceProvider.TopologyCreatorEdges("Add edge", graph, sourceNode, destinationNode) as Graph;
    });
  }

  Future<void> _promptForNodeRemoval() async {
    if (graph.nodes.isEmpty) {
      _showSnackBar("Cannot remove a Node because the graph has no nodes.");
      return;
    }
    if (graph.nodes.length <= 1) {
      _showSnackBar("You cannot have an empty graph");
      return;
    }

    Node? sourceNode = await _selectNode("Select source node");
    if (sourceNode == null) return;

    setState(() async {
      graph = await ServiceProvider.TopologyRemoveNode(graph, sourceNode) as Graph;
    });
  }

  Future<void> _promptForEdgeRemoval() async {
    if (graph.nodes.isEmpty) {
      _showSnackBar("Cannot remove an edge because the graph has no nodes.");
      return;
    }

    Node? sourceNode = await _selectNode("Select source node");
    if (sourceNode == null) return;

    Node? destinationNode = await _selectNode("Select destination node");
    if (destinationNode == null) return;

    setState(() async {
      graph = await ServiceProvider.TopologyRemoveEdges(graph, sourceNode, destinationNode) as Graph;
    });
  }

  Future<Node?> _selectNode(String title) async {
    return showDialog<Node?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Container(
            width: double.minPositive,
            child: ListView(
              shrinkWrap: true,
              children: graph.nodes.map((node) {
                return ListTile(
                  title: Text(node.key!.value),
                  onTap: () {
                    Navigator.of(context).pop(node);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void _resetGraphView() {
    setState(() {
      graph = Graph()..isTree = false;
      rootNode = Node.Id('Root Node');
      graph.addNode(rootNode!);
    });
  }Future<void> _addProperties() async {
    String selectedNodeId = ''; // Store selected node ID
    List<Map<String, dynamic>> properties = []; // Store properties added by the user
    String selectedNodeType = ''; // Store the node type of the selected node

    Map<String, dynamic>? result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        String key = '';
        String description = '';
        String type = '';
        bool required = false;
        String defaultValue = '';
        String typeError = '';  // To store and display errors if type is invalid

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Add Properties'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Dropdown to select node by ID
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'Select Node'),
                      items: graph.nodes.map((node) {
                        // Use the node ID for the dropdown value
                        return DropdownMenuItem<String>(
                          value: node.key?.value ?? '',
                          child: Text(node.key?.value ?? ''),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        selectedNodeId = newValue ?? '';
                        List<String> parts = selectedNodeId.split('\n');
                        String type = parts.length > 1 ? parts[1].replaceFirst('type:', '').trim() : '';
                        selectedNodeType = type; // Extract the node type from the node ID or properties
                        print('Selected Node ID: $selectedNodeId');  // Debugging
                        print('Selected Node Type: $selectedNodeType');  // Debugging
                      },
                    ),
                    Divider(),
                    TextField(
                      decoration: InputDecoration(hintText: "Property Key"),
                      onChanged: (text) {
                        key = text;
                      },
                    ),
                    TextField(
                      decoration: InputDecoration(hintText: "Description"),
                      onChanged: (text) {
                        description = text;
                      },
                    ),
                    TextField(
                      decoration: InputDecoration(hintText: "Type (e.g., string, integer)"),
                      onChanged: (text) {
                        type = text;
                        // Validate the entered type
                        if (!_isValidType(type)) {
                          setState(() {
                            typeError = 'Invalid type. Allowed types: string, int, float, etc.';
                          });
                        } else {
                          setState(() {
                            typeError = '';
                          });
                        }
                      },
                    ),
                    if (typeError.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          typeError,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    Row(
                      children: [
                        Text('Required:'),
                        Checkbox(
                          value: required,
                          onChanged: (bool? value) {
                            setState(() {
                              required = value ?? false;
                            });
                          },
                        ),
                      ],
                    ),
                    TextField(
                      decoration: InputDecoration(hintText: "Default Value (Optional)"),
                      onChanged: (text) {
                        defaultValue = text;
                      },
                    ),
                    TextButton(
                      onPressed: () {
                        if (key.isNotEmpty && type.isNotEmpty && typeError.isEmpty) {
                          // Add the property to the list of properties
                          Map<String, dynamic> property = {
                            'key': key,
                            'description': description,
                            'type': type,
                            'required': required,
                            if (defaultValue.isNotEmpty) 'default': defaultValue,
                          };

                          properties.add(property);
                          print('Added Property: $properties');  // Debugging

                          // Clear the fields for the next property
                          setState(() {
                            key = '';
                            description = '';
                            type = '';
                            required = false;
                            defaultValue = '';
                          });
                        } else {
                          // Show error if key, type is missing or type is invalid
                          print('Key and valid Type are required!');
                        }
                      },
                      child: Text('Add Another Property'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (selectedNodeId.isEmpty) {
                      print('No node selected!');  // Debugging
                    } else if (properties.isEmpty) {
                      print('No properties added!');  // Debugging
                    } else {
                      Navigator.of(context).pop({
                        'properties': properties,
                        'nodeId': selectedNodeId,
                        'nodeType': selectedNodeType
                      });
                    }
                  },
                  child: Text('Save Properties'),
                ),
              ],
            );
          },
        );
      },
    );

    // If the user has entered properties and selected a node, validate the properties before adding them
    if (result != null && result['properties'] != null && result['nodeId'] != '' && result['nodeType'] != '') {
      String nodeId = result['nodeId']; // Use nodeId as the key
      String nodeType = result['nodeType']; // Get the node type
      List<Map<String, dynamic>> properties = result['properties'];

      // Convert properties to a map structure for compatibility check
      Map<String, dynamic> providedProperties = {};
      for (var property in properties) {
        providedProperties[property['key']] = {
          'type': property['type'],
          'required': property['required'],
          if (property.containsKey('default')) 'default': property['default'],
        };
      }

      // List to collect warnings
      List<String> warnings = [];

      // Check compatibility with the node type
      bool isCompatible = await serviceProvider.checkPropertiesCompatibility(nodeType, providedProperties, context);

      if (isCompatible || warnings.isNotEmpty) {
        if (warnings.isNotEmpty) {
          // Show warnings to the user
          await _showWarningsDialog(context, warnings);
        }

        // If compatible or with warnings, update nodeProperties
        print('Selected Node to Update (ID): $nodeId');  // Debugging
        print('Properties to Add: $properties');      // Debugging

        setState(() {
          // Check if the node already exists in nodeProperties, if not, initialize it
          if (!nodeProperties.containsKey(nodeId)) {
            nodeProperties[nodeId] = {}; // Initialize the node properties if not already set
          }

          // Add each property to the node's properties map
          for (var property in properties) {
            nodeProperties[nodeId]![property['key']] = {
              'description': property['description'],
              'type': property['type'],
              'required': property['required'],
              if (property.containsKey('default')) 'default': property['default'], // Add default if present
            };
          }
          print('Updated nodeProperties: $nodeProperties');  // Debugging
        });

        _savePropertiesToYaml(); // Save to YAML
      } else {
        // If not compatible, show an error message or handle accordingly
        print('Properties are not compatible with the node type: $nodeType');
      }
    } else {
      print('No properties added or node not selected');  // Debugging
    }
  }

// Helper function to validate the type entered by the user
  bool _isValidType(String type) {
    final validTypes = ['string', 'int', 'float', 'boolean'];
    return validTypes.contains(type.toLowerCase());
  }

// Dialog to show warnings
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




  void _savePropertiesToYaml() {
    final buffer = StringBuffer();

    // Write properties for each node
    nodeProperties.forEach((nodeName, properties) {
      buffer.write('$nodeName:\n');
      buffer.write('  properties:\n');
      properties.forEach((key, value) {
        buffer.write('    $key:\n');
        value.forEach((propKey, propValue) {
          buffer.write('      $propKey: $propValue\n');
        });
      });
    });

    print(buffer.toString()); // For debugging, replace with the actual saving logic
  }



  Future<String?> _showNameInputDialog(BuildContext context) async {
    String nodeName = '';
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter node name'),
          content: TextField(
            onChanged: (value) {
              nodeName = value;
            },
            decoration: InputDecoration(hintText: "Name"),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(nodeName);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    String selectedOption = 'Option 1';
    SugiyamaConfiguration builder = SugiyamaConfiguration()
      ..nodeSeparation = 2
      ..orientation = SugiyamaConfiguration.ORIENTATION_TOP_BOTTOM;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Topology Editor'),
        backgroundColor: CupertinoColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
              return HomeScreen();
            }), (route) => false);
          },
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String item) {
              setState(() {
                selectedOption = item;
              });
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: '1',
                  child: const Text('Make the Deploy'),
                  onTap: () async {
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
                      return DeployScreen();
                    }), (route) => false);
                  },
                ),
                PopupMenuItem<String>(
                  value: '2',
                  child: const Text('Export your Topology'),
                  onTap: () async {
                    if (graph.hasNodes()) {
                      ServiceProvider.saveFile(graph, nodeProperties,yamlMap);
                    } else {
                      _showSnackBar("You cannot export an empty file");
                    }
                  },
                ),
                PopupMenuItem<String>(
                  value: '3',
                  child: const Text('View your Topology'),
                  onTap: () async {
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
                      return TopologyViewScreen();
                    }), (route) => false);
                  },
                ),
                PopupMenuItem<String>(
                  value: '4',
                  child: const Text('Import your Topology'),
                  onTap: () async {
                    setState(() {
                      graph = Graph()..isTree = false;
                      rootNode = Node.Id('Root Node');
                      graph.addNode(rootNode!);
                    });

                    final newGraph = await ServiceProvider.TopologyGraphFromYaml();

                    setState(() {
                      graph = newGraph!;
                    });
                  },
                ),
                PopupMenuItem<String>(
                  value: '5',
                  child: const Text('Reset your Topology'),
                  onTap: () async {
                    setState(() {
                      graph = Graph()..isTree = false;
                      rootNode = Node.Id('Root Node');
                      graph.addNode(rootNode!);
                      nodeProperties.clear();
                      yamlMap.clear();
                    });
                  },
                ),
                PopupMenuItem<String>(
                  value: '6',
                  child: const Text('Assess your Topology'),
                  onTap: () async {
                    var response;
                    response = await sendMessageWithFilesOption("");
                    _exportResponseAsTextFile(response);
                  },
                ),
                PopupMenuItem<String>(
                  value: '7',
                  child: const Text('Generate your  Topology'),
                  onTap: () async {
                    await serviceProvider.importAndExportYaml();
                  },
                ),
              ];
            },
            icon: const Icon(Icons.menu),
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        width: size.width,
        height: size.height,
        child: MouseRegion(
          onEnter: (_) {
            setState(() {
              _isDrawerOpen = true;
            });
          },
          onExit: (_) {
            setState(() {
              _isDrawerOpen = false;
            });
          },
          child: Stack(
            children: [
              Column(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                    alignment: Alignment.topLeft,
                  ),
                  Expanded(
                    child: InteractiveViewer(
                      constrained: false,
                      boundaryMargin: const EdgeInsets.all(100),
                      minScale: 0.01,
                      maxScale: 5.6,
                      child: GraphView(
                        graph: graph,
                        algorithm: SugiyamaAlgorithm(builder),
                        paint: Paint()
                          ..strokeWidth = 1
                          ..style = PaintingStyle.fill,
                        builder: (Node node) {
                          var nodeData = node.key?.value as String?;
                          return nodeData != null ? nodeWidget(node, nodeData) : Container();
                        },
                      ),
                    ),
                  ),
                ],
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                left: _isDrawerOpen ? 0 : -250,
                top: 0,
                bottom: 0,
                child: MouseRegion(
                  onEnter: (_) {
                    setState(() {
                      _isDrawerOpen = true;
                      _loadNodeDefinitions();
                    });
                  },
                  onExit: (_) {
                    setState(() {
                      _isDrawerOpen = false;
                    });
                  },
                  child: Drawer(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: <Widget>[
                        const DrawerHeader(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                          ),
                          child: Text(
                            'Component Manager',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                            ),
                          ),
                        ),
                        ...sidebarItems.map((item) {
                          return Column(
                            children: [
                              ListTile(
                                title: Text(item['title']),
                                onTap: item['onTap'],
                              ),
                              const Divider(),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget nodeWidget(Node node, String nodeData) {
    List<String> parts = nodeData.split('\n');
    String nodeName = parts.length > 1 ? parts[0].replaceFirst('name:', '') : '';
    String type = parts.length > 1 ? parts[1].replaceFirst('type:', '') : '';

    return Tooltip(
      message: nodeDescriptions[type] ?? 'No description available',
      child: Draggable<Node>(
        data: node,
        feedback: Material(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              fetchNodeIcon(type),
              const SizedBox(height: 4),
              Text('name: $nodeName'),
              Text('type: $type'),
            ],
          ),
        ),
        child: GestureDetector(
          onTap: () async {
            String? newName = await _showNameInputDialog(context);
            if (newName != null && newName.isNotEmpty) {
              setState(() {
                node.key = Key('name:$newName\ntype:$type') as ValueKey?;
                Node updatedNode = Node.Id('name:$newName\ntype:$type');
                graph.addNode(updatedNode);
                graph.removeNode(node);
                if (rootNode != null) {
                  graph.addEdge(rootNode!, updatedNode);
                }
              });
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              fetchNodeIcon(type),
              const SizedBox(height: 4),
              Text('name: $nodeName'),
              Text('type: $type'),
            ],
          ),
        ),
      ),
    );
  }
}
