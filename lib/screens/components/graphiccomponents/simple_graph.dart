import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:katena_dashboard/screens/services/services_provider.dart';
import 'package:yaml/yaml.dart';

Provider serviceProvider = Provider.instance;

class SimpleGraph extends StatefulWidget {
  const SimpleGraph({super.key});

  @override
  State<SimpleGraph> createState() => _SimpleGraphState();
}

class _SimpleGraphState extends State<SimpleGraph> {
  Graph? graph;
  String hoveredNodeId = ''; // Track hovered node
  bool showSidebar = false; // Control sidebar visibility
  TransformationController _transformationController = TransformationController();
  String nodeDescription = "";

  @override
  void initState() {
    super.initState();
    _getGraph();
  }

  Future<void> _getGraph() async {
    Graph? fetchedGraph = Graph()
      ..isTree = false;
    fetchedGraph = await serviceProvider.TopologyGraphFromYaml();
    setState(() {
      graph = fetchedGraph;
    });
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
    List<String> lines = nodeId.split('\n');
    Map<String, String> typeMap = {};
    for (var line in lines) {
      List<String> parts = line.split(':');
      if (parts.length == 2) {
        String key = parts[0].trim();
        String value = parts[1].trim();
        typeMap[key] = value;
        print(typeMap["type"]);
      }
    }
    var yamlDescription = await serviceProvider.GetDescriptionByType(typeMap["type"]!.toString());

    // Extract the description string (assuming the key is 'Value')
    YamlMap? descriptionMap = yamlDescription;
    if(descriptionMap!=null)
    {
      print("Mi piace Claudia");
    }
    String description = "";
    if (descriptionMap != null) {
      // Iterate over the key-value pairs in the YamlMap
      descriptionMap.forEach((key, value) {
        description += "$key: $value\n"; // Format the key-value pairs
      });
    }
    //print(description+"m");
    setState(() {
      nodeDescription=description;
    });
    print(nodeDescription);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: graph == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          InteractiveViewer(
            transformationController: _transformationController,
            boundaryMargin: EdgeInsets.all(100),
            minScale: 0.1,
            maxScale: 5.0,
            child: Container(
              width: size.width,
              height: size.height,
              child: GraphView(
                algorithm: FruchtermanReingoldAlgorithm(),
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
                      width: 76,
                      height: 76,
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

  Map<String, dynamic>? getNodeData(String nodeId) {
    // Mock data for demonstration; replace with actual data fetching logic
    return {
      'type': 'ExampleType',
      'status': 'Active',
    };
  }
}
