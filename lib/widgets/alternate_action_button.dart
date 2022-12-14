import 'package:flutter/material.dart';


class AlternateActionButton extends StatefulWidget {
  final Widget child;
  final void Function() onPressed;
  const AlternateActionButton({Key? key, required this.child, required this.onPressed}) : super(key: key);

  @override
  State<AlternateActionButton> createState() => _AlternateActionButtonState();
}

class _AlternateActionButtonState extends State<AlternateActionButton> {
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
            decoration: BoxDecoration(
              boxShadow: const [
                  BoxShadow(
                  color: Colors.red,
                  spreadRadius: 0,
                  blurRadius: 5,
                  offset: Offset(0, 0),
                )
              ],
              gradient: LinearGradient(colors: [Colors.red[300]!, Colors.red]),
              borderRadius: const BorderRadius.all(Radius.circular(18.0)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 8, 32, 8),
              child: widget.child,
            )),
      ),
    );
  }
}
