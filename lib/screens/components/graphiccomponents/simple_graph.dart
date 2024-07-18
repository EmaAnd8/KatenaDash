import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:katena_dashboard/screens/components/deploy_body.dart';
import 'package:katena_dashboard/screens/components/graphiccomponents/simple_node.dart';
// ... (Your other imports)

class SimpleGraph extends StatelessWidget {
  const SimpleGraph({super.key});

  Future<Graph?> _getGraph() async {
    Graph? graph = Graph()..isTree = false;
    graph = await ServiceProvider.TopologyGraphFromYaml();
    return graph;
  }

  String _getIconPathForNode(String nodeId) {

    //final nodeType = nodeId.split(".") ;

    //print(nodeId);
    if(nodeId.contains("network")) {
      return 'assets/icons/worldwide_10969702.png'; // Replace with the actual asset path
    }else if(nodeId.contains("network")) // Assuming you meant '2' here
        {
      return 'assets/icons/wallet_4121117.png'; // Replace with the actual asset path
    } else if(nodeId.contains('contract')){
      return 'assets/icons/smart_14210186.png'; // Replace with the actual asset path
    }
    return 'assets/icons/icons8-topology-53.png'; //
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Graph?>(
      future: _getGraph(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return  const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || snapshot.data == null || snapshot.data!.nodes.isEmpty) {
          return Center(child: Text("Error loading graph: ${snapshot.error ?? 'No data'}"));
        } else {
          return InteractiveViewer( // Allow zooming and panning for large graphs
            //constrained: false,
            child: GraphView(
              algorithm: FruchtermanReingoldAlgorithm(),
              graph: snapshot.data!,
              paint: Paint()
                ..strokeWidth = 2
                ..style = PaintingStyle.stroke,
              builder: (Node node) {
                String nodeId = node.key?.value ?? '';
                return SizedBox(
                  width: 60,
                  height: 60,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Image.asset(
                          _getIconPathForNode(nodeId), // Load icon from assets
                          width: 20,
                          height: 20,
                          //color: Colors.blue, // Optional: apply color to the icon
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
                );
              },
            ),
          );
        }
      },
    );
  }
}