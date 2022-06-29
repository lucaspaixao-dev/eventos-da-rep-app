import 'package:flutter/material.dart';

class ShowPeopleConfirmedOnEvent extends StatelessWidget {
  const ShowPeopleConfirmedOnEvent({
    Key? key,
    required this.mediaQuery,
  }) : super(key: key);

  final MediaQueryData mediaQuery;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Icon(
          Icons.people,
          size: 16,
          color: Colors.white,
        ),
        const SizedBox(
          width: 10,
        ),
        SizedBox(
          width: mediaQuery.size.width * 0.80,
          child: const Text(
            "Veja quem confirmou presença:",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
