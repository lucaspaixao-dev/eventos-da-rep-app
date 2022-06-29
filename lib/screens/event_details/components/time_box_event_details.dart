import 'package:flutter/material.dart';

import '../../../helpers/date_helper.dart';
import '../../../models/event.dart';

class TimeBoxEventDetails extends StatelessWidget {
  const TimeBoxEventDetails(
      {Key? key, required this.mediaQuery, required this.event})
      : super(key: key);

  final MediaQueryData mediaQuery;
  final Event event;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Icon(
          Icons.timer,
          size: 16,
          color: Colors.white,
        ),
        const SizedBox(
          width: 10,
        ),
        SizedBox(
          width: mediaQuery.size.width * 0.80,
          child: Text(
            // ignore: prefer_interpolation_to_compose_strings
            formatTime(event.begin) + ' - ' + formatTime(event.end),
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
