import 'package:eventos_da_rep/widgets/app_back_button.dart';
import 'package:flutter/material.dart';

class CheckoutCompleted extends StatelessWidget {
  const CheckoutCompleted({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color(0xff102733),
            ),
          ),
          Wrap(
            children: [
              const SizedBox(
                height: 600.0,
                child: Image(
                  image: AssetImage("assets/completed.png"),
                ),
              ),
              Center(
                child: SizedBox(
                  width: mediaQuery.size.width * 0.75,
                  child: const Text(
                    "Compra realizada com sucesso! Nós vemos no evento! 😍",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 30.0),
                  width: 400,
                  child: const AppBackButton(isLoading: false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
