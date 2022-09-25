import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:wakelock/wakelock.dart';
import 'package:wwp_hacks_project/widgets/add_new_run_panel.dart';

import '../services/database_manager.dart';
import '../services/location.dart';
import '../widgets/action_button.dart';

class AddNewRunPage extends StatefulWidget {
  const AddNewRunPage({Key? key}) : super(key: key);

  @override
  State<AddNewRunPage> createState() => _AddNewRunPageState();
}

class _AddNewRunPageState extends State<AddNewRunPage> {
  //map variables
  MapController? mapController;
  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.best,
    distanceFilter: 0,
  );

  //location variables
  late final Stream<Position> currentLocationStream;
  final LinkedHashMap<LatLng, int> path = LinkedHashMap();

  late final Stopwatch stopwatch;

  double distanceTraveled = 0;

  final Distance distance = const Distance();

  @override
  void initState() {
    super.initState();
    checkLocationPermissions(context);
    //stream of current location as it updates
    currentLocationStream = Geolocator.getPositionStream(locationSettings: locationSettings).asBroadcastStream();
    //whenever the stream updates do the following:

    stopwatch = Stopwatch();
    stopwatch.start();
  }

  @override
  void dispose() {
    stopwatch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Wakelock.enable();
    return Scaffold(
      body: FutureBuilder(
        future: Geolocator.getCurrentPosition(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          Position initialPos = snapshot.data as Position;
          return SlidingUpPanel(
              maxHeight: 200,
              borderRadius: const BorderRadius.all(Radius.circular(30.0)),
              panel: AddNewRunPanel(path, stopwatch, currentLocationStream),
              body: FlutterMap(
                options: MapOptions(
                  center: LatLng(initialPos.latitude, initialPos.longitude),
                  maxZoom: 18.0,
                  zoom: 18.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: const ['a', 'b', 'c'],
                    userAgentPackageName: 'com.example.ghost_trainer',
                  ),
                  StreamBuilder(
                      stream: currentLocationStream,
                      builder: (context, snapshot) {
                        if (snapshot.data != null) {
                          Position data = snapshot.data as Position;
                          path[LatLng(data.latitude, data.longitude)] = stopwatch.elapsedMilliseconds;
                        }
                        return PolylineLayer(
                          polylineCulling: true,
                          polylines: [
                            Polyline(
                              strokeWidth: 4.0,
                              points: path.keys.toList(),
                              gradientColors: [Colors.black, Colors.blue],
                            ),
                          ],
                        );
                      }),
                  StreamBuilder(
                    stream: currentLocationStream,
                    builder: (context, snapshot) {
                      Position? currentLocation = snapshot.data as Position?;
                      return MarkerLayer(
                        markers: [
                          Marker(
                            point: currentLocation == null ? LatLng(0, 0) : LatLng(currentLocation.latitude, currentLocation.longitude),
                            width: 20,
                            height: 20,
                            builder: (context) => Container(
                              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.blue),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ));
        },
      ),
    );
  }
}
