import 'package:eventos_da_rep/http/user_client.dart';
import 'package:eventos_da_rep/models/event.dart';
import 'package:flutter/material.dart';

import '../helpers/date_helper.dart';
import '../helpers/string_helper.dart';
import '../providers/shared_preferences_provider.dart';

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

  Widget _getLoading() => const SizedBox(
      width: 16,
      height: 16,
      child: CircularProgressIndicator(
        color: Colors.white,
        strokeWidth: 1.5,
      ));

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
    }).catchError((_) {
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
    }).catchError((_) {
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
          floatingActionButton: FloatingActionButton.extended(
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
            label: (_isLoading)
                ? _getLoading()
                : !isGoing
                    ? const Text('Confirmar Presença')
                    : const Text('Cancelar Presença'),
            icon: (!_isLoading)
                ? !isGoing
                    ? const Icon(Icons.thumb_up)
                    : const Icon(Icons.thumb_down)
                : null,
            backgroundColor: !isGoing ? Colors.green : Colors.red,
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          body: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(color: Color(0xff102733)),
              ),
              SingleChildScrollView(
                //physics: RangeMaintainingScrollPhysics(),
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
                                      fontSize: 14,
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
