import 'package:flutter/material.dart';

import '../../../helpers/string_helper.dart';
import '../../../models/event.dart';

class AddressBoxEventDetails extends StatelessWidget {
  const AddressBoxEventDetails({
    Key? key,
    required this.mediaQuery,
    required this.event,
  }) : super(key: key);

  final MediaQueryData mediaQuery;
  final Event event;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Icon(
          Icons.location_on,
          size: 16,
          color: Colors.white,
        ),
        const SizedBox(
          width: 10,
        ),
        SizedBox(
          width: mediaQuery.size.width * 0.81,
          child: Text(
            buildAddressResume(event),
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
