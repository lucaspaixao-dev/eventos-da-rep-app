import 'package:flutter/material.dart';

class TopCloseButton extends StatelessWidget {
  const TopCloseButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Positioned(
        right: 0.0,
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: const Align(
            alignment: Alignment.topRight,
            child: CircleAvatar(
              radius: 14.0,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.close,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
