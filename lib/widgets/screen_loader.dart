import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ScreenLoader extends StatelessWidget {
  const ScreenLoader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(color: Color(0xff102733)),
          ),
          Center(
            child: LoadingAnimationWidget.threeArchedCircle(
              color: Colors.white,
              size: 200,
            ),
          ),
        ],
      ),
    );
  }
}
