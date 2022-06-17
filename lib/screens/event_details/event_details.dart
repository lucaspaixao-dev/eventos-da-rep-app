import 'dart:async';

import 'package:eventos_da_rep/http/user_client.dart';
import 'package:eventos_da_rep/models/event.dart';
import 'package:eventos_da_rep/screens/event_details/components/map.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../helpers/date_helper.dart';
import '../../helpers/string_helper.dart';
import '../../providers/shared_preferences_provider.dart';
import '../../widgets/loader.dart';

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
  final Future<String?> _userId =
      SharedPreferencesProvider().getStringValue('userId');

  final _userClient = UserClient();

  bool _isLoading = false;

  bool checkIfUserIsGoing(String? userId) {
    if (userId == null) {
      return false;
    }

    if (widget.event.users.isEmpty) {
      return false;
    }

    return widget.event.users.contains(userId);
  }

  void _going(String userId) {
    _userClient.going(userId, widget.event.id).then((_) {
      setState(() {
        _isLoading = false;
      });

      final result = {
        'title': 'Ai sim! 👏👏👏',
        'message': 'Boa! Você está confirmado para o evento!',
        'isSuccess': 'success',
      };

      Navigator.pop(context, result);
    }).onError((_, __) {
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
    _userClient.cancel(userId, widget.event.id).then((_) {
      setState(() {
        _isLoading = false;
      });

      final result = {
        'title': 'Que pena! 😢😢😢',
        'message': 'Cancelamento confirmado!',
        'isSuccess': 'success',
      };

      Navigator.pop(context, result);
    }).onError((_, __) {
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

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return FutureBuilder<String?>(
      future: _userId,
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
                    SizedBox(
                      height: 250,
                      width: double.infinity,
                      child: Image.network(
                        widget.event.photo,
                        fit: BoxFit.cover,
                      ),
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
                              SizedBox(
                                width: mediaQuery.size.width * 0.90,
                                child: Text(
                                  widget.event.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
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
                            child: Row(
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
                                    buildAddressResume(widget.event),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
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
                                ElevatedButton(
                                  onPressed: () {
                                    showCupertinoModalBottomSheet(
                                      context: context,
                                      builder: (_) => Map(
                                        id: widget.event.id,
                                        latitude: widget.event.latitude,
                                        longitude: widget.event.longitude,
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                  ),
                                  child: const Text(
                                    'Ver no mapa',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    setState(() {
                                      _isLoading = true;
                                    });

                                    if (!isGoing) {
                                      _going(id!);
                                    } else {
                                      _cancel(id!);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    primary:
                                        !isGoing ? Colors.green : Colors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                  ),
                                  child: (_isLoading)
                                      ? const Loader()
                                      : !isGoing
                                          ? const Text('Confirmar Presença')
                                          : const Text('Cancelar Presença'),
                                ),
                              ],
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
                                    formatDate(widget.event.date),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
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
                                const Icon(
                                  Icons.timer,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                SizedBox(
                                  width: mediaQuery.size.width * 0.80,
                                  child: Text(
                                    // ignore: prefer_interpolation_to_compose_strings
                                    formatTime(widget.event.begin) +
                                        ' - ' +
                                        formatTime(widget.event.end),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  'Descrição',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
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
                                SizedBox(
                                  width: mediaQuery.size.width * 0.89,
                                  child: Text(
                                    widget.event.description,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
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
              ),
            ],
          ),
        );
      },
    );
  }
}
