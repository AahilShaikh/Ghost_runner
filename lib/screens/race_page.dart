import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:wakelock/wakelock.dart';
import 'package:wwp_hacks_project/constants/palette.dart';
import 'package:wwp_hacks_project/functions/ai.dart';

import '../services/location.dart';
import '../widgets/action_button.dart';
import '../widgets/alternate_action_button.dart';

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
  late final TextEditingController _runNameController;

  late final Stopwatch timer;

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
                      Column(
                        children: [
                          const Text(
                            "Your Progress",
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(32, 16, 0, 0),
                            child: LinearPercentIndicator(
                              width: 140.0,
                              lineHeight: 14.0,
                              percent: currentIndexOnPath / (widget.ghostData.length - 1),
                              backgroundColor: Colors.grey,
                              progressColor: lightGreen,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 16, 32, 0),
                        child: AlternateActionButton(
                            child: Row(
                              children: const [
                                Text("Cancel"),
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
                                                Navigator.of(context).pop();
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
                  ),
                  Text('Admin Panel'),
                  Expanded(
                    child: TextField(
                      onChanged: (String s) {
                        error = int.parse(s);
                      },
                    ),
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
                        if (snapshot.data != null) {
                          Position data = snapshot.data as Position;
                          LatLng point = LatLng(data.latitude, data.longitude);
                          path[point] = timer.elapsedMilliseconds;
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
