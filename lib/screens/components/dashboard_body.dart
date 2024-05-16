


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:katena_dashboard/screens/login/login_screen.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../firebase_options.dart';
import '../settings/settings_screen.dart';

class  DashboardBody extends StatefulWidget{
  const DashboardBody({super.key});

  @override
  _DashboardState createState() => _DashboardState();


}

class _DashboardState extends State<DashboardBody> {


  void Signout() async
  {



    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    //authentication provided from firebase

    try {
      // if my email is verified then I signin otherwise error



        await FirebaseAuth.instance.signOut();

    }on  FirebaseAuthException catch(e)
    {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size=MediaQuery.of(context).size; //with this query I get (w,h) of the screen
    return Scaffold(
      appBar: AppBar(
        title: const Text('KatenaDashboard'),
        backgroundColor: CupertinoColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context){return SettingsScreen();},),);
            },
          ),
          IconButton(
            icon: const Icon(Icons.login),
            color: Colors.black,
            onPressed: () {
               Signout();
               Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){return LoginScreen();},),);

            },
          ),
        ],
      ),
      body: Container(
        //initialize the chart
         child: Container(
             width: size.width/3,
             child: SfCartesianChart(
                  // Initialize category axis
                  primaryXAxis: CategoryAxis(),
              series: <CartesianSeries>[
              // Initialize line series
              LineSeries<ChartData, String>(
              dataSource: [
              // Bind data source
                  ChartData('Jan', 35),
                  ChartData('Feb', 28),
                  ChartData('Mar', 34),
                  ChartData('Apr', 32),
                  ChartData('May', 40)
              ],
                  xValueMapper: (ChartData data, _) => data.x,
                  yValueMapper: (ChartData data, _) => data.y
                  )
                  ]
              )
        )
      )
        );

  }
}



class ChartData {
  ChartData(this.x, this.y);
  final String x;
  final double? y;
}
