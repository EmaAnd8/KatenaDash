import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:katena_dashboard/screens/dashboard/dashboard_screen.dart';
import 'package:katena_dashboard/screens/deploy/deploy_screen.dart';
import 'package:katena_dashboard/screens/services/services_provider.dart';
import 'package:katena_dashboard/screens/topology/topologyview/topology_view_screen.dart';
import 'package:yaml/yaml.dart';

Provider ServiceProvider = Provider.instance;
String topologyYaml = "";
List<Map<String, dynamic>> sidebarItems = [];
Graph graph = Graph()..isTree = false;
String nodeDescription = "";
String name = '';
final BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();
Node? rootNode;
Map<String, String> nodeDescriptions = {};

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
    graph = Graph()..isTree = false;  // Reinitialize the graph
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
    }
    return Image.asset('assets/icons/icons8-topology-53.png', width: 24, height: 24);
  }

  void _showSnackBar(String message) {
    final snackBar = SnackBar(
      backgroundColor: Colors.red,
      content: Text(message, style: const TextStyle(color: CupertinoColors.white)),
      duration: const Duration(seconds: 3),
    );

    // Show the snackbar
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
         // _promptForEdgeCreation();
          final generated_graph= await ServiceProvider.TopologyGraphFromYamlGivenName("ens.yaml") as Graph;
          setState(() {
            graph=generated_graph;
          });
        },
      });

      String key_dxdy = "Add dxdy topology";
      sidebarItems.add({
        'title': key_dxdy,
        'onTap': () async {
          // _promptForEdgeCreation();

          final generated_graph=await ServiceProvider.TopologyGraphFromYamlGivenName("dydx.yaml") as Graph;
          setState(() {
            graph=generated_graph;
          });
        },
      });

      String key_darkforest = "Add dark forest topology";
      sidebarItems.add({
        'title': key_darkforest,
        'onTap': () async {
          final generated_graph=await ServiceProvider.TopologyGraphFromYamlGivenName("dark-forest.yaml") as Graph;
          setState(() {
            graph=generated_graph;
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

      setState(() {});
    } catch (e) {
      print('Error loading node definitions: $e');
    }
  }

  Future<void> _promptForEdgeCreation() async {
    if (graph.nodes.length <= 1) {
      _showSnackBar("Cannot add an edge because the graph has only one node.");
      return;
    }

    Node? sourceNode = await _selectNode("Select source node");
    if (sourceNode == null) return;

    Node? destinationNode = await _selectNode("Select destination node");
    if (destinationNode == null) return;

    if (destinationNode.key?.value != sourceNode.key?.value) {
      setState(() async {
        graph = await ServiceProvider.TopologyCreatorEdges("Add edge", graph, sourceNode, destinationNode) as Graph;
      });
    } else {
      _showSnackBar("Cannot connect a node to itself");
    }
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
                      ServiceProvider.saveFile(graph);
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
                    // Reset the graph view immediately
                    setState(() {
                      graph = Graph()..isTree = false;
                      rootNode = Node.Id('Root Node');
                      graph.addNode(rootNode!);
                    });

                    // Fetch the new graph asynchronously
                    final newGraph = await ServiceProvider.TopologyGraphFromYaml();

                    // Update the state with the new graph
                    setState(() {
                      graph = newGraph!;
                    });
                  },
                ),
                PopupMenuItem<String>(
                  value: '5',
                  child: const Text('Reset your Topology'),
                  onTap: () async {
                    // Reset the graph view immediately
                    setState(() {
                      graph = Graph()
                        ..isTree = false;
                      rootNode = Node.Id('Root Node');
                      graph.addNode(rootNode!);
                    });
                  }
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
                // Update the node ID to include the new name
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