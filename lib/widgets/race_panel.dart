import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:wwp_hacks_project/services/database_manager.dart';

import '../constants/palette.dart';
import '../services/location.dart';
import 'action_button.dart';
import 'alternate_action_button.dart';

class RacePanel extends StatefulWidget {
  final LinkedHashMap<LatLng, int> track;
  final Stopwatch stopwatch;
  final Stream<Position> dataStream;
  final String locationName;

  const RacePanel(this.track, this.stopwatch, this.dataStream, this.locationName, {Key? key}) : super(key: key);

  @override
  State<RacePanel> createState() => _RacePanelState();
}

class _RacePanelState extends State<RacePanel> {
  Position? prevPos;
  late final StreamSubscription sub;

  double distance = 0;
  double speed = 0;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    sub = widget.dataStream.listen((event) {
      if (prevPos == null) {
        prevPos = event;
        return;
      }
    });

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        distance = (Path.from(widget.track.keys).distance / 1609.0);
        speed = ((distance / widget.stopwatch.elapsedMilliseconds) * 3600000);
      });
    });
  }

  @override
  void dispose() {
    sub.cancel();
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          children: [
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(offset: const Offset(0, 1), blurRadius: 5, spreadRadius: 5, color: Colors.grey[300]!),
                  ],
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(5, 5, 5, 15),
                  child: Column(
                    children: [
                      const Text(
                        "Speed (mph):",
                        style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                      Text(speed.toStringAsFixed(3))
                    ],
                  ),
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(offset: const Offset(0, 1), blurRadius: 5, spreadRadius: 5, color: Colors.grey[300]!),
                  ],
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Your Progress",
                      style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(5, 5, 5, 15),
                      child: LinearPercentIndicator(
                        width: 140.0,
                        lineHeight: 14.0,
                        percent: 0.5,
                        backgroundColor: Colors.grey,
                        progressColor: lightGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          children: [
            const Spacer(),
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(offset: const Offset(0, 1), blurRadius: 5, spreadRadius: 5, color: Colors.grey[300]!),
                ],
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                child: Column(
                  children: [
                    const Text(
                      "Miles traveled:",
                      style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                    Text(distance.toStringAsFixed(3))
                  ],
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 40, 0),
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
                    widget.stopwatch.stop();
                    showDialog(
                        context: context,
                        builder: (context) {
                          return Dialog(
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height / 3,
                              width: MediaQuery.of(context).size.width / 2,
                              child: Column(
                                children: [
                                  const Text(
                                    "Cancel Run?",
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  ActionButton(
                                    child: const Text('End run'),
                                    onPressed: () {
                                      DatabaseManager.updateSpeed(speed);
                                      DatabaseManager.addHistoryData({
                                        "location": widget.locationName,
                                        "speed": speed,
                                        "distanceTraveled": distance,
                                      });
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    },
                                  ),
                                  TextButton(
                                    child: const Text('Cancel'),
                                    onPressed: () {
                                      widget.stopwatch.start();
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
      ],
    );
  }
}
