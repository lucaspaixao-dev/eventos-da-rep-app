import 'dart:async';

import 'package:eventos_da_rep/screens/event_details/event_details_bloc.dart';
import 'package:eventos_da_rep/services/user_service.dart';
import 'package:eventos_da_rep/widgets/no_items_found_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/event.dart';
import '../../models/payment.dart';
import '../../models/screen_message.dart';
import '../../providers/shared_preferences_provider.dart';
import '../../services/event_service.dart';
import '../../services/firebase_service.dart';
import '../../services/payment_service.dart';
import '../../widgets/app_snack_bar.dart';
import '../../widgets/screen_loader.dart';
import '../checkout/event_checkout.dart';
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
  final String eventId;

  const EventDetails({
    Key? key,
    required this.eventId,
  }) : super(key: key);

  @override
  State<EventDetails> createState() => _EventDetailsState();
}

class _EventDetailsState extends State<EventDetails> {
  final _eventService = EventService();
  final _firebaseService = FirebaseService();
  final _paymentService = PaymentService();
  final _userService = UserService();

  late String _userId;
  late bool _isGoing;
  late Event _event;

  late StreamSubscription _isLoadingSubscription;
  late StreamSubscription _screenMessageSubscription;
  late ScreenMessage _screenMessage;
  bool _isLoading = false;
  Payment? _currentPayment;

