import 'package:flutter/material.dart';

import '../constants/palette.dart';

class FABBottomSheetButton extends StatelessWidget {
  const FABBottomSheetButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: lightGreen,
      onPressed: () {
        Scaffold.of(context).showBottomSheet((context) => Container(
              height: 200,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  boxShadow: [BoxShadow(offset: const Offset(0, -1), blurRadius: 5, spreadRadius: 5, color: Colors.grey[300]!)]),
              child: Column(
                children: const [
                  Padding(padding: EdgeInsets.all(8), child: Text("Choose a location to run", style: TextStyle(fontSize: 20, color: darkBlack)))
                ],
              ),
            ));
        // Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddNewRunPage()));
      },
      child: const Icon(
        Icons.add,
        color: Colors.white,
      ),
    );
  }
}
