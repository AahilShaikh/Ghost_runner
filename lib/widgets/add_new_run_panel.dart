import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../services/database_manager.dart';
import '../services/location.dart';
import 'action_button.dart';

class AddNewRunPanel extends StatefulWidget {
  final LinkedHashMap<LatLng, int> track;
  final Stopwatch stopwatch;
  final Stream<Position> dataStream;

  const AddNewRunPanel(this.track, this.stopwatch, this.dataStream, {Key? key}) : super(key: key);

  @override
  State<AddNewRunPanel> createState() => _AddNewRunPanelState();
}

class _AddNewRunPanelState extends State<AddNewRunPanel> {
  //Run name
  late final TextEditingController _runNameController;

  Position? prevPos;
  late final StreamSubscription sub;
  double distance = 0;
  double speed = 0;

  late Timer timer;

  @override
  void initState() {
    super.initState();
    _runNameController = TextEditingController();
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
                  padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
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
                                  const Text("Enter Run Name"),
                                  Expanded(
                                    child: TextField(
                                      controller: _runNameController,
                                    ),
                                  ),
                                  ActionButton(
                                    child: const Text('Finish Run'),
                                    onPressed: () {
                                      // final Path smoothedPath = Path.from(widget.track.keys.toList());

                                      DatabaseManager.addNewRunLocation(
                                          _runNameController.text,
                                          {
                                            "Location Data": latlngToGeoPoint(widget.track.keys.toList()),
                                            "elapsed_time_intervals": widget.track.values.toList(),
                                            'name': _runNameController.text,
                                          },
                                          speed,
                                          distance);

                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    },
                                  ),
                                  TextButton(
                                    child: const Text('Cancel'),
                                    onPressed: () {
                                      widget.stopwatch.stop();
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
        const SizedBox(
          height: 20,
        ),
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
      ],
    );
  }
}