  @override
  void initState() {
    final bloc = Provider.of<EventDetailsBloc>(context, listen: false);
    bloc.cleanValue();

    _isLoadingSubscription = bloc.isLoading.listen((result) {
      setState(() {
        _isLoading = result;
      });
    });

    _screenMessageSubscription = bloc.screenMessage.listen((result) {
      setState(() {
        _screenMessage = result;
      });

      if (_screenMessage.title.isNotEmpty &&
          _screenMessage.message.isNotEmpty) {
        SnackBar appSnackBar;
        appSnackBar = AppSnackBar(
          duration: const Duration(
            milliseconds: 2000,
          ),
          title: _screenMessage.title,
          message: _screenMessage.message,
          isSuccess: true,
          elevation: 10.0,
        ).buildSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(appSnackBar);
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _isLoadingSubscription.cancel();
    _screenMessageSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return FutureBuilder(
      future: _getInfos(),
      builder: (context, snaphot) {
        if (!_isLoading) {
          if (snaphot.connectionState == ConnectionState.waiting) {
            return const ScreenLoader();
          } else if (snaphot.connectionState == ConnectionState.done) {
            return _getScreen(mediaQuery);
          } else {
            return const NoItemsFoundIndicator(
              message:
                  "Ocorreu um erro ao verificar sua inscrição no evento, tente novamente mais tarde.",
            );
          }
        } else {
          return _getScreen(mediaQuery);
        }
      },
    );
  }

  Widget _getScreen(MediaQueryData mediaQuery) => Scaffold(
        appBar: AppBar(
          title: const Text("Detalhes do Evento"),
          backgroundColor: const Color(0xff102733),
        ),
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
                        photo: _event.photo,
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
                                  title: _event.title,
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 4,
                              ),
                              child: AddressBoxEventDetails(
                                mediaQuery: mediaQuery,
                                event: _event,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 4,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  ShowMapEventDetails(
                                    latitude: _event.latitude,
                                    longitude: _event.longitude,
                                    title: _event.title,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Visibility(
                                    visible: (_currentPayment != null &&
                                        _currentPayment!.status ==
                                            PaymentStatus.processing),
                                    child: const ProcessingButtonEventDetails(),
                                  ),
                                  Visibility(
                                    visible: (_currentPayment == null) ||
                                        (_currentPayment!.status !=
                                            PaymentStatus.processing),
                                    child: ConfirmButtonEventDetails(
                                      isGoing: _isGoing,
                                      isLoading: _isLoading,
                                      onPressed: () => {
                                        {
                                          if (!_isGoing)
                                            {
                                              if (_event.isPayed)
                                                {
                                                  _createPayment(),
                                                }
                                              else
                                                {
                                                  _goingToFreeEvent(),
                                                }
                                            }
                                          else
                                            {
                                              if (_event.isPayed)
                                                {
                                                  _refundAndCancel(),
                                                }
                                              else
                                                {
                                                  _cancel(),
                                                }
                                            }
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ChatEventDetails(
                              isGoing: _isGoing,
                              title: _event.title,
                              userId: _userId,
                              eventId: _event.id,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 4,
                              ),
                              child: DateBoxEventDetails(
                                mediaQuery: mediaQuery,
                                date: _event.date,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 4,
                              ),
                              child: TimeBoxEventDetails(
                                mediaQuery: mediaQuery,
                                event: _event,
                              ),
                            ),
                            Visibility(
                              visible: _event.isPayed,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 4,
                                ),
                                child: EventPriceDetails(
                                  amount: _event.amount ?? 0,
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
                              event: _event,
                            ),
                            NoUsersOnEvent(
                              isEmpty: _event.users.isEmpty,
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
                                description: _event.description,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  //const TopCloseButton(),
                ],
              ),
            ),
          ],
        ),
      );

  void _refundAndCancel() async {
    if (_currentPayment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        buildErrorSnackBar("Pagamento não encontrado."),
      );
    } else {
      final bloc = Provider.of<EventDetailsBloc>(context, listen: false);
      bloc.updateLoading(true);

      try {
        await _paymentService.refundPayment(_currentPayment!.id);
        await _firebaseService.unsubscribeToTopic(_event.id);

        ScreenMessage message = ScreenMessage(
          'Que pena! 😢😢😢',
          'Cancelamento confirmado! Você irá receber o extorno em breve',
        );

        bloc.updateMessage(message);
        bloc.updateLoading(false);
      } catch (e) {
        bloc.updateLoading(false);

        ScaffoldMessenger.of(context).showSnackBar(
          buildErrorSnackBar(
            "Falha ao cancelar sua ida ao evento, tente novamente!",
          ),
        );
      }
    }
  }

  void _createPayment() async {
    final bloc = Provider.of<EventDetailsBloc>(context, listen: false);
    bloc.updateLoading(true);

    try {
      String paymentId =
          await _paymentService.createPayment(_event.id, _userId);
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            return EventCheckout(
              event: _event,
              paymentIntentClientSecret: paymentId,
            );
          },
        ),
      );
    } catch (e) {
      bloc.updateLoading(false);

      ScaffoldMessenger.of(context).showSnackBar(
        buildErrorSnackBar(
          "Ocorreu um erro ao criar seu pagamento, tente novamente mais tarde.",
        ),
      );
    }
  }

  void _goingToFreeEvent() async {
    final bloc = Provider.of<EventDetailsBloc>(context, listen: false);
    bloc.updateLoading(true);

    try {
      await _userService.goingToEvent(_userId, _event.id);
      ScreenMessage message = ScreenMessage(
        'Ai sim! 👏👏👏',
        'Você está confirmado para o evento!',
      );

      await _firebaseService.subscribeToTopic(_event.id);
      bloc.updateMessage(message);
      bloc.updateLoading(false);
    } catch (e) {
      bloc.updateLoading(false);

      ScaffoldMessenger.of(context).showSnackBar(
        buildErrorSnackBar(
          "Falha ao participar do evento, tente novamente!",
        ),
      );
    }
  }

  void _cancel() async {
    final bloc = Provider.of<EventDetailsBloc>(context, listen: false);
    bloc.updateLoading(true);

    try {
      await _userService.exitToEvent(_userId, _event.id);
      ScreenMessage message = ScreenMessage(
        'Que pena! 😢😢😢',
        'Cancelamento confirmado!',
      );

      await _firebaseService.unsubscribeToTopic(_event.id);
      bloc.updateMessage(message);
      bloc.updateLoading(false);
    } catch (e) {
      bloc.updateLoading(false);

      ScaffoldMessenger.of(context).showSnackBar(
        buildErrorSnackBar(
          "Falha ao sair do evento, tente novamente!",
        ),
      );
    }
  }

  Future<void> _getInfos() async {
    var values = await Future.wait([
      SharedPreferencesProvider().getStringValue(prefUserId),
      _eventService.getEventById(widget.eventId)
    ]);

    final userId = values[0] as String?;
    final event = values[1] as Event;
    _event = event;

    if (userId == null) {
      throw Exception("Usuário não encontrado");
    }

    _userId = userId;
    _isGoing = await _eventService.checkIfUserIsGoingToEvent(userId, _event);

    if (_isGoing) {
      await _firebaseService.subscribeToTopic(_event.id);
    }

    _currentPayment =
        await _paymentService.getSuccessPaymentOnEvent(userId, _event.id);
  }
}
