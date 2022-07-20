import 'dart:async';

import 'package:eventos_da_rep/http/payment_client.dart';
import 'package:eventos_da_rep/http/user_client.dart';
import 'package:eventos_da_rep/models/event.dart';
import 'package:eventos_da_rep/screens/checkout/event_checkout.dart';
import 'package:eventos_da_rep/widgets/app_snack_bar.dart';
import 'package:eventos_da_rep/widgets/top_close_button.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../../models/payment.dart';
import '../../providers/shared_preferences_provider.dart';
import 'components/address_box_event_details.dart';
import 'components/chat_event_details.dart';
import 'components/confirm_button_event_details.dart';
import 'components/cover_event_details.dart';
import 'components/date_box_event_details.dart';
import 'components/description_box_event_details.dart';
import 'components/description_event_details.dart';
import 'components/event_price_details.dart';
import 'components/no_users_event.dart';
import 'components/processing_button_event_details.dart';
import 'components/show_map_event_details.dart';
import 'components/show_people_confirmed_event.dart';
import 'components/show_users_on_event.dart';
import 'components/time_box_event_details.dart';
import 'components/title_event_details.dart';

class EventDetails extends StatefulWidget {
  final Event event;

  const EventDetails({
    Key? key,
    required this.event,
  }) : super(key: key);

  @override
  State<EventDetails> createState() => _EventDetailsState();
}

