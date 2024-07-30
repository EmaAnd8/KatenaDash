import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:katena_dashboard/screens/services/services_provider.dart';
import 'package:katena_dashboard/screens/dashboard/dashboard_screen.dart';
import 'package:katena_dashboard/screens/deploy/deploy_screen.dart';
import 'package:katena_dashboard/screens/topology/topologymanangement/topology_management_screen.dart';
import 'package:yaml/yaml.dart';

Provider serviceProvider = Provider.instance;

class TopologyViewBody extends StatefulWidget {
  const TopologyViewBody({super.key});

  @override
  _TopologyViewState createState() => _TopologyViewState();
}

class _TopologyViewState extends State<TopologyViewBody> {
  final _formKey = GlobalKey<FormState>();
  String selectedOption = 'Option 1';
  Widget simpleTopology = Container(); // Initialize here

  Future<void> _loadAndConvertYaml() async {
    setState(() {
      simpleTopology = Container(); // Reset before loading
    });
    // Load and rebuild the widget
    setState(() {
      simpleTopology = SimpleGraph(key: UniqueKey());
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size; // Get screen size
    return Scaffold(
      appBar: AppBar(
        title: const Text('Topology Viewer'),
        backgroundColor: CupertinoColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
              selectedOption = "";
              return HomeScreen();
            }));
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
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return DeployScreen();
                    }));
                  },
                ),
                PopupMenuItem<String>(
                  value: '2',
                  child: const Text('Edit your Topology'),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return TopologyManagementScreen();
                    }));
                  },
                ),
                PopupMenuItem<String>(
                  value: '3',
                  child: const Text('Insert a Topology'),
                  onTap: () async {
                    await _loadAndConvertYaml();
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
        width: size.width*3,
        height: size.height*3,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              children: <Widget>[
                Container(
                  height: size.height,
                  width: size.width,
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Center(
                        child: simpleTopology,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SimpleGraph extends StatefulWidget {
  const SimpleGraph({super.key});

  @override
  State<SimpleGraph> createState() => _SimpleGraphState();
}

class _SimpleGraphState extends State<SimpleGraph> {
  Graph? graph;
  String hoveredNodeId = ''; // Track hovered node
  bool showSidebar = false; // Control sidebar visibility
  final TransformationController _transformationController = TransformationController();
  String nodeDescription = "";

  @override
  void initState() {
    super.initState();
    _getGraph();
  }

  Future<void> _getGraph() async {
    try {
      Graph? fetchedGraph = Graph()..isTree = false;
      fetchedGraph = await serviceProvider.TopologyGraphFromYaml();
      setState(() {
        graph = fetchedGraph;
      });
    } catch (e) {
      print('Error fetching graph: $e');
    }
  }

  String _getIconPathForNode(String nodeId) {
    if (nodeId.contains("network")) {
      return 'assets/icons/worldwide_10969702.png';
    } else if (nodeId.contains("wallet")) {
      return 'assets/icons/wallet_4121117.png';
    } else if (nodeId.contains('contract')) {
      return 'assets/icons/smart_14210186.png';
    }
    return 'assets/icons/icons8-topology-53.png';
  }

  Future<void> _fetchNodeDescription(String nodeId) async {
    try {
      List<String> lines = nodeId.split('\n');
      Map<String, String> typeMap = {};
      for (var line in lines) {
        List<String> parts = line.split(':');
        if (parts.length == 2) {
          String key = parts[0].trim();
          String value = parts[1].trim();
          typeMap[key] = value;
        }
      }

      // Check if typeMap contains the "type" key before accessing it
      if (typeMap.containsKey("type")) {
        var yamlDescription = await serviceProvider.GetDescriptionByType(typeMap["type"]!.toString());

        YamlMap? descriptionMap = yamlDescription;
        String description = "";
        if (descriptionMap != null) {
          description = _formatYamlMap(descriptionMap, 0);
        }
        setState(() {
          nodeDescription = description;
        });
      } else {
        print('Type key not found in nodeId: $nodeId');
      }
    } catch (e) {
      print('Error fetching node description: $e');
    }
  }


  String _formatYamlMap(YamlMap map, int indentLevel) {
    final buffer = StringBuffer();
    print(map);
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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    SugiyamaConfiguration builder = SugiyamaConfiguration()
      ..nodeSeparation = (60)
      ..levelSeparation = (100)
      ..orientation = (BuchheimWalkerConfiguration.ORIENTATION_LEFT_RIGHT)
      ..levelSeparation = (150)
      ..nodeSeparation = (100);

    return Scaffold(
      body: graph == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          InteractiveViewer(
            transformationController: _transformationController,
            boundaryMargin: const EdgeInsets.all(200),
            constrained: false,
            minScale: 0.01,
            maxScale: 5.6,
            child: Center(
              child: GraphView(
                algorithm: SugiyamaAlgorithm(builder),
                graph: graph!,
                paint: Paint()
                  ..strokeWidth = 2
                  ..style = PaintingStyle.stroke,
                builder: (Node node) {
                  String nodeId = node.key?.value ?? '';
                  return MouseRegion(
                    onEnter: (_) {
                      setState(() {
                        hoveredNodeId = nodeId;
                        showSidebar = true;
                      });
                      _fetchNodeDescription(nodeId);
                    },
                    onExit: (_) => setState(() {
                      hoveredNodeId = '';
                      showSidebar = false;
                    }),
                    child: SizedBox(
                      width: 90,
                      height: 90,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Image.asset(
                              _getIconPathForNode(nodeId),
                              width: 20,
                              height: 20,
                            ),
                            Text(
                              nodeId,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          if (showSidebar)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 200,
                height: size.height,
                color: Colors.white,
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: _buildSidebarContent(hoveredNodeId),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSidebarContent(String nodeId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Node Details: $nodeId',
          style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        const Divider(),
        Text(
          'Description: $nodeDescription',
          style: const TextStyle(color: Colors.blue),
        ),
      ],
    );
  }
}
