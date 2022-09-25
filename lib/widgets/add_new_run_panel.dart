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

  double distanceTraveled = 0;
  Position? prevPos;
  late final StreamSubscription sub;

  @override
  void initState() {
    super.initState();
    _runNameController = TextEditingController();
    sub = widget.dataStream.listen((event) {
      if (prevPos == null) {
        prevPos = event;
        return;
      }
      if (mounted) {
        setState(() {
          distanceTraveled += (calcDistanceAsFeet(LatLng(prevPos!.latitude, prevPos!.longitude), LatLng(event.latitude, event.longitude))) / 5280;
        });
      }
    });
  }

  @override
  void dispose() {
    sub.cancel();
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
              child: Column(
                children: [
                  const Text(
                    "Speed (mph):",
                    style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                  Text(((distanceTraveled / widget.stopwatch.elapsedMilliseconds) * 3.6e+6).toStringAsFixed(3))
                ],
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
                                      DatabaseManager.addNewRunLocation(_runNameController.text, {
                                        "Location Data": latlngToGeoPoint(widget.track.keys.toList()),
                                        "elapsed_time_intervals": widget.track.values.toList(),
                                        'name': _runNameController.text
                                      });
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
        const SizedBox(height: 20,),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 0, 0),
          child: Column(
            children: [
              const Text(
                "Miles traveled:",
                style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold),
              ),
              Text(distanceTraveled.toStringAsFixed(3))
            ],
          ),
        ),
      ],
    );
  }
}
