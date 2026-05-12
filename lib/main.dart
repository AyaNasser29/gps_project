import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

void main() =>runApp(MaterialApp(
  home: GPS(),
));

class GPS extends StatefulWidget {
  const GPS({super.key});

  @override
  State<GPS> createState() => _GPSState();
}

class _GPSState extends State<GPS> {
String status = "Checking..."; 
  String lat = "0.0";
  String long = "0.0";
//check the permissions and services then return the current position
Future<void> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
      setState(() { status = "Please turn on GPS"; });
      return;
    }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
        setState(() { status = "Permission Denied"; });
        return;
      }
  }
  
  if (permission == LocationPermission.deniedForever) {
    return Future.error(
      'Location permissions are permanently denied, we cannot request permissions.');
  } 
Position position = await Geolocator.getCurrentPosition();

setState(() {
  lat = position.latitude.toString();
  long = position.longitude.toString();
  status = "GPS Ready";
});
}
//update loc every 5meters change
  void liveLocation() {
  Geolocator.getPositionStream(
    locationSettings: LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    ),
  ).listen((Position position) {

    setState(() {
      lat = position.latitude.toString();
      long = position.longitude.toString();
      status = "Live Tracking";
    });

  });
}
  @override
  void initState() {
    super.initState();
    _determinePosition().then((value) {
    liveLocation();
  });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GPS',
        style: TextStyle(color: Colors.amberAccent),
      ),
      backgroundColor:Colors.grey[900],
      centerTitle: true,
      ),
      body: 
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('$status',
        style: TextStyle(color: Colors.grey[900],fontSize: 30.0)),
        SizedBox(height: 20),
          Center(
            child: Card(
              color: Colors.grey[800],
              child: Padding(
              padding: const EdgeInsets.all(50.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Latitude : $lat',style: TextStyle(color: Colors.grey[400],fontSize: 20.0),),
                  Text('Longitude : $long',style: TextStyle(color: Colors.grey[400],fontSize: 20.0),),
                ],
              ),
            ))
            ,
          ),
        ],
      ),
    );
  }
}

