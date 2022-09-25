import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:wakelock/wakelock.dart';
import 'package:wwp_hacks_project/constants/palette.dart';
import 'package:wwp_hacks_project/widgets/race_panel.dart';

import '../services/database_manager.dart';
import '../services/location.dart';

class RacePage extends StatefulWidget {
  final LinkedHashMap<LatLng, int> ghostData;
  late final List<LatLng> track;

  RacePage(this.ghostData, {Key? key}) : super(key: key) {
    track = ghostData.keys.toList();
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

  late final Stopwatch stopwatch;

  double distanceTraveled = 0;
  int currentIndexOnPath = 0;
  int error = 25;

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

    stopwatch = Stopwatch();
    stopwatch.start();
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
              panel: RacePanel(path, stopwatch, currentLocationStream),
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
                          LatLng point = LatLng(data.latitude, data.longitude);
                          path[point] = stopwatch.elapsedMilliseconds;
                        }
                        return PolylineLayer(
                          polylineCulling: true,
                          polylines: [
                            Polyline(strokeWidth: 4.0, points: widget.track, color: Colors.grey[600]!),
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
                      if (calcDistanceAsFeet(ghostLocation, widget.track.last) < 20) {
                        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return const Dialog(
                                  child: SizedBox(
                                    height: 100,
                                    width: 100,
                                    child: Center(child: Text("You Lose!!", style: TextStyle(fontSize: 20)))),
                                );
                              });
                        });
                      }
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
                      LatLng point = LatLng(0, 0);
                      if (currentLocation != null) {
                        point = LatLng(currentLocation.latitude, currentLocation.longitude);
                      }
                      DatabaseManager.sendAdvanceRuns();
                      if (calcDistanceAsFeet(point, widget.track.last) < 20) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return const Dialog(
                                  child: SizedBox(
                                      height: 100,
                                      width: 100,
                                      child: Center(
                                        child: Text(
                                          "You Win!!",
                                          style: TextStyle(fontSize: 20),
                                        ),
                                      )),
                                );
                              });
                        });
                      }
                      return MarkerLayer(
                        markers: [
                          Marker(
                            point: point,
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
