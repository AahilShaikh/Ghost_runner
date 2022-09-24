import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:wakelock/wakelock.dart';

import '../services/database_manager.dart';
import '../services/location.dart';
import '../widgets/buttons.dart';

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
  late final StreamSubscription<Position> currentLocationSubscription;
  final Map<LatLng, int> path = {};

  //Run name
  late final TextEditingController _runNameController;

  late final Stopwatch timer;

  double distanceTraveled = 0;

  final Distance distance = const Distance();

  @override
  void initState() {
    super.initState();
    checkLocationPermissions(context);
    //stream of current location as it updates
    currentLocationStream = Geolocator.getPositionStream(locationSettings: locationSettings).asBroadcastStream();
    //whenever the stream updates do the following:

    _runNameController = TextEditingController();
    timer = Stopwatch();
    timer.start();
    currentLocationSubscription = currentLocationStream.listen((Position? pos) {
      if (mapController != null) {
        mapController!.move(LatLng(pos!.latitude, pos.longitude), mapController!.zoom);
      }
    });
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
              borderRadius: const BorderRadius.all(Radius.circular(30.0)),
              panel: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(32, 16, 0, 0),
                        child: Text("Meters traveled: Something"),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 16, 32, 0),
                        child: ActionButton(
                            child: Row(
                              children: const [
                                Text("Done"),
                                Icon(
                                  Icons.navigate_next_sharp,
                                  color: Colors.white,
                                )
                              ],
                            ),
                            onPressed: () {
                              currentLocationSubscription.pause();
                              timer.stop();
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return Dialog(
                                      child: SizedBox(
                                        height: MediaQuery.of(context).size.height / 3,
                                        width: MediaQuery.of(context).size.width / 2,
                                        child: Column(
                                          children: [
                                            const Text("Enter Run Name"),
                                            Expanded(
                                              child: TextField(
                                                controller: _runNameController,
                                              ),
                                            ),
                                            ActionButton(
                                              child: const Text('Finish Run'),
                                              onPressed: () {
                                                DatabaseManager.addNewRunLocation(_runNameController.text, {
                                                  "Location Data": latlngToGeoPoint(path.keys.toList()),
                                                  "elapsed_time_intervals": path.values.toList(),
                                                  'name': _runNameController.text
                                                });
                                                Navigator.pop(context);
                                                Navigator.pop(context);
                                              },
                                            ),
                                            TextButton(
                                              child: const Text('Cancel'),
                                              onPressed: () {
                                                currentLocationSubscription.resume();
                                                timer.stop();
                                              },
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            }),
                      )
                    ],
                  )
                ],
              ),
              body: FlutterMap(
                options: MapOptions(
                  center: LatLng(initialPos.latitude, initialPos.longitude),
                  maxZoom: 18.0,
                  zoom: 18.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c'],
                    userAgentPackageName: 'com.example.ghost_trainer',
                  ),
                  StreamBuilder(
                      stream: currentLocationStream,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          //something
                        }
                        if (snapshot.data != null) {
                          Position data = snapshot.data as Position;
                          path[LatLng(data.latitude, data.longitude)] = timer.elapsedMilliseconds;
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
