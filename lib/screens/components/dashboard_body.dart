//import 'dart:nativewrappers/_internal/vm/lib/core_patch.dart';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:katena_dashboard/screens/components/topology_management_body.dart';
import 'package:katena_dashboard/screens/deploy/deploy_screen.dart';
import 'package:katena_dashboard/screens/login/login_screen.dart';
import 'package:katena_dashboard/screens/topology/topologymanangement/topology_management_screen.dart';
import 'package:katena_dashboard/screens/topology/topologyview/topology_view_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../firebase_options.dart';
import '../settings/settings_screen.dart';
import '../services/services_provider.dart';

class DashboardBody extends StatefulWidget {
  const DashboardBody({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<DashboardBody> {
  String? uid1 = FirebaseAuth.instance.currentUser?.email;
  String? name = "";



  @override
  void initState() {
    super.initState();
    initializeFirebase();
    QueryName(uid1);
  }

  Future<void> initializeFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  Future<void> QueryName(String? email) async {
    if (email == null) return;

    CollectionReference users = FirebaseFirestore.instance.collection('Users');
    final query = await users.where("email", isEqualTo: email).get();

    for (var docSnapshot in query.docs) {
      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
      setState(() {
        name = data["Name"];
      });
    }
  }

  Widget newIcon = SvgPicture.asset('assets/icons/person-circle.svg',width:20,height: 20,);
  Future<void> loadProfileImage() async {
    Provider serviceProvider = Provider.instance;
    String url = await serviceProvider.ProfileImage();
    print(url);
    print("url...");
    try {
      setState(() {
        if (url.isNotEmpty) {
          newIcon = Image.network(url, width: 20, height: 20,);
        } else {
          newIcon = SvgPicture.asset('assets/icons/person-circle.svg', width: 20, height: 20,);
        }
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Katena Dashboard', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          /*
          TextButton(
            onPressed: loadProfileImage,
            child: Container(
                child: newIcon,
            ),
          ),

           */
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
                return SettingsScreen();
              }), (route) => false);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              Provider serviceProvider = Provider.instance;
              serviceProvider.Signout();

              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
              return LoginScreen();
              }), (route) => false);
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
                          "Hi, $name!",
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
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),

                              /*child:SfCartesianChart(
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
                              ), */

                        child: LineChart(
                          LineChartData(
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                axisNameWidget: Padding(
                                  padding: const EdgeInsets.only(top: 8.0),

                                ),
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 22,
                                  interval: 1, // Ensures each month is labeled
                                  getTitlesWidget: (value, _) {
                                    switch (value.toInt()) {
                                      case 0:
                                        return Text('Jan', style: TextStyle(fontSize: 12));
                                      case 1:
                                        return Text('Feb', style: TextStyle(fontSize: 12));
                                      case 2:
                                        return Text('Mar', style: TextStyle(fontSize: 12));
                                      case 3:
                                        return Text('Apr', style: TextStyle(fontSize: 12));
                                      case 4:
                                        return Text('May', style: TextStyle(fontSize: 12));
                                      case 5:
                                        return Text('Jun', style: TextStyle(fontSize: 12));
                                      case 6:
                                        return Text('Jul', style: TextStyle(fontSize: 12));
                                      case 7:
                                        return Text('Aug', style: TextStyle(fontSize: 12));
                                      case 8:
                                        return Text('Sep', style: TextStyle(fontSize: 12));
                                      case 9:
                                        return Text('Oct', style: TextStyle(fontSize: 12));
                                      case 10:
                                        return Text('Nov', style: TextStyle(fontSize: 12));
                                      case 11:
                                        return Text('Dec', style: TextStyle(fontSize: 12));
                                      default:
                                        return Text('');
                                    }
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 35,
                                  interval: 20,
                                  getTitlesWidget: (value, _) {
                                    return Text('${value.toInt()}%', style: TextStyle(fontSize: 12));
                                  },
                                ),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            gridData: FlGridData(show: true), // Display the grid background
                            borderData: FlBorderData(
                              show: true,
                              border: Border(
                                left: BorderSide(color: Colors.black, width: 2), // Left border
                                bottom: BorderSide(color: Colors.black, width: 2), // Bottom border
                              ),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                spots: [
                                  FlSpot(0, 10),
                                  FlSpot(1, 30),
                                  FlSpot(2, 40),
                                  FlSpot(3, 70),
                                  FlSpot(4, 60),
                                  FlSpot(5, 80),
                                  FlSpot(6, 50),
                                  FlSpot(7, 90),
                                  FlSpot(8, 110),
                                  FlSpot(9, 100),
                                  FlSpot(10, 120),
                                  FlSpot(11, 140),
                                ],
                                isCurved: true,
                                barWidth: 4,
                                color: Colors.blue, // Set the line color to blue
                                dotData: FlDotData(show: false),
                                belowBarData: BarAreaData(show: false),
                              ),
                            ],
                            lineTouchData: LineTouchData(
                              touchTooltipData: LineTouchTooltipData(
                               // tooltipBgColor: Colors.blueAccent,
                              ),
                              touchCallback: (FlTouchEvent event, LineTouchResponse? response) {},
                              handleBuiltInTouches: true,
                            ),
                          ),
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
                                    offset: const Offset(0, 3),
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
                                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
                                            return TopologyManagementScreen();
                                          }), (route) => false);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          backgroundColor: Colors.blue,
                                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20),
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
                                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
                                            return TopologyViewScreen();
                                          }), (route) => false);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          backgroundColor: Colors.blue,
                                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20),
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
                                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
                                            return DeployScreen();
                                          }), (route) => false);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          backgroundColor: Colors.blue,
                                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20),
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
      child: const Center(
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


