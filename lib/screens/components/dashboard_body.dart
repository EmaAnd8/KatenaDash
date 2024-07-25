import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:katena_dashboard/screens/components/topology_management_body.dart';
import 'package:katena_dashboard/screens/deploy/deploy_screen.dart';
import 'package:katena_dashboard/screens/login/login_screen.dart';
import 'package:katena_dashboard/screens/topology/topologymanangement/topology_management_screen.dart';
import 'package:katena_dashboard/screens/topology/topologyview/topology_view_screen.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../firebase_options.dart';
import '../settings/settings_screen.dart';
import '../services/services_provider.dart';
import 'dart:io';

final storageRef = FirebaseStorage.instance.ref();
String? name = "";

class DashboardBody extends StatefulWidget {
  const DashboardBody({super.key});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<DashboardBody> {
  String? uid1 = FirebaseAuth.instance.currentUser?.email;

  String? QueryName(email, context) {
    Map<String, String> keyValueMap = {};
    String modifiedString = "";
    String StringParser = "";
    List<String> pairs = [];
    List<String> parts = [];

    CollectionReference users = FirebaseFirestore.instance.collection('Users');
    // Update the population of a city
    final query = users.where("email", isEqualTo: email).get().then((querySnapshot) {
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
          name = keyValueMap["Name"];
          setState(() {});
        }
      }
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    String? alfa = QueryName(uid1, context);
    Size size = MediaQuery.of(context).size; // With this query I get (w,h) of the screen

    return Scaffold(
      appBar: AppBar(
        title: const Text('Katena Dashboard', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () async {
              WidgetsFlutterBinding.ensureInitialized();
              await Firebase.initializeApp(
                options: DefaultFirebaseOptions.currentPlatform,
              );
              Provider serviceProvider = Provider.instance;
              serviceProvider.ProfileImage();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return SettingsScreen();
              }));
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              Provider serviceProvider = Provider.instance;
              serviceProvider.Signout();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                return LoginScreen();
              }));
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        width: size.width,
        height: size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Hi, ${name}!",
                          style: const TextStyle(color: Colors.black, fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              height: size.height * 0.6,
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 5,
                                    blurRadius: 7,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: SfCartesianChart(
                                primaryXAxis: CategoryAxis(),
                                series: <CartesianSeries>[
                                  LineSeries<ChartData, String>(
                                    dataSource: [
                                      ChartData('Jan', 35),
                                      ChartData('Feb', 28),
                                      ChartData('Mar', 34),
                                      ChartData('Apr', 32),
                                      ChartData('May', 40),
                                    ],
                                    xValueMapper: (ChartData data, _) => data.x,
                                    yValueMapper: (ChartData data, _) => data.y,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Container(
                              height: size.height * 0.6,
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 5,
                                    blurRadius: 7,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: <Widget>[
                                  const Padding(
                                    padding: EdgeInsets.only(bottom: 40),
                                    child: Text(
                                      "Nodes Topology Editor",
                                      style: TextStyle(color: Colors.black, fontSize: 30, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                                            return TopologyManagementScreen();
                                          }));
                                        },
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          backgroundColor: Colors.blue, // Set text and icon color
                                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12), // Add padding
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20), // More rounded corners
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Image.asset(
                                              "assets/icons/icons8-topology-53.png",
                                              width: 50,
                                              height: 50,
                                            ),
                                            const Text('Manage Your Topology'),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                                            return TopologyViewScreen();
                                          }));
                                        },
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          backgroundColor: Colors.blue, // Set text and icon color
                                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12), // Add padding
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20), // More rounded corners
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Image.asset(
                                              "assets/icons/icons8-view-80.png",
                                              width: 50,
                                              height: 50,
                                            ),
                                            const Text('View Your Topology'),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                                            return DeployScreen();
                                          }));
                                        },
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          backgroundColor: Colors.blue, // Set text and icon color
                                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12), // Add padding
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20), // More rounded corners
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Image.asset(
                                              "assets/icons/5203923.png",
                                              width: 50,
                                              height: 50,
                                            ),
                                            const Text('Deploy Your Topology!'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            Footer(), // Add footer here
          ],
        ),
      ),
    );
  }
}

class Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: Center(
        child: Text(
          '© 2024 Katena Dashboard. All rights reserved.',
          style: TextStyle(color: Colors.black, fontSize: 14),
        ),
      ),
    );
  }
}

class ChartData {
  ChartData(this.x, this.y);
  final String x;
  final double? y;
}
