import 'package:eventos_da_rep/helpers/math_helper.dart';
import 'package:eventos_da_rep/screens/checkout/checkout_completed.dart';
import 'package:eventos_da_rep/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card_brazilian/credit_card_form.dart';
import 'package:flutter_credit_card_brazilian/credit_card_model.dart';
import 'package:flutter_credit_card_brazilian/credit_card_widget.dart';
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
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    void onCreditCardModelChange(CreditCardModel? creditCardModel) {
      setState(() {
        cardNumber = creditCardModel!.cardNumber;
        expiryDate = creditCardModel.expiryDate;
        cardHolderName = creditCardModel.cardHolderName;
        cvvCode = creditCardModel.cvvCode;
        isCvvFocused = creditCardModel.isCvvFocused;
      });
    }

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
          SingleChildScrollView(
            child: Wrap(
              children: [
                CreditCardWidget(
                  cardName: (String value) {},
                  cardNumber: cardNumber,
                  expiryDate: expiryDate,
                  cardHolderName: cardHolderName,
                  cvvCode: cvvCode,
                  showBackView: isCvvFocused,
                  obscureCardNumber: false,
                  obscureCardCvv: false,
                ),
                CreditCardForm(
                  formKey: formKey,
                  obscureCvv: false,
                  obscureNumber: false,
                  cardNumber: cardNumber,
                  cvvCode: cvvCode,
                  cardHolderName: cardHolderName,
                  expiryDate: expiryDate,
                  themeColor: Colors.white,
                  textColor: Colors.white,
                  cardNumberDecoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 0.0),
                    ),
                    border: OutlineInputBorder(),
                    labelStyle: TextStyle(color: Colors.white),
                    labelText: 'Número do cartão',
                    hintText: 'XXXX XXXX XXXX XXXX',
                    hintStyle: TextStyle(color: Colors.white),
                  ),
                  expiryDateDecoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 0.0),
                    ),
                    border: OutlineInputBorder(),
                    labelStyle: TextStyle(color: Colors.white),
                    labelText: 'Validade',
                    hintText: 'XX/XX',
                    hintStyle: TextStyle(color: Colors.white),
                  ),
                  cvvCodeDecoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 0.0),
                    ),
                    border: OutlineInputBorder(),
                    labelStyle: TextStyle(color: Colors.white),
                    labelText: 'CVV',
                    hintText: 'XXX',
                    hintStyle: TextStyle(color: Colors.white),
                  ),
                  cardHolderDecoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 0.0),
                    ),
                    border: OutlineInputBorder(),
                    labelStyle: TextStyle(color: Colors.white),
                    labelText: 'Nome completo',
                    hintStyle: TextStyle(color: Colors.white),
                  ),
                  onCreditCardModelChange: onCreditCardModelChange,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Row(
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
                ),
                Container(
                  margin:
                      const EdgeInsets.only(left: 30.0, right: 30.0, top: 30.0),
                  child: Row(
                    children: <Widget>[
                      const Expanded(
                        child: Text(
                          "Total:",
                          style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                      Text(
                        centsToReal(widget.event.amount!),
                        style: const TextStyle(
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
                      onPressed: () => _pay()
                          .then(
                            (value) => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CheckoutCompleted(),
                              ),
                            ),
                          )
                          .catchError(
                              (e) => ScaffoldMessenger.of(context).showSnackBar(
                                  buildErrorSnackBar(e.error.message)),
                              test: (e) => e is StripeException)
                          .catchError(
                              (e) => ScaffoldMessenger.of(context).showSnackBar(
                                    buildErrorSnackBar(
                                        "Ocorreu um erro ao realizar seu pagamento, tente novamente mais tarde."),
                                  ),
                              test: (e) => e is Exception),
                      text: "Pagar",
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pay() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final monthAndYear = expiryDate.split("/");

      CardDetails cardDetails = CardDetails(
        number: cardNumber,
        cvc: cvvCode,
        expirationMonth: int.parse(monthAndYear.first),
        expirationYear: int.parse(monthAndYear.last),
      );

      await Stripe.instance.dangerouslyUpdateCardDetails(cardDetails);

      const cardParams = PaymentMethodParams.card(
        paymentMethodData: PaymentMethodData(billingDetails: BillingDetails()),
      );

      await Stripe.instance.confirmPayment(
        widget.paymentIntentClientSecret,
        cardParams,
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      rethrow;
    }
  }
}
