import 'package:flutter/material.dart';

class DescriptionEventDetails extends StatelessWidget {
  const DescriptionEventDetails({
    Key? key,
    required this.mediaQuery,
    required this.description,
  }) : super(key: key);

  final MediaQueryData mediaQuery;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          width: mediaQuery.size.width * 0.86,
          child: Text(
            description,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
