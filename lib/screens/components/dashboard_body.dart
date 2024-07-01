import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:katena_dashboard/screens/login/login_screen.dart';
import 'package:katena_dashboard/screens/topology/topology_management_screen.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../firebase_options.dart';
import '../settings/settings_screen.dart';
import '../services/services_provider.dart';
import 'dart:io';


final storageRef = FirebaseStorage.instance.ref();
class  DashboardBody extends StatefulWidget{
  const DashboardBody({super.key});

  @override
  _DashboardState createState() => _DashboardState();



}

class _DashboardState extends State<DashboardBody> {


String? uid1=FirebaseAuth.instance.currentUser?.email;
String ToscatoJSON="";
late List<Widget> elements=[];


Future<void> _loadAndConvertYaml() async {
  Provider serviceProvider=Provider.instance;

  //String result = await serviceProvider.Parser('assets/input/simple-relationship-with-args.yaml');
   elements=(await serviceProvider.TopologyPrinter())!;

}
  @override
  Widget build(BuildContext context) {
   // _loadAndConvertYaml();
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
            icon: const Icon(Icons.account_circle),
            color: Colors.black,
            onPressed: () async {
              WidgetsFlutterBinding.ensureInitialized();
              await Firebase.initializeApp(
                options: DefaultFirebaseOptions.currentPlatform,
              );
              Provider serviceProvider=Provider.instance;
              serviceProvider.ProfileImage();
              _loadAndConvertYaml();
            }),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context){return SettingsScreen();},),);
            },
          ),
          IconButton(
            icon: const Icon(Icons.login),
            color: Colors.black,
            onPressed: () async {
              /*
              WidgetsFlutterBinding.ensureInitialized();
              await Firebase.initializeApp(
                options: DefaultFirebaseOptions.currentPlatform,
              );

               */
               Provider serviceProvider=Provider.instance;
               serviceProvider.Signout();
               Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){return LoginScreen();},),);

            },
          ),

        ],
      ),
      body: SingleChildScrollView(
      child:Column(

      children: <Widget>[
        Container(
           padding: const EdgeInsets.symmetric(vertical: 16.0,horizontal: 16.0),
           alignment:Alignment.topLeft,

           child:Text("Hi!\t${uid1!},",
           style: const TextStyle(color: Colors.black,fontSize: 30),
           textAlign:TextAlign.left,
           ),
        ),
        Row(
          children: <Widget>[
           Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0,horizontal: 16.0),
              width: size.width/2,
              height: size.height-132,
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
          ),
            Container(
              width: size.width/2,
              height: size.height-132,
              padding: const EdgeInsets.symmetric(vertical: 16.0,horizontal: 16.0),
             child:  Column(

                children: <Widget>[

                  const Text("Nodes Topology",
                  style: TextStyle(color: Colors.black,fontSize: 30),
                            textAlign:TextAlign.left),
                Container(
                  //child: Image.asset("assets/icons/icons8-chains-emoji-96.png"),
                 child: Column
                   (children: elements)

                    //child: Text(ToscatoJSON)
                ),
                ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){return TopologyManagementScreen();},),);

                },
                style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Set background color
                foregroundColor: Colors.white, // Set text and icon color
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Add padding
                shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20), // More rounded corners
                ),
                ),
                child: const Text('Manage Your Topology'),
                )
            ],
              ),
    ),



            ],// Your list of grid items
        ),

          ]
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
