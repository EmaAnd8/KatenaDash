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
      var yamlDescription = await serviceProvider.GetDescriptionByType(typeMap["type"]!.toString());

      YamlMap? descriptionMap = yamlDescription;
      String description = "";
      if (descriptionMap != null) {
        description = _formatYamlMap(descriptionMap, 0);
      }
      setState(() {
        nodeDescription = description;
      });
    } catch (e) {
      print('Error fetching node description: $e');
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
            boundaryMargin: const EdgeInsets.all(200),
            constrained: true,
            child: SizedBox(
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
}