class _EventDetailsState extends State<EventDetails> {
  final _userClient = UserClient();
  final _paymentClient = PaymentClient();
  bool _isLoading = false;
  Payment? _currentPayment;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return FutureBuilder<String?>(
      future: SharedPreferencesProvider().getStringValue(prefUserId),
      builder: (context, snapshot) {
        final String? id = snapshot.data;
        return FutureBuilder(
          future: checkIfUserIsGoing(id),
          builder: (context, snap2) {
            bool isGoing = false;

            if (snap2.connectionState == ConnectionState.waiting) {
              _isLoading = true;
            } else if (snap2.connectionState == ConnectionState.done) {
              isGoing = snap2.data as bool;
              _isLoading = false;
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                buildErrorSnackBar(
                    "Ocorreu um erro ao verificar sua inscrição no evento, tente novamente mais tarde."),
              );
            }

            return Scaffold(
              body: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(color: Color(0xff102733)),
                  ),
                  SingleChildScrollView(
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            CoverEventDetails(
                              photo: widget.event.photo,
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      TitleEventDetails(
                                        mediaQuery: mediaQuery,
                                        title: widget.event.title,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 4,
                                    ),
                                    child: AddressBoxEventDetails(
                                      mediaQuery: mediaQuery,
                                      event: widget.event,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 4,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        ShowMapEventDetails(
                                          latitude: widget.event.latitude,
                                          longitude: widget.event.longitude,
                                          title: widget.event.title,
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Visibility(
                                          visible: (_currentPayment != null &&
                                              _currentPayment!.status ==
                                                  PaymentStatus.processing),
                                          child:
                                              const ProcessingButtonEventDetails(),
                                        ),
                                        Visibility(
                                          visible: (_currentPayment == null) ||
                                              (_currentPayment!.status !=
                                                  PaymentStatus.processing),
                                          child: ConfirmButtonEventDetails(
                                            isGoing: isGoing,
                                            isLoading: _isLoading,
                                            onPressed: () =>
                                                _redirectGoingOrNot(
                                                    isGoing, id),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ChatEventDetails(
                                    isGoing: isGoing,
                                    title: widget.event.title,
                                    userId: id ?? "",
                                    eventId: widget.event.id,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 4,
                                    ),
                                    child: DateBoxEventDetails(
                                      mediaQuery: mediaQuery,
                                      date: widget.event.date,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 4,
                                    ),
                                    child: TimeBoxEventDetails(
                                      mediaQuery: mediaQuery,
                                      event: widget.event,
                                    ),
                                  ),
                                  Visibility(
                                    visible: widget.event.isPayed,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 4,
                                      ),
                                      child: EventPriceDetails(
                                        amount: widget.event.amount ?? 0,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 4,
                                    ),
                                    child: ShowPeopleConfirmedOnEvent(
                                      mediaQuery: mediaQuery,
                                    ),
                                  ),
                                  ShowUsersOnEvent(
                                    mediaQuery: mediaQuery,
                                    event: widget.event,
                                  ),
                                  NoUsersOnEvent(
                                    isEmpty: widget.event.users.isEmpty,
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 10,
                                    ),
                                    child: DecriptionBoxEventDetails(),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 4,
                                    ),
                                    child: DescriptionEventDetails(
                                      mediaQuery: mediaQuery,
                                      description: widget.event.description,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const TopCloseButton(),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _redirectGoingOrNot(isGoing, id) {
    if (!isGoing) {
      if (widget.event.isPayed) {
        _createPayment(id);
      } else {
        _going(id);
      }
    } else {
      if (widget.event.isPayed) {
        _refundAndCancel();
      } else {
        _cancel(id);
      }
    }
  }

  void _refundAndCancel() {
    if (_currentPayment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        buildErrorSnackBar("Pagamento não encontrado."),
      );
    } else {
      setState(() {
        _isLoading = true;
      });

      _paymentClient.refund(_currentPayment!.id).then((_) {
        final result = {
          'title': 'Que pena! 😢😢😢',
          'message':
              'Cancelamento confirmado! Você irá receber o extorno em breve',
          'isSuccess': 'success',
        };

        FirebaseMessaging.instance.unsubscribeFromTopic(widget.event.id).then(
              (value) => {
                setState(() {
                  _isLoading = false;
                }),
                Navigator.pop(context, result),
              },
            );
      }).onError((error, __) {
        setState(() {
          _isLoading = false;
        });

        final result = {
          'title': 'Ops! Ocorreu um erro',
          'message': 'Falha ao cancelar sua ida ao evento, tente novamente!',
          'isSuccess': 'failure',
        };
        Navigator.pop(context, result);
      });
    }
  }

  void _createPayment(String userId) {
    setState(() {
      _isLoading = true;
    });

    _paymentClient
        .createPaymentIntent(widget.event.id, userId)
        .then(
          (value) => Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) {
                return EventCheckout(
                  event: widget.event,
                  paymentIntentClientSecret: value,
                );
              },
            ),
          ),
        )
        .onError(
          (error, stackTrace) => {
            setState(() {
              _isLoading = false;
            }),
            ScaffoldMessenger.of(context).showSnackBar(
              buildErrorSnackBar(
                "Ocorreu um erro ao criar seu pagamento, tente novamente mais tarde.",
              ),
            )
          },
        );
  }

  void _going(String userId) async {
    setState(() {
      _isLoading = true;
    });

    _userClient.going(userId, widget.event.id).then((_) {
      final result = {
        'title': 'Ai sim! 👏👏👏',
        'message': 'Boa! Você está confirmado para o evento!',
        'isSuccess': 'success',
      };

      FirebaseMessaging.instance.subscribeToTopic(widget.event.id).then(
            (value) => {
              setState(() {
                _isLoading = false;
              }),
              Navigator.pop(context, result)
            },
          );
    }).onError((error, __) {
      setState(() {
        _isLoading = false;
      });

      final result = {
        'title': 'Ops! Ocorreu um erro',
        'message': 'Falha ao participar do evento, tente novamente!',
        'isSuccess': 'failure',
      };
      Navigator.pop(context, result);
    });
  }

  void _cancel(String userId) {
    setState(() {
      _isLoading = true;
    });
    _userClient.cancel(userId, widget.event.id).then((_) {
      final result = {
        'title': 'Que pena! 😢😢😢',
        'message': 'Cancelamento confirmado!',
        'isSuccess': 'success',
      };

      FirebaseMessaging.instance.unsubscribeFromTopic(widget.event.id).then(
            (value) => {
              setState(() {
                _isLoading = false;
              }),
              Navigator.pop(context, result),
            },
          );
    }).onError((error, __) {
      setState(() {
        _isLoading = false;
      });

      final result = {
        'title': 'Ops! Ocorreu um erro',
        'message': 'Falha ao cancelar sua ida ao evento, tente novamente!',
        'isSuccess': 'failure',
      };
      Navigator.pop(context, result);
    });
  }

  Future<bool> checkIfUserIsGoing(String? userId) async {
    if (userId == null) {
      return false;
    }

    bool userIsGoing = false;

    if (widget.event.isPayed) {
      List<Payment> payments = await _paymentClient
          .getPaymentsByEventIdAndUserId(widget.event.id, userId);

      for (Payment p in payments) {
        if (p.status == PaymentStatus.success) {
          userIsGoing = true;
          _currentPayment = p;
          await FirebaseMessaging.instance.subscribeToTopic(widget.event.id);
          break;
        }
      }

      return userIsGoing;
    }

    if (widget.event.users.isEmpty) {
      return false;
    }

    for (var user in widget.event.users) {
      if (user.id == userId) {
        userIsGoing = true;
      }
    }

    return userIsGoing;
  }
}
