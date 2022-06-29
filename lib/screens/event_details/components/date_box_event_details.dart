import 'package:flutter/material.dart';

import '../../../helpers/date_helper.dart';

class DateBoxEventDetails extends StatelessWidget {
  const DateBoxEventDetails({
    Key? key,
    required this.mediaQuery,
    required this.date,
  }) : super(key: key);

  final MediaQueryData mediaQuery;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Icon(
          Icons.calendar_month,
          size: 16,
          color: Colors.white,
        ),
        const SizedBox(
          width: 10,
        ),
        SizedBox(
          width: mediaQuery.size.width * 0.80,
          child: Text(
            formatDate(date),
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
