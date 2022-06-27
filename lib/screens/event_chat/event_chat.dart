import 'package:eventos_da_rep/exceptions/exceptions.dart';
import 'package:eventos_da_rep/http/message_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

import '../../widgets/app_snack_bar.dart';

class EventChat extends StatefulWidget {
  final String eventId;
  final String userId;
  final String eventName;

  const EventChat({
    Key? key,
    required this.eventId,
    required this.eventName,
    required this.userId,
  }) : super(key: key);

  @override
  State<EventChat> createState() => _EventChatState();
}

class _EventChatState extends State<EventChat> {
  final MessageClient client = MessageClient();
  late types.User _user;

  @override
  Widget build(BuildContext context) {
    _user = types.User(id: widget.userId);
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat do evento: ${widget.eventName}'),
        backgroundColor: const Color(0xff102733),
      ),
      body: StreamBuilder<List<types.Message>>(
        initialData: const [],
        stream: client.getMessages(widget.eventId),
        builder: (context, snapshot) => Chat(
          messages: snapshot.data ?? [],
          onSendPressed: _handleSendPressed,
          user: _user,
          emptyState: _buildEmptyMessages(),
          theme: const DefaultChatTheme(
            inputBackgroundColor: Colors.white12,
            backgroundColor: Color(0xff102733),
          ),
          l10n: const ChatL10nEn(
            inputPlaceholder: 'Digite sua mensagem aqui',
          ),
          showUserAvatars: true,
          showUserNames: true,
        ),
      ),
    );
  }

  Widget _buildEmptyMessages() => Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(
          horizontal: 24,
        ),
        child: const Text(
          "Esse evento ainda não possui nenhuma mensagem",
          style: TextStyle(
            color: neutral2,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      );

  _handleSendPressed(types.PartialText message) {
    client
        .sendMessage(
          widget.eventId,
          widget.userId,
          message.text,
        )
        .catchError(
          (e) => {
            {
              ScaffoldMessenger.of(context).showSnackBar(
                buildErrorSnackBar(
                  "Ocorreu um erro ao enviar a mensagem.",
                ),
              ),
            }
          },
          test: (e) => e is ApiException,
        );
  }
}
