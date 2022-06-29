import 'package:flutter/material.dart';

class CoverEventDetails extends StatelessWidget {
  const CoverEventDetails({
    Key? key,
    required this.photo,
  }) : super(key: key);

  final String photo;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      width: double.infinity,
      child: Image.network(
        photo,
        fit: BoxFit.cover,
      ),
    );
  }
}
