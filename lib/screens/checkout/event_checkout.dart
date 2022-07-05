import 'package:eventos_da_rep/helpers/math_helper.dart';
import 'package:eventos_da_rep/screens/checkout/checkout_completed.dart';
import 'package:eventos_da_rep/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../../models/event.dart';
import '../../widgets/app_snack_bar.dart';

class EventCheckout extends StatefulWidget {
  final Event event;
  final String paymentIntentClientSecret;

  const EventCheckout({
    Key? key,
    required this.event,
    required this.paymentIntentClientSecret,
  }) : super(key: key);

  @override
  State<EventCheckout> createState() => EventCheckoutState();
}

class EventCheckoutState extends State<EventCheckout> {
  bool _isLoading = false;

  @override
  void initState() {
    _initStripe();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: const Color(0xff102733),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color(0xff102733),
            ),
          ),
          Wrap(
            children: [
              Container(
                margin: const EdgeInsets.all(20.0),
                height: 300.0,
                child: const Image(
                  image: AssetImage("assets/checkout.png"),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: mediaQuery.size.width * 0.75,
                    child: Text(
                      "Você está adquirindo seu convite para o evento ${widget.event.title}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                margin:
                    const EdgeInsets.only(left: 30.0, right: 30.0, top: 30.0),
                child: Row(
                  children: <Widget>[
                    const Expanded(
                      child: Text(
                        "Valor do evento:",
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      centsToReal(widget.event.amount ?? 0),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin:
                    const EdgeInsets.only(left: 30.0, right: 30.0, top: 10.0),
                child: Row(
                  children: const <Widget>[
                    Expanded(
                      child: Text(
                        "Taxa:",
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      "R\$ 10.00",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin:
                    const EdgeInsets.only(left: 30.0, right: 30.0, top: 30.0),
                child: Row(
                  children: const <Widget>[
                    Expanded(
                      child: Text(
                        "Total:",
                        style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                    Text(
                      "R\$ 170.00",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 30.0),
                  width: 400,
                  child: AppButton(
                    isLoading: _isLoading,
                    onPressed: () => _pay(),
                    text: "Pagar",
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _initStripe() async {
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: widget.paymentIntentClientSecret,
        applePay: true,
        googlePay: true,
        merchantCountryCode: "brl",
        merchantDisplayName: "Eventos da REP",
      ),
    );
  }

  _pay() async {
    setState(() {
      _isLoading = true;
    });

    Stripe.instance
        .presentPaymentSheet()
        .then(
          (value) => Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const CheckoutCompleted(),
            ),
          ),
        )
        .onError(
          (error, stackTrace) => {
            setState(
              () {
                _isLoading = false;
              },
            ),
            ScaffoldMessenger.of(context).showSnackBar(
              buildErrorSnackBar(
                  "Ocorreu um erro ao realizar seu pagamento, tente novamente mais tarde."),
            )
          },
        );
  }
}
