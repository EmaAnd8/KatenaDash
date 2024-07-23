import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:katena_dashboard/screens/components/deploy_body.dart';
import 'package:katena_dashboard/screens/components/graphiccomponents/simple_node.dart';

class SimpleGraph extends StatefulWidget {
  const SimpleGraph({super.key});

  @override
  State<SimpleGraph> createState() => _SimpleGraphState();
}

class _SimpleGraphState extends State<SimpleGraph> {
  Graph? graph;
  String hoveredNodeId = ''; // Track hovered node
  bool showSidebar = false; // Control sidebar visibility

  @override
  void initState() {
    super.initState();
    _getGraph();
  }

  Future<void> _getGraph() async {
    Graph? fetchedGraph = Graph()..isTree = false;
    fetchedGraph = await ServiceProvider.TopologyGraphFromYaml();
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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: graph == null
          ? const Center(child: CircularProgressIndicator())
          : Stack( // Use Stack to overlay sidebar
        children: [
          InteractiveViewer(
            child: GraphView(
              algorithm: FruchtermanReingoldAlgorithm(),
              graph: graph!,
              paint: Paint()
                ..strokeWidth = 2
                ..style = PaintingStyle.stroke,
              builder: (Node node) {
                String nodeId = node.key?.value ?? '';
                return MouseRegion(
                  onEnter: (_) => setState(() {
                    hoveredNodeId = nodeId;
                    showSidebar = true; // Show sidebar on hover
                  }),
                  onExit: (_) => setState(() {
                    hoveredNodeId = '';
                    showSidebar = false; // Hide on exit
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
          if (showSidebar) // Conditionally render sidebar
            Positioned(
              right: 0, // Position at the right
              top: 0,
              child: Container(
                width: 200,
                height: size.height,
                color: Colors.white,
                padding: const EdgeInsets.all(16.0),
                child: _buildSidebarContent(hoveredNodeId),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSidebarContent(String nodeId) {
    // Fetch additional node data (e.g., from a service)
    final nodeData = getNodeData(nodeId); // Replace with your data fetching logic

    if (nodeData == null) {
      return const Text('Loading node data...');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Node Details: $nodeId',
          style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
        const Divider(),
        // Display relevant node information from `nodeData`
        Text('Type: ${nodeData['type'] ?? 'Unknown'}'),
        Text('Status: ${nodeData['status'] ?? 'N/A'}'),
        // ... (Add other relevant details)
      ],
    );
  }

  // Replace with your actual logic to fetch node data from a service
  Map<String, dynamic>? getNodeData(String nodeId) {
    // Implement
    return {
      'type': 'ExampleType',
      'status': 'Active',
      // Add other relevant details
    };
  }
}
