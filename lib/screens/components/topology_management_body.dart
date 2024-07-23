import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:katena_dashboard/screens/dashboard/dashboard_screen.dart';
import 'package:katena_dashboard/screens/deploy/deploy_screen.dart';
import 'package:katena_dashboard/screens/services/services_provider.dart';

Provider ServiceProvider = Provider.instance;
List<Widget> simpleTopology = [];
List<Map<String, dynamic>> sidebarItems = [];

class TopologyManagementBody extends StatefulWidget {
  const TopologyManagementBody({super.key});

  @override
  _TopologyManagementState createState() => _TopologyManagementState();
}




class _TopologyManagementState extends State<TopologyManagementBody> {
  final _formKey = GlobalKey<FormState>();
  bool _isDrawerOpen = false;



  @override
  Widget build(BuildContext context) {
    String selectedOption = 'Option 1';
    Size size = MediaQuery.of(context).size; //with this query I get (w,h) of the screen
    return Scaffold(
      appBar: AppBar(
        title: const Text('Topology Editor'),
        backgroundColor: CupertinoColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
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
                  child: Text('Make the Deploy'),
                  onTap: () async {
                    ServiceProvider.NodesDefinition();
                  },
                ),
                const PopupMenuItem<String>(
                  value: '2',
                  child: Text('Export your Topology'),
                ),
                const PopupMenuItem<String>(
                  value: '3',
                  child: Text('View your Topology'),
                ),
              ];
            },
            icon: Icon(Icons.menu),
          ),
        ],
      ),
      body: MouseRegion(
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
                    child: const Text(
                      "Here you can manage your Topology ",
                      style: TextStyle(color: Colors.black, fontSize: 30),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Row(),
                ],
              ),
            ),
            AnimatedPositioned(
              duration: Duration(milliseconds: 300),
              left: _isDrawerOpen ? 0 : -250, // Width of the drawer
              top: 0,
              bottom: 0,
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

                      ...sidebarItems.map((item) => ListTile(
                        //leading: Icon(item['icon']),
                        title: Text(item['title']),
                        onTap: item['onTap'],
                      )).toList(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
