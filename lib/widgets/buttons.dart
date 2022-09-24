import 'package:flutter/material.dart';

import '../constants/palette.dart';

class ActionButton extends StatefulWidget {
  final Widget child;
  final void Function() onPressed;
  const ActionButton({Key? key, required this.child, required this.onPressed}) : super(key: key);

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
      ),
      child: InkWell(
        onTap: widget.onPressed,
        child: Container(
          decoration: const BoxDecoration(
            boxShadow: [
               BoxShadow(
                color: Colors.green,
                spreadRadius: 0,
                blurRadius: 5,
                offset:  Offset(0, 0),
              )
            ],
            gradient: LinearGradient(colors: [lightGreen, Colors.green]),
            
            borderRadius: BorderRadius.all(Radius.circular(18.0)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(32, 8, 32, 8),
            child: widget.child,
          )),
      ),
    );
  }
}
