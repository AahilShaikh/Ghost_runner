import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:wakelock/wakelock.dart';
import 'package:wwp_hacks_project/constants/palette.dart';
import 'package:wwp_hacks_project/functions/ai.dart';

import '../services/location.dart';
import '../widgets/action_button.dart';

class RacePage extends StatefulWidget {
  final LinkedHashMap<LatLng, int> ghostData;
  late final List<LatLng> path;

  RacePage(this.ghostData, {Key? key}) : super(key: key) {
    path = ghostData.keys.toList();
  }

  @override
  State<RacePage> createState() => _RacePageState();
}

class _RacePageState extends State<RacePage> {
  //map variables
  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.best,
    distanceFilter: 0,
  );
  int ghostCurrentLocation = 0;

  //location variables
  late final Stream<Position> currentLocationStream;
  late final StreamSubscription<Position> currentLocationSubscription;
  final LinkedHashMap<LatLng, int> path = LinkedHashMap();

  //Run name
  late final TextEditingController _runNameController;

  late final Stopwatch timer;

  double distanceTraveled = 0;
  int currentIndexOnPath = 0;

  ///Release the ghost's position at every millisecond
  Stream<LatLng> ghostStream() async* {
    int count = 0;
    int nextTimeInterval = 0;
    while (count + 1 < widget.ghostData.length) {
      await Future.delayed(Duration(milliseconds: nextTimeInterval));
      nextTimeInterval = widget.ghostData.values.toList()[count + 1] - widget.ghostData.values.toList()[count];
      yield widget.ghostData.keys.toList()[count];
      count++;
    }
  }

  @override
  void initState() {
    super.initState();
    checkLocationPermissions(context);
    //stream of current location as it updates
    currentLocationStream = Geolocator.getPositionStream(locationSettings: locationSettings).asBroadcastStream();
    currentLocationSubscription = currentLocationStream.listen((Position? pos) {});

    _runNameController = TextEditingController();
    timer = Stopwatch();
    timer.start();
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
                      Padding(
                        padding: const EdgeInsets.fromLTRB(32, 16, 0, 0),
                        child: Text("Meters traveled: $distanceTraveled"),
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
                                                Navigator.pop(context);
                                                Navigator.pop(context);
                                              },
                                            ),
                                            TextButton(
                                              child: const Text('Cancel'),
                                              onPressed: () {
                                                currentLocationSubscription.resume();
                                                timer.start();
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
                    subdomains: const ['a', 'b', 'c'],
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
                          if (calcDistanceAsFeet(LatLng(data.latitude, data.longitude), widget.path[currentIndexOnPath]) < 5) {
                            path[LatLng(data.latitude, data.longitude)] = timer.elapsedMilliseconds;
                            currentIndexOnPath++;
                          }
                        }
                        return PolylineLayer(
                          polylineCulling: true,
                          polylines: [
                            Polyline(strokeWidth: 4.0, points: widget.path, color: Colors.grey[800]!),
                            Polyline(
                              strokeWidth: 4.0,
                              points: path.keys.toList(),
                              color: lightGreen,
                            ),
                          ],
                        );
                      }),
                  StreamBuilder(
                    stream: ghostStream(),
                    builder: ((context, snapshot) {
                      LatLng ghostLocation = (snapshot.data ?? LatLng(0, 0)) as LatLng;
                      return MarkerLayer(
                        markers: [
                          Marker(
                            point: ghostLocation,
                            width: 20,
                            height: 20,
                            builder: (context) => Container(
                              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.red),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
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
