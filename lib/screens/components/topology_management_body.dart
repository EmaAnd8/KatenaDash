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

  Widget fetchNodeIcon(String nodeId) {
    if (nodeId.contains("network")) {
      return Image.asset('assets/icons/worldwide_10969702.png', width: 24, height: 24);
    } else if (nodeId.contains("wallet")) {
      return Image.asset('assets/icons/wallet_4121117.png', width: 24, height: 24);
    } else if (nodeId.contains('contract')) {
      return Image.asset('assets/icons/smart_14210186.png', width: 24, height: 24);
    }
    return Image.asset('assets/icons/icons8-topology-53.png', width: 24, height: 24);
  }

  void _showSnackBar(String message) {
    final snackBar = SnackBar(
      backgroundColor: Colors.red,
      content: Text(message,
          style: const TextStyle(color: CupertinoColors.white)),
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
          'onTap': () {
            setState(() {
              graph = ServiceProvider.TopologyCreatorNodes(key, graph, rootNode) as Graph;
            });
          },
        });
      }

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

    setState(() async {
      if(destinationNode.key?.value!=sourceNode.key?.value) {
        graph = await ServiceProvider.TopologyCreatorEdges("Add edge", graph, sourceNode, destinationNode) as Graph;
      } else
        {

            _showSnackBar("Cannot connect a node to itself");
        }
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

  @override
  Widget build(BuildContext context) {
    String selectedOption = 'Option 1';
    Size size = MediaQuery.of(context).size; // Get screen dimensions
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
                    ServiceProvider.saveFile(topologyYaml);
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
              SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                      alignment: Alignment.topLeft,
                    ),
                    SizedBox(
                      height: size.height,
                      width: size.width - 250, // Adjust the width based on drawer
                      child: InteractiveViewer(
                        constrained: false,
                        boundaryMargin: const EdgeInsets.all(100),
                        minScale: 0.01,
                        maxScale: 5.6,
                        child: GraphView(
                          graph: graph,
                          algorithm: BuchheimWalkerAlgorithm(builder, TreeEdgeRenderer(builder)),
                          builder: (Node node) {
                            var nodeId = node.key?.value as String?;
                            return nodeId != null ? nodeWidget(nodeId) : Container();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                left: _isDrawerOpen ? 0 : -250, // Width of the drawer
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
                              Divider(),
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

  Widget nodeWidget(String nodeId) {
    String description = nodeDescriptions[nodeId] ?? 'No description available';
    return Tooltip(
      message: description,
      child: GestureDetector(
        onTap: () {
          print('Node $nodeId tapped');
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            fetchNodeIcon(nodeId),
            const SizedBox(width: 8),
            Text(nodeId),
          ],
        ),
      ),
    );
  }
}
