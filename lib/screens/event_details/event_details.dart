import 'dart:async';

import 'package:eventos_da_rep/http/user_client.dart';
import 'package:eventos_da_rep/models/event.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../../providers/shared_preferences_provider.dart';
import 'components/address_box_event_details.dart';
import 'components/chat_event_details.dart';
import 'components/confirm_button_event_details.dart';
import 'components/cover_event_details.dart';
import 'components/date_box_event_details.dart';
import 'components/description_box_event_details.dart';
import 'components/description_event_details.dart';
import 'components/no_users_event.dart';
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
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return FutureBuilder<String?>(
      future: SharedPreferencesProvider().getStringValue(prefUserId),
      builder: (context, snapshot) {
        final String? id = snapshot.data;
        final isGoing = checkIfUserIsGoing(id);

        return Scaffold(
          body: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(color: Color(0xff102733)),
              ),
              SingleChildScrollView(
                child: Column(
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
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                ShowMapEventDetails(
                                  latitude: widget.event.latitude,
                                  longitude: widget.event.longitude,
                                  title: widget.event.title,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                ConfirmButtonEventDetails(
                                  isGoing: isGoing,
                                  isLoading: _isLoading,
                                  onPressed: () =>
                                      _redirectGoingOrNot(isGoing, id),
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
                              vertical: 12,
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
              ),
            ],
          ),
        );
      },
    );
  }

  void _redirectGoingOrNot(isGoing, id) {
    if (!isGoing) {
      _going(id);
    } else {
      _cancel(id);
    }
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

  bool checkIfUserIsGoing(String? userId) {
    if (userId == null) {
      return false;
    }

    if (widget.event.users.isEmpty) {
      return false;
    }

    bool userIsGoing = false;

    for (var user in widget.event.users) {
      if (user.id == userId) {
        userIsGoing = true;
      }
    }

    return userIsGoing;
  }
}
