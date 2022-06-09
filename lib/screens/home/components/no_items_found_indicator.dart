import 'package:flutter/material.dart';

class NoItemsFoundIndicator extends StatelessWidget {
  const NoItemsFoundIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Image.asset(
            "assets/not_found.png",
            width: 110,
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            "A REP não tem nenhum próximo evento agendado, mas fique ligado que logo terá!",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}
