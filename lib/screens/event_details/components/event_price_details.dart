import 'package:flutter/material.dart';

import '../../../helpers/math_helper.dart';

class EventPriceDetails extends StatelessWidget {
  const EventPriceDetails({Key? key, required this.amount}) : super(key: key);

  final int amount;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Icon(
          Icons.monetization_on,
          size: 16,
          color: Colors.white,
        ),
        const SizedBox(
          width: 10,
        ),
        SizedBox(
          width: mediaQuery.size.width * 0.80,
          child: Text(
            "Este evento é pago. Valor: ${centsToReal(amount)}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
